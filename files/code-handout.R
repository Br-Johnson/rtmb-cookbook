#' ## Introduction: Salmon, Spawners and Recruits
#' 
## ----recipe-load-data, purl=TRUE----------------------------------------------
library(dplyr)
library(ggplot2)
sockeye <- read.csv("data/sockeye.csv")
head(sockeye)
distinct(sockeye, management_unit, stock) %>% count(management_unit)

#' 
## ----recipe-one-stock, purl=TRUE----------------------------------------------
my_stock <- sockeye %>%
  filter(stock == "Stellako") %>%
  mutate(logRS = log(recruits / spawners))
nrow(my_stock)
range(my_stock$logRS)

#' 
#' ### Challenge 1: What Does Zero Mean? (3 minutes)
#' 
#' In one brood year, log(R/S) = 0.
#' What happened?
#' 
#' - **(a)** No recruits were produced.
#' - **(b)** Each spawner produced one recruit: the stock exactly replaced itself.
#' - **(c)** The value is missing.
#' - **(d)** There were 1 thousand recruits.
#' 
#' ### Challenge 2: Your Turn: Upper Pitt River, Row 1 (7 minutes)
#' 
#' Make the log(R/S) against brood year plot for Upper Pitt River.
#' Call its data frame `pitt`, so that `my_stock` stays Stellako.
#' Describe in one sentence how log(R/S) changed after 2000.
#' 
#' Then start your report card.
#' In `upper-pitt-river.R`, keep the code you ran, then write row 1 under it as a comment line (starting with `#`): the first and last brood year, the number of years, and the range of spawners with units.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' Copy the recipe and the second plot, then change `"Stellako"` to `"Upper Pitt River"` and `my_stock` to `pitt`.
#' `range()` and `nrow()` give the numbers for row 1.
#' 
#' :::::::::::::::::::::::::
#' 
#' ## Quick Start: The Whole Workflow in Nine Steps
#' 
## ----qs1-data, message=FALSE, purl=TRUE---------------------------------------
library(RTMB)
library(dplyr)
library(ggplot2)

sockeye  <- read.csv("data/sockeye.csv")
my_stock <- filter(sockeye, stock == "Stellako")

dat <- list(
  S     = my_stock$spawners,                                  # spawners
  logRS = log(my_stock$recruits / my_stock$spawners),         # log(recruits per spawner)
  year  = my_stock$brood_year - min(my_stock$brood_year) + 1, # 1, 2, 3, ...
  S_new = 50                                                  # spawners for the forecast
)

#' 
## ----qs2-model, purl=TRUE-----------------------------------------------------
nll_ricker <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)                                  # these are the observations
  mu     <- log_alpha - S / exp(log_Smax)              # expected log(R/S)
  mu_new <- log_alpha - S_new / exp(log_Smax)          # ... for the forecast
  ADREPORT(mu_new)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))   # negative log-likelihood
}
par_ricker <- list(log_alpha = mean(dat$logRS),        # starting values from the data
                   log_Smax  = log(mean(dat$S)),
                   log_sigma = log(sd(dat$logRS)))

#' 
## ----qs3-fit, purl=TRUE-------------------------------------------------------
obj <- MakeADFun(function(p) nll_ricker(p, dat), par_ricker, silent = TRUE)  # build
opt <- nlminb(obj$par, obj$fn, obj$gr)                                       # fit
sdr <- sdreport(obj)                                                         # standard errors

#' 
#' ### Challenge 1: Predict the Score (2 minutes)
#' 
#' `obj$fn()` returns the negative log-likelihood for any parameter values.
#' At the starting values, `obj$par`, it is:
#' 
## ----ch1-start----------------------------------------------------------------
obj$fn(obj$par)

#' 
#' Will `opt$objective`, the value after fitting, be larger, smaller or the same?
#' Write down your prediction, then run `opt$objective`.
#' 
## ----qs4-check, purl=TRUE-----------------------------------------------------
check_fit <- function(opt, sdr) {
  c(finished  = opt$convergence == 0,                         # the optimiser stopped normally
    flat      = max(abs(sdr$gradient.fixed)) < 0.001,         # the ground is level
    curved    = sdr$pdHess,                                   # the bottom is a bowl
    finite_se = all(is.finite(summary(sdr, "fixed")[, "Std. Error"])))  # every SE is a number
}
check_fit(opt, sdr)

#' 
## ----qs5-estimates, purl=TRUE-------------------------------------------------
est <- summary(sdr, "fixed")
est
exp(est["log_Smax", "Estimate"] + c(-1.96, 0, 1.96) * est["log_Smax", "Std. Error"])

#' 
## ----qs6-residual-plot, purl=TRUE, fig.width=7, fig.height=3.5, fig.alt="Scatter plot of one-step-ahead residuals from the Ricker model against brood year for Stellako, 1948 to 2021, with a dashed line at zero. Most residuals are above zero before 1990, between about minus 0.6 and plus 1.7, and below zero after 2000, mostly between minus 2.2 and minus 0.7 after 2010. One residual, in 2005, is far below the others at about minus 4.2."----
my_stock$res_ricker <- oneStepPredict(obj, method = "fullGaussian", trace = FALSE)$residual
ggplot(my_stock, aes(x = brood_year, y = res_ricker)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_point() +
  labs(x = "Brood year", y = "One-step-ahead residual (Ricker)")

#' 
## ----qs6-lag1, purl=TRUE------------------------------------------------------
lag1 <- function(r) cor(head(r, -1), tail(r, -1))     # are neighbouring years alike?
lag1(my_stock$res_ricker)

#' 
#' ### Challenge 2: Read the Residuals (3 minutes)
#' 
#' Most residuals are above zero before 1990 and below zero after 2000.
#' What is the most likely reason?
#' 
#' - **(a)** The fit failed.
#' - **(b)** Productivity changed over time, and the model assumes it is constant.
#' - **(c)** One outlier year, 2005, pulls every residual down.
#' - **(d)** The yearly scatter, sigma, is too small.
#' 
## ----qs7-model, purl=TRUE-----------------------------------------------------
nll_walk <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  sd_walk <- exp(log_sd_walk)
  nll <- -dnorm(log_alpha_year[1], log_alpha, sd_walk, log = TRUE)       # first year
  nll <- nll - sum(dnorm(diff(log_alpha_year), 0, sd_walk, log = TRUE))  # yearly steps
  mu     <- log_alpha_year[year] - S / exp(log_Smax)
  mu_new <- log_alpha_year[max(year) + 1] - S_new / exp(log_Smax)        # next year
  ADREPORT(mu_new)
  nll - sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}

#' 
## ----qs7-fit, purl=TRUE-------------------------------------------------------
par_walk <- c(par_ricker,
              list(log_sd_walk    = log(0.1),                            # small steps
                   log_alpha_year = rep(mean(dat$logRS), max(dat$year) + 1)))
obj_walk <- MakeADFun(function(p) nll_walk(p, dat), par_walk,
                      random = "log_alpha_year", silent = TRUE)
opt_walk <- nlminb(obj_walk$par, obj_walk$fn, obj_walk$gr)
sdr_walk <- sdreport(obj_walk)
check_fit(opt_walk, sdr_walk)
my_stock$res_walk <- oneStepPredict(obj_walk, method = "fullGaussian", trace = FALSE)$residual
lag1(my_stock$res_walk)

#' 
#' ### Challenge 3: Predict the Winner (2 minutes)
#' 
#' The random walk has one more fixed parameter, which adds 2 to its AIC.
#' But its residuals suggest that it describes the drift that the Ricker misses (lag-1 correlation -0.10 against 0.25).
#' Which model do you expect to have the lower AIC?
#' Write down your prediction, then run the next chunk.
#' 
## ----qs8-aic, purl=TRUE-------------------------------------------------------
aic <- function(opt) 2 * opt$objective + 2 * length(opt$par)
c(ricker = aic(opt), walk = aic(opt_walk))

