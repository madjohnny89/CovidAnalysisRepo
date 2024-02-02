
-- display datasets of covid deaths
select *
from covidDeath

-- all cases and all deaths in every country
select location, sum(cast(new_cases as numeric)) as all_cases, sum(cast(new_deaths as numeric)) as all_deaths
from covidDeath
where continent is not null
group by location
order by 1

--death percentage in every country

select location, max((cast(total_deaths as numeric))/(cast(total_cases as numeric)))*100 as Death_Percentage
from covidDeath
where continent is not null 
group by location
order by 1

--death percentage in Bangladesh

select location, max((cast(total_deaths as numeric))/(cast(total_cases as numeric)))*100 as Death_Percentage
from covidDeath
where continent is not null and location like 'Bangladesh'
group by location


 --population percentage infected worldwide

 select location, population, max(cast(total_cases as numeric) / cast(population as numeric)) * 100 as Infected_Percentage
 from covidDeath
 where continent is not null
 group by location, population
 order by 3 desc


 --global

 -- total new cases and total new deaths everyday

 select date, sum(new_cases) as New_Cases, sum(cast(new_deaths as int)) as New_deaths
 from covidDeath
 where continent is not null
 group by date
 order by 1,2

 -- total cases, total deaths, and death percentage till now

 select sum(new_cases) as All_cases, sum(cast(new_deaths as int)) as All_deaths, (sum(cast(new_deaths as int)) / sum(new_cases)) * 100 as DeathPercentage
 from covidDeath
 where continent is not null


 -- all data in covid vaccinations dataset
select *
from covidVaccinations

--total tests in each country

select location, sum(Convert(numeric,new_tests)) as total_tests
from PortfolioProject..covidVaccinations
where continent is not null
group by location
Order by 1

--total tests carried out in usa so far

select location, sum(convert(numeric,new_tests)) as Total_tests_till_now
from covidVaccinations
where continent is not null and location like '%states'
group by location

-- max number of tests per country in a day

select location, date, max(convert(numeric, new_tests)) over (partition by new_tests) as Max_test
from covidVaccinations
where continent is not null
order by 3 desc


---------- joining two table

select *
from covidVaccinations vaccine
join covidDeath death
 on vaccine.date = death.date
 and vaccine.location = death.location

 -- total population vs vaccination

select death.location, cast(death.population as int) as Total_population, sum(cast(vaccine.new_tests as numeric)) as Total_vaccinations
from covidVaccinations vaccine
join covidDeath death
 on vaccine.date = death.date
 and vaccine.location = death.location
 where death.continent is not null
 group by death.location, population
 order by 1


 -- we can further enhance it by adding rolling vaccinations everyday for every location

 select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,sum(convert(numeric, vaccine.new_vaccinations)) over (partition by death.location 
order by death.location, death.date) as Total_vaccinations
 from covidDeath death
 join covidVaccinations vaccine
 on vaccine.date = death.date
 and vaccine.location = death.location
 where death.continent is not null
 order by 2


-- to use the same alias in the select function, we either need to create CTE or temporary table.

--cte

with populationvsvaccination (Continent, location, date, population, New_vaccination, rollingpplVaccination)
as
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,sum(convert(numeric, vaccine.new_vaccinations)) over (partition by death.location 
order by death.location, death.date) as Total_vaccinations
from covidDeath death
join covidVaccinations vaccine
on vaccine.date = death.date
and vaccine.location = death.location
where death.continent is not null
)
-- now heere I can use the alias that was used in the previous table
select *, (rollingpplVaccination/population)*100 Vaccination_percentage -- I could not use this in the previous table right after I had just created it
from populationvsvaccination

------we can achieve the same output by temp table

drop table if exists #PercentVaccinated
create table #PercentVaccinated (Continent nvarchar(255), location nvarchar(255), 
date datetime, population numeric, New_vaccination numeric, rollingpplVaccination numeric)

insert into #PercentVaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,sum(convert(numeric, vaccine.new_vaccinations)) over (partition by death.location 
order by death.location, death.date) as Total_vaccinations --I could not use this total vaccination to calculate
from covidDeath death
join covidVaccinations vaccine
on vaccine.date = death.date
and vaccine.location = death.location
where death.continent is not null

select *, (rollingpplVaccination/population)*100 Vaccination_percentage -- I could not use this in the previous table right after I had just created it
from #PercentVaccinated

---finally I'll create a view to store data for later visualization


create view percentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,sum(convert(numeric, vaccine.new_vaccinations)) over (partition by death.location 
order by death.location, death.date) as Total_vaccinations --I could not use this total vaccination to calculate
from covidDeath death
join covidVaccinations vaccine
on vaccine.date = death.date
and vaccine.location = death.location
where death.continent is not null


