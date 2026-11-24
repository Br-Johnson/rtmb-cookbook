---
title: 'Troubleshooting'
---

Read an error message from the bottom up.
Find the symptom below; every message here was produced by the lesson's own code.

Most problems show up in the four checks (`m$checks`, taught in [Fitting a Model and Checking the Fit](../episodes/04-fit-and-check.Rmd)) or as an error when you build or fit a model.
In the table, `m` is any fitted model, and the quoted messages, such as "X-convergence (3)", are in `m$opt$message`.

## Symptoms, Causes and Fixes

Table: Symptoms, their likely causes and fixes. Each row was reproduced with the lesson's own code and data.

| What you see | Likely cause | Fix |
|:---|:---|:---|
| `object 'stock' not found` from `filter()`, or `could not find function "%>%"` | dplyr is not loaded, so R's own `filter()` runs | run `library(dplyr)`, or the episode's Starting Point chunk |
| `could not find function "fit_model"` (or another lesson function) | the recipe box is not loaded | run `source("files/cookbook.R")` or your `my-recipes.R`; if R cannot open the file, download it into `files/` (the [Setup](setup.md) page lists the files) |
| `cannot open file 'sockeye.csv': No such file or directory` | wrong working directory or path | open the project; use `data/sockeye.csv` |
| `object 'log_alpha' not found` (or another parameter name) | `getAll(par, dat)` is missing | make it the first line of the function |
| `object 'log_S_max' not found` | a name differs between the function and `par` or `dat` | compare the names letter by letter |
| `Comparison is generally unsafe for AD types` | `if()` on a parameter | remove it; write a separate model function for each case |
| `The negative log-likelihood is not a finite number at the starting values.` | a missing value in the data, a log of zero, or a standard deviation on the natural scale started at 0 | remove rows with `NA`; check whether each zero is real: log(R/S) cannot use zero recruits, so remove a row only if it is an error, and give real zeros a score line that allows them ([Likelihoods](../episodes/03-likelihoods.Rmd), In Your Field) instead of adding a constant; estimate SDs as `log_...`; take starting values from the data |
| `NA/NaN gradient evaluation` (when calling `nlminb()` directly) | as above | as above |
| checks `TRUE FALSE FALSE FALSE`, `m$opt$objective` is `-Inf`, "X-convergence (3)" | the function returns the log-likelihood | put a minus sign in front of `sum()` |
| all four checks FALSE, "function evaluation limit reached without convergence (9)" | `log = TRUE` missing in `dnorm()` | add it |
| all four checks FALSE, "false convergence (8)", a very negative `m$opt$objective`, dozens of parameters | `random =` missing | add `random = "<name of the random effects>"` |
| `finished` and `flat` TRUE, `finite_se` FALSE (`curved` either), standard errors `NaN` | two parameters that the data cannot tell apart | remove one of them |
| only `flat` FALSE (largest gradient a little above 0.001) | the optimiser stopped a little short of the bottom | refit from the estimates: `fit_model(m$nll, m$obj$env$parList(m$opt$par), m$dat, m$random)`; the negative log-likelihood should stay the same or fall very slightly, and all four checks should now be TRUE |
| `'*this' is not a valid 'advector' (constructed using illegal operation?)` | a random-effect vector is too short (the random walk needs `max(year) + 1` values) | use `start_walk()` |
| `Some 'random' effect names does not match 'parameter' list` | a typo in `random =` | copy the name from the starting values |
| `attempt to select less than one element in get1index` from `osa_residuals()`; `simulate()` returns `list()` | `OBS()` missing | add `logRS <- OBS(logRS)` |
| `no 'dimnames' attribute for array` from `predict_recruits()`, with the warning `no or empty summary selected` | the model has no `ADREPORT(mu_new)` | add `mu_new` and `ADREPORT(mu_new)` |
| `class='advector'` printed while fitting | `print()` inside the function | remove it; look at results after fitting |
| `AIC can only compare models fitted to the same rows` | models fitted to different years | refit every model to the same rows |
| results change after you edit `dat` | a model built with raw calls reads `dat` from your workspace | use `fit_model()`; refit after changing the data |
| an SD near zero, `ci_table()` interval 0 to `Inf`, AIC = simpler model + 2 | no detectable variation | not an error: [Random Effects](../episodes/06-random-effects.Rmd), "Check an SD Near Zero" |
| warning `NA/NaN function evaluation`, but all four checks TRUE | the optimiser tried an impossible value on the way | harmless when all four checks pass |

If a check fails and no row matches, work down the checklist in the section "When a Check Fails" of [Fitting a Model and Checking the Fit](../episodes/04-fit-and-check.Rmd):

1. Is `obj$fn(obj$par)` a finite number? (`fit_model()` stops if not.)
2. Look at the data: missing values, zeros, units.
3. Are positive parameters on the log scale?
4. Do the starting values come from the data?
5. Simplify: remove a parameter the data cannot inform.

## Asking for Help

If none of this solves the problem, ask for help with a minimal example: the smallest piece of code that still shows the problem.

1. Make the data list as small as you can. If you may not share your data, simulate a few rows that show the same problem.
2. Include the data list, the model function, the starting values and the call that fails.
3. Run it in a fresh R session to make sure it shows the problem on its own.
4. Add the output of `m$checks` (if the fit runs) and of `sessionInfo()`, which lists your R and package versions.

Ask your instructor or a colleague first.
Ask questions about RTMB itself in the [TMB users discussion group](https://groups.google.com/g/tmb-users).
Report bugs in RTMB on the [RTMB issue tracker on GitHub](https://github.com/kaskr/RTMB/issues).
