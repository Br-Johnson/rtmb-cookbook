---
title: "Capstone: A Model Report for a New Stock"
teaching: 10
exercises: 80
---

:::::::::::::::::::::::::::::::::::::::: questions

- Can I take a new stock from data to a checked, compared and tested forecast on my own?
- Do model selection (AIC) and model evaluation (residuals, simulation, hindcast) agree?

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: objectives

- Complete rows 1-10 of the report card for a new stock using the lesson's recipes.
- Justify a model choice with evidence from residuals, simulation, AIC and forecast skill.
- Compare conclusions across stocks with other pairs.

::::::::::::::::::::::::::::::::::::::::::::::::::



## Starting Point

This episode runs all nine steps of the [Quick Start](02-quick-start.Rmd) again, on a stock you have not seen, with the recipes from every episode.

:::::::::::::::::::::::::::::::::::::::: prereq

### Run This If You Are Starting Here

Download [the capstone template (capstone-template.R)](files/capstone-template.R) into your project's `files/` folder and open it.
It loads everything it needs, including `files/cookbook.R`.
Run it from your project folder, which must also hold `data/sockeye.csv`, `data/npgo.csv` and `files/cookbook.R` (see [Setup](../learners/setup.md)).

::::::::::::::::::::::::::::::::::::::::::::::::::

## The Task

In pairs, choose a stock you have not seen in class and complete rows 1 to 10 of the report card with the template.
This is your third pass over the workflow: the instructor showed it on Stellako, you repeated it on Upper Pitt River, and now you run it on your own.

Choose one of these stocks, or use your own data:

