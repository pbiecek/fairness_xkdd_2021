##########################################
# Based on Jakub Wiśniewski example of fairmodels
# https://github.com/MI2DataLab/ResponsibleML-UseR2021
#
# get all these materials from 
# https://tinyurl.com/xkdd-fairness

################# imports #################
library(magrittr)
library(ggplot2)
library(DALEX)
library(fairmodels)
library(gbm)
library(ranger)

################# data #################
get_compas_data <- function() {
compas2 <- read.csv('https://raw.githubusercontent.com/propublica/compas-analysis/master/compas-scores-two-years.csv')

df <- compas2[,c('age', 'c_charge_degree', 'race', 'age_cat',
'score_text', 'sex', 'priors_count', 'juv_misd_count',
'v_decile_score', 'days_b_screening_arrest',
'decile_score', 'two_year_recid', 'c_jail_in', 'c_jail_out')]

df <- df[df$days_b_screening_arrest <= 30, ]
df <- df[df$days_b_screening_arrest >= -30, ]
df <- df[df$c_charge_degree != "O", ]
df <- df[df$score_text != 'N/A', ]
df$jail_time = as.numeric(difftime(df$c_jail_out,
                 df$c_jail_in, units = c('days')))
df <- na.omit(df)
df <- df[ -c(4:5, 13:14)]

# Here we change the order of the recidivism, so that the model
# predicts positive outcome
df$two_year_recid <- ifelse(df$two_year_recid == 1, 0, 1)

df$race <- factor(df$race, levels = c("Caucasian", "African-American", "Asian", "Hispanic", "Native American", 
                    "Other"),
labels = c("_Caucasian", "African-American", "Asian", "Hispanic", "Native American", 
           "Other"))
df
}
df <- get_compas_data()
head(df)

################# Fairness Check #################

# Classification task - will defendants become recidivist?
lr_model <- glm(two_year_recid ~., data = df,
              family = binomial())

lr_explainer <- DALEX::explain(lr_model, data = df, 
               y = df$two_year_recid)

# let's do fairness check and quickly check if the model is fair
(fobject <- fairness_check(lr_explainer,
              protected = df$race,
              privileged = '_Caucasian'))
plot(metric_scores(fobject))
plot(fobject)

################# More Models #################
rf_model <- ranger::ranger(as.factor(two_year_recid) ~.,
             data=df,
             probability = TRUE,
             num.trees = 100,
             max.depth = 7,
             seed = 123)

rf_explainer <- DALEX::explain(rf_model, data = df, 
             y = df$two_year_recid)

# we have a few options to compare the models
fobject2 <- fairness_check(rf_explainer, lr_explainer,
             protected = df$race,
             privileged = "_Caucasian")

plot(fobject2)
fobject2 %>% metric_scores() %>% plot()

################# Mitigation methods #################
##### Pre processing

# Let's construct a model previously used.

fobject <- fairness_check(rf_explainer,
      protected = df$race,
      privileged = '_Caucasian')

# resampling
indices <- resample(protected = df$race, df$two_year_recid)
df_resampled <- df[indices,]

rf_model_resampled <- ranger::ranger(as.factor(two_year_recid) ~.,
       data=df_resampled,
       num.trees = 100,
       max.depth = 7,
       seed = 123,
       probability = TRUE)

rf_explainer_resampled <- DALEX::explain(rf_model_resampled,
           data = df,
           y = df$two_year_recid,
           label = 'resampled')

fobject <- fairness_check(fobject, rf_explainer_resampled)
plot(fobject)


# reweight
weights <- reweight(protected = as.factor(df$race), y=df$two_year_recid)

rf_model_reweighted <- ranger::ranger(as.factor(two_year_recid) ~.,
                 data=df,
                 num.trees = 100,
                 max.depth = 7,
                 seed = 123,
                 case.weights = weights,
                 probability  = TRUE)

rf_explainer_reweighted <- DALEX::explain(rf_model_reweighted,
                 data = df,
                 y = df$two_year_recid,
                 label = 'reweighted')

fobject <- fairness_check(fobject, rf_explainer_reweighted)
plot(fobject)

# interactive exploration
library(arenar)
compas_ar <- create_arena(live = TRUE) %>%
      push_model(lr_explainer)  %>%
      push_model(rf_explainer) 

run_server(compas_ar)

