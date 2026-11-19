---
title: 'Instructor Notes'
---

These notes are for instructors and helpers.
They cover preparation, teaching, timing, checkpoints, feedback, the data and the answer keys.
The design record (objectives, report card, assessment map, misconceptions and concept map) is on the [Lesson Design](lesson-design.md) page.
Below these notes, this page also collects the instructor notes from every episode, in the order they appear.

## The Lesson in One Paragraph

The lesson makes three passes over one nine-step workflow (data, model, fit, check the fit, estimates, check the model, random effect, compare, forecast).
In the first pass you demonstrate on Stellako sockeye salmon.
In the second, learners repeat each step on Upper Pitt River in the "Your Turn" challenges, and fill in one row of a model report card per episode.
In the third, the [Capstone](../episodes/12-capstone.Rmd), pairs apply the whole workflow to a stock they choose, or to their own data.
The [Quick Start](../episodes/02-quick-start.Rmd) runs all nine steps in one hour, and each later episode opens one step as one or more recipe cards.
Learners copy each recipe into their own `my-recipes.R`; [the finished recipe box (cookbook.R)](../episodes/files/cookbook.R) holds every recipe, in lesson order.

## Before the Workshop

- Send the [Setup](../learners/setup.md) page a week ahead, and ask learners to reply (by email or a form) with the line `Your setup works.` that the setup check prints.
- Collect the answers to the three self-check questions on the Setup page.
  Anyone who gets two of the three wrong should take an introductory R lesson first; tell them before the workshop, kindly.
- Prepare:
  - sticky notes in two colours (green: done; another colour: I need help);
  - a shared notes document with a "parking lot" section for questions that a later episode answers;
  - a shared table for the capstone share-out, with the columns listed in the capstone (stock; best by AIC, with the AIC difference to the next; best by hindcast skill; random-walk 80% coverage; do AIC and the hindcast agree?; one sentence);
  - printed copies of the [Recipe Index](../learners/recipe-index.md);
  - the link to the code handout (`files/code-handout.R` on the built site), which holds every recipe chunk.
- Offer an optional setup help desk at 08:30 on Day 1.
- Rehearse on the computer you will teach from.
  In a project with `data/` and `files/` set up as on the Setup page, run:

  ```r
  source("files/quick-start.R")
  check_fit(opt, sdr)
  check_fit(opt_walk, sdr_walk)
  c(ricker = aic(opt), walk = aic(opt_walk))
  ```

  It takes about 3 seconds and must print four TRUE twice, then the two AIC values:

  ```output
   finished      flat    curved finite_se
       TRUE      TRUE      TRUE      TRUE
   finished      flat    curved finite_se
       TRUE      TRUE      TRUE      TRUE
    ricker     walk
  198.2570 178.3082
  ```

## Teaching

- Teach by participatory live coding, with a large font and dark text on a light background.
  Type everything, say each line as you type it, then explain it again.
- There are three exceptions to typing:
  - learners who fall behind in the Quick Start may paste from [the Quick Start script (quick-start.R)](../episodes/files/quick-start.R); this is the only episode where pasting is the plan;
  - `naive_forecast()` in Episode 11 is read together, not typed (learners copy it from `cookbook.R`);
  - the capstone uses [the capstone template (capstone-template.R)](../episodes/files/capstone-template.R).
- Make the planned mistakes live, and let learners read the output before you explain it:
  - the missing minus sign in front of `sum()` (Episode 4);
  - the missing `random =` argument (Episodes 4 and 8);
  - the random-effect vector that is one value too short (Episode 6).
- Ask "What questions do you have?", not "Any questions?".
  Write deep questions in the parking lot, labelled with the episode that answers them, and come back to them there.
- Keep to the lesson's one way per task.
  If someone asks about another method (`optim()`, `lm()`, Bayesian fitting, `REPORT()`), say that it exists, and point to the [Going Further](../learners/going-further.md) page.

## Timing and Cuts

