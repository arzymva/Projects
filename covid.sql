---- First look at data. Retrieving all records where the continent is not null, ordered by third and fourth columns which are location and date accordingly.

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4;

--Retrieving specific columns in order to further understanding the given data.

SELECT LOCATION, date, total_cases, new_cases, total_deaths, population 
FROM coviddeaths
ORDER BY 1, 2; 

--total cases vs total death, likelihood of death in a country we live.

SELECT LOCATION, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE LOCATION = 'Azerbaijan'
ORDER BY 1, 2; 

--total cases vs population in Azerbaijan.
--Ratio of population getting accused.

SELECT LOCATION, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM coviddeaths
WHERE LOCATION = 'Azerbaijan'
ORDER BY 1, 2; 

--Countries with highest infection rate compared to population.

SELECT LOCATION, population, 
       max(total_cases),  
       max(total_cases/population)*100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY LOCATION, population
ORDER BY PercentPopulationInfected DESC; 

--Countries with highest death count per population.

SELECT LOCATION, max(total_deaths) AS TotalDeaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeaths DESC; 

--Death count by continent

SELECT continent, max(total_deaths) AS TotalDeaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeaths DESC; 

--Global Numbers

SELECT date, 
       sum(new_cases) AS total_cases, 
       sum(new_deaths) AS total_deaths, 
       sum(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

SELECT sum(new_cases) AS total_cases, 
       sum(new_deaths) AS total_deaths,
       sum(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;

--Total vaccination vs population. Percentage of Population that has recieved at least one Covid Vaccine.

SELECT death.continent, 
       death.location, 
       death.date, 
       death.population, 
       vac.new_vaccinations, 
       sum(vac.new_vaccinations) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM coviddeaths death
JOIN covidvaccinations vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2, 3;

--with the use of CTE

WITH PopvsVac (continent, LOCATION, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT death.continent, 
        death.location, 
        death.date, 
        death.population, 
        vac.new_vaccinations, 
        sum(vac.new_vaccinations) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM coviddeaths death
JOIN covidvaccinations vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL
-- order by 2, 3)
)
SELECT *, 
       (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

--Temp table for the same purpose

DROP TABLE IF EXISTS PercentPopVaccinated;

CREATE TEMPORARY TABLE PercentPopVaccinated (
    continent VARCHAR(50),
    LOCATION VARCHAR(50), 
    date DATE, 
    population NUMERIC,
    new_vaccinations NUMERIC, 
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO PercentPopVaccinated
SELECT death.continent, 
       death.location, 
       death.date, 
       death.population, 
       vac.new_vaccinations, 
       sum(vac.new_vaccinations) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM coviddeaths death
JOIN covidvaccinations vac
    ON death.location = vac.location
    AND death.date = vac.date;

--Creating view for storing data for later visualizations

CREATE VIEW PercentPopVaccinated AS 
SELECT death.continent, 
       death.location, 
       death.date, 
       death.population, 
       vac.new_vaccinations, 
       sum(vac.new_vaccinations) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM coviddeaths death
JOIN covidvaccinations vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL; 

SELECT * 
FROM PercentPopVaccinated
