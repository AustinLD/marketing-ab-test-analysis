-- =====================================================================
-- Project 3: Marketing A/B Test  |  00_setup_database.sql
-- Create the database, load the experiment file, index it.
-- Target: MySQL 8. Run this first; the other scripts assume `marketing_ab`.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS marketing_ab;
USE marketing_ab;

DROP TABLE IF EXISTS experiment;

-- One row per user. row_index is the original CSV index column, kept for traceability.
CREATE TABLE experiment (
    row_index      INT,
    user_id        INT,
    test_group     ENUM('ad','psa')  NOT NULL,
    converted      TINYINT(1)        NOT NULL,   -- 0 / 1
    total_ads      INT               NOT NULL,
    most_ads_day   VARCHAR(10)       NOT NULL,
    most_ads_hour  TINYINT           NOT NULL,
    PRIMARY KEY (user_id)
);

-- The raw file stores converted as the text True / False, so load it into a
-- staging column and cast. Adjust the path to your local data/raw/ folder.
LOAD DATA LOCAL INFILE 'marketing_AB.csv'
INTO TABLE experiment
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(row_index, user_id, test_group, @converted, total_ads, most_ads_day, most_ads_hour)
SET converted = IF(@converted = 'True', 1, 0);

-- Indexes for the group and segment aggregations used downstream.
CREATE INDEX idx_group     ON experiment (test_group);
CREATE INDEX idx_converted ON experiment (converted);
CREATE INDEX idx_totalads  ON experiment (total_ads);

-- Sanity check: expect 588,101 rows, ~96% ad / ~4% psa.
SELECT test_group,
       COUNT(*)                                              AS users,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)      AS share_pct
FROM experiment
GROUP BY test_group;
