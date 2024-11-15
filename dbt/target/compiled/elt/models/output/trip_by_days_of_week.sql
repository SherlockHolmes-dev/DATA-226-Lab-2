with __dbt__cte__trip_data as (
SELECT
    *
FROM dev.raw_data.trip_data
) SELECT
    EXTRACT(DAYOFWEEK, starttime) AS day_of_week,
    COUNT(*) AS total_trips,
    load_timestamp
FROM 
    __dbt__cte__trip_data
GROUP BY 
    day_of_week, load_timestamp
ORDER BY 
    day_of_week