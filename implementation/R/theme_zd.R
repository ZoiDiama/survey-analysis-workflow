# theme_zd.R ---------------------------------------------------------------
# Chart theme and colour palettes for Zoi Diamantakou's portfolio.
# Matches the website: Poppins, white background, navy headings,
# light warm grid lines.
#
# How to use
#   source("theme_zd.R")
#   ggplot(df, aes(year, value, colour = group)) +
#     geom_line() +
#     scale_colour_zd() +
#     labs(title = "Finding as the title", subtitle = "What is measured",
#          caption = "Source: ...") +
#     theme_zd()
#
# Font: install Poppins from Google Fonts on your computer.
# Saving: use ragg so the font is embedded correctly, e.g.
#   ggsave("chart.png", width = 8, height = 5, dpi = 300,
#          device = ragg::agg_png, bg = "white")
# ---------------------------------------------------------------------------

library(ggplot2)

# Colours -------------------------------------------------------------------

# Brand colours (website): use for text, titles and single-colour highlights.
zd_colours <- c(
  navy      = "#22344F",  # buttons, focus colour in highlight charts
  heading   = "#1A2A40",  # chart titles
  teal      = "#1F7A80",  # brand teal
  magenta   = "#B03A62",
  orange    = "#D9762B",
  ink       = "#1F1F1F",  # main text
  text      = "#4A4640",  # subtitles, legend text
  muted     = "#5B5750",  # axis text, captions
  grid      = "#ECE7E0",  # grid lines and borders
  band      = "#FAF8F5",  # light background band
  white     = "#FFFFFF"
)

# Chart palettes. The categorical set has been checked for colour-blind
# separation, contrast on white, and lightness. Keep this order: colour
# follows the group, never its rank.
zd_palettes <- list(
  # Up to 4 groups. More than 4: fold the rest into "Other" or use facets.
  categorical = c("#2F6DB0",   # blue
                  "#D9762B",   # orange
                  "#0F9A93",   # teal
                  "#B03A62"),  # magenta
  other       = "#9AA1AA",     # grey for "Other" / everything else

  # One group stands out, the rest are context.
  highlight   = c(focus = "#22344F", context = "#C9CED6"),

  # Magnitude: one hue, light to dark.
  sequential  = c("#E4ECF5", "#BCD0E6", "#8EAED4", "#5F8CC1",
                  "#2F6DB0", "#22344F"),

  # Above / below a midpoint: two hues with a neutral grey centre.
  diverging   = c("#B03A62", "#D58AA4", "#F0D3DD", "#EEEBE7",
                  "#C3E3E0", "#6CBDB6", "#0F9A93")
)

# Return n categorical colours, in fixed order.
zd_cat <- function(n = 4) {
  if (n > length(zd_palettes$categorical)) {
    stop("theme_zd has 4 categorical colours. With more groups, fold the ",
         "smallest into 'Other' (zd_palettes$other) or use facet_wrap().",
         call. = FALSE)
  }
  zd_palettes$categorical[seq_len(n)]
}

# Scales --------------------------------------------------------------------

# Groups (discrete). Pass named values to fix colours to groups, e.g.
#   scale_colour_zd(values = c(IDP = zd_cat()[1], Host = zd_cat()[2]))
scale_colour_zd <- function(..., values = NULL) {
  if (is.null(values)) values <- zd_palettes$categorical
  scale_colour_manual(..., values = values)
}
scale_fill_zd <- function(..., values = NULL) {
  if (is.null(values)) values <- zd_palettes$categorical
  scale_fill_manual(..., values = values)
}

# One group highlighted, everything else grey.
# Map a logical or two-level variable, e.g. aes(fill = country == "Greece").
scale_fill_zd_highlight <- function(..., guide = "none") {
  scale_fill_manual(..., values = c(`TRUE` = zd_palettes$highlight[["focus"]],
                                    `FALSE` = zd_palettes$highlight[["context"]]),
                    guide = guide)
}
scale_colour_zd_highlight <- function(..., guide = "none") {
  scale_colour_manual(..., values = c(`TRUE` = zd_palettes$highlight[["focus"]],
                                      `FALSE` = zd_palettes$highlight[["context"]]),
                      guide = guide)
}

