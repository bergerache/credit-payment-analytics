
-- Test: High value customers shouldn't have multiple late payments
-- This should return no rows
SELECT 
    customer_id,
    customer_value_score,
    late_payment_count
FROM {{ ref('mart_customer_credit_profile') }}
WHERE customer_value_score >= 80 
  AND late_payment_count > 1
