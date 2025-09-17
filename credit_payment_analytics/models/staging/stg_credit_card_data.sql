{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ ref('raw_credit_card_data') }}
)

SELECT 
    -- Customer identifiers
    ID as customer_id,
    LIMIT_BAL as credit_limit,
    AGE as age,
    
    -- Decode demographics
    CASE SEX
        WHEN 1 THEN 'male'
        WHEN 2 THEN 'female'
        ELSE 'unknown'
    END as gender,
    
    CASE EDUCATION
        WHEN 0 THEN 'unknown'
        WHEN 1 THEN 'graduate_school'
        WHEN 2 THEN 'university'
        WHEN 3 THEN 'high_school'
        WHEN 4 THEN 'other'
        WHEN 5 THEN 'unknown'
        WHEN 6 THEN 'unknown'
        ELSE 'unknown'
    END as education_level,
    
    CASE MARRIAGE
        WHEN 0 THEN 'unknown'
        WHEN 1 THEN 'married'
        WHEN 2 THEN 'single'
        WHEN 3 THEN 'other'
        ELSE 'unknown'
    END as marital_status,
    
    -- Decode payment statuses
    CASE PAY_0
        WHEN -2 THEN 'account_in_credit'
        WHEN -1 THEN 'paid_in_full'
        WHEN 0 THEN 'minimum_payment_only'
        WHEN 1 THEN 'payment_delay_1m'
        WHEN 2 THEN 'payment_delay_2m'
        WHEN 3 THEN 'payment_delay_3m'
        WHEN 4 THEN 'payment_delay_4m'
        WHEN 5 THEN 'payment_delay_5m'
        WHEN 6 THEN 'payment_delay_6m'
        WHEN 7 THEN 'payment_delay_7m'
        WHEN 8 THEN 'payment_delay_8m'
        ELSE 'unknown'
    END as pay_status_sep,
    
    CASE PAY_2
        WHEN -2 THEN 'account_in_credit'
        WHEN -1 THEN 'paid_in_full'
        WHEN 0 THEN 'minimum_payment_only'
        WHEN 1 THEN 'payment_delay_1m'
        WHEN 2 THEN 'payment_delay_2m'
        WHEN 3 THEN 'payment_delay_3m'
        WHEN 4 THEN 'payment_delay_4m'
        WHEN 5 THEN 'payment_delay_5m'
        WHEN 6 THEN 'payment_delay_6m'
        WHEN 7 THEN 'payment_delay_7m'
        WHEN 8 THEN 'payment_delay_8m'
        ELSE 'unknown'
    END as pay_status_aug,
    
    
    CASE PAY_3
        WHEN -2 THEN 'account_in_credit'
        WHEN -1 THEN 'paid_in_full'
        WHEN 0 THEN 'minimum_payment_only'
        WHEN 1 THEN 'payment_delay_1m'
        WHEN 2 THEN 'payment_delay_2m'
        WHEN 3 THEN 'payment_delay_3m'
        WHEN 4 THEN 'payment_delay_4m'
        WHEN 5 THEN 'payment_delay_5m'
        WHEN 6 THEN 'payment_delay_6m'
        WHEN 7 THEN 'payment_delay_7m'
        WHEN 8 THEN 'payment_delay_8m'
        ELSE 'unknown'
    END as pay_status_jul,
    
    CASE PAY_4
        WHEN -2 THEN 'account_in_credit'
        WHEN -1 THEN 'paid_in_full'
        WHEN 0 THEN 'minimum_payment_only'
        WHEN 1 THEN 'payment_delay_1m'
        WHEN 2 THEN 'payment_delay_2m'
        WHEN 3 THEN 'payment_delay_3m'
        WHEN 4 THEN 'payment_delay_4m'
        WHEN 5 THEN 'payment_delay_5m'
        WHEN 6 THEN 'payment_delay_6m'
        WHEN 7 THEN 'payment_delay_7m'
        WHEN 8 THEN 'payment_delay_8m'
        ELSE 'unknown'
    END as pay_status_jun,
    
    CASE PAY_5
        WHEN -2 THEN 'account_in_credit'
        WHEN -1 THEN 'paid_in_full'
        WHEN 0 THEN 'minimum_payment_only'
        WHEN 1 THEN 'payment_delay_1m'
        WHEN 2 THEN 'payment_delay_2m'
        WHEN 3 THEN 'payment_delay_3m'
        WHEN 4 THEN 'payment_delay_4m'
        WHEN 5 THEN 'payment_delay_5m'
        WHEN 6 THEN 'payment_delay_6m'
        WHEN 7 THEN 'payment_delay_7m'
        WHEN 8 THEN 'payment_delay_8m'
        ELSE 'unknown'
    END as pay_status_may,
    
    CASE PAY_6
        WHEN -2 THEN 'account_in_credit'
        WHEN -1 THEN 'paid_in_full'
        WHEN 0 THEN 'minimum_payment_only'
        WHEN 1 THEN 'payment_delay_1m'
        WHEN 2 THEN 'payment_delay_2m'
        WHEN 3 THEN 'payment_delay_3m'
        WHEN 4 THEN 'payment_delay_4m'
        WHEN 5 THEN 'payment_delay_5m'
        WHEN 6 THEN 'payment_delay_6m'
        WHEN 7 THEN 'payment_delay_7m'
        WHEN 8 THEN 'payment_delay_8m'
        ELSE 'unknown'
    END as pay_status_apr,
    
    
    -- Bill amounts (keep as-is)
    BILL_AMT1 as bill_amt_sep,
    BILL_AMT2 as bill_amt_aug,
    BILL_AMT3 as bill_amt_jul,
    BILL_AMT4 as bill_amt_jun,
    BILL_AMT5 as bill_amt_may,
    BILL_AMT6 as bill_amt_apr,
    
    -- Payment amounts (keep as-is)
    PAY_AMT1 as pay_amt_sep,
    PAY_AMT2 as pay_amt_aug,
    PAY_AMT3 as pay_amt_jul,
    PAY_AMT4 as pay_amt_jun,
    PAY_AMT5 as pay_amt_may,
    PAY_AMT6 as pay_amt_apr

FROM source