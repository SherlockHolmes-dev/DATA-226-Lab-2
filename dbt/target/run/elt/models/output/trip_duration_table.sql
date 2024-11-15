
  
    

        create or replace transient table dev.analytics.trip_duration_table
         as
        (with __dbt__cte__trip_data as (
SELECT
    *
FROM dev.raw_data.trip_data
) SELECT
    CASE
        WHEN tripduration < 300 THEN '0-5 mins'
        WHEN tripduration BETWEEN 300 AND 600 THEN '5-10 mins'
        WHEN tripduration BETWEEN 600 AND 1200 THEN '10-20 mins'
        WHEN tripduration BETWEEN 1200 AND 1800 THEN '20-30 mins'
        ELSE '30+ mins'
    END AS duration_range,
    COUNT(*) AS trip_count,
    AVG(tripduration) AS avg_trip_duration,
    load_timestamp
FROM 
    __dbt__cte__trip_data 
GROUP BY 
    duration_range, load_timestamp
ORDER BY 2 DESC
        );
      
  