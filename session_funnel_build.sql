-- =====================================================================
-- 01_session_funnel_build.sql
-- This is the only transformation step that has to happen in BigQuery:
-- unnesting the GA4 event_params array to pull out the session id, and
-- collapsing raw events into ONE ROW PER SESSION with funnel flags.
--
-- Why session-scoped, not lifetime: a "lifetime" funnel (did this user
-- EVER view/cart/checkout/purchase, with no time bound) can merge two
-- completely unrelated visits into one fake "conversion" — e.g. a user
-- who browsed in March and bought something unrelated in June gets
-- counted as a full funnel completion. Scoping to ga_session_id fixes
-- this: each row is one visit, one honest funnel attempt.
--
-- Replace `your_project.your_dataset` with your own project + dataset
-- (create the dataset first if needed: bq mk your_dataset).
-- =====================================================================

CREATE OR REPLACE TABLE `your_project.your_dataset.session_funnel` AS

WITH base_events AS (
  SELECT
    user_pseudo_id,
    -- ga_session_id lives inside the repeated event_params array,
    -- not as a top-level column — this is the standard GA4 export
    -- pattern for pulling it out.
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_name,
    device.category AS device_category,
    geo.country AS country,
    traffic_source.source AS traffic_source,
    traffic_source.medium AS traffic_medium,
    ecommerce.purchase_revenue_in_usd AS purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  -- Optional cost control once you know the real range from 00_explore_dataset.sql:
  -- WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)

SELECT
  user_pseudo_id,
  session_id,
  MIN(event_date) AS session_date,
  -- device/country/source are constant within a session, so ANY_VALUE
  -- just picks the (single) value that's there
  ANY_VALUE(device_category) AS device_category,
  ANY_VALUE(country) AS country,
  ANY_VALUE(traffic_source) AS traffic_source,
  ANY_VALUE(traffic_medium) AS traffic_medium,
  MAX(IF(event_name = 'view_item', 1, 0)) AS viewed,
  MAX(IF(event_name = 'add_to_cart', 1, 0)) AS cart,
  MAX(IF(event_name = 'begin_checkout', 1, 0)) AS checkout,
  MAX(IF(event_name = 'purchase', 1, 0)) AS purchased,
  SUM(IF(event_name = 'purchase', purchase_revenue, 0)) AS revenue
FROM base_events
WHERE session_id IS NOT NULL   -- a handful of events can lack a session id; drop them
GROUP BY user_pseudo_id, session_id;

-- Note: every session gets a row here, including ones that never
-- touched the ecommerce funnel at all (viewed = cart = checkout =
-- purchased = 0). That's intentional — it's what makes "session"
-- the correct denominator for the top of the funnel, replacing the
-- old "Users" label from the lifetime version.

SELECT COUNT(*) AS total_sessions FROM `your_project.your_dataset.session_funnel`;
