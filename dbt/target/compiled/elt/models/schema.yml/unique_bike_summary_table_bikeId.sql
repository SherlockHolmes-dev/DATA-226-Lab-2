
    
    

select
    bikeId as unique_field,
    count(*) as n_records

from dev.analytics.bike_summary_table
where bikeId is not null
group by bikeId
having count(*) > 1


