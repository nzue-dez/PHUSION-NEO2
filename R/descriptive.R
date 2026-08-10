# ─────────────────────────────────────────────────────────────────────────────
# descriptive.R
# Analyse descriptive et comparative de la population
# Tableau 1 : caractéristiques générales + comparaisons entre groupes
# ─────────────────────────────────────────────────────────────────────────────

# Tableau 1 (variables quantitatives)
lab_quant1 <- list(
  term_cal = "GA at birth (weeks)",
  pd_n     = "Birthweight (g)",
  crib     = "Crib")

table_to_word(df1,
              quant_vars = vars_quant1,
              labels = lab_quant1,
              group_var = "periode",
              filename = "results/Tableau1_quant.docx")



# Tableau 1 (variables qualitatives)
vars_qual_lab1 <- list(
  grp_term_cal = "GA at birth, week, n (%)",
  sex          = "Gender, n (%)",
  inborn_status = "Inborn status, n (%) ",
  acc          = "Accouchement",
  gr_mult      = "Multiple pregnancy, n (%)",
  rpde         = "Premature rupture of membrane, n (%)",
  beta_sone    = "Prenatal steroids, n (%)",
  rciu         = "IUGR <10th centile, n(%)",
  nb_surf      = "N doses surfactant, n (%)",
  prmloc       = "N receiving prophylaxis hydrocortisone, n (%)")

table_to_word(df1,
              qual_vars = vars_qual1,
              labels = vars_qual_lab1,
              group_var = "periode",
              filename = "results/Tableau1_qual.docx")


# Tableau 2 (variables quantitatives)
lab_quant2 <- list(
  somcu_int        = "Cumulated duration of invasive ventilation (d)",
  somcu_vni        = "Cumulated duration of non-invasive ventilation (d)",
  cortico_gene_doz = "Dose of postnatal steroids (mg/kg)")

table_to_word(df1,
              quant_vars = vars_quant2,
              labels = lab_quant2,
              group_var = "periode",
              filename = "results/Tableau2_quant.docx")


# Tableau 2 (variables qualitatives)
lab_qual2 <- list(
  dec_ou_dbp_36sa = "Death or DBP at 36 weeks, n (%)",
  dec_36sa        = "Death at 36 weeks, n (%)",
  dbp_36sa        = "BPD at 36 weeks, n (%)",         # parmi les survivants uniquement (among survivors)
  cortico_tard    = "Late (> day 10) steroids , n (%)",
  pneu_tho        = "Air leaks, n (%)",
  hemo_pulm       = "Pulmonary haemorrhage, n (%)",
  hiv_plus_lpmv   = "Severe IVH (grade 3-4) and/or PVL, n (%)",
  cnl_ttt         = "PDA pharmacological treatment, n (%)",
  ca_opr          = "PDA mechanical closure, n (%)",
  noso            = "Late-onset sepsis, n (%)",
  ecun            = "NEC, n (%)",
  perfo_isl       = "Isolated intestinal perforation, n (%)",
  dec_s           = "Death before discharge, n (%)",
  chir_lser       = "Treatment for ROP, n (%)")       # parmi les survivants uniquement (among survivors)

# dbp_36sa et chir_lser sont calculés uniquement chez les patients non décédés avant la sortie
conditions = list(
  chir_lser = quote(dec_s == "Non"),
  dbp_36sa  = quote(dec_s == "Non")
)

table_to_word(df1,
              qual_vars = vars_qual2,
              labels = lab_qual2,
              group_var = "periode",
              conditions = conditions,
              filename = "results/Tableau2_qual.docx")
