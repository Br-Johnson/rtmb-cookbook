---
title: 'Going Further'
---

The lesson teaches one way to do each task.
This page lists what comes next: other methods, bigger models and the theory the lesson leaves out.
Each paragraph names the episode it extends.
None of it is needed for the capstone.

## Topics Beyond This Lesson

**Profile-likelihood intervals for standard deviations.**
Extends [Random Effects](../episodes/06-random-effects.Rmd) and [Many Stocks](../episodes/10-many-stocks.Rmd).
`ci_table()` builds every interval from a standard error, which works poorly for a standard deviation (SD) close to zero.
A profile interval instead refits the model with the parameter held at a range of values and keeps the values the data support.
`TMB::tmbprofile()` computes it, and both episodes show it in an optional box.
For an SD estimated at zero the profile is flat and its interval is unreliable too: report the estimate and the comparison by Akaike information criterion (AIC) instead.

**REML for variance components.**
Extends [Many Stocks](../episodes/10-many-stocks.Rmd).
Standard deviations of random effects estimated by maximum likelihood are a little too small.
Listing the fixed means in `random =` as well (restricted maximum likelihood, REML) gives less biased SDs.
In the design research for this lesson, the between-stock SD rose from 0.106 to 0.127.
Use REML to report SDs, not to compare models: AIC needs the ordinary fits.

**Heavier tails for extreme years.**
Extends [Residuals](../episodes/07-residuals.Rmd) and [Simulation](../episodes/08-simulation.Rmd).
Stellako's brood year 2005 is far below every other year, and a normal distribution finds it very surprising.
A Student-t distribution, RTMB's `dt()`, expects an occasional extreme year.
In the design research, a Student-t random walk lowered Stellako's AIC from 178.3 to 170.9.

**Year effects correlated from year to year.**
Extends [Random Effects](../episodes/06-random-effects.Rmd) and [Many Stocks](../episodes/10-many-stocks.Rmd).
The shared year effects of Episode 10 are independent of each other.
RTMB's `dautoreg()` lets neighbouring years be alike, between independent years and a random walk.
Another extension gives every stock its own random walk in productivity.

**Cycles and the Larkin model.**
Extends [Comparing Models](../episodes/09-model-selection.Rmd).
Some Fraser stocks, such as Quesnel, have strong four-year cycles: a large brood year is followed by smaller ones.
The Larkin model adds the spawners of the three previous brood years to the Ricker model.
It drops the first three years, so every model it is compared with must be refitted to the same rows.
Put spawners in millions to avoid false alarms in the `flat` check.
Challenge 1 below fits it to Chilko.

**`map` and `REPORT()`.**
Extends [Fitting and Checking](../episodes/04-fit-and-check.Rmd) and [Comparing Models](../episodes/09-model-selection.Rmd).
`map` holds a parameter at its starting value without writing a new function; Episode 9 shows it in an optional box.
`REPORT()` returns any value computed inside the function, without a standard error.
Read reported values with `obj$report(obj$env$last.par.best)`, never `obj$report()` alone, which uses whatever parameter values were evaluated last.

**Other forecast scores.**
Extends [Forecasting](../episodes/11-forecasting.Rmd).
The log score rewards a forecast for giving high probability to what happened, and probability integral transform (PIT) plots show whether prediction intervals are too narrow or too wide.
Episode 11 shows the log score in an optional box.

**State-space spawner-recruit models.**
Extends [Likelihoods](../episodes/03-likelihoods.Rmd).
Spawner counts are measured with error, which biases the regression of log(R/S) on spawners.
A state-space model separates the true number of spawners, a random effect, from the measured one.

**Forecasts by return year and age.**
Extends [Forecasting](../episodes/11-forecasting.Rmd).
Real pre-season forecasts predict the adults returning in one calendar year, which come from several brood years (mostly four- and five-year-old fish).
The lesson forecasts by brood year instead.

