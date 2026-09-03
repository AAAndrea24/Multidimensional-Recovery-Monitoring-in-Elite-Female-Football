# ==============================================================================
# 01_data_preparation.R
#
# Imports the raw actigraphy and daily-questionnaire data, applies a
# physiological-plausibility filter, keeps only athletes meeting the
# longitudinal-completeness criterion, and derives the person-median-centered
# predictor variables used by every downstream model (scripts 02-09).
# ==============================================================================

library(tidyverse)
library(readxl)
library(janitor)

# ---- Paths ------------------------------------------------------------------
# Place the raw file in data/lazio_statistics.xlsx before running (see
# data/README.md for the expected sheet layout and column names).
data_path <- file.path("data", "lazio_statistics.xlsx")

# ---- Import -------------------------------------------------------------
# Sheet 1: nightly actigraphy variables (GGIR output)
# Sheet 3: daily subjective Sleep Quality (SQ) and Total Quality of Recovery (TQR)
sleep <- read_xlsx(data_path, sheet = 1) %>%
  clean_names() %>%
  mutate(
    id = as.character(id),
    date = as.POSIXct(date, format = "%Y-%m-%d"),
    t_md_r = factor(t_md_r, levels = c("R", "T", "MD")) # Rest / Training / Match Day
  )

tqrsq <- read_xlsx(data_path, sheet = 3) %>%
  clean_names() %>%
  mutate(
    id = as.character(id),
    date = as.POSIXct(date, format = "%Y-%m-%d"),
    periods = factor(periods)
  )

# ---- Physiological plausibility filter --------------------------------------
# Removes nights with implausible actigraphy values (e.g. device/wear artefacts).
sleep_clean <- sleep %>%
  filter(
    totalsleeptime  >= 180, totalsleeptime  <= 720,  # 3-12 h
    sleeplatency    >= 0,   sleeplatency    <= 180,  # 0-3 h
    sleepefficiency >= 50,  sleepefficiency <= 100,  # %
    timeinbed       >= 240, timeinbed       <= 900   # 4-15 h
  )

# ---- Longitudinal-completeness criterion ------------------------------------
# Only athletes with >= 7 nights of data in >= 3 bi-weekly assessment periods
# are retained, to preserve the longitudinal integrity of the dataset.
min_nights     <- 7
min_timepoints <- 3

sleep_nights <- sleep_clean %>%
  group_by(id, time) %>%
  summarise(n_nights = n(), .groups = "drop")

ids_keep <- sleep_nights %>%
  group_by(id) %>%
  summarise(n_timepoints = sum(n_nights >= min_nights), .groups = "drop") %>%
  filter(n_timepoints >= min_timepoints) %>%
  pull(id)

# ---- Build the analysis-ready, night-by-night dataset -----------------------
# Sleep predictors are centered on each athlete's own median (person-median
# centering) to isolate within-athlete, day-to-day fluctuations from
# between-athlete (habitual) differences, per the Statistical Analysis section.
night_df <- sleep_clean %>%
  filter(id %in% ids_keep) %>%
  select(id, date, t_md_r, totalsleeptime, timeinbed, sleepefficiency,
         sleeplatency, waso, n_awk, sleepregularityindex) %>%
  left_join(
    tqrsq %>% select(id, date, sq, tqr, periods),
    by = c("id", "date")
  ) %>%
  filter(!is.na(sq) | !is.na(tqr)) %>%
  group_by(id) %>%
  mutate(
    totalsleeptime_c       = (totalsleeptime - median(totalsleeptime, na.rm = TRUE)) / 60, # hours
    timeinbed_c            = (timeinbed - median(timeinbed, na.rm = TRUE)) / 60,           # hours
    sleepefficiency_c      = sleepefficiency - median(sleepefficiency, na.rm = TRUE),      # percentage points
    sleeplatency_c         = (sleeplatency - median(sleeplatency, na.rm = TRUE)) / 60,     # hours
    waso_c                 = (waso - median(waso, na.rm = TRUE)) / 60,                     # hours
    n_awk_c                = n_awk - median(n_awk, na.rm = TRUE),                          # count deviation
    sleepregularityindex_c = sleepregularityindex - median(sleepregularityindex, na.rm = TRUE)
  ) %>%
  ungroup()

# `night_df` is the dataset used by every downstream script (02-09).
