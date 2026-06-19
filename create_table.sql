CREATE TABLE session_funnel (
    user_pseudo_id   TEXT,
    session_id       BIGINT,
    session_date     DATE,
    device_category  TEXT,
    country          TEXT,
    traffic_source   TEXT,
    traffic_medium   TEXT,
    viewed           SMALLINT,
    cart             SMALLINT,
    checkout         SMALLINT,
    purchased        SMALLINT,
    revenue          NUMERIC(12,2)
);

SELECT COUNT(*) FROM session_funnel;