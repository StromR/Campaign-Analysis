-- Key Performance Metrics
WITH campaign_metrics AS (
    SELECT 
        c.campaign_id,
        c.campaign_name,
        c.budget,
        cm.impressions,
        cm.clicks,
        cm.website_landing_hits,
        
        -- Calculate metrics
        ROUND(SAFE_DIVIDE(cm.clicks, cm.impressions) * 100, 2) AS ctr_percent,
        ROUND(SAFE_DIVIDE(cm.clicks - cm.website_landing_hits, cm.clicks) * 100, 2) AS bounce_rate_percent,
        ROUND(SAFE_DIVIDE(c.budget, cm.clicks), 2) AS cost_per_click,
        ROUND(SAFE_DIVIDE(cm.website_landing_hits, cm.clicks) * 100, 2) AS landing_page_conversion_rate
    FROM `DATASET.campaigns` c
    JOIN `DATASET.campaign_metrics` cm 
        ON c.campaign_id = cm.campaign_id
),
revenue_metrics AS (
    SELECT 
        t.campaign_id,
        COUNT(t.transaction_id) AS total_transactions,
        SUM(t.amount) AS total_revenue,
        ROUND(AVG(t.amount), 2) AS avg_transaction_value,
        COUNT(DISTINCT t.customer_id) AS unique_customers
    FROM `DATASET.transactions` t
    GROUP BY t.campaign_id
)
SELECT 
    cm.*,
    COALESCE(rm.total_transactions, 0) AS total_transactions,
    COALESCE(rm.total_revenue, 0) AS total_revenue,
    COALESCE(rm.avg_transaction_value, 0) AS avg_transaction_value,
    COALESCE(rm.unique_customers, 0) AS unique_customers,
    
    -- ROI 
    ROUND(SAFE_DIVIDE(COALESCE(rm.total_revenue, 0) - cm.budget, cm.budget) * 100, 2) AS roi_percent,
    
    -- Conversion rate from landing page hits to transactions
    ROUND(SAFE_DIVIDE(COALESCE(rm.total_transactions, 0), cm.website_landing_hits) * 100, 2) AS final_conversion_rate_percent,
    
    -- Cost per acquisition
    ROUND(SAFE_DIVIDE(cm.budget, COALESCE(rm.total_transactions, 0)), 2) AS cost_per_acquisition

FROM campaign_metrics cm
LEFT JOIN revenue_metrics rm 
    ON cm.campaign_id = rm.campaign_id;
