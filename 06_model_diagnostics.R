# ==============================================================================
# 06_model_diagnostics.R
#
# Simulation-based residual diagnostics (DHARMa) and collinearity /
# heteroscedasticity / normality checks (performance) for the final SQ and
# TQR models. Run 04_lmm_sleep_quality.R and 05_lmm_recovery_quality.R first
# so that `m_sq_final` and `m_tqr_final` exist.
# ==============================================================================

library(DHARMa)
library(performance)

# ---- Sleep Quality (SQ) ------------------------------------------------------
sim_sq <- simulateResiduals(m_sq_final)
plot(sim_sq)                 # QQ plot + residuals vs. fitted
testDispersion(sim_sq)
testOutliers(sim_sq)
# Note: DHARMa flags non-uniformity of residuals for SQ (p < .001), likely
# attributable to the discrete ordinal nature of the scale -- see
# 09_ordinal_sensitivity.R for the ordinal-model sensitivity check.

check_collinearity(m_sq_final)        # all VIF < 2 in the manuscript
check_heteroscedasticity(m_sq_final)
check_outliers(m_sq_final)            # leverage-based
check_normality(m_sq_final, effects = "random")

# ---- Total Quality of Recovery (TQR) -----------------------------------------
sim_tqr <- simulateResiduals(m_tqr_final)
plot(sim_tqr)
testDispersion(sim_tqr)
testOutliers(sim_tqr)

check_collinearity(m_tqr_final)
check_heteroscedasticity(m_tqr_final)
check_outliers(m_tqr_final)
check_normality(m_tqr_final, effects = "random")
