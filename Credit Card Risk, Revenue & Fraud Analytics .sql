#Monthly Revenue: Merchant Fees + Interest

SELECT
    DATE_FORMAT(txn_timestamp, '%Y-%m') AS month,
    ROUND(SUM(txn_amount) * 0.015, 2) AS merchant_fee_revenue,
    ROUND(SUM(CASE WHEN txn_amount > 0 THEN txn_amount * 0.02 ELSE 0 END), 2) AS est_interest_revenue
FROM transactions
WHERE status = 'Success'
GROUP BY month
ORDER BY month;

#Credit Utilization & Risk Segmentation

SELECT 
    c.customer_id,
    ROUND(SUM(t.txn_amount) / MAX(cd.credit_limit) * 100, 2) AS utilization_pct,
    CASE 
        WHEN SUM(t.txn_amount) / MAX(cd.credit_limit) * 100 > 90 THEN 'Very High Risk'
        WHEN SUM(t.txn_amount) / MAX(cd.credit_limit) * 100 > 70 THEN 'High Risk'
        WHEN SUM(t.txn_amount) / MAX(cd.credit_limit) * 100 > 30 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM customers c
JOIN cards cd ON c.customer_id = cd.customer_id
JOIN transactions t ON cd.card_id = t.card_id
WHERE t.status = 'Success'
GROUP BY c.customer_id
ORDER BY utilization_pct DESC;


#Delinquency Exposure — DPD Buckets

SELECT
    CASE
        WHEN days_past_due = 0 THEN 'Current'
        WHEN days_past_due BETWEEN 1 AND 30 THEN '1-30 DPD'
        WHEN days_past_due BETWEEN 31 AND 60 THEN '31-60 DPD'
        WHEN days_past_due BETWEEN 61 AND 90 THEN '61-90 DPD'
        ELSE '90+ DPD'
    END AS dpd_bucket,
    COUNT(*) AS num_accounts,
    ROUND(SUM(closing_balance), 2) AS total_exposure
FROM statements
GROUP BY dpd_bucket
ORDER BY FIELD(dpd_bucket, 'Current','1-30 DPD','31-60 DPD','61-90 DPD','90+ DPD');

#Fraud Pattern — Rapid Cross-Country Transactions

SELECT 
    t1.card_id,
    t1.txn_id AS txn1,
    t2.txn_id AS txn2,
    TIMESTAMPDIFF(MINUTE, t1.txn_timestamp, t2.txn_timestamp) AS minutes_gap
FROM transactions t1
JOIN transactions t2
    ON t1.card_id = t2.card_id
   AND t2.txn_timestamp > t1.txn_timestamp
WHERE t1.txn_country <> t2.txn_country
  AND TIMESTAMPDIFF(MINUTE, t1.txn_timestamp, t2.txn_timestamp) <= 10;


#Customer Lifetime Value Estimate

SELECT
    c.customer_id,
    SUM(t.txn_amount) * 0.015 AS est_CLTV
FROM customers c
JOIN cards cd ON c.customer_id = cd.customer_id
JOIN transactions t ON cd.card_id = t.card_id
GROUP BY c.customer_id
ORDER BY est_CLTV DESC;


#Merchant Category Profitability

SELECT 
    merchant_category,
    COUNT(*) AS txn_count,
    ROUND(SUM(txn_amount),2) AS total_spend,
    ROUND(SUM(txn_amount) * 0.015,2) AS est_fee_revenue
FROM transactions
WHERE status = 'Success'
GROUP BY merchant_category
ORDER BY est_fee_revenue DESC;

#Revolving Credit Revenue — Interest Earning Customers Only - Business value: Identify revenue from customers who don’t pay in full — top source of banking profit.

SELECT 
    s.card_id,
    SUM(GREATEST(s.closing_balance - p.payment_amount, 0)) AS revolving_balance,
    ROUND(SUM(GREATEST(s.closing_balance - p.payment_amount, 0)) * 0.02, 2) AS est_interest_revenue
