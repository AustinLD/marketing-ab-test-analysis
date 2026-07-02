-- =====================================================================
-- 02_exposure_buckets.sql
-- Inside the ad group, how conversion changes with the number of ads seen.
-- Uses CASE bins plus window functions for a running, cumulative view.
-- NOTE: total_ads was NOT randomly assigned, so this is correlational.
--       It describes who converts, it does not prove that more ads cause it.
-- =====================================================================
USE marketing_ab;

-- Conversion rate per exposure bucket, with a cumulative share of all
-- conversions as the buckets grow (SUM() OVER an ordered window).
WITH bucketed AS (
    SELECT
        CASE
            WHEN total_ads = 1               THEN '1'
            WHEN total_ads BETWEEN 2  AND 5  THEN '2-5'
            WHEN total_ads BETWEEN 6  AND 10 THEN '6-10'
            WHEN total_ads BETWEEN 11 AND 25 THEN '11-25'
            WHEN total_ads BETWEEN 26 AND 50 THEN '26-50'
            WHEN total_ads BETWEEN 51 AND 100 THEN '51-100'
            ELSE '100+'
        END AS exposure_bucket,
        -- sort key so the buckets stay in natural order
        CASE
            WHEN total_ads = 1               THEN 1
            WHEN total_ads BETWEEN 2  AND 5  THEN 2
            WHEN total_ads BETWEEN 6  AND 10 THEN 3
            WHEN total_ads BETWEEN 11 AND 25 THEN 4
            WHEN total_ads BETWEEN 26 AND 50 THEN 5
            WHEN total_ads BETWEEN 51 AND 100 THEN 6
            ELSE 7
        END AS bucket_order,
        converted
    FROM experiment
    WHERE test_group = 'ad'
),
per_bucket AS (
    SELECT
        exposure_bucket,
        bucket_order,
        COUNT(*)                        AS users,
        SUM(converted)                  AS conversions,
        ROUND(100 * AVG(converted), 3)  AS conversion_rate_pct
    FROM bucketed
    GROUP BY exposure_bucket, bucket_order
)
SELECT
    exposure_bucket,
    users,
    conversions,
    conversion_rate_pct,
    -- running totals across buckets, low exposure to high
    SUM(users)        OVER w AS cum_users,
    SUM(conversions)  OVER w AS cum_conversions,
    ROUND(100 * SUM(conversions) OVER w
              / SUM(conversions) OVER (), 1) AS cum_share_of_conversions_pct
FROM per_bucket
WINDOW w AS (ORDER BY bucket_order)
ORDER BY bucket_order;

-- Average ads seen, converters vs non-converters (the confound in one line).
SELECT
    CASE WHEN converted = 1 THEN 'converted' ELSE 'did not convert' END AS outcome,
    COUNT(*)               AS users,
    ROUND(AVG(total_ads), 1) AS avg_ads_seen
FROM experiment
WHERE test_group = 'ad'
GROUP BY converted;
