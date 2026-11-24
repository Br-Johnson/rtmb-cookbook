# RTMB Cookbook: Fit, Check, Compare and Forecast with Your Own Models

In two hands-on days you will write your own statistical model as a short R function, fit it with RTMB, check that the fit worked, compare it with other models and test its forecasts on years it never saw, using one tested recipe for each step and no proofs.

This is a lesson in the style of [Data Carpentry](https://datacarpentry.org/),
built with [The Carpentries Workbench][workbench].
It is not an official Carpentries lesson.

It was developed from the materials of the RTMB workshop hosted by the Pacific Salmon Commission in November 2026 (slides and examples by Paul van Dam-Bates).
It is a new lesson: a cookbook that shows one recommended way to do each task, starts with a quick start that runs the whole workflow, and adds model selection and model evaluation.

It is for people who analyse data in R and fit regressions with `lm()` or `glm()`, and who now need a model that a formula interface cannot write for them, or who must read and question such models.
The worked example is Fraser River sockeye salmon, explained from scratch; no fisheries background is needed.
[profiles/learner-profiles.md](profiles/learner-profiles.md) describes the learners it was designed for.

## What is in this repository

| Path | What it is |
|---|---|
| `index.md` | The home page: what the lesson is, who it is for and the prerequisites (the built site adds the Setup page to it) |
| `episodes/` | The lesson, one R Markdown file per episode |
| `episodes/data/` | The data learners use: `sockeye.csv` and `npgo.csv` |
| `episodes/files/` | The scripts learners download: `quick-start.R`, `cookbook.R` (the finished recipe box) and `capstone-template.R` |
| `episodes/fig/` | Static figures (SVG) used in the episodes |
| `learners/` | Setup instructions, the Recipe Index, troubleshooting, the glossary and further reading |
| `instructors/` | Instructor notes and the lesson design record |
| `profiles/` | Learner profiles: who the lesson is for |
| `scripts/prepare-data.R` | How the data files were made from the original workshop data (in `scripts/raw/`) |
| `config.yaml` | Lesson settings and episode order |
| `links.md` | Links shared by every page of the lesson |
| `CITATION.cff` | How to cite the lesson |
| `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `LICENSE.md` | The code of conduct, how to contribute, and the licences |

## Build the lesson locally

You need:

- R: a current release is easiest, because CRAN builds ready-made Windows and macOS packages only for the latest and the previous R version; with an older R, RTMB is compiled from source, which needs a C++ compiler (Rtools on Windows, the Xcode command line tools on macOS);
- [pandoc](https://pandoc.org/installing.html) 2.11.4 or later (RStudio includes it);
- the Workbench packages and the three packages the lesson uses:

```r
install.packages(c("sandpaper", "varnish", "pegboard", "tinkr"),
                 repos = c("https://carpentries.r-universe.dev/", getOption("repos")))
install.packages(c("RTMB", "dplyr", "ggplot2"))
```

On Linux, CRAN packages are compiled from source, which needs C and C++ compilers and the development files of several system libraries.
To install ready-made packages from Posit Public Package Manager instead, run this line first, then the two `install.packages()` lines above:

```r
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"))
```

Replace `noble` (Ubuntu 24.04) with your distribution's code name, for example `jammy` for Ubuntu 22.04.

Then, from the root of this repository:

```r
sandpaper::build_lesson()                     # builds the site and opens a preview in your browser
sandpaper::check_lesson()                     # checks the lesson structure
sandpaper::validate_lesson(headings = TRUE)   # checks divs, links, images and headings
```

The built site is in `site/docs/`.
The lesson was developed and tested with R 4.3.3, RTMB 2.0, TMB 1.9.25, sandpaper 0.21.2 and pandoc 3.1.3.
The build knits every episode in a fresh R session and stops at any R error that is not in a chunk marked `error=TRUE` (`fail_on_error: true` in `config.yaml`).
`episodes/files/cookbook.R` must stay identical to the code taught in the episodes: if you change a recipe, change both.

## Publishing the website

The workflows in `.github/workflows/` build the site on GitHub and publish it to the `gh-pages` branch.
GitHub Pages can serve a site from a **private** repository only on paid GitHub plans.
On a free plan, either make the repository public or build the lesson locally and share the files in `site/docs/`.

The first build on GitHub installs the R packages the lesson needs.
If it reports missing packages, run the "02 Maintain: Check for Updated Packages" workflow from the Actions tab, merge the pull request it opens, and the site will rebuild.

## Data

The sockeye salmon spawner and recruit data for 19 Fraser River stocks, and the North Pacific Gyre Oscillation index, come from the original workshop repository.
`scripts/prepare-data.R` documents every change made to them.
The workshop described the salmon data as "not necessarily official numbers": they are for teaching, not management advice.

## Licence and credit

The licences are in `LICENSE.md`: the Carpentries defaults from the template (CC BY 4.0 for the lesson, MIT for the code), with a note at the top about the original workshop materials.
The original workshop materials (slides and examples by Paul van Dam-Bates) do not state a licence, so confirm with their authors before you publish this lesson.

To cite the lesson, use `CITATION.cff`; the built site shows the citation on its "Cite" page.

## Maintainer

Br-Johnson (GitHub)

[workbench]: https://carpentries.github.io/sandpaper-docs/
