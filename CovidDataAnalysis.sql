-- Extract and Explore the Data ---
Select * From [Portfolio Project].dbo.CovidDeaths;
--

-- List out the total country
Select DISTINCT(location)
From [Portfolio Project].dbo.CovidDeaths 
Order by location;

Select COUNT( DISTINCT location) AS Total_Countries
From [Portfolio Project].dbo.CovidDeaths
WHERE location IS NOT NULL;
--

--Important features
Select Location, date, population, total_cases, new_cases, total_deaths
From [Portfolio Project].dbo.CovidDeaths
Order by 1,2;
--


--Total Cases vs. Total Deaths
--How many cases and deaths(for entrire case) per country?
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_percentage'
From [Portfolio Project].dbo.CovidDeaths
Order by 1,2;
-- In Afghanistan when 34 cases detected , total death was 1 and 2.94%
--the last record from 2021_04_30 shows 59745 total cases from which 2625 were dead which has 4.39% i.e. 4 % chance of death


--checking the same for Germany
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_percentage'
From [Portfolio Project].dbo.CovidDeaths
where location LIKE '%Germany%'
Order by 1,2;
-- In 2021 Apr, Germany has 2% chance of death i.e. out of 3405365 , 83097 were dead nevertheless high number of people died comapred to Afghanistan

--Nepal
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'death_percentage'
From [Portfolio Project].dbo.CovidDeaths
where location LIKE '%Nepal%'
Order by 1,2;
--

--Total cases vs. Population
--What % of population got covid?
Select Location, date,population, total_cases, (total_cases/population)*100 AS 'infected_population%'
From [Portfolio Project].dbo.CovidDeaths
where location LIKE '%Nepal%'
Order by 1,2;

--What country has the highest infection count per location? --
Select Location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 'infected_population%'
From [Portfolio Project].dbo.CovidDeaths
Group by location, population
Order by 'infected_population%';

-- Year and the Number of record --
Select YEAR(date) AS Year, COUNT(*) AS Num_of_records
From [Portfolio Project].dbo.CovidDeaths
GROUP BY YEAR(date)
ORDER BY Year;
--

-- Why was the number of record huge in 2020 and not 2021? -- 
Select YEAR(date) AS Year, MONTH(date) AS Month
From [Portfolio Project].dbo.CovidDeaths
GROUP BY YEAR(date), Month(date)
Order by Year, Month;
-- Comparing cumulative yearly statistics would be biased as 2021 has only 4 months record and 2020 with 12 months
-

-- If so, how did the infection percentage change between "January–April 2020" and "January–April 2021"?
Select location, YEAR(date) AS year, MAX(total_cases) AS max_total_case, MAX(population) as max_population,
ROUND(MAX(total_cases) * 100.0/MAX(population),2) AS infection_percentage
From [Portfolio Project].dbo.CovidDeaths
WHERE MONTH(date) BETWEEN 1 AND 4 
AND YEAR(date) IN (2020,2021)
AND continent IS NOT NULL
GROUP BY location, YEAR(date)
ORDER BY location, year;
--Each country is compared on 2020 and 2021 and results drawn--