The time budget, in minutes. The schedule on the home page is generated from these numbers.

Table: Time budget per episode (minutes) and number of challenges.

| Episode | Teaching | Exercises | Total | Challenges |
|------------------------------|---:|---:|---:|------:|
| [01 Introduction: Salmon, Spawners and Recruits](../episodes/01-introduction.Rmd) | 15 | 10 | 25 | 2 |
| [02 Quick Start: The Whole Workflow in Nine Steps](../episodes/02-quick-start.Rmd) | 40 | 20 | 60 | 6 |
| [03 Writing a Model as a Likelihood](../episodes/03-likelihoods.Rmd) | 30 | 25 | 55 | 5 |
| [04 Fitting a Model and Checking the Fit](../episodes/04-fit-and-check.Rmd) | 30 | 25 | 55 | 4 |
| [05 Estimates, Intervals and Derived Quantities](../episodes/05-uncertainty.Rmd) | 30 | 20 | 50 | 4 (+1 optional) |
| [06 Random Effects: Productivity That Changes over Time](../episodes/06-random-effects.Rmd) | 35 | 25 | 60 | 4 |
| [07 Checking a Model with Residuals](../episodes/07-residuals.Rmd) | 25 | 20 | 45 | 3 |
| **Day 1** | **205** | **145** | **350** | |
| [08 Checking a Model with Simulation](../episodes/08-simulation.Rmd) | 25 | 25 | 50 | 5 |
| [09 Comparing Models with AIC](../episodes/09-model-selection.Rmd) | 35 | 30 | 65 | 5 |
| [10 Many Stocks: Random Effects for Groups (optional)](../episodes/10-many-stocks.Rmd) | 25 | 20 | 45 | 4 |
| [11 Forecasting and Testing Forecasts](../episodes/11-forecasting.Rmd) | 40 | 35 | 75 | 5 |
| [12 Capstone: A Model Report for a New Stock](../episodes/12-capstone.Rmd) | 10 | 80 | 90 | 2 |
| **Day 2** | **135** | **190** | **325** | |
| **Total** | **340** | **335** | **675** | **50** |

- Exercises take half of the time.
  Episodes 1 to 11 have 48 challenges in 330 minutes of teaching: one every 7 minutes on average.
- All times are first estimates.
  After you teach, replace `teaching:` and `exercises:` at the top of each episode with the times you measured.

**When you fall behind, never speed up: cut whole pieces, and tell learners where the skipped material is.**
Cut in this order:

1. Episode 10 (Many Stocks). Tell the pooled-NPGO story in two minutes at the end of Episode 9: across all 19 stocks, the North Pacific Gyre Oscillation (NPGO) index lowers AIC by 16 without shared year effects, but raises it by 0.6 with them.
2. In Episode 8, demonstrate the self-test instead of having learners type `self_test()`.
3. Episode 3, Challenge 2 and Episode 5, Challenge 2.
4. Episode 11, Challenge 3.
5. Capstone rows 5 and 6.

Never cut the Quick Start, Episode 4, the core of Episodes 7, 9 and 11, or capstone rows 2, 3, 7, 8 and 9.

A workshop can stop at two points and still be useful:

- after Episode 7: fitting and checking one stock is complete (lesson objectives 1 to 5);
- after Episode 9: models can also be compared (objectives 1 to 6).

## Two-Day Schedule

Breaks are not counted in the episode minutes.

Table: Day 1, one stock, one model, done properly.

| Time | Session | Minutes |
|-----|-------------------------|----:|
| 08:30 | Optional setup help desk | |
| 09:00 | Welcome, code of conduct, sticky notes, setup check | 10 |
| 09:10 | 01 Introduction: Salmon, Spawners and Recruits | 25 |
| 09:35 | 02 Quick Start: The Whole Workflow in Nine Steps | 60 |
| 10:35 | Break | 15 |
| 10:50 | 03 Writing a Model as a Likelihood | 55 |
| 11:45 | 04 Fitting a Model and Checking the Fit | 55 |
| 12:40 | Lunch (minute cards) | 50 |
| 13:30 | 05 Estimates, Intervals and Derived Quantities | 50 |
| 14:20 | 06 Random Effects: Productivity That Changes over Time | 60 |
| 15:20 | Break | 15 |
| 15:35 | 07 Checking a Model with Residuals | 45 |
| 16:20 | Wrap-up: report-card rows 1 to 5; one-up/one-down | 10 |
| 16:30 | End | |

