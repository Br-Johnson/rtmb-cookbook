---
title: Setup
---

Set up your computer before the workshop: it takes about 20 minutes, longer on Linux.
At the end, a short script tells you whether everything works.

## Data Sets and Files

Make a project folder (an RStudio or Positron project) with two subfolders, `data/` and `files/`, and two empty scripts, `my-recipes.R` (your recipe box) and `report-card.R` (your report card).
In RStudio, use File > New Project > New Directory > New Project.
In Positron, make a new folder and open it with File > Open Folder.

Download these two data files into `data/`:

- [the sockeye salmon data (sockeye.csv)](../episodes/data/sockeye.csv);
- [the ocean index data (npgo.csv)](../episodes/data/npgo.csv).

Download these three R scripts into `files/`:

- [the Quick Start script (quick-start.R)](../episodes/files/quick-start.R), the whole Quick Start in one file, if you fall behind;
- [the finished recipe box (cookbook.R)](../episodes/files/cookbook.R), every function the lesson teaches, used to catch up at the start of each episode;
- [the capstone template (capstone-template.R)](../episodes/files/capstone-template.R), used on Day 2.

Your project folder should then look like this:

```text
my-project/
|-- data/
|   |-- npgo.csv
|   `-- sockeye.csv
|-- files/
|   |-- capstone-template.R
|   |-- cookbook.R
|   `-- quick-start.R
|-- my-recipes.R
`-- report-card.R
```

Every path in the lesson, such as `read.csv("data/sockeye.csv")`, assumes that R is running in this project folder.

Table: The two data files. Spawners and recruits are in thousands of fish: 9.242 means 9242 fish.

| File | Column | Meaning | Units |
|:---|:---|:---|:---|
| `sockeye.csv` | `stock` | one of 19 Fraser River sockeye salmon stocks | |
| | `management_unit` | Early Stuart (1 stock), Early Summer (7), Summer (6), Late (5) | |
| | `brood_year` | year the parents spawned, 1948-2022 | year |
| | `spawners` | adults that spawned in the brood year | thousands of fish |
| | `recruits` | adult offspring produced by those spawners (caught or returning), all ages | thousands of fish |
| `npgo.csv` | `year` | calendar year, 1950-2026 | year |
| | `npgo` | North Pacific Gyre Oscillation index (ocean conditions; higher usually means more food) | index (mean -0.18, SD 1.05) |

`sockeye.csv` has 1245 rows, with no zeros and no missing values.
Some stocks start after 1948, and three stocks (Cultus, Portage and Scotch Creek) have missing brood years; every recipe in the lesson handles them.

## Software Setup

You need:

- R 4.1 or later, from [CRAN, the R download site](https://cran.r-project.org/);
- [RStudio Desktop](https://posit.co/download/rstudio-desktop/) or [Positron](https://positron.posit.co/);
- the R packages RTMB, dplyr and ggplot2.

The lesson was tested with R 4.3.3, RTMB 2.0 and TMB 1.9.25.
Install the packages by running this in the R console:

```r
install.packages(c("RTMB", "dplyr", "ggplot2"))
```

TMB is installed with RTMB.
To find out which versions you have, run `R.version.string` and `packageVersion("RTMB")`.

:::::::::::::::::::::::::::::::::::::::: spoiler

### Windows

R installs ready-made (binary) versions of RTMB, dplyr and ggplot2, so you do not need a compiler.
If R asks "Do you want to install from sources the packages which need compilation?", answer `no`.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: spoiler

### macOS

R installs ready-made (binary) versions of RTMB, dplyr and ggplot2, so you do not need a compiler.
If R asks "Do you want to install from sources the packages which need compilation?", answer `no`.

::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::: spoiler

### Linux

On Linux, R compiles RTMB from its source code.
This needs a C++ compiler, for example on Debian or Ubuntu:

```bash
sudo apt install build-essential
```

Compiling RTMB and TMB takes several minutes, so install the packages before the workshop, not on the day.

::::::::::::::::::::::::::::::::::::::::::::::::::

## Check Your Setup

Run this from your project folder.
It must print `Your setup works.`

Copy the code into a new script, save it in your project folder (for example as `setup-check.R`) and run all of it.

```r
library(RTMB)
library(dplyr)
library(ggplot2)
sockeye <- read.csv("data/sockeye.csv")
npgo    <- read.csv("data/npgo.csv")
nll_check <- function(par, dat) {
  getAll(par, dat)
  -sum(dnorm(y, mean_y, exp(log_sd), log = TRUE))
}
dat_check <- list(y = log(sockeye$recruits / sockeye$spawners))
obj <- MakeADFun(function(p) nll_check(p, dat_check), list(mean_y = 0, log_sd = 0), silent = TRUE)
opt <- nlminb(obj$par, obj$fn, obj$gr)
if (nrow(sockeye) == 1245 && nrow(npgo) == 77 && opt$convergence == 0) {
  cat("Your setup works.\n")
} else {
  cat("Something is wrong: see the Setup page.\n")
}
```

```output
Your setup works.
```

Loading dplyr also prints a message that some objects (`filter`, `lag`, `intersect` and others) are masked.
That is normal.

If the check does not print `Your setup works.`:

- `there is no package called 'RTMB'` (or another package): run the `install.packages()` line again and read its messages.
- `cannot open the connection`, with the warning `cannot open file 'data/sockeye.csv': No such file or directory`: R is not running in your project folder, or the file is not in `data/`. Open the project and try again.
- `Something is wrong: see the Setup page.`: a data file is incomplete. Download both files again (`sockeye.csv` has 1245 rows and `npgo.csv` has 77).

The [Troubleshooting](troubleshooting.md) page lists other messages and what to do about them.

## Before You Come

Answer these three questions without running R.
They test the R and statistics the lesson assumes.

1. What does `f <- function(x, k = 2) x * k; f(c(1, 3))` print?
   (a) `2 6`; (b) `1 3 2`; (c) an error; (d) `8`.
2. A regression slope is 0.50 with standard error 0.10. Which is the best reading?
   (a) about 95% of the data lie between 0.3 and 0.7;
   (b) a plausible range for the true slope is about 0.3 to 0.7;
   (c) the slope is wrong by 0.10;
   (d) 10% of the points are outliers.
3. `x <- list(a = 1, b = "z")`. What does `x$b` return?

:::::::::::::::::::::::::::::::::::::::: spoiler

### Answers

1. (a) `2 6`. `k` takes its default value, 2, and `x * k` multiplies each element of the vector `c(1, 3)` by 2.
2. (b). Plus or minus about two standard errors gives a plausible range for the slope itself (here 0.3 to 0.7). The standard error describes the estimate, not the spread of the data (a), it is not the size of the error (c), and it says nothing about outliers (d).
3. `"z"`. `$` extracts the element named `b` from the list.

::::::::::::::::::::::::::::::::::::::::::::::::::

If two of the three are hard, take an introductory R lesson first, such as Data Carpentry's [R for Ecologists](https://datacarpentry.org/R-ecology-lesson/).
