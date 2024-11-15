{% snapshot snapshot_bike_summary_table %}

{{
  config(
    target_schema='snapshots',
    unique_key='bikeId',
    strategy='timestamp',
    updated_at='load_timestamp',
    invalidate_hard_deletes=True 
  )
}}  

SELECT * FROM {{ ref('bike_summary_table') }}

{% endsnapshot %}