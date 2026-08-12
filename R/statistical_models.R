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

lab_quant3 <- list(
  term_cal = "GA at birth (weeks)",
  pd_n     = "Birthweight (g)",
  crib     = "Crib")

tab3_quant <- table_to_word(df1,
              quant_vars = vars_quant3,
              labels = lab_quant3,
              group_var = "dec_ou_dbp_36sa",
              filename = "results/Tableau3_quant.docx")


## Tableau 3 (variables qualitatives)
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

tab3_qual <- table_to_word(df1,
              qual_vars = vars_qual3,
              labels = vars_qual_lab3,
              group_var = "dec_ou_dbp_36sa",
              filename = "results/Tableau3_qual.docx")




#---------------------------------------------------- Construction du modèle multivarié -------------------------------------------------------------
modlog1 <- glm(Surv_without_dbp36sa ~ term_cal + sex + gr_mult + rpde + rciu + nb_surf + periode,
               data = df1, family = binomial(link = "logit"))



# ----------------------------------------------------- Estimation des effets ajustés --------------------------------------------------------------
summary(modlog1)


# Export des résultats 
multivari_model <- tbl_regression(modlog1, exponentiate = TRUE)
multivari_model %>% as_flex_table() %>% flextable::save_as_docx(path = "results/modèle_multivarié.docx")


# ---------------------------------------------------------- Forest plot du modèle -----------------------------------------------------------------
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

