/* 
COVID19 Data Exploration

Skills used: Joims, CTE's, Temp Tables, Windows Funcations, Aggregate Funcations, Creating Views, Converting Data Types

*/


select *
from [Portfolio Project]..CovidDeaths$
order by 3, 4

--select *
--from [Portfolio Project]..CovidVaccinations$
--order by 3, 4


-- select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths$
order by 1, 2



--Looking at the total cases vs. total deaths
--Shows likelihood of dying if you get Covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
Where location like '%states%'
order by 1, 2



--Looking at the total cases vs. population
--Shows what percentage of population has gotten covid

select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from [Portfolio Project]..CovidDeaths$
Where location like '%states%'
order by 1, 2



--Looking at countries with highest infection rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
from [Portfolio Project]..CovidDeaths$
Group by location, population
order by InfectedPercentage desc



-- BREAKING THINGS DOWN BY CONTINENT
--Showing continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by date
order by 1, 2



--Looking at total population vs vaccinations
--Shows percentage of population that has received at least one covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountofPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Using CTE to perform calculation on partition by in previous query

With PopVsVac (Continent, location, date, population, new_vaccinations, RollingCountofPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountofPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

)

select *, (RollingCountofPeopleVaccinated/population)*100 as RollingCountPercentage
from PopVsVac



-- Using temp table to perform calculation on partition by in previous query

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, population numeric, new_vaccinations numeric, RollingCountofPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountofPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (RollingCountofPeopleVaccinated/population)*100 as RollingCountPercentage
from #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountofPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated


