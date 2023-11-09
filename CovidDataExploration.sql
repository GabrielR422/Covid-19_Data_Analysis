Select * 
From CovidPortafolioProject..CovidDeaths
order by 3,4


--Select * 
--From CovidPortafolioProject..CovidVaccinations
--order by 3,4


--Select Data

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidPortafolioProject..CovidDeaths
order by 1,2


--Looking at total cases vs total deaths in the United states
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From CovidPortafolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Total caces vs population 
--Percent of population that has covid in the United states
Select Location, date, total_cases, population, (total_cases/population)*100 as HasCovidPercentage 
From CovidPortafolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at the countries with the highest infection rate realtive to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulstionInfected
From CovidPortafolioProject..CovidDeaths
Group by location, population
order by PercentPopulstionInfected desc

--Looking at the countries with the highest infection rate realtive to population
Select location, population, date, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulstionInfected
From CovidPortafolioProject..CovidDeaths
Group by location, population, date
order by PercentPopulstionInfected desc


--Countries with the highest death count relative to population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidPortafolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


--Death counts by Continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidPortafolioProject..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--Global total 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPearcetage
From CovidPortafolioProject..CovidDeaths
where continent is not null
order by 1,2

--Global by day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPearcetage
From CovidPortafolioProject..CovidDeaths
where continent is not null
Group by date 
order by 1,2


--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortafolioProject..CovidDeaths dea
Join CovidPortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortafolioProject..CovidDeaths dea
Join CovidPortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Create View to visualize
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidPortafolioProject..CovidDeaths dea
Join CovidPortafolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


