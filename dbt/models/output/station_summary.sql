SELECT
    start_station_id,
    start_station_name,
    COUNT(*) AS total_trips_started,
    AVG(tripduration) AS avg_trip_duration,
    SUM(tripduration) AS total_trip_duration,
    load_timestamp
FROM 
    {{ ref("trip_data") }} 
GROUP BY 
    start_station_id, start_station_name, load_timestamp