---
title: 'Reference'
---

## Glossary

ADREPORT()
: An RTMB function that asks for a standard error for any quantity computed inside the model function.

AIC (Akaike information criterion)
: A score for comparing models fitted to the same data: 2 × negative log-likelihood + 2 × number of fixed parameters. Smaller is better.

Akaike weight
: The share of support for each model within one set of candidates, computed from AIC differences.

Automatic differentiation
: How RTMB works out exact slopes of the negative log-likelihood from a recording of your calculation.

Back-transform
: Turning a value on the log scale back to the natural scale with `exp()`.

Benchmark (naive forecast)
: A plain forecasting rule, such as "recruits per spawner as in the last four years", that a model must beat to be useful.

Beverton-Holt model
: A curve of recruits against spawners (a stock-recruitment curve) in which recruits rise and then level off as spawners increase, instead of turning down.

Bias (of forecasts)
: The average of log(forecast / observed). Above zero means forecasts were too high.

Brood year
: The year in which the parent fish spawned.

Confidence interval
: A range of values for a parameter or a curve that is consistent with the data. This lesson uses 95%.

Convergence
: The optimiser's report that it stopped normally (`opt$convergence` is 0, the `finished` check). Necessary but not enough: use the four checks.

Coverage
: The share of observations that fell inside a prediction interval. An 80% interval should cover about 80%.

Data list
: The named list (`dat`) that a model function uses: inputs, observations, indices and forecast inputs.

Derived quantity
: A quantity computed from the parameters, such as R_max or S_MSY.

Fixed parameter
: A parameter estimated directly by the optimiser. Fixed parameters are counted in AIC; random effects are not.

Forecast skill
: A model's mean absolute error divided by the benchmark's. Below 1 means it beats the benchmark.

Four checks
: The lesson's test of whether a fit can be used: the optimiser `finished`, the ground is `flat`, the bottom is `curved` like a bowl, and every standard error is finite (`finite_se`).

Gradient
: The slope of the negative log-likelihood. Near zero at the best values (the `flat` check).

Hessian
: The curvature of the negative log-likelihood at the best values. It must form a bowl (the `curved` check) for standard errors to exist.

Hindcast
: A test of forecasts on past years: refit the model to the years before a target year, forecast that year, and repeat for many years. Also called a leave-future-out test.

Lag-1 correlation
: The correlation between each value and the next one in time. Near zero for good residuals.

Laplace approximation
: The method RTMB uses to average over random effects.

Likelihood
: How probable the observed data are for given parameter values.

Log scale
: Values after taking natural logarithms. Positive parameters are estimated on the log scale so they stay positive.

Management unit
: A group of Fraser sockeye stocks that return at a similar time and are managed together.

Mean absolute error (MAE)
: The average size of forecast errors, here on the log scale.

Median
: The middle value: half of the outcomes are expected below it. `exp()` of a log-scale forecast is a median, not a mean.

Negative log-likelihood
: Minus the log of the likelihood: a "surprise score" that fitting makes as small as possible.

NPGO (North Pacific Gyre Oscillation)
: An index of ocean circulation in the North Pacific. Higher values usually mean more food for young salmon.

OBS()
: An RTMB function that marks the observations, so that residuals and simulations can find them.

One-step-ahead residual
: How far each observation is from what the model predicted from the earlier years only, scaled so that a good model gives values like draws from a normal distribution with mean 0 and standard deviation 1. The residual used throughout this lesson.

Optimiser
: The function (`nlminb()`) that searches for the parameter values with the smallest negative log-likelihood.

Parameter
: An unknown number in a model that is estimated from the data.

Prediction interval
: A range where a new observation will probably fall. Wider than a confidence interval, because it adds the yearly scatter. This lesson uses 80%.

Productivity
: Recruits per spawner when spawners are few (alpha).

QQ plot (quantile-quantile plot)
: Sorted residuals plotted against the values a normal distribution would give. Points close to the line mean the normal distribution fits.

R_max
: In the Ricker model, the largest number of recruits the curve predicts, produced by S_max spawners.

Random effect
: A set of related unknown values (one per year, or one per group) that come from a distribution. RTMB averages over them and estimates the distribution's standard deviation.

Random walk
: A sequence in which each value equals the previous one plus a small random step.

Recruits
: All the adult fish produced by one brood year's spawners, whether caught or returning to spawn.

Recruits per spawner (R/S)
: Recruits divided by spawners. log(R/S) = 0 means each spawner replaced itself.

Residual
: How far an observation is from what the model expected, on a standard scale.

Ricker model
: A curve of recruits against spawners (a stock-recruitment curve) in which recruits per spawner fall steadily as spawners increase, so the number of recruits peaks at S_max.

RTMB
: An R package that fits models written as ordinary R functions, with exact slopes and random effects. It lets you use Template Model Builder (TMB) without writing any C++.

