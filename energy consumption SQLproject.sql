CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;
drop database energydb2;
-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);
select count(*) as total
from country;
SELECT * FROM COUNTRY;
desc COUNTRY;
-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);
select count(*) as total
from emission_3;
DESC EMISSION_3;
SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);
DESC POPULATION;
select count(*) as total
from population;
SELECT * FROM POPULATION;

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);
select count(*) as total
from production;
DESC PRODUCTION;
SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);
DESC GDP_3;
select count(*) as total
from gdp_3;
SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);
select count(*) as total
from consumption;
DESC CONSUMPTION;
SELECT * FROM CONSUMPTION;


-- General & Comparative Analysis
-- What is the total emission per country for the most recent year available?
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country;

-- 2.What are the top 5 countries by GDP in the most recent year?
SELECT Country, Value AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY Value DESC
LIMIT 5;

-- 3.Compare energy production and consumption by country and year. 
SELECT p.country, p.year,
       SUM(p.production) AS total_production,
       SUM(c.consumption) AS total_consumption
FROM production p
JOIN consumption c
ON p.country = c.country AND p.year = c.year
GROUP BY p.country, p.year;

-- 4.Which energy types contribute most to emissions across all countries?
SELECT energy_type, SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type
ORDER BY total_emission DESC;

-- Trend Analysis Over Time
-- 5.How have global emissions changed year over year?
SELECT year, SUM(emission) AS global_emission
FROM emission_3
GROUP BY year
ORDER BY year;

-- 6.What is the trend in GDP for each country over the given years?
SELECT COUNTRY,YEAR,VALUE
FROM GDP_3
ORDER BY COUNTRY,YEAR;

-- 7.How has population growth affected total emissions in each country?
SELECT 
    e.country,
    e.year,
    SUM(e.emission) AS total_emission,
    p.Value AS population
FROM emission_3 e
JOIN population p
    ON e.country = p.countries
   AND e.year = p.year
GROUP BY 
    e.country,
    e.year,
    p.Value;

-- 8.Has energy consumption increased or decreased over the years for major economies?
SELECT country, year, SUM(consumption) AS total_consumption
FROM consumption
GROUP BY country, year
ORDER BY COUNTRY,YEAR;

-- 9.What is the average yearly change in emissions per capita for each country?
SELECT country,
       AVG(per_capita_emission) AS avg_per_capita_emission
FROM emission_3
GROUP BY country;

-- Ratio & Per Capita Analysis
-- 10.What is the emission-to-GDP ratio for each country by year?
SELECT 
    e.country,
    e.year,
    SUM(e.emission) AS total_emission,
    g.Value AS gdp,
    SUM(e.emission) / g.Value AS emission_gdp_ratio
FROM emission_3 e
JOIN gdp_3 g
    ON e.country = g.Country
   AND e.year = g.year
GROUP BY 
    e.country,
    e.year,
    g.Value;


-- 11.What is the energy consumption per capita for each country over the last decade?
SELECT 
    c.country,
    c.year,
    SUM(c.consumption) AS total_consumption,
    p.Value AS population,
    SUM(c.consumption) / p.Value AS consumption_per_capita
FROM consumption c
JOIN population p
    ON c.country = p.countries
   AND c.year = p.year
WHERE c.year >= (SELECT MAX(year) - 10 FROM consumption)
GROUP BY 
    c.country,
    c.year,
    p.Value;

    
-- 12.How does energy production per capita vary across countries?
SELECT 
    pr.country,
    pr.year,
    SUM(pr.production) AS total_production,
    p.Value AS population,
    SUM(pr.production) / p.Value AS production_per_capita
FROM production pr
JOIN population p
    ON pr.country = p.countries
   AND pr.year = p.year
GROUP BY 
    pr.country,
    pr.year,
    p.Value;


-- 13.Which countries have the highest energy consumption relative to GDP?
SELECT 
    c.country,
    c.year,
    SUM(c.consumption) AS total_consumption,
    g.Value AS gdp,
    SUM(c.consumption) / g.Value AS consumption_gdp_ratio
FROM consumption c
JOIN gdp_3 g
    ON c.country = g.Country
   AND c.year = g.year
GROUP BY 
    c.country,
    c.year,
    g.Value
ORDER BY consumption_gdp_ratio DESC;

 -- Global Comparisons

-- 14.What are the top 10 countries by population and how do their emissions compare?
SELECT 
    p.countries AS country,
    p.year,
    p.Value AS population,
    SUM(e.emission) AS total_emission
FROM population p
JOIN emission_3 e
    ON p.countries = e.country
   AND p.year = e.year
GROUP BY 
    p.countries,
    p.year,
    p.Value
ORDER BY population DESC
LIMIT 10;


-- 15.Which countries have improved (reduced) their per capita emissions the most over the last decade?
SELECT 
    country,
    MAX(per_capita_emission) - MIN(per_capita_emission) AS reduction
FROM emission_3
GROUP BY country
ORDER BY reduction DESC;


-- 16. What is the global share (%) of emissions by country?
SELECT 
    country,
    SUM(emission) * 100.0 /
    (SELECT SUM(emission) FROM emission_3) AS emission_percentage
FROM emission_3
GROUP BY country;


-- 17.What is the global average GDP, emission, and population by year?
SELECT 
    e.year,
    AVG(g.Value) AS avg_gdp,
    AVG(e.emission) AS avg_emission,
    AVG(p.Value) AS avg_population
FROM emission_3 e
JOIN gdp_3 g
    ON e.country = g.Country
   AND e.year = g.year
JOIN population p
    ON e.country = p.countries
   AND e.year = p.year
GROUP BY e.year
ORDER BY e.year;





