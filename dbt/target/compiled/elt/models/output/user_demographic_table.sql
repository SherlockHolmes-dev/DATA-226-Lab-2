with __dbt__cte__trip_data as (
SELECT
    *
FROM dev.raw_data.trip_data
) SELECT
    COALESCE(usertype, 'Other') AS usertype,
    COUNT(*) AS trip_count,
    ROUND(AVG(birth_year)) AS avg_birth_year,
    SUM(CASE WHEN gender = 1 THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN gender = 2 THEN 1 ELSE 0 END) AS female_count,
    SUM(CASE WHEN gender = 0 THEN 1 ELSE 0 END) AS unknown_gender_count,
    load_timestamp
FROM
    __dbt__cte__trip_data  -- Referencing the trip_data table in the raw_data schema
GROUP BY
    usertype, load_timestamp