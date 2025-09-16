-- Test: Customers recommended for limit increase should meet criteria
-- This should return no rows
SELECT 
    customer_id,
    recommended_action,
    customer_value_score,
    avg_utilisation_pct
FROM {{ ref('mart_customer_credit_profile') }}
WHERE recommended_action = 'INCREASE_LIMIT'
  AND (customer_value_score < 80 
       OR avg_utilisation_pct < 30 
       OR avg_utilisation_pct > 70)