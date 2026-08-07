# PHUSION NEO2

## Description

### Objectif
Identifier les facteurs indépendamment associés à la survie sans dysplasie bronchopulmonaire (DBP) à 36 semaines d'âge post-menstruel chez les grands prématurés (<= 28 SA),
en portant une attention particulière à l'impact de la stratégie de prophylaxie par hydrocortisone - élargie (10/2017 à 02/2021) versus restrictive (03/2021 à 06/2025) - sur ce critère de jugement principal composite.


### Données et méthodes
Il s'agit d'une étude de cohorte observationnelle rétrospective-prospective monocentrique conduite dans le service de réanimation néonatale du Centre Hospitalier Intercommunal de Créteil (CHIC).
Ont été inclus les grands prématurés (<= 28 SA) pris en charge durant deux périodes successives de prophylaxie par hydrocortisone à faible dose (HSHC) : (i) une période à indication élargie (octobre 2017 - février 2021, N=136) et 
(ii) une période à indication restrictive (à partir de mars 2021, N=165).

Le critère de jugement principal était la survie sans DBP à 36 semaine d'âge post-menstruel. les critères secondaires incluaient les composantes individuelles de mortalité et de morbidité néonatale.

### Méthodes statistiques
Statistique descriptive : les variables continues sont exprimées en médiane (écart interquartile, EIQ) et en moyenne (écart-type, SD). Les comparaisons entre groupes ont utilisé le test de Wilcoxon-Mann-Whitney pour les variables continues et le
test du CHI2 ou le test exact de Fisher (lorsque plus de 20% des attendus étaient inférieur à 5) pour les variables catégorielles. Tous les tests étaient bilatéraux, avec un seuil de significativité fixé à alpha = 0.05.

Analyse univariée : Les variables ont été comparées entre les enfants ayant survécu sans DBP et ceux décédés ou ayant développé une DBP. Les variables atteignant p<0.2, en analyse univariée étaient candidates à l'inclusion dans le modèle multivarié.
La période de prophylaxie a été forcée dans le modèle a priori, indépendamment de sa valeur p univariée.

Analyse de colinéarité : les corrélations par paires entre l'âge gestationnel, le poids de naissance et le score CRIB ont été examinées. Des corrélations non négligeables ont été identifiées (|r|>= 0.57, p<0.001 pour toutes les paires). Afin d'éviter la redondance
et l'instabilité du modèle, seul l'âge gestationnel a été retenu comme indicateur représentatif de la maturité dans le modèle multivarié.

Régression logistique multivariéé : un modèle de régression logistique avec le critère principal comme variable dépendante a été ajusté. Les diagnostics du modèle ont inclus l'analyse des résidus studentisés, des points à fort levier, et 
le test de Hosmer-Lemeshow. Les résultats sont exprimés en odds ratios ajustés (ORa) avec leurs intervalles de confiance à 95% (IC 95%) et valeurs p. 

NB : Toutes les analyses ont été réalisées sous R version 4.5.2.


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


## Contraintes techniques

- **XQuartz requis sur macOS** : nécessaire pour le package `flextable` -> installer depuis [xquartz.org](https://www.xquartz.org)
- **Données manquantes** : < 5% sur toutes les variables -> exclusion listwise retenue (pas d'imputation)
- **renv** : environnement figé sous R 4.5.2 — lancer `renv::restore()` avant toute analyse

## Reproduire les analyses

### 1. Restaurer l'environnement
```r
renv::restore()
```

### 2. Ordre d'exécution
```r
source("R/load_functions.R")      # bibliothèque personnelle de fonctions
source("R/data_management.R")     # import, nettoyage, recodage
source("R/statistical_models.R")  # modèles statistiques
source("R/survival_analysis.R")   # analyses de survie
source("R/visualization.R")       # figures et graphiques
```

### 3. Résultats
Les exports (tableaux Word, figures) se trouvent dans outputs/
