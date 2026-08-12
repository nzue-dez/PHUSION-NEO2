# ─────────────────────────────────────────────────────────────────────────────
# analyse.R — Script principal
# Appelle les modules R/ dans l'ordre
# ─────────────────────────────────────────────────────────────────────────────

source(here::here("R/load_functions.R"))
source(here::here("R/data_management.R"))
source(here::here("R/descriptive.R"))
source(here::here("R/missing_analysis.R"))
source(here::here("R/statistical_models.R"))
source(here::here("R/model_diagnostics.R"))
source(here::here("R/visualization.R"))
# NB: pas de survival_analysis.R — tout modèle (y compris survie) se fait dans statistical_models.R
