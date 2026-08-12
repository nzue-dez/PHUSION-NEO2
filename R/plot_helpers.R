# ─────────────────────────────────────────────────────────────────────────────
# plot_helpers.R
# Fonctions de visualisation "projet", construites au-dessus de ggplot2 /
# patchwork, pour produire des graphiques de corrélation propres et
# personnalisables (remplace les appels à plot_scatter_pairs() pour les
# figures de corrélation du rapport).
# ─────────────────────────────────────────────────────────────────────────────

# -----------------------------------------------------------------------------
# plot_correlation : nuage de points + droite de tendance pour UNE paire de
# variables quantitatives, avec le coefficient de corrélation et sa p-value
# proprement affichés sur le graphique (étoiles de significativité incluses,
# via pval_stars() défini dans R/table_helpers.R).
#
# Personnalisation disponible :
#   - method      : "pearson" (par défaut) ou "spearman"
#   - smooth      : "linear" (régression linéaire) ou "loess"
#   - point_color, line_color, point_alpha, point_size
#   - digits      : nombre de décimales pour le coefficient affiché
#   - label_pos   : position de l'encart (r, p) : "top_left" (défaut),
#                   "top_right", "bottom_left", "bottom_right"
#   - x_label, y_label, title : libellés d'axes / titre
# -----------------------------------------------------------------------------
plot_correlation <- function(df, x, y,
                              x_label = NULL, y_label = NULL, title = NULL,
                              method      = c("pearson", "spearman"),
                              smooth      = c("linear", "loess"),
                              point_color = "#1F3864",
                              line_color  = "#C00000",
                              point_alpha = 0.55,
                              point_size  = 2,
                              digits      = 2,
                              label_pos   = c("top_left", "top_right", "bottom_left", "bottom_right")) {

  method    <- match.arg(method)
  smooth    <- match.arg(smooth)
  label_pos <- match.arg(label_pos)

  d <- df[, c(x, y)]
  d <- d[stats::complete.cases(d), ]

  test <- suppressWarnings(stats::cor.test(d[[x]], d[[y]], method = method))
  r    <- unname(test$estimate)
  pv   <- test$p.value

  coef_symbol <- if (method == "pearson") "r" else "\u03c1"
  method_name <- if (method == "pearson") "Pearson" else "Spearman"
  p_txt       <- if (pv < 0.001) "< 0.001" else sprintf("= %.3f", pv)
  stars       <- if (exists("pval_stars")) pval_stars(pv) else ""

  ann_label <- sprintf("%s = %.*f (%s)\np %s %s", coef_symbol, digits, r, method_name, p_txt, stars)

  xl <- if (!is.null(x_label)) x_label else x
  yl <- if (!is.null(y_label)) y_label else y

  pos <- switch(label_pos,
    top_left     = list(x = -Inf, y =  Inf, hjust = -0.05, vjust = 1.3),
    top_right    = list(x =  Inf, y =  Inf, hjust =  1.05, vjust = 1.3),
    bottom_left  = list(x = -Inf, y = -Inf, hjust = -0.05, vjust = -0.3),
    bottom_right = list(x =  Inf, y = -Inf, hjust =  1.05, vjust = -0.3)
  )

  p <- ggplot2::ggplot(d, ggplot2::aes(x = .data[[x]], y = .data[[y]])) +
    ggplot2::geom_point(color = point_color, alpha = point_alpha, size = point_size) +
    ggplot2::geom_smooth(
      method    = if (smooth == "linear") "lm" else "loess",
      formula   = y ~ x,
      color     = line_color, fill = line_color, alpha = 0.15, linewidth = 0.9
    ) +
    ggplot2::labs(title = title, x = xl, y = yl) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title       = ggplot2::element_text(face = "bold", size = 12, color = "#1F3864"),
      panel.grid.minor = ggplot2::element_blank()
    ) +
    ggplot2::annotate(
      "label",
      x = pos$x, y = pos$y, hjust = pos$hjust, vjust = pos$vjust,
      label = ann_label, size = 3.6, color = "#1F3864",
      fill = "white", label.size = 0.3, fontface = "bold"
    )

  p
}

# -----------------------------------------------------------------------------
# save_correlation_grid : applique plot_correlation() à une ou plusieurs
# paires de variables et assemble le résultat (via patchwork) dans une seule
# figure, sauvegardée si file_path est fourni. Fonctionne aussi bien pour une
# paire unique (une image correctement proportionnée) que pour plusieurs
# paires combinées côte à côte.
#
# pairs   : liste de vecteurs de longueur 2, ex. list(c("term_cal","pd_n"), ...)
# labels  : liste nommée variable -> libellé (optionnel)
# ...     : arguments supplémentaires transmis à plot_correlation()
#           (method, smooth, point_color, line_color, digits, label_pos, ...)
# -----------------------------------------------------------------------------
save_correlation_grid <- function(df, pairs, labels = NULL,
                                   ncol = NULL, nrow = NULL,
                                   file_path = NULL, width = NULL, height = NULL,
                                   ...) {

  plots <- lapply(pairs, function(pr) {
    x <- pr[1]; y <- pr[2]
    plot_correlation(
      df, x, y,
      x_label = if (!is.null(labels) && x %in% names(labels)) labels[[x]] else x,
      y_label = if (!is.null(labels) && y %in% names(labels)) labels[[y]] else y,
      ...
    )
  })

  if (is.null(ncol)) ncol <- length(plots)
  if (is.null(nrow)) nrow <- 1

  combined <- patchwork::wrap_plots(plots, ncol = ncol, nrow = nrow)

  if (!is.null(file_path)) {
    if (is.null(width))  width  <- 5.2 * ncol
    if (is.null(height)) height <- 4.4 * nrow
    ggplot2::ggsave(file_path, combined, width = width, height = height, dpi = 300, bg = "white")
  }

  combined
}
