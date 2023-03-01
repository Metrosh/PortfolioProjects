SELECT *
FROM PortfolioProject2..CovidDeaths
Where continent is not Null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject2..CovidVaccinations
--Where continent is not Null
--ORDER BY 3,4
--Select data that we are going to be using

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject2..CovidDeaths
Where continent is not Null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in the US, removed data with 0 cases and 0 deaths.
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE location like '%states%' AND total_cases > 0 AND total_deaths > 0 AND continent is not Null
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of US population got Covid, removed data with 0 cases
SELECT Location,date,total_cases,population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject2..CovidDeaths
WHERE location like '%states%' AND total_cases > 0 AND continent is not Null	
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectedPercentage
FROM PortfolioProject2..CovidDeaths
WHERE total_cases > 0 AND continent is not Null
GROUP BY population,location
ORDER BY HighestInfectedPercentage desc

--Showing Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE total_cases > 0 AND continent is not Null
GROUP BY location
ORDER BY TotalDeathCount desc

--let's break things down by continent

--Showing continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
WHERE total_cases > 0 AND continent is not Null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE continent is not Null AND new_cases > 0
ORDER BY 1,2

-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RunningTotalVaccinations
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RunningTotalVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RunningTotalVaccinations
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RunningTotalVaccinations/Population)*100 as RunningPercentageVaccinated
FROM PopsvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent varchar(255), Location varchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RunningTotalVaccinations numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RunningTotalVaccinations
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (RunningTotalVaccinations/Population)*100 as RunningPercentageVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3

--Creating View to Store Data for Later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RunningTotalVaccinations
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
