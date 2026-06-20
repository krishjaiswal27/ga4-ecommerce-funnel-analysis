WITH funnel AS (
    SELECT
        COUNT(*)        AS sessions,
        SUM(viewed)     AS viewed,
        SUM(cart)       AS cart,
        SUM(checkout)   AS checkout,
        SUM(purchased)  AS purchased
    FROM session_funnel
)
SELECT
    sessions,
    viewed,
    cart,
    checkout,
    purchased,
    ROUND(100.0 * viewed / sessions, 2)                AS pct_session_to_view,
    ROUND(100.0 * cart / NULLIF(viewed, 0), 2)         AS pct_view_to_cart,
    ROUND(100.0 * checkout / NULLIF(cart, 0), 2)       AS pct_cart_to_checkout,
    ROUND(100.0 * purchased / NULLIF(checkout, 0), 2)  AS pct_checkout_to_purchase,
    ROUND(100.0 * purchased / sessions, 2)             AS pct_overall_conversion
FROM funnel;