Table: Day 2, check, compare, forecast.

| Time | Session | Minutes |
|-----|-------------------------|----:|
| 09:00 | What we changed after Day 1's feedback | 5 |
| 09:05 | 08 Checking a Model with Simulation (opens with the Parsons warm-up) | 50 |
| 09:55 | 09 Comparing Models with AIC | 65 |
| 11:00 | Break | 15 |
| 11:15 | 10 Many Stocks: Random Effects for Groups (optional) | 45 |
| 12:00 | Lunch (minute cards) | 60 |
| 13:00 | 11 Forecasting and Testing Forecasts | 75 |
| 14:15 | Break | 15 |
| 14:30 | 12 Capstone: A Model Report for a New Stock | 90 |
| 16:00 | Survey, one-up/one-down, where to go next | 15 |
| 16:15 | Spare time for overruns | 15 |
| 16:30 | End | |

If you cut Episode 10, Day 2 gains 45 minutes: give 30 to the capstone and keep 15 in reserve.
For four half-days, split after Episodes 4, 7 and 10.

## Sticky-Note Checkpoints

Every recipe ends with a "Check it worked" line, which is also a sticky-note checkpoint.
Ask for sticky notes at least at these points:

Table: Where to ask for sticky notes, and what learners should have.

| Where | Green sticky note when... |
|--------|--------------------------|
| Episode 1 | both plots of Stellako appear |
| Quick Start, step 4 | `check_fit()` prints four TRUE |
| Quick Start, step 8 | two AIC values print |
| Episode 3 | `obj$fn(obj$par)` prints 144.8 |
| Episode 4 | `ricker$checks` shows four TRUE |
| Episode 5 | `ci_table(ricker)` prints |
| Episode 6 | the productivity plot appears |
| Episode 7 | the three residual checks have run, and rows 1 to 5 of the Upper Pitt River report card are written |
| Episode 8 | the self-test table prints |
| Episode 9 | the full AIC table prints |
| Episode 10 | the year-effect plot appears |
| Episode 11 | the score table prints |
| Capstone | after C2 (the checks of every model), C7 (the AIC table) and C8 (the hindcast scores) |

## Responding to Multiple-Choice Answers

Every wrong option in a multiple-choice challenge comes from a named misconception.
Plan your response before you ask:

- if most learners pick one wrong answer, re-teach the misconception it names, using the evidence in the table below;
- if answers are spread out, go back to the last point everyone understood;
- if almost everyone is right, move on.

In the table, E03.C2 means Episode 3, Challenge 2.

Table: Misconceptions, the evidence to re-teach with, and where the lesson targets them.

