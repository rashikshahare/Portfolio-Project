
select * from Portfolio_project.. CovidDeaths
where continent is not null
order by 3,4;



--select * from Portfolio_project.. CovidVaccinations
--order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project.. CovidDeaths
order by 1 ,2;

--Looking at Total Cases vs Total Deaths 
--shows likelihood of dying if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases) *100 as DeathPercentage
from Portfolio_project.. CovidDeaths
where location like '%India%'
order by 1 ,2;


--looking at total cases vs total population
---shows what percentage of population got Covid

select location, date, population, total_cases, new_cases, (total_cases/population) *100 as DeathPercentage
from Portfolio_project.. CovidDeaths
--where location like '%India%'
order by 1 ,2;


--Looking at  Countries with Highest Infection rate compared to population

select location, population, MAX(total_cases) as HighInfecionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
from Portfolio_project.. CovidDeaths
--where location like '%India%'
group by location, population
order by 1 ,2;


--Showing Countries with highest Death Count

select location ,MAX(CAST(total_deaths as int)) as TotalDeathCount
from Portfolio_project.. CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc;


--LET'S BREAK HTINGS DOWN BY CONTINENT 


--Continent with highest death count per population

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from Portfolio_project.. CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc;


--GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeatPercentage
from Portfolio_project.. CovidDeaths
where continent is not null
group by date
order by 1 ,2;


--TOTALCASES VS TOTALDEATHS

select  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeatPercentage
from Portfolio_project.. CovidDeaths
where continent is not null
--group by date
order by 1 ,2;


--Looking at Total  Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- USE CTE

with PopvsVac( Continent, Location,Date, Population, new_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;
)
select *, (RollingPeopleVaccinated/Population)*100
from Popvsvac;


-- TEMP TABEL

DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continenet nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3;

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated;



--Creating a view to store data fro later visualizations

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from Portfolio_project..CovidDeaths dea
join Portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;

select * from 
PercentPopulationVaccinated;

