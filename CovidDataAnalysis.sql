-- Extract and Explore the Data ---
SELECT * FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 3,4;

SELECT * FROM [Portfolio Project].dbo.CovidVaccination
ORDER BY 3,4
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
    TRY_CAST(total_deaths AS FLOAT) AS total_deaths,
    
    (TRY_CAST(total_deaths AS FLOAT) / NULLIF(population, 0)) * 100
        AS population_death_percentage,

    (TRY_CAST(total_deaths AS FLOAT) / NULLIF(population, 0)) * 100000
        AS deaths_per_100000_population

FROM [Portfolio Project].dbo.CovidDeaths
WHERE location IN ('Germany', 'Nepal')
AND date = '2021-04-30'
ORDER BY deaths_per_100000_population DESC;
--


--What country has the highest infection rate compared to population? --
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 'infected_population%'
From [Portfolio Project].dbo.CovidDeaths
Group by location, population
Order by 'infected_population%' desc;
-- Andorra has the highest infected population with 17.13%
-- Germany : reached 3.4 million confirmed cases, i.e. at it's peak, 4.06% of it's population had been infected | while Nepal recorded 323,187 cases (1.11% of its population)


-- What country has the highest death count per cases?
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

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project].dbo.CovidDeaths dea
Join From [Portfolio Project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 