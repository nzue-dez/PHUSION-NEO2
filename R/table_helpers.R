# ─────────────────────────────────────────────────────────────────────────────
# table_helpers.R
# Fonctions de mise en forme "projet" construites au-dessus de la bibliothèque
# personnelle (R/fonctions/), pour :
#   - choisir automatiquement moyenne(ET) vs médiane(EIQ) par variable
#     quantitative selon la normalité (Shapiro-Wilk) au sein des groupes ;
#   - fusionner variables quantitatives et qualitatives dans un même tableau ;
#   - remplacer la colonne "Test" par des étoiles de significativité sur la
#     p-value (le test utilisé est documenté en note sous le tableau) ;
#   - produire un flextable au style unifié (identique pour les tableaux
#     descriptifs et pour le tableau du modèle multivarié), avec une largeur
#     fixe qui tient toujours dans la page.
# ─────────────────────────────────────────────────────────────────────────────

# -----------------------------------------------------------------------------
# Étoiles de significativité + formatage de la p-value
# -----------------------------------------------------------------------------
pval_stars <- function(p) {
  p <- suppressWarnings(as.numeric(p))
  if (is.null(p) || length(p) == 0 || is.na(p)) return("")
  if (p < 0.001) return("***")
  if (p < 0.01)  return("**")
  if (p < 0.05)  return("*")
  return("")
}

fmt_pval <- function(p) {
  p <- suppressWarnings(as.numeric(p))
  if (is.null(p) || length(p) == 0 || is.na(p)) return("")
  base  <- if (p < 0.001) "< 0.001" else sprintf("%.3f", p)
  stars <- pval_stars(p)
  trimws(paste(base, stars))
}

# -----------------------------------------------------------------------------
# Normalité par groupe (Shapiro-Wilk) : TRUE seulement si la normalité n'est
# rejetée dans AUCUN groupe (attitude conservatrice : au moindre doute ou au
# moindre petit échantillon, on retient la statistique non paramétrique).
# -----------------------------------------------------------------------------
is_normal_by_group <- function(x, g, alpha = 0.05) {
  g <- droplevels(as.factor(g))
  if (length(levels(g)) < 1) return(FALSE)
  for (lv in levels(g)) {
    xi <- x[g == lv]
    xi <- xi[!is.na(xi)]
    if (length(xi) < 3 || length(unique(xi)) < 2) return(FALSE)
    p <- suppressWarnings(stats::shapiro.test(xi)$p.value)
    if (is.na(p) || p <= alpha) return(FALSE)
  }
  TRUE
}

# -----------------------------------------------------------------------------
# merged_desc_table : construit UN tableau descriptif (quantitatif +
# qualitatif fusionnés) en réutilisant table_to_word() variable par variable
# pour les quantitatives (avec choix automatique moyenne/médiane + test),
# puis en assemblant le tout. La colonne "Test" est retirée et la p-value
# reformatée avec des étoiles.
# -----------------------------------------------------------------------------
merged_desc_table <- function(df, group_var, quant_vars = NULL, qual_vars = NULL,
                               labels = NULL, conditions = NULL) {

  rows <- list()

  if (!is.null(quant_vars)) {
    for (v in quant_vars) {

      df_v <- df
      if (!is.null(conditions) && v %in% names(conditions)) {
        keep <- eval(conditions[[v]], envir = df)
        df_v <- df[keep, , drop = FALSE]
      }

      x <- df_v[[v]]
      g <- df_v[[group_var]]

      normal <- is_normal_by_group(x, g)
      stat   <- if (normal) "mean_sd" else "median_iqr"
      test   <- if (normal) "ttest"   else "wilcoxon"
      n_miss <- sum(is.na(x))
      stats_quant <- if (n_miss > 0) c(stat, "na") else stat

      tt <- table_to_word(
        df,
        group_var     = group_var,
        quant_vars    = v,
        labels        = labels,
        stats_quant   = stats_quant,
        tests_choices = list(quant = setNames(list(test), v)),
        conditions    = conditions,
        filename      = tempfile(fileext = ".docx")
      )

      rows[[length(rows) + 1]] <- tt
    }
  }

  if (!is.null(qual_vars)) {
    tt <- table_to_word(
      df,
      group_var  = group_var,
      qual_vars  = qual_vars,
      labels     = labels,
      conditions = conditions,
      filename   = tempfile(fileext = ".docx")
    )
    rows[[length(rows) + 1]] <- tt
  }

  df_out <- dplyr::bind_rows(rows)
  df_out$Test <- NULL
  df_out$`p-value` <- vapply(df_out$`p-value`, fmt_pval, character(1))
  df_out
}

