with taxi_zone as  (
    select * from {{ref('taxi_zone_lookup')}}
),

renamed as (
    select 
    locationid as location_id,
    Borough,
    zone,
    service_zone
    from taxi_zone
)

select * from renamed ORDER BY location_id