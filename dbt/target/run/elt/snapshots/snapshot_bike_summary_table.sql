
      
  
    

        create or replace transient table dev.snapshots.snapshot_bike_summary_table
         as
        (
    

    select *,
        md5(coalesce(cast(bikeId as varchar ), '')
         || '|' || coalesce(cast(load_timestamp as varchar ), '')
        ) as dbt_scd_id,
        load_timestamp as dbt_updated_at,
        load_timestamp as dbt_valid_from,
        
  
  coalesce(nullif(load_timestamp, load_timestamp), null)
  as dbt_valid_to

    from (
        

  

SELECT * FROM dev.analytics.bike_summary_table

    ) sbq



        );
      
  
  