- **Quesnel**: one of the largest Fraser River sockeye stocks, with a strong four-year cycle in spawner numbers; 25 of its 74 brood years had fewer than 1 thousand spawners.
- **Late Stuart**: cyclic too; its data start in 1949, and 9 brood years had fewer than 1 thousand spawners.
- **Chilko**: the largest stock on this menu, with at least 6.6 thousand spawners in every year.
- **Harrison**: the only stock with data for brood year 2022.
- **Birkenhead**: its fewest spawners on record were in 2019 and 2020 (2.0 and 1.6 thousand).
- **Your own data**: one population with parents and offspring counted in each year (the section [Your Own Data](#your-own-data) says how).

Where you can, pair up with someone whose experience differs from yours: a confident R user with someone who knows the field.

:::::::::::::::::::::::::::::::::::::::: caution

### Years with Very Few Spawners

In some brood years of Quesnel, Late Stuart and Harrison, fewer than 1 thousand fish spawned: as few as 9 fish in Quesnel's 1951.
Birkenhead's last few brood years are low for that stock (2.0 and 1.6 thousand in 2019 and 2020).
Recruits per spawner in such years can be extreme, and these years can pull estimates and forecasts.
Every fit on the menu passes the four checks, but before you trust a result, look at those years (`arrange(my_stock, spawners)` lists them first).
Say in your report when an estimate, such as S_max, lies beyond the spawner counts in the data.

::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

The capstone takes 90 minutes: 10 minutes to present the menu, the template and the rubric, 60 minutes of pair work, and 20 minutes of share-out.
Form the pairs before you present the template, mixing profiles where you can (an R-confident learner with a domain-confident one).
Ask for sticky notes at three checkpoints: after C2 (all checks TRUE), after C7 (the AIC table) and after C8 (the hindcast scores).
If pairs fall behind, make rows 5 and 6 optional; never cut rows 2, 3, 7, 8 and 9.
If Episode 10 was cut, give the capstone 30 of the 45 minutes saved.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

## The Template

The template is the whole workflow on one page.
It loads the packages, the data and the finished recipe box, so every function from the lesson is ready to use.
Its sections C1 to C11 fill rows 1 to 11 of the report card, in the order of the episodes.
It fits four candidate models (`ricker`, `bh`, `walk` and `ricker_npgo`) and keeps them in one named list, `models`.

The blanks (`___`) are where you decide something:

- the stock name (C1);
- the starting values for the Beverton-Holt model (C2);
- the name of the random effects in `random =` (C2);
- which part of a fitted model holds the four checks (C2);
- the function that makes the table of estimates with 95% intervals (C3);
- which part of the summary holds the yearly productivity values (C4);
- the function for one-step-ahead residuals (C5);
- the statistic to simulate (C6);
- the model to self-test (C6);
- the function that makes the AIC table (C7);
- the benchmark (C8);
- the model to forecast from (C9).

Replace a blank, run its section, and write the report-card row before you move on.
The whole template runs in a few seconds.


``` r
## Capstone: a model report card for a new stock (or your own data).
## Fill in every ___ . Each section is one row of the report card.
## Run from your project folder (it needs data/ and files/).

library(RTMB)
library(dplyr)
library(ggplot2)
source("files/cookbook.R")
sockeye <- read.csv("data/sockeye.csv")
npgo    <- read.csv("data/npgo.csv")

## C1 Data (row 1) --------------------------------------------------------------
## Your own data? Make a data frame with columns brood_year, spawners, recruits
## (one row per year, in time order, no missing values) and use it as my_stock.
my_stock <- filter(sockeye, stock == "___")
range(my_stock$brood_year); nrow(my_stock); range(my_stock$spawners)
S_new <- mean(tail(my_stock$spawners, 4))           # spawners for the forecast
dat   <- make_dat(my_stock, S_new = S_new)
npgo_by_brood <- npgo %>% mutate(brood_year = year - 2) %>% select(brood_year, npgo)
my_stock <- left_join(my_stock, npgo_by_brood, by = "brood_year")
dat$npgo     <- my_stock$npgo
dat$npgo_new <- npgo$npgo[npgo$year == max(my_stock$brood_year) + 3]

## C2 Fit every candidate and check it (row 2) -----------------------------------
models <- list(
  ricker      = fit_model(nll_ricker, start_ricker(dat), dat),
  bh          = fit_model(nll_bh, ___(dat), dat),
  walk        = fit_model(nll_walk, start_walk(dat), dat, random = "___"),
  ricker_npgo = fit_model(nll_ricker_npgo, c(start_ricker(dat), list(b_npgo = 0)), dat))
sapply(models, function(m) m$___)                   # four TRUE in every column?

## C3 Estimates with 95% intervals (row 3) ----------------------------------------
___(models$ricker)
ci_table(models$bh)

## C4 The random effect (row 4) -----------------------------------------------------
ci_table(models$walk)                               # is sd_walk near zero? (Episode 6)
prod <- ci_table(models$walk, "___")
prod$brood_year <- min(my_stock$brood_year) + seq_len(nrow(prod)) - 1
ggplot(prod, aes(x = brood_year, y = estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "grey80") +
  geom_line() +
  labs(x = "Brood year", y = "Productivity (recruits per spawner)")

## C5 Residuals (row 5) ---------------------------------------------------------------
my_stock$res_ricker <- osa_residuals(models$ricker)
my_stock$res_walk   <- ___(models$walk)
c(ricker = lag1(my_stock$res_ricker), walk = lag1(my_stock$res_walk),
  limit = 2 / sqrt(nrow(my_stock)))
ggplot(my_stock, aes(sample = res_ricker)) + stat_qq() + stat_qq_line()
ggplot(my_stock, aes(x = brood_year, y = res_ricker)) +
  geom_hline(yintercept = 0, linetype = "dashed") + geom_point()

## C6 Simulation (row 6) ---------------------------------------------------------------
set.seed(2026)
c(ricker = mean(simulate_stat(models$ricker, lag1) >= lag1(dat$logRS)),
  walk   = mean(simulate_stat(models$walk, ___) >= lag1(dat$logRS)))
set.seed(2026)
st <- self_test(models$___, n_sim = 30)            # the model you expect to choose
st %>% group_by(parameter) %>%
  summarise(truth = first(truth), median_estimate = median(estimate), fits_ok = sum(fit_ok))

## C7 Compare with AIC (row 7) ------------------------------------------------------------
___(models)

## C8 Test forecasts on past years (row 8) --------------------------------------------------
hc <- bind_rows(ricker = hindcast(models$ricker, my_stock, first_year = 2007),
                bh     = hindcast(models$bh,     my_stock, first_year = 2007),
                walk   = hindcast(models$walk,   my_stock, first_year = 2007),
                naive  = ___(my_stock, first_year = 2007),
                .id = "model")
all(hc$fit_ok)
score_forecasts(hc)

## C9 Forecast from the model you chose (row 9) -----------------------------------------------
predict_recruits(models$___)

## C10 Conclusion (row 10): write three sentences ---------------------------------------------
## Which model? Why (rows 5 to 8)? What is the main caveat?

## C11 Stretch (row 11): write nll_bh_walk (Beverton-Holt curve + random-walk productivity),
## fit it, check it, and add it to the AIC table (C7) and the hindcast (C8).
```

## Your Own Data

The template works for any population counted as parents and offspring in each year.
Make a data frame with one row per year, in time order, with columns `brood_year`, `spawners` and `recruits` (any units, but say which), and no missing values.
Use it as `my_stock` in C1, in place of the `filter()` line.
If your file has other column names, rename them as you read it:


``` r
my_stock <- read.csv("data/my-data.csv") %>%
  rename(brood_year = year, spawners = adults, recruits = offspring) %>%
  arrange(brood_year)
```

Here `year`, `adults` and `offspring` stand for the names in your file, and `arrange()` puts the rows in time order.
Then make three more changes:

- Delete the NPGO lines, or replace NPGO with a covariate you chose in advance.
  To delete them, remove the last four lines of C1 and the `ricker_npgo` line of C2, and end the `walk` line with `))` instead of `),`.
- In C8, change `first_year = 2007` in all four lines so that about the last 15 years are forecast, for example `first_year = max(my_stock$brood_year) - 14`.
- For counts or other kinds of data, change the score line in each model ([Episode 3](03-likelihoods.Rmd), In Your Field).
  The helpers written for log(recruits per spawner) then need changes too: `make_dat()`, `predict_recruits()`, and `osa_residuals()`, whose method assumes a normal score line.

## The Report Card

Your report card has the same eleven rows as the Stellako card in [the Introduction](01-introduction.Rmd).
A row is done when it has everything in this list.

:::::::::::::::::::::::::::::::::::::::: checklist

### Rubric: The Model Report Card

1. **Data** ([Episode 1](01-introduction.Rmd), [Episode 3](03-likelihoods.Rmd)): the stock; the first and last brood year; the number of years; the spawner range with units; `S_new`, the average spawners of the last four brood years.
2. **Fits usable** ([Episode 4](04-fit-and-check.Rmd)): `$checks` shown for every model; any FALSE explained and fixed.
3. **Estimates** ([Episode 5](05-uncertainty.Rmd)): alpha and S_max (S_half for Beverton-Holt) with 95% confidence intervals, on the natural scale, with units.
4. **Random effect** ([Episode 6](06-random-effects.Rmd)): sd_walk in words; productivity in the first year, at its peak and in the last year; an SD near zero recognised and interpreted, and its interval not reported.
5. **Residuals** ([Episode 7](07-residuals.Rmd)): for each model, the lag-1 correlation against the limit 2/sqrt(n), the QQ verdict, and any pattern over time.
6. **Simulation** ([Episode 8](08-simulation.Rmd)): the share of simulations with a lag-1 correlation at least as large as the data's; a self-test of the chosen model (medians against the truth, refits that pass, SDs collapsing to zero).
7. **Comparison** ([Episode 9](09-model-selection.Rmd)): an AIC table on identical rows; a choice using the four rules; one sentence on what AIC cannot tell you.
8. **Forecast skill** ([Episode 11](11-forecasting.Rmd)): a hindcast from 2007 (bias, MAE, skill against the benchmark, 80% coverage) for each candidate and the benchmark; one sentence.
9. **Forecast** ([Episode 11](11-forecasting.Rmd)): the median recruits for `S_new` with an 80% prediction interval from the chosen model, with units and the word "median".
10. **Conclusion**: three sentences: which model, why (rows 5 to 8), and the main caveat.
11. **Stretch** (optional): a new model that combines two ideas, fitted, checked, and added to rows 7 and 8.

::::::::::::::::::::::::::::::::::::::::::::::::::

Helpers use the same list to give feedback.
Nothing is graded.

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 1: Complete the Report Card (60 minutes)

In pairs, fill in every blank in the template, run it section by section, and complete rows 1 to 10 in your report card.
Use the [Recipe Index](../learners/recipe-index.md) when you are unsure which recipe to use.

:::::::::::::::::::::::: hint

- The order of the template is the order of the episodes.
- If a check fails, work through [Troubleshooting](../learners/troubleshooting.md).
- If an SD is near zero, go back to "Check an SD Near Zero" in [Episode 6](06-random-effects.Rmd).
- For row 6, count the sd_walk estimates that collapsed to zero, as in [Episode 8](08-simulation.Rmd).
- Write each row as soon as its section runs.

:::::::::::::::::::::::::

:::::::::::::::::::::::: solution

Here is the template filled in for Late Stuart.
The blanks, in the order they appear, are `"Late Stuart"`, `start_bh`, `"log_alpha_year"`, `checks`, `ci_table`, `"random"`, `osa_residuals`, `lag1`, `walk`, `aic_table`, `naive_forecast` and `walk`.
These are the filled lines, with one line added in C6 to count the sd_walk estimates near zero:


``` r
## C1
my_stock <- filter(sockeye, stock == "Late Stuart")
## C2
  bh          = fit_model(nll_bh, start_bh(dat), dat),
  walk        = fit_model(nll_walk, start_walk(dat), dat, random = "log_alpha_year"),
sapply(models, function(m) m$checks)                   # four TRUE in every column?
## C3
ci_table(models$ricker)
## C4
prod <- ci_table(models$walk, "random")
## C5
my_stock$res_walk   <- osa_residuals(models$walk)
## C6
  walk   = mean(simulate_stat(models$walk, lag1) >= lag1(dat$logRS)))
st <- self_test(models$walk, n_sim = 30)            # the model you expect to choose
st %>% filter(parameter == "log_sd_walk") %>% summarise(near_zero = sum(exp(estimate) < 0.01))  # added
## C7
aic_table(models)
## C8
                naive  = naive_forecast(my_stock, first_year = 2007),
## C9
predict_recruits(models$walk)
```

If your template is filled correctly, C7, C8 and C9 print these tables for Late Stuart:

```output
        model k      AIC checks_ok     dAIC
3        walk 4 242.7625      TRUE 0.000000
2          bh 3 246.6309      TRUE 3.868404
1      ricker 3 249.7623      TRUE 6.999759
4 ricker_npgo 4 251.7357      TRUE 8.973199

# A tibble: 4 × 6
  model      n   bias   MAE coverage80 skill
  <chr>  <int>  <dbl> <dbl>      <dbl> <dbl>
1 bh        15  0.744 1.04       0.8    1.61
2 naive     15 -0.208 0.644      0.933  1
3 ricker    15  0.743 1.00       0.867  1.55
4 walk      15 -0.192 0.685      0.933  1.06

     S_new   median    lower    upper
1 65.98475 490.7406 99.56392 2418.812
```

The report card for Late Stuart:

- Row 1: "Late Stuart, brood years 1949-2021, 73 years, spawners 0.016 to 1184 thousand (9 years under 1 thousand); `S_new` is 66 thousand spawners, the average of 2018-2021."
- Row 2: "Ricker, Beverton-Holt, random walk and Ricker + NPGO: all four checks TRUE."
- Row 3: "Ricker: when spawners are few, each spawner produces about 10 recruits (95% CI 7.4 to 14). Recruitment peaks at about 530 thousand spawners (95% CI 190 to 1440 thousand), a count exceeded in only one year of the data. Beverton-Holt: alpha 12.7 recruits per spawner (8.2 to 19.7), S_half 104 thousand spawners (26 to 415)."
- Row 4: "sd_walk is 0.28 (95% CI 0.11 to 0.71): productivity typically changes by about 30% from year to year. It was 34 recruits per spawner in 1949, at its peak of 34.3 in 1951, fell to about 9 by 1960, rose to 22 in 1987, fell to about 4 in the 2000s, and was 8.3 in 2021."
- Row 5: "Ricker: neighbouring years are alike (lag-1 correlation 0.28, above the limit of 0.23); its residuals are mostly above zero before 1990 (average +0.40) and below zero from 2000 (average -0.59); its QQ plot follows the line. Random walk: lag-1 correlation -0.02, residuals scattered around zero over time, QQ plot close to the line. No residual is beyond ±3 (the most extreme, 1979, is -2.5 for the Ricker and -2.7 for the random walk)."
- Row 6: "Simulated data as alike from year to year as the real data (lag-1 correlation of log(R/S) 0.28): Ricker 0 of 200 simulations, random walk 65%. Self-test of the random walk: 30 of 30 refits pass, the medians are close to the true values (log_alpha 3.42 against 3.53), and sd_walk collapses to zero in 2 of 30."
- Row 7: "The random walk has the lowest AIC: 3.9 below Beverton-Holt, 7.0 below the Ricker and 9.0 below Ricker + NPGO. The gap to Beverton-Holt is between 2 and 10, so we favour the random walk and check residuals and forecasts (rule 3). AIC cannot tell us whether it forecasts better."
- Row 8: "In forecasts of 2007-2021, no model beat the recent-average benchmark: skill 1.06 for the random walk, 1.55 for the Ricker and 1.61 for Beverton-Holt. The Ricker and Beverton-Holt were too high by a factor of exp(0.74) = 2.1 on average; the random walk was slightly low (bias -0.19). The random walk's 80% intervals caught 93% of what happened, so they were not too narrow."
- Row 9: "From 66 thousand spawners, the random walk forecasts a median of 491 thousand recruits (80% prediction interval 100 to 2420 thousand)."
- Row 10: "Productivity has fallen from about 34 recruits per spawner around 1950 to about 4 in the 2000s, with a partial recovery to about 8 by 2021. The random walk captures this: it passes the residual checks and has the lowest AIC, but in past years it forecast no better than the average of the last four years (skill 1.06). Its forecast is very uncertain (100 to 2420 thousand recruits), although its intervals were honest in the hindcast (93% coverage)."

Late Stuart shows why a report needs both kinds of evidence: AIC and the residuals choose the random walk, and the hindcast says the recent average forecasts as well.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 2 (Optional): Stretch: Combine Two Ideas (not timed)

For fast pairs, row 11.
Write `nll_bh_walk`, the Beverton-Holt curve with random-walk productivity.
Fit it, check it, and add it to your AIC table and hindcast.

:::::::::::::::::::::::: hint

Start from `nll_walk` in [the finished recipe box (cookbook.R)](files/cookbook.R).
Only the two lines that compute `mu` and `mu_new` change: they take the Beverton-Holt curve from `nll_bh`, with `log_alpha_year` in place of `log_alpha`.
For the starting values, combine `start_bh(dat)` with the two random-walk entries of `start_walk()`.

:::::::::::::::::::::::::

:::::::::::::::::::::::: solution

Add the new model to the list `models`, then rebuild the AIC table:


``` r
nll_bh_walk <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  sd_walk <- exp(log_sd_walk)
  nll <- -dnorm(log_alpha_year[1], log_alpha, sd_walk, log = TRUE)
  nll <- nll - sum(dnorm(diff(log_alpha_year), 0, sd_walk, log = TRUE))
  mu     <- log_alpha_year[year] - log(1 + S / exp(log_Shalf))
  mu_new <- log_alpha_year[max(year) + 1] - log(1 + S_new / exp(log_Shalf))
  ADREPORT(mu_new)
  nll - sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}
par_bh_walk <- c(start_bh(dat), list(log_sd_walk = log(0.1),
                                     log_alpha_year = rep(mean(dat$logRS), max(dat$year) + 1)))
models$bh_walk <- fit_model(nll_bh_walk, par_bh_walk, dat, random = "log_alpha_year")
models$bh_walk$checks
aic_table(models)
```

Then add one line to the hindcast in C8:


``` r
hc <- bind_rows(ricker  = hindcast(models$ricker,  my_stock, first_year = 2007),
                bh      = hindcast(models$bh,      my_stock, first_year = 2007),
                walk    = hindcast(models$walk,    my_stock, first_year = 2007),
                bh_walk = hindcast(models$bh_walk, my_stock, first_year = 2007),
                naive   = naive_forecast(my_stock, first_year = 2007),
                .id = "model")
all(hc$fit_ok)
score_forecasts(hc)
```

For Late Stuart, all four checks are TRUE and every refit passes.

Row 11: "Beverton-Holt with random walk has the lowest AIC (240.83), 1.9 below the random walk: a tie (rule 3), so we report both. Its hindcast skill is 1.12 (80% coverage 0.93), so it forecasts no better than the random walk (1.06) or the benchmark."

On the other menu stocks, the combined model has the lowest AIC or ties for it, and its skill ranges from 0.78 (Harrison) to 1.00 (Quesnel).

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

**Answer key** (values from the filled template; hindcast from 2007; skill = MAE / MAE of the four-year benchmark).
Every fit and every refit passed all four checks, and one run of the filled template takes a few seconds.

Table: Capstone answer key, with the two stocks from class for comparison.

| Stock | Data notes | Best by AIC (ΔAIC to next) | Residual lag-1, Ricker to walk (limit 0.23) | Hindcast skill Ricker / BH / walk | Walk 80% coverage | Forecast (chosen model) | Stretch: BH + walk | Story for the share-out |
|:---|:---|:---|:---|:---|---:|:---|:---|:---|
| Quesnel | 1948-2021, 74 years; spawners 0.009-1740 thousand, 25 years under 1 thousand (four-year cycle); `S_new` 100.6 | walk (24.3 over BH) | 0.32 to -0.11 | 1.38 / 1.37 / 0.995 | 0.80 | walk: 536 (151-1898) | AIC 212.76 (a tie with the walk), skill 1.00 | AIC strongly prefers the walk, which removes the Ricker's optimism (bias +0.97 to -0.27) but only ties the recent average. Under the walk S_max is 3481 thousand (CI 320 to 37 900), beyond the data: "the data cannot pin S_max down" |
| Late Stuart | 1949-2021, 73 years; spawners 0.016-1184, 9 years under 1 thousand; `S_new` 66.0 | walk (3.9 over BH, 7.0 over Ricker) | 0.28 to -0.02 | 1.55 / 1.61 / 1.06 | 0.93 | walk: 491 (100-2419) | AIC 240.83 (best by 1.9), skill 1.12 | AIC and the residuals prefer the walk, but the recent four-year average forecasts as well; intervals are honest here |
| Chilko | 1948-2021, 74 years; spawners 6.6-1182; `S_new` 257.5 | walk 0, BH 0.4, Ricker 1.9: a three-way tie | 0.29 to 0.18 | 0.96 / 0.81 / 1.06 | 0.53 | BH: 1288 (436-3805) | AIC 187.22 (best by 2.2), skill 0.89 | AIC cannot decide; the hindcast prefers Beverton-Holt; the walk's intervals are far too narrow |
| Harrison | 1948-2022, 75 years (16 forecasts); spawners 0.17-400; `S_new` 28.0 | BH (19.0 over Ricker + NPGO) | 0.12; walk collapses (sd_walk 5e-06, the Ricker + 2) | 1.18 / 0.79 / 1.21 | 0.75 | BH: 68 (15-315) | AIC 240.41 (best by 2.4), sd_walk 0.25, skill 0.78 | The curve shape matters: Beverton-Holt wins by 19 and forecasts best. The Ricker random walk finds no drift, but the Beverton-Holt random walk does. Do not report the walk's 0-to-Inf interval |
| Birkenhead | 1948-2021, 74 years; spawners 1.6-198, recent years 2.0, 1.6, 23.5; `S_new` 8.6 | walk (8.1 over BH) | 0.50 to 0.11 | 0.93 / 0.85 / 0.90 | 0.53 | walk: 166 (39-698) | AIC 220.89 (best by 8.8), skill 0.79 | All models only modestly beat the benchmark. The Ricker residuals fail the shape check (QQ). Productivity jumps to 21 recruits per spawner in the last years, when spawners were very few: check those years before trusting the forecast |
| (Stellako) | demonstration stock | walk (18.2) | 0.25 to -0.10 | 1.22 / 1.22 / 0.79 | 0.73 | walk: 152 (57-407) at the recent average of 51.7 | AIC 177.67 (a tie), skill 0.76 | AIC and the hindcast agree |
| (Upper Pitt River) | "your turn" stock | walk (6.2 over Ricker + NPGO) | 0.47 to 0.13 | 0.78 / 0.78 / 0.82 | 0.60 | walk: 12.4 (4.4-35.2) | AIC 182.18 (best by 3.5), skill 0.77 | AIC prefers the walk, the hindcast MAE slightly prefers the stationary curves, and NPGO helps |

Further key values:

- **Ricker estimates** (alpha in recruits per spawner, S_max in thousand spawners, 95% CI):
  - Quesnel: alpha 9.7 (7.3-13.0), S_max 1046 (468-2338);
  - Late Stuart: 10.2 (7.4-14.1), 527 (194-1435);
  - Chilko: 11.2 (8.4-14.9), 388 (268-560);
  - Harrison: 7.3 (5.3-10.2), 112 (69-179); Beverton-Holt alpha 21.1 (10.1-44.5), S_half 3.7 (1.2-11.4);
  - Birkenhead: 11.4 (7.8-16.5), 77.5 (47.8-125.5).
- **sd_walk:** Quesnel 0.22 (0.11-0.43); Late Stuart 0.28 (0.11-0.71); Chilko 0.12 (0.024-0.59); Harrison at zero; Birkenhead 0.48 (0.24-0.94).
- **Simulated-data check**, share of random-walk simulations at or above the observed lag-1 correlation of log(R/S): Quesnel 0.375 (observed 0.43); Late Stuart 0.65; Chilko 0.06 (observed 0.46); Harrison 0.235 (Ricker 0.22); Birkenhead 0.78.
  The Ricker has 0 for every stock except Harrison.
- **Self-test** (30 simulations; Harrison tests Beverton-Holt): every refit passes.
  sd_walk collapses to near zero in 2 of 30 for Quesnel and Late Stuart, 5 for Chilko and 0 for Birkenhead.

Pairs who pick Harrison will find sd_walk at zero: point them to "Check an SD Near Zero" in Episode 6 and to rule 4 of the AIC rules, and let them choose Beverton-Holt for the self-test and the forecast.
Pairs who pick Quesnel should report S_max under the random walk as "beyond the data", not as a number.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

## Share-Out

When the pair work ends, each pair adds one line to a shared table (your instructor provides it):

- the stock;
- the best model by AIC, with the difference in AIC to the next model;
- the best model by hindcast skill, with its skill;
- the random walk's 80% coverage;
- whether AIC and the hindcast agree;
- one sentence about the stock.

Here are the two stocks from class, as examples.

Table: The share-out table, with the two stocks from class as examples.

| Stock | Best by AIC (ΔAIC to next) | Best by hindcast skill (skill) | Random walk 80% coverage | Agree? | One sentence |
|:---|:---|:---|---:|:---|:---|
| Stellako | random walk (18.2) | random walk (0.79) | 0.73 | yes | Productivity fell, and the random walk wins on AIC and in forecasts. |
| Upper Pitt River | random walk (6.2) | Beverton-Holt (0.78) | 0.60 | no | AIC prefers the random walk, but the curves without drift forecast slightly better. |

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 3: Share-Out: Where Did AIC and the Hindcast Disagree? (20 minutes)

Add your line to the shared table.
Then, as a whole group: where did AIC and the hindcast disagree, and why?

:::::::::::::::::::::::: solution

The share-out table for the five menu stocks:

Table: Share-out answers for the five menu stocks.

| Stock | Best by AIC (ΔAIC to next) | Best by hindcast skill (skill) | Random walk 80% coverage | Agree? | One sentence |
|:---|:---|:---|---:|:---|:---|
| Quesnel | random walk (24.3) | random walk (0.995) | 0.80 | yes | The random walk removes the Ricker's optimism, but forecasts only as well as the recent average. |
| Late Stuart | random walk (3.9) | random walk (1.06) | 0.93 | yes | No model beats the recent average in past years. |
| Chilko | a tie: random walk, Beverton-Holt (0.4), Ricker (1.9) | Beverton-Holt (0.81) | 0.53 | no | AIC cannot decide; the hindcast prefers Beverton-Holt, and the random walk's intervals are far too narrow. |
| Harrison | Beverton-Holt (19.0) | Beverton-Holt (0.79) | 0.75 | yes | The shape of the curve matters more than drift: sd_walk is estimated at zero. |
| Birkenhead | random walk (8.1) | Beverton-Holt (0.85) | 0.53 | no | All models only modestly beat the benchmark, and productivity jumps to about 21 recruits per spawner in the last years, when spawners were very few. |

Points the instructor should hear:

- AIC scores how well a model describes the years it was fitted to, with a penalty for each parameter; the hindcast scores forecasts of years the model had not seen. They answer different questions, so they can disagree.
- The random walk often wins on AIC because it follows productivity through every year it has seen. A forecast needs next year's productivity, one step beyond the data, and a recent average can forecast as well (Quesnel, Late Stuart).
- Skill rests on only 15 or 16 forecasts, so a small difference in skill, such as 0.78 against 0.82, depends on a few years.
- Coverage well below 0.80 (Chilko and Birkenhead, 0.53) means intervals that were too narrow: report it next to the forecast.
- When AIC and the hindcast disagree, report both, and say which question the chosen model answers best: describing the past or forecasting the next year.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

## Where Next

You can now take a new data set from counts to a checked, compared and tested forecast.
These pages help you keep going:

- the [Recipe Index](../learners/recipe-index.md): which recipe for which task, on one page;
- [Troubleshooting](../learners/troubleshooting.md): what to do when a check fails or an error appears;
- [Going Further](../learners/going-further.md): the methods this lesson left out, and where to learn them.

Your `my-recipes.R` and report card are a template for your next analysis: copy the capstone template, change C1, and work down the rows.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

After the share-out, close the workshop outside the counted minutes: minute cards, the post-workshop survey, and one-up/one-down.
Point learners to the Going Further page and the Recipe Index, and remind them to keep `my-recipes.R`, `report-card.R` and the filled template.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: callout

### Add to Your Recipe Box

Your recipe box is complete.
Keep `my-recipes.R`, `report-card.R` and the template for your next analysis.
If you wrote `nll_bh_walk()` in Challenge 2, add it too.
The finished box is [cookbook.R](files/cookbook.R).

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: callout

### In Your Field

To use the template with your own data, keep the order of the sections and change only C1 (the data).
If your data are not log ratios, change the score line in each model too, and the helpers written for log ratios ([Your Own Data](#your-own-data)).

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: keypoints

- The recipes, applied in order, take a new data set from counts to a checked, compared and tested forecast.
- Model selection (AIC) and model evaluation (residuals, simulation, hindcast) answer different questions; a report needs both.
- A good report states what was checked, what failed, and what the forecast can and cannot be trusted for.

::::::::::::::::::::::::::::::::::::::::::::::::::
