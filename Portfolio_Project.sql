select *
from CoronaVaccinations

select data that we are using

select *
from CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total_cases vs total_death
--shows the likelihood of dying of covid in your country

select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--looking at total_cases vs population
--shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
--WHERE location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
--WHERE location like '%states%'
group by location,population
order by PercentPopulationInfected desc

-- showing countries with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
where continent is not null
group by location
order by TotalDeathCount desc

-- lets break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
where continent is not null
group by continent
order by TotalDeathCount desc


-- showing continent with the highest count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
case
	when sum(new_cases) = 0 then null
	else sum(cast(new_deaths as int))/sum(new_cases) * 100 end as DeathPercentage
from PortfolioProject..CovidDeaths
--WHERE location like '%states%'
  where continent is not null
 -- group by date
order by 1,2

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100  
from CovidDeaths dea
join PortfolioProject..CoronaVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3




	use CTE

	WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	as
	(
	select dea.continent, dea.location, dea.date, vac.population as float, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100  
from CovidDeaths dea
join PortfolioProject..CoronaVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null 
--	order by 2,3
	)
	select *, (RollingPeopleVaccinated/population) * 100 as VaccinatedPercentage
	from PopvsVac

	set ansi_warnings off


	-- TEMP TABLE

	drop table if exists  #PecentPopulatedVaccinated
	CREATE TABLE #PecentPopulatedVaccinated
	(
	continent nvarchar(225),
	location nvarchar(225),
	Date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)


	insert into #PecentPopulatedVaccinated
	select dea.continent, dea.location, dea.date, vac.population as float, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100  
from CovidDeaths dea
join PortfolioProject..CoronaVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	--where dea.continent is not null 
--	order by 2,3

	select *, (RollingPeopleVaccinated/population) * 100 as VaccinatedPercentage
	from #PecentPopulatedVaccinated

	--creating view to store data for later visualization

	create view PecentPopulatedVaccinated as
	select dea.continent, dea.location, dea.date, vac.population as float, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100  
from CovidDeaths dea
join PortfolioProject..CoronaVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
		where dea.continent is not null 
		--order by 2,3

		sp_rename PecentPopulatedVaccinated, PercentPopulationVaccinated