#' 
## ----qs9-forecast, purl=TRUE--------------------------------------------------
p <- summary(sdr_walk, "report")["mu_new", ]
sd_pred <- sqrt(p[["Std. Error"]]^2 + exp(opt_walk$par[["log_sigma"]])^2)   # curve + yearly noise
dat$S_new * exp(p[["Estimate"]] + qnorm(c(0.1, 0.5, 0.9)) * sd_pred)

#' 
#' ### Challenge 4: Which Forecast Would You Trust? (3 minutes)
#' 
#' Copy the three lines of QS9 and paste the copy below them.
#' In the copy, change `sdr_walk` to `sdr` and `opt_walk` to `opt`, so that it forecasts with the Ricker.
#' Also rename `p` to `p_ricker` and `sd_pred` to `sd_ricker` in the copy, so that `p` and `sd_pred` keep the random walk's forecast.
#' Run the copy.
#' How different is the forecast?
#' Which would you trust, and why?
#' Write your answer down: [Episode 11](11-forecasting.Rmd) tests it.
#' 
#' ### Challenge 5: Which Step Answers Which Question? (3 minutes)
#' 
#' Match each situation to the step (QS1 to QS9) that deals with it.
#' 
#' 1. Your fit gives standard errors of `NaN`. Which step should have warned you?
#' 2. A report needs a range of plausible values for S\_max.
#' 3. A reviewer asks whether the model missed a change in productivity over the years.
#' 4. A colleague wants to add an ocean index to the model. Which step tells you whether the data support the bigger model?
#' 5. Your manager asks how many recruits 50 thousand spawners will produce.
#' 
#' ### Challenge 6: Your Turn: Change One Word (7 minutes)
#' 
#' In QS1, replace `"Stellako"` with `"Upper Pitt River"` and run every step again.
#' 
#' - Do all checks pass?
#' - Does the random walk again lower AIC and bring the lag-1 correlation closer to zero?
#' - Write one sentence that reports S\_max for Upper Pitt River with its 95% confidence interval and units (QS5).
#' - Compare 50 thousand spawners with the average of the stock's last four brood years, `mean(tail(my_stock$spawners, 4))`, as in QS1. Is the forecast for 50 thousand spawners sensible for this stock?
#' 
#' :::::::::::::::::::::::: hint
#' 
#' Run the whole script again from the top: select all of it and run it (Ctrl+A, then Ctrl+Enter; use Cmd instead of Ctrl on a Mac), or run `source("my-quick-start.R", echo = TRUE)` with your script's name.
#' Plain `source()` runs the code but prints nothing and draws no plot.
#' This replaces the Stellako objects in your R session, so change the name back to `"Stellako"` and run the script again when you are done.
#' 
#' :::::::::::::::::::::::::
#' 
#' ## Writing a Model as a Likelihood
#' 
## ----recipe-make-dat, purl=TRUE-----------------------------------------------
make_dat <- function(df, S_new) {
  list(S     = df$spawners,                                    # spawners
       logRS = log(df$recruits / df$spawners),                 # log(recruits per spawner)
       year  = df$brood_year - min(df$brood_year) + 1,         # 1, 2, 3, ... (gaps allowed)
       S_new = S_new)                                          # spawners for a forecast
}
dat <- make_dat(my_stock, S_new = 50)
str(dat)

#' 
## ----recipe-nll-ricker, purl=TRUE---------------------------------------------
nll_ricker <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)                                  # these are the observations
  mu     <- log_alpha - S / exp(log_Smax)              # expected log(R/S)
  mu_new <- log_alpha - S_new / exp(log_Smax)          # ... for the forecast
  ADREPORT(mu_new)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))   # negative log-likelihood
}

#' 
## ----recipe-start-ricker, purl=TRUE-------------------------------------------
start_ricker <- function(dat) {
  list(log_alpha = mean(dat$logRS), log_Smax = log(mean(dat$S)), log_sigma = log(sd(dat$logRS)))
}
start_ricker(dat)
obj <- MakeADFun(function(p) nll_ricker(p, dat), start_ricker(dat), silent = TRUE)
obj$fn(obj$par)
obj$gr(obj$par)

#' 
#' ### Challenge 1: Which Guess Fits Best? (3 minutes)
#' 
#' The plot shows three guesses at the curve.
#' Which will have the smallest negative log-likelihood?
#' Write down your answer, then run the next chunk.
#' 
#' ### Challenge 2: Put the Model in Order (5 minutes)
#' 
#' Put these lines in order to make `nll_ricker`.
#' Two lines do not belong: which, and why?
#' 
#' ```r
#' -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
#' ADREPORT(mu_new)
#' nll_ricker <- function(par, dat) {
#' sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
#' mu     <- log_alpha - S / exp(log_Smax)
#' }
#' getAll(par, dat)
#' -sum(dnorm(logRS, mu, log_sigma, log = TRUE))
#' logRS <- OBS(logRS)
#' mu_new <- log_alpha - S_new / exp(log_Smax)
#' ```
#' 
#' ### Challenge 3: Write the Beverton-Holt Model (10 minutes)
#' 
#' Fill in the blanks, then check that the function returns a finite number at the starting values.
#' 
#' ```r
#' nll_bh <- function(par, dat) {
#'   getAll(par, dat)
#'   logRS <- OBS(logRS)
#'   mu     <- log_alpha - log(1 + ___ / exp(log_Shalf))
#'   mu_new <- log_alpha - log(1 + ___ / exp(log_Shalf))
#'   ADREPORT(mu_new)
#'   -sum(dnorm(___, ___, exp(log_sigma), log = TRUE))
#' }
#' start_bh <- function(dat) {
#'   list(log_alpha = mean(dat$logRS), log_Shalf = ___, log_sigma = log(sd(dat$logRS)))
#' }
#' obj_bh <- MakeADFun(function(p) nll_bh(p, dat), start_bh(dat), silent = TRUE)
#' obj_bh$fn(obj_bh$par)
#' ```
#' 
#' :::::::::::::::::::::::: hint
#' 
#' S\_half has the same units as spawners, so start it like S\_max.
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 4: Why the Log Scale? (3 minutes)
#' 
#' Why do we estimate `log_sigma` and use `exp(log_sigma)` in the model?
#' 
#' - **(a)** Sigma must be positive; on the log scale the optimiser can try any number, and `exp()` keeps sigma positive.
#' - **(b)** It makes fitting faster.
#' - **(c)** Because the data are on the log scale.
#' - **(d)** Because `dnorm()` needs a logged standard deviation.
#' 
#' ### Challenge 5: Your Turn: Upper Pitt River, Row 1 (4 minutes)
#' 
#' Make the data list for Upper Pitt River with `S_new` set to the average spawner count of its last four brood years.
#' Check that the Ricker model returns a finite number at the starting values.
#' Then add `S_new` to row 1 of your report card, in `upper-pitt-river.R`.
#' Use the names `pitt`, `dat_pitt` and `obj_pitt`, so that the Stellako objects stay as they are.
#' 
#' ## Fitting a Model and Checking the Fit
#' 
## ----recipe-fit-model, purl=TRUE----------------------------------------------
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

#' 
## ----check-fit, purl=TRUE-----------------------------------------------------
check_fit <- function(opt, sdr) {
  c(finished  = opt$convergence == 0,                         # the optimiser stopped normally
    flat      = max(abs(sdr$gradient.fixed)) < 0.001,         # the ground is level
    curved    = sdr$pdHess,                                   # the bottom is a bowl
    finite_se = all(is.finite(summary(sdr, "fixed")[, "Std. Error"])))  # every SE is a number
}

