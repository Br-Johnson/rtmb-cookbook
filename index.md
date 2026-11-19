---
site: sandpaper::sandpaper_site
---

In two hands-on days you will write your own statistical model as a short R function, fit it with RTMB, check that the fit worked, compare it with other models and test its forecasts on years it never saw, using one tested recipe for each step and no proofs.

This is a lesson in the style of [Data Carpentry](https://datacarpentry.org/), built with [The Carpentries Workbench](https://carpentries.github.io/sandpaper-docs/).
It is not an official Carpentries lesson.
It was developed from the materials of the RTMB workshop taught by the Pacific Salmon Commission in November 2026.

## Who It Is For

This lesson is for people who analyse data in R and fit regressions with `lm()` or `glm()`, and who now need a model that a formula interface cannot write for them:

- a curve of their own;
- a quantity that drifts over time;
- groups that share information;
- a forecast with an honest interval.

It is also for people who must read and question such models, for example reviewers of stock assessments.

The worked example is Fraser River sockeye salmon.
The salmon background is explained from scratch, every recipe uses generic ingredients (`dat`, `par`, `nll_*`, `fit_model()`), and every episode has an "In Your Field" note for other kinds of data.
The lesson is novice-level for model fitting, not for R.
The <a href="profiles.html">learner profiles</a> describe four people it was written for, from a stock assessment biologist to a public health analyst learning alone.

If you are new to R, take an introductory R lesson first.
If you already use TMB and want C++ or derivations, the [Going Further](learners/going-further.md) page points to them.

:::::::::::::::::::::::::::::::::::::::: prereq

### Before You Start

You can:

- open a project in RStudio or Positron and run a script;
- read a CSV file and use `filter()` and `mutate()` from dplyr, and make a scatter or line plot with ggplot2 (with help);
- make vectors and named lists (`x[3]`, `my_list$name`), and write and call a short function;
- use `log()` and `exp()`;
- say what a mean, a standard deviation and a normal (bell-shaped) distribution are;
- read an estimate and its standard error from a regression.

Not needed: calculus, matrix algebra, C++, TMB, Bayesian statistics, likelihood theory, fisheries science.
The Data Carpentry lesson [R for Ecologists](https://datacarpentry.org/R-ecology-lesson/), or any introductory R course, is enough.

Not sure? Answer the three questions under "Before You Come" in the [Setup](learners/setup.md) instructions below.

::::::::::::::::::::::::::::::::::::::::::::::::::

## What You Will Leave With

- Your own recipe box, `my-recipes.R`: every function the lesson teaches, typed by you.
- A completed model report card for a stock you chose: data, fits, estimates, checks, model comparison and a tested forecast.
- A template for your next analysis: [the capstone template (capstone-template.R)](episodes/files/capstone-template.R) runs the whole workflow on another stock or on your own data.
- The one-page [Recipe Index](learners/recipe-index.md), which answers "Which recipe do I need?".

## How the Lesson Works

- The [Quick Start](episodes/02-quick-start.Rmd) runs the whole workflow first, in nine steps on one stock: data, model, fit, check the fit, estimates, check the model, random effect, compare, forecast.
- Each later episode opens one of those steps and turns it into recipes you can reuse.
- Every episode ends with a "your turn" challenge on a second stock, Upper Pitt River, which fills one row of your report card.
- The [capstone](episodes/12-capstone.Rmd) repeats the workflow on a stock you choose, or on your own data.

From Episode 3 on, every episode opens with a Starting Point box that recreates everything it needs.
You can therefore learn alone from this website, or rejoin after a missed session.
Episode 10 (many stocks) is optional.

## About the Data

The data are spawner and recruit estimates for 19 Fraser River sockeye salmon stocks, brood years 1948-2022, in thousands of fish.
They were supplied with the Pacific Salmon Commission RTMB workshop and described there as not necessarily official numbers.
The lesson also uses the North Pacific Gyre Oscillation index, a measure of ocean conditions.
The script `scripts/prepare-data.R` in the lesson's source repository records every cleaning step.

These stocks matter to First Nations and to commercial and recreational fisheries.
The lesson uses them to teach methods; nothing in it is management advice.

The lesson follows the [CARE principles for Indigenous data governance](https://www.gida-global.org/care): collective benefit, authority to control, responsibility and ethics.

Licence and attribution: to be confirmed with the data providers before the lesson is shared.