| # | Misconception | Evidence (from the lesson's own runs) | Targeted by |
|---|----------|--------------|------|
| M1 | Return the log-likelihood, not its negative | `opt$convergence` is 0 with the message "X-convergence (3)", `opt$objective` is `-Inf`, and the checks are TRUE FALSE FALSE FALSE | E03.C2, E04.C1 |
| M2 | `convergence == 0` means the fit is usable | the same output | E04.C1 |
| M3 | If the optimiser finished on flat ground, the standard errors are fine | two parameters that do one job: `finished` TRUE, `flat` TRUE, every standard error `NaN` | E04.C2 |
| M4 | Back-transform as exp(estimate) ± 1.96 SE | gives 122.2 to 123.3 instead of 73 to 207 thousand for Stellako's S_max | E05.C1 |
| M5 | A confidence band should contain most data points | the 95% band holds 24% of the Stellako points | E05.C3, E11.C1 |
| M6 | `exp()` of a log-scale forecast is the mean | median 148, mean 199 thousand recruits | E11.C2 |
| M7 | `random =` means "draw random numbers"; an SD at zero means the fit failed | Harrison: four checks TRUE, sd_walk 5e-6, AIC exactly 2.00 above the Ricker | E06.C1, E06.C4 |
| M8 | Observed-minus-fitted residuals are fine for random-effect models | conditional residuals have SD 0.96 and lag-1 correlation -0.17; one-step-ahead residuals have SD 1.00 and -0.10 | Episode 7 spoiler and keypoint |
| M9 | Models fitted to different rows can be compared by AIC | the Ricker on 1958-2021 has AIC 177.2 and appears to beat the random walk on 1948-2021 (178.3); on the same rows the walk wins by 17.6 | E09.C3 |
| M10 | Lower AIC means better forecasts | Upper Pitt River: AIC prefers the random walk by 11.8, but the Ricker's hindcast errors are slightly smaller (skill 0.78 against 0.82); Chilko and Late Stuart in the capstone | E11.C4, capstone share-out |
| M11 | Changing `dat` after a fit is harmless | with the raw RTMB calls, `dat$S_new <- 150` after fitting silently changed `sdreport()`'s `mu_new` from 1.97 to 1.16 | Episode 4 spoiler (demonstration) |
| M12 | A covariate that lowers AIC is robust | pooled NPGO: AIC changes by -16.0 without year effects and +0.57 with them | E10.C4 |
| M13 | An SD estimated at zero proves there is no variation | self-test: 11 of 50 data sets simulated with sd_walk 0.13 gave an estimate of about zero | E06.C4 (option c), E08.C5 |
| M14 | `obj$simulate()` without arguments uses the fitted values | it uses the parameters evaluated last | Episode 8 caution |
| M15 | S_max is a carrying capacity | (terminology) | Episode 5 caution |
| M16 | AIC can compare a model of log(R/S) with a model of R | the two models describe different responses | E09.C5 |

## Feedback

- Collect minute cards at lunch on both days: one thing that went well, and one question or thing that was unclear.
- Collect one-up/one-down at the end of each day: each learner says one thing to keep and one thing to change.
- Open Day 2 by saying what you changed after Day 1's feedback (5 minutes).
- Day 2 starts with the Parsons warm-up, [Checking a Model with Simulation](../episodes/08-simulation.Rmd), Challenge 1: it rebuilds Day 1's fitting recipe and reminds everyone of `random =`.

## Data Notes

- Stellako brood year 2005 (102 thousand spawners, 11.6 thousand recruits) returned mainly in 2009, one of the poorest Fraser River sockeye returns on record.
  It is real; do not delete it.
  Episode 7, Challenge 3 asks what to do about it.
- Upper Pitt River is the "Your Turn" stock because it behaves like Stellako but has two differences worth discussing: NPGO helps, and AIC and the hindcast disagree.
- Harrison is the only stock with brood year 2022, so its hindcast from 2007 has 16 forecasts instead of 15.
- Quesnel and Late Stuart have strong four-year cycles and years with under 1 thousand spawners (25 years for Quesnel, 9 for Late Stuart).
  Every fit still passes all four checks, but under the random walk Quesnel's S_max (3481 thousand) is far beyond its data.
- Early Stuart (two brood years with 15 and 46 spawners) and Late Shuswap (S_max beyond the data) are left out of the examples on purpose.
- Cultus, Portage and Scotch Creek have missing years.
  Every recipe handles them, but they are not on the capstone menu.
- The data were supplied with the Pacific Salmon Commission RTMB workshop and described there as "not necessarily official numbers".
  The lesson uses them to teach methods; nothing in it is management advice.
  These stocks matter to First Nations and to commercial and recreational fisheries: treat questions about them with care, following the [CARE principles for Indigenous data governance][care].

## Hidden Curriculum to Make Explicit