#' 
## ----fit-ricker, purl=TRUE----------------------------------------------------
ricker <- fit_model(nll_ricker, start_ricker(dat), dat)
ricker$checks
names(ricker)

#' 
#' ### Challenge 1: Is This Fit Usable? (3 minutes)
#' 
#' Someone wrote this model and fitted it to the Stellako data:
#' 
#' ```r
#' nll_sign <- function(par, dat) {
#'   getAll(par, dat)
#'   logRS <- OBS(logRS)
#'   mu <- log_alpha - S / exp(log_Smax)
#'   sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
#' }
#' m_sign <- fit_model(nll_sign, start_ricker(dat), dat)
#' m_sign$opt[c("objective", "convergence", "message")]
#' m_sign$checks
#' ```
#' 
#' R printed two warnings, `NA/NaN function evaluation`, and then:
#' 
## ----ch1-output, echo=FALSE, warning=FALSE------------------------------------
nll_sign <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha - S / exp(log_Smax)
  sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}
m_sign <- fit_model(nll_sign, start_ricker(dat), dat)
m_sign$opt[c("objective", "convergence", "message")]
m_sign$checks

#' 
#' Is this fit usable?
#' 
#' - **(a)** Yes: convergence is 0.
#' - **(b)** No: three of the four checks fail.
#' - **(c)** Yes, if the estimates look reasonable.
#' - **(d)** No, because the message is not "relative convergence".
#' 
#' ### Challenge 2: Diagnose Three Fits (8 minutes)
#' 
#' Here are the outputs of three failed fits, all to the Stellako data (74 brood years).
#' Match each output to its cause, using the table of the four checks above and the [Troubleshooting](../learners/troubleshooting.md) page.
#' Two causes are not used.
#' 
#' 1. `log = TRUE` missing in `dnorm()`.
#' 2. `random =` missing in a model with random effects.
#' 3. Two parameters that do the same job.
#' 4. A missing value (`NA`) in the data.
#' 5. The minus sign missing.
#' 
#' Output A shows `m$checks`, `m$opt$message` and the number of estimated parameters, `length(m$opt$par)`:
#' 
## ----ch2-output-a, echo=FALSE-------------------------------------------------
m_a <- fit_model(nll_walk, start_walk(dat), dat)
m_a$checks
m_a$opt$message
length(m_a$opt$par)

#' 
#' Output B shows `m$checks` and `summary(m$sdr, "fixed")`:
#' 
## ----ch2-output-b, echo=FALSE-------------------------------------------------
nll_two <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha + log_extra - S / exp(log_Smax)     # two parameters doing one job
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}
m_b <- fit_model(nll_two, c(start_ricker(dat), list(log_extra = 0)), dat)
m_b$checks
summary(m_b$sdr, "fixed")

#' 
#' Output C is an error:
#' 
## ----ch2-output-c, echo=FALSE, error=TRUE-------------------------------------
try({
dat_na <- dat
dat_na$logRS[5] <- NA
fit_model(nll_ricker, start_ricker(dat_na), dat_na)
})

#' 
#' :::::::::::::::::::::::: hint
#' 
#' Count the parameters in Output A.
#' The Ricker has three.
#' The random walk from step 7 of the Quick Start has four fixed parameters; its 75 yearly productivities are kept out of `opt$par` only when they are named in `random =`.
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 3: Find the Bug (6 minutes)
#' 
#' This model was fitted to the Stellako data:
#' 
#' ```r
#' nll_nolog <- function(par, dat) {
#'   getAll(par, dat)
#'   logRS <- OBS(logRS)
#'   mu <- log_alpha - S / exp(log_Smax)
#'   -sum(dnorm(logRS, mu, exp(log_sigma)))
#' }
#' m_nolog <- fit_model(nll_nolog, start_ricker(dat), dat)
#' m_nolog$opt$message
#' m_nolog$opt$par
#' m_nolog$checks
#' ```
#' 
#' R printed `There were 50 or more warnings (use warnings() to see the first 50)`, and then:
#' 
## ----ch3-output, echo=FALSE---------------------------------------------------
nll_nolog <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu <- log_alpha - S / exp(log_Smax)
  -sum(dnorm(logRS, mu, exp(log_sigma)))
}
m_nolog <- suppressWarnings(fit_model(nll_nolog, start_ricker(dat), dat))
m_nolog$opt$message
m_nolog$opt$par
m_nolog$checks

#' 
#' Use the table above to find the likely cause.
#' Which line is wrong?
#' Copy the code from this page rather than typing it, then fix the function and refit.
#' 
#' ### Challenge 4: Your Turn: Upper Pitt River, Row 2 (8 minutes)
#' 
#' Fit the Ricker model to Upper Pitt River with `fit_model()`.
#' Use the names `pitt`, `dat_pitt` and `ricker_pitt`, so that the Stellako objects stay as they are.
#' Add the code to `upper-pitt-river.R` and record its checks in row 2 of your report card, as a comment line under it.
#' Put up a green sticky note when `ricker_pitt$checks` shows four TRUE.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' `pitt` and `dat_pitt` are in `upper-pitt-river.R` from Episode 3 (Challenge 5); if they are not in your workspace, run the script from the top.
#' Then copy the line that fitted `ricker` above, `ricker <- fit_model(nll_ricker, start_ricker(dat), dat)`, and change `ricker` to `ricker_pitt` and each `dat` to `dat_pitt`.
#' 
#' :::::::::::::::::::::::::
#' 
#' ## Estimates, Intervals and Derived Quantities
#' 
#' ### Challenge 1: Back to the Natural Scale (3 minutes)
#' 
#' `log_alpha` is 2.38 with standard error 0.16.
#' Which is the 95% confidence interval for alpha, in recruits per spawner?
#' 
#' - **(a)** exp(2.38) ± 1.96 × 0.16 = 10.5 to 11.1.
#' - **(b)** exp(2.38 - 0.31) to exp(2.38 + 0.31) = about 7.9 to 14.7.
#' - **(c)** 2.07 to 2.69.
#' - **(d)** 10.8 ± 1.96 × exp(0.16) = 8.5 to 13.1.
#' 
## ----recipe-ci-table, purl=TRUE-----------------------------------------------
ci_table <- function(m, select = "fixed") {
  est <- summary(m$sdr, select)
  out <- data.frame(parameter = rownames(est),
                    estimate  = est[, "Estimate"],
                    lower     = est[, "Estimate"] - 1.96 * est[, "Std. Error"],
                    upper     = est[, "Estimate"] + 1.96 * est[, "Std. Error"],
                    row.names = NULL)
  logs <- startsWith(out$parameter, "log_")
  out[logs, 2:4] <- exp(out[logs, 2:4])                       # back to the natural scale
  out$parameter[logs] <- sub("^log_", "", out$parameter[logs])
  out
}
ci_table(ricker)

#' 
## ----recipe-adreport, purl=TRUE-----------------------------------------------
nll_ricker_rmax <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu     <- log_alpha - S / exp(log_Smax)
  mu_new <- log_alpha - S_new / exp(log_Smax)
  ADREPORT(mu_new)
  log_Rmax <- log_alpha + log_Smax - 1          # most recruits: alpha * Smax / e
  ADREPORT(log_Rmax)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}
ricker_rmax <- fit_model(nll_ricker_rmax, start_ricker(dat), dat)
ci_table(ricker_rmax, "report")

