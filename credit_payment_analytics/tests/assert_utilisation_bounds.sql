-- Test: Utilisation percentages should be within reasonable bounds
-- This should return no rows
SELECT 
    customer_id,
    avg_utilisation_pct,
    max_utilisation_pct
FROM {{ ref('int_utilisation_analysis') }}
WHERE avg_utilisation_pct > 600 
   
