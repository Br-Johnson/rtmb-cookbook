## Spell-check the prose of the lesson with hunspell (en_GB).
## Usage, from the lesson root: Rscript scripts/spell_check.R .  (needs the hunspell package)
## Code chunks, inline code, URLs, fenced-div lines, YAML and chunk options are removed first.
args <- commandArgs(trailingOnly = TRUE)
root <- args[1]
files <- c(list.files(file.path(root, "episodes"), "\\.Rmd$", full.names = TRUE),
           list.files(file.path(root, "learners"), "\\.md$", full.names = TRUE),
           list.files(file.path(root, "instructors"), "\\.md$", full.names = TRUE),
           list.files(file.path(root, "profiles"), "\\.md$", full.names = TRUE),
           file.path(root, "index.md"), file.path(root, "README.md"))
dict <- hunspell::dictionary("en_GB")
ignore <- c("Ricker", "Beverton", "Holt", "RTMB", "TMB", "NPGO", "Stellako", "Pitt", "Birkenhead",
            "Bowron", "Chilko", "Cultus", "Fennel", "Quesnel", "Raft", "Seymour", "Shuswap",
            "Stuart", "Nadina", "Portage", "Weaver", "Harrison", "AIC", "QQ", "CI", "PI", "MSY",
            "logRS", "dplyr", "ggplot", "RStudio", "Positron", "CRAN", "Posit", "Fraser",
            "sockeye", "Sockeye", "hindcast", "Hindcast", "hindcasts", "glmmTMB", "tmbstan",
            "lme", "Wald", "Laplace", "Hessian", "Akaike", "Parsons", "MakeADFun", "nlminb",
            "sdreport", "ADREPORT", "OBS", "getAll", "Smax", "Shalf", "Srep", "Rmax", "Smsy",
            "Umsy", "npgo", "pdHess", "Workbench", "Carpentries", "Carpentry", "GitHub",
            "Okabe", "Ito", "UK", "CSV", "csv", "MCQ", "SD", "SDs", "SE", "MAE", "dAIC", "Inf",
            "NaN", "NA", "sd", "walk's", "Ricker's", "alpha", "sigma", "mu", "exp", "lm", "glm",
            "ggplot2", "Rmd", "YAML", "REML", "Lambert", "AR", "GMRF", "ADjoint", "DataEval",
            "autoreg", "dautoreg", "dnorm", "dpois", "dbinom", "dlnorm", "dgamma", "sqrt",
            "qnorm", "pbinom", "uniroot", "sapply", "tapply", "mutate", "summarise", "rbind",
            "bind", "facet", "geom", "aes", "ymin", "ymax", "xintercept", "yintercept",
            "linetype", "stat", "qq", "ncol", "renv", "sandpaper", "pegboard", "varnish",
            "Ctrl", "Cmd", "macOS", "Ubuntu", "Debian", "Homebrew", "conda", "jammy", "noble",
            "Linux", "gfortran", "liblapack", "libblas", "BLAS", "LAPACK", "Rtools", "Xcode",
            "CARE", "GIDA", "PSC", "Dam", "Bates", "Mira", "Tomás", "Dana", "Sam",
            "LD", "Tomás", "tmbprofile", "confint", "Shapiro", "Wilk", "boxplot")
all_bad <- list()
for (f in files) {
  if (!file.exists(f)) next
  x <- readLines(f, warn = FALSE)
  # drop code chunks
  inchunk <- FALSE; keep <- logical(length(x))
  for (i in seq_along(x)) {
    if (startsWith(x[i], "```")) { inchunk <- !inchunk; keep[i] <- FALSE; next }
    keep[i] <- !inchunk
  }
  x <- x[keep]
  x <- x[!grepl("^:{3,}", x)]
  x <- x[!grepl("^\\s*(title|teaching|exercises):", x)]
  x <- gsub("`[^`]*`", " ", x)                  # inline code
  x <- gsub("\\$[^$]*\\$", " ", x)              # inline maths
  x <- gsub("https?://\\S+", " ", x)
  x <- gsub("\\[([^]]*)\\]\\([^)]*\\)", "\\1", x) # links -> text
  x <- gsub("[*_#|>]", " ", x)
  x <- gsub("\\b[A-Za-z]+_[A-Za-z_]+\\b", " ", x) # snake_case names
  words <- unlist(hunspell::hunspell(x, dict = dict, ignore = ignore))
  if (length(words)) all_bad[[basename(f)]] <- sort(table(words), decreasing = TRUE)
}
for (nm in names(all_bad)) {
  cat("==", nm, "\n")
  t <- all_bad[[nm]]
  cat(paste0(names(t), " (", t, ")"), sep = "  ")
  cat("\n")
}