S_half
: In the Beverton-Holt model, the spawner count that produces half the maximum recruits.

S_max
: In the Ricker model, the spawner count that produces the most recruits. Not a carrying capacity.

S_MSY
: The spawner count that gives the largest catch that can be taken year after year (the maximum sustainable yield).

S_rep
: The spawner count at which each spawner exactly replaces itself (log(R/S) = 0).

sd_walk
: The standard deviation of the yearly steps in a random walk.

Self-test
: Simulating data sets from a fitted model, refitting the model to each, and checking that the known values are recovered.

Shrinkage
: In a model with a random effect for groups, the movement of each group's estimate towards the overall average. It is largest for groups whose own estimates are extreme and uncertain.

Sigma
: The standard deviation of the yearly scatter of log(R/S) around the curve.

Simulated-data check
: Comparing a feature of the real data with the same feature in many data sets simulated from the fitted model.

Spawners
: The adult fish that spawned in a brood year.

Standard error
: How uncertain an estimate is. Used to build confidence intervals.

Starting values
: The parameter values where the optimiser begins its search.

Stock
: A group of salmon that spawn in the same place at the same time of year.

Template Model Builder (TMB)
: The C++ library behind RTMB.

U_MSY
: The share of recruits caught (the harvest rate) that gives the maximum sustainable yield.

Year effect
: A random effect shared by all stocks in a brood year: good and bad years common to all.

## Functions by Episode

The functions the lesson uses beyond basic R (such as `mean()`, `log()` or `sapply()`), in the order the episodes introduce them.
The episodes are
[01 Introduction](../episodes/01-introduction.Rmd),
[02 Quick Start](../episodes/02-quick-start.Rmd),
[03 Likelihoods](../episodes/03-likelihoods.Rmd),
[04 Fitting and Checking](../episodes/04-fit-and-check.Rmd),
[05 Uncertainty](../episodes/05-uncertainty.Rmd),
[06 Random Effects](../episodes/06-random-effects.Rmd),
[07 Residuals](../episodes/07-residuals.Rmd),
[08 Simulation](../episodes/08-simulation.Rmd),
[09 Comparing Models](../episodes/09-model-selection.Rmd),
[10 Many Stocks](../episodes/10-many-stocks.Rmd),
[11 Forecasting](../episodes/11-forecasting.Rmd) and
[12 Capstone](../episodes/12-capstone.Rmd).
The lesson's own functions are all in [the finished recipe box (cookbook.R)](../episodes/files/cookbook.R).

Table: Functions by episode. "Lesson" means a function written in the lesson, which you keep in `my-recipes.R`.

