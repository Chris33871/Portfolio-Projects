-- Deaths Table
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in the UK
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kingdom%'
And continent is not null
Order by 1, 2


-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kingdom%'
and continent is not null
Order by InfectedPercentage Desc

Select location, date, population, Max(total_cases) as HighestInfectionCount, Max((total_cases)/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Group by location, population, date
Order by InfectedPercentage Desc


-- Looking at countries with highest infection rate compared to population
Select location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by population, location
Order by InfectedPercentage desc 


-- Showing Continents/Area with the Highest Death Count
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc 

Select location, Sum(Cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 
'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
Order by TotalDeathCount desc


-- Showing Countries with the Highest Death Count per Population
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by population, location
Order by TotalDeathCount desc 


-- Global Numbers
Select date, Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int)) as TotalDeaths, 
Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

Select Sum(new_cases) as TotalCases, Sum(Cast(new_deaths as int)) as TotalDeaths, 
Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2




-- Vaccination Table + Join
Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3 


-- Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population) *100 as PercentageVaccinated
From PopvsVac


-- TEMP table 
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), location nvarchar(255), date datetime, 
population numeric, new_vaccinations numeric, RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100 as PercentageVaccinated
From #PercentPopulationVaccinated




-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated
