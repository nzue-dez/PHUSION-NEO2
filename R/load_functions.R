# ─────────────────────────────────────────────────────────────────────────────
# load_functions.R
# Chargement des packages et de la bibliothèque personnelle
# ─────────────────────────────────────────────────────────────────────────────

# Bibliothèque personnelle de fonctions
#source("/Users/kouadio/Desktop/DOSSIERS BUREAU/ENSEMBLE_FONCTIONS/charger_fonctions.R")
source(here::here("R/fonctions/charger_fonctions.R"))

# Packages du projet
library(broom)
library(gtsummary)
library(tidyverse)
library(here)
# library(survival)   # décommenter si analyse de survie
# library(rms)        # décommenter si modélisation avancée
# library(brms)       # décommenter si modèles bayésiens

# Fonctions de mise en forme des tableaux (projet), construites au-dessus de
# la bibliothèque personnelle ci-dessus (table_to_word, flextable, officer...)
source(here::here("R/table_helpers.R"))

# Fonctions de visualisation (projet) : graphiques de corrélation personnalisables
# (choix du test Pearson/Spearman, p-value affichée proprement sur le graphique)
source(here::here("R/plot_helpers.R"))

