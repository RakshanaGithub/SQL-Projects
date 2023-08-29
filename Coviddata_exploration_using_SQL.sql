/*
Covid 19 Data Exploration 
Using data from https://ourworldindata.org/covid-deaths
Skills used: Joins, CTE's, Temp Tables, Windows Functions, 
Aggregate Functions, Creating Views, Converting Data Types
*/

-- View the data saved in the Covid deaths file

Select *
From Project..CovidDeaths
Where continent is not null 
order by 3,4;

-- Gather the Data that we are going to be working with

Select Location, date, total_cases, new_cases, total_deaths, population
From Project..CovidDeaths
Where continent is not null 
order by 1,2;

-- Percentage of new cases wrt total cases observed in Albania

Select Location, date, total_cases,total_deaths, (new_cases/total_cases)*100 as 'Percentage of new cases'
From Project..CovidDeaths
Where location like '%Albania%'
and continent is not null 
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Project..CovidDeaths
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Count_of_high_infection ,  Max((total_cases/population))*100 as Percent_Population_Infected
From Project..CovidDeaths
Group by Location, Population
order by Percent_Population_Infected desc;

-- Countries with Highest Death Count/Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeath
From Project..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeath desc

-- Working with data related to continents

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeath
From Project..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeath desc

-- Total death percentage through out the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From Project..CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) 
as Rolling_People_Vaccinated
From Project..CovidDeaths D
Join Project..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select D.Continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) 
OVER (Partition by D.Location Order by D.location, D.Date) as Rolling_People_Vaccinated
From Project..CovidDeaths D
Join Project..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists Percent_Population_Vaccinated
Create Table Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into Percent_Population_Vaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as Rolling_People_Vaccinated
From Project..CovidDeaths D
Join Project..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date


Select *, (Rolling_People_Vaccinated/Population)*100
From Percent_Population_Vaccinated


-- Creating a View

Create View 
Percent_PopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(CONVERT(int,V.new_vaccinations))
OVER (Partition by D.Location Order by D.location, D.Date) as Rolling_People_Vaccinated
From Project..CovidDeaths D
Join Project..CovidVaccinations V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
