select * from CovidDeaths
where continent is not null
order by 3,4

--select * from covidvaccinations
--order by 3,4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Germany

select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage 
from CovidDeaths
where location like 'germany'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select location, date, total_cases, population,(total_cases/population) * 100 as Casespercentage
from CovidDeaths
where location like 'germany'
and continent is not null
order by 1,2

-- Looking at Countries with highest Infection Rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount,Max((total_cases/population)) * 100 as PercentPopulationInfected
from CovidDeaths
group by location,Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population and Death Rate

select location,max(cast(total_deaths as int)) as HighestDeathsCount,Max((total_deaths/population)) * 100 as PercentDeathPopulation
from CovidDeaths
where continent is not null
group by location,Population
order by HighestDeathsCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing contients with the highest death count per population 

select continent,max(cast(total_deaths as int)) as HighestDeathsCount
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathsCount desc

-- Global Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from CovidDeaths
--where location like 'germany'
where continent is not null
--group by date
order by 1,2

-- Looking at total population vs vaccination
With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/Population) * 100
from PopvsVac

-- Temp Table

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
select d.continent, d.location, d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

--Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
select d.continent, d.location, d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated