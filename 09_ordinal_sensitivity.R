# ==============================================================================
# 09_ordinal_sensitivity.R
#
# Cumulative Link Mixed Model (ordinal logistic mixed model) sensitivity
# analysis. SQ is a discrete 5-point Likert scale, so it is refitted here as
# an ordinal outcome to validate the linear-model results reported in
# 04_lmm_sleep_quality.R and 05_lmm_recovery_quality.R.
# Run 01_data_preparation.R, 04_lmm_sleep_quality.R and
# 05_lmm_recovery_quality.R first.
# ==============================================================================

library(ordinal)

night_df$sq_factor  <- factor(night_df$sq,  ordered = TRUE)
night_df$tqr_factor <- factor(night_df$tqr, ordered = TRUE)

m_sq_ordinal <- clmm(
  sq_factor ~ totalsleeptime_c + sleeplatency_c + waso_c + t_md_r + (1 | id),
  data = night_df,
  link = "logit"
)
summary(m_sq_ordinal)
exp(coef(m_sq_ordinal))   # odds ratios, reported in the manuscript

m_tqr_ordinal <- clmm(
  tqr_factor ~ totalsleeptime_c + sleeplatency_c + waso_c + t_md_r + (1 | id),
  data = night_df,
  link = "logit"
)
summary(m_tqr_ordinal)
exp(coef(m_tqr_ordinal))

# ---- Compare direction/significance against the final linear mixed models --
summary(m_sq_final)
summary(m_tqr_final)
