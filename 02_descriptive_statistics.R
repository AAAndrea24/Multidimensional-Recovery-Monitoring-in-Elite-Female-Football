# ==============================================================================
# 02_descriptive_statistics.R
#
# Distribution checks (histograms/density, skewness, kurtosis) and a
# correlation matrix for the person-median-centered predictor variables.
# Run 01_data_preparation.R first so that `night_df` exists.
# ==============================================================================

library(tidyverse)
library(e1071)   # skewness() and kurtosis()

vars <- c("totalsleeptime_c", "timeinbed_c", "waso_c",
          "sleepefficiency_c", "sleeplatency_c", "n_awk_c",
          "sleepregularityindex_c")

# ---- Histograms + density overlay, one panel per variable -------------------
night_df %>%
  select(all_of(vars)) %>%
  pivot_longer(everything(), names_to = "var", values_to = "value") %>%
  ggplot(aes(value)) +
  geom_histogram(aes(y = after_stat(density)), bins = 30, fill = "grey75", color = "white") +
  geom_density(color = "black", linewidth = 0.7) +
  facet_wrap(~var, scales = "free") +
  theme_minimal()

# ---- Summary statistics: mean, SD, skewness, kurtosis -----------------------
stats <- night_df %>%
  select(all_of(vars)) %>%
  pivot_longer(everything(), names_to = "var", values_to = "value") %>%
  filter(is.finite(value)) %>%
  group_by(var) %>%
  summarise(
    mean = mean(value),
    sd = sd(value),
    skewness = skewness(value),
    kurtosis = kurtosis(value),
    n = n()
  )

print(stats)

# ---- Correlation matrix among centered predictors ---------------------------
# Used alongside the VIF checks in 06_model_diagnostics.R to screen for
# multicollinearity before model fitting.
cor(night_df[, vars], use = "complete.obs")
