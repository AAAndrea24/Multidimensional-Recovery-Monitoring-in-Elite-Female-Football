# ==============================================================================
# 04_lmm_sleep_quality.R
#
# Linear mixed-effects model for subjective Sleep Quality (SQ), built by
# backward elimination of non-informative predictors, guided by likelihood
# ratio tests (LRT) and AIC/BIC (see manuscript Statistical Analysis section).
# Run 01_data_preparation.R first so that `night_df` exists.
# ==============================================================================

library(lme4)
library(lmerTest)

# Full model: all actigraphy predictors + day type; random intercept and
# random slope for total sleep time by athlete.
m_sq_full <- lmer(
  sq ~ totalsleeptime_c + sleeplatency_c + sleepefficiency_c + waso_c + n_awk_c + t_md_r +
    (1 + totalsleeptime_c | id),
  data = night_df, REML = FALSE
)
summary(m_sq_full)

# Step 1: drop sleep efficiency (p = .99, non-informative).
# --> This is the model reported in Table 4 of the manuscript.
m_sq_final <- lmer(
  sq ~ totalsleeptime_c + sleeplatency_c + waso_c + n_awk_c + t_md_r +
    (1 + totalsleeptime_c | id),
  data = night_df, REML = FALSE
)
summary(m_sq_final)

# Exploratory step (NOT adopted as the final model): further dropping number
# of awakenings, which was non-significant on its own (p = .135). It was kept
# in m_sq_final for structural consistency with the TQR model, per the
# manuscript's rationale.
m_sq_drop_nawk <- lmer(
  sq ~ totalsleeptime_c + sleeplatency_c + waso_c + t_md_r +
    (1 + totalsleeptime_c | id),
  data = night_df, REML = FALSE
)

anova(m_sq_full, m_sq_final, m_sq_drop_nawk)
