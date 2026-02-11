# Master-Thesis-Influence-of-immigration-status-on-depression-score-A-machine-learning-approach
Code used to write the master's thesis: Influence of immigration status on depression score: A machine learning approach

## How to run

1. Open the R project in RStudio
2. Run `00_install_packages.R` (once)
3. Run `01_main_analysis.R`

## Data

NHANES 2021 public-use files are automatically downloaded.
Raw data are not stored in this repository.

## Outputs

Figures and tables are saved to the `/outputs` folder.

## Sessioninfo:
R version 4.5.2 (2025-10-31)
Platform: x86_64-pc-linux-gnu
Running under: Ubuntu 22.04.3 LTS

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.20.so;  LAPACK version 3.10.0

locale:
 [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
 [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C               LC_TELEPHONE=C             LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

time zone: Europe/Amsterdam
tzcode source: system (glibc)

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] haven_2.5.5        pmsampsize_1.1.3   corrplot_0.95      ggrepel_0.9.6      fairmodels_1.2.2   patchwork_1.3.2    DALEX_2.5.3        smd_0.8.0          effectsize_1.0.1  
[10] VIM_7.0.0          colorspace_2.1-0   gt_1.3.0           gtsummary_2.5.0    janitor_2.2.1      vip_0.4.5          ranger_0.17.0      visdat_0.6.0       srvyr_1.3.1       
[19] survey_4.4-8       survival_3.8-3     Matrix_1.7-4       naniar_1.1.0       yardstick_1.3.2    workflowsets_1.1.1 workflows_1.3.0    tune_2.0.0         tailor_0.1.0      
[28] rsample_1.3.1      recipes_1.3.1      parsnip_1.3.3      modeldata_1.5.1    infer_1.0.9        dials_1.4.2        scales_1.4.0       broom_1.0.12       tidymodels_1.4.1  
[37] lubridate_1.9.3    forcats_1.0.1      stringr_1.6.0      dplyr_1.1.4        purrr_1.1.0        readr_2.1.5        tidyr_1.3.2        tibble_3.3.1       ggplot2_4.0.2     
[46] tidyverse_2.0.0   

loaded via a namespace (and not attached):
 [1] RColorBrewer_1.1-3   vcd_1.4-13           rstudioapi_0.17.1    jsonlite_1.8.8       datawizard_1.3.0     magrittr_2.0.3       farver_2.1.1         fs_1.6.6            
 [9] vctrs_0.7.1          htmltools_0.5.8.1    xgboost_1.7.6.1      Formula_1.2-5        parallelly_1.46.0    mlr3_1.3.0           palmerpenguins_0.1.1 mlr3tuning_1.5.1    
[17] zoo_1.8-14           uuid_1.2-0           lifecycle_1.0.5      iterators_1.0.14     pkgconfig_2.0.3      R6_2.5.1             fastmap_1.1.1        future_1.68.0       
[25] snakecase_0.11.1     digest_0.6.34        furrr_0.3.1          mlr3misc_0.19.0      ingredients_2.3.0    fansi_1.0.6          timechange_0.3.0     abind_1.4-8         
[33] compiler_4.5.2       proxy_0.4-27         withr_3.0.0          S7_0.2.0             backports_1.5.0      carData_3.0-5        DBI_1.2.1            MASS_7.3-65         
[41] lava_1.7.3           tools_4.5.2          lmtest_0.9-40        future.apply_1.11.1  nnet_7.3-20          glue_1.8.0           lgr_0.5.0            checkmate_2.3.3     
[49] generics_0.1.3       gtable_0.3.6         tzdb_0.4.0           class_7.3-23         data.table_1.15.0    hms_1.1.3            sp_1.6-0             xml2_1.3.6          
[57] car_3.1-3            utf8_1.2.4           foreach_1.5.2        pillar_1.9.0         mitools_2.4          robustbase_0.99-6    bbotk_1.8.1          splines_4.5.2       
[65] lhs_1.1.5            lattice_0.22-5       tidyselect_1.2.1     hardhat_1.4.2        timeDate_4032.109    DEoptimR_1.1-4       stringi_1.8.3        DiceDesign_1.10     
[73] boot_1.3-32          codetools_0.2-19     laeken_0.5.3         cli_3.6.5            rpart_4.1.24         parameters_0.28.3    mlr3learners_0.14.0  Rcpp_1.0.12         
[81] globals_0.18.0       parallel_4.5.2       gower_1.0.0          bayestestR_0.17.0    GPfit_1.0-8          paradox_1.0.1        listenv_0.9.1        mlr3pipelines_0.10.0
[89] ipred_0.9-14         prodlim_2023.08.28   e1071_1.7-16         insight_1.4.4        crayon_1.5.2         rlang_1.1.7          cards_0.7.1         
> 
