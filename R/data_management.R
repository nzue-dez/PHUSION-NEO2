# ─────────────────────────────────────────────────────────────────────────────
# data_management.R — Étape 2
# Import, contrôle qualité, nettoyage, recodage et construction de la variable dépendante
# ─────────────────────────────────────────────────────────────────────────────

# Import ------------------------------------------------------------------
# Import de la base
data <- readxl::read_excel(here("data/raw/donnees_phuneo.xlsx"))

# Dimension de la base
Message <- sprintf("La base contient %d variables dans notre base", dim(data)[2])
cat(Message)

# On écarte de l'étude ces trois variables non déterminantes 
data <- data %>% select(-TERME_JOURS,-TERME_SEM)

# On restreint la population aux nouveau-nés dont l'âge gestationnel (AG) est inférieur ou égal à 28 
df1 <- data %>% filter((TERME_CALCUL<=28) == TRUE)

# Dictionnaire des variables
dic_vars <- tibble(
  variable = names(df1),
  
  type = c(
    "num", # 1
    "date", # 2
    "num", # 3
    "cat", # 4
    "cat", # 5
    "num", # 6
    "num", # 7
    "num", # 8
    "cat", # 9
    "cat", # 10
    "cat", # 11
    "cat", # 12
    "cat", # 13
    "cat", # 14
    "cat", # 15
    "cat", # 16
    "cat", # 17
    "cat", # 18
    "cat", # 19
    "cat", # 20
    "cat", # 21
    "cat", # 22
    "cat", # 23
    "cat", # 24
    "cat", # 25
    "cat", # 26
    "cat", # 27
    "cat", # 28
    "num", # 29
    "cat", # 30
    "cat", # 31
    "num", # 32
    "cat", # 33
    "cat", # 34
    "num", # 35
    "num", # 36
    "num"  # 37
  ),
  
  description = c(
    "Identifiant", # 1
    "date de naissance", # 2
    "Âge gestationnel à la naissance", # 3
    "sexe", # 4
    "Lieu de naissance", # 5
    "Poids de naissance", # 6
    "Taille de naissance", # 7
    "Périmètre crânien à la naissance", # 8
    "Accouchement", # 9
    "Grossesse multiple", # 10
    "Rupture de la poche des eaux", # 11
    "Corticoïde donné à la mère", # 12
    "Retard de croissance intra-utérin", # 13
    "Surfactant, instillé directement dans les poumons pour améliorer les organes respiratoires", # 14
    "Pneumothorax", # 15
    "Hémoglobine pulmonaire", # 16
    "Traitement du canal artériel", # 17
    "Canal artériel opéré", # 18
    "Hémorragie intra-ventriculaire", # 19
    "Leucomalacie péri-ventriculaire", # 20
    "HIV + LPMV", # 21
    "Infection nosocomiale", # 22
    "Entérocolite ulcéro-nécrosante", # 23
    "Entérocolite ulcéro-nécrosante opérée", # 24
    "Perforation isolée", # 25
    "Décès à 36 semaines d'âge post-menstruel", # 26
    "Dysplasie bronchopulmonaire à 36 semaines d'âge post-mentruel", # 27
    "Décès ou dysplasie à 36 semaines d'âge post-menstruel", # 28
    "CRIB", # 29
    "HSHC prophylactique à visée respiratoire administrée à la naissance", # 30
    "Corticothérapie générale", # 31
    "Dose toale de la corticothérapie générale administrée", # 32
    "Rétinopathie opérée", # 33
    "Décès à la sortie", # 34
    "Durée totale de ventilation invasive", # 35
    "Durée totale de ventilation non invasive", # 36
    "Cortisolémie à la naissance" # 37
  ),
  
  unite = c(
    NA, # 1
    "YY-MM-DD", # 2
    "semaines d'aménorrhée", # 3
    "1 = Femme ; 0 = Homme", # 4
    "1 = Né au chic (inborn) ; 0 = Né ailleurs (outborn)", # 5
    "g", # 6
    "cm", # 7
    "1 = Oui ; 0 = Non", # 8
    "1 = Oui ; 0 = Non", # 9
    "1 = Oui ; 0 = Non", # 10
    "1 = Oui ; 0 = Non", # 11
    "0 = Pas de cure ; 2 = Cure complète ; 1 = Cure incomplète", # 12
    "1 = Oui ; 0 = Non", # 13
    "0 = Aucune dose ; 1 = Une dose ; ≥2 = Deux doses ou plus", # 14
    "1 = Oui ; 0 = Non", # 15
    "1 = Oui ; 0 = Non", # 16
    "1 = Oui (ibuprofène ou paracétamol) ; 0 = Non", # 17
    "1 = Oui (chirurgie ou percutané) ; 0 = Non", # 18
    "0 = normale (pas d'HIV) ; 1 = grade 1 ; 2 = grade 2 ; 3 = grade 3 ; 4 = grade 4", # 19
    "1 = Oui ; 0 = Non", # 20
    "1 = Oui ; 0 = Non  HIV + LPMV = 0 si HIV = 0,1,2 et LPMV = 0 \nsinon HIV + LPMV = 1", # 21
    "1 = Oui ; 0 = Non", # 22
    "1 = Oui ; 0 = Non", # 23
    "1 = Oui ; 0 = Non ; 9 = Pas d'ecun", # 24
    "1 = Oui ; 0 = Non", # 25
    "1 = Oui ; 0 = Non", # 26
    "1 = Oui ; 0 = Non", # 27
    "1 = Oui ; 0 = Non", # 28
    "Non identifié(e)", # 29
    "1 = Oui ; 0 = Non", # 30
    "1 = Oui ; 0 = Non", # 31
    "mg/kg", # 32
    "1 = Oui ; 0 = Non", # 33
    "1 = Oui ; 0 = Non", # 34
    "Non identifié(e)", # 35
    "Non identifié(e)", # 36
    "nmol/l" # 37
  )
)

