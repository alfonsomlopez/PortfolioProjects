select *
from 2022coviddeaths
where continent is not null;

select * 
from 2022covidvaccinations;

-- select data we are using 

select location, date, total_cases, new_cases, total_deaths, population
from 2022coviddeaths
order by 1,2;

-- looking at total cases vs total deaths 
-- shows likelihood of dying in you test positive for covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from 2022coviddeaths
where location like '%states'
order by 1,2;

-- cases vs population 
-- shows percentage of population that tested positive for covid
select location, date, total_cases, population, (total_cases/population) as PercentPopulationInfected
from 2022coviddeaths
where location like '%states'
order by 1,2;

-- countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from 2022coviddeaths
-- where location like '%states'
Group by location, population
order by PercentPopulationInfected desc;

-- countries with highest death count per population

select location, Max(cast(total_deaths as UNSIGNED)) as TotalDeathCount
from 2022coviddeaths
Group by location
order by TotalDeathCount desc;

-- continents with highest death count

select continent, Max(cast(total_deaths as UNSIGNED)) as TotalDeathCount
from 2022coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- global numbers

select Max(total_cases) as TotalCases, Max(cast(total_deaths as UNSIGNED)) as TotalDeaths, Max(cast(total_deaths as UNSIGNED))/Max(total_cases)*100 as DeathPercentage
from 2022coviddeaths
where continent is not null
order by 1,2;

-- population vs vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(cv.new_vaccinations, unsigned)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from 2022coviddeaths cd
join 2022covidvaccinations cv
	on cd.location = cv.location
    and cd.date = cv.date
where cd.location like '%states'
order by 2,3;

-- use CTE 

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(cv.new_vaccinations, unsigned)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from 2022coviddeaths cd
join 2022covidvaccinations cv
	on cd.location = cv.location
    and cd.date = cv.date
where cd.location like '%states'
order by 2,3)

select *, (rollingPeopleVaccinated/population)
from PopvsVac;

-- create view 

create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(convert(cv.new_vaccinations, unsigned)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from 2022coviddeaths cd
join 2022covidvaccinations cv
	on cd.location = cv.location
    and cd.date = cv.date
where cd.location like '%states'
order by 2,3;

