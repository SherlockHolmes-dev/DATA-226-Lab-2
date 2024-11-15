with __dbt__cte__trip_data as (
SELECT
    *
FROM dev.raw_data.trip_data
) SELECT
    bikeid,
    COUNT(*) AS total_trips,
    AVG(tripduration) AS avg_trip_duration,
    SUM(tripduration) AS total_trip_duration,
    load_timestamp
FROM 
    __dbt__cte__trip_data
GROUP BY 
    bikeid, load_timestamp
ORDER BY 
    total_trips DESC