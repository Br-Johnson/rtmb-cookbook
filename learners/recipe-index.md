---
title: 'Recipe Index'
---

![
The nine-step workflow. Each recipe below belongs to one of these steps.
](../episodes/fig/workflow.svg){
alt="Nine numbered boxes in a row joined by arrows: 1 data, 2 model, 3 fit, 4 check the fit, 5 estimates, 6 check the model, 7 random effect, 8 compare, 9 forecast."
}

Print this page and keep it next to you while you work.
Every recipe's code is in your `my-recipes.R` and in [the finished recipe box (cookbook.R)](../episodes/files/cookbook.R).
In the table, `m` is any fitted model and `nll_x`, `start_x` stand for any model function and its starting values.
CI is a confidence interval, PI a prediction interval, SD a standard deviation and AIC the Akaike information criterion.

## Which Recipe Do I Need?

Table: Which recipe do I need? Each row gives the recipe, the sign that it worked and the episode that teaches it.

| I want to... | Recipe | Check it worked | Episode |
|:---|:---|:---|:---|
| look at one stock | `my_stock <- filter(sockeye, stock == "Stellako")` | rows and units as expected | [01 Introduction](../episodes/01-introduction.Rmd) |
| make a data list | `dat <- make_dat(my_stock, S_new = mean(tail(my_stock$spawners, 4)))` | `S`, `logRS`, `year` have one value per row | [03 Likelihoods](../episodes/03-likelihoods.Rmd) |
| write a model | `getAll()`; `OBS()`; `mu`, `mu_new`, `ADREPORT(mu_new)`; `-sum(dnorm(..., log = TRUE))` | `obj$fn(obj$par)` is a finite number | [03 Likelihoods](../episodes/03-likelihoods.Rmd) |
| choose starting values | `start_ricker(dat)`, `start_bh(dat)`, `start_walk(dat)` | as above | [03 Likelihoods](../episodes/03-likelihoods.Rmd), [06 Random Effects](../episodes/06-random-effects.Rmd) |
| fit a model | `m <- fit_model(nll_x, start_x(dat), dat)` | no error | [04 Fitting and Checking](../episodes/04-fit-and-check.Rmd) |
| tell whether a fit can be used | `m$checks` | four TRUE | [04 Fitting and Checking](../episodes/04-fit-and-check.Rmd) |
| report estimates | `ci_table(m)` | natural scale, units, 95% CI | [05 Uncertainty](../episodes/05-uncertainty.Rmd) |
| report a derived quantity | `log_x <- ...; ADREPORT(log_x)` in the function; `ci_table(m, "report")` | a row named `x` | [05 Uncertainty](../episodes/05-uncertainty.Rmd) |
| draw a curve with its band | `S_new` as a grid; refit; `predict_recruits(m, "confidence", 0.95)` | band widest where data are sparse | [05 Uncertainty](../episodes/05-uncertainty.Rmd) |
| let a quantity drift over time | `nll_walk`, `random = "log_alpha_year"` | four TRUE; `sd_walk` read in words | [06 Random Effects](../episodes/06-random-effects.Rmd) |
| plot the drift | `ci_table(m, "random")` + `geom_ribbon()` | last row is the forecast year | [06 Random Effects](../episodes/06-random-effects.Rmd) |
| deal with an SD near zero | refit from `log(0.001)`; compare AIC with the simpler model | same negative log-likelihood; AIC + 2 | [06 Random Effects](../episodes/06-random-effects.Rmd) |
| check residuals | `osa_residuals(m)`; QQ plot; against year and spawners; `lag1()` | lag-1 within ±2/sqrt(n) | [07 Residuals](../episodes/07-residuals.Rmd) |
| ask whether the model can make data like mine | `simulate_stat(m, lag1)` | the real value is inside the simulated range | [08 Simulation](../episodes/08-simulation.Rmd) |
| ask whether the recipe recovers the truth | `self_test(m, n_sim = 30)` | refits pass; medians near the truth | [08 Simulation](../episodes/08-simulation.Rmd) |
| compare models | `aic_table(list(a = m1, b = m2))` | same rows; all checks TRUE | [09 Comparing Models](../episodes/09-model-selection.Rmd) |
| add a covariate | `left_join()` by year; `+ b_x * x` in `mu` and `mu_new`; start `b_x = 0` | no `NA`; CI for `b_x` | [09 Comparing Models](../episodes/09-model-selection.Rmd) |
| let groups differ | a group index; `dnorm(group_values, mean, exp(log_sd))`; `random =` | estimates shrink toward the mean | [10 Many Stocks](../episodes/10-many-stocks.Rmd) |
| forecast | `predict_recruits(m)` | median with 80% PI, units | [11 Forecasting](../episodes/11-forecasting.Rmd) |
| test forecasts | `hindcast(m, df, 2007)`, `naive_forecast(df, 2007)`, `score_forecasts()` | skill below 1 beats the benchmark | [11 Forecasting](../episodes/11-forecasting.Rmd) |

The [Reference](reference.md#glossary) page defines every term.
If something goes wrong, the [Troubleshooting](troubleshooting.md) page lists the messages and their fixes.

## Rules Cards

:::::::::::::::::::::::::::::::::::::::: callout

### The Four Checks

`finished`, `flat`, `curved`, `finite_se`.
All four must be TRUE before you use a fit.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: callout

### The Three Residual Checks

- Shape: the QQ plot follows its line.
- Pattern: no trend against brood year or against spawners.
- Independence: the lag-1 correlation is within ±2/sqrt(n), where n is the number of years.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: callout

### The Four AIC Rules

1. Same rows, same response (`logRS`), and every fit passes all four checks.
2. Choose the candidate models before you look at results: one question per model.
3. A difference under 2 is a tie: prefer the simpler model, or report both. Over 10 is decisive. In between, favour the lower AIC and look at residuals and forecasts.
4. A random effect whose SD collapses to zero adds about 2 to AIC. That means the data cannot detect the variation, not that it is absent.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: callout

### The Forecast Scores

- Bias: near 0. Above 0, forecasts were too high.
- Mean absolute error (MAE): smaller is better.
- Skill: below 1 beats the benchmark.
- 80% coverage: near 0.80.

::::::::::::::::::::::::::::::::::::::::::::::::::
