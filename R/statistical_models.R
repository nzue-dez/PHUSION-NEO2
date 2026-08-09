# ─────────────────────────────────────────────────────────────────────────────
# statistical_models.R
# Modèles statistiques (régression logistique, linéaire, mixtes...)
# ─────────────────────────────────────────────────────────────────────────────

# Etude de corrélation entre les variables quantitatives de la base
labels <- list(term_cal = "GA at birth (weeks)", pd_n = "Birthweight (g)")
plot_scatter_pairs(df1, vars = c("term_cal","pd_n"), point_color = "darkred", test = c("pearson"),
                   labels_list = labels, smooth = c("linear"), ncol = 3, nrow = 1, file_path = "results/scatter_pairs1.pdf")

labels <- list(term_cal = "GA at birth (weeks)", crib = "Crib")
plot_scatter_pairs(df1, vars = c("term_cal","crib"), point_color = "darkred", test = c("pearson"),
                   labels_list = labels, smooth = c("linear"), ncol = 3, nrow = 1, file_path = "results/scatter_pairs2.pdf")

labels <- list(pd_n = "Birthweight (g)", crib = "Crib")
plot_scatter_pairs(df1, vars = c("pd_n","crib"), point_color = "darkred", test = c("pearson"),
                   labels_list = labels, smooth = c("linear"), ncol = 3, nrow = 1, file_path = "results/scatter_pairs3.pdf")



#---------------------------------------------------------- Analyse univariée -------------------------------------------------------------------------
## Tableau 3 (variables quantitatives)
vars_quant3 = c("term_cal","pd_n","crib")

lab_quant3 <- list(
  term_cal = "GA at birth (weeks)",
  pd_n     = "Birthweight (g)",
  crib     = "Crib")

table_to_word(df1,
              quant_vars = vars_quant3,
              labels = lab_quant3,
              group_var = "dec_ou_dbp_36sa",
              filename = "results/Tableau3_quant.docx")


## Tableau 3 (variables qualitatives)
vars_qual3 = c("grp_term_cal","sex","inborn_status","acc","gr_mult","rpde","beta_sone","rciu","nb_surf","periode")

vars_qual_lab3 <- list(
  grp_term_cal  = "GA at birth, week, n (%)",
  sex           = "Gender, n (%)",
  inborn_status = "Inborn status, n (%) ",
  acc           = "Accouchement",
  gr_mult       = "Multiple pregnancy, n (%)",
  rpde          = "Premature rupture of membrane, n (%)",
  beta_sone     = "Prenatal steroids, n (%)",
  rciu          = "IUGR <10th centile, n(%)",
  nb_surf       = "N doses surfactant, n (%)",
  periode       = "Period")

table_to_word(df1,
              qual_vars = vars_qual3,
              labels = vars_qual_lab3,
              group_var = "dec_ou_dbp_36sa",
              filename = "results/Tableau3_qual.docx")




#---------------------------------------------------- Construction du modèle multivarié -------------------------------------------------------------
modlog1 <- glm(Surv_without_dbp36sa ~ term_cal + sex + gr_mult + rpde + rciu + nb_surf + periode,
               data = df1, family = binomial(link = "logit"))