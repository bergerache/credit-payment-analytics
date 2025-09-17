-- tests/assert_recommended_action_logic.sql
-- Test: All recommended actions should meet their criteria
-- This should return no rows if logic is correct

-- Test 1: INCREASE_LIMIT validation
SELECT 
    customer_id,
    customer_value_score,
    avg_utilisation_pct,
    'INCREASE_LIMIT failed' as test_failure
FROM {{ ref('mart_customer_credit_profile') }}
WHERE recommended_action = 'INCREASE_LIMIT'
  AND NOT (
    customer_value_score >= 80 
    AND avg_utilisation_pct >= 50 
    AND avg_utilisation_pct <= 75
  )

UNION ALL

-- Test 2: MAINTAIN validation  
SELECT 
    customer_id,
    customer_value_score,
    avg_utilisation_pct,
    'MAINTAIN failed' as test_failure
FROM {{ ref('mart_customer_credit_profile') }}
WHERE recommended_action = 'MAINTAIN'
  AND NOT (
    (customer_value_score >= 80 AND avg_utilisation_pct <= 85)
    OR (customer_value_score >= 60 AND avg_utilisation_pct <= 85)
  )

UNION ALL

-- Test 3: REVIEW_ACCOUNT validation
SELECT 
    customer_id,
    customer_value_score,
    avg_utilisation_pct,
    'REVIEW_ACCOUNT failed' as test_failure
FROM {{ ref('mart_customer_credit_profile') }}
WHERE recommended_action = 'REVIEW_ACCOUNT'
  AND NOT (
    customer_value_score <= 40
    OR avg_utilisation_pct > 95
    OR (customer_value_score < 60 AND customer_value_score >= 40 AND avg_utilisation_pct > 90)  -- Fixed!
  )