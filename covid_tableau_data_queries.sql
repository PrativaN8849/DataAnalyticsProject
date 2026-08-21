-- checking the data--
Select * FROM [Portfolio Project].dbo.CovidDeaths;

Select * FROM [Portfolio Project].dbo.CovidVaccination;
--


-- 1.

-- How many people got COVID across the world in total? -- 
-- What % of people died across thw World in total? --
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL;
--

-- Same query as above but replace with NULL if divides with 0 --
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
    SUM(CAST(new_deaths AS int))/ NULLIF(SUM(new_cases), 0) * 100 AS death_percentage --Prevent division by 0, return NULL when total cases are 0
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL;




-- 2. 

-- How many total COVID deaths were reported according to continent? --
SELECT location, SUM(cast(new_deaths as int)) AS total_death_count
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is null
AND location NOT IN ('World', 'European Union', 'International')   --EU is part of Europe, World and International are already included 
GROUP BY location
ORDER BY total_death_count DESC;
--



-- 3. 

-- For each country:
-- How many COVID cases were reported in total?
-- What % of country's population was reported as infected?


--SELECT location, population, MAX(total_cases) AS total_reported_COVIDcases
--FROM [Portfolio Project].dbo.CovidDeaths
--WHERE location NOT IN ('World', 'Europe', 'Asia', 'North America', 'South America', 'European Union')
--GROUP BY location, Population
--ORDER BY total_reported_COVIDcases DESC;

SELECT location, population, MAX(total_cases) AS total_reported_COVIDinfection, MAX((total_cases/population))*100 AS total_reported_COVIDinfection_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_reported_COVIDinfection_percentage DESC;
--

-- Same query as above except replace with NULL if divides with 0
SELECT location, population,
    MAX(total_cases) AS total_reported_COVIDinfection,
    MAX(100.0 * total_cases / NULLIF(population, 0)) AS total_reported_COVIDinfection_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY total_reported_COVIDinfection_percentage DESC;
--




-- 4.

-- How did the infection(or reported COVID case) change over time in each country?
-- How did the % of population infected by COVID change over time in each country?
SELECT location, population, date, MAX(total_cases) AS reported_COVIDinfection, MAX((total_cases/population))*100 as reported_COVIDinfection_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population,date
ORDER BY reported_COVIDinfection_percentage DESC;
--

--
SELECT location, population, date,
    MAX(total_cases) AS reported_COVIDinfection,
    MAX(100.0 * total_cases / NULLIF(population, 0))
        AS reported_COVIDinfection_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY reported_COVIDinfection_percentage DESC;
--