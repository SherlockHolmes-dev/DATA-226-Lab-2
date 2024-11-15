with __dbt__cte__trip_data as (
SELECT
    *
FROM dev.raw_data.trip_data
) SELECT
    COUNT(*) AS total_trips,
    AVG(tripduration) AS avg_trip_duration,
    SUM(tripduration) AS total_trip_duration,
    COUNT(DISTINCT bikeid) AS unique_bikes,
    COUNT(DISTINCT start_station_id) AS unique_start_stations,
    COUNT(DISTINCT end_station_id) AS unique_end_stations,
    COUNT(DISTINCT usertype) AS unique_user_types,
    EXTRACT(HOUR FROM starttime) AS trip_hour,
    load_timestamp
FROM
    __dbt__cte__trip_data  -- Referencing the trip_data table in the raw_data schema
GROUP BY
    trip_hour, load_timestamp
ORDER BY
    trip_hour