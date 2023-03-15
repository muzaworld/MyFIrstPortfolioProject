/*
Covid 19 Data Exploration

Tools used: Joins, CTE's Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be starting

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2



-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%indo%'
Order by 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%indo%'
Order By 1,2



-- Total Death vs Population

Select Location, date, total_deaths, population, (total_deaths/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%indo%'
Order By 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By Location, Population
Order by PercentPopulationInfected desc



-- Showing Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location
Order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2



-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3



-- USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac




-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3