## Description
This portfolio demonstrates SQL expertise in analysing COVID-19 data, focusing on key metrics such as infection rates, vaccination efficiency, and the relationship between population and health outcomes. Key techniques include advanced SQL functions like CTEs, joins, window functions, and temporary tables to generate actionable insights for global health trends and vaccination strategies.

## Key Features
- **Infection Rate & Vaccination Analysis:** Comparative analysis of infection rates versus population and vaccination coverage.
- **Vaccination Efficiency:** Ranked countries by vaccination efficiency, using rolling sums for accurate population coverage analysis.
- **Data Visualisation Preparation:** SQL views and tables created for seamless integration into data visualisation tools.
- **Advanced SQL Techniques:** Utilisation of CTEs, window functions, temporary tables, and joins to extract meaningful patterns from large datasets.

## Tools and Skills
- Excel - data cleaning [Download here](https://www.microsoft.com)
  - [Download here](https://www.microsoft.com)
- SQL - data analysis [Download here](https://www.microsoft.com)
- Power BI - creating the report [Download here](https://www.microsoft.com)

## Data Sources
1. Covid_Deaths
2. Covid_Vaccinations

## Data cleaning

## Exploratory Data Analysis

## Data Analysis
CTE functions used to produce the vaccination rate ratio
```SQL
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
```
