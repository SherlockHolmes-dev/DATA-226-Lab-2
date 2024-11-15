
  
    

        create or replace transient table dev.analytics.station_summary
         as
        (with __dbt__cte__trip_data as (
SELECT
    *
FROM dev.raw_data.trip_data
) SELECT
    start_station_id,
    start_station_name,
    COUNT(*) AS total_trips_started,
    AVG(tripduration) AS avg_trip_duration,
    SUM(tripduration) AS total_trip_duration,
    load_timestamp
FROM 
    __dbt__cte__trip_data 
GROUP BY 
    start_station_id, start_station_name, load_timestamp
        );
      
  