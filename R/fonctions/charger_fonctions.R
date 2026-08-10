# =============================================================================
# charger_fonctions.R
# Chargement de toute la bibliothèque personnelle de fonctions biostat
# =============================================================================
# Usage : source("/Users/kouadio/Desktop/DOSSIERS BUREAU/ENSEMBLE_FONCTIONS/charger_fonctions.R")
# =============================================================================

#.FONCTIONS_DIR <- "/Users/kouadio/Desktop/DOSSIERS BUREAU/ENSEMBLE_FONCTIONS"
.FONCTIONS_DIR <- here::here("R/fonctions")

.sourcer_rmd <- function(fichier) {
  chemin <- file.path(.FONCTIONS_DIR, fichier)
  tmp <- tempfile(fileext = ".R")
  knitr::purl(chemin, output = tmp, quiet = TRUE, documentation = 0L)
  source(tmp, local = FALSE)
  invisible(NULL)
}

# -----------------------------------------------------------------------------
# Chargement des modules dans l'ordre
# -----------------------------------------------------------------------------
message("── Chargement bibliothèque personnelle ──────────────────────────────")

message("  01 · Utilitaires (typage, transformation, manipulation)")
.sourcer_rmd("01_utilitaires.Rmd")

message("  02 · Qualité & données manquantes")
.sourcer_rmd("02_qualite_manquantes.Rmd")

message("  03 · Statistiques descriptives & visualisation")
.sourcer_rmd("03_statistiques_viz.Rmd")

message("  04 · Modélisation & Machine Learning")
.sourcer_rmd("04_modelisation.Rmd")

message("  05 · Export & tableaux Word")
.sourcer_rmd("05_export.Rmd")

message("  06 · Survie & données hospitalières")
.sourcer_rmd("06_survie.Rmd")

message("── Bibliothèque chargée ✓ ───────────────────────────────────────────")
