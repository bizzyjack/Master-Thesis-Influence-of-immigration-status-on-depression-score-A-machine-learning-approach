pkgs <- c(
  "tidyverse",
  "tidymodels",
  "naniar",
  "ranger",
  "vip",
  "gtsummary",
  "gt",
  "broom",
  "srvyr",
  "janitor",
  "VIM",
  "smd",
  "survey",
  "effectsize",
  "DALEX",
  "ggrepel",
  "fairmodels",
  "corrplot",
  "pmsampsize",
  "haven",
  "scales",
  "forcats"
)

invisible(lapply(pkgs, library, character.only = TRUE))
