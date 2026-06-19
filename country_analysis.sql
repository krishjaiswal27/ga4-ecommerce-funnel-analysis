SELECT
    COALESCE(country, '(unknown)') AS country,
    COUNT(*)                        AS sessions,
    SUM(purchased)                  AS purchased,
    ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS pct_overall_conversion,
    ROUND(SUM(revenue), 2)                      AS total_revenue
FROM session_funnel
GROUP BY country
ORDER BY sessions DESC
LIMIT 15;
