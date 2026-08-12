-- Extract and Explore the Data ---
SELECT * FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 3,4;

SELECT * FROM [Portfolio Project].dbo.CovidVaccination
ORDER BY 3,4;
--



-- List out the total country
SELECT DISTINCT(location)
FROM [Portfolio Project].dbo.CovidDeaths 
ORDER BY location;

SELECT COUNT( DISTINCT location) AS Total_Countries
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location IS NOT NULL AND continent IS not NULL; --location also has continent in the data where corresponding continent value is NULL
--



--Important features
SELECT Location, date, population, total_cases, new_cases, total_deaths
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 1,2;
--



--Total Cases vs. Total Deaths
--Out of all confirmed Covid cases, what percentage of infected people died?
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_percentage'
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 1,2;
-- In Afghanistan when 34 cases detected , total death was 1 and 2.94%
-- the last record from 2021_04_30 shows 59745 total covid cases from which 2625 were dead which has 4.39% i.e. 4 % chance of death



--checking the death percentage for Germany
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_percentage'
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE '%Germany%'
ORDER BY 1,2;
-- In 2021_4_30 Apr, Germany has 2.4% chance of death i.e. out of 3405365 covid cases, 83097 were dead nevertheless high number of people died comapred to Afghanistan

--checking the death percentage for Nepal
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_percentage'
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE '%Nepal%'
ORDER BY 1,2;
-- In 2021 Apr, Nepal has 1.01% chance of death i.e. 3279 deaths out of 323187 --
-- Since the covid case of Germany is already higher and so the death number the death percentage will be high if compared to Nepal 



--Check dtype of each columns--
EXEC sp_help '[Portfolio Project].dbo.CovidDeaths';
--


-- Out of total case, what percent of people died in Germany and Nepal? --
Select location, date, total_cases, total_deaths,
    TRY_CAST(total_deaths AS FLOAT) * 100.0 / NULLIF(TRY_CAST(total_cases AS FLOAT), 0) --total deaths and total_cases are numeric
    AS case_fatality_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location IN ('Germany', 'Nepal')
  AND date = '2021-04-30'
ORDER BY case_fatality_percentage DESC;
--


-- Total Population in Germany and Nepal
SELECT location, MAX(Population)AS Total_Population
FROM [Portfolio Project].dbo.CovidDeaths 
WHERE location IN ('Germany', 'Nepal')
GROUP BY location;
--


-- Which country had the higher number of deaths per 100,000 population — Germany or Nepal?
SELECT location, date, population,
    TRY_CAST(total_deaths AS FLOAT) AS total_deaths,   --TRY_CAST helps convert value to another dtype
    
    (TRY_CAST(total_deaths AS FLOAT) / NULLIF(population, 0)) * 100 --NULLIF(value,0 protects againsts division by 0
        AS population_death_percentage,

    (TRY_CAST(total_deaths AS FLOAT) / NULLIF(population, 0)) * 100000
        AS deaths_per_100000_population

FROM [Portfolio Project].dbo.CovidDeaths
WHERE location IN ('Germany', 'Nepal')
AND date = '2021-04-30'
ORDER BY deaths_per_100000_population DESC;
--



-- ** What percenatge of your population has gotten covid** --
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases)*100.0/NULLIF(population, 0) AS 'infected_population%'
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 'infected_population%' desc;
-- Andorra has the highest infected population with 17.13%
-- Germany : reached 3.4 million confirmed cases, i.e. at it's peak, 4.06% of it's population had been infected | while Nepal recorded 323,187 cases (1.11% of its population)
--



-- Which country has the maximum deaths? --
Select location, MAX(cast(total_deaths as int)) AS HighestDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null 
Group by location
order by HighestDeathCount desc;
--Germany comes on number 9 with 83097 deaths and Nepal on 67 with 3279 deaths, US has the highest i.e. 576232



