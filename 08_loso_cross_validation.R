# ==============================================================================
# 08_loso_cross_validation.R
#
# Leave-one-subject-out cross-validation (LOSO-CV) to assess the stability
# of fixed-effect coefficients across participants, and the resulting
# robustness classification (Robust: CV < 10%; Moderate: 10-20%;
# Unstable: > 20%). Run 01_data_preparation.R, 04_lmm_sleep_quality.R and
# 05_lmm_recovery_quality.R first.
# ==============================================================================

library(lme4)
library(dplyr)

ids <- unique(night_df$id)

# ---- Sleep Quality (SQ) ------------------------------------------------------
results_sq <- lapply(ids, function(i) {
  data_i  <- filter(night_df, id != i)
  model_i <- lmer(
    sq ~ totalsleeptime_c + sleeplatency_c + waso_c + n_awk_c + t_md_r +
      (1 + totalsleeptime_c | id),
    data = data_i
  )
  fixef(model_i)
})

sq_df <- do.call(rbind, results_sq)
boxplot(sq_df, main = "LOSO-CV - SQ model coefficient stability")
abline(h = 0, lty = 2)

# ---- Total Quality of Recovery (TQR) -----------------------------------------
# Random slope covariance constrained to zero (||) during LOSO-CV to prevent
# singular fits, as noted in the manuscript.
results_tqr <- lapply(ids, function(i) {
  data_i  <- filter(night_df, id != i)
  model_i <- lmer(
    tqr ~ totalsleeptime_c + sleeplatency_c + waso_c + n_awk_c + t_md_r +
      (1 + totalsleeptime_c || id),
    data = data_i
  )
  fixef(model_i)
})

tqr_df <- do.call(rbind, results_tqr)
boxplot(tqr_df, main = "LOSO-CV - TQR model coefficient stability")
abline(h = 0, lty = 2)

# ---- Coefficient of variation and robustness classification -----------------
classify_stability <- function(cv_values) {
  cut(cv_values,
      breaks = c(-Inf, 0.10, 0.20, Inf),
      labels = c("ROBUST", "MODERATE", "UNSTABLE"))
}

sq_cv <- apply(sq_df, 2, function(x) sd(x) / abs(mean(x)))
sq_summary <- data.frame(variable = names(sq_cv), cv = as.numeric(sq_cv))
sq_summary$stability <- classify_stability(sq_summary$cv)
sq_summary$beta <- fixef(m_sq_final)[match(sq_summary$variable, names(fixef(m_sq_final)))]
sq_summary <- sq_summary[, c("variable", "beta", "cv", "stability")]
print(sq_summary)

tqr_cv <- apply(tqr_df, 2, function(x) sd(x) / abs(mean(x)))
tqr_summary <- data.frame(variable = names(tqr_cv), cv = as.numeric(tqr_cv))
tqr_summary$stability <- classify_stability(tqr_summary$cv)
tqr_summary$beta <- fixef(m_tqr_final)[match(tqr_summary$variable, names(fixef(m_tqr_final)))]
tqr_summary <- tqr_summary[, c("variable", "beta", "cv", "stability")]
print(tqr_summary)
