{{ config(materialized='table') }}

WITH customer_base AS (
    SELECT * FROM {{ ref('stg_credit_card_data') }}
),

payment_metrics AS (
    SELECT * FROM {{ ref('int_payment_performance') }}
),

utilisation_metrics AS (
    SELECT * FROM {{ ref('int_utilisation_analysis') }}
)

SELECT 
    cb.customer_id,
    cb.age,
    cb.gender,
    cb.education_level,
    cb.marital_status,
    cb.credit_limit,
    
    -- Payment behaviour
    pm.full_payment_count,
    pm.late_payment_count,
    pm.customer_value_score,
    
    -- Utilisation patterns
    um.avg_utilisation_pct,
    um.max_utilisation_pct,
    um.months_over_limit,
    um.utilisation_range,
    
    -- Business decisions
    CASE 
        WHEN pm.customer_value_score >= 80 AND um.avg_utilisation_pct BETWEEN 30 AND 70 THEN 'INCREASE_LIMIT'
        WHEN pm.customer_value_score >= 60 AND um.months_over_limit = 0 THEN 'MAINTAIN'
        WHEN pm.customer_value_score < 35 OR um.months_over_limit > 2 THEN 'REVIEW_ACCOUNT'
        ELSE 'MONITOR'
    END as recommended_action

FROM customer_base cb
LEFT JOIN payment_metrics pm ON cb.customer_id = pm.customer_id
LEFT JOIN utilisation_metrics um ON cb.customer_id = um.customer_id