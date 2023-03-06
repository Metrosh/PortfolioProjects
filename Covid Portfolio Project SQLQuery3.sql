--This dataset was downloaded 2/22/23 from the public dataset available here: https://ourworldindata.org/coronavirus. This original dataset contains 259,147 rows and 67 columns of data.
--This dataset was separated into two separate excel files to track deaths and vaccination records separately and then later joined using SQL to perform some of these queries using SQL Server 2022.
--These are queries ran as practice to review and observe the data.
--WHERE contintent IS NOT Null is used to remove unwanted returns from the dataset including aggregated numbers for High Income, Low Income, and other descriptors.

SELECT *
FROM PortfolioProject2..CovidDeaths
WHERE [continent] IS NOT NULL
ORDER BY 
	[location], 
	[date]

SELECT 
	[Location],
	[date],
	[total_cases],
	[new_cases],
	[total_deaths],
	[population]
FROM PortfolioProject2..CovidDeaths
WHERE [continent] IS NOT NULL
ORDER BY 
	[location], 
	[date]

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the US, removed data with 0 cases and 0 deaths.
SELECT 
	[Location], 
	[date], 
	[total_cases], 
	[total_deaths], 
	([total_deaths]/[total_cases]) * 100 AS [DeathPercentage]
FROM PortfolioProject2..CovidDeaths
WHERE 
	[location] LIKE '%states%' 
	AND [total_cases] > 0 
	AND [total_deaths] > 0 
	AND [continent] IS NOT NULL
ORDER BY 
	[location], 
	[date]

--Looking at total cases vs population
--Shows what percentage of US population got Covid, removed data with 0 cases
SELECT 
	[Location], 
	[date], 
	[total_cases], 
	[population], 
	([total_cases]/[population]) * 100 AS [InfectedPercentage]
FROM PortfolioProject2..CovidDeaths
WHERE 
	[location] LIKE '%states%' 
	AND [total_cases] > 0 
	AND [continent] IS NOT NULL	
ORDER BY 
	[location],
	[date]

--Looking at countries with highest infection rate compared to population
SELECT
	[Location],
	[population],
	MAX([total_cases]) AS [HighestInfectionCount],
	MAX(([total_cases]/[population])) * 100 AS [HighestInfectedPercentage]
FROM PortfolioProject2..CovidDeaths
WHERE 
	[total_cases] > 0 
	AND [continent] IS NOT NULL
GROUP BY 
	[population], 
	[location]
ORDER BY [HighestInfectedPercentage] DESC

--Showing Countries with highest death count per population 
--CAST AS BIGINT is used to convert total_deaths into integers from here on out
SELECT 
	[Location], 
	MAX(CAST([total_deaths] AS BIGINT)) AS [TotalDeathCount]
FROM PortfolioProject2..CovidDeaths
WHERE 
	[total_cases] > 0 
	AND [continent] IS NOT NULL
GROUP BY [location]
ORDER BY [TotalDeathCount] DESC

--Showing continents with the highest death count
SELECT 
	[continent], 
	MAX(CAST([total_deaths] AS BIGINT)) AS [TotalDeathCount]
FROM PortfolioProject2..CovidDeaths
WHERE 
	[total_cases] > 0 
	AND [continent] IS NOT NULL
GROUP BY [continent]
ORDER BY [TotalDeathCount] DESC


--Global Numbers
SELECT 
	SUM([new_cases]) AS [TotalCases], 
	SUM(CAST([new_deaths] AS BIGINT)) AS [TotalDeaths], 
	SUM(CAST([new_deaths] AS BIGINT))/SUM([new_cases]) * 100 AS [DeathPercentage]
FROM PortfolioProject2..CovidDeaths
WHERE [continent] IS NOT NULL

-- Looking at total population vs vaccinations
SELECT 
	dea.[continent], 
	dea.[location], 
	dea.[date], 
	dea.[population], 
	vac.[new_vaccinations],
	SUM(CAST(vac.[new_vaccinations] AS BIGINT)) OVER (PARTITION BY dea.[location] ORDER BY dea.[location],dea.[date]) AS [RunningTotalVaccinations]
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.[location] = vac.[location]
	AND dea.[date] = vac.[date]
WHERE dea.[continent] IS NOT NULL
ORDER BY 
	[location], 
	[date]

--USE CTE
WITH PopsvsVac 
	([Continent], 
	[Location], 
	[Date], 
	[Population], 
	[New_Vaccinations], 
	[RunningTotalVaccinations])
AS
(SELECT 
	dea.[continent], 
	dea.[location], 
	dea.[date], 
	dea.[population], 
	vac.[new_vaccinations], 
	SUM(CONVERT(bigint,vac.[new_vaccinations])) OVER (PARTITION BY dea.[location] ORDER BY dea.[location],dea.[date]) AS [RunningTotalVaccinations]
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.[location] = vac.[location]
	AND dea.[date] = vac.[date]
WHERE dea.[continent] IS NOT NULL)

SELECT 
	*, 
	([RunningTotalVaccinations]/[Population])*100 AS [RunningPercentageVaccinated]
FROM PopsvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	([Continent] varchar(255), 
	[Location] varchar(255), 
	[Date] datetime, 
	[Population] numeric, 
	[New_Vaccinations] numeric, 
	[RunningTotalVaccinations] numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	dea.[continent], 
	dea.[location], 
	dea.[date], 
	dea.[population], 
	vac.[new_vaccinations], 
	SUM(CONVERT(bigint,vac.[new_vaccinations])) OVER (PARTITION BY dea.[location] ORDER BY dea.[location],dea.[date]) AS [RunningTotalVaccinations]
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.[location] = vac.[location]
	AND dea.[date] = vac.[date]
WHERE dea.[continent] IS NOT NULL
SELECT 
	*, 
	([RunningTotalVaccinations]/[Population]) * 100 AS [RunningPercentageVaccinated]
FROM #PercentPopulationVaccinated
ORDER BY 
	[location], 
	[date]

--Creating View to Store Data for Later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
dea.[continent], 
dea.[location], 
dea.[date], 
dea.[population], 
vac.[new_vaccinations],
SUM(CONVERT(bigint,vac.[new_vaccinations])) OVER (PARTITION BY dea.[location] ORDER BY dea.[location],dea.[date]) AS [RunningTotalVaccinations]
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.[location] = vac.[location]
	AND dea.[date] = vac.[date]
WHERE dea.[continent] IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
