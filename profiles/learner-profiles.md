---
title: 'Learner Profiles'
---

The four people on this page are fictional.
They describe who this lesson is for, what each of them can already do, what they need, and how the lesson helps them.
The lesson is for people who are new to fitting their own models, not for people who are new to R.

## Mira, Stock Assessment Biologist

**Background.**
Mira is a stock assessment biologist at a government agency.

**What she can already do.**
She uses R every day for data summaries and ggplot2 figures.
She fits the Ricker spawner-recruit model (the curve of recruits against spawners that the lesson starts with) as `lm(log(R/S) ~ S)`.

**What she needs.**
Her manager now wants spawner reference points (such as S_max, the spawner count that produces the most recruits) with intervals, and a forecast that allows for falling productivity.
A reviewer of her last assessment asked: "Did you check the residuals, and does it beat a naive forecast?"

**How the lesson helps.**
The lesson gives her one recipe she can rerun every season, the checks that tell her when to trust it, and the words to explain the result.
She will use the intervals of [Estimates, Intervals and Derived Quantities](../episodes/05-uncertainty.Rmd), the drifting productivity of [Random Effects: Productivity That Changes over Time](../episodes/06-random-effects.Rmd), the residual checks of [Checking a Model with Residuals](../episodes/07-residuals.Rmd) and the comparison with a naive benchmark in [Forecasting and Testing Forecasts](../episodes/11-forecasting.Rmd).

## Tomás, MSc Student in Freshwater Ecology

**Background.**
Tomás is an MSc student in freshwater ecology.

**What he can already do.**
He is comfortable with `lm()`, `glm()` and `glmmTMB()`.

**What he needs.**
His thesis needs a saturating growth curve with a random effect for each sampling site, which formula functions such as `lm()` and `glmmTMB()` cannot write for him.
He wants a template he can adapt this month and a list of checks his committee will accept.
Derivations can wait.

**How the lesson helps.**
[Writing a Model as a Likelihood](../episodes/03-likelihoods.Rmd) shows him how to write a curve of his own as a short R function; its Beverton-Holt challenge is a saturating curve.
[Many Stocks: Random Effects for Groups](../episodes/10-many-stocks.Rmd) gives each group its own value, which is the same recipe as one value per sampling site.
The four checks of [Fitting a Model and Checking the Fit](../episodes/04-fit-and-check.Rmd) and the self-test of [Checking a Model with Simulation](../episodes/08-simulation.Rmd) are checks he can show his committee.
The "In Your Field" note at the end of every episode translates the recipe to other kinds of data.

## Dana, Biologist with an Indigenous Fisheries Organisation

**Background.**
Dana is a biologist with an Indigenous fisheries organisation.

**What she can already do.**
She reviews pre-season forecasts and escapement goals (targets for how many adult salmon should reach the spawning grounds) produced by others, and uses R occasionally.

**What she needs.**
She wants to know what is behind the numbers and what evidence to ask for.
Was the model checked?
How much does the answer depend on the model chosen?
How did these forecasts do in past years?

**How the lesson helps.**
The model report card, shown complete in the [Introduction](../episodes/01-introduction.Rmd) and filled in by learners in the [Capstone](../episodes/12-capstone.Rmd), lists the evidence a model report should contain.
[Comparing Models with AIC](../episodes/09-model-selection.Rmd) shows how much a conclusion depends on the model chosen, and the hindcast in [Forecasting and Testing Forecasts](../episodes/11-forecasting.Rmd) shows how forecasts would have done in past years.
She will rerun and modify the recipes, and use the report card as a checklist when she reviews.

## Sam, Public Health Analyst Learning Alone

**Background.**
Sam is a public health analyst who will learn from the website alone and will never attend a workshop.

**What Sam can already do.**
Sam analyses data in R and met likelihoods in a statistics course years ago.

**What Sam needs.**
Sam needs random-effects models for clinic-level time series: a baseline rate that drifts from month to month, and clinics that share information.

**How the lesson helps.**
Every episode runs on its own: Episodes 1 and 2 start from the data file, and from Episode 3 on, the Starting Point box at the top recreates everything the episode needs.
Every challenge has a full solution: the code and its output where there is code, and an explanation of every answer.
The [glossary](../learners/reference.md#glossary) and the "In Your Field" notes do not assume any knowledge of salmon.
The [Recipe Index](../learners/recipe-index.md) answers "which recipe do I need?" on one page.

## Who the Lesson Is Not For

- People who are new to R.
  Take an introductory R lesson first, such as [Data Carpentry's R for Ecologists][r-ecology].
- People who already use TMB and want C++ templates or derivations.
  The [Going Further](../learners/going-further.md) page points to the RTMB and TMB documentation and to the original workshop materials.
