with __dbt__cte__trip_data as (
SELECT
    *
FROM dev.raw_data.trip_data
) SELECT
    CASE
        WHEN EXTRACT(MONTH, starttime) IN (12, 1, 2) THEN 'Winter (Dec-Feb)'
        WHEN EXTRACT(MONTH, starttime) IN (3, 4, 5) THEN 'Spring (Mar-May)'
        WHEN EXTRACT(MONTH, starttime) IN (6, 7, 8) THEN 'Summer (Jun-Aug)'
        WHEN EXTRACT(MONTH, starttime) IN (9, 10, 11) THEN 'Fall (Sept-Nov)'
    END AS season,
    COUNT(*) AS total_trips,
    AVG(tripduration) AS avg_trip_duration,
    load_timestamp
FROM 
    __dbt__cte__trip_data
GROUP BY 
    season, load_timestamp