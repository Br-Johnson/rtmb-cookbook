## cookbook.R: the finished recipe box of the RTMB Cookbook, in lesson order.
## Use it with:  library(RTMB); library(dplyr); library(ggplot2); source("files/cookbook.R")
## Spawners (S) and recruits (R) are in thousands of fish. Models describe log(R/S).
## The [Episode] tag says where each recipe is taught.

## ---- Data and starting values ----------------------------------------------------
## One stock's rows -> the data list every single-stock model uses          [Likelihoods]
make_dat <- function(df, S_new) {
  list(S     = df$spawners,                                    # spawners
       logRS = log(df$recruits / df$spawners),                 # log(recruits per spawner)
       year  = df$brood_year - min(df$brood_year) + 1,         # 1, 2, 3, ... (gaps allowed)
       S_new = S_new)                                          # spawners for a forecast
}
## Starting values: typical values from the data                             [Likelihoods]
start_ricker <- function(dat) {
  list(log_alpha = mean(dat$logRS), log_Smax = log(mean(dat$S)), log_sigma = log(sd(dat$logRS)))
}
start_bh <- function(dat) {                                                  # [Likelihoods]
  list(log_alpha = mean(dat$logRS), log_Shalf = log(mean(dat$S)), log_sigma = log(sd(dat$logRS)))
}
start_walk <- function(dat) {                                                # [Random effects]
  c(start_ricker(dat),
    list(log_sd_walk = log(0.1),                                   # small yearly steps
         log_alpha_year = rep(mean(dat$logRS), max(dat$year) + 1)))  # every year + next year
}

## ---- Models (negative log-likelihood functions) -------------------------------------
## Ricker: log(R/S) = log(alpha) - S / Smax + noise                         [Quick Start]
nll_ricker <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)                                  # these are the observations
  mu     <- log_alpha - S / exp(log_Smax)              # expected log(R/S)
  mu_new <- log_alpha - S_new / exp(log_Smax)          # ... for the forecast
  ADREPORT(mu_new)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))   # negative log-likelihood
}
## Beverton-Holt: log(R/S) = log(alpha) - log(1 + S / Shalf) + noise         [Likelihoods]
nll_bh <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu     <- log_alpha - log(1 + S / exp(log_Shalf))
  mu_new <- log_alpha - log(1 + S_new / exp(log_Shalf))
  ADREPORT(mu_new)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}
## Ricker with productivity that drifts from year to year (random walk)   [Quick Start, Random effects]
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
## Ricker + NPGO in the year the young fish enter the ocean                  [Comparing models]
nll_ricker_npgo <- function(par, dat) {
  getAll(par, dat)
  logRS <- OBS(logRS)
  mu     <- log_alpha - S / exp(log_Smax) + b_npgo * npgo
  mu_new <- log_alpha - S_new / exp(log_Smax) + b_npgo * npgo_new
  ADREPORT(mu_new)
  -sum(dnorm(logRS, mu, exp(log_sigma), log = TRUE))
}

## ---- Fit and check ------------------------------------------------------------------
## The four checks                                                          [Quick Start]
check_fit <- function(opt, sdr) {
  c(finished  = opt$convergence == 0,                         # the optimiser stopped normally
    flat      = max(abs(sdr$gradient.fixed)) < 0.001,         # the ground is level
    curved    = sdr$pdHess,                                   # the bottom is a bowl
    finite_se = all(is.finite(summary(sdr, "fixed")[, "Std. Error"])))  # every SE is a number
}
## Build, fit, check, and keep the recipe for refits                         [Fitting]
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

## ---- Report ---------------------------------------------------------------------------
## 95% confidence intervals; anything named log_* is back-transformed with exp()   [Uncertainty]
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
## Recruits for S_new spawners: a confidence band for the curve, or a prediction interval
## for one new year (adds the yearly noise, sigma)                  [Uncertainty, Forecasting]
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

## ---- Check the model against the data --------------------------------------------------
lag1 <- function(r) cor(head(r, -1), tail(r, -1))            # [Quick Start] neighbouring years alike?
osa_residuals <- function(m) {                                 # [Residuals]
  oneStepPredict(m$obj, method = "fullGaussian", trace = FALSE)$residual
}
simulate_stat <- function(m, stat, n_sim = 200) {              # [Simulation]
  replicate(n_sim, stat(m$obj$simulate(m$obj$env$last.par.best)$logRS))
}
self_test <- function(m, n_sim = 50) {                         # [Simulation]
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

## ---- Compare models ----------------------------------------------------------------------
aic <- function(opt) 2 * opt$objective + 2 * length(opt$par)  # [Quick Start]
aic_table <- function(models) {                               # [Comparing models]
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

## ---- Forecast and test forecasts ------------------------------------------------------
## Refit to the years before each test year and forecast that year            [Forecasting]
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
## Benchmark: recruits per spawner as in the previous four brood years        [Forecasting]
naive_forecast <- function(df, first_year) {
  df <- mutate(df, logRS = log(recruits / spawners))
  df$recent <- sapply(df$brood_year, function(yr) mean(df$logRS[df$brood_year %in% (yr - 4):(yr - 1)]))
  out <- NULL
  for (yr in df$brood_year[df$brood_year >= first_year]) {
    past   <- filter(df, brood_year < yr, !is.na(recent))
    sd_err <- sd(past$logRS - past$recent)                     # how wrong the rule was before
    test   <- filter(df, brood_year == yr)
    out <- rbind(out, data.frame(brood_year = yr, observed = test$recruits, S_new = test$spawners,
                                 median = test$spawners * exp(test$recent),
                                 lower  = test$spawners * exp(test$recent - qnorm(0.9) * sd_err),
                                 upper  = test$spawners * exp(test$recent + qnorm(0.9) * sd_err),
                                 fit_ok = TRUE))
  }
  out
}
score_forecasts <- function(hc) {                              # [Forecasting]
  hc %>%
    mutate(error = log(median / observed)) %>%                 # above 0: forecast too high
    group_by(model) %>%
    summarise(n = n(), bias = mean(error), MAE = mean(abs(error)),
              coverage80 = mean(observed >= lower & observed <= upper), .groups = "drop") %>%
    mutate(skill = MAE / MAE[model == "naive"])                # below 1: beats the benchmark
}

## ---- Many stocks (optional episode) -------------------------------------------------------
nll_stocks <- function(par, dat) {                             # [Many stocks]
  getAll(par, dat)
  logRS <- OBS(logRS)
  nll <- -sum(dnorm(log_alpha_stock, mean_log_alpha, exp(log_sd_stock), log = TRUE))
  mu  <- log_alpha_stock[stock] - S / exp(log_Smax[stock])
  nll - sum(dnorm(logRS, mu, exp(log_sigma[stock]), log = TRUE))
}
nll_stocks_years <- function(par, dat) {                       # [Many stocks]
  getAll(par, dat)
  logRS <- OBS(logRS)
  nll <- -sum(dnorm(log_alpha_stock, mean_log_alpha, exp(log_sd_stock), log = TRUE))
  nll <- nll - sum(dnorm(year_effect, 0, exp(log_sd_year), log = TRUE))   # shared good and bad years
  mu  <- log_alpha_stock[stock] + year_effect[year] - S / exp(log_Smax[stock])
  nll - sum(dnorm(logRS, mu, exp(log_sigma[stock]), log = TRUE))
}