# -----------------------------------------------------------------------------
# build_or_table : transforme la sortie recodée d'un modèle logistique (objet
# `res` obtenu via broom::tidy(..., exponentiate = TRUE)) en tableau au même
# format que les tableaux descriptifs (Variable / Modalité / ORa / IC95% /
# p-value), avec une ligne de référence "(réf.)" pour chaque variable
# catégorielle, afin d'être rendu par render_flextable_pro().
#
# group_defs : liste nommée par le libellé de la variable à afficher, où
# chaque élément est soit :
#   - list(type = "continuous", term = "<nom du terme recodé>")
#   - list(type = "factor", ref = "<libellé de la référence>",
#          terms = c("<nom du terme recodé>" = "<libellé de la modalité>", ...))
# -----------------------------------------------------------------------------
build_or_table <- function(res, group_defs) {

  fmt_or <- function(term) {
    r <- res[res$term == term, ]
    if (nrow(r) == 0) {
      return(data.frame(ORa = "", `IC95 %` = "", `p-value` = "", check.names = FALSE))
    }
    data.frame(
      ORa      = sprintf("%.2f", r$estimate[1]),
      `IC95 %` = sprintf("[%.2f ; %.2f]", r$conf.low[1], r$conf.high[1]),
      `p-value` = fmt_pval(r$p.value[1]),
      check.names = FALSE
    )
  }

  rows <- list()

  for (label in names(group_defs)) {
    gd <- group_defs[[label]]

    if (identical(gd$type, "continuous")) {
      rows[[length(rows) + 1]] <- cbind(
        data.frame(Variable = label, Modalité = "", check.names = FALSE),
        fmt_or(gd$term)
      )
    } else {
      rows[[length(rows) + 1]] <- data.frame(
        Variable = label, Modalité = "", ORa = "", `IC95 %` = "", `p-value` = "",
        check.names = FALSE
      )
      rows[[length(rows) + 1]] <- data.frame(
        Variable = "", Modalité = paste0(gd$ref, " (réf.)"),
        ORa = "1", `IC95 %` = "\u2014", `p-value` = "",
        check.names = FALSE
      )
      for (term in names(gd$terms)) {
        rows[[length(rows) + 1]] <- cbind(
          data.frame(Variable = "", Modalité = gd$terms[[term]], check.names = FALSE),
          fmt_or(term)
        )
      }
    }
  }

  dplyr::bind_rows(rows)
}

# -----------------------------------------------------------------------------
# render_flextable_pro : rendu flextable unique pour tous les tableaux du
# rapport (descriptifs ET modèle multivarié) — en-tête bleu marine/blanc,
# lignes "parent" grisées et en gras, lignes "enfant" indentées, significativité
# repérée par la présence d'étoiles (robuste au texte "< 0.001 ***"), largeur
# fixe proportionnelle qui tient toujours dans la page (16.5 cm utiles).
# -----------------------------------------------------------------------------
render_flextable_pro <- function(df_out, caption = NULL, font_size = 8,
                                  total_width_cm = 16.5) {

  parent_rows <- which(df_out$Variable != "")
  child_rows  <- setdiff(seq_len(nrow(df_out)), parent_rows)
  sig_rows    <- which(grepl("\\*", df_out[["p-value"]]))

  ft <- flextable::flextable(df_out)
  ft <- flextable::fontsize(ft, size = font_size, part = "all")
  ft <- flextable::bold(ft, i = parent_rows, bold = TRUE)
  ft <- flextable::bg(ft, i = parent_rows, bg = "#F2F2F2")

  if ("Modalité" %in% names(df_out) && length(child_rows) > 0) {
    ft <- flextable::padding(ft, i = child_rows, j = "Modalité", padding.left = 20)
  }

  if (length(sig_rows) > 0) {
    ft <- flextable::color(ft, i = sig_rows, j = "p-value", color = "#C00000")
    ft <- flextable::bold(ft,  i = sig_rows, j = "p-value", bold = TRUE)
  }

  ft <- flextable::bold(ft, part = "header", bold = TRUE)
  ft <- flextable::bg(ft, part = "header", bg = "#1F3864")
  ft <- flextable::color(ft, part = "header", color = "white")

  ft <- flextable::align(ft, align = "left", part = "all")
  center_cols <- intersect(c("n", "p-value", "ORa", "IC95 %"), names(df_out))
  if (length(center_cols) > 0) {
    ft <- flextable::align(ft, j = center_cols, align = "center", part = "all")
  }

  ft <- flextable::border_remove(ft)
  ft <- flextable::hline(ft, part = "header",
                          border = officer::fp_border(color = "white", width = 1))
  ft <- flextable::hline(ft, i = parent_rows,
                          border = officer::fp_border(color = "#BFBFBF", width = 0.5))
  ft <- flextable::hline_bottom(ft, part = "body",
                                 border = officer::fp_border(color = "#1F3864", width = 1.5))

  # Largeurs fixes proportionnelles : la somme vaut toujours total_width_cm,
  # quel que soit le nombre de colonnes -> le tableau tient dans la page.
  base_w <- vapply(names(df_out), function(cn) {
    if (cn == "Variable")   3.4
    else if (cn == "Modalité") 3.2
    else if (cn == "n")        0.9
    else if (cn == "p-value")  1.6
    else if (cn == "ORa")      1.3
    else if (cn == "IC95 %")   2.6
    else                       2.4   # Total / colonnes de groupe
  }, numeric(1))
  w_cm <- base_w * (total_width_cm / sum(base_w))

  ft <- flextable::set_table_properties(ft, layout = "fixed")
  for (cn in names(df_out)) {
    ft <- flextable::width(ft, j = cn, width = unname(w_cm[cn]))
  }

  if (!is.null(caption)) ft <- flextable::set_caption(ft, caption)
  ft
}

# -----------------------------------------------------------------------------
# export_flextable_docx : exporte un tableau (data.frame déjà au format
# Variable/Modalité/...) vers un fichier Word autonome, avec le même rendu
# que dans le rapport.
# -----------------------------------------------------------------------------
export_flextable_docx <- function(df_out, caption, filename) {
  doc <- officer::read_docx()
  doc <- flextable::body_add_flextable(doc, render_flextable_pro(df_out, caption = caption))
  print(doc, target = filename)
  invisible(filename)
}
