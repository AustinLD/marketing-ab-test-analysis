# Project 3: Did the Ads Actually Work? A Marketing A/B Test

## Problem Statement

A company ran a marketing campaign and wants to know one thing before they spend more: did the ads actually cause people to convert, or would those customers have bought anyway? To find out, most users were shown the real ad and a smaller control group saw a public service announcement in the same slot. If the ad group converts at a meaningfully higher rate than the control, the campaign worked. If not, the spend is hard to justify.

This project treats that campaign as a controlled experiment and answers three questions:

1. Did the ad group convert at a higher rate than the control group, and is the difference statistically significant or just noise?
2. How large is the lift, what is the confidence interval around it, and what does that mean in real conversions and revenue?
3. Inside the ad group, conversion rises sharply with the number of ads a person saw. Is that the ad working, or are already-engaged users simply being shown more ads? This is the confounding question that decides how much to trust the headline result.

The point is to show experimentation and statistical thinking: state a hypothesis, test it properly, quantify the uncertainty, and be honest about what the design can and cannot prove.

## Dataset

**Marketing A/B Testing (ad vs. PSA)**

- Source: [kaggle.com/datasets/faviovaz/marketing-ab-testing](https://www.kaggle.com/datasets/faviovaz/marketing-ab-testing)
- Size: 588,101 rows, one per user
- Columns: user_id, test_group (ad or psa), converted (True/False), total_ads, most_ads_day, most_ads_hour

This is a real marketing experiment. The ad group is the treatment (saw the real advertisement) and the psa group is the control (saw a public service announcement of the same size, in the same place). The design is deliberately imbalanced: roughly 96% of users are in the ad group and 4% in the control. That imbalance is real and worth analyzing, because it affects how much statistical power the control group gives us.

Findings are for skill demonstration, not a real campaign decision.

## Tools & Stack

| Layer | Tool | Purpose |
| :---- | :---- | :---- |
| Data prep | Python (Pandas) | Load 588K rows, validate, check group balance and data quality |
| SQL analysis | SQL (CTEs, window functions) | Conversion rates by group, exposure buckets, cumulative conversion curves, segment lift |
| Statistics | Python (Pandas, NumPy) | Two-proportion z-test, chi-square, confidence intervals, bootstrap, power check, computed directly from the formulas |
| Visualization | Power BI | Experiment results dashboard: lift, significance, conversion by segment |
| Version control | GitHub | Code, SQL scripts, README, case study |

## Deliverables

### 1. SQL Analysis Scripts

Well-commented queries that frame the experiment in SQL, including:

- Conversion rate and user counts per test group, the absolute and relative lift between them
- Conversion rate by `total_ads` exposure bucket, using CASE bins and window functions for cumulative conversion across buckets
- Conversion rate by day of week and hour, to see when ads landed best
- Segment lift: a CTE that computes ad-vs-control conversion within each day or hour segment, then ranks where the ad helped most
- A running, cumulative conversion view using SUM() OVER to show how the rate stabilizes as the sample grows

### 2. Python Notebook

- Load and validate the 588K-row file, confirm group sizes, check for duplicate users and nulls
- Headline result: conversion rate by group, absolute lift, relative lift
- Significance test: two-proportion z-test and chi-square test of independence, with the p-value stated plainly
- Confidence interval on the lift, plus a bootstrap of the difference in conversion rates to show the same answer a second way
- The confounding check: conversion vs. number of ads seen, and a short, honest discussion of why exposure is not randomly assigned
- A quick power/sample-size note on what the 96/4 split means for the control group

### 3. Power BI Dashboard

- **Results:** conversion rate for ad vs. control, absolute and relative lift, p-value and a clear significant / not-significant flag, as KPI cards
- **By exposure:** conversion rate by number of ads seen, with the confounding caveat called out
- **By timing:** conversion by day of week and hour, highlighting the best windows
- **Segments:** where the ad lifted conversion most, ranked

### 4. Case Study Write-Up

A short document (500-800 words): Problem, Approach, Insights, Business Impact. Hosted as the GitHub README. Written for a hiring manager with 90 seconds, leading with the decision the result supports.

## Key Skills Demonstrated

- Experimentation: framing a campaign as a controlled test, stating a hypothesis, reading significance correctly
- Statistics: two-proportion z-test, chi-square, confidence intervals, bootstrap, basic power reasoning
- Critical thinking: spotting the exposure confound and being honest about what a non-randomized variable can prove
- SQL: CTEs and window functions on a conversion dataset (cumulative rates, segment lift, exposure buckets)
- Python: validation, statistical testing, clear result visuals
- Storytelling: a decision-framed write-up, not a methods dump

## GitHub Structure (planned)

```
marketing-ab-test-analysis/
├── data/               # Raw CSV gitignored if large; committed slim copy otherwise
├── sql/                # SQL scripts, named by analysis
├── notebooks/          # Jupyter notebook for prep, testing, and EDA
├── powerbi/            # .pbix file
└── README.md           # Case study write-up
```

## Status

Active. Week 1: download the dataset, validate it in Python, confirm group balance, and run the headline conversion-rate test.
