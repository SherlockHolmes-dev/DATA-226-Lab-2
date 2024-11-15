SELECT
    EXTRACT(DAYOFWEEK, starttime) AS day_of_week,
    COUNT(*) AS total_trips,
    load_timestamp
FROM 
    {{ ref("trip_data") }}
GROUP BY 
    day_of_week, load_timestamp
ORDER BY 
    day_of_week