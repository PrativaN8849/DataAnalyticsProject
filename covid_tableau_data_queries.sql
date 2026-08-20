-- checking the data--
Select * from [Portfolio Project].dbo.CovidDeaths;

Select * from [Portfolio Project].dbo.CovidVaccination;
--



-- 1. Calcualte the Global COVID Total and GLOBAL Death percentage --
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null;
--

--SELECT
--    SUM(new_cases) AS total_cases,
--    SUM(TRY_CAST(new_deaths AS int)) AS total_deaths,
--    SUM(TRY_CAST(new_deaths AS int))
--        / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
--FROM [Portfolio Project].dbo.CovidDeaths
--WHERE continent IS NOT NULL;



-- 2. Total reported covid deaths by continent --
SELECT location, SUM(cast(new_deaths as int)) AS total_death_count
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is null
AND location NOT IN ('World', 'European Union', 'International')   --EU is part of Europe, World and International are already included 
GROUP BY location
ORDER BY total_death_count DESC;
--



--3.  How many COVID cases were reported in each country? -> total cases
--    and what % of each county's population do the reported cases represent? 
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM [Portfolio Project].dbo.CovidDeaths
--WHERE continent is NULL
GROUP BY location, Population
ORDER BY percent_population_infected DESC;
--



-- 4. How did reported COVID case and their share of the population chnage over time in each country?
SELECT location, population, date, MAX(total_cases) AS highest_infection_count, max((total_cases/population))*100 as percent_population_infected
FROM [Portfolio Project].dbo.CovidDeaths
GROUP BY location, population,date
ORDER BY percent_population_infected DESC;
--

--
SELECT
    location,
    population,
    date,
    MAX(total_cases) AS cumulative_reported_cases,
    MAX(100.0 * total_cases / NULLIF(population, 0))
        AS reported_cases_population_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY location, date;
--