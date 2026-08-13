# ─────────────────────────────────────────────────────────────────────────────
# visualization.R
# Graphiques et figures (ggplot2)
# Sauvegarder dans figures/ avec ggsave()
# ─────────────────────────────────────────────────────────────────────────────

# Comparaison des variables quantitatives entre les deux périodes de prophylaxie
# (réutilise plot_box_points, déjà présente dans la bibliothèque de fonctions)
box_quant_by_periode <- plot_box_points(  # [n°37]
  df1,
  x_var   = "periode",
  y_vars  = vars_quant1,
  labels_list = lab_quant1,
  group_colors = c("#A9CCE3", "#F5B7B1"),
  ncol = 3,
  nrow = 1,
  save_path = "results/box_quant_by_periode.png"
)

# Rotation des labels de période en x (noms de période longs) pour la lisibilité,
# sans modifier plot_box_points elle-même (fonction partagée avec l'équipe biostat)
box_quant_by_periode$plot <- box_quant_by_periode$plot &
  theme(axis.text.x = element_text(angle = 20, hjust = 1, size = 8))


# Taux des critères de jugement (Tableau 2) par période -----------------
# Mêmes variables/labels/conditions que le Tableau 2, en graphique en barres.
#
# IMPORTANT — dépendance implicite : `conditions` et `lab_qual2` ne sont PAS
# définis dans ce fichier. Ils sont créés dans R/descriptive.R (Tableau 2) et
# doivent être présents dans l'environnement global au moment où ce script
# s'exécute. Ça ne fonctionne que parce que analyse.R source descriptive.R
# avant visualization.R — ce fichier ne doit pas être exécuté isolément.

calc_taux_qual2 <- function(var) {

  df_v <- df1
  if (var %in% names(conditions)) {
    df_v <- df_v %>% dplyr::filter(eval(conditions[[var]], envir = df_v))
  }

  df_v %>%
    dplyr::filter(!is.na(.data[[var]])) %>%
    dplyr::count(periode, .data[[var]]) %>%
    dplyr::group_by(periode) %>%
    dplyr::mutate(pct = 100 * n / sum(n)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(.data[[var]] == "Oui") %>%
    dplyr::transmute(
      variable = var,
      label    = lab_qual2[[var]],
      periode,
      n, pct
    )
}

taux_qual2_by_periode <- dplyr::bind_rows(lapply(names(lab_qual2), calc_taux_qual2))

bar_outcomes_by_periode <- ggplot(
  taux_qual2_by_periode,
  aes(x = reorder(label, pct), y = pct, fill = periode)
) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(
    aes(label = paste0(n, " (", round(pct, 1), "%)")),
    position = position_dodge(width = 0.8),
    hjust = -0.1, size = 3
  ) +
  coord_flip(clip = "off") +
  scale_fill_manual(values = c("#A9CCE3", "#F5B7B1"), name = "Période") +
  scale_y_continuous(limits = c(0, max(taux_qual2_by_periode$pct) * 1.3),
                     labels = function(x) paste0(x, "%")) +
  labs(
    title = "Critères de jugement par période de prophylaxie",
    x = NULL, y = "% patients concernés"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title      = element_text(face = "bold"),
    legend.position = "top"
  )

ggsave("results/bar_outcomes_by_periode.png", bar_outcomes_by_periode,
       width = 10, height = 7, dpi = 300, bg = "white")
