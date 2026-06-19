-- =====================================================================
-- 02_validation_checks.sql
-- Run these before trusting anything downstream. Each one should
-- return 0 or a very small number — if not, something upstream
-- (usually the session scoping) needs a closer look.
-- =====================================================================

-- 1. Sessions that reached checkout without ever adding to cart.
--    In a normal GA4 flow this should be rare/zero. A large number
--    here usually means session_id extraction is off, or events are
--    still leaking across separate visits.
SELECT COUNT(*) AS checkout_without_cart
FROM `your_project.your_dataset.session_funnel`
WHERE checkout = 1 AND cart = 0;

-- 2. Same idea one stage further down.
SELECT COUNT(*) AS purchase_without_checkout
FROM `your_project.your_dataset.session_funnel`
WHERE purchased = 1 AND checkout = 0;

-- 3. How many sessions have missing dimensions? You'll want an
--    "(unknown)" bucket downstream rather than silently dropping rows.
SELECT
  COUNTIF(device_category IS NULL) AS null_device,
  COUNTIF(country IS NULL) AS null_country,
  COUNTIF(traffic_source IS NULL) AS null_source
FROM `your_project.your_dataset.session_funnel`;

-- 4. Overall funnel preview — eyeball this before exporting anything.
SELECT
  COUNT(*) AS sessions,
  SUM(viewed) AS viewed,
  SUM(cart) AS cart,
  SUM(checkout) AS checkout,
  SUM(purchased) AS purchased,
  ROUND(100.0 * SUM(viewed) / COUNT(*), 2) AS pct_session_to_view,
  ROUND(100.0 * SUM(purchased) / COUNT(*), 2) AS pct_overall_conversion
FROM `your_project.your_dataset.session_funnel`;