**Bayesian fitting.**
Extends [Fitting and Checking](../episodes/04-fit-and-check.Rmd).
The [tmbstan package on CRAN](https://cran.r-project.org/package=tmbstan) samples from the same RTMB model objects with Stan, and gives posterior distributions instead of standard errors.

**Formula interfaces for standard models.**
Extends [Many Stocks](../episodes/10-many-stocks.Rmd).
When a model is a standard mixed model, a formula package is quicker to write.
The [glmmTMB package on CRAN](https://cran.r-project.org/package=glmmTMB) gives the same negative log-likelihood (1883.81) for Episode 10's stock model.

**Custom distributions.**
Extends [Likelihoods](../episodes/03-likelihoods.Rmd).
RTMB has the usual R distributions; the RTMBdist package adds more, and you can write your own with support for simulation.

**Documentation and derivations.**
The [RTMB documentation](https://kaskr.github.io/RTMB/), the [TMB documentation](https://kaskr.github.io/adcomp/) and the materials of the original Pacific Salmon Commission RTMB workshop contain the derivations this lesson leaves out: gradients, the Laplace approximation and the delta method.

## Extra Challenges

These challenges are for fast learners, or for after the workshop.
Each starts from this code, run in your project folder:

```r
library(RTMB)
library(dplyr)
library(ggplot2)
source("files/cookbook.R")
sockeye <- read.csv("data/sockeye.csv")
npgo    <- read.csv("data/npgo.csv")
```

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 1 (Optional): A Larkin Model for Chilko (not timed)

Chilko sockeye have a four-year cycle.
The Larkin model lets this year's recruits per spawner depend on the spawners of the three previous brood years as well:

$$\log(R_t/S_t) = \log\alpha - S_t/S_{max} - b_1 S_{t-1} - b_2 S_{t-2} - b_3 S_{t-3} + \text{noise}$$

In words: the Ricker model, plus one term for each of the three earlier brood years' spawners.

Write `nll_larkin`, fit it to Chilko, check it, and compare it with the Ricker model using `aic_table()`.
Which brood years affect this year's productivity?

:::::::::::::::::::::::: hint

- Build the earlier spawners by brood year, not by row: `spawners[match(brood_year - 1, brood_year)]` inside `mutate()`.
- The first three brood years have no earlier spawners: drop them, and fit the Ricker model to the same rows.
- Divide the earlier spawners by 1000 (millions of fish), so that `b1` to `b3` are not tiny numbers.
- For `mu_new`, the earlier spawners of the next brood year are the last three observed ones.

:::::::::::::::::::::::::

:::::::::::::::::::::::: solution

```r
chilko <- sockeye %>%
  filter(stock == "Chilko") %>%
  mutate(S1 = spawners[match(brood_year - 1, brood_year)] / 1000,   # millions of fish
         S2 = spawners[match(brood_year - 2, brood_year)] / 1000,
         S3 = spawners[match(brood_year - 3, brood_year)] / 1000) %>%
  filter(!is.na(S3))                                    # drop years without three earlier ones
dat_ch <- make_dat(chilko, S_new = mean(tail(chilko$spawners, 4)))
dat_ch$S1 <- chilko$S1
dat_ch$S2 <- chilko$S2
dat_ch$S3 <- chilko$S3
dat_ch$S_lags_new <- rev(tail(chilko$spawners, 3)) / 1000   # lags 1, 2, 3 for the next year

nll_larkin <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu     <- log_alpha - S / exp(log_Smax) - b1 * S1 - b2 * S2 - b3 * S3
  mu_new <- log_alpha - S_new / exp(log_Smax) - sum(c(b1, b2, b3) * S_lags_new)
  ADREPORT(mu_new)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}

larkin_ch <- fit_model(nll_larkin, c(start_ricker(dat_ch), list(b1 = 0, b2 = 0, b3 = 0)), dat_ch)
ricker_ch <- fit_model(nll_ricker, start_ricker(dat_ch), dat_ch)     # the same 71 rows
larkin_ch$checks
aic_table(list(ricker = ricker_ch, larkin = larkin_ch))
ci_table(larkin_ch)
```

```output
 finished      flat    curved finite_se 
     TRUE      TRUE      TRUE      TRUE 
   model k      AIC checks_ok     dAIC
2 larkin 6 165.3239      TRUE  0.00000
1 ricker 3 185.0405      TRUE 19.71659
  parameter    estimate       lower       upper
1     alpha  18.8998069  13.6324471  26.2023903
2      Smax 535.0998884 324.7446725 881.7138963
3     sigma   0.7123454   0.6043076   0.8396981
4        b1   1.3835859   0.4367815   2.3303903
5        b2   1.3931868   0.4383542   2.3480195
6        b3   0.4090741  -0.5397814   1.3579295
```

The Larkin model passes all four checks and is better than the Ricker model by 19.7 AIC units on the same 71 brood years (1951-2021): a decisive difference.
Spawners one and two brood years earlier both lower this year's recruits per spawner: log(R/S) falls by about 1.4 for every million spawners in either year.
The interval for three brood years earlier includes zero.
`b1` to `b3` have no `log_` prefix because they may be negative, so `ci_table()` leaves them on their own scale.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 2 (Optional): NPGO for Every Stock (not timed)

Episode 9 found no clear effect of the NPGO index on Stellako.
Fit `nll_ricker_npgo` to each of the 19 stocks separately, and collect the estimate of `b_npgo` with its 95% confidence interval.
How many intervals lie above zero, and how many below?
What would you conclude, and what makes you wary?

:::::::::::::::::::::::: hint

Loop over `unique(sockeye$stock)`.
Inside the loop, reuse the covariate recipe of Episode 9, and keep the `b_npgo` row with `filter(ci_table(m_s), parameter == "b_npgo")`.

:::::::::::::::::::::::::

:::::::::::::::::::::::: solution

```r
npgo_by_brood <- npgo %>%
  mutate(brood_year = year - 2) %>%
  select(brood_year, npgo)
b_npgo <- NULL
for (s in unique(sockeye$stock)) {
  one   <- filter(sockeye, stock == s) %>% left_join(npgo_by_brood, by = "brood_year")
  dat_s <- make_dat(one, S_new = mean(tail(one$spawners, 4)))
  dat_s$npgo     <- one$npgo
  dat_s$npgo_new <- npgo$npgo[npgo$year == max(one$brood_year) + 3]
  m_s <- fit_model(nll_ricker_npgo, c(start_ricker(dat_s), list(b_npgo = 0)), dat_s)
  b_npgo <- rbind(b_npgo, data.frame(stock = s, filter(ci_table(m_s), parameter == "b_npgo"),
                                     checks_ok = all(m_s$checks)))
}
arrange(b_npgo, estimate)
c(above_zero = sum(b_npgo$lower > 0), below_zero = sum(b_npgo$upper < 0))
```

```output
              stock parameter    estimate       lower     upper checks_ok
1            Bowron    b_npgo -0.13294111 -0.38808383 0.1222016      TRUE
2      Early Stuart    b_npgo -0.09333289 -0.28904288 0.1023771      TRUE
3           Portage    b_npgo  0.01722932 -0.28735917 0.3218178      TRUE
4      Weaver Creek    b_npgo  0.02433940 -0.29080043 0.3394792      TRUE
5       Late Stuart    b_npgo  0.02454883 -0.27066270 0.3197603      TRUE
6            Nadina    b_npgo  0.03285248 -0.18326695 0.2489719      TRUE
7           Quesnel    b_npgo  0.07977448 -0.18558337 0.3451323      TRUE
8              Raft    b_npgo  0.08375738 -0.14373383 0.3112486      TRUE
9            Chilko    b_npgo  0.09685889 -0.09627300 0.2899908      TRUE
10         Stellako    b_npgo  0.11591279 -0.08948870 0.3213143      TRUE
11       Birkenhead    b_npgo  0.11866021 -0.15559407 0.3929145      TRUE
12     Fennel Creek    b_npgo  0.17605820 -0.11193167 0.4640481      TRUE
13          Seymour    b_npgo  0.19861605 -0.03563336 0.4328654      TRUE
14     Late Shuswap    b_npgo  0.20606196 -0.07759905 0.4897230      TRUE
15            Gates    b_npgo  0.27500849  0.04412795 0.5058890      TRUE
16 Upper Pitt River    b_npgo  0.28235536  0.08671565 0.4779951      TRUE
17         Harrison    b_npgo  0.32820965  0.02986734 0.6265520      TRUE
18     Scotch Creek    b_npgo  0.39791217  0.09844914 0.6973752      TRUE
19           Cultus    b_npgo  0.66047130  0.30629244 1.0146502      TRUE
above_zero below_zero 
         5          0 
```

All 19 fits pass the four checks.
Sixteen of the 19 estimates are positive, five intervals lie above zero and none lie below: higher NPGO tends to go with more recruits per spawner.
Two things call for caution.
With 19 separate intervals, about one in 20 would exclude zero by chance even with no effect at all.
And good and bad ocean years affect all stocks at once, so the 19 results are not independent pieces of evidence.
[Many Stocks](../episodes/10-many-stocks.Rmd) fits the stocks together: there, NPGO looks strong until the model also has a shared year effect, and then AIC no longer supports it.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 3 (Optional): Check Your Data First (not timed)

Fit the random-walk model to Early Stuart and find its productivity in the forecast year.
Then check the data: which brood years drive that result?
Refit without them and compare.

:::::::::::::::::::::::: hint

Plot log(R/S) against brood year, and list the years with the smallest spawner counts (`filter(spawners < 1)`).
You cannot compare the two fits with AIC, because they use different rows: compare the productivity instead.

:::::::::::::::::::::::::

:::::::::::::::::::::::: solution

```r
early   <- filter(sockeye, stock == "Early Stuart")
dat_es  <- make_dat(early, S_new = mean(tail(early$spawners, 4)))
walk_es <- fit_model(nll_walk, start_walk(dat_es), dat_es, random = "log_alpha_year")
walk_es$checks
tail(ci_table(walk_es, "random"), 1)         # productivity in the forecast year
early %>%
  mutate(logRS = log(recruits / spawners)) %>%
  filter(spawners < 1)                       # fewer than 1 thousand spawners
early_100  <- filter(early, spawners >= 0.1) # drop the two years with fewer than 100 spawners
dat_es100  <- make_dat(early_100, S_new = mean(tail(early_100$spawners, 4)))
walk_es100 <- fit_model(nll_walk, start_walk(dat_es100), dat_es100, random = "log_alpha_year")
walk_es100$checks
tail(ci_table(walk_es100, "random"), 1)
```

```output
 finished      flat    curved finite_se 
     TRUE      TRUE      TRUE      TRUE 
    parameter estimate    lower    upper
75 alpha_year 24.24504 8.454139 69.53067
         stock management_unit brood_year spawners recruits    logRS
1 Early Stuart    Early Stuart       1968    0.795   10.412 2.572372
2 Early Stuart    Early Stuart       2011    0.233    2.366 2.317918
3 Early Stuart    Early Stuart       2019    0.046    0.438 2.253578
4 Early Stuart    Early Stuart       2020    0.015    1.170 4.356709
 finished      flat    curved finite_se 
     TRUE      TRUE      TRUE      TRUE 
    parameter estimate    lower    upper
75 alpha_year 13.92486 4.103095 47.25746
```

The fit passes all four checks and puts productivity in the forecast year at 24 recruits per spawner.
But brood years 2019 and 2020 had 46 and 15 spawners (0.046 and 0.015 thousand), and 15 spawners producing 1170 recruits gives the highest log(R/S) in the series, 4.36.
The random walk follows the last years, so these two counts nearly double the forecast productivity: without them it is 14 recruits per spawner.
The four checks only say that the optimiser found the best values for these data; they cannot say whether the data make sense.
Before you trust a model, plot the data, look at the smallest and largest values, ask the people who collected them about anything odd, and report how much the result depends on those years.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::