FROM statements s
LEFT JOIN payments p ON s.card_id = p.card_id
GROUP BY s.card_id
HAVING revolving_balance > 0
ORDER BY est_interest_revenue DESC;

#High-Value Customers — CLTV + Profitability - Business value: Target top customers for rewards & retention.

SELECT 
    c.customer_id,
    SUM(t.txn_amount) AS total_spend,
    ROUND(SUM(t.txn_amount) * 0.015, 2) AS revenue_from_fees,
    CASE WHEN SUM(t.txn_amount) > 20000 THEN 'High Value' ELSE 'Regular' END AS value_segment
FROM customers c
JOIN cards cd ON c.customer_id = cd.customer_id
JOIN transactions t ON cd.card_id = t.card_id
GROUP BY c.customer_id
ORDER BY total_spend DESC
LIMIT 20;

#Credit Score vs Utilization Risk Matrix - Business value: Classic banking risk model — Credit Score x Utilization segmentation.

SELECT
    c.customer_id,
    c.credit_score,
    ROUND(SUM(t.txn_amount) / MAX(cd.credit_limit) * 100, 2) AS utilization_pct,
    CASE 
        WHEN c.credit_score < 600 AND SUM(t.txn_amount) / MAX(cd.credit_limit) * 100 > 70 THEN 'High Default Risk'
        WHEN c.credit_score BETWEEN 600 AND 700 AND SUM(t.txn_amount) / MAX(cd.credit_limit) * 100 > 50 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_classification
FROM customers c
JOIN cards cd ON c.customer_id = cd.customer_id
JOIN transactions t ON cd.card_id = t.card_id
GROUP BY c.customer_id, c.credit_score
ORDER BY risk_classification DESC;

#Txn Count vs Revenue Elasticity by Product Type - Which products generate more revenue per transaction

SELECT
    cd.product_name,
    COUNT(t.txn_id) AS txn_count,
    ROUND(SUM(t.txn_amount),2) AS total_spend,
    ROUND(SUM(t.txn_amount) * 0.015, 2) AS merchant_fee_revenue,
    ROUND(AVG(t.txn_amount),2) AS avg_ticket_size
FROM transactions t
JOIN cards cd USING (card_id)
GROUP BY cd.product_name
ORDER BY merchant_fee_revenue DESC;

#Revolving Revenue Opportunity by Customer Segment - Find high-interest revenue customers

SELECT
    c.customer_id,
    ROUND(SUM(t.txn_amount)*0.02,2) AS pot_interest_rev,
    CASE 
        WHEN c.credit_score < 600 THEN 'High Yield Risk'
        WHEN c.credit_score BETWEEN 600 AND 700 THEN 'Medium Yield'
        ELSE 'Prime'
    END AS yield_segment
FROM customers c
JOIN cards cd USING (customer_id)
JOIN transactions t USING (card_id)
GROUP BY c.customer_id
ORDER BY pot_interest_rev DESC
LIMIT 50;

#Profit Curve by Location (Card market strategy) - Where should marketing invest more

SELECT 
    t.txn_city,
    ROUND(SUM(t.txn_amount),2) AS total_spend,
    ROUND(SUM(t.txn_amount) * 0.015, 2) AS revenue
FROM transactions t
GROUP BY txn_city
ORDER BY revenue DESC;

#Interchange ROI: Revenue by Merchant Category - Helps decide which merchant partnerships to strengthen

SELECT
    merchant_category,
    COUNT(*) AS txn_count,
    ROUND(SUM(txn_amount),2) AS total_spend,
    ROUND(SUM(txn_amount) * 0.015,2) AS interchange_revenue,
    ROUND((SUM(txn_amount) * 0.015) / COUNT(*), 3) AS revenue_per_txn
FROM transactions
GROUP BY merchant_category
ORDER BY revenue_per_txn DESC;


#Profitability Heatmap: Channel + Category - Used to detect high-profit behavior patterns

SELECT
    channel,
    merchant_category,
    ROUND(SUM(txn_amount) * 0.015, 2) AS revenue
FROM transactions
WHERE status='Success'
GROUP BY channel, merchant_category
ORDER BY revenue DESC;

