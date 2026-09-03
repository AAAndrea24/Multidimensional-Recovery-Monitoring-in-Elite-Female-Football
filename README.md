# Sleep, Actigraphy and Recovery in Elite Female Football Players

Analysis code accompanying the manuscript on actigraphy-derived sleep
parameters, subjective sleep quality (SQ), and perceived recovery (TQR) in
elite female football players (S.S. Lazio Women, 2024-2025 season).

> **TODO before publishing / minting a DOI:** replace this placeholder with
> the manuscript title, author list, and journal/DOI once available (see also
> `CITATION.cff`).

## Repository structure

```
.
├── data/
│   └── README.md          # expected input file & column description (data not included)
├── scripts/
│   ├── 01_data_preparation.R        # import, QC filter, person-median centering
│   ├── 02_descriptive_statistics.R  # distributions, skewness/kurtosis, correlations
│   ├── 03_null_models_icc.R         # ICC + day-type LRT
│   ├── 04_lmm_sleep_quality.R       # SQ mixed model (backward elimination)
│   ├── 05_lmm_recovery_quality.R    # TQR mixed model (backward elimination)
│   ├── 06_model_diagnostics.R       # DHARMa + performance diagnostics
│   ├── 07_sensitivity_influence.R   # Cook's-distance sensitivity analysis
│   ├── 08_loso_cross_validation.R   # leave-one-subject-out CV + robustness table
│   └── 09_ordinal_sensitivity.R     # CLMM ordinal sensitivity analysis
├── LICENSE
├── CITATION.cff
└── .gitignore
```

Scripts are numbered and meant to be run in order; each one documents in its
header which previous script(s) it depends on.

## Requirements

- R >= 4.5.0
- Packages: `tidyverse`, `readxl`, `janitor`, `lme4`, `lmerTest`, `performance`,
  `DHARMa`, `influence.ME`, `ordinal`, `e1071`, `dplyr`

Install everything with:

```r
install.packages(c(
  "tidyverse", "readxl", "janitor", "lme4", "lmerTest", "performance",
  "DHARMa", "influence.ME", "ordinal", "e1071"
))
```

## Data availability

The raw actigraphy and questionnaire data are not included in this
repository because they contain individually identifiable athlete-level
health information collected under an IRB-approved protocol (University
Niccolò Cusano, protocol MO3/22). Data are available from the corresponding
author upon reasonable request, subject to institutional approval. See
`data/README.md` for the exact file/column layout expected by the scripts.

## Note on the primary HRV outcome

The manuscript's primary HRV analysis (`LnRMSSD ~ total sleep time + sleep
efficiency + (1 | id)`, Table 3) was not present in the R script supplied for
this cleanup and is therefore not yet included here. Add an
`0X_lmm_hrv.R` script following the same structure as scripts 04-05 once the
corresponding HRV data-preparation code is available.

## License

Code released under the MIT License (see `LICENSE`).

## Citing this repository

If you use this code, please cite it via the metadata in `CITATION.cff`
(auto-rendered by GitHub, and used by Zenodo when minting the DOI).
