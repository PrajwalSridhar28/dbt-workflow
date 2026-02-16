-- Data mart for monthly revenue analysis by pickup zone and service type
-- This aggregation is optimized for business reporting and dashboards
-- Enables analysis of revenue trends across different zones and taxi types
with interjust as (
select
    -- Grouping dimensions
    coalesce(pickup_zone, 'Unknown Zone') as pickup_zone,
    {% if target.type == 'bigquery' %}cast(date_trunc(pickup_datetime, month) as date)
    {% elif target.type == 'duckdb' %}date_trunc('month', pickup_datetime)
    {% endif %} as revenue_month,
    service_type,

    -- Revenue breakdown (summed by zone, month, and service type)
    sum(fare_amount) as revenue_monthly_fare,
    sum(extra) as revenue_monthly_extra,
    sum(mta_tax) as revenue_monthly_mta_tax,
    sum(tip_amount) as revenue_monthly_tip_amount,
    sum(tolls_amount) as revenue_monthly_tolls_amount,
    sum(ehail_fee) as revenue_monthly_ehail_fee,
    sum(improvement_surcharge) as revenue_monthly_improvement_surcharge,
    sum(total_amount) as revenue_monthly_total_amount,

    -- Additional metrics for operational analysis
    count(trip_id) as total_monthly_trips,
    avg(passenger_count) as avg_monthly_passenger_count,
    avg(trip_distance) as avg_monthly_trip_distance

from {{ ref('fct_trips') }}
group by pickup_zone, revenue_month, service_type
)

select
    service_type,
    sum(total_monthly_trips) as monthly_trips_total
from interjust
where 
  extract(year from revenue_month) = {{ var('year', 2019) }}
  and extract(month from revenue_month) = {{ var('month', 10) }}
group by service_type
order by monthly_trips_total desc
limit 10