# ==============================================================================
# 05_lmm_recovery_quality.R
#
# Linear mixed-effects model for perceived recovery (Total Quality of
# Recovery, TQR), built by backward elimination of non-informative
# predictors, guided by likelihood ratio tests (LRT) and AIC/BIC.
# Run 01_data_preparation.R first so that `night_df` exists.
# ==============================================================================

library(lme4)
library(lmerTest)

# Full model: all actigraphy predictors + day type; random intercept and
# random slope for total sleep time by athlete.
m_tqr_full <- lmer(
  tqr ~ totalsleeptime_c + sleeplatency_c + sleepefficiency_c + waso_c + n_awk_c + t_md_r +
    (1 + totalsleeptime_c | id),
  data = night_df, REML = FALSE
)
summary(m_tqr_full)

# Step 1: drop sleep latency (p = .35).
m_tqr_step2 <- lmer(
  tqr ~ totalsleeptime_c + sleepefficiency_c + waso_c + n_awk_c + t_md_r +
    (1 + totalsleeptime_c | id),
  data = night_df, REML = FALSE
)
summary(m_tqr_step2)

# Step 2: drop sleep efficiency (p = .31).
# --> This is the model reported in Table 4 of the manuscript.
m_tqr_final <- lmer(
  tqr ~ totalsleeptime_c + sleeplatency_c + waso_c + n_awk_c + t_md_r +
    (1 + totalsleeptime_c | id),
  data = night_df, REML = FALSE
)
summary(m_tqr_final)

# Exploratory step (NOT adopted as the final model): dropping both sleep
# latency and sleep efficiency together, kept here only to document the
# full backward-elimination path via the LRT comparison below.
m_tqr_drop_both <- lmer(
  tqr ~ totalsleeptime_c + waso_c + n_awk_c + t_md_r +
    (1 + totalsleeptime_c | id),
  data = night_df, REML = FALSE
)

anova(m_tqr_full, m_tqr_step2, m_tqr_final, m_tqr_drop_both)
