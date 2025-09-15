{{ config(materialized='table') }}

WITH monthly_utilisation AS (
    SELECT 
        customer_id,
        credit_limit,
        
        -- Calculate utilisation for each month
        ROUND(bill_amt_sep / NULLIF(credit_limit, 0) * 100, 2) as util_sep,
        ROUND(bill_amt_aug / NULLIF(credit_limit, 0) * 100, 2) as util_aug,
        ROUND(bill_amt_jul / NULLIF(credit_limit, 0) * 100, 2) as util_jul,
        ROUND(bill_amt_jun / NULLIF(credit_limit, 0) * 100, 2) as util_jun,
        ROUND(bill_amt_may / NULLIF(credit_limit, 0) * 100, 2) as util_may,
        ROUND(bill_amt_apr / NULLIF(credit_limit, 0) * 100, 2) as util_apr
        
    FROM {{ ref('stg_credit_card_data') }}
)

SELECT 
    customer_id,
    credit_limit,
    
    -- Average utilisation
    ROUND((util_sep + util_aug + util_jul + util_jun + util_may + util_apr) / 6, 2) as avg_utilisation_pct,
    
    -- Max utilisation (risk indicator)
    GREATEST(util_sep, util_aug, util_jul, util_jun, util_may, util_apr) as max_utilisation_pct,
    
    -- Count months over limit
    (CASE WHEN util_sep > 100 THEN 1 ELSE 0 END +
     CASE WHEN util_aug > 100 THEN 1 ELSE 0 END +
     CASE WHEN util_jul > 100 THEN 1 ELSE 0 END +
     CASE WHEN util_jun > 100 THEN 1 ELSE 0 END +
     CASE WHEN util_may > 100 THEN 1 ELSE 0 END +
     CASE WHEN util_apr > 100 THEN 1 ELSE 0 END) as months_over_limit,
    
   -- Volatility proxy: difference between max and min
    (GREATEST(util_sep, util_aug, util_jul, util_jun, util_may, util_apr) - 
    LEAST(util_sep, util_aug, util_jul, util_jun, util_may, util_apr)) as utilisation_range

FROM monthly_utilisation