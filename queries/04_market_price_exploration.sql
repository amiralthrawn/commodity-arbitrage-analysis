SELECT *
FROM market_prices
LIMIT 10;

SELECT COUNT(*)
FROM market_prices;

SELECT DISTINCT commodity_id
FROM market_prices
ORDER BY commodity_id;

SELECT 
    commodity_id,
    AVG(price) AS average_price
FROM market_prices
GROUP BY commodity_id
ORDER BY commodity_id;

SELECT
    commodity_id,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM market_prices
GROUP BY commodity_id
ORDER BY commodity_id;

SELECT
    commodity_id,
    MIN(observation_date) AS first_date,
    MAX(observation_date) AS last_date
FROM market_prices
GROUP BY commodity_id
ORDER BY commodity_id;

SELECT
    market_prices.commodity_id,
    commodities.commodity_name,
    market_prices.observation_date,
    market_prices.price
FROM market_prices
JOIN commodities
    ON market_prices.commodity_id = commodities.commodity_id
LIMIT 10;

SELECT
    c.commodity_name,
    mp.observation_date,
    mp.price
FROM market_prices AS mp
JOIN commodities AS c
    ON mp.commodity_id = c.commodity_id
ORDER BY c.commodity_name, mp.observation_date
LIMIT 20;

SELECT
    c.commodity_name,
    mp.observation_date,
    mp.price
FROM market_prices AS mp
JOIN commodities AS c
    ON mp.commodity_id = c.commodity_id
ORDER BY mp.observation_date, c.commodity_name
LIMIT 20;

SELECT
    mp_brent.observation_date,
    mp_brent.price AS brent_price,
    mp_wti.price AS wti_price,
    mp_brent.price - mp_wti.price AS brent_wti_spread
FROM market_prices AS mp_brent
JOIN market_prices AS mp_wti
    ON mp_brent.observation_date = mp_wti.observation_date
WHERE mp_brent.commodity_id = 1
  AND mp_wti.commodity_id = 2
ORDER BY mp_brent.observation_date
LIMIT 20;

WITH daily_spread AS (
    SELECT
        mp_brent.observation_date,
        mp_brent.price AS brent_price,
        mp_wti.price AS wti_price,
        mp_brent.price - mp_wti.price AS brent_wti_spread
    FROM market_prices AS mp_brent
    JOIN market_prices AS mp_wti
        ON mp_brent.observation_date = mp_wti.observation_date
    WHERE mp_brent.commodity_id = 1
      AND mp_wti.commodity_id = 2
)

SELECT
    COUNT(*) AS observations,
    AVG(brent_wti_spread) AS average_spread,
    MIN(brent_wti_spread) AS minimum_spread,
    MAX(brent_wti_spread) AS maximum_spread
FROM daily_spread;

WITH daily_spread AS (
    SELECT
        mp_brent.observation_date,
        mp_brent.price AS brent_price,
        mp_wti.price AS wti_price,
        mp_brent.price - mp_wti.price AS brent_wti_spread
    FROM market_prices AS mp_brent
    JOIN market_prices AS mp_wti
        ON mp_brent.observation_date = mp_wti.observation_date
    WHERE mp_brent.commodity_id = 1
      AND mp_wti.commodity_id = 2
)

SELECT
    observation_date,
    brent_price,
    wti_price,
    brent_wti_spread
FROM daily_spread
ORDER BY brent_wti_spread DESC
LIMIT 10;

WITH daily_spread AS (
    SELECT
        mp_brent.observation_date,
        mp_brent.price AS brent_price,
        mp_wti.price AS wti_price,
        mp_brent.price - mp_wti.price AS brent_wti_spread
    FROM market_prices AS mp_brent
    JOIN market_prices AS mp_wti
        ON mp_brent.observation_date = mp_wti.observation_date
    WHERE mp_brent.commodity_id = 1
      AND mp_wti.commodity_id = 2
)

SELECT
    DATE_TRUNC('month', observation_date) AS month,
    COUNT(*) AS observations,
    AVG(brent_wti_spread) AS average_spread,
    MIN(brent_wti_spread) AS minimum_spread,
    MAX(brent_wti_spread) AS maximum_spread
FROM daily_spread
GROUP BY DATE_TRUNC('month', observation_date)
ORDER BY month;

WITH daily_spread AS (
    SELECT
        mp_brent.observation_date,
        mp_brent.price AS brent_price,
        mp_wti.price AS wti_price,
        mp_brent.price - mp_wti.price AS brent_wti_spread
    FROM market_prices AS mp_brent
    JOIN market_prices AS mp_wti
        ON mp_brent.observation_date = mp_wti.observation_date
    WHERE mp_brent.commodity_id = 1
      AND mp_wti.commodity_id = 2
),

monthly_spread AS (
    SELECT
        DATE_TRUNC('month', observation_date) AS month,
        AVG(brent_wti_spread) AS average_spread
    FROM daily_spread
    GROUP BY DATE_TRUNC('month', observation_date)
)

SELECT
    month,
    average_spread,
    LAG(average_spread) OVER (ORDER BY month) AS previous_month_spread,
    average_spread
        - LAG(average_spread) OVER (ORDER BY month) AS monthly_change
FROM monthly_spread
ORDER BY month;

WITH daily_spread AS (
    SELECT
        mp_brent.observation_date,
        mp_brent.price - mp_wti.price AS brent_wti_spread
    FROM market_prices AS mp_brent
    JOIN market_prices AS mp_wti
        ON mp_brent.observation_date = mp_wti.observation_date
    WHERE mp_brent.commodity_id = 1
      AND mp_wti.commodity_id = 2
)

SELECT
    DATE_TRUNC('month', observation_date) AS month,
    COUNT(*) AS observations,
    AVG(brent_wti_spread) AS average_spread,
    STDDEV(brent_wti_spread) AS spread_volatility
FROM daily_spread
GROUP BY DATE_TRUNC('month', observation_date)
ORDER BY month;

WITH daily_spread AS (
    SELECT
        mp_brent.observation_date,
        mp_brent.price - mp_wti.price AS brent_wti_spread
    FROM market_prices AS mp_brent
    JOIN market_prices AS mp_wti
        ON mp_brent.observation_date = mp_wti.observation_date
    WHERE mp_brent.commodity_id = 1
      AND mp_wti.commodity_id = 2
),

spread_changes AS (
    SELECT
        observation_date,
        brent_wti_spread,
        brent_wti_spread
            - LAG(brent_wti_spread) OVER (
                ORDER BY observation_date
            ) AS daily_change
    FROM daily_spread
)

SELECT
    DATE_TRUNC('month', observation_date) AS month,
    COUNT(daily_change) AS observations,
    AVG(daily_change) AS average_daily_change,
    STDDEV(daily_change) AS daily_volatility
FROM spread_changes
WHERE observation_date >= '2026-03-01'
  AND observation_date < '2026-07-01'
GROUP BY DATE_TRUNC('month', observation_date)
ORDER BY month;

WITH daily_spread AS (
    SELECT
        mp_brent.observation_date,
        mp_brent.price - mp_wti.price AS brent_wti_spread
    FROM market_prices AS mp_brent
    JOIN market_prices AS mp_wti
        ON mp_brent.observation_date = mp_wti.observation_date
    WHERE mp_brent.commodity_id = 1
      AND mp_wti.commodity_id = 2
)

SELECT
    observation_date,
    brent_wti_spread
FROM daily_spread
WHERE observation_date >= '2026-03-01'
  AND observation_date < '2026-07-01'
ORDER BY brent_wti_spread DESC
LIMIT 20;