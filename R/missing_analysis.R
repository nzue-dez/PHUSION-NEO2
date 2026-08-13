# ─────────────────────────────────────────────────────────────────────────────
# missing_analysis.R
# Étude des données manquantes, restreinte aux variables associées à p<0.2 en
# analyse univariée (Tableau 3) : pd_n, grp_term_cal, crib, sex, gr_mult,
# rpde, rciu, nb_surf, periode, Surv_without_dbp36sa (cible).
# ─────────────────────────────────────────────────────────────────────────────

# Sélection de variables
df2 <- df1 %>% select(pd_n, grp_term_cal, crib, sex, gr_mult, rpde, rciu, nb_surf, periode, Surv_without_dbp36sa)


# Table par variable (peu de manquants globalement ; crib est la plus touchée)
missing_per_var <- export_missing_data_table(data = df2, file_name = "results/table_donnees_manquantes.docx")  # [n°21]

# Visualisation des patterns de données manquantes
plot1_missing <- plot_missing_patterns(df2, png_path = "results/plot1_missing.png")  # [n°25]

# MCAR / MNAR / MAR ?
plot2_missing_MCARvsOthers <- plot_missing_mar_explore(df2, target_vars = c("rpde","crib"), png_path = "results/plot2_missing_MCARvsOthers.png")  # [n°26]

# CONCLUSION crib (n=34 manquants) :
# MAR conditionnel à la période (p<0.001)
# → décision d'exclusion à confirmer à l'étape colinéarité (statistical_models.R)
