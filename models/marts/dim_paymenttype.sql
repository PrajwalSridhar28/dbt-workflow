with lookup_payment as(
    select * from {{ref('payment_type_lookup')}}
),

renamed as (
    select 
    payment_type,
    description as payment_type_description
    from lookup_payment
)

select * from renamed ORDER by payment_type