# Magnitude (continuous): light to dark blue.
scale_fill_zd_seq <- function(...) {
  scale_fill_gradientn(..., colours = zd_palettes$sequential)
}
scale_colour_zd_seq <- function(...) {
  scale_colour_gradientn(..., colours = zd_palettes$sequential)
}

# Above / below a midpoint (continuous): magenta - grey - teal.
scale_fill_zd_div <- function(..., midpoint = 0) {
  scale_fill_gradientn(
    ..., colours = zd_palettes$diverging,
    rescaler = function(x, to = c(0, 1), from = range(x, na.rm = TRUE)) {
      scales::rescale_mid(x, to = to, from = from, mid = midpoint)
    }
  )
}
scale_colour_zd_div <- function(..., midpoint = 0) {
  scale_colour_gradientn(
    ..., colours = zd_palettes$diverging,
    rescaler = function(x, to = c(0, 1), from = range(x, na.rm = TRUE)) {
      scales::rescale_mid(x, to = to, from = from, mid = midpoint)
    }
  )
}

# Theme ---------------------------------------------------------------------

# grid: "y" (default, for bars and lines), "x" (horizontal bars), "xy" or "none"
theme_zd <- function(base_size = 12, base_family = "Poppins", grid = "y") {
  grid_line <- element_line(colour = zd_colours[["grid"]], linewidth = 0.4)

  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      # Background
      plot.background  = element_rect(fill = zd_colours[["white"]], colour = NA),
      panel.background = element_rect(fill = zd_colours[["white"]], colour = NA),

      # Grid: light and in one direction only
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = if (grid %in% c("x", "xy")) grid_line else element_blank(),
      panel.grid.major.y = if (grid %in% c("y", "xy")) grid_line else element_blank(),

      # Axes: quiet
      axis.ticks  = element_blank(),
      axis.text   = element_text(colour = zd_colours[["muted"]], size = rel(0.85)),
      axis.title  = element_text(colour = zd_colours[["muted"]], size = rel(0.85)),
      axis.title.x = element_text(margin = margin(t = 8)),
      axis.title.y = element_text(margin = margin(r = 8)),

      # Titles: finding-led title, left-aligned with the whole plot
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.title = element_text(face = "bold", size = rel(1.45),
                                colour = zd_colours[["heading"]],
                                lineheight = 1.15, margin = margin(b = 6)),
      plot.subtitle = element_text(size = rel(1), colour = zd_colours[["text"]],
                                   lineheight = 1.3, margin = margin(b = 14)),
      plot.caption = element_text(size = rel(0.72), colour = zd_colours[["muted"]],
                                  hjust = 0, lineheight = 1.3,
                                  margin = margin(t = 14)),

      # Legend: top left, no title (the subtitle explains the groups)
      legend.position      = "top",
      legend.justification = "left",
      legend.title         = element_blank(),
      legend.text          = element_text(colour = zd_colours[["text"]],
                                          size = rel(0.85)),
      legend.key.size      = unit(0.9, "lines"),
      legend.margin        = margin(0, 0, 4, 0),

      # Facets
      strip.text = element_text(face = "bold", colour = zd_colours[["ink"]],
                                hjust = 0, size = rel(0.95),
                                margin = margin(b = 6)),
      panel.spacing = unit(1.2, "lines"),

      plot.margin = margin(20, 24, 16, 20)
    )
}

# Optional: default look for geoms (thin lines, readable points, Poppins labels)
zd_set_defaults <- function(base_family = "Poppins") {
  update_geom_defaults("line",  list(linewidth = 0.8, colour = zd_palettes$categorical[1]))
  update_geom_defaults("point", list(size = 2.4, colour = zd_palettes$categorical[1]))
  update_geom_defaults("col",   list(fill = zd_palettes$categorical[1]))
  update_geom_defaults("bar",   list(fill = zd_palettes$categorical[1]))
  update_geom_defaults("text",  list(family = base_family, colour = zd_colours[["ink"]], size = 3.5))
  update_geom_defaults("label", list(family = base_family, colour = zd_colours[["ink"]], size = 3.5))
  invisible(TRUE)
}