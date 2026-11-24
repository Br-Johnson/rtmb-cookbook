## Build the two data files used in the lesson from the data supplied with the
## PSC RTMB workshop (November 2026). Run from the root of this repository:
##   Rscript scripts/prepare-data.R
## Input files are in scripts/raw/ (copied unchanged from the workshop repository).

raw <- "scripts/raw"
sr    <- read.csv(file.path(raw, "SRDATA2026 1.csv"))
stock <- read.csv(file.path(raw, "FC_StockInfo 2.csv"))
npgo  <- read.csv(file.path(raw, "NPGO.csv"))

sockeye <- merge(sr, stock, by = "PopID")
sockeye <- sockeye[sockeye$Species == "Sockeye", ]
# keep brood years where both spawners and recruits are known
sockeye <- sockeye[!is.na(sockeye$spawners) & !is.na(sockeye$recruits), ]

sockeye <- data.frame(
  stock           = sockeye$PopName,
  management_unit = sockeye$MU,
  brood_year      = sockeye$yr,
  spawners        = round(sockeye$spawners * 1000, 3),  # thousands of fish
  recruits        = round(sockeye$recruits * 1000, 3)   # thousands of fish
)
sockeye$management_unit <- c(EarlyStuart = "Early Stuart", EarlySummer = "Early Summer",
                             Summer = "Summer", Late = "Late")[sockeye$management_unit]
sockeye <- sockeye[order(sockeye$stock, sockeye$brood_year), ]
write.csv(sockeye, "episodes/data/sockeye.csv", row.names = FALSE)

npgo <- data.frame(year = npgo$year, npgo = round(npgo$NPGO, 3))
write.csv(npgo, "episodes/data/npgo.csv", row.names = FALSE)

cat("sockeye.csv:", nrow(sockeye), "rows,", length(unique(sockeye$stock)), "stocks, brood years",
    paste(range(sockeye$brood_year), collapse = "-"), "\n")
cat("npgo.csv:", nrow(npgo), "rows, years", paste(range(npgo$year), collapse = "-"), "\n")
