{{ config(materialized='table') }}

WITH payment_data AS (
    SELECT * FROM {{ ref('stg_credit_card_data') }}
),

payment_summary AS (
    SELECT 
        customer_id,
        
        -- Add account_in_credit count (BEST payers but least profitable)
        (CASE WHEN pay_status_sep = 'account_in_credit' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_aug = 'account_in_credit' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jul = 'account_in_credit' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jun = 'account_in_credit' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_may = 'account_in_credit' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_apr = 'account_in_credit' THEN 1 ELSE 0 END) as overpaid_count,

        -- Count payment behaviours across all months
        (CASE WHEN pay_status_sep = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_aug = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jul = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jun = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_may = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_apr = 'paid_in_full' THEN 1 ELSE 0 END) as full_payment_count,

         -- Add minimum_payment_only count (TRUE revolvers!)
        (CASE WHEN pay_status_sep = 'minimum_payment_only' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_aug = 'minimum_payment_only' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jul = 'minimum_payment_only' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jun = 'minimum_payment_only' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_may = 'minimum_payment_only' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_apr = 'minimum_payment_only' THEN 1 ELSE 0 END) as minimum_payment_count,
        
        (CASE WHEN pay_status_sep LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_aug LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jul LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jun LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_may LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_apr LIKE 'payment_delay_%' THEN 1 ELSE 0 END) as late_payment_count,
        
        -- Add average balance to identify true revolvers vs transactors
        (bill_amt_sep + bill_amt_aug + bill_amt_jul + bill_amt_jun + bill_amt_may + bill_amt_apr) / 6 as avg_balance,
        -- Total amounts
        (pay_amt_sep + pay_amt_aug + pay_amt_jul + pay_amt_jun + pay_amt_may + pay_amt_apr) as total_paid,
        (bill_amt_sep + bill_amt_aug + bill_amt_jul + bill_amt_jun + bill_amt_may + bill_amt_apr) as total_billed
        
    FROM payment_data
)

SELECT 
    customer_id,
    overpaid_count,
    full_payment_count,
    minimum_payment_count,
    late_payment_count,
    avg_balance,
    total_paid,
    total_billed,
    
    
    -- Customer value score from business perspective
CASE 
    -- TIER 1: Premium (Score 100) - Profitable revolvers with perfect payment
    WHEN late_payment_count = 0 
        AND minimum_payment_count >= 3
        AND avg_balance > 1000
    THEN 100

    -- TIER 2: Standard (Score 80) - Good payers, some value
    WHEN late_payment_count = 0
        AND avg_balance > 500
    THEN 80

    -- TIER 3: Acceptable Risk (Score 60) - 1 late or low profitability
    WHEN late_payment_count = 1
        OR (late_payment_count = 0 AND avg_balance <= 500)
    THEN 60

    -- TIER 4: Monitor (Score 40) - Multiple risk signals
    WHEN late_payment_count = 2
        OR overpaid_count >= 2
    THEN 40

    -- TIER 5A: Inactive/Dormant (Score 30) - No activity, not necessarily risky
    WHEN (late_payment_count + minimum_payment_count + full_payment_count + overpaid_count) <= 1
        AND avg_balance < 100
    THEN 30

    -- TIER 5B: High Risk (Score 15) - Serious delinquency
    WHEN late_payment_count >= 3
    THEN 15

    -- Catch-all for unusual patterns
    ELSE 20

END as customer_value_score

FROM payment_summary