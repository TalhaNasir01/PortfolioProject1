--Select *
--from PortfolioProject..coviddeaths
--order by 3,4

--select *
--from PortfolioProject..covidvaccinations
--order by 3,4


--selecting the data that we will be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country at a certain point in time

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Pakistan%'
and continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%Pakistan%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PopulationInfected desc


-- Countries with Highest Death Count

select location, max(cast (total_deaths as int)) as HighestDeathCount	
from PortfolioProject..CovidDeaths
where continent is not null
and population is not null
group by location
order by HighestDeathCount desc


-- Countries with Highest Death Count as a Percentage of the Population

select location, population, max(cast(total_deaths as int)) as HighestDeathCount, (max(cast(total_deaths as int))/population)*100 as PercentPopulationDead
from PortfolioProject..CovidDeaths
where continent is not null
and population is not null
group by location, population
order by PercentPopulationDead desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

--Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--Where continent is not null 
--Group by continent
--order by TotalDeathCount desc

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
Group by location
order by TotalDeathCount desc	


-- GLOBAL NUMBERS PER DAY

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentDeadPerCase
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- GLOBAL NUMBERS

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentDeadPerCase
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2 desc


--JOINING THE TWO TABLES

select *
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationsNumber
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationsNumber)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationsNumber
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinationsNumber/Population)*100 as PercentPopulationVaccinated
from PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationsNumber numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationsNumber
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingVaccinationsNumber/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated
order by location



-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationsNumber
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


create view DeathCountPerContinent as
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
Group by location
--order by TotalDeathCount desc	
