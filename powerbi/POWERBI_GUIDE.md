# Power BI Build Guide: Marketing A/B Test Dashboard

Step by step build for the experiment-results dashboard. The .pbix is gitignored, so commit a few screenshots for the README once it is built. Every number below is what you should actually see if the load is correct, so use them as checkpoints.

## 1. Load the data

1. Get Data, Text/CSV, select `data/raw/marketing_AB.csv`.
2. In the preview, click Transform Data to open Power Query.
3. Clean up:
   - Remove the first unnamed index column (right click, Remove).
   - Rename columns to `user_id`, `test_group`, `converted`, `total_ads`, `most_ads_day`, `most_ads_hour`.
   - Set `converted` to type True/False, `total_ads` and `most_ads_hour` to Whole Number, the rest to Text.
4. Add a numeric conversion column for measures. Add Column, Custom Column, name it `converted_flag`, formula `if [converted] = true then 1 else 0`. Set it to Whole Number.
5. Close and Apply. You should land on 588,101 rows.

## 2. Helper table for day ordering

Day of week sorts alphabetically by default, which reads badly. Fix it once:

1. New Table:
   ```
   DayOrder =
   DATATABLE(
       "most_ads_day", STRING, "day_num", INTEGER,
       {
           {"Monday",1},{"Tuesday",2},{"Wednesday",3},{"Thursday",4},
           {"Friday",5},{"Saturday",6},{"Sunday",7}
       }
   )
   ```
2. Relate `DayOrder[most_ads_day]` to `experiment[most_ads_day]` (many to one).
3. Select `most_ads_day` in the experiment table, Column tools, Sort by Column, choose `day_num` (you can also sort the DayOrder column by day_num and use that field on visuals).

## 3. Core DAX measures

Create these in the experiment table. Expected values are noted so you can verify as you go.

```DAX
Total Users = COUNTROWS(experiment)                       -- 588,101

Conversions = SUM(experiment[converted_flag])             -- 14,843 overall

Conversion Rate = DIVIDE([Conversions], [Total Users])    -- 2.52% overall

Ad Rate =
CALCULATE([Conversion Rate], experiment[test_group] = "ad")    -- 2.55%

PSA Rate =
CALCULATE([Conversion Rate], experiment[test_group] = "psa")   -- 1.79%

Abs Lift (pp) = ([Ad Rate] - [PSA Rate]) * 100            -- 0.77

Rel Lift % = DIVIDE([Ad Rate] - [PSA Rate], [PSA Rate])   -- 43.1% (format as %)
```

Significance, computed inline so the dashboard states it instead of you asserting it:

```DAX
Z Statistic =
VAR n_ad  = CALCULATE([Total Users], experiment[test_group] = "ad")
VAR n_psa = CALCULATE([Total Users], experiment[test_group] = "psa")
VAR x_ad  = CALCULATE([Conversions], experiment[test_group] = "ad")
VAR x_psa = CALCULATE([Conversions], experiment[test_group] = "psa")
VAR p_ad  = DIVIDE(x_ad, n_ad)
VAR p_psa = DIVIDE(x_psa, n_psa)
VAR p_pool = DIVIDE(x_ad + x_psa, n_ad + n_psa)
VAR se = SQRT(p_pool * (1 - p_pool) * (1/n_ad + 1/n_psa))
RETURN DIVIDE(p_ad - p_psa, se)                           -- ~7.37
```

```DAX
Significance Flag =
IF(ABS([Z Statistic]) > 1.96,
   "Significant at 95% (p < 0.001)",
   "Not significant")
```

## 4. Page layout

Four pages. Keep a consistent header band with the title and a `test_group` slicer where it helps.

### Page 1: Results

The page a hiring manager reads in 10 seconds.

- KPI cards: `Ad Rate` (2.55%), `PSA Rate` (1.79%), `Abs Lift (pp)` (0.77), `Rel Lift %` (43.1%).
- A card or text box bound to `Significance Flag` so the verdict is on the page in words.
- A clustered column chart: axis = `test_group`, value = `Conversion Rate`, with data labels. Add error bars if you want to show the confidence interval.
- A short text box stating the finding: the ad lifted conversion by 0.77 points, a 43% relative gain, significant well below p = 0.05.

### Page 2: Exposure

- Column chart: axis = a `total_ads` bucket, value = `Conversion Rate`, ad group only. Build the bucket as a calculated column:
  ```DAX
  Exposure Bucket =
  SWITCH(TRUE(),
      experiment[total_ads] = 1, "1",
      experiment[total_ads] <= 5, "2-5",
      experiment[total_ads] <= 10, "6-10",
      experiment[total_ads] <= 25, "11-25",
      experiment[total_ads] <= 50, "26-50",
      experiment[total_ads] <= 100, "51-100",
      "100+")
  ```
  Sort it with a matching order column. Conversion should climb from about 0.16% to 17%.
- A prominent caption: exposure was not randomized, so this is correlational, not proof that more ads cause conversions.

### Page 3: Timing

- Column chart: axis = `most_ads_day` (sorted Mon to Sun), value = `Conversion Rate`, ad group. Monday should top out near 3.32%.
- Column or line chart: axis = `most_ads_hour`, value = `Conversion Rate`. Mid-afternoon (15 to 16) and evening (20) read highest; the small hours (1 to 3) read lowest.

### Page 4: Segments

- Matrix: rows = `most_ads_day`, values = `Ad Rate`, `PSA Rate`, `Abs Lift (pp)`. This is the true treatment-vs-control view by segment. Conditional-format the lift column.
- Note that the per-day lift ranking is not the same as the raw ad-rate ranking, because the control rate moves too. Tuesday shows the largest lift even though Monday has the highest ad rate.

## 5. Theme and finish

- One accent color for the ad group, a muted grey or orange for the control, used consistently.
- Round rates to two decimals, lift to two, relative lift to one.
- Title the report "Did the Ads Work? A/B Test Results."
- Save as `powerbi/marketing_ab_test.pbix`. Export 2 or 3 screenshots (the Results page especially) into `powerbi/` and link them from the README.

## Verification checklist

- Total Users = 588,101
- Ad Rate 2.55%, PSA Rate 1.79%, Abs Lift 0.77 pp, Rel Lift 43.1%
- Z Statistic ~7.37, Significance Flag shows significant
- Exposure chart climbs 0.16% to 17%
- Monday is the best day at ~3.32%
