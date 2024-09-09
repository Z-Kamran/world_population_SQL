-- Seeing the Table as it is
SELECT * FROM world_countries;

-- Ranking
SELECT `Country/Territory` AS `Country`, `2022 Population`, `Continent`, 
RANK() OVER(ORDER BY `2022 Population` DESC) AS `World Ranking`,
RANK() OVER(partition by `Continent` ORDER BY `2022 Population` DESC) AS `Continent Ranking` 
FROM world_countries
ORDER BY `World Ranking` ASC;


-- Grouping by number of countries in a continent
SELECT `Continent`, COUNT('Country/Territory')  FROM world_countries
GROUP BY `Continent`;


-- Adding Growth Rate without CTE
SELECT `Country/Territory` AS `Country`, `2022 Population`,`2020 Population`,`2015 Population`, `Continent`, 
RANK() OVER(ORDER BY `2022 Population` DESC) AS `World Ranking`,
RANK() OVER(partition by `Continent` ORDER BY `2022 Population` DESC) AS `Continent Ranking`,
ROUND((((`2022 Population`/`2020 Population`)+(`2020 Population`/`2015 Population`))/2.0),2) AS `Growth Rate`
FROM world_countries
ORDER BY `Country/Territory` ASC;

-- Adding Density without CTE
SELECT `Country/Territory` AS `Country`, `2022 Population`,`2020 Population`,`2015 Population`, `Continent`, 
RANK() OVER(ORDER BY `2022 Population` DESC) AS `World Ranking`,
RANK() OVER(partition by `Continent` ORDER BY `2022 Population` DESC) AS `Continent Ranking`,
ROUND((((`2022 Population`/`2020 Population`)+(`2020 Population`/`2015 Population`))/2.0),2) AS `Growth Rate`, `Area (kmÂ²)` AS Area,
ROUND((`2022 Population`/`Area (kmÂ²)`),2) AS Density
FROM world_countries
ORDER BY `Country/Territory` ASC;


-- Density Grouping
WITH density AS (
SELECT `2022 Population`/`Area (kmÂ²)` AS Density, `Country/Territory` AS `Country` FROM world_countries
),

other_info AS(
SELECT `Country/Territory` AS `Country`, `2022 Population`, `Area (kmÂ²)` FROM world_countries),

density_grouping AS (
SELECT `Country`, CASE
WHEN `Density` <= 1000 THEN "Low Density"
WHEN `Density` BETWEEN 1000 AND 5000 THEN "Medium Density"
WHEN `Density` BETWEEN 5000 AND 10000 THEN "High Density"
WHEN `Density` > 10000 THEN "Very High Density"
END `Grouping` FROM density
),
everything AS (SELECT d.`Country`, d.`Density`, dg.`Grouping`, o.`2022 Population`
FROM other_info o
JOIN density d ON o.`Country` = d.`Country` 
JOIN density_grouping dg ON dg.`Country` = o.`Country`)

-- GROUPING BY DENSITY GROUP
-- SELECT `GROUPING`, COUNT(`COUNTRY`) FROM everything
-- GROUP BY `GROUPING`

SELECT * FROM everything;



-- Adding Area Per Person Without CTE
SELECT `Country/Territory` AS `Country`, `2022 Population`,`2020 Population`,`2015 Population`, `Continent`, 
RANK() OVER(ORDER BY `2022 Population` DESC) AS `World Ranking`,
RANK() OVER(partition by `Continent` ORDER BY `2022 Population` DESC) AS `Continent Ranking`,
ROUND((((`2022 Population`/`2020 Population`)+(`2020 Population`/`2015 Population`))/2.0),2) AS `Growth Rate`, `Area (kmÂ²)` AS Area,
ROUND((`2022 Population`/`Area (kmÂ²)`),2) AS Density,
ROUND((`Area (kmÂ²)`/`2022 Population`)*1000000,2) AS `Area Per Person Meter Square`
FROM world_countries
ORDER BY `Country/Territory` ASC;



-- World Population Percentage 
Select *,
ROUND((`2022 Population`)/ (SELECT SUM(`2022 Population`) FROM world_countries)*100,2) AS Percentage
from world_countries;


-- Comparing Continenets
SELECT `Continent`,
	SUM(`2022 Population`),
    SUM(`Area (kmÂ²)`)
    FROM world_countries
    group by `Continent`;
    
    
    
-- Ranking, Growth Rate, Density, , Density Grouping, Area Per Person, World Population Percentage    
    
-- Creating Temp Table For Tablaue Projectworld_countriesworld_countries 

CREATE TABLE ready_for_tablaue AS(   
WITH density AS (
SELECT `2022 Population`/`Area (kmÂ²)` AS Density, `Country/Territory` AS `Country` FROM world_countries
),
ranking AS(SELECT `Country/Territory` AS `Country`, 
RANK() OVER(ORDER BY `2022 Population` DESC) AS `World Ranking`,
RANK() OVER(partition by `Continent` ORDER BY `2022 Population` DESC) AS `Continent Ranking` 
FROM world_countries
),
growth_rate AS (
SELECT `Country/Territory` AS `Country`,
ROUND((((`2022 Population`/`2020 Population`)+(`2020 Population`/`2015 Population`))/2.0),2) AS `Growth Rate`
FROM world_countries
),
area_per_person AS (
SELECT `Country/Territory` AS `Country`,
ROUND((`Area (kmÂ²)`/`2022 Population`)*1000000,2) AS `Area Per Person Meter Square`
FROM world_countries
),
world_populatoin_percentage AS(
Select `Country/Territory` AS `Country`,
ROUND((`2022 Population`)/ (SELECT SUM(`2022 Population`) FROM world_countries)*100,2) AS Percentage
from world_countries
),
density_grouping AS (
SELECT `Country`, CASE
WHEN `Density` <= 1000 THEN "Low Density"
WHEN `Density` BETWEEN 1000 AND 5000 THEN "Medium Density"
WHEN `Density` BETWEEN 5000 AND 10000 THEN "High Density"
WHEN `Density` > 10000 THEN "Very High Density"
END `Grouping` FROM density
)
SELECT rnk.`World Ranking`, rnk.`Continent Ranking`, `CCA3`, `Country/Territory` AS `Country`, `Capital`, `2022 Population` AS population, gr.`Growth Rate`,wpp.`Percentage` AS `World Population Percentage`,`Area (kmÂ²)`,dsty.`Density`, app.`Area Per Person Meter Square`, dg.`Grouping`
	FROM world_countries wc
	JOIN density dsty
		ON wc.`Country/Territory` = dsty.`Country`
    JOIN ranking rnk
		ON wc.`Country/Territory` = rnk.`Country`
    JOIN growth_rate gr
		ON wc.`Country/Territory` = gr.`Country`
	JOIN area_per_person app
		ON wc.`Country/Territory` = app.`Country`
	JOIN world_populatoin_percentage wpp
		ON wc.`Country/Territory` = wpp.`Country`
	JOIN density_grouping dg
		ON wc.`Country/Territory` = dg.`Country`);
        
select * from ready_for_tablaue;
    



