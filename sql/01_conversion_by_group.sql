-- =====================================================================
-- 01_conversion_by_group.sql
-- The headline result: conversion rate per group, plus the absolute and
-- relative lift of the ad (treatment) over the psa (control).
-- =====================================================================
USE marketing_ab;

-- Conversion rate by group.
SELECT
    test_group,
    COUNT(*)                                   AS users,
    SUM(converted)                             AS conversions,
    ROUND(100 * AVG(converted), 3)             AS conversion_rate_pct
FROM experiment
GROUP BY test_group;

-- Lift: pivot the two group rates into one row, then compute the gap.
-- AVG(converted) returns a decimal in MySQL, so the ratios are exact.
WITH rates AS (
    SELECT
        AVG(CASE WHEN test_group = 'ad'  THEN converted END) AS rate_ad,
        AVG(CASE WHEN test_group = 'psa' THEN converted END) AS rate_psa,
        SUM(CASE WHEN test_group = 'ad'  THEN converted END) AS conv_ad,
        SUM(CASE WHEN test_group = 'psa' THEN converted END) AS conv_psa,
        SUM(test_group = 'ad')                               AS n_ad,
        SUM(test_group = 'psa')                              AS n_psa
    FROM experiment
)
SELECT
    ROUND(100 * rate_ad,  3)                       AS ad_rate_pct,
    ROUND(100 * rate_psa, 3)                       AS psa_rate_pct,
    ROUND(100 * (rate_ad - rate_psa), 3)           AS abs_lift_pp,      -- expect ~0.769
    ROUND(100 * (rate_ad / rate_psa - 1), 1)       AS rel_lift_pct,     -- expect ~43.1
    -- Pooled two-proportion z-statistic, computed inline.
    ROUND(
        (rate_ad - rate_psa) /
        SQRT(
            ((conv_ad + conv_psa) / (n_ad + n_psa)) *
            (1 - (conv_ad + conv_psa) / (n_ad + n_psa)) *
            (1.0 / n_ad + 1.0 / n_psa)
        ), 3)                                       AS z_statistic       -- expect ~7.37
FROM rates;
