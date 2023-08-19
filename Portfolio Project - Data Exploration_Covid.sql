/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select location, date , total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1

--looking at total cases vs total deaths
Select location, date , total_cases, total_deaths,(total_deaths/total_cases)*100 as PercentageDeath
From PortfolioProject..CovidDeaths
where location like 'morocco'
order by 1,2

---- Total Cases vs Population
Select location, date ,population, total_cases,(total_cases/population)*100 as PercentageOfPopul
From PortfolioProject..CovidDeaths
where location like 'morocco'
order by 1,2


---- Countries with Highest Infection Rate compared to Population
Select location ,population,max(total_cases) as HighestInfectionCount ,max((total_cases/population)*100) as HighestPercentageOfPopulInfected
From PortfolioProject..CovidDeaths
group by  location ,population
order by 4 desc

---- Countries with Highest Death Count per Population
Select location , max(cast (total_deaths as int)) as HighestDeathsCount
From PortfolioProject..CovidDeaths
Where continent is not null 
group by  location 
order by  HighestDeathsCount desc


-- BREAKING THINGS DOWN BY CONTINENT

Select location , max(cast (total_deaths as int)) as HighestDeathsCount
From PortfolioProject..CovidDeaths
Where continent is null 
group by  location 
order by  HighestDeathsCount desc

-- GLOBAL NUMBERS

Select date , sum(new_cases) as total_cases, sum(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as PercentageDeath
From PortfolioProject..CovidDeaths
Where continent is not null 
group by  date 
Order by 1

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinations vac 
on dea.location= vac.location and vac.date=dea.date
Where dea.continent is not null 
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


with PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths dea 
join CovidVaccinations vac 
on dea.location= vac.location and vac.date=dea.date
Where dea.continent is not null )

select * ,(RollingPeopleVaccinated/population)*100
from PopVsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by 2,3

-- Creating View to store data for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 





