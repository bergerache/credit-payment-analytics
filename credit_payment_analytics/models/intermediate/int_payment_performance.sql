{{ config(materialized='table') }}

WITH payment_data AS (
    SELECT * FROM {{ ref('stg_credit_card_data') }}
),

payment_summary AS (
    SELECT 
        customer_id,
        
        -- Count payment behaviours across all months
        (CASE WHEN pay_status_sep = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_aug = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jul = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jun = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_may = 'paid_in_full' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_apr = 'paid_in_full' THEN 1 ELSE 0 END) as full_payment_count,
        
        (CASE WHEN pay_status_sep LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_aug LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jul LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_jun LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_may LIKE 'payment_delay_%' THEN 1 ELSE 0 END +
         CASE WHEN pay_status_apr LIKE 'payment_delay_%' THEN 1 ELSE 0 END) as late_payment_count,
        
        -- Total amounts
        (pay_amt_sep + pay_amt_aug + pay_amt_jul + pay_amt_jun + pay_amt_may + pay_amt_apr) as total_paid,
        (bill_amt_sep + bill_amt_aug + bill_amt_jul + bill_amt_jun + bill_amt_may + bill_amt_apr) as total_billed
        
    FROM payment_data
)

SELECT 
    customer_id,
    full_payment_count,
    late_payment_count,
    total_paid,
    total_billed,
    
    -- Customer value score from business perspective
CASE 
    -- Perfect revolvers (no late, mostly revolving)
    WHEN late_payment_count = 0 AND full_payment_count <= 2 THEN 100
    
    -- Good revolvers (no late, some revolving)
    WHEN late_payment_count = 0 AND full_payment_count <= 4 THEN 80
    
    -- "Deadbeats" (no late but pay in full too often)
    WHEN late_payment_count = 0 AND full_payment_count >= 5 THEN 40
    
    -- Acceptable risk revolvers (1 late, still revolving)
    WHEN late_payment_count = 1 AND full_payment_count <= 3 THEN 60
    
    -- Higher risk (1 late, less profitable)
    WHEN late_payment_count = 1 AND full_payment_count >= 4 THEN 35
    
    -- 2 late but good revolver (still generates revenue)
    WHEN late_payment_count = 2 AND full_payment_count <= 2 THEN 30
    
    -- 2 late and not profitable
    WHEN late_payment_count = 2 AND full_payment_count >= 3 THEN 20
    
    -- High risk (3+ late payments)
    ELSE 15
END as customer_value_score

FROM payment_summary