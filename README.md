# PHUSION NEO2

## Description


## Structure

```
PHUSION NEO2/
├── R/
│   ├── load_functions.R      # Packages + bibliothèque personnelle
│   ├── data_management.R     # Import, nettoyage, recodage
│   ├── statistical_models.R  # Modèles statistiques
│   ├── bayesian_models.R     # Modèles bayésiens
│   ├── survival_analysis.R   # Analyse de survie
│   └── visualization.R       # Graphiques
├── data/
│   ├── raw/                  # Données brutes (non versionnées)
│   └── processed/            # Données nettoyées (non versionnées)
├── figures/                  # Graphiques générés (non versionnés)
├── results/                  # Résultats exportés (non versionnés)
├── analyse.R                 # Script principal
├── rapport.Rmd               # Rapport final
└── README.md
```

## Chargement des fonctions

```r
source("/Users/kouadio/Desktop/DOSSIERS BUREAU/ENSEMBLE_FONCTIONS/charger_fonctions.R")
```

## Note confidentialité

Les données (`data/`) ne sont pas versionnées (données patient — exclus via `.gitignore`).
