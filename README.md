# LESSON_TITLE

LESSON_PITCH

This is a lesson in the style of [Data Carpentry](https://datacarpentry.org/),
built with [The Carpentries Workbench][workbench].
It is not an official Carpentries lesson.

It was developed from the materials of the RTMB workshop taught by the Pacific Salmon Commission in
November 2026, but it is a new lesson: a cookbook that shows one recommended way to do each task,
starts with a quick start that runs the whole workflow, and adds model selection and model evaluation.

## What is in this repository

| Path | What it is |
|---|---|
| `episodes/` | The lesson, one R Markdown file per episode |
| `episodes/data/` | The data learners use: `sockeye.csv` and `npgo.csv` |
| `learners/` | Setup instructions, glossary and other pages for learners |
| `instructors/` | Notes for instructors |
| `profiles/` | Learner profiles: who the lesson is for |
| `scripts/prepare-data.R` | How the data files were made from the original workshop data (in `scripts/raw/`) |
| `config.yaml` | Lesson settings and episode order |

## Build the lesson locally

You need R (4.1 or later), [pandoc](https://pandoc.org/installing.html) (2.11 or later; RStudio includes it), and the Workbench packages:

```r
install.packages(c("sandpaper", "varnish", "pegboard", "tinkr"),
                 repos = c("https://carpentries.r-universe.dev/", getOption("repos")))
install.packages(c("RTMB", "dplyr", "ggplot2"))
```

Then, from the root of this repository:

```r
sandpaper::build_lesson()   # builds the site and opens a preview in your browser
sandpaper::check_lesson()   # checks the lesson structure
```

The built site is in `site/docs/`.

## Publishing the website

The workflows in `.github/workflows/` build the site on GitHub and publish it to the `gh-pages` branch.
GitHub Pages can serve a site from a **private** repository only on paid GitHub plans.
On a free plan, either make the repository public or build the lesson locally and share the files in `site/docs/`.

The first build on GitHub installs the R packages the lesson needs.
If it reports missing packages, run the "02 Maintain: Check for Updated Packages" workflow from the Actions tab,
merge the pull request it opens, and the site will rebuild.

## Data

The sockeye salmon spawner and recruit data for 19 Fraser River stocks, and the North Pacific Gyre Oscillation index,
come from the original workshop repository. `scripts/prepare-data.R` documents every change made to them.
The workshop described the salmon data as "not necessarily official numbers": they are for teaching, not management advice.

## License and credit

See `LICENSE.md`. The license there is the Carpentries default that comes with the template.
The original workshop materials do not state a license, so confirm with their authors before you publish this lesson.

## Maintainer

LESSON_MAINTAINER

[workbench]: https://carpentries.github.io/sandpaper-docs/
