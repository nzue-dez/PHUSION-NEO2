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


# Construction du modèle multivarié
modlog1 <- glm(Surv_without_dbp36sa ~ term_cal + sex + gr_mult + rpde + rciu + nb_surf + periode,
               data = df1, family = binomial(link = "logit"))