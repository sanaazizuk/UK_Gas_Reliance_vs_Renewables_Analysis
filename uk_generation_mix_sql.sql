CREATE DATABASE uk_energy;
USE uk_energy;


CREATE TABLE generation_mix (
    period_start DATETIME,
    period_end DATETIME,
    biomass_pct FLOAT,
    coal_pct FLOAT,
    imports_pct FLOAT,
    gas_pct FLOAT,
    nuclear_pct FLOAT,
    other_pct FLOAT,
    hydro_pct FLOAT,
    solar_pct FLOAT,
    wind_pct FLOAT,
    total_pct FLOAT,
    month VARCHAR(10),
    month_num INT,
    hour INT,
    day_of_week VARCHAR(10),
    date DATE,
    season VARCHAR(10),
    is_low_wind_day VARCHAR(5)
);
# deleting table content but keeping structure created
TRUNCATE TABLE generation_mix;

SELECT * FROM  generation_mix

SELECT COUNT(*) FROM generation_mix;

#Average gas share by month
SELECT month, month_num, ROUND(AVG(gas_pct), 1) AS avg_gas_pct
FROM generation_mix
GROUP BY month, month_num
ORDER BY month_num;

#Gas share by season
SELECT season, ROUND(AVG(gas_pct), 1) AS avg_gas_pct
FROM generation_mix
GROUP BY season
ORDER BY FIELD(season, 'Winter', 'Spring', 'Summer', 'Autumn');

#Gas share,  low wind days vs rest of year
SELECT 
is_low_wind_day,
ROUND(AVG(gas_pct), 1) AS avg_gas_pct,
COUNT(DISTINCT date) AS num_days
FROM generation_mix
GROUP BY is_low_wind_day;

#Top 5 highest gas reliance days
SELECT date, ROUND(AVG(gas_pct), 1) AS avg_gas_pct
FROM generation_mix
GROUP BY date
ORDER BY avg_gas_pct DESC
LIMIT 5;

#Gas share by hour of day (for your hourly pattern chart)
SELECT hour, ROUND(AVG(gas_pct), 1) AS avg_gas_pct
FROM generation_mix
GROUP BY hour
ORDER BY hour;

#A window function  month over month change in gas share
SELECT 
month_num,
month,
ROUND(AVG(gas_pct), 1) AS avg_gas_pct,
ROUND(AVG(gas_pct) - LAG(AVG(gas_pct)) OVER (ORDER BY month_num), 1) AS change_vs_prev_month
FROM generation_mix
GROUP BY month_num, month
ORDER BY month_num;

#One thing worth doing with that October finding
#as all 5 top days cluster in midOctober, its worth a quick follow up query to check if thats a genuine lowwind spell
SELECT date, ROUND(AVG(gas_pct), 1) AS avg_gas_pct, ROUND(AVG(wind_pct), 1) AS avg_wind_pct
FROM generation_mix
WHERE date BETWEEN '2025-10-12' AND '2025-10-18'
GROUP BY date
ORDER BY date;



## Key Finding

#Gas share of UK generation nearly doubles on low wind days, rising from 
#around 25.5% on a typical day to around 45.1% on days when wind output 
#drops below 10%. Across the 12 month period analysed (356 days), there 
#were 17 such low wind days, about 5% of the year.

#This is not just a statistical pattern. During 12 to 17 October 2025, 
#wind output fell to between 5% and 10.5% for six consecutive days, and 
#gas share rose correspondingly, reaching as high as 64.5% on 13 October, 
#the single highest gas reliant day of the year. Once wind recovered to 
#over 30% on 18 October, gas share fell straight back down to 30.8%.

#This pattern also shows up seasonally. Gas reliance peaks in winter 
#(29.2%) and falls to its lowest in summer (24.3%), tracking closely with 
#when wind and solar output are naturally weaker.

#Together, these patterns suggest that as wind and solar capacity has 
#grown, gas has not disappeared from the UK's energy mix. It has instead 
#concentrated into a smaller number of high reliance moments, both 
#predictable ones such as winter, and specific short lived events such as 
#the mid October low wind spell. Rather than a steady year round 
#dependency, gas increasingly acts as a backup fuel that the grid leans on 
#heavily during these conditions.

#For grid planning and policy, this reframes the question. It is not just 
#how much gas the UK uses on average, but how much flexible backup 
#capacity is needed to cover the gaps when wind and solar underperform. 
#This analysis shows those gaps are concentrated, not random, and can 
#persist for several days at a time.