--Select * 
--FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE continent is not null
--ORDER BY 3,4

--Select * 
--FROM PortfolioProjects.dbo.CovidVaccinations$
--WHERE continent is not null
--ORDER BY 3,4

-- Select the Data to be used.

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- View Total Cases compared to Total Deaths.
-- Show probability of death if covid is caught.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
--WHERE location like '%states%'
ORDER BY 1,2

-- View Total Cases vs Population
-- Shows Percetange of poplulation that has contracted covid
Select location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
WHERE location like '%states%'
ORDER BY 1,2


--Viewing countries with highest infenction rates compared to population.

Select location, population, MAX(total_cases) AS HighestInfenctionCount, 
MAX((total_cases/population))*100 AS MaxCasePercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY MaxCasePercentage desc


--Shows Countries by Highest Death Count by population

Select location, MAX(cast(Total_deaths as int)) AS TotalDeaths
FROM PortfolioProjects..CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeaths desc


--Highest death counts by continent

Select continent, MAX(cast(Total_deaths as int)) AS TotalDeaths
FROM PortfolioProjects..CovidDeaths$
--where location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths desc

--Proper Continent formatting
--null provented proper inclusion

Select location, MAX(cast(Total_deaths as int)) AS TotalDeaths
FROM PortfolioProjects..CovidDeaths$
--where location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeaths desc


-- Global numbers

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
--WHERE location like '%states%'
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinations
--, (RollingVaccinations/population)*100
FROM PortfolioProjects.dbo.CovidDeaths$ AS dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

-- CTE to get Vaccitnation Percentages

WITH POPvsVAC (continent, locations, date, population, new_vaccinations, RollingVaccinations) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinations
--, (RollingVaccinations/population)*100
FROM PortfolioProjects.dbo.CovidDeaths$ AS dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT*, (RollingVaccinations/population)*100 AS VacPercentage
FROM POPvsVAC

--TEMP Table version of Vac Percentage

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)



INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinations
--, (RollingVaccinations/population)*100
FROM PortfolioProjects.dbo.CovidDeaths$ AS dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT*, (RollingVaccinations/population)*100 AS VacPercentage
FROM #PercentPopulationVaccinated

-- Creating View to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinations
--, (RollingVaccinations/population)*100
FROM PortfolioProjects.dbo.CovidDeaths$ AS dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


-- View for Death Percentages

CREATE VIEW DeathPercentage AS
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
--WHERE location like '%states%'


-- View for for Highest Infenction counts

CREATE VIEW HighestInfection AS
Select location, population, MAX(total_cases) AS HighestInfenctionCount, 
MAX((total_cases/population))*100 AS MaxCasePercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location,population


-- View for vaccination percentages
CREATE VIEW VacPercentage AS
WITH POPvsVAC (continent, locations, date, population, new_vaccinations, RollingVaccinations) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingVaccinations
--, (RollingVaccinations/population)*100
FROM PortfolioProjects.dbo.CovidDeaths$ AS dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT*, (RollingVaccinations/population)*100 AS VacPercentage
FROM POPvsVAC