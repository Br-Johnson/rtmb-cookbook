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
