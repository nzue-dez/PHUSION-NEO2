# ─────────────────────────────────────────────────────────────────────────────
# statistical_models.R
# Modèles statistiques (régression logistique, linéaire, mixtes...)
# ─────────────────────────────────────────────────────────────────────────────

# Etude de corrélation entre les variables quantitatives de la base
# NB : plot_correlation()/save_correlation_grid() (R/plot_helpers.R) affichent
# proprement le coefficient et la p-value sur chaque graphique, et permettent
# de choisir le test (method = "pearson" ou "spearman"), le lissage
# (smooth = "linear" ou "loess"), les couleurs, la position de l'encart, etc.
corr_labels <- list(
  term_cal = "GA at birth (weeks)",
  pd_n     = "Birthweight (g)",
  crib     = "Crib"
)

save_correlation_grid(df1, pairs = list(c("term_cal", "pd_n")), labels = corr_labels,
                       method = "pearson", smooth = "linear",
                       file_path = "results/scatter_pairs1.png")

save_correlation_grid(df1, pairs = list(c("term_cal", "crib")), labels = corr_labels,
                       method = "pearson", smooth = "linear",
                       file_path = "results/scatter_pairs2.png")

save_correlation_grid(df1, pairs = list(c("pd_n", "crib")), labels = corr_labels,
                       method = "pearson", smooth = "linear",
                       file_path = "results/scatter_pairs3.png")



#---------------------------------------------------------- Analyse univariée -------------------------------------------------------------------------
## Tableau 3 (variables quantitatives + qualitatives fusionnées en un seul tableau)

lab_quant3 <- list(
  term_cal = "GA at birth (weeks)",
  pd_n     = "Birthweight (g)",
  crib     = "Crib")

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

tab3 <- merged_desc_table(df1,
              group_var  = "dec_ou_dbp_36sa",
              quant_vars = vars_quant3,
              qual_vars  = vars_qual3,
              labels     = c(lab_quant3, vars_qual_lab3))

export_flextable_docx(tab3, "Tableau 3 — Analyse univariée des facteurs associés à la survie sans DBP",
                       "results/Tableau3.docx")



#---------------------------------------------------- Construction du modèle multivarié -------------------------------------------------------------
modlog1 <- glm(Surv_without_dbp36sa ~ term_cal + sex + gr_mult + rpde + rciu + nb_surf + periode,
               data = df1, family = binomial(link = "logit"))



# ----------------------------------------------------- Estimation des effets ajustés --------------------------------------------------------------
summary(modlog1)


# ---------------------------------------------------------- Extraction des résultats ---------------------------------------------------------------
res <- tidy(modlog1, exponentiate = TRUE, conf.int = TRUE) %>%
  filter(term != "(Intercept)")

res <- res %>%
  mutate(term = dplyr::recode(term,
                              "term_cal"                              = "Gestational age (weeks)",
                              "sexFemme"                              = "Sex: Female",
                              "gr_multOui"                            = "Multiple pregnancy: Yes",
                              "rpdeOui"                               = "PPROM: Yes",
                              "rciuOui"                               = "IUGR <10th centile: Yes",
                              "nb_surfUne dose"                       = "Surfactant: One dose",
                              "nb_surfDeux doses ou plus"             = "Surfactant: ≥2 doses",
                              "periodeRestrictive prophylaxis period" = "Prophylaxis period: Restrictive"
  ))

# ---------------------------------------------------------- Tableau 4 (ORa) au même style que les tableaux descriptifs ------------------------------
group_defs_model <- list(
  "Âge gestationnel (par semaine)" = list(type = "continuous", term = "Gestational age (weeks)"),
  "Sexe" = list(type = "factor", ref = "Homme",
                terms = c("Sex: Female" = "Femme")),
  "Grossesse multiple" = list(type = "factor", ref = "Non",
                terms = c("Multiple pregnancy: Yes" = "Oui")),
  "Rupture prématurée des membranes" = list(type = "factor", ref = "Non",
                terms = c("PPROM: Yes" = "Oui")),
  "RCIU < 10ᵉ percentile" = list(type = "factor", ref = "Non",
                terms = c("IUGR <10th centile: Yes" = "Oui")),
  "Surfactant" = list(type = "factor", ref = "Aucune dose",
                terms = c("Surfactant: One dose"       = "Une dose",
                          "Surfactant: ≥2 doses"        = "≥ 2 doses")),
  "Période de prophylaxie" = list(type = "factor", ref = "Élargie",
                terms = c("Prophylaxis period: Restrictive" = "Restrictive"))
)

