SELECT
    DATE_TRUNC('week', session_date) AS week_start,
    COUNT(*) AS sessions,
    SUM(purchased) AS purchases,
    SUM(revenue) AS revenue,
    ROUND(
        100.0 * SUM(purchased) / COUNT(*),
        2
    ) AS conversion_rate
FROM session_funnel
GROUP BY 1
ORDER BY 1;