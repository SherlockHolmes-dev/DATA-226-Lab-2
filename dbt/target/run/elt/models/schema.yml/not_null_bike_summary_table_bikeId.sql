select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select bikeId
from dev.analytics.bike_summary_table
where bikeId is null



      
    ) dbt_internal_test