SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Look at total_deaths vs. total_cases
--shows the likelihood of dying if you contract Covid in Canada
SELECT location,continent, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE location like '%canada%' --AND continent IS NOT NULL
ORDER BY 1,2

--looking at the total_cases vs. population
--shows the percentage of population got Covid
SELECT location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
--WHERE location like '%canada%'
ORDER BY 1,2

--looking at the countries with highest infection rate compare to population
SELECT location, population, MAX(total_cases) AS HighestInfectionRate,  
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC


-- shows countries with higest death counts by population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

--break down by continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT IN ('European Union', 'International', 'World')
GROUP BY location
ORDER BY TotalDeathCount DESC
 --SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
 --FROM PortfolioProject..CovidDeaths
 --WHERE continent is not null
 --GROUP BY continent
 --ORDER BY TotalDeathCount DESC

 --Global numbers per day
 SELECT date, SUM(new_cases) AS NewCaseCount, SUM(cast(new_deaths as int)) AS NewDeathCount, 
 (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 GROUP BY date
 ORDER BY 1,2

--global number total
SELECT SUM(new_cases) AS NewCaseCount, SUM(cast(new_deaths as int)) AS NewDeathCount, 
 (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

 --join two tables
 SELECT *
 FROM PortfolioProject..CovidDeaths AS dea
 join PortfolioProject..CovidVaccinations AS vac
 on dea.date = vac.date AND dea.location = vac.location

 --look at total population vs. vaccination
 --1. using CTE
 WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVacTotal)
 as(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( int, vac.new_vaccinations)) OVER (
	PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVacTotal
	FROM PortfolioProject..CovidDeaths AS dea
	join PortfolioProject..CovidVaccinations AS vac
	on dea.date = vac.date AND dea.location = vac.location
	WHERE dea.continent is not null
 )
 SELECT *, (RollingVacTotal/population)*100 AS TotalVacPercentage
 FROM PopvsVac

 --Total vaccination percentage per country
 --2. using temp table
 DROP TABLE IF EXISTS #TotalVactPercentage
 CREATE TABLE #TotalVactPercentage
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingTestTotal numeric)

 INSERT INTO #TotalVactPercentage
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( int, vac.new_vaccinations)) OVER (
	PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingVacTotal
	FROM PortfolioProject..CovidDeaths AS dea
	join PortfolioProject..CovidVaccinations AS vac
	on dea.date = vac.date AND dea.location = vac.location
	WHERE dea.continent is not null

SELECT * 
FROM #TotalVactPercentage


--creating views for later data visualizations
CREATE VIEW TotalVactPercentage AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT( int, vac.new_vaccinations)) OVER (
	PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingVacTotal
	FROM PortfolioProject..CovidDeaths AS dea
	join PortfolioProject..CovidVaccinations AS vac
	on dea.date = vac.date AND dea.location = vac.location
	WHERE dea.continent is not null
	
SELECT *
FROM TotalVactPercentage