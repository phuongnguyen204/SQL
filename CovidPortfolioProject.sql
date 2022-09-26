/* COVID 19 DATA EXPLORATION

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Coverting Data Types
*/


-- Show all data 

Select * From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select Data that we are going to starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Total Cases VS Total Deaths
-- Likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location = 'Australia' and 
continent is not null
Order By 1,2

-- Total Cases VS Population
-- Show what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--Where Location = 'Australia'
Order By 1,2

-- Countries with highest Infection Rate compared to Population 

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location, Population
Order By PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Location
Order By TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- Continent with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group By Location
Order By TotalDeathCount DESC

--OR

Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By Continent
Order By TotalDeathCount DESC

--GLOBAL NUMBERS
-- Total number of new cases, new deaths across the world up to 30 April 2021

Select Sum(new_cases) as Total_cases,Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null

--Total number of new cases, new deaths across the world each day

Select date, Sum(new_cases) as Total_cases,Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null
Group By date
Order By 1,2

-- Total Population vs Vaccinations
--Looking at rolling people vaccinated by country

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3

-- Use CTE to calculate the percentage of population vaccinated 

With  PopVSVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
As (
Select dea.continent, dea.location, dea.date,population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.date = vac.date
Where dea.continent is not null)
Select *, (RollingPeopleVaccinated/Population)*100 As PopVaccinationRate
From PopVSVac

-- UsingTemp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 As PopVaccinationRate  From #PercentPopulationVaccinated

-- Create View to store data for later visuallisations
-- View for Percentage of Population Vaccinated

Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as bigint)) Over (Partition By dea.Location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.Location = vac.Location
	and dea.date = vac.date
Where dea.continent is not null


-- Total number of new cases, new deaths across the world up to 30 April 2021
-- View for GlobalNumber such as Total Cases, Total Deaths, Death Percentage

Create View GlobalNumber As
Select Sum(new_cases) as Total_cases,Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent is not null