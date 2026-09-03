# ==============================================================================
# 03_null_models_icc.R
#
# Null (intercept-only) models and Intraclass Correlation Coefficients (ICC)
# to quantify between-athlete clustering and justify the multilevel approach,
# plus likelihood ratio tests (LRT) for whether day type (Rest/Training/Match
# Day) should be included as a fixed effect in the SQ and TQR models.
# Run 01_data_preparation.R first so that `night_df` exists.
# ==============================================================================

library(lme4)
library(lmerTest)
library(performance)

# ---- Sleep Quality (SQ) ------------------------------------------------------
m0_sq        <- lmer(sq  ~ 1 + (1 | id), data = night_df, REML = TRUE)
m0_sq_t_md_r <- lmer(sq  ~ 1 + t_md_r + (1 | id), data = night_df, REML = TRUE)

performance::icc(m0_sq)         # ICC = 0.31 in the manuscript
anova(m0_sq, m0_sq_t_md_r)      # day type significantly improves fit (p < .001)

# ---- Total Quality of Recovery (TQR) -----------------------------------------
m0_tqr        <- lmer(tqr ~ 1 + (1 | id), data = night_df, REML = TRUE)
m0_tqr_t_md_r <- lmer(tqr ~ 1 + t_md_r + (1 | id), data = night_df, REML = TRUE)

performance::icc(m0_tqr)        # ICC = 0.51 in the manuscript
anova(m0_tqr, m0_tqr_t_md_r)    # day type significantly improves fit (p < .001)
