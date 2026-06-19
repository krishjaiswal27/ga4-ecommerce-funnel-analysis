WITH overall AS (
    SELECT 100.0 * SUM(purchased) / COUNT(*) AS benchmark_rate
    FROM session_funnel
),
device_perf AS (
    SELECT
        device_category,
        COUNT(*) AS sessions,
        100.0 * SUM(purchased) / COUNT(*) AS conversion_rate
    FROM session_funnel
    GROUP BY device_category
)
SELECT
    d.device_category,
    d.sessions,
    ROUND(d.conversion_rate, 2)                                   AS conversion_rate,
    ROUND(o.benchmark_rate, 2)                                    AS benchmark_rate,
    ROUND(d.sessions * (o.benchmark_rate - d.conversion_rate) / 100.0, 0) AS est_lost_purchases
FROM device_perf d
CROSS JOIN overall o
ORDER BY est_lost_purchases DESC;