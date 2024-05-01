SELECT *
FROM `covid-analysis-421907.Covid.Covid_death`

WHERE continent is not null
order by 3,4

-- select data that we are going to be using
-- likely to die if you're in Bangladesh

SELECT location, date , total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `covid-analysis-421907.Covid.Covid_death`
Where location LIKE "United States"
order by 1,2

-- Looking at Total Cases vs Population
-- shows percentage of population got covid

SELECT location, date , total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM `covid-analysis-421907.Covid.Covid_death`
--Where location LIKE "Bangladesh"
order by 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HigestInfection, MAX((total_cases/population))*100 AS CovidPercentage
FROM `covid-analysis-421907.Covid.Covid_death`
--Where location LIKE "Bangladesh"
WHERE continent is not null
GROUP BY location, population
order by CovidPercentage DESC


-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM `covid-analysis-421907.Covid.Covid_death`
--Where location LIKE "Bangladesh"
WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC


-- Lets Break Things Down by continent

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM `covid-analysis-421907.Covid.Covid_death`
--Where location LIKE "Bangladesh"
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC


-- Showing continents with the higest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM `covid-analysis-421907.Covid.Covid_death`
--Where location LIKE "Bangladesh"
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

-- Global Numbers
SELECT  Sum(new_cases) As Total_Cases, Sum(new_deaths) As Total_Deaths, Sum(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM `covid-analysis-421907.Covid.Covid_death`
Where continent is not null
--Group by date
order by 1,2


-- Join Covid vaccination table with Covid Death table

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(Cast(vaccine.new_vaccinations AS int)) over (partition by death.location order by death.location, death.date) AS rolling_people_vaccinated,
--(/population)*100
FROM `covid-analysis-421907.Covid.Covid_death` death
Join `covid-analysis-421907.Covid.Covid_vaccine` vaccine
  on death.location= vaccine.location
  and death.date=vaccine.date
  WHERE death.continent is not null
  order by 2,3

  -- USE CTE

with popvsvac AS (

  SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(Cast(vaccine.new_vaccinations AS int)) over (partition by death.location order by death.location, death.date) AS rolling_people_vaccinated,
FROM `covid-analysis-421907.Covid.Covid_death` death
Join `covid-analysis-421907.Covid.Covid_vaccine` vaccine
  on death.location= vaccine.location
  and death.date=vaccine.date
  WHERE death.continent is not null
  )

SELECT *, (rolling_people_vaccinated/population)*100 AS rolling_vaccine_percent
FROM popvsvac




