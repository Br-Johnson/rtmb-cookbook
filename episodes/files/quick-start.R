## Quick Start: the whole workflow on one stock, in nine steps (QS1-QS9).
## Stellako sockeye salmon. Spawners and recruits are in THOUSANDS of fish.

## QS1 Data ---------------------------------------------------------------------
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

## QS2 Model --------------------------------------------------------------------
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

## QS3 Fit ----------------------------------------------------------------------
obj <- MakeADFun(function(p) nll_ricker(p, dat), par_ricker, silent = TRUE)  # build
opt <- nlminb(obj$par, obj$fn, obj$gr)                                       # fit
sdr <- sdreport(obj)                                                         # standard errors

## QS4 Check the fit ------------------------------------------------------------
check_fit <- function(opt, sdr) {
  c(finished  = opt$convergence == 0,                         # the optimiser stopped normally
    flat      = max(abs(sdr$gradient.fixed)) < 0.001,         # the ground is level
    curved    = sdr$pdHess,                                   # the bottom is a bowl
    finite_se = all(is.finite(summary(sdr, "fixed")[, "Std. Error"])))  # every SE is a number
}
check_fit(opt, sdr)

## QS5 Estimates with uncertainty -----------------------------------------------
est <- summary(sdr, "fixed")
est
exp(est["log_Smax", "Estimate"] + c(-1.96, 0, 1.96) * est["log_Smax", "Std. Error"])

## QS6 Check the model: one-step-ahead residuals ----------------------------------
my_stock$res_ricker <- oneStepPredict(obj, method = "fullGaussian", trace = FALSE)$residual
ggplot(my_stock, aes(x = brood_year, y = res_ricker)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_point() +
  labs(x = "Brood year", y = "One-step-ahead residual (Ricker)")
lag1 <- function(r) cor(head(r, -1), tail(r, -1))     # are neighbouring years alike?
lag1(my_stock$res_ricker)

## QS7a A random effect: productivity that drifts from year to year ---------------
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
par_walk <- c(par_ricker,
              list(log_sd_walk    = log(0.1),                            # small steps
                   log_alpha_year = rep(mean(dat$logRS), max(dat$year) + 1)))

## QS7b Fit and check it: the same three calls, plus random = ---------------------
obj_walk <- MakeADFun(function(p) nll_walk(p, dat), par_walk,
                      random = "log_alpha_year", silent = TRUE)
opt_walk <- nlminb(obj_walk$par, obj_walk$fn, obj_walk$gr)
sdr_walk <- sdreport(obj_walk)
check_fit(opt_walk, sdr_walk)
my_stock$res_walk <- oneStepPredict(obj_walk, method = "fullGaussian", trace = FALSE)$residual
lag1(my_stock$res_walk)

## QS8 Compare the two models with AIC ----------------------------------------------
aic <- function(opt) 2 * opt$objective + 2 * length(opt$par)
c(ricker = aic(opt), walk = aic(opt_walk))

## QS9 Forecast: recruits from S_new spawners next year (median, 80% interval) -----------
p <- summary(sdr_walk, "report")["mu_new", ]
sd_pred <- sqrt(p[["Std. Error"]]^2 + exp(opt_walk$par[["log_sigma"]])^2)   # curve + yearly noise
dat$S_new * exp(p[["Estimate"]] + qnorm(c(0.1, 0.5, 0.9)) * sd_pred)
