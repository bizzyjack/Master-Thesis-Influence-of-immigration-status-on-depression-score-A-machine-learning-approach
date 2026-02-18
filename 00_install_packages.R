pkgs <- c(
  "tidyverse",
  "tidymodels",
  "naniar",
  "survey",
  "srvyr",
  "visdat",
  "ranger",
  "vip",
  "janitor",
  "forcats",
  "gtsummary",
  "gt",
  "broom",
  "VIM",
  "effectsize",
  "smd",
  "yardstick",
  "DALEX",
  "patchwork",
  "fairmodels",
  "ggrepel",
  "scales",
  "corrplot",
  "pmsampsize",
  "haven"
)

to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install) > 0)
  install.packages(to_install, dependencies = TRUE)
