# --------------------------------------------------------------------------------------------------------------------------------------------
# Nous allons étudier les données manquantes de la base composée uniquement des variables associées à p<0.2 dans la table 3 (analyse univariée)
# Ces variables sont: pd_n, grp_term_cal, crib, sex, gr_mult, rpde, rciu, nb_surf, periode, Surv_without_dbp36sa (variable cible)
# --------------------------------------------------------------------------------------------------------------------------------------------

# Sélection de variables
df2 <- df1 %>% select(pd_n, grp_term_cal, crib, sex, gr_mult, rpde, rciu, nb_surf, periode, Surv_without_dbp36sa)


# table de données manquantes par variable (globalement très peu de données manquantes; crib contient beaucoup de données manquantes)
missing_per_var <- export_missing_data_table(data = df2, file_name = "results/table_donnees_manquantes.docx")

# visualize 1
plot1_missing <- plot_missing_patterns(df2, png_path = "results/plot1_missing.png") 


# visualize 2 (question: Les données manquantes sont-elles MCAR, MNAR ou MAR?)
plot2_missing_MCARvsOthers <- plot_missing_mar_explore(df2, target_vars = c("rpde","crib"), png_path = "results/plot2_missing_MCARvsOthers.png")

# CONCLUSION crib (n=34 manquants) :
# MAR conditionnel à la période (p<0.001)
# → décision d'exclusion à confirmer à l'étape colinéarité (statistical_models.R)