-- ** What country has the highest death count per cases? ** --
Select location, population, MAX (total_cases) AS HighestInfectionCount, MAX(cast(total_deaths as int)) AS HighestDeathCount, MAX(total_deaths)*100/ NULLIF(MAX(total_cases),0) AS 'DeathPercentage'
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null  --the location consist of continent and null on corresponding continent
Group by location, population
order by Deathpercentage desc;
--



-- ** Which continent has the maximum deaths? ** --
Select location, MAX(cast(total_deaths as int)) AS HighestDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is null  -- checking only the continent,[the data consist the field location also with continent and its corresponding continent NULL]
Group by location
order by HighestDeathCount desc;
--



-- Across the entire world - total_case, total_deaths and Death percent
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 1,2;
-- This is more accurate -- because new cases could be corrected with minus sometimes


-- Alternatively checking the death total_case, total_death and Death percent across the entire world --
WITH CountryTotals AS
(
    SELECT location,
        MAX(TRY_CAST(total_cases AS bigint)) AS TotalCases,
        MAX(TRY_CAST(total_deaths AS bigint)) AS TotalDeaths
    FROM [Portfolio Project].dbo.CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY location
)
SELECT
    SUM(TotalCases) AS WorldwideCases,
    SUM(TotalDeaths) AS WorldwideDeaths,
    SUM(TotalDeaths) * 100.0 /
        NULLIF(SUM(TotalCases), 0) AS DeathPercentage
FROM CountryTotals;
--


--
-- Join two tables *CovidDeaths and CovidVaccination*--
SELECT * 
FROM [Portfolio Project].dbo.CovidDeaths D
JOIN [Portfolio Project].dbo.CovidDeaths V
ON D.location = V.location
and D.date = V.date 
--


--
-- What is the total amount of people in this world that has been vaccinated? --
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
FROM [Portfolio Project].dbo.CovidDeaths D
JOIN [Portfolio Project].dbo.CovidVaccination V
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent is not null
ORDER BY 2,3;
-- NULL mean no vaccinations was recorded that day --
-- Shows each country's population and daily new vaccination --



--
-- Instead of New vaccination everyday rolling count would be easy to see how many people got vaccinated until now --
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
    SUM(TRY_CAST(V.new_vaccinations as int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingCount_Vaccination
FROM [Portfolio Project].dbo.CovidDeaths D
JOIN [Portfolio Project].dbo.CovidVaccination V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent is not null
ORDER BY 2,3;
--



-- Use that number and divide it to check how many people in that country is vaccinated --
-- How many vaccination doses were given compared with the number of people living in the country?--

WITH  PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingCount_Vaccination) AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(TRY_CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingCount_Vaccination 
--(RollingCountVaccination/population)*100
FROM [Portfolio Project].dbo.CovidDeaths D
JOIN [Portfolio Project].dbo.CovidVaccination V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent is not null
--ORDER BY 2,3;
)
SELECT *, RollingCount_Vaccination*100 / NULLIF(Population, 0) AS 'Vaccination%' FROM PopvsVac;
--SELECT *, (RollingCount_Vaccination/ Population)*100 AS A FROM PopvsVac;
--



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #RollingCount_Vaccination
Create Table #RollingCount_Vaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #RollingCount_Vaccination
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(TRY_CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingCount_Vaccination 
--(RollingCountVaccination/population)*100
FROM [Portfolio Project].dbo.CovidDeaths D
JOIN [Portfolio Project].dbo.CovidVaccination V
ON D.location = V.location
AND D.date = V.date
--WHERE D.continent is not null
--ORDER BY 2,3;
SELECT *, (RollingCount_Vaccination*100 / Population) FROM #RollingCount_Vaccination;
---



-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(TRY_CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingCount_Vaccination 
FROM [Portfolio Project].dbo.CovidDeaths D
JOIN [Portfolio Project].dbo.CovidVaccination V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent is not null;

