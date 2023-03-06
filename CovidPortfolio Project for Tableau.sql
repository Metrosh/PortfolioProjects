--This dataset was downloaded 2/22/23 from the public dataset available here: https://ourworldindata.org/coronavirus. This original dataset contains 259,147 rows and 67 columns of data.
--This dataset was separated into two separate excel files to track deaths and vaccination records separately and then later joined using SQL to perform some of these queries using SQL Server 2022.

--These initial four queries were used to generate a presentation of covid numbers as of 2/22/23 available through Tableau public: 
--https://public.tableau.com/shared/BYW8T5T9J?:display_count=n&:origin=viz_share_link
--This Tableau link is best viewed in full screen.

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
--Return the continent & total deaths belonging to each continent from coviddeaths table, avoiding unwanted location & continent descriptors within the dataset (to avoid duplicate info) sorted in descending order by total death count
SELECT
	[continent],
	SUM(CAST(new_deaths AS BIGINT)) AS totaldeathcount
FROM PortfolioProject2..CovidDeaths
WHERE 
	continent IS NOT NULL
	AND new_deaths IS NOT NULL
	AND [location] NOT IN
		('World',
		'European Union',
		'International')
GROUP BY [continent]
ORDER BY totaldeathcount DESC

--3
--Return location, population, highest number of infected and caclulated percentage of population infected for each location from coviddeaths table ordered by percentpopulationinfected.
SELECT
	[location],
	[population],
	MAX(total_cases) AS highestinfectioncount,
	MAX((total_cases/[population])) * 100 AS percentpopulationinfected
FROM PortfolioProject2..CovidDeaths
WHERE 
	total_cases IS NOT NULL
	AND [population] IS NOT NULL
GROUP BY
	[location],
	[population]
ORDER BY percentpopulationinfected DESC

--4
--same as query 3 but included date
SELECT
	[location],
	[population],
	[date],
	MAX(total_cases) AS highestinfectioncount,
	MAX((total_cases/[population])) * 100 AS percentpopulationinfected
FROM PortfolioProject2..CovidDeaths
WHERE 
	total_cases IS NOT NULL
	AND [population] IS NOT NULL
GROUP BY
	[location],
	[population],
	[date]
ORDER BY percentpopulationinfected DESC


--These additional queries were not used in the tableau presentation

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
