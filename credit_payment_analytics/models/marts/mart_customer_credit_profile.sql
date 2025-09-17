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
    pm.overpaid_count,
    pm.minimum_payment_count,
    pm.customer_value_score,
    pm.avg_balance,  
    pm.total_paid,
    pm.total_billed,
    
    -- Utilisation patterns
    um.avg_utilisation_pct,
    um.max_utilisation_pct,
    um.months_over_limit,
    um.utilisation_range,
    
    -- Business decisions
   CASE 
    -- High-value customers with room to grow
    WHEN pm.customer_value_score >= 80 
        AND um.avg_utilisation_pct BETWEEN 50 AND 75
    THEN 'INCREASE_LIMIT'
    
    -- Premium customers with risk signals
    WHEN pm.customer_value_score >= 80 
        AND um.avg_utilisation_pct > 85
    THEN 'MONITOR'
    
    -- High-value customers well-managed 
    WHEN pm.customer_value_score >= 80 
        AND um.avg_utilisation_pct <= 85  
    THEN 'MAINTAIN'
    
    -- Standard customers in good standing
    WHEN pm.customer_value_score >= 60 
        AND um.avg_utilisation_pct <= 85
    THEN 'MAINTAIN'
    
    -- Clear risk signals requiring review
    WHEN pm.customer_value_score <= 40
        OR um.avg_utilisation_pct > 95
        OR (pm.customer_value_score < 60 AND um.avg_utilisation_pct > 90)
    THEN 'REVIEW_ACCOUNT'
    
    ELSE 'MONITOR'

    
END as recommended_action

FROM customer_base cb
LEFT JOIN payment_metrics pm ON cb.customer_id = pm.customer_id
LEFT JOIN utilisation_metrics um ON cb.customer_id = um.customer_id