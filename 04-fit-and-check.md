---
title: "Fitting a Model and Checking the Fit"
teaching: 30
exercises: 25
---

:::::::::::::::::::::::::::::::::::::::: questions

- How do I fit a model, and how do I know the fit worked?
- What should I do when a check fails?

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: objectives

- Fit any model in the lesson with `fit_model()`.
- Use the four checks to tell whether a fit can be used.
- Identify the cause of a failed fit from its checks or error message, using the troubleshooting table.

::::::::::::::::::::::::::::::::::::::::::::::::::



## Starting Point

This episode opens steps 3 and 4 of the [Quick Start](02-quick-start.Rmd): fitting and checking.

:::::::::::::::::::::::::::::::::::::::: prereq

### Run This Only If You Are Starting Here

If you have followed along in `stellako.R`, you already have these objects: skip this chunk.
If you are starting here or have restarted R, run this chunk first.
It needs `data/sockeye.csv` and `files/cookbook.R` in your project (see [Setup](../learners/setup.md)).


``` r
library(RTMB)
library(dplyr)
library(ggplot2)
source("files/cookbook.R")        # the finished recipe box (your my-recipes.R works too)
sockeye  <- read.csv("data/sockeye.csv")
my_stock <- filter(sockeye, stock == "Stellako")
dat      <- make_dat(my_stock, S_new = 50)
```

::::::::::::::::::::::::::::::::::::::::::::::::::

## What Fitting Does