Say these out loud when they first come up; experienced R users do them without thinking.

- Work in a project, and use relative paths such as `data/sockeye.csv`.
- Keep code in a script, not in the console, so you can rerun it.
- Read an error message from the bottom up, then find it on the [Troubleshooting](../learners/troubleshooting.md) page.
- Call `set.seed()` before anything that simulates, so the numbers can be reproduced.
- Save `report-card.R` as you go: each row is written as soon as its challenge runs.
- Use new object names in your own experiments (`ricker_test`, not `ricker`), so you do not overwrite the demonstration objects that later steps use.

## Answer Keys

- **Upper Pitt River**: the full solutions are in the "Your Turn" challenges of Episodes 1 to 11. The completed report card is summarised below.
- **Capstone**: the answer key for Quesnel, Late Stuart, Chilko, Harrison and Birkenhead is an instructor note in the [Capstone](../episodes/12-capstone.Rmd), and is collected at the bottom of this page.

Table: The Upper Pitt River report card (answer key for the "Your Turn" challenges).

| Row | Item | Upper Pitt River | Challenge |
|--:|----|------------------|------|
| 1 | Data | 1948-2021, 74 years, spawners 2.1 to 74.6 thousand; `S_new` = 5.3 thousand spawners (average of 2018-2021) | E01.C2, E03.C5 |
| 2 | Fits usable | four checks TRUE for the Ricker, the random walk, Beverton-Holt and Ricker + NPGO | E04.C4, E06.C3, E09.C4 |
| 3 | Estimates | alpha 8.9 recruits per spawner (95% CI 6.5 to 12.1); S_max 20 thousand spawners (15 to 28), inside the observed range | E05.C4 |
| 4 | Random effect | sd_walk 0.33 (0.14 to 0.78): productivity typically changes by about a third from year to year; 10.4 recruits per spawner in 1948, 16.3 in 1965, 4.7 in 1980, 10.9 in 2000, 2.9 in 2021 | E06.C3 |
| 5 | Residuals | Ricker lag-1 0.47 against a limit of 0.23, long waves over time, QQ plot bends below the line at both ends; random walk lag-1 0.13 | E07.C2 |
| 6 | Simulation | observed lag-1 0.58: reached by 0 of 200 Ricker simulations and 63% of random-walk simulations; self-test of the walk: 30 of 30 refits pass, no sd_walk at zero | E08.C4 |
| 7 | Comparison | random walk best: 6.2 below Ricker + NPGO, 7.5 below Beverton-Holt, 11.8 below the Ricker; NPGO helps here (b_npgo 0.28, 95% CI 0.09 to 0.48) | E09.C4 |
| 8 | Forecast skill | hindcast from 2007: Ricker skill 0.78, bias +0.74, coverage 0.67; random walk skill 0.82, bias 0.00, coverage 0.60; benchmark coverage 0.40. AIC and the hindcast disagree | E11.C4 |
| 9 | Forecast | random walk: median 12 thousand recruits (80% prediction interval 4.4 to 35 thousand) from 5.3 thousand spawners | E11.C4 |

## Building the Lesson

- Each episode is knitted in a fresh R session, so its Starting Point chunk recreates everything it needs.
- `episodes/files/cookbook.R` must stay identical to the code taught in the episodes.
  If you change a recipe, change it in both places, and in every episode that uses it.
- `config.yaml` sets `fail_on_error: true`, so any unplanned error stops the build.
  Chunks that are meant to fail are marked `error=TRUE`.
- No chunk takes more than about 5 seconds.
  The slowest is the optional profile interval in Episode 10; the 50-simulation self-test in Episode 8 takes about 2 seconds.
- Run `sandpaper::validate_lesson(headings = TRUE)` before you commit.
  The README explains how to build the lesson locally.

## A Private Repository

- GitHub Pages can serve a site from a private repository only on a paid GitHub plan, and the site may still be public.
- Until the lesson is ready to share, build it locally and share the `site/docs/` folder as a zip file.
