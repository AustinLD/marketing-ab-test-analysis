-- =====================================================================
-- 04_segment_lift.sql
-- The proper apples-to-apples comparison, segment by segment: ad vs psa
-- conversion within each day of week, and the lift between them, ranked.
-- This is the randomized comparison (treatment vs control), unlike the
-- exposure buckets in script 02, so these lifts are causal within segment.
-- =====================================================================
USE marketing_ab;

WITH seg AS (
    SELECT
        most_ads_day,
        AVG(CASE WHEN test_group = 'ad'  THEN converted END) AS rate_ad,
        AVG(CASE WHEN test_group = 'psa' THEN converted END) AS rate_psa,
        SUM(test_group = 'ad')                               AS n_ad,
        SUM(test_group = 'psa')                              AS n_psa
    FROM experiment
    GROUP BY most_ads_day
)
SELECT
    most_ads_day,
    n_ad,
    n_psa,
    ROUND(100 * rate_ad,  3)                          AS ad_rate_pct,
    ROUND(100 * rate_psa, 3)                          AS psa_rate_pct,
    ROUND(100 * (rate_ad - rate_psa), 3)              AS abs_lift_pp,
    ROUND(100 * (rate_ad / NULLIF(rate_psa, 0) - 1), 1) AS rel_lift_pct,
    RANK() OVER (ORDER BY (rate_ad - rate_psa) DESC)  AS lift_rank
FROM seg
ORDER BY lift_rank;

-- A stability check on the headline rate: as we accumulate users (ordered by
-- user_id as a proxy for arrival), does the running ad conversion rate settle
-- near 2.55%? Useful for spotting an early sample that is not yet trustworthy.
WITH ad_running AS (
    SELECT
        user_id,
        converted,
        ROW_NUMBER() OVER (ORDER BY user_id)                         AS seq,
        SUM(converted) OVER (ORDER BY user_id)                       AS cum_conv,
        ROUND(100 * AVG(converted) OVER (ORDER BY user_id), 3)       AS running_rate_pct
    FROM experiment
    WHERE test_group = 'ad'
)
SELECT seq, cum_conv, running_rate_pct
FROM ad_running
WHERE seq IN (1000, 10000, 50000, 100000, 250000, 500000, 564577)
ORDER BY seq;