#' 
#' ### Challenge 2: Where the Stock Replaces Itself (7 minutes)
#' 
#' Each spawner exactly replaces itself (log(R/S) = 0) at [S\_rep](../learners/reference.md#glossary) = log(alpha) × S\_max spawners.
#' Fill in the blanks, fit, and report S\_rep with its 95% CI.
#' Is it inside the range of spawner counts in the data (9 to 240 thousand)?
#' 
#' ```r
#' nll_ricker_srep <- function(par, dat) {
#'   getAll(par, dat)
#'   logRS <- OBS(logRS)
#'   mu     <- log_alpha - S / exp(log_Smax)
#'   mu_new <- log_alpha - S_new / exp(log_Smax)
#'   ADREPORT(mu_new)
#'   log_Srep <- log(___) + ___
#'   ADREPORT(___)
#'   -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
#' }
#' ricker_srep <- fit_model(nll_ricker_srep, start_ricker(dat), dat)
#' ci_table(ricker_srep, "report")
#' ```
#' 
#' :::::::::::::::::::::::: hint
#' 
#' On the log scale, log(S\_rep) = log(log(alpha)) + log(S\_max), and log(alpha) is `log_alpha` in the function.
#' 
#' :::::::::::::::::::::::::
#' 
## ----recipe-predict-recruits, purl=TRUE---------------------------------------
predict_recruits <- function(m, interval = "prediction", level = 0.80) {
  rep <- summary(m$sdr, "report")
  p   <- rep[rownames(rep) == "mu_new", , drop = FALSE]       # one row per value of S_new
  se  <- p[, "Std. Error"]                                    # uncertainty about the curve
  if (interval == "prediction") se <- sqrt(se^2 + exp(m$opt$par[["log_sigma"]])^2)
  z <- qnorm(1 - (1 - level) / 2)
  data.frame(S_new  = m$dat$S_new,
             median = m$dat$S_new * exp(p[, "Estimate"]),
             lower  = m$dat$S_new * exp(p[, "Estimate"] - z * se),
             upper  = m$dat$S_new * exp(p[, "Estimate"] + z * se))
}

#' 
## ----curve-band, purl=TRUE----------------------------------------------------
dat_grid <- dat
dat_grid$S_new <- seq(1, 250, by = 1)                # a grid of spawner values
ricker_grid <- fit_model(nll_ricker, start_ricker(dat_grid), dat_grid)
band <- predict_recruits(ricker_grid, interval = "confidence", level = 0.95)
filter(band, median == max(median))

#' 
## ----plot-curve-band, purl=TRUE, fig.width=6, fig.height=4, fig.cap="The fitted Ricker curve for Stellako with its 95% confidence band.", fig.alt="Scatter plot of Stellako recruits (12 to about 1900 thousand) against spawners (9 to 240 thousand), drawn as open circles, with the fitted Ricker curve and a shaded 95% confidence band. The curve rises to about 490 thousand recruits near 120 thousand spawners, then falls slowly to about 350 thousand at 250 thousand spawners. The band is narrow below 60 thousand spawners and widens to about 150 to 830 thousand at 250 thousand. Most points lie outside the band."----
ggplot(band, aes(x = S_new, y = median)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "grey80") +
  geom_line() +
  geom_point(data = my_stock, aes(x = spawners, y = recruits), shape = 1) +
  labs(x = "Spawners (thousands)", y = "Recruits (thousands)")

#' 
#' ### Challenge 3: Why Are Most Points Outside the Band? (3 minutes)
#' 
#' The 95% band contains only about a quarter of the points (24%).
#' What does this mean?
#' 
#' - **(a)** The model is wrong.
#' - **(b)** This is as it should be: the band shows uncertainty about the median curve; single years scatter around it with standard deviation sigma.
#' - **(c)** The band should be 99%.
#' - **(d)** The points outside the band are outliers.
#' 
#' ### Challenge 4: Your Turn: Upper Pitt River, Row 3 (7 minutes)
#' 
#' Make the interval table for the Upper Pitt River Ricker model, `ricker_pitt`, and write two sentences for row 3 of your report card, with units, as a comment under the code in `upper-pitt-river.R`.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' `ricker_pitt` is in `upper-pitt-river.R` from Episode 4 (Challenge 4); if it is not in your workspace, run the script from the top.
#' Without the script, fit it again with these three lines:
#' 
#' - `pitt <- filter(sockeye, stock == "Upper Pitt River")`
#' - `dat_pitt <- make_dat(pitt, S_new = mean(tail(pitt$spawners, 4)))`, where `S_new` is the average spawner count of the last four brood years
#' - `ricker_pitt <- fit_model(nll_ricker, start_ricker(dat_pitt), dat_pitt)`
#' 
#' Then make the table as you did for Stellako.
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 5 (Optional): Salmon Reference Points (not timed)
#' 
#' This challenge is for learners who work with salmon management.
#' [U\_MSY](../learners/reference.md#glossary) is the harvest rate (the share of recruits that are caught) that gives the maximum sustainable yield (MSY), and [S\_MSY](../learners/reference.md#glossary) is the spawner count that gives it.
#' Add the lines below to a copy of the Ricker model function (before the last line), fit it to Stellako, and report both.
#' Then do the same for Upper Pitt River with `dat_pitt` from Challenge 4.
#' 
#' ```r
#' U_msy <- uniroot(function(U) log(1 - U) + log_alpha - U,     # harvest rate for maximum yield
#'                  lower = 1e-8, upper = 1 - 1e-8, tol = 1e-10)$root
#' log_Smsy <- log(U_msy) + log_Smax                            # spawners for maximum yield
#' ADREPORT(U_msy)
#' ADREPORT(log_Smsy)
#' ```
#' 
#' ## Random Effects: Productivity That Changes over Time
#' 
## ----recipe-nll-walk, purl=TRUE-----------------------------------------------
nll_walk <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  sd_walk <- exp(log_sd_walk)
  nll <- -dnorm(log_alpha_year[1], log_alpha, sd_walk, log = TRUE)       # first year
  nll <- nll - sum(dnorm(diff(log_alpha_year), 0, sd_walk, log = TRUE))  # yearly steps
  mu     <- log_alpha_year[year] - S / exp(log_Smax)
  mu_new <- log_alpha_year[max(year) + 1] - S_new / exp(log_Smax)        # next year
  ADREPORT(mu_new)
  nll - sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}

#' 
## ----recipe-start-walk, purl=TRUE---------------------------------------------
start_walk <- function(dat) {
  c(start_ricker(dat),
    list(log_sd_walk = log(0.1),                                   # small yearly steps
         log_alpha_year = rep(mean(dat$logRS), max(dat$year) + 1)))  # every year + next year
}
length(start_walk(dat)$log_alpha_year)

#' 
## ----fit-walk, purl=TRUE------------------------------------------------------
walk <- fit_model(nll_walk, start_walk(dat), dat, random = "log_alpha_year")
walk$checks
ci_table(walk)

#' 
#' ### Challenge 1: What Does `random =` Mean? (3 minutes)
#' 
#' What does `random = "log_alpha_year"` tell RTMB?
#' 
#' - **(a)** Fix these values at zero.
#' - **(b)** Draw new random numbers for them every time the model runs.
#' - **(c)** Treat them as unknown values that come from a distribution: average over them, and estimate the distribution's standard deviation.
#' - **(d)** The data in those years are random.
#' 
## ----recipe-plot-productivity, purl=TRUE, fig.width=7, fig.height=3.5, fig.cap="Estimated productivity of Stellako sockeye salmon with a 95% confidence band. The dashed line is the Ricker model's constant productivity.", fig.alt="Line plot of estimated Stellako productivity, in recruits per spawner when spawners are few, against brood year, 1948 to 2022, with a shaded 95% band and a dashed horizontal line at 10.8, the constant Ricker estimate. Productivity is about 12 to 16 from 1948 to the mid-1980s, falls steeply from about 1985 to 2005, and stays near 4 from 2005 to 2022. The band is widest around 1980, about 10 to 25."----
prod <- ci_table(walk, "random")
prod$brood_year <- min(my_stock$brood_year) + seq_len(nrow(prod)) - 1
ggplot(prod, aes(x = brood_year, y = estimate)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "grey80") +
  geom_line() +
  geom_hline(yintercept = exp(ricker$opt$par[["log_alpha"]]), linetype = "dashed") +
  labs(x = "Brood year", y = "Productivity (recruits per spawner)")

