--Queries used for Tableau project

-- 1
--Return the total cases, deaths, and a calculated death percentage from coviddeaths table while also removing unwanted location descriptors within the dataset (to avoid duplicate information)
SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS BIGINT)) AS total_deaths,
	SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases) * 100 AS deathpercentage
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY
	total_cases,
	total_deaths

--2
--Return the location & total deaths belonging to each location from coviddeaths table, avoiding unwanted location descriptors within the dataset (to avoid duplicate info) sorted in descending order by total death count
SELECT
	[location],
	SUM(CAST(new_deaths AS BIGINT)) AS totaldeathcount
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
	AND [location] NOT IN
		('World',
		'European Union',
		'International')
GROUP BY [location]
ORDER BY totaldeathcount DESC

--3
--Return location, population, highest number of infected and caclulated percentage of population infected for each location from coviddeaths table ordered by percentpopulationinfected.
SELECT
	[location],
	[population],
	MAX(total_cases) AS highestinfectioncount,
	MAX((total_cases/[population])) * 100 AS percentpopulationinfected
FROM PortfolioProject2..CovidDeaths
GROUP BY
	[location],
	[population]
ORDER BY percentpopulationinfected DESC

--4
--same as query 3 but included date
SELECT
	[location],
	[population],
	MAX(total_cases) AS highestinfectioncount,
	MAX((total_cases/[population])) * 100 AS percentpopulationinfected
FROM PortfolioProject2..CovidDeaths
GROUP BY
	[location],
	[population],
	[date]
ORDER BY percentpopulationinfected DESC


--additional queries not used for tableau

--1
SELECT 
	dea.continent, 
	dea.[location], 
	dea.[date], 
	dea.[population], 
	MAX(vac.total_vaccinations) AS rollingpeoplevaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.[location] = vac.[location]
	AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL 
GROUP BY 
	dea.continent, 
	dea.[location], 
	dea.[date], 
	dea.[population]
ORDER BY 
	[continent],
	[location],
	[date]

--2
SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS BIGINT)) AS total_deaths,
	SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases) * 100 AS deathpercentage
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 
	[total_cases],
	[total_deaths]

--Just a double check of the above here
SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS BIGINT)) AS total_deaths,
	SUM(CAST(new_deaths AS BIGINT))/SUM(new_cases) * 100 AS deathpercentage
FROM PortfolioProject2..CovidDeaths
WHERE [location] = 'World'
ORDER BY
	[total_cases],
	[total_deaths]

--3
SELECT 
	[location], 
	SUM(CAST(new_deaths AS BIGINT)) AS totaldeathcount
FROM PortfolioProject2..CovidDeaths
WHERE 
	continent IS NULL 
	AND [location] NOT IN 
		('World', 
		'European Union', 
		'International')
GROUP BY [location]
ORDER BY TotalDeathCount DESC

--4
SELECT 
	[location], 
	[population], 
	MAX(total_cases) AS highestinfectioncount,  
	MAX((total_cases/[population])) * 100 AS percentpopulationinfected
FROM PortfolioProject2..CovidDeaths
GROUP BY 
	[location], 
	[population]
ORDER BY percentpopulationinfected DESC

--5
SELECT 
	[location], 
	[date], 
	total_cases,
	total_deaths, 
	(total_deaths/total_cases) * 100 AS deathpercentage,
	[population]
FROM PortfolioProject2..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY
	[location],
	[date]

--6
WITH popvsvac 
	(Continent, 
	[Location], 
	[Date], 
	[Population], 
	New_Vaccinations, 
	RollingPeopleVaccinated)
	AS
		(
		SELECT 
			dea.continent, 
			dea.[location], 
			dea.[date], 
			dea.[population], 
			vac.new_vaccinations,
			SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.[Location] ORDER BY dea.[location], dea.[Date]) AS RollingPeopleVaccinated
		FROM PortfolioProject2..CovidDeaths dea
		JOIN PortfolioProject2..CovidVaccinations vac
			ON dea.[location] = vac.[location]
			AND dea.[date] = vac.[date]
		WHERE dea.continent IS NOT NULL
		)
SELECT 
	*, 
	(RollingPeopleVaccinated/[Population]) * 100 AS PercentPeopleVaccinated
FROM popvsvac


--7
SELECT 
	[Location], 
	[Population],
	[date], 
	MAX(total_cases) AS HighestInfectionCount,  
	MAX((total_cases/[population])) * 100 AS PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths
GROUP BY 
	[Location], 
	[Population], 
	[date]
ORDER BY PercentPopulationInfected DESC