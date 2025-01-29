# Covid 19 Data Analysis

## Table of contents
- [Project Overview](#project-overview)
- [Data Sources](#date-sources)
- [Data cleaning](#data-cleaning)
- [Data Analysis](#data-analysis)
- [Recommendations](#recommendations)

### Project Overview
This portfolio demonstrates SQL expertise in analysing *COVID-19 data*, focusing on key metrics such as infection rates, vaccination efficiency, and the relationship between population and health outcomes. Key techniques include advanced SQL functions like *CTEs*, *joins*, *window functions*, and *temporary* tables to generate actionable insights for global health trends and vaccination strategies. 😄

---

### Key Features 
- **Infection Rate & Vaccination Analysis**: Comparative analysis of infection rates versus population and vaccination coverage.
  - This is a subpoint
- **Vaccination Efficiency**: Ranked countries by vaccination efficiency, using rolling sums for accurate population coverage analysis.
- **Data Visualisation Preparation**: SQL views and tables created for seamless integration into data visualisation tools.
- **Advanced SQL Techniques**: Utilisation of CTEs, window functions, temporary tables, and joins to extract meaningful patterns from large datasets.

### Tools and Skills 💻
1. Excel - data cleaning [Download here](https://www.microsoft.com)
  - [Download here](https://www.microsoft.com)
2. SQL - data analysis [Download here](https://github.com/B77Stefan/Covid-19-Data-SQL-Analysis/blob/2818a5e5c763e4af4ff465813c374069baa7da2c/SQLQuery2.sql)
3. Power BI - creating the report [Download here](https://www.microsoft.com)

### Data Sources
|Source|Link|
|----|----|
|Covid_Deaths|https://example.com|
|Covid_Vaccinations|https://example.com|

### Data cleaning

### Exploratory Data Analysis

### Data Analysis
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

### Results and findings
The analysis results are summarised as follows:

## [Tableau Dashboard](https://public.tableau.com/views/Covid19_Project_17379884039100/Dashboard1?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)
![Covid-19 Dashboard](https://github.com/B77Stefan/Covid-19-Data-Analysis/blob/f7b99e6f13235a46452cb43939563b13357a2d0d/Tableau%20Dashboard.png)

### Recommendations
Based on the analysis results, we recommend the following:

## Limitations
Actions that limits the quality of the analysis. E.g. Outlier data (Data from 2019 was removed) was removed for accurate results

## References
- SQL for businesses by [Alex the Analyst]
- [Stack overflow](https://stackoverflow.com/)
