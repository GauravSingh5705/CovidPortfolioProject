-- Basic Inspection

select location, date, total_cases, new_cases, total_deaths, population
from [CovidDeaths - CSV]
order by 1,2

-- convert datatype of columns

alter table [CovidDeaths - CSV]
alter column population float

-- Percentage Deaths against Total Infected per country per day

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeaths
from [CovidDeaths - CSV]
where location = 'united states'
order by 1,2 desc

-- Percentage Infected trend per country per day

select location, date, total_cases, population, (total_cases/population)*100 as PercentageInfected
from [CovidDeaths - CSV]
--where location like '%states'
order by 1,2

-- Percentage Infected by country(Location)

select location, population, max(total_cases) as Max_Cases, max((total_cases/population))*100 as MaxPercentageInfected
from [CovidDeaths - CSV]
where continent is not null
Group by location, population
order by 4 desc

-- Continent wise Total Deaths

select CONTINENT, MAX(TOTAL_DEATHS) as Total_Deaths
from [CovidDeaths - CSV]
where continent is not null
group by CONTINENT
order by Total_Deaths desc

-- Percentage Deaths against Total Contracted

select SUM(new_cases) as total_cases, sum(new_deaths) as total_deaths, SUM(new_deaths)/ sum(new_cases) * 100 as Percentage_Deaths
from [dbo].[CovidDeaths - CSV]
where continent is not null

-- Rolling Sum

select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(va.new_vaccinations) over (partition by de.location order by de.location, de.date) as Total_Rolling_Vaccinations_Country
from [dbo].[CovidDeaths - CSV] as de
join [dbo].[CovidVaccinations - CSV] as va
on de.location = va.location
and de.date = va.date
where de.continent is not null
--and de.location = 'india'
order by 2,3

-- CTE

with popvsvac( continent, loc, date, population, new_vaccinations, Total_Rolling_Vaccinations_Country)
as
(
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
sum(va.new_vaccinations) over (partition by de.location order by de.location, de.date) as Total_Rolling_Vaccinations_Country
from [dbo].[CovidDeaths - CSV] as de
join [dbo].[CovidVaccinations - CSV] as va
on de.location = va.location
and de.date = va.date
where de.continent is not null
--and de.location = 'india'
--order by 2,3
)
select *, ( Total_Rolling_Vaccinations_Country/population)*100 as Percentage_vaccinated_rolling
from popvsvac

-- TempTable

drop table if exists #popvsvac
create table #popvsvac
(
continent varchar(50),
location varchar(50),
date date,
population float,
new_vaccinations float,
Total_Rolling_Vaccinations_Country float
)
Insert into #popvsvac
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
sum(va.new_vaccinations) over (partition by de.location order by de.location, de.date) as Total_Rolling_Vaccinations_Country
from [dbo].[CovidDeaths - CSV] as de
join [dbo].[CovidVaccinations - CSV] as va
on de.location = va.location
and de.date = va.date
where de.continent is not null
--and de.location like '%states'

select *, (Total_Rolling_Vaccinations_Country/population) * 100 as percentage_vaccinated
from #popvsvac



-- View

create view Total_Rolling_Vaccinations_Country as
select de.continent, de.location, de.date, de.population, va.new_vaccinations, 
sum(va.new_vaccinations) over (partition by de.location order by de.location, de.date) as Total_Rolling_Vaccinations_Country
from [dbo].[CovidDeaths - CSV] as de
join [dbo].[CovidVaccinations - CSV] as va
on de.location = va.location
and de.date = va.date
where de.continent is not null

