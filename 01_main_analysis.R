#### packages and data download ####




##loading the required packages
source("00_load_packages.R")

#filesave
if (!file.exists("00_load_packages.R")) {
  stop("Missing 00_load_packages.R. Please clone the full repo and run from project root.")
}
source("00_load_packages.R")


##Reproducibility general seed
set.seed(231)

#Folders for figures
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)



##gathering nhaness data
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

download_if_needed <- function(url, dest_dir = "data/raw") {
  dest_file <- file.path(dest_dir, basename(url))
  
  if (!file.exists(dest_file)) {
    message("Downloading: ", url)
    utils::download.file(url,
                         destfile = dest_file,
                         mode = "wb",
                         quiet = FALSE)
  } else {
    message("Using cached file: ", dest_file)
  }
  
  dest_file
}

# URLs (source of truth)
nhanes_urls <- list(
  demo = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/DEMO_L.XPT",
  dpq  = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/DPQ_L.xpt",
  hiq  = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/HIQ_L.xpt",
  huq  = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/HUQ_L.xpt",
  hoq  = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/HOQ_L.xpt",
  inq  = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/INQ_L.xpt",
  ocq  = "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/OCQ_L.xpt"
)

# Download (or reuse cached)
nhanes_files <- lapply(nhanes_urls, download_if_needed)

# Read local files (NOT directly from the internet)
demo <- haven::read_xpt(nhanes_files$demo)
DPQ  <- haven::read_xpt(nhanes_files$dpq)
HIQ  <- haven::read_xpt(nhanes_files$hiq)
HUQ  <- haven::read_xpt(nhanes_files$huq)
HOQ  <- haven::read_xpt(nhanes_files$hoq)
INQ  <- haven::read_xpt(nhanes_files$inq)
OCQ  <- haven::read_xpt(nhanes_files$ocq)

#merge databases into one data set by respondent number
nhanes_allData <- demo %>%
  left_join(DPQ, by = "SEQN") %>%
  left_join(HIQ, by = "SEQN") %>%
  left_join(HUQ, by = "SEQN") %>%
  left_join(HOQ, by = "SEQN") %>%
  left_join(INQ, by = "SEQN") %>%
  left_join(OCQ, by = "SEQN")

#### Data preparation  ####

##creating a cleaned data set that has all the required variables named correctly
nhanes_cleaned <- nhanes_allData

#removing variables that are not used
nhanes_cleaned <- nhanes_cleaned %>%
  select(
    -SDDSRVYR,
    -RIDSTATR,
    -RIDAGEMN,
    -RIDEXMON,
    -RIDEXAGM,
    -DMDHRGND,
    -DMDHRAGZ,
    -DMDHREDZ,
    -DMDHRMAZ,
    -DMDHSEDZ
    ,
    -OCQ210,
    -OCQ215,
    -OCQ383,
    -OCQ180,
    -WTMEC2YR,
    -RIDRETH1,
    -DMQMILIZ,
    -DMDMARTZ,
    -RIDEXPRG,
    -HIQ032A,
    -HIQ032B
    ,
    -HIQ032C,
    -HIQ032D,
    -HIQ032E,
    -HIQ032F,
    -HIQ032H,
    -HIQ032I,
    -HIQ210,
    -DMDHHSIZ,
    -HUQ030,
    -HUQ042,
    -HUQ055
    ,
    -HUQ090 ,
    -HOD051,
    -INQ300,
    -IND310,
    -INDFMMPC
  )

#renaming variables that are used to what they mean
nhanes_cleaned <- nhanes_cleaned %>%
  rename(
    gender = RIAGENDR,
    age = RIDAGEYR,
    race = RIDRETH3,
    years_in_US = DMDYRUSR,
    education = DMDEDUC2,
    income_ratio = INDFMPIR,
    health_insurance = HIQ011,
    general_health = HUQ010,
    occupation = OCD150,
    immigrant_status = DMDBORN4
  )

##filtering out everyone who is under 18
nhanes_cleaned <- nhanes_cleaned %>%
  filter(age >= 18)

##re-coding used variables so all options not relevant to study question are NAs

#making health_insurance variable having health insurance = 1, and no = 0, everything else is na
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(
    health_insurance = case_when(
      health_insurance == 1 ~ 1L,
      health_insurance == 2 ~ 0L,
      health_insurance %in% c(7, 9) |
        is.na(health_insurance) ~ NA_integer_
    )
  )

#type of work done 7,9 as NA
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(occupation = na_if(occupation, 7),
         occupation = na_if(occupation, 9))

#immigrant_status if answered 77 or 99 = na
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(
    immigrant_status = na_if(immigrant_status, 77),
    immigrant_status = na_if(immigrant_status, 99)
  )

#years_in_the_us if answered 77 or 99 = na
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(years_in_US = na_if(years_in_US, 77),
         years_in_US = na_if(years_in_US, 99))

#mutate all missing values on years_in_the_us as 0
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(years_in_US = if_else(is.na(years_in_US), 0, years_in_US))


#education if answered 7 or 9 = na
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(education = na_if(education, 7),
         education = na_if(education, 9))

#general health if answered 7 or 9 = na
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(
    general_health = na_if(general_health, 7),
    general_health = na_if(general_health, 9)
  )

#depression questions if answered 7 or 9 = na
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(across(
    DPQ010:DPQ090,
    ~ case_when(
      .x %in% 0:3 ~ as.numeric(.x),
      .x %in% c(7, 9) ~ NA_real_,
      TRUE ~ NA_real_
    )
  ))

##log transformation of income ratio as its positively  skewed
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(income_ratio_log = log(income_ratio + 0.01))


##MCAR test to see if data is missing at random
#Selecting variables for MCAR test
vars_to_test <- nhanes_cleaned %>%
  select(
    gender,
    age,
    race,
    years_in_US,
    education,
    income_ratio_log,
    health_insurance,
    general_health,
    occupation,
    immigrant_status
  )

mcar_test(vars_to_test)

#making a container for variables that may EXPLAIN missingness (predictors in the models)
expl_vars <- c(
  "gender",
  "age",
  "race",
  "years_in_US",
  "education",
  "income_ratio_log",
  "health_insurance",
  "general_health",
  "occupation",
  "immigrant_status"
)

