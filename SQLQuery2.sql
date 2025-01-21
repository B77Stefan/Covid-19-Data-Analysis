SELECT * FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL;
--SELECT * FROM CovidVaccinations;

SELECT COUNT(*) FROM PortofolioProject.dbo.CovidDeaths;

--Total Cases vs Total Deaths
--This shows the percentage of Cases that resulted in death
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location LIKE '%Romania%' AND continent IS NOT NULL
ORDER BY 2;

--Total Cases vs Population.
SELECT *, total_cases/population*100 AS PercentageCases
FROM CovidDeaths
--This shows the percentage of the Population that contracted COVID-19.
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE location LIKE 'Romania' AND continent IS NOT NULL
ORDER BY 2;

--Infection rate by Country
--This shows countries with the highest Infection Rate compared to the Population
SELECT location, MAX(ROUND((total_cases/population)*100,2)) AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY PercentPopulationInfected DESC;

SELECT location, population, MAX(total_cases) AS HighestInfenctionCount, MAX(ROUND((total_cases/population)*100,2)) AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--Inspect the Total Deaths value
SELECT location, total_deaths FROM PortofolioProject..CovidDeaths WHERE continent IS NOT NULL ORDER BY total_deaths DESC
SELECT location, CAST(total_deaths AS INT) FROM PortofolioProject..CovidDeaths WHERE continent IS NOT NULL ORDER BY 2 DESC;

--Death Count per Population
--This shows the countries with the highest Death Count per Population
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount, MAX(ROUND((CAST(total_deaths AS INT)/population)*100,2)) AS PercentPopulationDeath
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationDeath DESC;

--Continent Data Breakdown - CREATE VIEW
--This shows continents with the highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Global Data Breakdown -- CREATE VIEW
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, ROUND(((SUM(CAST(new_deaths AS INT)))/(SUM(new_cases)))*100,2) AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Join CovidDeaths and CovidVaccinations
SELECT * 
FROM CovidDeaths DEA
INNER JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date;

--Looking at Total Population vs Vaccination
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
	   SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
INNER JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL AND VAC.new_vaccinations IS NOT NULL
ORDER BY 1,2,3;

--CTE(Common Table Expressions)
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
			  (
				SELECT DEA.CONTINENT, DEA.LOCATION, DEA.DATE, DEA.POPULATION, VAC.NEW_VACCINATIONS, 
				SUM(CONVERT(INT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLINGPEOPLEVACCINATED
				FROM CovidDeaths DEA
				INNER JOIN CovidVaccinations VAC
					ON DEA.location = VAC.location AND DEA.date = VAC.date
				WHERE DEA.continent IS NOT NULL
				)
SELECT *, ROUND(RollingPeopleVaccinated/population * 100,2) AS PercentagePeopleVaccinated
FROM PopvsVac
ORDER BY 2,3 ASC;

--Vaccination Campaign Efficiency - This query ranks countries by vaccination efficiency, using a rolling sum to calculate population coverage.
WITH VaccinationEfficiency AS (
	SELECT 
		CV.location,
		CV.date,
		CAST(CD.population AS FLOAT) AS Population,
		CAST(CV.new_vaccinations AS FLOAT) AS NewVaccinations,
		SUM(CAST(CV.new_vaccinations AS FLOAT)) OVER (PARTITION BY CV.location ORDER BY CV.date) AS RollingVaccinations,
		ROUND(SUM(CAST(CV.new_vaccinations AS FLOAT)) OVER (PARTITION BY CV.location ORDER BY CV.date) 
		/ CAST(CD.population AS FLOAT) * 100,2) AS PercentPopulationVaccinated
	FROM 
		PortofolioProject..CovidVaccinations CV
	INNER JOIN 
		PortofolioProject..CovidDeaths CD
		ON CV.date = CD.date AND CV.location = CD.location
	WHERE
		CV.continent IS NOT NULL 
		AND CV.new_vaccinations IS NOT NULL
		AND CD.population IS NOT NULL
	)
SELECT 
    location,
    MAX(PercentPopulationVaccinated) AS MaxPercentPopulationVaccinated,
    MAX(RollingVaccinations) AS TotalVaccinations,
    MAX(Population) AS Population
FROM 
    VaccinationEfficiency
GROUP BY 
    location
ORDER BY 
    MaxPercentPopulationVaccinated DESC;

--Identify the top 5 countries with the steepest increase in cases over time.
WITH DailyCaseIncreases AS (
							SELECT continent, location, date, total_cases,
								   LAG(total_cases) OVER (PARTITION BY location ORDER BY date) AS previous_cases,
								   total_cases - LAG(total_cases) OVER (PARTITION BY location ORDER BY date) AS daily_increase
							FROM CovidDeaths
							),
	 RankedCountries AS (
						SELECT location, date, daily_increase, 
						ROW_NUMBER() OVER (PARTITION BY location ORDER BY daily_increase DESC) AS row_num
						FROM DailyCaseIncreases
						WHERE continent IS NOT NULL AND daily_increase IS NOT NULL
						)
SELECT TOP 5 location, date, daily_increase
FROM RankedCountries
WHERE row_num = 1
ORDER BY daily_increase DESC;

--TEMPORARY TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
INNER JOIN CovidVaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, ROUND(RollingPeopleVaccinated/population * 100,2) AS PercentagePeopleVaccinated
FROM #PercentPopulationVaccinated;

--Identify countries with the highest infection-to-vaccination ratio
DROP TABLE IF EXISTS #InfectionVaccinationRatio;
CREATE TABLE #InfectionVaccinationRatio (
	location NVARCHAR(255),
	population NUMERIC,
	infection_rate NUMERIC,
	vaccination_rate NUMERIC
);

INSERT INTO #InfectionVaccinationRatio
SELECT 
	CD.location,
	CD.population,
	(CD.total_cases/CD.population)*100 AS infection_rate,
	(CV.people_fully_vaccinated/CD.population)*100 AS vaccination_rate
FROM PortofolioProject..CovidDeaths CD
INNER JOIN PortofolioProject..CovidVaccinations CV
	ON CD.location = CV.location AND CD.date = CV.date
WHERE CD.continent IS NOT NULL;

--CREATE VIEW TO STORE DATA FOR VISUALISATIONS
CREATE VIEW PercentPopulationVaccinated AS
WITH rollingvaccinations (location, date, new_vaccinations, RollingVaccinations) AS 
(
	SELECT location, date, new_vaccinations,
	SUM(CONVERT(INT, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) AS RollingVaccinations
	FROM PortofolioProject..CovidVaccinations
	WHERE continent IS NOT NULL
)
SELECT RV.location AS Location, RV.date AS Date, CD.population AS Population, RV.new_vaccinations AS New_Vaccinations, RV.RollingVaccinations, ROUND(RV.RollingVaccinations / CD.population * 100,2) AS VaccinationRatio
FROM rollingvaccinations RV
INNER JOIN PortofolioProject..CovidDeaths CD
ON CD.location = RV.location AND CD.date = RV.date;