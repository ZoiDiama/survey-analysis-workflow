# =============================================================================
# 06_charts.R                                             Workflow step 8: Reporting
#
# The three charts in the brief, in the portfolio style (theme_zd.R):
#   1 In how many states IDP households are clearly worse off, by indicator
#   2 No household member earning: IDP and host households by state
#   3 Validation: published figures against the same figures from the data
#
# Input : output/tables/T2_idp_and_host.csv, T2_summary.csv, T6_validation.csv
# Output: output/figures/chart_1_overview.png, chart_2_work.png, chart_3_validation.png
# =============================================================================

library(tidyverse)
source("R/theme_zd.R")

T2         <- read_csv("output/tables/T2_idp_and_host.csv", show_col_types = FALSE)
T2_summary <- read_csv("output/tables/T2_summary.csv", show_col_types = FALSE)
T6         <- read_csv("output/tables/T6_validation.csv", show_col_types = FALSE)
dir.create("output/figures", showWarnings = FALSE)

save_chart <- function(p, file, width = 8, height = 4.8) {
  ggsave(file.path("output/figures", file), p, width = width, height = height,
         dpi = 300, device = ragg::agg_png, bg = "white")
}
source_note <- paste("Source: IDMC/NRC household survey, Aug-Nov 2024 (HDX). Unweighted; surveyed sites only,",
                     "not representative of all IDPs in Sudan. Clear difference: 95% CI excludes 0 and at least 5 points.")


# 1. OVERVIEW ------------------------------------------------------------------------
# Navy: states where IDP households are clearly worse off; grey: the other states.
overview <- T2_summary %>%
  mutate(label = fct_reorder(str_remove(indicator, "^\\d+ "), idps_worse_off))
stopifnot(all(overview$hosts_worse_off == 0))   # the subtitle says so

p1 <- ggplot(overview, aes(y = label)) +
  geom_col(aes(x = states_reported), fill = zd_palettes$highlight[["context"]], width = 0.62) +
  geom_col(aes(x = idps_worse_off),  fill = zd_palettes$highlight[["focus"]],   width = 0.62) +
  geom_text(aes(x = states_reported, label = paste(idps_worse_off, "of", states_reported)),
            hjust = -0.15, family = "Poppins", size = 3.4, colour = zd_colours[["text"]]) +
  scale_x_continuous(limits = c(0, 9.3), expand = expansion(0)) +
  labs(title = "IDP households are worse off than hosts on every indicator,\nmost consistently on work",
       subtitle = "States (of 8) where IDP households are clearly worse off than host households (navy);\ngrey: no clear difference. Hosts are never clearly worse off.",
       x = NULL, y = NULL, caption = str_wrap(source_note, 110)) +
  theme_zd(base_size = 11, grid = "none") +
  theme(axis.text.x = element_blank())
save_chart(p1, "chart_1_overview.png", height = 4.6)


# 2. WORK -----------------------------------------------------------------------------
work <- T2 %>% filter(indicator == "2 No household member earning from work") %>%
  mutate(state = fct_reorder(state, pct_idp))
work_long <- work %>% select(state, IDP = pct_idp, Host = pct_host) %>%
  pivot_longer(c(IDP, Host), names_to = "group", values_to = "pct")
stopifnot(all(work$clear))   # the caption says so

p2 <- ggplot(work, aes(y = state)) +
  geom_segment(aes(x = pct_host, xend = pct_idp, yend = state), colour = zd_colours[["grid"]], linewidth = 2.2) +
  geom_point(data = work_long, aes(x = pct, fill = group), shape = 21, size = 3.6, colour = "white", stroke = 0.8) +
  geom_text(aes(x = pct_idp, label = sprintf("+%.0f", difference)), hjust = -0.6,
            family = "Poppins", size = 3.1, colour = zd_colours[["muted"]]) +
  scale_fill_manual(values = c(IDP = zd_cat(2)[1], Host = zd_cat(2)[2]), breaks = c("IDP", "Host"),
                    labels = c("IDP households", "Host households")) +
  scale_x_continuous(limits = c(0, 100), labels = function(x) paste0(x, "%")) +
  labs(title = sprintf("In every state, IDP households are %.0f to %.0f points more\nlikely than hosts to have no one earning",
                       min(work$difference), max(work$difference)),
       subtitle = "Households where no member earns money from work, by state (difference in percentage points)",
       x = NULL, y = NULL, caption = str_wrap(paste(source_note, "All 8 differences are clear."), 110)) +
  theme_zd(base_size = 11, grid = "x")
save_chart(p2, "chart_2_work.png", height = 5)


# 3. VALIDATION ---------------------------------------------------------------------------
# Six-state figures as pooled shares (the average of the state shares gives the
# same count). Navy: not reproduced (more than 5 points apart). Band: within 2 points.
val <- T6 %>% mutate(not_reproduced = verdict_pooled == "Not reproduced")
labels <- tribble(
  ~figure_id, ~label,                                    ~hjust, ~dx,  ~dy,
  "F19",      "Hosts in urgent need of\nnon-food items",  1,     -2.5,  0,
  "F20",      "Same, hosts\nin Northern",                 1,     -2.5,  0,
  "F21",      "IDPs' children\nnot in school",            0,      2.5, -4,
  "F22",      "Hosts' children\nnot in school",           0,      2.5, -6
) %>% left_join(select(val, figure_id, nrc_value, pooled), by = "figure_id")
stopifnot(setequal(labels$figure_id, val$figure_id[val$not_reproduced]))   # labels match the data

p3 <- ggplot(val, aes(nrc_value, pooled)) +
  annotate("polygon", x = c(0, 100, 100, 0), y = c(-2, 98, 102, 2), fill = zd_colours[["grid"]], alpha = 0.7) +
  geom_abline(slope = 1, intercept = 0, colour = zd_palettes$highlight[["context"]], linewidth = 0.5) +
  geom_point(aes(colour = not_reproduced), size = 2.6) +
  geom_text(data = labels, aes(x = nrc_value + dx, y = pooled + dy, label = label, hjust = hjust),
            family = "Poppins", size = 3, lineheight = 0.95, colour = zd_colours[["text"]]) +
  scale_colour_zd_highlight() +
  scale_x_continuous(limits = c(0, 100), labels = function(x) paste0(x, "%")) +
  scale_y_continuous(limits = c(-2, 102), labels = function(x) paste0(x, "%")) +
  coord_equal(clip = "off") +
  labs(title = sprintf("The public data reproduce %d of %d figures\nin the published report", sum(val$verdict_pooled == "Reproduced"), nrow(val)),
       subtitle = "Each dot is one figure: as published (across) and\nrecalculated from the data (up). Band: within 2 points.",
       x = "Published in the report", y = "Recalculated from the data",
       caption = str_wrap(paste("Source: NRC (2024) Bursting at the seams; IDMC/NRC household survey (HDX). Six August-round states;",
                                "six-state figures as pooled shares. Navy: not reproduced (more than 5 points apart)."), 75)) +
  theme_zd(base_size = 11, grid = "xy")
save_chart(p3, "chart_3_validation.png", width = 6.4, height = 7)

cat("Done: 3 charts in output/figures\n")