#making a container for variables that HAVE missingness (targets in the models)
vars_with_na <- miss_var_summary(nhanes_cleaned) %>%
  filter(n_miss > 0) %>%
  pull(variable)

#Creating an function: for each variable in the model ask the question "is it missing?"
test_missingness_for_var <- function(var, data, predictors) {
  preds <- setdiff(predictors, var)
  if (length(preds) == 0)
    return(NULL)
  
  
  form <- as.formula(paste0("miss_", var, " ~ ", paste(preds, collapse = " + ")))
  
  data %>%
    mutate(!!paste0("miss_", var) := as.integer(is.na(.data[[var]]))) %>%
    glm(formula = form,
        data = .,
        family = binomial()) %>%
    tidy() %>%
    filter(term != "(Intercept)") %>%       # drop intercept
    mutate(target_variable = var, .before = 1)
}

#Run the function for all variables with NA
missingness_results <- map_dfr(vars_with_na,
                               ~ test_missingness_for_var(.x, nhanes_cleaned, expl_vars))

#Keep only significant predictors of missingness
missingness_results_sig <- missingness_results %>%
  filter(p.value < 0.05) %>%
  arrange(target_variable, p.value)

missingness_results_sig

##imputing mising values
nhanes_imputed <- kNN(nhanes_cleaned, k = 5)

#Removing additional colums indicators created by kNN
nhanes_imputed <- nhanes_imputed %>%
  select(-ends_with("_imp"))

#Merge imputed dataset into cleaned dataset
nhanes_cleaned <- nhanes_imputed

##Create PHQ-9 total score
nhanes_cleaned <- nhanes_cleaned %>%
  rowwise() %>%
  mutate(
    phq_items_answered = sum(!is.na(c_across(DPQ010:DPQ090))),
    phq9_total = if_else(phq_items_answered >= 7, sum(c_across(DPQ010:DPQ090), na.rm = TRUE), NA_real_)
  ) %>%
  ungroup()


## Computing an correlation matrix
num_vars <- nhanes_cleaned %>%
  select(where(is.numeric))


num_vars <- num_vars[, !names(num_vars) %in% c(
  "DPQ010",
  "DPQ020",
  "income_ratio",
  "DPQ030",
  "DPQ040",
  "DPQ050",
  "DPQ060",
  "DPQ070",
  "DPQ080",
  "DPQ090",
  "DPQ100",
  "INDFMMPI",
  "SEQN",
  "phq_items_answered",
  "WTINT2YR",
  "SDMVSTRA",
  "SDMVPSU"
)]


cor_matrix <- cor(num_vars, use = "pairwise.complete.obs")

#View  the correlation matrix
cor_matrix

high_corr <- which(abs(cor_matrix) > 0.7 &
                     abs(cor_matrix) < 1, arr.ind = TRUE)
cor_matrix[high_corr]


corrplot(cor_matrix,
         type = "upper",
         tl.col = "black",
         tl.cex = 0.7)

#calculation to see if sample size is large enough for study question
sd_phq9 <- sd(nhanes_cleaned$phq9_total, na.rm = TRUE)
sd_phq9

phq9_intercept <- mean(nhanes_cleaned$phq9_total, na.rm = TRUE)
phq9_intercept

pmsampsize(
  type        = "c",
  rsquared    = 0.90,
  parameters  = 10,
  sd          = sd(nhanes_cleaned$phq9_total, na.rm = TRUE),
  intercept   = phq9_intercept
)


#### models ####
##creating bins for the PHQ-9 score so stratified sampling can be used, as its heavily negativly skewed
nhanes_cleaned <- nhanes_cleaned %>%
  mutate(phq9_bin = cut(
    phq9_total,
    breaks = c(-Inf, 4, 9, 14, 19, 27),
    labels = c(
      "0-4 None",
      "5-9 Mild",
      "10-14 Moderate",
      "15-19 Moderately Severe",
      "20-27 Severe"
    ),
    right = TRUE
  ))

tidymodels_prefer()

##splitting the data into training/testing sets using the creating bins
set.seed(999)

nhanes_split <- initial_split(nhanes_cleaned, prop = 0.80, strata = phq9_bin)
nhanes_split
nhanes_train <- training(nhanes_split)
nhanes_test <- testing(nhanes_split)

##creating the stratified vfolds
set.seed(111)
nhanes_folds <- vfold_cv(nhanes_train, strata = phq9_bin)

##creating the recipe that will be used for all models
nhanes_recipe <- recipe(
  phq9_total ~
    gender + age + race + years_in_US + education + income_ratio_log + health_insurance + general_health
  + occupation + immigrant_status ,
  data = nhanes_train
) %>%
  step_mutate(
    gender = factor(gender),
    race = factor(race),
    education = factor(education),
    general_health = factor(general_health),
    occupation = factor(occupation),
    health_insurance = factor(health_insurance),
    immigrant_status = factor(immigrant_status)
  )

#inspect data
nhanes_prep <- prep(nhanes_recipe)
juiced <- juice(nhanes_prep)

##Creating the RF model
#specifying hyper parameters for tuning
tune_spec <- rand_forest(mtry = tune(),
                         trees = 1000,
                         min_n = tune()) %>%
  set_mode("regression") %>%
  set_engine("ranger")

#creating the workflow
nhanes_workflow <-
  workflow() %>%
  add_recipe(nhanes_recipe) %>%
  add_model(tune_spec)

#performance metrics
rf_metrics <- metric_set(rmse, rsq, mae)

#tuning hyper parameters
set.seed(222)
tune_res <- tune_grid(
  nhanes_workflow,
  resamples = nhanes_folds,
  grid = 20,
  metrics = rf_metrics
)

#viewing tuned results
tune_res %>%
  collect_metrics() %>%
  filter(.metric == "rmse") %>%
  select(mean, min_n, mtry) %>%
  pivot_longer(min_n:mtry, values_to = "value", names_to = "parameter") %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap( ~ parameter, scale = "free_x")

#creating manual grid for closer inspecting
rf_grid <- grid_regular(mtry(range = c(2, 5)), min_n(range =  c(5, 40)), levels = 5)

set.seed(333)
regular_res <- tune_grid(
  nhanes_workflow,
  resamples = nhanes_folds,
  grid = rf_grid,
  metrics = rf_metrics,
  control = control_grid(save_pred = TRUE)
)

regular_res

#view manual grid
regular_res %>%
  collect_metrics() %>%
  filter(mtry != 1) %>%
  filter(.metric == "rmse") %>%
  mutate(min_n = factor(min_n)) %>%
  ggplot(aes(mtry, mean, colour = min_n)) +
  geom_line(alpha = 0.5, size = 1.5) +
  geom_point()

#selecting the best performing hyperparameters based on the rmse score
best_rmse <- select_best(regular_res, metric = "rmse")
best_rmse

final_rf <- finalize_model(tune_spec, best_rmse)

#final rf model
final_wf <- workflow() %>%
  add_recipe(nhanes_recipe) %>%
  add_model(final_rf)

#fitting final rf model on the test set
final_res <- final_wf %>%
  last_fit(nhanes_split)

#view results
final_res %>%
  collect_metrics()

## XGBoost model

tidymodels_prefer()


#Recipe for XGBoost
nhanes_xgb_recipe <- nhanes_recipe %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors())


#XGBoost model spec for tuning
xgb_spec <- boost_tree(
  trees         = 300,
  tree_depth     = tune(),
  learn_rate     = tune(),
  min_n          = tune(),
  loss_reduction = tune(),
  sample_size    = tune(),
  mtry           = tune()
) %>%
  set_engine("xgboost") %>%
  set_mode("regression")

xgb_spec

#Workflow for XGBoost
xgb_wf <- workflow() %>%
  add_recipe(nhanes_xgb_recipe) %>%
  add_model(xgb_spec)

xgb_wf

#Tuning grid
set.seed(444)

# Space-filling grid over hyperparameter space
xgb_grid <- grid_space_filling(
  tree_depth(),
  min_n(),
  loss_reduction(),
  sample_size = sample_prop(),
  finalize(mtry(), nhanes_train),
  learn_rate(),
  size = 20
)

xgb_grid

#Tune XGBOOST with the SAME folds & metrics as RF
set.seed(555)
xgb_res <- tune_grid(
  xgb_wf,
  resamples = nhanes_folds,
  grid      = xgb_grid,
  metrics   = rf_metrics,
  control   = control_grid(save_pred = TRUE)
)

#View tuning results
xgb_res %>%
  collect_metrics() %>%
  filter(.metric == "rmse") %>%
  select(mean, mtry:sample_size) %>%
  pivot_longer(mtry:sample_size, names_to = "parameter", values_to = "value") %>%
  ggplot(aes(value, mean, color = parameter)) +
  geom_point(show.legend = FALSE) +
  facet_wrap( ~ parameter, scales = "free_x")

show_best(xgb_res, metric = "rmse")

#Pick best XGBoost model by RMSE
best_xgb <- xgb_res %>%
  select_best(metric = "rmse")

best_xgb

final_xgb <- finalize_model(xgb_spec, best_xgb)


#Final XGBoost workflow + test-set evaluation
final_xgb_wf <- workflow() %>%
  add_recipe(nhanes_xgb_recipe) %>%
  add_model(final_xgb)

final_xgb_wf %>%
  fit(data = nhanes_train) %>%
  pull_workflow_fit() %>%
  vip(geom = "point")

xgb_final_res <- last_fit(final_xgb_wf, nhanes_split)

xgb_final_res %>%
  collect_metrics()

## LM model
# Linear regression spec
lm_spec <- linear_reg() %>%
  set_engine("lm") %>%
  set_mode("regression")

#LM workflow
lm_wf <- workflow() %>%
  add_recipe(nhanes_recipe) %>%
  add_model(lm_spec)

#fit LM on training data
lm_fit <- fit(lm_wf, data = nhanes_train)

#fit LM on tesst data
lm_res <- last_fit(lm_wf, nhanes_split)

#view results
lm_res %>%
  collect_metrics()


#### Explainable AI results ####
#Creating an additional test set database for analysis
test_df <- nhanes_test

#Putting the dependent value on the Y axis
y_test <- test_df$phq9_total

#Putting the independent variables on the X axis
X_test <- test_df %>%
  select(
    gender,
    age,
    race,
    years_in_US,
    education,
    income_ratio_log,
    health_insurance,
    general_health,
    occupation,
    immigrant_status
  )

#Creating an DALEX compatible predict function based on "newdata"
predict_workflow <- function(model, newdata) {
  predict(model, new_data = newdata) %>%
    dplyr::pull(.pred)
}

# Fit final workflows on training data
rf_fit  <- fit(final_wf, data = nhanes_train)
xgb_fit <- fit(final_xgb_wf, data = nhanes_train)
lm_fit <- fit(lm_wf, data = nhanes_train)

##Make explainer containers
#RF explainer
explainer_rf <- explain(
  model = rf_fit,
  data  = X_test,
  y     = y_test,
  label = "Random Forest",
  predict_function = predict_workflow
)

#XGB explainer
explainer_xgb <- explain(
  model = xgb_fit,
  data  = X_test,
  y     = y_test,
  label = "XGBoost",
  predict_function = predict_workflow
)

#LM explainer
explainer_lm <- explain(
  model = lm_fit,
  data = X_test,
  y = y_test,
  label = "Linear Regression",
  predict_function = predict_workflow
)

##VIP TEST
set.seed(123)

vip_rf  <- model_parts(explainer_rf, loss_function = loss_root_mean_square)
vip_xgb <- model_parts(explainer_xgb, loss_function = loss_root_mean_square)
vip_lm  <- model_parts(explainer_lm, loss_function = loss_root_mean_square)

VIP_test <- plot(vip_lm, vip_rf, vip_xgb)

# Save for Word
ggsave(
  filename = "outputs/Figure_VIP_TEST_.png",
  plot     = VIP_test,
  width    = 10,
  height   = 14,
  dpi      = 300,
  bg = "white"
)




#### Plots and tables to view data results ####

##Code to create the demograhpic table

#creating factors for categorical predictors
nhanes_demo <- nhanes_cleaned %>%
  mutate(
    gender_fac = factor(
      gender,
      levels = c(1, 2),
      labels = c("Male", "Female")
    ),
    immigrant_status_fac = factor(
      immigrant_status,
      levels = c(1, 2),
      labels = c("Native-born", "Immigrant")
    ),
    race_fac = factor(
      race,
      levels = c(1, 2, 3, 4, 6, 7),
      labels = c(
        "Mexican American",
        "Other Hispanic",
        "Non-Hispanic White",
        "Non-Hispanic Black",
        "Non-Hispanic Asian",
        "Other / Multiracial"
      )
    ),
    education_fac = factor(
      education,
      levels = c(1, 2, 3, 4, 5),
      labels = c(
        "<9th grade",
        "9–11th grade",
        "High school/GED",
        "Some college/AA",
        "College graduate+"
      )
    ),
    general_health_fac = factor(
      general_health,
      levels = c(1, 2, 3, 4, 5),
      labels = c("Excellent", "Very good", "Good", "Fair", "Poor")
    ),
    health_insurance_fac = factor(
      health_insurance,
      levels = c(0, 1),
      labels = c("No", "Yes")
    ),
    occupation_fac = factor(occupation)
  )

#Creating the continuous independent variables for the table
continuous_vars <- c("age", "income_ratio", "years_in_US", "phq9_total")

mean_diff <- nhanes_demo %>%
  filter(!is.na(immigrant_status_fac)) %>%
  pivot_longer(all_of(continuous_vars),
               names_to = "variable",
               values_to = "value") %>%
  group_by(variable) %>%
  summarise(diff = mean(value[immigrant_status_fac == "Immigrant"], na.rm = TRUE) -
              mean(value[immigrant_status_fac == "Native-born"], na.rm = TRUE),
            .groups = "drop") %>%
  mutate(comparison = sprintf("ΔM = %.2f", diff)) %>%
  select(variable, comparison)


#Making an container for categorical varaibles
cat_vars <- c(
  "gender_fac",
  "race_fac",
  "education_fac",
  "occupation_fac",
  "health_insurance_fac",
  "general_health_fac"
)


prop_diff <- nhanes_demo %>%
  filter(!is.na(immigrant_status_fac)) %>%
  pivot_longer(all_of(cat_vars), names_to = "variable", values_to = "level") %>%
  filter(!is.na(level)) %>%
  count(variable, immigrant_status_fac, level, name = "n") %>%
  group_by(variable, immigrant_status_fac) %>%
  mutate(p = n / sum(n)) %>%
  ungroup() %>%
  select(variable, immigrant_status_fac, level, p) %>%
  pivot_wider(names_from = immigrant_status_fac, values_from = p) %>%
  mutate(diff = `Immigrant` - `Native-born`,
         comparison = sprintf("Δp = %.2f", diff)) %>%
  select(variable, level, comparison)


#Creating the Cohen's d (continuous)
cont_es <- nhanes_demo %>%
  filter(!is.na(immigrant_status_fac)) %>%
  pivot_longer(all_of(continuous_vars),
               names_to = "variable",
               values_to = "value") %>%
  group_by(variable) %>%
  summarise(
    d = effectsize::cohens_d(
      value ~ immigrant_status_fac,
      pooled_sd = TRUE,
      na.rm = TRUE
    )$Cohens_d,
    .groups = "drop"
  ) %>%
  mutate(
    d = ifelse(is.finite(d), d, NA_real_),
    effect_size = ifelse(is.na(d), NA_character_, sprintf("d=%.2f", d))
  ) %>%
  select(variable, effect_size)


#Creating the Cramér's V (categorical) - one per variable
cat_es <- lapply(cat_vars, function(v) {
  tmp <- nhanes_demo %>%
    select(immigrant_status_fac, !!sym(v)) %>%
    filter(!is.na(immigrant_status_fac), !is.na(.data[[v]]))
  
  tab <- table(tmp$immigrant_status_fac, tmp[[v]])
  V <- effectsize::cramers_v(tab)$Cramers_v
  V <- ifelse(is.finite(V), V, NA_real_)
  
  tibble(variable = v,
         effect_size = ifelse(is.na(V), NA_character_, sprintf("V=%.2f", V)))
}) %>%
  bind_rows()

#fit everything in a base table
demographic_table_base <- nhanes_demo %>%
  select(
    immigrant_status_fac,
    age,
    income_ratio,
    years_in_US,
    phq9_total,
    gender_fac,
    race_fac,
    education_fac,
    occupation_fac,
    health_insurance_fac,
    general_health_fac
  ) %>%
  tbl_summary(
    by = immigrant_status_fac,
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    missing = "no"
  ) %>%
  add_p()

#Create the final table
demographic_table <- demographic_table_base %>%
  modify_table_body(
    ~ .x %>%
      # add comparison stat (ΔM for continuous, Δp per level for categorical)
      left_join(mean_diff, by = "variable") %>%
      left_join(prop_diff, by = c("variable", "label" = "level")) %>%
      mutate(comparison = coalesce(comparison.x, comparison.y)) %>%
      select(-comparison.x, -comparison.y) %>%
      
      # add effect size (d for continuous, V for categorical)
      left_join(cont_es, by = "variable") %>%
      left_join(cat_es, by = "variable") %>%
      mutate(effect_size = coalesce(effect_size.x, effect_size.y)) %>%
      select(-effect_size.x, -effect_size.y) %>%
      
      # Show categorical effect size only once (first row of that variable block)
      group_by(variable) %>%
      mutate(effect_size = if_else(
        row_number() == 1, effect_size, NA_character_
      )) %>%
      ungroup() %>%
      
      # fill missing display
      mutate(
        comparison  = if_else(is.na(comparison), "—", comparison),
        effect_size = if_else(is.na(effect_size), "—", effect_size)
      )
  ) %>%
  modify_header(comparison  ~ "Comparison statistic",
                p.value     ~ "p value",
                effect_size ~ "Effect size")

#view the table
demographic_table

#Apply an APA formating to the table
demographic_table_apa <- demographic_table %>%
  modify_caption("**Table 1**\n*Sample characteristics by immigration status*") %>%
  bold_labels() %>%   # bold column labels + variable labels
  as_gt() %>%
  # Optional: relabel the default first column header if it shows "Characteristic"
  tab_style(style = cell_text(weight = "bold"),
            locations = cells_column_labels(everything())) %>%
  tab_options(
    table.align = "center",
    table.width = pct(100),
    table.font.size = 11,
    data_row.padding = px(3),
    
    # APA-like: minimal vertical lines, emphasize top/bottom rules
    table.border.top.color    = "black",
    table.border.top.width    = px(1),
    table.border.bottom.color = "black",
    table.border.bottom.width = px(1),
    
    table.border.left.style   = "none",
    table.border.right.style  = "none",
    
    # light horizontal lines in body (optional; set to 0 for cleaner APA)
    table_body.hlines.color   = "grey80",
    table_body.hlines.width   = px(0.5),
    
    # headings
    heading.align = "left",
    column_labels.border.top.width = px(0),
    column_labels.border.bottom.color = "black",
    column_labels.border.bottom.width = px(1)
  ) %>%
  # Make the stub (variable/level column) left-aligned
  cols_align(align = "left", columns = 1) %>%
  # Make numeric columns centered (adjust if your column names differ)
  cols_align(align = "center", columns = everything()) %>%
  # Format p-values nicely if present
  fmt_number(columns = matches("p value"), decimals = 3) %>%
  # Add an APA-style note
  tab_source_note(
    source_note = paste(
      "Note. Values are n (%) for categorical variables and M (SD) for continuous variables.",
      "Group difference is shown as mean difference or proportion difference (Immigrant − Native-born).",
      "Effect sizes: d = Cohen's d (continuous); V = Cramér’s V (categorical)."
    )
  )

#Save APA ready table to Word (.docx) for easy insertion
gtsave(demographic_table_apa, filename = "outputs/Table1_demographics_APA.docx")

#View the table
demographic_table_apa

##Distribution comparison: Development vs Test

#Defining the two datasets
dev_df  <- nhanes_train
test_df <- nhanes_test

#Container for Categorical predictors (demographics etc.)
cat_vars <- c(
  "gender",
  "race",
  "immigrant_status",
  "education",
  "health_insurance",
  "occupation",
  "general_health"
)

#Container for Numeric predictors + outcome
num_vars <- c("age", "years_in_US", "income_ratio", "phq9_total"   # outcome)
              
              #Create a general APA theme
              apa_theme <- theme_classic(base_size = 12) +
                theme(
                  plot.title = element_text(face = "bold"),
                  axis.title = element_text(face = "plain"),
                  strip.background = element_rect(fill = "white", colour = "black"),
                  strip.text = element_text(face = "bold"),
                  legend.title = element_blank(),
                  legend.position = "top"
                )
              
              #Tag rows with split
              dev_tagged  <- dev_df  %>% mutate(Split = "Development")
              test_tagged <- test_df %>% mutate(Split = "Test")
              
              both <- bind_rows(dev_tagged, test_tagged) %>%
                mutate(Split = factor(Split, levels = c("Development", "Test")))
              
              #FIGURE: Numeric predictors + outcome (density overlays)
              
              num_long <- both %>%
                select(all_of(c("Split", num_vars))) %>%
                pivot_longer(cols = all_of(num_vars),
                             names_to = "Variable",
                             values_to = "Value") %>%
                filter(!is.na(Value))
              
              fig_numeric <- ggplot(num_long, aes(x = Value, linetype = Split)) +
                geom_density(linewidth = 0.6) +
                facet_wrap( ~ Variable, scales = "free", ncol = 2) +
                labs(title = "Distribution comparison (Development vs Test): Numeric predictors and outcome", x = NULL, y = "Density") +
                apa_theme
              
              #FIGURE: Categorical predictors (proportion bars)
              
              cat_long <- both %>%
                select(all_of(c("Split", cat_vars))) %>%
                pivot_longer(cols = all_of(cat_vars),
                             names_to = "Variable",
                             values_to = "Level") %>%
                mutate(Level = as.factor(Level)) %>%
                filter(!is.na(Level)) %>%
                # reorder levels within each variable by overall frequency for nicer plots
                group_by(Variable) %>%
                mutate(Level = fct_infreq(Level)) %>%
                ungroup()
              
              cat_props <- cat_long %>%
                count(Split, Variable, Level) %>%
                group_by(Split, Variable) %>%
                mutate(prop = n / sum(n)) %>%
                ungroup()
              
              fig_categorical <- ggplot(cat_props, aes(x = Level, y = prop, fill = Split)) +
                geom_col(
                  position = position_dodge(width = 0.85),
                  width = 0.8,
                  colour = "black"
                ) +
                facet_wrap( ~ Variable, scales = "free_x", ncol = 2) +
                scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
                labs(title = "Distribution comparison (Development vs Test): Categorical predictors", x = NULL, y = "Proportion") +
                apa_theme +
                theme(axis.text.x = element_text(angle = 25, hjust = 1),
                      legend.position = "top")
              
              #save figures
              
              fig_numeric
              fig_categorical
              
              # Save in high quality for Word
              ggsave(
                "outputs/Figure_Distributions_Numeric_Dev_vs_Test.png",
                fig_numeric,
                width = 12,
                height = 8,
                dpi = 300
              )
              ggsave(
                "outputs/Figure_Distributions_Categorical_Dev_vs_Test.png",
                fig_categorical,
                width = 12,
                height = 10,
                dpi = 300
              )
              
              #Plots for results
              # Collect TEST predictions
              
              
              rf_test_pred <- final_res %>%
                collect_predictions() %>%
                transmute(Model = "Random Forest", .pred, phq9_total)
              
              xgb_test_pred <- xgb_final_res %>%
                collect_predictions() %>%
                transmute(Model = "XGBoost", .pred, phq9_total)
              
              lm_test_pred <- lm_res %>%
                collect_predictions() %>%
                transmute(Model = "Linear Regression", .pred, phq9_total)
              
              pred_all <- bind_rows(rf_test_pred, xgb_test_pred, lm_test_pred) %>%
                filter(!is.na(.pred), !is.na(phq9_total)) %>%
                mutate(
                  Model = factor(
                    Model,
                    levels = c("Linear Regression", "Random Forest", "XGBoost"),
                    labels = c("Linear\nRegression", "Random\nForest", "XGBoost")
                  ),
                  residual  = phq9_total - .pred,
                  abs_resid = abs(residual)
                )
              
              
              # APA theme
              
              
              apa_theme <- theme_classic(base_size = 11) +
                theme(
                  plot.title       = element_text(size = 11, face = "bold"),
                  axis.title       = element_text(size = 11),
                  axis.text        = element_text(size = 10),
                  strip.background = element_rect(fill = "white", colour = "black"),
                  strip.text       = element_text(size = 10),
                  legend.position  = "none"
                )
              
              fmt_num <- function(x, digits = 2) {
                formatC(x, format = "f", digits = digits)
              }
              
              
              
              ##Calibration plot
              
              PHQ9_MAX <- 27  # not needed anymore, but fine to keep
              
              make_cal_bins <- function(df, n_bins = 10) {
                df %>%
                  mutate(bin = ntile(.pred, n_bins)) %>%
                  group_by(Model, bin) %>%
                  summarise(
                    mean_pred = mean(.pred, na.rm = TRUE),
                    mean_obs  = mean(phq9_total, na.rm = TRUE),
                    .groups = "drop"
                  )
              }
              
              # Calibration curve data
              cal_all <- pred_all %>%
                make_cal_bins(n_bins = 10)
              
              # Fit calibration line per model: mean_obs = intercept + slope * mean_pred
              y_top <- max(cal_all$mean_obs, na.rm = TRUE)
              x_left <- min(cal_all$mean_pred, na.rm = TRUE)
              
              cal_fit <- cal_all %>%
                group_by(Model) %>%
                summarise(intercept = coef(lm(mean_obs ~ mean_pred))[1],
                          slope     = coef(lm(mean_obs ~ mean_pred))[2],
                          .groups = "drop") %>%
                mutate(
                  # SAME position for all facets
                  x_pos = x_left + 0.05 * diff(range(cal_all$mean_pred, na.rm = TRUE)),
                  y_pos = y_top  - 0.05 * diff(range(cal_all$mean_obs, na.rm = TRUE)),
                  label = paste0(
                    "Intercept = ",
                    formatC(intercept, format = "f", digits = 2),
                    "\nSlope = ",
                    formatC(slope, format = "f", digits = 2)
                  )
                )
              
              
              p_cal <- ggplot(cal_all, aes(x = mean_pred, y = mean_obs)) +
                geom_point(size = 1.6) +
                geom_line() +
                geom_abline(slope = 1,
                            intercept = 0,
                            linetype = "dashed") +
                facet_wrap( ~ Model, nrow = 1) +
                # Add slope/intercept label top-right within each facet
                geom_label(
                  data = cal_fit,
                  aes(x = x_pos, y = y_pos, label = label),
                  inherit.aes = FALSE,
                  hjust = 0,
                  vjust = 1,
                  size = 3,
                  label.size = 0,
                  fill = "white"
                ) +
                coord_cartesian(clip = "off") +
                labs(title = "Calibration (test set)", x = "Mean predicted PHQ-9", y = "Mean observed PHQ-9") +
                apa_theme + theme(
                  panel.border = element_blank(),
                  strip.background = element_blank(),
                  strip.text = element_text(face = "plain"),
                  axis.line = element_line(color = "black")
                )
              
              #Plot of Residuals vs predicted
              p_resid <- ggplot(pred_all, aes(x = .pred, y = residual)) +
                geom_hline(yintercept = 0, linetype = "dashed") +
                geom_point(alpha = 0.25, size = 0.9) +
                facet_wrap( ~ Model, nrow = 1) +
                scale_x_continuous(breaks = scales::pretty_breaks(5),
                                   expand = expansion(mult = c(0.07, 0.07))) +
                scale_y_continuous(breaks = scales::pretty_breaks(5),
                                   expand = expansion(mult = c(0.06, 0.06))) +
                labs(title = "Residuals vs predicted (test set)", x = "Predicted PHQ-9 (ŷ)", y = "Residual (y − ŷ)") +
                apa_theme
              
              
              #Plot of the Absolute error distribution (WITH MEDIAN + N)
              box_labs <- pred_all %>%
                group_by(Model) %>%
                summarise(
                  med = median(abs_resid, na.rm = TRUE),
                  q3  = quantile(abs_resid, 0.75, na.rm = TRUE),
                  n   = sum(!is.na(abs_resid)),
                  .groups = "drop"
                ) %>%
                mutate(
                  label = paste0("Median = ", formatC(
                    med, format = "f", digits = 2
                  ), "\nN = ", n),
                  y_pos = q3 + 1.5,
                  x_pos = as.numeric(Model) + 0.35
                )
              
              p_err_box <- ggplot(pred_all, aes(x = Model, y = abs_resid)) +
                geom_boxplot(fill = "grey80", colour = "black") +
                geom_text(
                  data = box_labs,
                  aes(x = x_pos, y = y_pos, label = label),
                  inherit.aes = FALSE,
                  hjust = 0,
                  # left align, so it reads nicely to the right
                  size = 3
                ) +
                coord_cartesian(clip = "off") +  # allow text outside panel if needed
                labs(title = "Absolute error distribution (test set)", x = NULL, y = "Absolute error |y − ŷ|") +
                apa_theme +
                theme(
                  axis.text.x = element_text(angle = 15, hjust = 1),
                  plot.margin = margin(5.5, 25, 5.5, 5.5)  # extra right margin for labels
                )
              
              
              
              #Save as Figures
              
              #Calibration
              print(p_cal)
              ggsave(
                filename = "outputs/FigureB_Calibration_TestSet.png",
                plot     = p_cal,
                width    = 10,
                height   = 4.5,
                dpi      = 300
              )
              
              #Residuals vs predicted
              print(p_resid)
              ggsave(
                filename = "outputs/FigureC_Residuals_TestSet.png",
                plot     = p_resid,
                width    = 10,
                height   = 4.5,
                dpi      = 300
              )
              
              #Absolute error distribution
              print(p_err_box)
              ggsave(
                filename = "outputs/FigureD_AbsError_TestSet.png",
                plot     = p_err_box,
                width    = 10,
                height   = 4.5,
                dpi      = 300
              )
              
              ## Performance metrics table with CI ##
              
              # Build a clean test set (remove missing outcome)
              test_df2 <- nhanes_test %>%
                filter(!is.na(phq9_total))
              
              # Collect predictions (overall test set)
              pred_test <- bind_rows(
                tibble(
                  Model = "Linear Regression",
                  y = test_df2$phq9_total,
                  yhat = predict(lm_fit, new_data = test_df2) %>% dplyr::pull(.pred)
                ),
                tibble(
                  Model = "Random Forest",
                  y = test_df2$phq9_total,
                  yhat = predict(rf_fit, new_data = test_df2) %>% dplyr::pull(.pred)
                ),
                tibble(
                  Model = "XGBoost",
                  y = test_df2$phq9_total,
                  yhat = predict(xgb_fit, new_data = test_df2) %>% dplyr::pull(.pred)
                )
              ) %>%
                filter(!is.na(y), !is.na(yhat))
              
              # Metric functions
              rmse_fn <- function(y, yhat)
                sqrt(mean((y - yhat)^2, na.rm = TRUE))
              mae_fn  <- function(y, yhat)
                mean(abs(y - yhat), na.rm = TRUE)
              rsq_fn  <- function(y, yhat) {
                1 - sum((y - yhat)^2, na.rm = TRUE) / sum((y - mean(y, na.rm = TRUE))^2, na.rm = TRUE)
              }
              
              # Bootstrap CI helper (percentile)
              boot_ci <- function(y,
                                  yhat,
                                  metric_fun,
                                  B = 2000,
                                  conf = 0.95) {
                n <- length(y)
                est <- metric_fun(y, yhat)
                boots <- replicate(B, {
                  idx <- sample.int(n, n, replace = TRUE)
                  metric_fun(y[idx], yhat[idx])
                })
                alpha <- (1 - conf) / 2
                tibble(est = est,
                       lo  = unname(quantile(
                         boots, probs = alpha, na.rm = TRUE
                       )),
                       hi  = unname(quantile(
                         boots, probs = 1 - alpha, na.rm = TRUE
                       )))
              }
              
              # Compute metrics + CIs per model
              set.seed(2025)
              perf_ci_long <- pred_test %>%
                group_by(Model) %>%
                group_modify( ~ {
                  y <- .x$y
                  yhat <- .x$yhat
                  bind_rows(
                    RMSE = boot_ci(y, yhat, rmse_fn, B = 2000),
                    MAE  = boot_ci(y, yhat, mae_fn, B = 2000),
                    R2   = boot_ci(y, yhat, rsq_fn, B = 2000),
                    .id = "Metric"
                  ) %>%
                    mutate(n = length(y))
                }) %>%
                ungroup()
              
              perf_ci_long
              
              # APA text formatting: estimate [lo, hi]
              fmt_ci <- function(est, lo, hi, digits = 3) {
                sprintf(paste0("%.", digits, "f [%.", digits, "f, %.", digits, "f]"),
                        est,
                        lo,
                        hi)
              }
              
              perf_ci_wide <- perf_ci_long %>%
                mutate(Value = fmt_ci(est, lo, hi, digits = 3)) %>%
                select(Model, n, Metric, Value) %>%
                tidyr::pivot_wider(
                  id_cols = c(Metric),
                  names_from = Model,
                  values_from = Value
                )
              
              
              # n row (once) so it’s visible in the table
              n_row <- perf_ci_long %>%
                distinct(Model, n) %>%
                tidyr::pivot_wider(names_from = Model, values_from = n) %>%
                mutate(Metric = "n") %>%
                select(Metric, everything()) %>%
                mutate(across(-Metric, as.character))  # <-- FIX (coerce to character)
              
              perf_ci_table <- bind_rows(n_row, perf_ci_wide)
              
              
              # APA-ish gt table export
              perf_ci_apa <- perf_ci_table %>%
                gt() %>%
                tab_header(
                  title = md("**Table X**"),
                  subtitle = md(
                    "*Test-set performance metrics with 95% bootstrap confidence intervals (B = 2000)*"
                  )
                ) %>%
                cols_label(
                  Metric = "Metric",
                  `Linear Regression` = "Linear Regression",
                  `Random Forest` = "Random Forest",
                  `XGBoost` = "XGBoost"
                ) %>%
                tab_source_note(
                  source_note = paste(
                    "Note. Values are estimate [95% percentile bootstrap CI] for RMSE, MAE, and R².",
                    "n refers to the number of complete test observations used."
                  )
                ) %>%
                tab_options(
                  table.align = "center",
                  table.font.size = 11,
                  table.border.top.color    = "black",
                  table.border.top.width    = px(1),
                  table.border.bottom.color = "black",
                  table.border.bottom.width = px(1),
                  column_labels.border.bottom.color = "black",
                  column_labels.border.bottom.width = px(1),
                  data_row.padding = px(4),
                  heading.align = "left"
                )
              
              gtsave(perf_ci_apa, filename = "outputs/Table_Performance_TEST_withCI_LM_RF_XGB_APA.docx")
              perf_ci_apa
              
              ##Fairness table  ##
              
              
              
              #One canonical TEST df
              test_df3 <- nhanes_test %>%
                mutate(
                  gender_lab = factor(
                    gender,
                    levels = c(1, 2),
                    labels = c("Male", "Female")
                  ),
                  imm_lab    = factor(
                    immigrant_status,
                    levels = c(1, 2),
                    labels = c("Native-born", "Immigrant")
                  ),
                  race_lab   = factor(as.character(race)),
                  # keep as character codes (1,2,3,4,6,7)
                  age_bin    = cut(
                    age,
                    breaks = c(18, 30, 45, 60, 80, Inf),
                    include.lowest = TRUE,
                    right = TRUE,
                    labels = c("18–30", "31–45", "46–60", "61–80", "81+")
                  )
                ) %>%
                filter(!is.na(phq9_total))  # keep one consistent test set
              
              
              #Collect TEST predictions once
              pred_test_all <- bind_rows(
                tibble(
                  Model = "Linear Regression",
                  y = test_df3$phq9_total,
                  yhat = predict(lm_fit, new_data = test_df3) %>% pull(.pred),
                  gender_lab = test_df3$gender_lab,
                  imm_lab    = test_df3$imm_lab,
                  race_lab   = test_df3$race_lab,
                  age_bin    = test_df3$age_bin
                ),
                tibble(
                  Model = "Random Forest",
                  y = test_df3$phq9_total,
                  yhat = predict(rf_fit, new_data = test_df3) %>% pull(.pred),
                  gender_lab = test_df3$gender_lab,
                  imm_lab    = test_df3$imm_lab,
                  race_lab   = test_df3$race_lab,
                  age_bin    = test_df3$age_bin
                ),
                tibble(
                  Model = "XGBoost",
                  y = test_df3$phq9_total,
                  yhat = predict(xgb_fit, new_data = test_df3) %>% pull(.pred),
                  gender_lab = test_df3$gender_lab,
                  imm_lab    = test_df3$imm_lab,
                  race_lab   = test_df3$race_lab,
                  age_bin    = test_df3$age_bin
                )
              ) %>%
                filter(!is.na(y), !is.na(yhat)) %>%
                mutate(abs_err = abs(y - yhat), bias    = yhat - y)
              
              #Helper: compute MAE/Bias per subgroup directly from predictions (no reuse of summaries)
              fair_group <- function(df, group_var, grouping_name) {
                df %>%
                  filter(!is.na(.data[[group_var]])) %>%
                  group_by(Grouping = grouping_name, Group = .data[[group_var]], Model) %>%
                  summarise(
                    n    = n(),
                    MAE  = mean(abs_err, na.rm = TRUE),
                    Bias = mean(bias, na.rm = TRUE),
                    .groups = "drop"
                  )
              }
              
              fair_long <- bind_rows(
                fair_group(pred_test_all, "gender_lab", "Gender"),
                fair_group(pred_test_all, "imm_lab", "Immigration status"),
                fair_group(pred_test_all, "race_lab", "Race/ethnicity"),
                fair_group(pred_test_all, "age_bin", "Age (bins)")
              )
              
              #Compact cell text + models as columns
              fair_compact_wide <- fair_long %>%
                mutate(Model = factor(Model, levels = c(
                  "Linear Regression", "Random Forest", "XGBoost"
                )),
                cell  = sprintf("%.2f (%.2f)", round(MAE, 2), round(Bias, 2))) %>%
                select(Grouping, Group, Model, n, cell) %>%
                pivot_wider(
                  id_cols = c(Grouping, Group),
                  names_from = Model,
                  values_from = cell
                ) %>%
                # n is identical per group across models (but keep it explicit)
                left_join(
                  fair_long %>%
                    group_by(Grouping, Group) %>%
                    summarise(n = max(n), .groups = "drop"),
                  by = c("Grouping", "Group")
                ) %>%
                relocate(n, .after = Group)
              
              #Enforce correct ordering (Gender, Immigration, Race codes 1,2,3,4,6,7, Age bins)
              grouping_order <- c("Gender", "Immigration status", "Race/ethnicity", "Age (bins)")
              race_order     <- c("1", "2", "3", "4", "6", "7")  # NHANES RIDRETH3 codes present in your data
              
              fair_compact_wide <- fair_compact_wide %>%
                mutate(
                  Grouping = factor(Grouping, levels = grouping_order),
                  Group_chr = as.character(Group),
                  row_order = case_when(
                    Grouping == "Gender" ~ match(Group_chr, c("Male", "Female")),
                    Grouping == "Immigration status" ~ match(Group_chr, c("Native-born", "Immigrant")),
                    Grouping == "Race/ethnicity" ~ match(Group_chr, race_order),
                    Grouping == "Age (bins)" ~ match(Group_chr, c("18–30", "31–45", "46–60", "61–80", "81+")),
                    TRUE ~ 999L
                  ),
                  Group = str_wrap(Group_chr, width = 18)
                ) %>%
                arrange(Grouping, row_order) %>%
                select(-Group_chr, -row_order)
              
              #APA-ish gt table
              fair_test_tbl_apa <- fair_compact_wide %>%
                gt(rowname_col = "Group", groupname_col = "Grouping") %>%
                tab_header(
                  title = md("**Table X**"),
                  subtitle = md("*Test-set fairness summary by subgroup. Cells show MAE (Bias).*")
                ) %>%
                cols_label(
                  n = "n",
                  `Linear Regression` = "Linear Regression: MAE (Bias)",
                  `Random Forest`     = "Random Forest: MAE (Bias)",
                  `XGBoost`           = "XGBoost: MAE (Bias)"
                ) %>%
                tab_source_note(
                  source_note = paste(
                    "Note. MAE = mean absolute error. Bias = mean(predicted − observed PHQ-9).",
                    "Positive Bias indicates overprediction; negative Bias indicates underprediction."
                  )
                ) %>%
                tab_options(
                  table.align = "center",
                  table.font.size = 11,
                  data_row.padding = px(5),
                  table.border.top.color    = "black",
                  table.border.top.width    = px(1),
                  table.border.bottom.color = "black",
                  table.border.bottom.width = px(1),
                  column_labels.border.bottom.color = "black",
                  column_labels.border.bottom.width = px(1),
                  heading.align = "left"
                )
              
              gtsave(fair_test_tbl_apa, filename = "outputs/Table_Fairness_TEST_Compact_MAE_Bias_APA.docx")
              fair_test_tbl_apa
              
              ##Density plot ##
              nhanes_cleaned %>%
                filter(!is.na(phq9_total), !is.na(immigrant_status)) %>%
                mutate(immigrant_status = factor(
                  immigrant_status,
                  levels = c(1, 2),
                  labels = c("Native-born", "Immigrant")
                )) %>%
                ggplot(aes(x = phq9_total, linetype = immigrant_status)) +
                geom_density(linewidth = 0.9, na.rm = TRUE) +
                scale_x_continuous(breaks = seq(0, 27, by = 3), limits = c(0, 27)) +
                labs(x = "PHQ-9 total score", y = "Density", linetype = "Immigration status") +
                theme_classic(base_size = 12) +
                theme(
                  plot.title = element_blank(),
                  # APA: no title in figure
                  legend.position = "top",
                  legend.title = element_text(size = 11),
                  legend.text  = element_text(size = 11),
                  axis.title   = element_text(size = 12),
                  axis.text    = element_text(size = 11)
                )
              
              ggsave(
                filename = "outputs/Figure_PHQ9_Density_Immigration_APA.png",
                plot     = last_plot(),
                width    = 6.5,
                # APA-recommended figure width (inches)
                height   = 4.5,
                # balanced height for density plots
                dpi      = 300,
                bg       = "white"
              )
              
              
#### Session info ####
              sessionInfo()
              