#' 
#' ### Challenge 2: Find the Bug (5 minutes)
#' 
#' Someone made their own starting values for the random walk and fitted it:
#' 
#' ```r
#' par_short <- start_walk(dat)
#' par_short$log_alpha_year <- rep(mean(dat$logRS), max(dat$year))
#' fit_model(nll_walk, par_short, dat, random = "log_alpha_year")
#' ```
#' 
#' R stopped with this error:
#' 
#' ```error
#' Error:
#' ! '*this' is not a valid 'advector' (constructed using illegal operation?)
#' ```
#' 
#' What is wrong?
#' 
#' ### Challenge 3: Your Turn: Upper Pitt River, Row 4 (10 minutes)
#' 
#' Fit the random walk to Upper Pitt River.
#' Add the code to `upper-pitt-river.R`, and record its checks in row 2 of your report card.
#' In row 4, write sd\_walk in words, and productivity in 1948, 1965, 1980, 2000 and 2021.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' `pitt` and `dat_pitt` are in `upper-pitt-river.R` from Episode 3; if they are not in your workspace, run the script from the top.
#' Then copy the three lines that fitted `walk` and the plot recipe, and change `dat` to `dat_pitt`, `walk` to `walk_pitt`, `prod` to `prod_pitt` and `my_stock` to `pitt`.
#' Leave out the dashed line.
#' 
#' :::::::::::::::::::::::::
#' 
## ----harrison-walk, purl=TRUE-------------------------------------------------
harrison <- filter(sockeye, stock == "Harrison")
dat_h    <- make_dat(harrison, S_new = mean(tail(harrison$spawners, 4)))
walk_h   <- fit_model(nll_walk, start_walk(dat_h), dat_h, random = "log_alpha_year")
walk_h$checks
ci_table(walk_h) %>% filter(parameter == "sd_walk")

#' 
## ----recipe-sd-near-zero, purl=TRUE-------------------------------------------
par_tiny <- start_walk(dat_h)
par_tiny$log_sd_walk <- log(0.001)                  # start the SD near zero
walk_h_tiny <- fit_model(nll_walk, par_tiny, dat_h, random = "log_alpha_year")
ricker_h    <- fit_model(nll_ricker, start_ricker(dat_h), dat_h)
c(start_0.1 = walk_h$opt$objective, start_0.001 = walk_h_tiny$opt$objective)
c(ricker = aic(ricker_h$opt), walk = aic(walk_h$opt))

#' 
#' ### Challenge 4: A Stock That Did Not Drift (5 minutes)
#' 
#' For Harrison, all four checks are TRUE, sd\_walk is 0.000005, both starting values reach the same negative log-likelihood, and AIC is 266.36 for the random walk against 264.36 for the Ricker.
#' Which statement is best?
#' 
#' - **(a)** The fit failed.
#' - **(b)** The data show no detectable drift: the random walk has collapsed to the Ricker and pays 2 AIC units for its extra parameter.
#' - **(c)** Harrison's productivity has been exactly constant since 1948.
#' - **(d)** The optimiser needs more iterations.
#' 
#' ## Checking a Model with Residuals
#' 
## ----recipe-osa, purl=TRUE----------------------------------------------------
osa_residuals <- function(m) {
  oneStepPredict(m$obj, method = "fullGaussian", trace = FALSE)$residual
}
my_stock$res_ricker <- osa_residuals(ricker)
my_stock$res_walk   <- osa_residuals(walk)
round(c(mean = mean(my_stock$res_ricker), sd = sd(my_stock$res_ricker)), 2)
round(c(mean = mean(my_stock$res_walk), sd = sd(my_stock$res_walk)), 2)

#' 
## ----recipe-check-shape, purl=TRUE, fig.width=6, fig.height=4, fig.alt="Normal quantile-quantile plot of the Stellako Ricker one-step-ahead residuals. The points follow the straight line closely in the middle, for expected quantiles between about minus 1.3 and plus 1.3. The lowest point, at about minus 4.2 (brood year 2005), lies far below the line; the next few lowest points and the few highest points lie a little below it."----
ggplot(my_stock, aes(sample = res_ricker)) +
  stat_qq() +
  stat_qq_line() +
  labs(x = "Expected quantile (normal)", y = "One-step-ahead residual (Ricker)")

#' 
## ----recipe-check-pattern, purl=TRUE, fig.width=7, fig.height=5, fig.alt="Two panels of one-step-ahead residuals against brood year for Stellako, 1948 to 2021, each with a dashed line at zero. Top, random walk: residuals scatter around zero with no long runs. Bottom, Ricker: residuals are mostly above zero before 1990 and mostly below zero after 2000. Both panels have one point near minus 4 in 2005."----
res_long <- bind_rows(
  data.frame(model = "Ricker",      brood_year = my_stock$brood_year, residual = my_stock$res_ricker),
  data.frame(model = "Random walk", brood_year = my_stock$brood_year, residual = my_stock$res_walk))
