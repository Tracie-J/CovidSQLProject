--Checking original data

SELECT *
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3,4

--Select Data that we are going to be using.

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Looking at the Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in the United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
Where Location like '%states%'
AND continent is not null
ORDER BY 1, 2

--Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Which Countries have the highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Shows Countries with highest death count per population

SELECT Location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Showing continents with highest death count per population.

SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinated
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,
 dea.date) as RollingVaccinated
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null

SELECT*, (RollingVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Create Views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinated
FROM CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated


CREATE VIEW USADeathPercentage as
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE Location like '%states%'
AND continent is not null


CREATE VIEW PercentPopulationGotCovid as
SELECT Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidProject..CovidDeaths
WHERE continent is not null


CREATE VIEW CountryHighestInfectionRate as
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population


CREATE VIEW CountryHighestDeathRate as
SELECT Location, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location

CREATE VIEW DeathCountByContinent as
SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent is not null
GROUP BY continent