# Mise en forme du dictionnaire
dic_vars <- dic_vars %>%
  gt() %>%
  tab_header(title = "Dictionnaire des variables") %>%
  cols_label(
    variable = "Variable",
    type = "Type",
    description = "Description",
    unite = "Unité / Codage"
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#2C7FB8"),
      cell_text(color = "white", weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  opt_row_striping() %>%
  tab_options(row.striping.background_color = "#F7F7F7")

# Enregistrement du dictionnaire
gtsave(dic_vars, "results/dictionnaire_variables.html") 


# vecteur de variables
Vars = c("DATE_DDN","TERME_CALCUL","SEXE","INBORN_OUTBORN","POIDS_DDN","TAILLE_DDN","PC_DDN",
         "ACCOUCHEMENT","GROSS_MULTI","RPDE","BETAMETHASONE","RCIU","NB_SURFACTANT","PNEUMOTHORAX",
         "HEMO_PULMONAIRE","CANAL_TTT","CA_OPERE","NEURO_HIV","NEURO_LMPV","HIV+LPMV","NOSO","ECUN",
         "ECUN_OPERE","PERFO_ISOLE","DECES_36SA","DBP_36SA","décès ou DBP à 36 SA","CRIB","PREMILOC",
         "CORTICO_TARDIVE","CORTICO_GENE_DOSE","CHIR_LASER","DECES_SORTIE","SommeDeCUMUL_INTUB","SommeDeCUMUL_VNI",
         "Cortisol naissance (nmol/L)")

# Extraction des positions des variables du vecteur "Vars"
get_variable_positions(df1, Vars) # (C'est l'une des fonctions incluses dans load_functions)


# Renomme les variables pour faciliter leur manipulation.
# IMPORTANT : le renommage se fait par CORRESPONDANCE DE NOM (dplyr::rename),
# pas par position -- contrairement à `colnames(df1)[2:37] <- c(...)`, cette
# approche est robuste à un changement de l'ordre des colonnes dans le fichier
# source (data/raw/donnees_phuneo.xlsx) : si un nom de colonne attendu (Vars,
# ci-dessus) n'existe pas dans df1, R lève une erreur explicite au lieu de
# renommer silencieusement la mauvaise colonne.
nouveaux_noms <- c("date_naiss", "term_cal", "sex", "inborn_status", "pd_n",
                    "tll_n", "pc_n", "acc", "gr_mult", "rpde", "beta_sone",
                    "rciu", "nb_surf", "pneu_tho", "hemo_pulm", "cnl_ttt",
                    "ca_opr", "nro_hiv", "nro_lmpv", "hiv_plus_lpmv", "noso",
                    "ecun", "ecun_opr", "perfo_isl", "dec_36sa", "dbp_36sa",
                    "dec_ou_dbp_36sa", "crib", "prmloc", "cortico_tard",
                    "cortico_gene_doz", "chir_lser", "dec_s", "somcu_int",
                    "somcu_vni", "cortisol_n")

stopifnot(length(Vars) == length(nouveaux_noms))

# rename_map : vecteur nommé nouveaux_noms -> Vars (noms bruts), tel qu'attendu
# par dplyr::rename(df, !!!rename_map)
rename_map <- setNames(Vars, nouveaux_noms)
df1 <- df1 %>% dplyr::rename(!!!rename_map)


# Contrôle qualité --------------------------------------------------------
# plot_range_check()      : détection des valeurs aberrantes (variables quantitatives)
# check_dominance_qual()  : détection des classes déséquilibrées (variables qualitatives)
# (appliquées plus bas, une fois les variables qualitatives/quantitatives d'intérêt définies)


# Recherche des valeurs "DM" et "NA" dans la base. (À ce stade, les "NA" ne sont pas encore reconnus par le logiciel comme étant des données manquantes; DM représente, en fait, des données manquantes)
## règle de la recherche
rules = list(
  list(values = "DM", types = "exact", label = "egal_DM"),
  list(values = "NA", types = "exact", label = "egal_NA")
)
# On lance la recherche
detect_vars_with_value_patterns(df1, rules = rules) #  (C'est l'une des fonctions incluses dans load_functions)

# Remplacement
## On met les variables; dbp_36sa et chir_lser en caractère pour faciliter le remplacement 
df1$dbp_36sa  <- as.character(df1$dbp_36sa)
df1$chir_lser <- as.character(df1$chir_lser)

## Instruction de remplacement
replacements = list(
  tll_n            = list(char = "DM", replacement = NA, convert_numeric = TRUE),
  rpde             = list(char = "DM", replacement = NA, convert_numeric = FALSE),
  hemo_pulm        = list(char = "DM", replacement = NA, convert_numeric = FALSE),
  nro_hiv          = list(char = "DM", replacement = NA, convert_numeric = FALSE),
  nro_lmpv         = list(char = "DM", replacement = NA, convert_numeric = FALSE),
  crib             = list(char = "DM", replacement = NA, convert_numeric = TRUE),
  cortico_gene_doz = list(char = "DM", replacement = NA, convert_numeric = TRUE),
  somcu_vni        = list(char = "DM", replacement = NA, convert_numeric = TRUE),
  dbp_36sa         = list(char = "9",  replacement = NA, convert_numeric = TRUE),  # 9 = données non disponibles (à voir plus tard, notamment dans la modélisation, si on peut les considérer comme de "réelles données manquantes")
  chir_lser        = list(char = "9",  replacement = NA, convert_numeric = TRUE),  # idem
  cortisol_n       = list(char = "DM", replacement = NA, convert_numeric = TRUE)
)

## On lance la procédure de remplacement
df1 <- replace_char_multiple(df1, replacements = replacements) # (C'est l'une des fonctions incluses dans load_functions)


# Création de la variable période à partir de l'ordre d'enregistrement des patients (ici, on connait cet ordre)
## Période 1 (lignes 1–136)   : prophylaxie non restrictive (sans/avec PREMILOC)
## Période 2 (lignes 137–310) : prophylaxie restrictive (critères d'exclusion ajoutés)
df1$periode <- factor(ifelse(1:nrow(df1) <= 136, 1,
                             ifelse(1:nrow(df1) <= 310, 2, NA)))


# Recodage de toutes les variables catégorielles en facteurs avec labels lisibles
df1$sex            <- factor(df1$sex,            levels = c(0,1),     labels = c("Homme","Femme"))
df1$inborn_status  <- factor(df1$inborn_status,  levels = c(0,1),     labels = c("Inborn","Outborn"))
df1$acc            <- factor(df1$acc,            levels = c(0,1),     labels = c("Voie basse","Césarienne"))
df1$gr_mult        <- factor(df1$gr_mult,        levels = c(0,1),     labels = c("Non","Oui"))
df1$rpde           <- factor(df1$rpde,           levels = c(0,1),     labels = c("Non","Oui"))
df1$beta_sone      <- factor(df1$beta_sone,      levels = c(0,1,2),   labels = c("Pas de cure","Cure incomplète","Cure complète"))
df1$rciu           <- factor(df1$rciu,           levels = c(0,1),     labels = c("Non","Oui"))
df1$nb_surf        <- factor(df1$nb_surf,        levels = c("0","1","2","≥2"), labels = c("Aucune dose","Une dose","Deux doses ou plus","Deux doses ou plus"))
df1$pneu_tho       <- factor(df1$pneu_tho,       levels = c(0,1),     labels = c("Non","Oui"))
df1$hemo_pulm      <- factor(df1$hemo_pulm,      levels = c(0,1),     labels = c("Non","Oui"))
df1$cnl_ttt        <- factor(df1$cnl_ttt,        levels = c(0,1),     labels = c("Non","Oui"))
df1$ca_opr         <- factor(df1$ca_opr,         levels = c(0,1),     labels = c("Non","Oui"))
df1$nro_hiv        <- factor(df1$nro_hiv,        levels = c(0,1,2,3,4), labels = c("Normale","Grade 1","Grade 2","Grade 3","Grade 4"))
df1$nro_lmpv       <- factor(df1$nro_lmpv,       levels = c(0,1),     labels = c("Non","Oui"))
df1$hiv_plus_lpmv  <- factor(df1$hiv_plus_lpmv,  levels = c(0,1),     labels = c("Non","Oui"))
df1$noso           <- factor(df1$noso,           levels = c(0,1),     labels = c("Non","Oui"))
df1$ecun           <- factor(df1$ecun,           levels = c(0,1),     labels = c("Non","Oui"))
df1$ecun_opr       <- factor(df1$ecun_opr,       levels = c(0,1),     labels = c("Non","Oui"))
df1$perfo_isl      <- factor(df1$perfo_isl,      levels = c(0,1),     labels = c("Non","Oui"))
df1$dec_36sa       <- factor(df1$dec_36sa,       levels = c(0,1),     labels = c("Non","Oui"))
df1$dbp_36sa       <- factor(df1$dbp_36sa,       levels = c(0,1),     labels = c("Non","Oui"))
df1$dec_ou_dbp_36sa <- factor(df1$dec_ou_dbp_36sa, levels = c(0,1),   labels = c("Non","Oui"))
df1$prmloc         <- factor(df1$prmloc,         levels = c(0,1),     labels = c("Non","Oui"))
df1$cortico_tard   <- factor(df1$cortico_tard,   levels = c(0,1),     labels = c("Non","Oui"))
df1$chir_lser      <- factor(df1$chir_lser,      levels = c(0,1),     labels = c("Non","Oui"))
df1$dec_s          <- factor(df1$dec_s,          levels = c(0,1),     labels = c("Non","Oui"))
df1$periode        <- factor(df1$periode,        levels = c(1,2),     labels = c("Unrestrictive prophylaxis period","Restrictive prophylaxis period"))


# On forme des sous groupes à partir du terme de naissance (calculé) des nouveau-nés préma. 
## Découpage indiqué par le medecin ; [minimum(terme calculé)=23.3;26] et (26;maximum(terme calculé)=28] 
df1 <- df1 |> mutate(grp_term_cal = cut(
  term_cal,
  breaks = c(min(df1$term_cal), 25.99, max(df1$term_cal)),
  include.lowest = TRUE,
  right = TRUE,
  dig.lab = 5 # pour éviter d'arrondir la valeur 25.99 à l'entier supérieur
))


# Construction de la variable dépendante: survie sans DBP à 36 SA (Surv_without_dbp36sa)
# Si dec_ou_dbp_36sa = Non => Surv_without_dbp36sa = Oui; Si dec_ou_dbp_36sa = Oui => Surv_without_dbp36sa = Non;
df1 <- df1 %>%
  mutate(
    Surv_without_dbp36sa = case_when(
      dec_ou_dbp_36sa == "Non" ~ "Oui",
      dec_ou_dbp_36sa == "Oui" ~ "Non",
      TRUE ~ dec_ou_dbp_36sa
    )
  )

# On utilise une version qualitative chiffrée pour faciliter son intégration dans des modèles
df1$Surv_without_dbp36sa <- factor(df1$Surv_without_dbp36sa, levels = c("Non","Oui"), labels = c("0","1"))

# --------------------------------------------------------- contrôle de qualité ---------------------------------------------
vars_qual1 = c("grp_term_cal","sex","inborn_status","acc","gr_mult","rpde","beta_sone","rciu","nb_surf","prmloc")
vars_qual2 = c("dec_ou_dbp_36sa","dec_36sa","dbp_36sa","cortico_tard","pneu_tho","hemo_pulm",
               "hiv_plus_lpmv","cnl_ttt","ca_opr","noso","ecun","perfo_isl","dec_s","chir_lser")
vars_qual3 = c("grp_term_cal","sex","inborn_status","acc","gr_mult","rpde","beta_sone","rciu","nb_surf","periode")

## Variables qualitatives
check_equilib_qual1 <- check_dominance_qual(df1, vars = vars_qual1, ncol = 3, png_path = "results/check_equilib_qual1.png")
check_equilib_qual2 <- check_dominance_qual(df1, vars = vars_qual2, ncol = 3, png_path = "results/check_equilib_qual2.png")
check_equilib_qual3 <- check_dominance_qual(df1, vars = vars_qual3, ncol = 3, png_path = "results/check_equilib_qual3.png")


# Commentaire (variables qualitatives) :
# Toutes les variables qualitatives présentent une distribution équilibrée (seuil 95%),
# à l'exception de deux variables présentant une dominance détectée :
#   - pneu_tho  (pneumothorax)       : modalité "Non" dominante (~98%) — événement rare
#   - chir_lser (chirurgie laser)    : modalité "Non" dominante (~97%) — événement rare
# → Ces deux variables seront conservées dans l'analyse mais interprétées avec prudence
#   en raison de leur manque de variabilité (effectifs très faibles dans la modalité "Oui").



vars_quant1 = c("term_cal","pd_n","crib")
vars_quant2 = c("somcu_int","somcu_vni","cortico_gene_doz")
vars_quant3 = c("term_cal","pd_n","crib")

## Variables quantitatives
check_vars_quant_value1 <- plot_range_check(df1, vars = vars_quant1, ncol = 3, png_path = "results/check_vars_quant_value1.png")
check_vars_quant_value2 <- plot_range_check(df1, vars = vars_quant2, ncol = 3, png_path = "results/check_vars_quant_value2.png")
check_vars_quant_value3 <- plot_range_check(df1, vars = vars_quant3, ncol = 3, png_path = "results/check_vars_quant_value3.png")


# Commentaire:
# On a détecté quelques observations avec des valeurs assez écartées de la plage majoritaire.

# Liste des variables pour lesquelles il y aurait des valeurs potentiellement aberrantes et/ou atypiques
# (inspection au cas par cas : subset(check_vars_quant_value2$outliers_table, variable == "<nom_variable>"))
unique(check_vars_quant_value2$outliers_table$variable)
