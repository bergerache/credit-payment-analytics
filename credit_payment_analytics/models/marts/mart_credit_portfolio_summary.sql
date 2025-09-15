{{ config(materialized='table') }}

WITH customer_profiles AS (
    SELECT * FROM {{ ref('mart_customer_credit_profile') }}
)

SELECT 
    -- Portfolio segmentation
    recommended_action,
    COUNT(*) as customer_count,
    
    -- Financial metrics
    ROUND(AVG(credit_limit), 0) as avg_credit_limit,
    ROUND(SUM(credit_limit), 0) as total_credit_extended,
    
    -- Risk metrics
    ROUND(AVG(customer_value_score), 1) as avg_value_score,
    ROUND(AVG(avg_utilisation_pct), 1) as avg_utilisation,
    ROUND(AVG(late_payment_count), 2) as avg_late_payments,
    SUM(months_over_limit) as total_overlimit_incidents,
    
    -- Portfolio distribution
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) as pct_of_portfolio,
    ROUND(100.0 * SUM(credit_limit) / SUM(SUM(credit_limit)) OVER (), 1) as pct_of_total_credit

FROM customer_profiles
GROUP BY recommended_action
ORDER BY 
    CASE recommended_action
        WHEN 'INCREASE_LIMIT' THEN 1
        WHEN 'MAINTAIN' THEN 2
        WHEN 'MONITOR' THEN 3
        WHEN 'REVIEW_ACCOUNT' THEN 4
    END