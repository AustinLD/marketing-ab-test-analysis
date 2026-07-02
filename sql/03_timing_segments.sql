-- =====================================================================
-- 03_timing_segments.sql
-- When did the ad land best? Conversion by day of week and by hour,
-- ranked so the strongest and weakest windows surface immediately.
-- =====================================================================
USE marketing_ab;

-- Conversion by day of week (ad group), ranked best to worst.
WITH by_day AS (
    SELECT
        most_ads_day,
        COUNT(*)                        AS users,
        ROUND(100 * AVG(converted), 3)  AS conversion_rate_pct
    FROM experiment
    WHERE test_group = 'ad'
    GROUP BY most_ads_day
)
SELECT
    most_ads_day,
    users,
    conversion_rate_pct,
    RANK() OVER (ORDER BY conversion_rate_pct DESC) AS rate_rank
FROM by_day
ORDER BY rate_rank;

-- Conversion by hour (ad group). NTILE splits the 24 hours into quartiles
-- of performance so the best block of hours is easy to read off.
WITH by_hour AS (
    SELECT
        most_ads_hour,
        COUNT(*)                        AS users,
        ROUND(100 * AVG(converted), 3)  AS conversion_rate_pct
    FROM experiment
    WHERE test_group = 'ad'
    GROUP BY most_ads_hour
)
SELECT
    most_ads_hour,
    users,
    conversion_rate_pct,
    NTILE(4) OVER (ORDER BY conversion_rate_pct DESC) AS performance_quartile
FROM by_hour
ORDER BY conversion_rate_pct DESC;
