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

## Description of code

# Package and data download
1. Loads the required packages and data needed for analysis.
2. Contains reproducibility seed.
3. Merges based on respondent number.

#Data preparation
1. Create a clean dataset for easy fallback, while removing variables not used in analysis and filtering out anyone under 18.
2. Recodes variables so all have additional codes recoded toward missing values for imputations.
3. Log transformation on income.
4. MCAR test to view missingness and kNN to impute all missing values.
5. Merge values back intthe o dataset and create a total PHQ-9 score.
6. Create a correlation matrix.
7. Sample size calculation.

#Models
1. Create bin values for PHQ-9 scores, as it is heavily negatively skewed.
2. Split the data into training/testing 80/20 proportion and create 10V stratified folds using the bins.
3. Create RF model.
4. Create XGBoost model.
5. Create an LR model. 

#Explainable AI results
1. Create an additional database for analysis and prep data for analysis.
2. Create explainer containers.
3. VIP test.

#Plots and tables to view data results
1. Demographic table.
2. Distribution comparison.
3. Categorical predictors distribution.
4. Calibration plot.
5. Residuals vs Predicted plot.
6. Absolute error distribution plot.
7. Performance Table.
8. Fairness Table.
9. Desity plot. 

## Sessioninfo:
R version 4.5.2 (2025-10-31)

## Packages used with version number:
haven_2.5.5        
pmsampsize_1.1.3   
corrplot_0.95      
ggrepel_0.9.6      
fairmodels_1.2.2   
patchwork_1.3.2    
DALEX_2.5.3        
smd_0.8.0          
effectsize_1.0.1  
VIM_7.0.0          
colorspace_2.1-0   
gt_1.3.0           
gtsummary_2.5.0    
janitor_2.2.1      
vip_0.4.5          
ranger_0.17.0      
visdat_0.6.0       
srvyr_1.3.1       
survey_4.4-8       
survival_3.8-3     
Matrix_1.7-4      
naniar_1.1.0      
yardstick_1.3.2    
workflowsets_1.1.1 
workflows_1.3.0    
tune_2.0.0         
tailor_0.1.0      
rsample_1.3.1      
recipes_1.3.1     
parsnip_1.3.3     
modeldata_1.5.1    
infer_1.0.9        
dials_1.4.2       
scales_1.4.0      
broom_1.0.12       
tidymodels_1.4.1  
lubridate_1.9.3   
forcats_1.0.1      
stringr_1.6.0      
dplyr_1.1.4        
purrr_1.1.0       
readr_2.1.5        
tidyr_1.3.2       
tibble_3.3.1     
ggplot2_4.0.2     
tidyverse_2.0.0   

> 
