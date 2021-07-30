


Select *
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
order by 3,4

--Select *
--From [Covid Project].dbo.COVID_VACCINATION
--order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

Select location, date, total_cases, new_cases, total_deaths, population
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
order by 1,2

--LOOKING AT TOTAL CASES vs TOTAL DEATHS
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Project].dbo.COVID_DEATHS
Where location like '%India%'
order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION
Select location, date,population, total_cases, (total_cases/population)*100 as CasePercentage
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
Where location like '%India%'
order by 1,2

--ALL OVER WORLD
Select location, date,population, total_cases, (total_cases/population)*100 as CasePercentage
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
order by 1,2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid Project].dbo.COVID_DEATHS
Where continent is null and location not in ('World','European Union', 'International')
Group by location
order by TotalDeathCount desc

--LOOKING AT THE COUNTRIES WITH HIGHEST INFECTIONRATE COMPRE TO POPULATION
Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
Group By location, population
order by PopulationPercentageInfected desc

Select location,population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
From [Covid Project].dbo.COVID_DEATHS
--Where continent is not null
Group By location, population,date
order by PopulationPercentageInfected desc



--LOOKING AT COUNTRIES WITH HIGHEST DEATH RATES
Select location,population, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
Group By location, population
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

-- SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
Group By continent
order by TotalDeathCount desc

--LOOKING AT THE CONTINENT WITH HIGHEST INFECTIONRATE COMPRE TO POPULATION
Select continent,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
Group By continent
order by PopulationPercentageInfected desc

--GLOBAL NUMBERS ---on this day how much cases discovered globally
Select date, SUM(new_cases) as total_newCases, SUM(cast(new_deaths as int)) as total_newDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentageperNewCase
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_newCases, SUM(cast(new_deaths as int)) as total_newDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentageperNewCase
From [Covid Project].dbo.COVID_DEATHS
Where continent is not null
--Group by date
order by 1,2


-- TOATL POPULATION VS VACCINATION
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,SUM(cast(vac.new_vaccinations as int)) Over 
(Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From [Covid Project].dbo.COVID_DEATHS dea
Join [Covid Project].dbo.COVID_VACCINATION vac
    On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3


--USE CTE

With  PopvsVac (Continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,SUM(cast(vac.new_vaccinations as int)) Over 
(Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From [Covid Project].dbo.COVID_DEATHS dea
Join [Covid Project].dbo.COVID_VACCINATION vac
    On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population) as Vaccinationperpopulation

From PopvsVac
--Where location like '%India%'

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,SUM(cast(vac.new_vaccinations as int)) Over 
(Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From [Covid Project].dbo.COVID_DEATHS dea
Join [Covid Project].dbo.COVID_VACCINATION vac
    On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/population) as Vaccinationperpopulation
From #PercentPopulationVaccinated

-- creating view to store data for later
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,SUM(cast(vac.new_vaccinations as int)) Over 
(Partition by dea.location Order by dea.location, dea.date ) as RollingPeopleVaccinated
From [Covid Project].dbo.COVID_DEATHS dea
Join [Covid Project].dbo.COVID_VACCINATION vac
    On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3



SELECT *
FROM PercentagePopulationVaccinated