ggplot(res_long, aes(x = brood_year, y = residual)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_point() +
  facet_wrap(~ model, ncol = 1) +
  labs(x = "Brood year", y = "One-step-ahead residual")

#' 
## ----check-pattern-spawners, purl=TRUE, fig.width=6, fig.height=4, fig.alt="Scatter plot of Stellako Ricker one-step-ahead residuals against spawners in thousands, with a dashed line at zero. Most points are below 80 thousand spawners and scatter around zero, between about minus 2.2 and plus 1.7, with no clear curve. Six of the seven points above 105 thousand spawners lie above zero. The lowest point, near minus 4.2, is at about 100 thousand spawners."----
ggplot(my_stock, aes(x = spawners, y = res_ricker)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_point() +
  labs(x = "Spawners (thousands)", y = "One-step-ahead residual (Ricker)")

#' 
## ----recipe-check-independence, purl=TRUE-------------------------------------
lag1 <- function(r) cor(head(r, -1), tail(r, -1))            # neighbouring years alike?
c(ricker = lag1(my_stock$res_ricker), walk = lag1(my_stock$res_walk),
  limit = 2 / sqrt(nrow(my_stock)))

#' 
#' ### Challenge 1: What Does the Lag-1 Correlation Say? (3 minutes)
#' 
#' The Ricker residuals have lag-1 correlation 0.25 with 74 years (limit 0.23).
#' What does this suggest?
#' 
#' - **(a)** Good years tend to follow good years: the model misses something that persists.
#' - **(b)** The residuals are not normal.
#' - **(c)** The fit failed: refit from other starting values.
#' - **(d)** The data contain an error.
#' 
#' ### Challenge 2: Your Turn: Upper Pitt River, Row 5 (14 minutes)
#' 
#' Run the three checks (shape, pattern over time and independence) for the Upper Pitt River Ricker and random-walk models.
#' Which checks does each model pass?
#' Add the code to `upper-pitt-river.R` and write row 5 of your report card under it.
#' Row 5 records these three checks; the plot against spawners is optional.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' Copy the recipe chunks in order and change three names: `my_stock` to `pitt`, `res_long` to `res_long_pitt`, and the fitted models in `osa_residuals(ricker)` and `osa_residuals(walk)` to `ricker_pitt` and `walk_pitt`.
#' If `ricker_pitt` and `walk_pitt` are not in your workspace, run `upper-pitt-river.R` from the top: it has them from Episodes 4 and 6.
#' For the random walk's QQ plot, change `res_ricker` to `res_walk` and `(Ricker)` to `(random walk)`, as you did for Stellako.
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 3: One Extreme Year (3 minutes)
#' 
#' The Stellako QQ plot has one point at -4.2: brood year 2005, when 102 thousand spawners produced 11.6 thousand recruits.
#' What should you do next?
#' 
#' - **(a)** Delete 2005 and refit.
#' - **(b)** Check the 2005 record, keep it unless it is an error, and report it.
#' - **(c)** Switch to another distribution at once.
#' - **(d)** Ignore it: one year cannot matter.
#' 
#' ## Checking a Model with Simulation
#' 
#' ### Challenge 1: Warm-Up: Put the Recipe in Order (5 minutes)
#' 
#' Put these lines in order to fit and check the [random walk](../learners/reference.md#glossary) model from scratch.
#' One line does not belong: which, and why?
#' Order the lines on paper or as comments.
#' If you run lines to test an order, run the first chunk of the solution afterwards, so that `walk` is the right model again.
#' 
#' ```r
#' walk$checks
#' walk <- fit_model(nll_walk, start_walk(dat), dat, random = "log_alpha_year")
#' my_stock <- filter(sockeye, stock == "Stellako")
#' ci_table(walk)
#' dat <- make_dat(my_stock, S_new = 50)
#' sockeye <- read.csv("data/sockeye.csv")
#' walk <- fit_model(nll_walk, start_walk(dat), dat)
#' ```
#' 
#' ### Challenge 2: Predict Before You Simulate (3 minutes)
#' 
#' The real Stellako log(R/S) has lag-1 correlation 0.40.
#' Write down your answers before you run the recipe below.
#' 
#' 1. Will any of 200 data sets simulated from the fitted Ricker have a lag-1 correlation of 0.40 or more?
#' 2. What share of 200 data sets simulated from the random walk will reach 0.40?
#'    **(a)** none; **(b)** about 10%; **(c)** about half; **(d)** nearly all.
#' 
## ----recipe-simulate-stat, purl=TRUE------------------------------------------
simulate_stat <- function(m, stat, n_sim = 200) {
  replicate(n_sim, stat(m$obj$simulate(m$obj$env$last.par.best)$logRS))
}
lag1(dat$logRS)
set.seed(2026)
sim_ricker <- simulate_stat(ricker, lag1)
sim_walk   <- simulate_stat(walk, lag1)
c(ricker = mean(sim_ricker >= lag1(dat$logRS)), walk = mean(sim_walk >= lag1(dat$logRS)))

#' 
#' ### Challenge 3: Can the Models Make a 2005? (5 minutes)
#' 
#' Brood year 2005 was Stellako's worst year, the extreme point in the residual checks of [Episode 7](07-residuals.Rmd).
#' Repeat the check with `min`, the worst year, instead of `lag1`, and find the share of simulations whose worst year is at least as low as the real one.
#' Fill in the blanks.
#' 
#' ```r
#' min(dat$logRS)
#' set.seed(2026)
#' c(ricker = mean(simulate_stat(ricker, ___) <= min(dat$logRS)),
#'   walk   = mean(simulate_stat(___, min) <= ___))
#' ```
#' 
## ----recipe-self-test, purl=TRUE----------------------------------------------
self_test <- function(m, n_sim = 50) {
  out <- NULL
  for (i in 1:n_sim) {
    dat_sim <- m$dat
    dat_sim$logRS <- m$obj$simulate(m$obj$env$last.par.best)$logRS  # new data from the fitted model
    m_sim <- fit_model(m$nll, m$par, dat_sim, m$random)             # same recipe, refitted
    est <- summary(m_sim$sdr, "fixed")
    out <- rbind(out, data.frame(sim = i, parameter = rownames(est), truth = m$opt$par,
                                 estimate = est[, "Estimate"], se = est[, "Std. Error"],
                                 fit_ok = all(m_sim$checks), row.names = NULL))
  }
  out
}

#' 
## ----run-self-test, purl=TRUE-------------------------------------------------
set.seed(2026)
st_walk <- self_test(walk, n_sim = 50)
st_walk %>%
  group_by(parameter) %>%
  summarise(truth = first(truth), median_estimate = median(estimate),
            coverage = mean(abs(estimate - truth) < 1.96 * se, na.rm = TRUE),
            fits_ok = sum(fit_ok))

#' 
#' ### Challenge 4: What Does a Coverage of 1.00 Mean? (3 minutes)
#' 
#' In the Stellako self-test, the coverage of `log_sd_walk` is 1.00: all 50 intervals caught the true value.
#' Which reading is best?
#' 
#' - **(a)** sd\_walk is estimated very precisely.
#' - **(b)** Some of the intervals are so wide that they would catch any value, so this coverage says little about how good the intervals are.
#' - **(c)** The self-test failed, because coverage should be 0.95.
#' - **(d)** Higher coverage is always better, so these are the best intervals in the table.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' Look at the sd\_walk panel of the plot, and remember Harrison's interval for sd\_walk in [Episode 6](06-random-effects.Rmd).
#' 
#' :::::::::::::::::::::::::
#' 
## ----sd-walk-collapse, purl=TRUE----------------------------------------------
st_walk %>%
  filter(parameter == "log_sd_walk") %>%
  summarise(near_zero = sum(exp(estimate) < 0.01))

#' 
#' ### Challenge 5: Your Turn: Upper Pitt River, Row 6 (10 minutes)
#' 
#' Run the simulated-data check (lag-1) for both Upper Pitt River models and a self-test of the random walk with `n_sim = 30`.
#' Add the code to `upper-pitt-river.R` and write row 6 of your report card under it:
#' 
#' - for each model, the share of simulations with a lag-1 correlation at least as large as the data's;
#' - for the self-test, the median estimates against the truth, the number of refits that pass, and the number of sd\_walk estimates that collapse to zero.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' If `walk_pitt` is not in your workspace (for example, in a new R session), run `upper-pitt-river.R` from the top: it makes `pitt`, `dat_pitt`, `ricker_pitt` and `walk_pitt`.
#' Then use `simulate_stat()` and `self_test()` as in this episode: call `set.seed(2026)` once before the two `simulate_stat()` calls, and again before `self_test()`.
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 6: What Does a Zero Tell You? (2 minutes)
#' 
#' In the Stellako self-test, 11 of 50 data sets simulated with drift gave sd\_walk near zero.
#' In [Episode 6](06-random-effects.Rmd), Harrison's random walk passed all four checks with sd\_walk 0.000005.
#' Challenge 4 there offered two readings: (b) "the data show no detectable drift", and (c) "Harrison's productivity has been exactly constant since 1948".
#' Which would you choose now, and why?
#' Discuss in pairs.
#' 
#' ## Comparing Models with AIC
#' 
## ----recipe-aic-table, purl=TRUE----------------------------------------------
aic_table <- function(models) {
  same <- sapply(models, function(m) identical(m$dat$logRS, models[[1]]$dat$logRS))
  if (!all(same)) stop("AIC can only compare models fitted to the same rows. Different data: ",
                       paste(names(models)[!same], collapse = ", "))
  tab <- data.frame(model     = names(models),
                    k         = sapply(models, function(m) length(m$opt$par)),
                    AIC       = sapply(models, function(m) aic(m$opt)),
                    checks_ok = sapply(models, function(m) all(m$checks)),
                    row.names = NULL)
  tab$dAIC <- tab$AIC - min(tab$AIC)
  tab[order(tab$AIC), ]
}
aic_table(list(ricker = ricker, walk = walk))

#' 
#' ### Challenge 1: Predict the Winner (3 minutes)
#' 
#' Beverton-Holt has a negative log-likelihood of 95.24 and the Ricker 96.13; both have 3 parameters.
#' Which has the lower AIC, by how much, and does the difference matter?
#' Write down your answer before you open the solution.
#' 
## ----recipe-join-covariate, purl=TRUE-----------------------------------------
npgo <- read.csv("data/npgo.csv")
npgo_by_brood <- npgo %>%
  mutate(brood_year = year - 2) %>%        # fish enter the ocean 2 years after their brood year
  select(brood_year, npgo)
my_stock <- left_join(my_stock, npgo_by_brood, by = "brood_year")
dat$npgo     <- my_stock$npgo
dat$npgo_new <- npgo$npgo[npgo$year == max(my_stock$brood_year) + 3]  # next brood year + 2
sum(is.na(dat$npgo))
dat$npgo_new

#' 
## ----recipe-covariate-model, purl=TRUE----------------------------------------
nll_ricker_npgo <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu     <- log_alpha - S / exp(log_Smax) + b_npgo * npgo
  mu_new <- log_alpha - S_new / exp(log_Smax) + b_npgo * npgo_new
  ADREPORT(mu_new)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}

#' 
#' ### Challenge 2: Will NPGO Help? (6 minutes)
#' 
#' Will adding NPGO lower AIC for Stellako?
#' Write down your prediction.
#' Then run the next chunk: it fits `ricker_npgo` and compares it with the Ricker.
#' What does `b_npgo` mean in words?
#' 
#' ### Challenge 3: A Comparison That Is Not Fair (5 minutes)
#' 
#' A colleague drops the first ten years of Stellako, refits the Ricker, and compares it with your random walk:
#' 
#' ```r
#' recent        <- filter(my_stock, brood_year >= 1958)
#' dat_recent    <- make_dat(recent, S_new = 50)
#' ricker_recent <- fit_model(nll_ricker, start_ricker(dat_recent), dat_recent)
#' c(ricker_recent = aic(ricker_recent$opt), walk = aic(walk$opt))
#' ```
#' 
#' ```output
#' ricker_recent          walk
#'      177.1593      178.3082
#' ```
#' 
#' The colleague writes: "The Ricker wins."
#' 
#' 1. What is wrong?
#' 2. Fix it.
#' 
#' ### Challenge 4: Your Turn: Upper Pitt River, Row 7 (12 minutes)
#' 
#' Fit the four candidate models to Upper Pitt River, make the AIC table, and write row 7 of your report card under the code in `upper-pitt-river.R`, using the four rules.
#' Add the new models' checks to row 2.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' Start from the covariate recipe, with `pitt` in place of `my_stock`: `npgo_by_brood` and `npgo` are already in your workspace.
#' As in earlier episodes, `S_new` for Upper Pitt River is the average number of spawners in its last four brood years.
#' Put the four fitted models in a named list, as in the full table.
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 5: Same Data, Different Response (4 minutes)
#' 
#' Model A describes log(R/S) with a normal distribution; model B describes R itself with a normal distribution.
#' Both use the same 74 years.
#' Can you compare their AIC?
#' 
#' - **(a)** Yes, they use the same data.
#' - **(b)** No: they describe different responses, so their likelihoods are on different scales.
#' - **(c)** Yes, if both pass the four checks.
#' - **(d)** Only with Akaike weights.
#' 
#' ## Many Stocks: Random Effects for Groups
#' 
## ----recipe-many-groups-data, purl=TRUE---------------------------------------
all_stocks <- arrange(sockeye, brood_year, stock)          # time order, needed for residuals
all_dat <- list(S     = all_stocks$spawners,
                logRS = log(all_stocks$recruits / all_stocks$spawners),
                stock = as.integer(factor(all_stocks$stock)),                    # 1 ... 19
                year  = all_stocks$brood_year - min(all_stocks$brood_year) + 1)  # 1 ... 75
c(rows = length(all_dat$S), stocks = max(all_dat$stock), years = max(all_dat$year))

#' 
## ----recipe-nll-stocks, purl=TRUE---------------------------------------------
nll_stocks <- function(par, dat) {                             # [Many stocks]
  getAll(par, dat)
  logRS <- OBS(logRS)
  nll <- -sum(dnorm(log_alpha_stock, mean_log_alpha, exp(log_sd_stock), log = TRUE))
  mu  <- log_alpha_stock[stock] - S / exp(log_Smax[stock])
  nll - sum(dnorm(logRS, mu, exp(log_sigma[stock]), log = TRUE))
}

#' 
#' ### Challenge 1: Who Moves Most? (3 minutes)
#' 
#' Before you run the next two chunks, predict: which stocks' productivity estimates will move most toward the average when pooled?
#' 
#' - **(a)** Stocks with the most years of data.
#' - **(b)** Stocks far from the average whose own estimates are uncertain.
#' - **(c)** The largest stocks.
#' - **(d)** All stocks move equally.
#' 
## ----recipe-nll-stocks-years, purl=TRUE---------------------------------------
nll_stocks_years <- function(par, dat) {                       # [Many stocks]
  getAll(par, dat)
  logRS <- OBS(logRS)
  nll <- -sum(dnorm(log_alpha_stock, mean_log_alpha, exp(log_sd_stock), log = TRUE))
  nll <- nll - sum(dnorm(year_effect, 0, exp(log_sd_year), log = TRUE))   # shared good and bad years
  mu  <- log_alpha_stock[stock] + year_effect[year] - S / exp(log_Smax[stock])
  nll - sum(dnorm(logRS, mu, exp(log_sigma[stock]), log = TRUE))
}

#' 
#' ### Challenge 2: Read the Year Effect (4 minutes)
#' 
#' The shared year effect averages +0.41 in the 1970s, -0.36 in the 2000s and -0.88 in the 2010s.
#' Describe this in one sentence, and compare it with the Stellako random walk from Episode 6, where productivity fell from about 15.6 recruits per spawner in 1980 to about 3.8 in 2021.
#' 
#' ### Challenge 3: Add NPGO to the Shared-Year Model (8 minutes)
#' 
#' Add NPGO at ocean entry to the model with year effects.
#' Fill in the blanks, fit it, and compare its AIC with that of `stocks_years`.
#' 
#' ```r
#' all_stocks <- left_join(all_stocks,
#'                         npgo %>% mutate(brood_year = year - 2) %>% select(brood_year, npgo),
#'                         by = "brood_year")
#' all_dat$npgo <- all_stocks$npgo
#' nll_stocks_years_npgo <- function(par, dat) {
#'   getAll(par, dat)
#'   logRS <- OBS(logRS)
#'   nll <- -sum(dnorm(log_alpha_stock, mean_log_alpha, exp(log_sd_stock), log = TRUE))
#'   nll <- nll - sum(dnorm(year_effect, 0, exp(log_sd_year), log = TRUE))
#'   mu  <- log_alpha_stock[stock] + year_effect[year] - S / exp(log_Smax[stock]) + ___ * ___
#'   nll - sum(dnorm(logRS, mu, exp(log_sigma[stock]), log = TRUE))
#' }
#' stocks_years_npgo <- fit_model(nll_stocks_years_npgo, c(par_years, list(b_npgo = ___)), all_dat,
#'                                random = c("log_alpha_stock", "year_effect"))
#' aic_table(list(stocks_years = stocks_years, stocks_years_npgo = stocks_years_npgo))
#' ```
#' 
#' ### Challenge 4: Why Did the Evidence Disappear? (5 minutes)
#' 
#' Without the shared year effect, the same NPGO term looks strong: b\_npgo = 0.13 (standard error 0.03), and AIC falls by 16.
#' With the year effect, b\_npgo = 0.10 (standard error 0.08), and AIC rises by 0.6.
#' Why? Discuss in pairs.
#' 
#' ## Forecasting and Testing Forecasts
#' 
## ----recipe-forecast, purl=TRUE-----------------------------------------------
predict_recruits(walk)
predict_recruits(ricker)

#' 
#' ### Challenge 1: Which Interval? (4 minutes)
#' 
#' For 50 thousand Stellako spawners, the random walk gives a 95% confidence interval for the median of 80 to 274 thousand recruits, and an 80% prediction interval of 55 to 397 thousand.
#' Which range describes where next year's recruits will probably fall?
#' Then say in one sentence why the 80% interval is wider than the 95% one.
#' 
#' - **(a)** The 95% confidence interval, because 95 is more than 80.
#' - **(b)** The 80% prediction interval.
#' - **(c)** Both equally.
#' - **(d)** Neither: use the median.
#' 
#' ### Challenge 2: Median or Mean? (3 minutes)
#' 
#' `predict_recruits()` reports a median of 148 thousand.
#' The mean of the same forecast distribution is 199 thousand.
#' Which statement is right?
#' 
#' - **(a)** `exp()` of the log-scale forecast is the mean.
#' - **(b)** 148 thousand is the middle of the possible outcomes; a few very large possible outcomes pull the mean up.
#' - **(c)** 199 is a mistake.
#' - **(d)** The two should be equal.
#' 
## ----recipe-hindcast, purl=TRUE-----------------------------------------------
hindcast <- function(m, df, first_year) {
  out <- NULL
  for (yr in df$brood_year[df$brood_year >= first_year]) {     # observed years only
    train <- filter(df, brood_year < yr)                         # what we knew then
    test  <- filter(df, brood_year == yr)                        # what happened next
    m_yr  <- fit_model(m$nll, m$par, make_dat(train, S_new = test$spawners), m$random)
    out   <- rbind(out, data.frame(brood_year = yr, observed = test$recruits,
                                   predict_recruits(m_yr), fit_ok = all(m_yr$checks)))
  }
  out
}

#' 
## ----recipe-hindcast-try, purl=TRUE-------------------------------------------
hindcast(walk, my_stock, first_year = 2019)

#' 
## ----recipe-naive-try, purl=TRUE----------------------------------------------
naive_forecast(my_stock, first_year = 2019)

#' 
## ----recipe-score, purl=TRUE--------------------------------------------------
score_forecasts <- function(hc) {
  hc %>%
    mutate(error = log(median / observed)) %>%                 # above 0: forecast too high
    group_by(model) %>%
    summarise(n = n(), bias = mean(error), MAE = mean(abs(error)),
              coverage80 = mean(observed >= lower & observed <= upper), .groups = "drop") %>%
    mutate(skill = MAE / MAE[model == "naive"])                # below 1: beats the benchmark
}

#' 
## ----run-hindcast, purl=TRUE--------------------------------------------------
hc <- bind_rows(ricker = hindcast(ricker, my_stock, first_year = 2007),
                walk   = hindcast(walk,   my_stock, first_year = 2007),
                naive  = naive_forecast(my_stock, first_year = 2007),
                .id = "model")
all(hc$fit_ok)
score_forecasts(hc)

#' 
#' ### Challenge 3: Read a Score Row (3 minutes)
#' 
#' Another model's hindcast row reads: bias 0.40, MAE 0.70, coverage80 0.93, skill 0.86.
#' Which reading is right?
#' 
#' - **(a)** It beat the benchmark, but its forecasts were too high by a factor of about exp(0.40) = 1.5 on average.
#' - **(b)** It did worse than the benchmark, because its skill is above 0.
#' - **(c)** Its intervals were too narrow, because 0.93 is far from 0.80.
#' - **(d)** It shows no sign of bias, because its MAE is larger than its bias.
#' 
#' ### Challenge 4: Your Turn: Upper Pitt River, Rows 8 and 9 (15 minutes)
#' 
#' For Upper Pitt River, run the hindcast from 2007 for the Ricker, the random walk and the benchmark, and score it.
#' Then forecast from the random walk, with `S_new` set to the average spawners of the last four brood years.
#' Add the code to `upper-pitt-river.R` and write rows 8 and 9 of your report card under it:
#' 
#' - row 8: the bias, MAE, skill and 80% coverage of each model and the benchmark, in one or two sentences;
#' - row 9: the median and 80% prediction interval from the random walk, with units and the word "median".
#' 
#' Compare row 8 with row 7 (AIC): do they agree?
#' 
#' :::::::::::::::::::::::: hint
#' 
#' `pitt`, `dat_pitt`, `ricker_pitt` and `walk_pitt` are in `upper-pitt-river.R`; run it from the top if they are not in your workspace.
#' Then copy the `hc <- bind_rows(...)` chunk that ran the hindcast from 2007 and change the names: `pitt` for `my_stock`, `ricker_pitt` and `walk_pitt` for `ricker` and `walk`, and `hc_pitt` for `hc`.
#' If row 7 is not in your report card, run `aic_table(list(ricker = ricker_pitt, walk = walk_pitt))`.
#' Row 9 can follow this frame: "From \_\_\_ thousand spawners, the random walk forecasts a median of \_\_\_ thousand recruits (80% prediction interval \_\_\_ to \_\_\_ thousand)."
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 5: What Do You Tell a Manager? (5 minutes)
#' 
#' Stellako's random walk caught 73% of past outcomes (11 of 15) in its 80% intervals; the Ricker caught 60% (9 of 15).
#' What should a manager be told along with the forecast?
#' Discuss in pairs.
#' 
#' ### Challenge 6 (Optional): A Second Benchmark (not timed)
#' 
#' Another benchmark: "recruits per spawner as last year".
#' Copy `naive_forecast()` from [the finished recipe box (cookbook.R)](files/cookbook.R), call the copy `last_year_forecast()`, and change `(yr - 4):(yr - 1)` to `(yr - 1)`.
#' Then copy the `hc <- bind_rows(...)` chunk that ran the hindcast from 2007, call the result `hc_4`, and add the line `last_year = last_year_forecast(my_stock, first_year = 2007),` before `.id = "model"`.
#' Score all four.
#' Does the random walk beat the new benchmark?
#' 
#' :::::::::::::::::::::::: hint
#' 
#' Keep the brackets around `yr - 1`.
#' R works out `%in%` before `-`, so `df$brood_year %in% yr - 1` means `(df$brood_year %in% yr) - 1`: it gives no error, but it averages the wrong years.
#' 
#' :::::::::::::::::::::::::
#' 
#' ## Capstone: A Model Report for a New Stock
#' 
#' ### Challenge 1: Complete the Report Card (60 minutes)
#' 
#' In pairs, fill in every blank in the template, run it section by section, and complete rows 1 to 10 in your report card.
#' Use the [Recipe Index](../learners/recipe-index.md) when you are unsure which recipe to use.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' - The order of the template is the order of the episodes.
#' - If a check fails, work through [Troubleshooting](../learners/troubleshooting.md).
#' - If an SD is near zero, go back to "Check an SD Near Zero" in [Episode 6](06-random-effects.Rmd).
#' - For row 6, count the sd\_walk estimates that collapsed to zero, as in [Episode 8](08-simulation.Rmd).
#' - Write each row as soon as its section runs.
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 2 (Optional): Stretch: Combine Two Ideas (not timed)
#' 
#' For fast pairs, row 11.
#' Write `nll_bh_walk`, the Beverton-Holt curve with random-walk productivity.
#' Fit it, check it, and add it to your AIC table and hindcast.
#' 
#' :::::::::::::::::::::::: hint
#' 
#' Start from `nll_walk` in [the finished recipe box (cookbook.R)](files/cookbook.R).
#' Only the two lines that compute `mu` and `mu_new` change: they take the Beverton-Holt curve from `nll_bh`, with `log_alpha_year` in place of `log_alpha`.
#' For the starting values, combine `start_bh(dat)` with the two random-walk entries of `start_walk()`.
#' 
#' :::::::::::::::::::::::::
#' 
#' ### Challenge 3: Share-Out: Where Did AIC and the Hindcast Disagree? (20 minutes)
#' 
#' Add your line to the shared table.
#' Then, as a whole group: where did AIC and the hindcast disagree, and why?
#' 