| Function | Package | What it does | Episode |
|:---|:---|:---|:---|
| `filter()` | dplyr | keep the rows that meet a condition, such as one stock | 01 |
| `mutate()` | dplyr | add or change a column, such as `logRS` | 01 |
| `distinct()`, `count()` | dplyr | list the unique combinations of columns; count rows per group | 01 |
| `case_when()` | dplyr | choose a value by conditions, such as a period for each brood year | 01 |
| `group_by()`, `summarise()`, `n()` | dplyr | summarise rows by group, such as by period, parameter or model; `n()` counts the rows in each group | 01 |
| `ggplot()`, `aes()`, `geom_point()`, `geom_line()`, `labs()` | ggplot2 | start a plot; map columns to x, y and other features; draw points; draw lines; label the axes with units | 01 |
| `geom_hline()` | ggplot2 | draw a horizontal reference line, such as log(R/S) = 0 | 01 |
| `getAll()` | RTMB | make every element of `par` and `dat` available by name inside a model function | 02 |
| `OBS()` | RTMB | mark the observations, so residuals and simulations can find them | 02 |
| `ADREPORT()` | RTMB | ask for a standard error for a quantity computed inside the model function | 02 |
| `dnorm()` | base R | normal density; with `log = TRUE`, the log-likelihood of each observation | 02 |
| `diff()` | base R | the differences between neighbouring values: the yearly steps of a random walk | 02 |
| `MakeADFun()` | RTMB | build a model object from the model function, the starting values and `random =` | 02 |
| `obj$fn()`, `obj$gr()` | RTMB | the negative log-likelihood, and its slopes, at given parameter values | 02 |
| `nlminb()` | base R | search for the parameter values with the smallest negative log-likelihood | 02 |
| `sdreport()` | RTMB | compute standard errors after fitting | 02 |
| `summary(sdr, "fixed")`, `summary(sdr, "report")` | RTMB | estimates and standard errors of the fixed parameters, or of the `ADREPORT()` quantities | 02 |
| `oneStepPredict()` | RTMB | one-step-ahead residuals | 02 |
| `qnorm()` | base R | a quantile of the normal distribution, such as `qnorm(0.9)` for an 80% interval | 02 |
| `check_fit()` | lesson | the four checks from the optimiser's result and `sdreport()` | 02 |
| `lag1()` | lesson | the lag-1 correlation: are neighbouring years alike? | 02 |
| `aic()` | lesson | AIC from the optimiser's result | 02 |
| `nll_ricker()` | lesson | the Ricker model | 02, 03 |
| `nll_walk()` | lesson | the Ricker model with productivity that drifts from year to year (random walk) | 02, 06 |
| `make_dat()` | lesson | turn one stock's rows into the data list every single-stock model uses | 03 |
| `start_ricker()`, `start_bh()` | lesson | starting values taken from the data | 03 |
| `nll_bh()` | lesson | the Beverton-Holt model | 03 |
| `bind_rows()` | dplyr | stack data frames, with a column saying which one each row came from | 03 |
| `scale_linetype_manual()` | ggplot2 | choose the line type (solid, dotted, dashed) for each group, so the plot does not rely on colour | 03 |
| `fit_model()` | lesson | build, fit and check a model, and keep its data and recipe for refits | 04 |
| `ci_table()` | lesson | 95% confidence intervals, back-transformed to the natural scale | 05 |
| `predict_recruits()` | lesson | recruits for `S_new` spawners, with a confidence band (05) or a prediction interval (11) | 05, 11 |
| `geom_ribbon()` | ggplot2 | draw an interval band | 05 |
| `uniroot()` | base R | find where a function crosses zero, for S_MSY (optional) | 05 |
| `start_walk()` | lesson | starting values for the random walk: one value per year, plus the next year | 06 |
| `summary(sdr, "random")` | RTMB | estimates and standard errors of the random effects (used by `ci_table(m, "random")`) | 06 |
| `TMB::tmbprofile()`, `confint()` | TMB | a profile interval for one parameter (optional) | 06, 10 |
| `osa_residuals()` | lesson | one-step-ahead residuals of a fitted model | 07 |
| `arrange()` | dplyr | sort rows, for example by brood year | 07, 10 |
| `stat_qq()`, `stat_qq_line()` | ggplot2 | a QQ plot of residuals against the normal distribution, with its reference line | 07 |
| `facet_wrap()` | ggplot2 | one panel per model or group | 07 |
| `obj$simulate()` | RTMB | simulate a new data set from the model | 08 |
| `obj$env$last.par.best` | RTMB | the best parameter values found, including random effects; pass them to `obj$simulate()` | 08 |
| `set.seed()` | base R | fix the random numbers, so a simulation gives the same result every time | 08 |
| `replicate()` | base R | repeat a calculation many times and collect the results | 08 |
| `simulate_stat()` | lesson | a statistic, such as `lag1()`, computed on many data sets simulated from a fitted model | 08 |
| `self_test()` | lesson | simulate from a fitted model, refit to each data set and compare with the known values | 08 |
| `first()` | dplyr | the first value in each group, inside `summarise()` | 08 |
| `geom_histogram()`, `geom_vline()` | ggplot2 | a histogram; a vertical reference line, such as the observed value | 08 |
| `scale_x_log10()`, `scale_y_log10()` | ggplot2 | a logarithmic x or y axis | 08, 11 |
| `aic_table()` | lesson | an AIC table; stops if the models were fitted to different rows | 09 |
| `nll_ricker_npgo()` | lesson | the Ricker model plus the NPGO index in the year the young fish enter the ocean | 09 |
| `select()`, `left_join()` | dplyr | keep some columns; add columns from another table by a shared column, such as brood year | 09 |
| `nll_stocks()`, `nll_stocks_years()` | lesson | all stocks with a random effect for stock productivity, then with a shared year effect | 10 |
| `tapply()` | base R | apply a function to each group, such as the mean spawner count of each stock | 10 |
| `desc()` | dplyr | sort from largest to smallest, inside `arrange()` | 10 |
| `geom_pointrange()`, `geom_segment()` | ggplot2 | a point with its interval; a line segment between two points | 10 |
| `reorder()` | base R | order the groups on a plot axis by another value, such as stocks by their estimate | 10 |
| `arrow()`, `unit()` | ggplot2 (from grid) | arrowheads for `geom_segment()`, and their size | 10 |
| `hindcast()` | lesson | refit to the years before each test year and forecast that year | 11 |
| `naive_forecast()` | lesson | the benchmark: recruits per spawner as in the previous four brood years | 11 |
| `score_forecasts()` | lesson | bias, mean absolute error, 80% coverage and skill against the benchmark | 11 |
| `rename()` | dplyr | rename the columns of your own data | 12 |
| `obj$env$parList()` | RTMB | the estimates as a list shaped like the starting values, to refit from them | [Troubleshooting](troubleshooting.md) |
