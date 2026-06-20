

CREATE OR REPLACE TABLE `project-6a2c2022-16f7-4eef-852.your_dataset.session_funnel` AS

WITH base_events AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_name,
    device.category AS device_category,
    geo.country AS country,
    traffic_source.source AS traffic_source,
    traffic_source.medium AS traffic_medium,
    ecommerce.purchase_revenue_in_usd AS purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)

SELECT
  user_pseudo_id,
  session_id,
  MIN(event_date) AS session_date,
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
WHERE session_id IS NOT NULL   
GROUP BY user_pseudo_id, session_id;


SELECT COUNT(*) AS total_sessions FROM `project-6a2c2022-16f7-4eef-852.your_dataset.session_funnel`;
