Select *
from PortfolioProject..CovidDeaths$
order by 3, 4

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Total cases vs total deaths
-- Shows the likelihood of dying
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- Total cases vs Population
-- What % of the population got covid
Select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--highest infection rate compared to the population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
group by population, location
order by PercentPopulationInfected desc 

--highest death rate compared to the population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc 

--LETS BREAK THINGS DOWN BY CONTINENT
--highest death rate compared to the population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc 

--continent with highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2 

-- removing dates
Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2 

Select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

-- Total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- RUNING TOTAL BY LOCATION
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- RUNING TOTAL BY CONTINENT
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.continent)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, dea.date) 
as RollingPeopleVacinated, (RollingPeopleVacinated/dea.population) * 100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USING CTE
With PopvsVac (Continent, Location, Date, Population,New_Vacinations, RollingPeopleVacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, dea.date) 
as RollingPeopleVacinated --, (RollingPeopleVacinated/dea.population) * 100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVacinated/Population) * 100
from PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulatedVaccinated
Create Table #PercentPopulatedVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacinations numeric,
RollingPeopleVacinated numeric
)
Insert into #PercentPopulatedVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, dea.date) 
as RollingPeopleVacinated --, (RollingPeopleVacinated/dea.population) * 100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVacinated/Population) * 100
from #PercentPopulatedVaccinated

--CREATING VIEWS TO STORE FOR VISUALISATION
Create View PercentPopulatedVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, dea.date) 
as RollingPeopleVacinated --, (RollingPeopleVacinated/dea.population) * 100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulatedVaccinated