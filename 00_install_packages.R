pkgs <- c(
  "tidyverse",
  "tidymodels",
  "naniar",
  "ranger",
  "vip",
  "gtsummary",
  "srvyr",
  "janitor",
  "gt",
  "broom",
  "survey",
  "smd",
  "VIM",
  "effectsize",
  "fairmodels",
  "DALEX",
  "ggrepel",
  "corrplot",
  "pmsampsize",
  "haven",
  "scales",
  "forcats"
)

to_install <- setdiff(pkgs, rownames(installed.packages()))

for (p in to_install) {
  message("Installing: ", p)
  try(install.packages(p, dependencies = NA))
}