tab4 <- build_or_table(res, group_defs_model)

export_flextable_docx(tab4,
  "Tableau 4 — Régression logistique multivariée : ORa pour la survie sans DBP à 36 semaines",
  "results/modele_multivarie.docx")

res <- res %>%
  mutate(
    significant = ifelse(p.value < 0.05, "Significant", "Not significant"),
    term = factor(term, levels = rev(term))
  )

caption_text <- paste0(
  "PPROM: preterm premature rupture of membranes; IUGR: intrauterine growth restriction;\n",
  "OR: odds ratio; CI: 95% confidence interval.\n",
  "Reference categories: Male (sex), No (PPROM, IUGR, multiple pregnancy),\n",
  "no surfactant dose, unrestricted prophylaxis period.\n",
  "Multivariable logistic regression. Adjusted OR with 95% CI."
)

p <- ggplot(res, aes(x = estimate, y = term, color = significant)) +
  
  geom_hline(
    yintercept = seq(1.5, nrow(res) - 0.5, by = 2),
    color = "#F5F5F5", linewidth = 6
  ) +
  
  geom_vline(xintercept = 1, linetype = "dashed",
             color = "#555555", linewidth = 0.6) +
  
  geom_errorbarh(
    aes(xmin = conf.low, xmax = conf.high),
    height = 0.25, linewidth = 0.9
  ) +
  
  geom_point(size = 3.5, shape = 18) +
  
  scale_x_log10(
    breaks = c(0.1, 0.2, 0.5, 1, 2, 3, 5),
    labels = c("0.1", "0.2", "0.5", "1.0", "2.0", "3.0", "5.0")
  ) +
  
  scale_color_manual(
    values = c("Significant" = "#1B3A6B", "Not significant" = "#C0392B"),
    name = NULL
  ) +
  
  labs(
    title    = "Adjusted Odds Ratios for Survival Without BPD at 36 Weeks",
    subtitle = "Multivariable logistic regression",
    x        = "Odds Ratio (OR)",
    y        = NULL,
    caption  = caption_text
  ) +
  
  theme_classic(base_size = 12, base_family = "sans") +
  theme(
    plot.title         = element_text(face = "bold", size = 13, color = "#1B3A6B",
                                      margin = margin(b = 4)),
    plot.subtitle      = element_text(size = 10, color = "#6B7280",
                                      margin = margin(b = 10)),
    axis.text.y        = element_text(size = 10.5, color = "#111111", hjust = 1),
    axis.text.x        = element_text(size = 10, color = "#555555"),
    axis.title.x       = element_text(size = 10.5, margin = margin(t = 8)),
    axis.line          = element_line(color = "#CCCCCC", linewidth = 0.4),
    axis.ticks         = element_line(color = "#CCCCCC", linewidth = 0.4),
    panel.grid.major.x = element_line(color = "#EEEEEE", linewidth = 0.4),
    panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank(),
    legend.position    = "top",
    legend.justification = "left",
    legend.text        = element_text(size = 10),
    legend.key.size    = unit(0.8, "lines"),
    plot.caption       = element_text(size = 8, color = "#6B7280",
                                      hjust = 0, lineheight = 1.5,
                                      margin = margin(t = 12)),
    plot.margin        = margin(t = 12, r = 20, b = 10, l = 10)
  )

# Export du forest plot
ggsave("results/forest_plot_modele.png",  plot = p, width = 11, height = 6.5, dpi = 300, bg = "white")

