SELECT
    bikeid,
    COUNT(*) AS total_trips,
    AVG(tripduration) AS avg_trip_duration,
    SUM(tripduration) AS total_trip_duration,
    load_timestamp
FROM 
    {{ ref("trip_data") }}
GROUP BY 
    bikeid, load_timestamp
ORDER BY 
    total_trips DESC