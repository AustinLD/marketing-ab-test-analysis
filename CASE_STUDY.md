# Did the Ads Actually Work? A Marketing A/B Test

## Problem

A company spent real money showing display ads, and wanted one question answered before spending more: did the ads cause people to convert, or would those customers have bought anyway? To find out, the marketing team ran a controlled experiment. Most users saw the real ad, and a small control group saw a public service announcement in the same slot. If the ad group converts at a higher rate than the control, the campaign earned its budget. If not, the spend is hard to defend.

The dataset is 588,101 users, one row each, with the group they were in, whether they converted, how many ads they saw, and when. The job was to measure the lift, prove it was real and not noise, and be honest about what the data can and cannot establish.

## Approach

I started with the data quality, because a significance test means nothing on a dirty table. There were no missing values, no duplicate users, and a clean conversion flag, so the comparison was trustworthy from the start.

The design is deliberately lopsided: 96% of users saw the ad and only 4% saw the control. I called that out early, because the small control group is what limits how precise the result can be.

For the headline, I compared conversion rates between the two groups and tested the gap two ways: a two-proportion z-test and a chi-square test of independence. Then I went past the p-value to the size of the effect, putting a 95% confidence interval on the lift and confirming it with a 10,000-sample bootstrap. Finally I looked inside the ad group at how conversion changed with the number of ads seen, and by day of week, to find where the campaign worked hardest.

## Insights

**The ad worked, clearly.** The ad group converted at 2.55% versus 1.79% for the control. That is a 0.77 percentage point gain and a 43% relative lift. Both tests put the result far beyond chance, with a z-statistic of 7.4 and a p-value near 0.0000000000002.

**The lift is precise enough to act on.** The 95% confidence interval runs from about 0.60 to 0.94 percentage points, and across 10,000 bootstrap resamples not one landed at or below zero. Even the cautious end of that range is a real relative gain over the control.

**The "more ads, more conversion" pattern is a trap.** Inside the ad group, conversion climbs from 0.16% for people who saw one ad to 17% for those who saw more than a hundred, and converters averaged 84 ads against 23 for everyone else. That looks like proof that volume drives sales, but ad exposure was never randomized. People who were already interested browse more and therefore see more ads, so heavy exposure is partly a symptom of an engaged user, not only a cause of conversion. The clean randomized evidence is the ad-versus-control gap, and that is the number I would stand behind.

**Timing matters.** Conversion was strongest for users whose ads landed early in the week. Monday reached 3.32% while Thursday sat at 2.16%, a spread of more than a full point.

## Business Impact

The recommendation is to keep running the ad. The lift is real, statistically clear, and beats the control by 43%, so the campaign is doing its job.

Two cautions come with that. First, do not pour budget into raw ad frequency on the strength of the exposure curve. That relationship is confounded by who chooses to engage, and the only honest way to size the effect of more impressions is a separate randomized test on frequency. Second, lean delivery toward early in the week, where conversion is consistently highest.

One note on the experiment itself: the control group was only 4% of users. It was large enough to catch an effect this size cleanly, but a smaller true lift could have slipped through. A more balanced split would buy more precision for the next test, at the cost of a slightly larger holdout.

The point of this project was to show the full arc of an experiment: clean the data, state a hypothesis, test it properly, size the effect, and separate what the design proves from what it only suggests.
