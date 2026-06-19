SELECT
    COALESCE(traffic_source, '(unknown)') AS traffic_source,
    COUNT(*)                               AS sessions,
    SUM(purchased)                         AS purchased,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2)         AS pct_overall_conversion,
    ROUND(SUM(revenue) / NULLIF(SUM(purchased), 0), 2)  AS avg_order_value,
    ROUND(SUM(revenue), 2)                              AS total_revenue
FROM session_funnel
GROUP BY traffic_source
ORDER BY sessions DESC
LIMIT 15;