Fitting a model means finding the parameter values that make the [negative log-likelihood](../learners/reference.md#glossary), the surprise score of Episode 3, as small as possible.
As in step 4 of the Quick Start, picture the score as the height of the ground in a valley.
Each spot in the valley is one set of parameter values, and the lowest spot is the best fit.

The [optimiser](../learners/reference.md#glossary), `nlminb()`, is a hiker in fog.
It cannot see the bottom of the valley.
It can only feel the slope of the ground under its feet, and it walks downhill until the ground is level.
`obj$fn()` gives the height of the ground at any spot, and `obj$gr()` gives the exact slope there; statisticians call this slope the [gradient](../learners/reference.md#glossary).

Here are the three calls from step 3 of the Quick Start, with the [starting values](../learners/reference.md#glossary) from Episode 3:


``` r
obj <- MakeADFun(function(p) nll_ricker(p, dat), start_ricker(dat), silent = TRUE)
opt <- nlminb(obj$par, obj$fn, obj$gr)
sdr <- sdreport(obj)
opt[c("par", "objective", "convergence", "iterations", "message")]
```

``` output
$par
 log_alpha   log_Smax  log_sigma 
 2.3797073  4.8081068 -0.1199054 

$objective
[1] 96.12848

$convergence
[1] 0

$iterations
[1] 14

$message
[1] "relative convergence (4)"
```

The output of `nlminb()` is a list.
Read it one element at a time:

- `par` holds the best values the hiker found, on the [log scale](../learners/reference.md#glossary): `log_alpha` 2.38, `log_Smax` 4.81 and `log_sigma` -0.12.
  Episode 5 turns them into estimates with units and intervals.
- `objective` is the negative log-likelihood at those values: 96.1, down from 144.8 at the starting values (Episode 3).
- `convergence` is 0, which means the optimiser stopped normally.
  It does not tell you whether it stopped in a good place.
- `iterations` is the number of steps downhill: 14.
- `message` says why the hiker stopped: "relative convergence (4)" means further steps would make the score smaller by only a negligible amount.

`sdreport()` then measures how sharply the ground curves at the bottom.
A narrow, steep bowl means the data pin the parameters down, and gives small [standard errors](../learners/reference.md#glossary); a wide, shallow bowl gives large ones.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

In a workshop, skip the optional spoilers "How RTMB Gets Exact Slopes" (below) and "Why Restart Once?"; learners can read them later.
Show the data-copy spoiler from the page without typing it: it answers misconception M11, that changing `dat` after a fit is harmless.
If your learners rarely write functions, type `fit_model()` in two passes: first the three calls and a list of `obj`, `opt` and `sdr`, which you run; then the safety steps and the recipe items, naming each one as you add it.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: spoiler

### How RTMB Gets Exact Slopes (optional)

RTMB records your calculation once and works out exact slopes from the recording.
This is called [automatic differentiation](../learners/reference.md#glossary).
It is why RTMB is fast, and why your function must not use `if()` on a parameter: the recording follows one path only, and RTMB stops with the error `Comparison is generally unsafe for AD types`.
To switch between models, write a separate function for each.

::::::::::::::::::::::::::::::::::::::::::::::::::

## Recipe: Fit Any Model

**Use it when:** you fit any model, from now on.

**Ingredients:** a negative log-likelihood function, starting values, a [data list](../learners/reference.md#glossary), and the names of any [random effects](../learners/reference.md#glossary).

`fit_model()` packages the three calls you already know into one function.
If you ran the Starting Point chunk, it is already loaded from `cookbook.R`; type it anyway, so that you know what it does.


``` r
fit_model <- function(nll, par, dat, random = NULL) {
  obj <- MakeADFun(function(p) nll(p, dat), par, random = random, silent = TRUE)
  if (!is.finite(obj$fn(obj$par)))
    stop("The negative log-likelihood is not a finite number at the starting values.")
  control <- list(eval.max = 10000, iter.max = 10000)
  opt <- nlminb(obj$par, obj$fn, obj$gr, control = control)
  opt <- nlminb(opt$par, obj$fn, obj$gr, control = control)   # restart once where it stopped
  sdr <- sdreport(obj)
  list(obj = obj, opt = opt, sdr = sdr, checks = check_fit(opt, sdr),
       nll = nll, par = par, dat = dat, random = random)       # the recipe, kept for refits
}
```

These are the three calls from the Quick Start, plus four safety steps:

- it stops with a clear message if the negative log-likelihood is not a finite number (for example `NA` or `Inf`) at the starting values;
- it allows the optimiser more steps (10 000 instead of the default 200 evaluations and 150 iterations);
- it restarts the optimiser once, from where it stopped;
- it keeps the data and the recipe (the function, starting values and random effects), so that results computed after fitting use the data the model was fitted to, and later refits (Episodes 8 and 11) reuse the same recipe.

Its last line runs `check_fit()`, which you typed in step 4 of the Quick Start, to get the [four checks](../learners/reference.md#glossary); the next section explains them.
Here it is again.
You do not need to type it a second time, but copy it and run it, so that `fit_model()` can find it even if you have restarted R since the Quick Start:


``` r
check_fit <- function(opt, sdr) {
  c(finished  = opt$convergence == 0,                         # the optimiser stopped normally
    flat      = max(abs(sdr$gradient.fixed)) < 0.001,         # the ground is level
    curved    = sdr$pdHess,                                   # the bottom is a bowl
    finite_se = all(is.finite(summary(sdr, "fixed")[, "Std. Error"])))  # every SE is a number
}
```

Now fit the Ricker model with `fit_model()`:


``` r
ricker <- fit_model(nll_ricker, start_ricker(dat), dat)
ricker$checks
```

``` output
 finished      flat    curved finite_se 
     TRUE      TRUE      TRUE      TRUE 
```

``` r
names(ricker)
```

``` output
[1] "obj"    "opt"    "sdr"    "checks" "nll"    "par"    "dat"    "random"
```

`ricker` is a fitted model: a list that holds the three RTMB objects (`obj`, `opt` and `sdr`), the four checks, and the recipe it was fitted with.
From now on, every model in the lesson is fitted this way.

**Check it worked:** `ricker$checks` shows four TRUE. Put up a green sticky note when it does.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

Ask for sticky notes when `ricker$checks` shows four TRUE.
If a learner's own `fit_model()` gives an error, rerunning the Starting Point chunk loads the version in `cookbook.R`; fix their copy at the break.
Then ask for a show of hands on the prediction below before you run `rbind()` (1 minute).
Across all 19 stocks, a single `nlminb()` call already passes every check for these models, so the restart is insurance for larger models and learners' own data, not a fix for these data.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

`fit_model()` runs `nlminb()` twice.
Will its estimates differ from `opt$par`, which the three calls found at the start of this episode?
Write down your prediction, then run:


``` r
rbind(three_calls = opt$par, fit_model = ricker$opt$par)
```

``` output
            log_alpha log_Smax  log_sigma
three_calls  2.379707 4.808107 -0.1199054
fit_model    2.379707 4.808107 -0.1199054
```

The two rows are identical.
For these data, one run of `nlminb()` already reached the bottom, so the restart found nothing to improve.

:::::::::::::::::::::::::::::::::::::::: spoiler

### Why Restart Once? (optional)

`nlminb()` sometimes stops a little short of the bottom in larger models.
Starting it again from where it stopped costs little: a few milliseconds for the models in this lesson.
For every single-stock fit in this lesson, one run was already enough.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: spoiler

### Why `fit_model()` Keeps Its Own Copy of the Data (optional)

RTMB reruns your R function after fitting when it computes reported quantities such as `mu_new` (and their standard errors), residuals and simulations.
A model built with the raw calls reads `dat` from your workspace each time, so editing `dat` after fitting changes those results without any warning.
This chunk changes `S_new` after a fit made with the raw calls:


``` r
dat_demo <- dat
obj_demo <- MakeADFun(function(p) nll_ricker(p, dat_demo), start_ricker(dat_demo), silent = TRUE)
opt_demo <- nlminb(obj_demo$par, obj_demo$fn, obj_demo$gr)
dat_demo$S_new <- 150                    # change the data after fitting
summary(sdreport(obj_demo), "report")    # mu_new now silently uses S_new = 150
```

``` output
       Estimate Std. Error
mu_new 1.155212  0.2328307
```

``` r
summary(ricker$sdr, "report")            # fit_model() kept its copy: S_new = 50
```

``` output
       Estimate Std. Error
mu_new 1.971542  0.1035622
```

The forecast `mu_new` from the raw calls is now 1.16, the value for 150 thousand spawners, although the model was fitted when `S_new` was 50.
The fitted model from `fit_model()` still gives 1.97, the value for 50 thousand spawners.
`fit_model()` gives each model its own copy of the data; to change the data, fit the model again.

::::::::::::::::::::::::::::::::::::::::::::::::::

## The Four Checks

A fit can be used only when all four checks are TRUE.
Each line of `check_fit()` asks one question:

- `finished` reads the optimiser's `convergence` code.
- `flat` asks whether every slope (`gradient.fixed`) is close to zero where the hiker stopped.
- `curved` reads `pdHess` (short for "positive definite Hessian"), which is TRUE when the curvature at the bottom, called the [Hessian](../learners/reference.md#glossary), forms a bowl.
- `finite_se` asks whether every standard error is a number, not `NaN` (not a number) or `Inf` (infinity).

Table: The four checks, and what a failure usually means.

| Check | Question | In the picture | A failure usually means |
|---|---|---|---|
| `finished` | Did the optimiser stop normally? | the hiker stopped walking | it hit a limit or ran away: a model error (Challenge 3) or a missing `random =` |
| `flat` | Is the ground level where it stopped? | flat ground underfoot | it stopped early, or the score has no bottom (Challenge 1) |
| `curved` | Is the bottom a bowl? | one lowest spot | two parameters do one job, or the data cannot pin one down |
| `finite_se` | Can every standard error be computed? | the width of the bowl can be measured | as for `curved` |

![
Three places the hiker can stop: a bowl, a slope and a flat-bottomed trough.
](fig/valley.svg){
alt="Three sketches of a valley with a hiker. Left: a round bowl with the hiker at the single lowest point, labelled all four checks TRUE. Middle: the hiker stopped on a slope above the bottom, labelled flat FALSE. Right: a valley with a long flat floor where the hiker could stand anywhere, labelled curved or finite_se FALSE: two parameters do one job."
}

Four TRUE say that the hiker stands at the bottom of a bowl.
They cannot say whether a lower bowl exists elsewhere in the valley; starting values taken from the data make stopping in the wrong bowl less likely.

## When a Check Fails

A fit can fail without any error from R.
The next challenge shows a fit that looks finished but cannot be used.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

Make the sign error live: type `nll_sign`, fit it, and let learners read the output before you explain anything.
A mistake made in front of the room is a teaching moment.
Then ask the question below and let learners vote.
If most choose (a), they think that `convergence == 0` means a usable fit (misconception M2): show `m_sign$opt$par`, ask what S_max would be, and repeat that code 0 only says the optimiser stopped.
If answers are spread out, go back to the valley picture and the four checks.
The demonstration and the vote take about 5 minutes.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 1: Is This Fit Usable? (3 minutes)

Someone wrote this model and fitted it to the Stellako data:

```r
nll_sign <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha - S / exp(log_Smax)
  sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}
m_sign <- fit_model(nll_sign, start_ricker(dat), dat)
m_sign$opt[c("objective", "convergence", "message")]
m_sign$checks
```

R printed two warnings, `NA/NaN function evaluation`, and then:


``` output
$objective
[1] -Inf

$convergence
[1] 0

$message
[1] "X-convergence (3)"
```

``` output
 finished      flat    curved finite_se 
     TRUE     FALSE     FALSE     FALSE 
```

Is this fit usable?

- **(a)** Yes: convergence is 0.
- **(b)** No: three of the four checks fail.
- **(c)** Yes, if the estimates look reasonable.
- **(d)** No, because the message is not "relative convergence".

:::::::::::::::::::::::: solution

The answer is (b).


``` r
nll_sign <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha - S / exp(log_Smax)
  sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))   # minus sign missing
}
m_sign <- fit_model(nll_sign, start_ricker(dat), dat)
```

``` warning
Warning in nlminb(obj$par, obj$fn, obj$gr, control = control): NA/NaN function
evaluation
```

``` warning
Warning in nlminb(opt$par, obj$fn, obj$gr, control = control): NA/NaN function
evaluation
```

``` r
m_sign$opt[c("objective", "convergence", "message")]
```

``` output
$objective
[1] -Inf

$convergence
[1] 0

$message
[1] "X-convergence (3)"
```

``` r
m_sign$checks
```

``` output
 finished      flat    curved finite_se 
     TRUE     FALSE     FALSE     FALSE 
```

``` r
m_sign$opt$par
```

``` output
   log_alpha     log_Smax    log_sigma 
   0.7471605 -176.0607325 -180.3133672 
```

The two warnings, `NA/NaN function evaluation`, come from the two runs of `nlminb()`: the optimiser tried values where the score could not be computed.

- **(a)** is the most common mistake: convergence code 0 only says that the optimiser stopped, not that it stopped at a sensible bottom.
- **(b)** is right.
  The cause is the missing minus sign: the function returns the log-likelihood, and the optimiser makes it as small as possible, so it runs off to minus infinity.
  The ground is not flat there, and there is no bowl.
- **(c)** is wrong twice.
  The estimates are absurd: `log_Smax` is about -176, so S_max would be exp(-176) thousand spawners, far less than one fish.
  (The exact value depends on your computer, because this score has no bottom; it is always a huge negative number.)
  And judging estimates by eye is not a test; the four checks are.
- **(d)** is the right verdict for the wrong reason.
  The wording of the message is not the test: usable fits can also stop with other messages.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: caution

### Convergence Code 0 Is Not Enough

`opt$convergence` can be 0 for a fit that is useless, as in Challenge 1.
Use all four checks.

::::::::::::::::::::::::::::::::::::::::::::::::::

Whether a check fails or `fit_model()` stops with an error, first look up the pattern of checks and messages in the [Troubleshooting](../learners/troubleshooting.md) table.
It lists the mistakes in the code, such as a missing minus sign, a missing `log = TRUE` or a missing `random =`, and the pattern each one leaves.
If no row matches, work down these five questions; they find problems in the data, the scales and the starting values.

:::::::::::::::::::::::::::::::::::::::: checklist

### When a Check Fails, Work Down This List

1. Is `obj$fn(obj$par)` a finite number? (`fit_model()` stops if not.)
2. Look at the data: missing values, zeros, units.
3. Are positive parameters on the log scale?
4. Do the starting values come from the data?
5. Simplify: remove a parameter the data cannot inform.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 2: Diagnose Three Fits (8 minutes)

Here are the outputs of three failed fits, all to the Stellako data (74 brood years).
Match each output to its cause, using the table of the four checks above and the [Troubleshooting](../learners/troubleshooting.md) page.
Two causes are not used.

1. `log = TRUE` missing in `dnorm()`.
2. `random =` missing in a model with random effects.
3. Two parameters that do the same job.
4. A missing value (`NA`) in the data.
5. The minus sign missing.

Output A shows `m$checks`, `m$opt$message` and the number of estimated parameters, `length(m$opt$par)`:


``` output
 finished      flat    curved finite_se 
    FALSE     FALSE     FALSE     FALSE 
```

``` output
[1] "false convergence (8)"
```

``` output
[1] 79
```

Output B shows `m$checks` and `summary(m$sdr, "fixed")`:


``` output
 finished      flat    curved finite_se 
     TRUE      TRUE     FALSE     FALSE 
```

``` output
            Estimate Std. Error
log_alpha  2.1576015        NaN
log_Smax   4.8081069        NaN
log_sigma -0.1199050        NaN
log_extra  0.2221058        NaN
```

Output C is an error:


``` error
Error in `fit_model()`:
! The negative log-likelihood is not a finite number at the starting values.
```

:::::::::::::::::::::::: hint

Count the parameters in Output A.
The Ricker has three.
The random walk from step 7 of the Quick Start has four fixed parameters; its 75 yearly productivities are kept out of `opt$par` only when they are named in `random =`.

:::::::::::::::::::::::::

:::::::::::::::::::::::: solution

A matches 2, B matches 3 and C matches 4.

**A: `random =` missing.**
The random-walk model from the Quick Start, fitted without `random = "log_alpha_year"`, estimates all 75 yearly productivities as ordinary [fixed parameters](../learners/reference.md#glossary): 79 parameters in all.
(`start_walk()` comes from `cookbook.R`; Episode 6 teaches it.
Episode 3 did not load `cookbook.R`, so if R cannot find `start_walk()` or `nll_walk`, run `source("files/cookbook.R")` first.)


``` r
m_a <- fit_model(nll_walk, start_walk(dat), dat)
m_a$checks
```

``` output
 finished      flat    curved finite_se 
    FALSE     FALSE     FALSE     FALSE 
```

``` r
m_a$opt$message
```

``` output
[1] "false convergence (8)"
```

``` r
length(m_a$opt$par)
```

``` output
[1] 79
```

``` r
range(m_a$opt$par[-(1:4)])          # the 75 yearly values: lowest and highest
```

``` output
[1] 2.114435 2.114435
```

``` r
exp(m_a$opt$par[["log_sd_walk"]])   # sd_walk, the size of the yearly steps
```

``` output
[1] 6.231478e-15
```

``` r
m_a$opt$objective
```

``` output
[1] -1950.661
```

Without `random =`, the optimiser chooses every yearly value itself.
It makes all 75 of them the same (about 2.1 on the log scale), so every yearly step is zero, and then shrinks the size of the steps towards zero: sd_walk collapses to about 6e-15 and the score runs down to -1951.
The score has no bottom, so all four checks fail; the exact numbers depend on your computer, because the optimiser stops wherever it gives up.
The 79 parameters are the clue: the random walk has four fixed parameters, so a correct fit reports four.
The fix is to name the random effects:


``` r
m_a_fixed <- fit_model(nll_walk, start_walk(dat), dat, random = "log_alpha_year")
m_a_fixed$checks
```

``` output
 finished      flat    curved finite_se 
     TRUE      TRUE      TRUE      TRUE 
```

``` r
length(m_a_fixed$opt$par)
```

``` output
[1] 4
```

**B: two parameters that do the same job.**


``` r
nll_two <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha + log_extra - S / exp(log_Smax)     # two parameters doing one job
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}
m_b <- fit_model(nll_two, c(start_ricker(dat), list(log_extra = 0)), dat)
m_b$checks
```

``` output
 finished      flat    curved finite_se 
     TRUE      TRUE     FALSE     FALSE 
```

``` r
summary(m_b$sdr, "fixed")
```

``` output
            Estimate Std. Error
log_alpha  2.1576015        NaN
log_Smax   4.8081069        NaN
log_sigma -0.1199050        NaN
log_extra  0.2221058        NaN
```

`log_alpha` and `log_extra` add up to 2.38, the Ricker's `log_alpha`, but the data can only tell their sum.
Any split between them fits equally well: the valley has a long flat floor, so the standard errors cannot be computed.
`curved` is FALSE here, but in fits like this it can also come out TRUE, depending on the computer: trust `finite_se`.
The fix is to remove `log_extra`: the model is then the Ricker, which passes all four checks (`ricker$checks` above).

**C: a missing value in the data.**


``` r
dat_na <- dat
dat_na$logRS[5] <- NA
fit_model(nll_ricker, start_ricker(dat_na), dat_na)
```

``` error
Error in `fit_model()`:
! The negative log-likelihood is not a finite number at the starting values.
```

One `NA` in `logRS` makes the whole score `NA`, so `fit_model()` stops before the optimiser starts.
The fix is to remove the rows with missing values from the data frame before `make_dat()`, for example with `filter(my_stock, !is.na(spawners), !is.na(recruits))`.

The unused causes: a missing minus sign (5) gives `TRUE FALSE FALSE FALSE` and a score of `-Inf`, as in Challenge 1.
A missing `log = TRUE` (1) also gives four FALSE, but with a different message and only three parameters; you will meet it in Challenge 3.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

Give learners 5 minutes alone, then 3 minutes to compare answers with a neighbour.
If many match A with cause 1 (`log = TRUE` missing), point at the 79: the number of estimated parameters is the clue that the random effects were not declared.
Cause 3 is the hardest to picture; draw the flat-bottomed trough from the figure.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

## Reading Error Messages

When R stops with an error, read the message from the bottom up.
The last line says what went wrong: look it up in the table below.
The first line usually says where R stopped, for example `Error in fit_model(nll_ricker, start_ricker(dat_na), dat_na) :` for Output C of Challenge 2.
An error inside your model function starts with `Error in nll(p, dat) :`, because `nll` is the name `fit_model()` gives your function.
(This page, and some editors, show errors in a slightly different layout.)

Most problems with fitting come from a small set of mistakes in the model function.
The table lists the five most common (`m` is any fitted model); the [Troubleshooting](../learners/troubleshooting.md) page lists every message this lesson produces.

:::::::::::::::::::::::::::::::::::::::: caution

### Common Problems: Fit Any Model

Table: The five most common problems when fitting a model.

| What you see | Likely cause | Fix |
|---|---|---|
| `object 'logRS' not found` or `object 'log_alpha' not found` (a name from `dat` or `par`) | `getAll(par, dat)` is missing | make it the first line of the function |
| `object 'log_S_max' not found` | a name differs between the function and `par` or `dat` | compare the names letter by letter |
| `Comparison is generally unsafe for AD types` | `if()` on a parameter | remove it; write a separate model function for each case |
| checks `TRUE FALSE FALSE FALSE`, `m$opt$objective` is `-Inf`, "X-convergence (3)" | the function returns the log-likelihood | put a minus sign in front of `sum()` |
| all four checks FALSE, "function evaluation limit reached without convergence (9)" | `log = TRUE` missing in `dnorm()` | add it |

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 3: Find the Bug (6 minutes)

This model was fitted to the Stellako data:

```r
nll_nolog <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha - S / exp(log_Smax)
  -sum(dnorm(logRS, mu, exp(log_sigma)))
}
m_nolog <- fit_model(nll_nolog, start_ricker(dat), dat)
m_nolog$opt$message
m_nolog$opt$par
m_nolog$checks
```

R printed `There were 50 or more warnings (use warnings() to see the first 50)`, and then:


``` output
[1] "function evaluation limit reached without convergence (9)"
```

``` output
  log_alpha    log_Smax   log_sigma 
   2.398421    5.466528 -666.201828 
```

``` output
 finished      flat    curved finite_se 
    FALSE     FALSE     FALSE     FALSE 
```

Use the table above to find the likely cause.
Which line is wrong?
Copy the code from this page rather than typing it, then fix the function and refit.

:::::::::::::::::::::::: solution

The last line is wrong: `log = TRUE` is missing in `dnorm()`.
This chunk reruns the broken fit; `suppressWarnings()` hides its 10 000 copies of the warning `NA/NaN function evaluation`.
We hide the warnings only to keep this page short; in your own work, read them.


``` r
nll_nolog <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha - S / exp(log_Smax)
  -sum(dnorm(logRS, mu, exp(log_sigma)))
}
m_nolog <- suppressWarnings(fit_model(nll_nolog, start_ricker(dat), dat))
m_nolog$opt$message
```

``` output
[1] "function evaluation limit reached without convergence (9)"
```

``` r
m_nolog$opt$par
```

``` output
  log_alpha    log_Smax   log_sigma 
   2.398421    5.466528 -666.201828 
```

``` r
m_nolog$checks
```

``` output
 finished      flat    curved finite_se 
    FALSE     FALSE     FALSE     FALSE 
```

Without `log = TRUE`, `dnorm()` returns densities, and the function adds them up instead of adding log-densities.
When the curve passes through one point exactly, that point's density grows without limit as sigma shrinks towards zero, so the score has no bottom.
The first run of `nlminb()` walked downhill until `log_sigma` reached -666 (the exact value depends on your computer), and stopped there.
The restart then tried 10 000 times to take one more step, but the score could not be computed at any of the new values it tried, so nearly every try printed a warning.
It stopped at its limit of 10 000 evaluations without moving, so `finished` is FALSE.

Add `log = TRUE` and refit:


``` r
nll_fixed <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha - S / exp(log_Smax)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))   # log = TRUE added
}
m_fixed <- fit_model(nll_fixed, start_ricker(dat), dat)
m_fixed$checks
```

``` output
 finished      flat    curved finite_se 
     TRUE      TRUE      TRUE      TRUE 
```

``` r
m_fixed$opt$par
```

``` output
 log_alpha   log_Smax  log_sigma 
 2.3797073  4.8081068 -0.1199054 
```

All four checks are TRUE, and the estimates are the Ricker's: 2.38, 4.81 and -0.12.

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: challenge

### Challenge 4: Your Turn: Upper Pitt River, Row 2 (8 minutes)

Fit the Ricker model to Upper Pitt River with `fit_model()`.
Use the names `pitt`, `dat_pitt` and `ricker_pitt`, so that the Stellako objects stay as they are.
Add the code to `upper-pitt-river.R` and record its checks in row 2 of your report card, as a comment line under it.
Put up a green sticky note when `ricker_pitt$checks` shows four TRUE.

:::::::::::::::::::::::: hint

`pitt` and `dat_pitt` are in `upper-pitt-river.R` from Episode 3 (Challenge 5); if they are not in your workspace, run the script from the top.
Then copy the line that fitted `ricker` above, `ricker <- fit_model(nll_ricker, start_ricker(dat), dat)`, and change `ricker` to `ricker_pitt` and each `dat` to `dat_pitt`.

:::::::::::::::::::::::::

:::::::::::::::::::::::: solution


``` r
pitt        <- filter(sockeye, stock == "Upper Pitt River")
dat_pitt    <- make_dat(pitt, S_new = mean(tail(pitt$spawners, 4)))
ricker_pitt <- fit_model(nll_ricker, start_ricker(dat_pitt), dat_pitt)
ricker_pitt$checks
```

``` output
 finished      flat    curved finite_se 
     TRUE      TRUE      TRUE      TRUE 
```

All four checks are TRUE, so the fit can be used.

Row 2: "Ricker: all four checks TRUE." (Other models are added in Episodes 6 and 9.)
In `upper-pitt-river.R`, add the two `ricker_pitt` lines (the first two lines of the chunk are already there from Episode 3), then the row comment `# Row 2 (fits usable): Ricker: all four checks TRUE.`

:::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: instructor

Check that learners named the fit `ricker_pitt`.
Anyone who overwrote `ricker` should run `ricker <- fit_model(nll_ricker, start_ricker(dat), dat)` again before Episode 5, which uses the Stellako fit.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: callout

### Add to Your Recipe Box

Copy these functions into your `my-recipes.R`: `fit_model()`, and `check_fit()` from the Quick Start, which `fit_model()` uses.
The finished box is [cookbook.R](files/cookbook.R).

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: callout

### In Your Field

The four checks apply to any model fitted by maximum likelihood.
glmmTMB and TMB report the same quantities: convergence, the gradient, whether the Hessian is positive definite (the `curved` check), and the standard errors.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: keypoints

- `fit_model()` builds a model with `MakeADFun()`, fits it with `nlminb()` (restarting once), computes standard errors with `sdreport()`, and keeps the data and recipe it used.
- A fit can be used only when all four checks are TRUE: finished, flat, curved and finite_se.
- `convergence == 0` on its own is not evidence of a usable fit.
- When a check fails or R stops, look up the symptom in the troubleshooting table; if no row matches, work through the list: a finite start, the data, the log scale for positive parameters, the starting values, a simpler model.

::::::::::::::::::::::::::::::::::::::::::::::::::
