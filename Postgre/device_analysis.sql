SELECT
    COALESCE(device_category, '(unknown)') AS device_category,
    COUNT(*)                                AS sessions,
    SUM(viewed)                             AS viewed,
    SUM(cart)                               AS cart,
    SUM(checkout)                           AS checkout,
    SUM(purchased)                          AS purchased,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2)            AS pct_overall_conversion,
    ROUND(SUM(revenue) / NULLIF(SUM(purchased), 0), 2)     AS avg_order_value,
    ROUND(SUM(revenue) / COUNT(*), 2)                      AS revenue_per_session
FROM session_funnel
GROUP BY device_category
ORDER BY sessions DESC;