-- customer_demographics
  SELECT 
    c.campaign_id,
    c.campaign_name,
    
    -- Gender Analysis
    t.gender,
    t.product_category,
    COUNT(DISTINCT t.transaction_id) as transactions_by_gender,
    ROUND(AVG(t.amount), 2) as avg_transaction_by_gender,
    SUM(t.amount) as total_revenue_by_gender,
    ROUND(AVG(t.age), 2) as avg_age_by_gender,
    
    -- Age Group Analysis
    CASE 
        WHEN t.age BETWEEN 18 AND 29 THEN '18-29'
        WHEN t.age BETWEEN 30 AND 39 THEN '30-39'
        WHEN t.age BETWEEN 40 AND 49 THEN '40-49'
        WHEN t.age BETWEEN 50 AND 59 THEN '50-59'
        WHEN t.age >= 60 THEN '60+'
        ELSE 'Uncategorized'
    END AS age_group,
    
    -- Performance Metrics by Demographics
    ROUND(SAFE_DIVIDE(SUM(t.amount), COUNT(DISTINCT t.transaction_id)), 2) as revenue_per_transaction
    
  FROM `DATASET.campaigns` c
  JOIN `DATASET.transactions` t 
    ON c.campaign_id = t.campaign_id
  GROUP BY 1,2,3,4,9