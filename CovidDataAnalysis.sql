-- Extract and Explore the Data ---
Select * From [Portfolio Project].dbo.CovidDeaths;
--

-- List out the total country
Select DISTINCT(location)
From [Portfolio Project].dbo.CovidDeaths 
Order by location;

Select COUNT( DISTINCT location) AS Total_Countries
From [Portfolio Project].dbo.CovidDeaths
WHERE location IS NOT NULL AND continent IS not NULL; --location also has continent in the data where corresponding continent value is NULL
--

--Important features
Select Location, date, population, total_cases, new_cases, total_deaths
From [Portfolio Project].dbo.CovidDeaths
Order by 1,2;
--


--Total Cases vs. Total Deaths
--Out of all confirmed Covid cases, what percentage of infected people died?
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
--What percentage of population got covid?
Select Location, date,population, total_cases, (total_cases/population)*100 AS 'infected_population%'
From [Portfolio Project].dbo.CovidDeaths
where location LIKE '%Germany%'
Order by 1,2;
--

--What country has the largest proportion of its population infected? --
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 'infected_population%'
From [Portfolio Project].dbo.CovidDeaths
Group by location, population
Order by 'infected_population%' desc;
-- Germany : reached 3.4 million confirmed cases, i.e. at it's peak, 4.06% of it's population had been infected.
-- A comparison is fair when it's compared to its own population rather than another contry's population

-- What couttry has the highest death count per cases?
Select location, population, MAX (total_cases) AS HighestInfectionCount, MAX(cast(total_deaths as int)) AS HighestDeathCount, MAX(total_deaths)*100/ NULLIF(MAX(total_cases),0) AS 'DeathPercentage'
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null  --the location consist of continent and null on corresponding continent
Group by location, population
order by Deathpercentage desc;

--Not the largest percentage yet the largest population
Select Location, MAX(cast(total_deaths as int)) AS HighestDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null 
Group by location
order by HighestDeathCount desc;
--Germany comes on number 9 with 83097 deaths and Nepal on 67 with 3279 deaths, US has the highest i.e. 576232

--Highest death count By Continent
Select location, MAX(cast(total_deaths as int)) AS HighestDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is null  -- checking only the continent,[the data consist location as continent and its corresponding continent NULL]
Group by location
order by HighestDeathCount desc;

