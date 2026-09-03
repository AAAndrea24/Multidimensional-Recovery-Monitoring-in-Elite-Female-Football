# ==============================================================================
# 07_sensitivity_influence.R
#
# Influence diagnostics via Cook's distance, and model refitting after
# excluding influential observations (threshold: 4/n), to evaluate the
# robustness of the final SQ and TQR models.
# Run 04_lmm_sleep_quality.R and 05_lmm_recovery_quality.R first so that
# `m_sq_final` and `m_tqr_final` exist.
# ==============================================================================

library(lme4)
library(influence.ME)

# ---- Sleep Quality (SQ) ------------------------------------------------------
infl_sq <- influence(m_sq_final, obs = TRUE)
plot(infl_sq, which = "cook")

cook_sq       <- cooks.distance(infl_sq)
influential_sq <- which(cook_sq > 4 / length(cook_sq))

night_df_clean_sq <- night_df[-influential_sq, ]

m_sq_sensitivity <- lmer(
  sq ~ totalsleeptime_c + sleeplatency_c + waso_c + n_awk_c + t_md_r +
    (1 + totalsleeptime_c | id),
  data = night_df_clean_sq
)

summary(m_sq_final)
summary(m_sq_sensitivity)   # consistent results after excluding 39 obs (5.7%)

# ---- Total Quality of Recovery (TQR) -----------------------------------------
# A random-intercept-only proxy model is used to compute Cook's distance,
# avoiding the convergence issues associated with the random-slope structure.
m_tqr_influence_proxy <- lmer(
  tqr ~ totalsleeptime_c + sleeplatency_c + waso_c + n_awk_c + t_md_r +
    (1 | id),
  data = night_df, REML = FALSE
)

infl_tqr <- influence(m_tqr_influence_proxy, obs = TRUE)
plot(infl_tqr, which = "cook")

cook_tqr        <- cooks.distance(infl_tqr)
influential_tqr <- which(cook_tqr > 4 / length(cook_tqr))

night_df_clean_tqr <- night_df[-influential_tqr, ]

# Sensitivity model refitted with random intercept only, on the reduced
# data, as per the manuscript.
m_tqr_sensitivity <- lmer(
  tqr ~ totalsleeptime_c + sleeplatency_c + waso_c + n_awk_c + t_md_r +
    (1 | id),
  data = night_df_clean_tqr
)

summary(m_tqr_final)
summary(m_tqr_sensitivity)   # consistent results after excluding 47 obs (6.9%)
