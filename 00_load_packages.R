pkgs <- c(
  "tidyverse", "tidymodels", "naniar", "survey", "srvyr", "visdat", "ranger", "vip",
  "janitor", "forcats", "gtsummary", "gt", "broom", "VIM", "effectsize", "smd",
  "yardstick", "DALEX", "patchwork", "fairmodels", "ggrepel", "scales", "corrplot",
  "pmsampsize", "haven"
)

invisible(lapply(pkgs, library, character.only = TRUE))
