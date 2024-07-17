library(tidyverse)
library(lme4)
library(lmerTest)
library(jsonlite)
library(rwebppl)
library(emmeans)
library(ggplot2)
library(grid)
# install.packages("xtable")
library(xtable)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("helpers.R")
theme_set(theme_bw())
# color-blind-friendly palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#000000", "#999999") 

#################
# data cleaning #
#################

contrasts(d$negation)
# 고민
# no negation = reference level
# negation = test level
# reference level = lower value of Y
# 1. low/high X
# 
# 2. *** 
# no negation = reference level
# negation = test level
# -> regression models...
# relevel negation...
# discrepancy...
# 1) rerun all the models
# 2) create new column 
# 3) don't relevel
  
# load the main data
# TODO : do exclusion of `non-native speakers of english` and `did not pay attention` in this script
# did not pay attention = responded in the wrong half more than 2 times in value quesetions (main stim) or state questions (control stim)

d = read_csv("../../../data/01_entityType_valueScale/negated_adjectives-merged-english-attention.csv") # 4196
# d = read_csv("../../../data/01_entityType_valueScale/negated_adjectives-merged.csv") # 4371
d$subject_information.asses # No Confused # TODO: try excluding these
d$subject_information.language # not inlcude English # TODO: exclude in R code instead of manually
# TODO: do it later after changing d$value and etc.
# View(d[((d$stimulusType=="main_stimulus" & d$value=="default" & d$responseValue<=0.5) | (d$stimulusType=="main_stimulus" & d$value=="reverse" & d$responseValue>=0.5)),]) # TODO: exclude participants who did this more than 2 times (???)

nrow(d)
# View(d)
summary(d$time_in_minutes)


# rescale Y for readability of coefficients TODO: is this ok? 
d = d%>%
  mutate(responseState100 = responseState * 100)
summary(d$responseState100)

# rename thing -> nonhuman
d$targetType <- ifelse(d$targetType == "thing", "nonhuman", d$targetType)

# rename flipped -> reverse ; normal -> default
d$value <- ifelse(d$value == "flipped", "reverse", 
                  ifelse(d$value == "normal", "default", d$value))

# exclude practice items
d = d %>% 
  filter(!stimulusType %in% c("example1","example2")) %>% 
  droplevels()
nrow(d)

# exclude continue without response
d = d %>% 
  filter(!(responseState==0.5 & responseValue==0.5 & responseHonest==0.5 & responsePositive==0.5)) %>% 
  droplevels()
nrow(d)

# exclude Firefox
# TODO: check if results vary with vs. without Firefox!!!
# TODO: to exclude or not to?
  # exlore firefox
d_firefox = d %>%
  filter(system.Browser=="Firefox") %>%
  droplevels()
length(unique(d_firefox$workerid)) # 41 participants
  # exclude firefox
# d = d %>%
#   filter(!(system.Browser=="Firefox")) %>%
#   droplevels()
nrow(d)


# remove empty columns
d = d %>% 
  select(-proliferate.condition, -catch_trials, -error)
  
# create weighted intentions
d = d %>%
  mutate(weightedResponseHonest = ifelse(responseHonest + responsePositive > 0, responseHonest / (responseHonest + responsePositive), 0)) %>%
  mutate(weightedResponsePositive = ifelse(responseHonest + responsePositive > 0, responsePositive / (responseHonest + responsePositive), 0))

# adjust responseValue to -0.5 ~ 0.5
# adjst responseValue to -1 ~ 1 (for norming responseState)
# Q. which way to go?
d = d %>% 
  mutate(adjustedResponseValue = (responseValue - 0.5)*2)

# change independent variables into factors
d$negation = as.factor(as.character(d$negation))
d$polarity = as.factor(as.character(d$polarity))
d$targetType = as.factor(as.character(d$targetType))
d$value = as.factor(as.character(d$value))
d$state = as.factor(as.character(d$state))

# TODO : adjective vs. adjectivePair?
d$workerid = as.factor(as.character(d$workerid))
d$adjective = as.factor(as.character(d$adjective))
d$adjectivePair = as.factor(as.character(d$adjectivePair))

# change baselines
d$polarity <- factor(d$polarity, levels = c("positive", "negative"))
d$targetType <- factor(d$targetType, levels = c("nonhuman", "human"))
d$value <- factor(d$value, levels = c("default", "reverse"))
d$negation <- factor(d$negation, levels = c("0", "1"))
d$state <- factor(d$state, levels = c("positive", "negative"))

# data including control items
d_with_control <- d
nrow(d_with_control)
  # control stims have lots of instances of these "weird" combinations
nrow(d_with_control[d_with_control$value=="default" & d_with_control$responseValue<=0.5,])
nrow(d_with_control[d_with_control$value=="reverse" & d_with_control$responseValue>=0.5,])

# data excluding control items
# TODO : control responses need to be used for calibration of intention scales. but how?
d = d %>% 
  filter(!stimulusType == "control") %>% 
  droplevels() %>%
  select(-listenerGender, -listenerName, -state)

# exclude value==default & responseValue <= 0.5 ; value==reverse & responseValue >= 0.5
# TODO: I already (manually) removed who did this more than 2 times. do it again???
nrow(d[d$value=="default" & d$responseValue<=0.5,])
nrow(d[d$value=="reverse" & d$responseValue>=0.5,])
# View(d[((d$value=="default" & d$responseValue<=0.5) | (d$value=="reverse" & d$responseValue>=0.5)),])
nrow(d)
# d = d %>%
#   filter(!(value=="default" & responseValue<=0.5)) %>%
#   filter(!(value=="reverse" & responseValue>=0.5)) %>%
#   droplevels()
nrow(d)

# norm responseState by responseValue
d = d %>%
  mutate(normedResponseState = case_when(
    value == "default" ~ responseState/adjustedResponseValue,      # Calculation for "forward" values
    value == "reverse" ~ -responseState/adjustedResponseValue,      # Calculation for "reverse" values
    TRUE ~ NA_real_                       # Default for other cases (if any)
  ))

# View(d[, c("value", "desired", "sentence", "responseState", "responseValue", "adjustedResponseValue", "normedResponseState")])
nrow(d)
length(unique(d$workerid)) # 231 after exclusion
# View(d)

############
# Analysis #
############

# TODO: what is this section about?

# correlation between intention and state

d_default = d %>%
  filter(value=="default") %>%
  droplevels()

# effect of relative positivity on ANY state rating
# cor.test(d_default$weightedResponsePositive, d_default$responseState, method=c("pearson", "kendall", "spearman"))
# RESULT: NOT significant

# effect of relative positivity on state rating for POLARITY X NEGATION
# RESULT: positivity & state rating are positively related for affirmative
# while they are negatively related for negated
# TODO: how to interpret the POSITIVE correlation??

d_default_positive = d %>%
  filter(value=="default" & negation=="0" & polarity=="positive") %>%
  droplevels()
cor.test(d_default_positive$weightedResponsePositive, d_default_positive$responseState, method=c("pearson", "kendall", "spearman"))
# RESULT: "good" NEGATIVE effect (as expected): -0.164

d_default_negated_positive = d %>%
  filter(value=="default" & negation=="1" & polarity=="positive") %>%
  droplevels()
cor.test(d_default_negated_positive$weightedResponsePositive, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# RESULT: "not good" POSITIVE effect (NOT expected): 0.255

d_default_negative = d %>%
  filter(value=="default" & negation=="0" & polarity=="negative") %>%
  droplevels()
cor.test(d_default_negative$weightedResponsePositive, d_default_negative$responseState, method=c("pearson", "kendall", "spearman"))
# RESULT: "bad" NEGATIVE effect (as expected): -0.202

d_default_negated_negative = d %>%
  filter(value=="default" & negation=="1" & polarity=="negative") %>%
  droplevels()
cor.test(d_default_negated_negative$weightedResponsePositive, d_default_negated_negative$responseState, method=c("pearson", "kendall", "spearman"))
# RESULT: "not bad" POSITIVE effect (NOT expected): 0.016

# effect of relative positivity
plot(d_default_negated_positive$weightedResponsePositive, d_default_negated_positive$responseState)
# effect of relative honesty
plot(d_default_negated_positive$weightedResponseHonest, d_default_negated_positive$responseState)
# effect of raw positivity
plot(d_default_negated_positive$responsePositive, d_default_negated_positive$responseState)
# effect of raw weight of honesty
plot(d_default_negated_positive$responseHonest, d_default_negated_positive$responseState)

# relative positivity has weak POSITIVE (NOT expected) effect: 0.255
cor.test(d_default_negated_positive$weightedResponsePositive, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# relative honesty (redundant)
# cor.test(d_default_negated_positive$weightedResponseHonest, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# raw positivity is insignificant
# cor.test(d_default_negated_positive$responsePositive, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# raw honesty has weak NEGATIVE effect
cor.test(d_default_negated_positive$responseHonest, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))


# only positive in default context
d_default_positive = d %>%
  filter(value=="default" & polarity=="positive") %>%
  droplevels()

# effect of negation on relative positivity
plot(d_default_positive$negation, d_default_positive$weightedResponsePositive)
# effect of negation on relative honesty
plot(d_default_positive$negation, d_default_positive$weightedResponseHonest)
# effect of negation on raw positivity
plot(d_default_positive$negation, d_default_positive$responsePositive)
# effect of negation on raw honesty
plot(d_default_positive$negation, d_default_positive$responseHonest)
# RESULT: negation reduces (relative) positivity & increases relative honesty


# only default context
d_default = d %>%
  filter(value=="default") %>%
  droplevels()

# TODO: 

# relative positivity has weak POSITIVE effect
cor.test(d_default_negated_positive$weightedResponsePositive, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# relative honesty (redundant)
# cor.test(d_default_negated_positive$weightedResponseHonest, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# raw positivity is insignificant
# cor.test(d_default_negated_positive$responsePositive, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# raw honesty has weak NEGATIVE effect
cor.test(d_default_negated_positive$responseHonest, d_default_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))

# TODO: tidy up correlation exploration ^ (remove duplicates)


#################
# BOOTSTRAPPING #
#################

view(d)
nrow(d[d$polarity=="positive" & d$negation==0 & d$value=="default",])
nrow(d[d$polarity=="positive" & d$negation==1 & d$value=="default",])
nrow(d[d$polarity=="negative" & d$negation==0 & d$value=="default",])
nrow(d[d$polarity=="negative" & d$negation==1 & d$value=="default",])
nrow(d[d$polarity=="positive" & d$negation==0 & d$value=="reverse",])
nrow(d[d$polarity=="positive" & d$negation==1 & d$value=="reverse",])
nrow(d[d$polarity=="negative" & d$negation==0 & d$value=="reverse",])
nrow(d[d$polarity=="negative" & d$negation==1 & d$value=="reverse",])
# smallest number of datapoints = 222

R <- 50

nrow(d)
# view(d)
### Second
bootstrap_results <- data.frame(
  diff = c(),
  polarity = c(),
  value = c(),
  targetType = c(),
  adjectivePair = c()
)

sample_size_df <- d %>%
  group_by(value, targetType, adjectivePair, polarity, negation) %>%
  count()
# view(sample_size_df)
sample_size <- min(sample_size_df$n)
sample_size


for (val in c("default", "reverse")) {
  for (target in c("human", "nonhuman")) {
    for (pair in c("big-small", "fast-slow", "good-bad", "long-short")) {
      d_f <- d %>%
        filter((adjectivePair==pair) & (value==val) & (targetType==target)) %>%
        droplevels()
      positive <- d_f[d_f$polarity=="positive" & d_f$negation==0,]$responseState # good
      not_positive <- d_f[d_f$polarity=="positive" & d_f$negation==1,]$responseState # not good
      negative <- d_f[d_f$polarity=="negative" & d_f$negation==0,]$responseState # bad
      not_negative <- d_f[d_f$polarity=="negative" & d_f$negation==1,]$responseState # not bad
      for (i in 1:R) {
        sample_mean_positive <- mean(sample(positive, size=sample_size, replace=TRUE))
        sample_mean_not_positive <- mean(sample(not_positive, size=sample_size, replace=TRUE))
        new_record <- list(
          diff = sample_mean_positive - sample_mean_not_positive,
          polarity = "positive",
          value = val,
          targetType = target,
          adjectivePair = pair
        )
        bootstrap_results <- rbind(bootstrap_results, new_record)
        sample_mean_negative <- mean(sample(negative, size=sample_size, replace=TRUE))
        sample_mean_not_negative <- mean(sample(not_negative, size=sample_size, replace=TRUE))
        new_record <- list(
          diff = sample_mean_negative - sample_mean_not_negative,
          polarity = "negative",
          value = val,
          targetType = target,
          adjectivePair = pair
        )
    
        bootstrap_results <- rbind(bootstrap_results, new_record)
      }
    }
  }
}

# plot
# basic NS DIFFERENCE with CI (for CAMP)
ns_diff = bootstrap_results %>%
  filter(value=="default") %>%
  droplevels() %>%
  group_by(polarity) %>% 
  summarise(mean = mean(diff),
            CILow = ci.low(diff),
            CIHigh = ci.high(diff)) %>%
  ungroup() %>%
  mutate_if(is.character, as.factor) %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh,
         polarity = fct_relevel(polarity, "positive", "negative"))
ggplot(ns_diff, aes(x=polarity, y=mean, fill=polarity))+
  geom_bar(stat="identity", position=dodge) +
  geom_text(aes(label=c("slow - not slow", "fast - not fast")), vjust=-1, size=3) + # WHY WRONG ORDER???
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[2], cbPalette[6]), name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8), limits = c(0,0.8)) + 
  theme(legend.position = "none")
ggsave(file="../graphs/ns-diff-CI.png",width=2.5,height=3.2)

# NS DIFFERENCE by VALUE with CI (for CAMP)
ns_value_diff = bootstrap_results %>%
  # filter(value=="default") %>%
  # droplevels() %>%
  group_by(polarity, value) %>% 
  summarise(mean = mean(diff),
            CILow = ci.low(diff),
            CIHigh = ci.high(diff)) %>%
  ungroup() %>%
  mutate_if(is.character, as.factor) %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh,
         polarity = fct_relevel(polarity, "positive", "negative"))

ggplot(ns_value_diff, aes(x=polarity, y=mean, fill=value)) +
  geom_bar(stat="identity", position=dodge) +
  # geom_text(aes(label=c("", "slow - not slow", "fast - not fast", "")), vjust=-1, size=3) + # WHY WRONG ORDER???
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[1], cbPalette[5]), name="Value scale") +
  # labs(caption = "(Value context = default)") +
  xlab("Adjectival polarity") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8), limits = c(0,0.8)) +
  theme(axis.text = element_text(size=30),
        axis.title = element_text(size=32),
        legend.text = element_text(size=22),
        legend.title = element_text(size=24),
        legend.key.size = unit(15, "mm"),
        legend.box.background = element_rect(color = "black"),
        # legend.box.margin = margin(t=1, l=1),
        legend.position = c(0.85, 0.85))
ggsave(file="../graphs/ns-value-diff-CI.png",width=4,height=3.2)
ggsave(file="../graphs/ns-value-diff-CI-forCogSciPoster.png",width=8.6,height=9.6)

# NS DIFFERENCE by HUMANNESS with CI (for CAMP)
boot_agr_ns_targetType_diff <- bootstrap_results %>% 
  filter((value=="default")) %>% 
  droplevels() %>%
  group_by(polarity, targetType) %>% # polarity, 
  summarise(mean = mean(diff),
            CILow = ci.low(diff),
            CIHigh = ci.high(diff)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh,
         polarity = fct_relevel(polarity, "positive", "negative"),
         targetType = fct_relevel(targetType, "nonhuman", "human"),
         targetType = fct_recode(targetType, "non-human" = "nonhuman"))
ggplot(boot_agr_ns_targetType_diff, aes(x=polarity, y=mean, fill=targetType)) + 
  geom_bar(stat="identity", position=dodge) +
  geom_text(aes(label=c("","slow - not slow", "fast - not fast", "")), vjust=-1, size=3) + # ORDER IS WRONG
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[9], cbPalette[7]), name="Assessed entity") + # c("pink2", "skyblue2")
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") + 
  labs(caption = "(Value scale = default)") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8), limits=c(0, 0.8)) 
ggsave(file="../graphs/ns-human-diff-CI.png",width=4.3,height=3.4)

# adjectival variation DIFFERENCE with CI (for CAMP) 
boot_agr_adj_diff <- bootstrap_results %>% 
  filter((value=="default")) %>% 
  droplevels() %>%
  group_by(adjectivePair, polarity) %>% # polarity, 
  summarise(mean = mean(diff),
            CILow = ci.low(diff),
            CIHigh = ci.high(diff)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh,
         polarity = fct_relevel(polarity, "positive", "negative"),
         adjectivePair = fct_recode(adjectivePair, "good/bad" = "good-bad", "fast/slow" = "fast-slow", "big/small" = "big-small", "long/short" = "long-short"))
ggplot(boot_agr_adj_diff, aes(x=adjectivePair, y=mean, fill=polarity))+ 
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[2], cbPalette[6]), name="Polarity") + # c("pink2", "skyblue2")
  xlab("Adjective") +
  ylab("Negative strengthening") +
  labs(caption = "(Value scale = default)") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8), limits=c(0,0.8))
ggsave(file="../graphs/ns-adj-diff-CI.png",width=4.7,height=3.2)


# adjectival variation DIFFERENCE by VALUE with CI (for CogSci)
boot_agr_adj_value_diff <- bootstrap_results %>% 
  # filter((value=="default")) %>% 
  # droplevels() %>%
  group_by(adjectivePair, polarity, value) %>% # polarity, 
  summarise(mean = mean(diff),
            CILow = ci.low(diff),
            CIHigh = ci.high(diff)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh,
         polarity = fct_relevel(polarity, "positive", "negative"),
         adjectivePair = fct_recode(adjectivePair, "good/bad" = "good-bad", "fast/slow" = "fast-slow", "big/small" = "big-small", "long/short" = "long-short"))
ggplot(boot_agr_adj_value_diff, aes(x=adjectivePair, y=mean, fill=polarity))+ 
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[2], cbPalette[6]), name="Polarity") + # c("pink2", "skyblue2")
  xlab("Adjective") +
  ylab("Negative strengthening") +
  # labs(caption = "(Value scale = default)") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8), limits=c(0,0.8)) +
  # theme(legend.position = "bottom", legend.margin=margin(t = 0, unit='cm')) +
  facet_grid(value~.)
ggsave(file="../graphs/ns-adj-value-diff-CI.png",width=4.5,height=4)



# difference by value X humanness (for CogSci) 
boot_agr_ns_value_targetType_diff <- bootstrap_results %>% 
  # filter((value=="default")) %>% 
  # droplevels() %>%
  group_by(polarity, value, targetType) %>% 
  summarise(mean = mean(diff),
            CILow = ci.low(diff),
            CIHigh = ci.high(diff)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh,
         polarity = fct_relevel(polarity, "positive", "negative"),
         targetType = fct_relevel(targetType, "nonhuman", "human"),
         targetType = fct_recode(targetType, "non-human" = "nonhuman"))
ggplot(boot_agr_ns_value_targetType_diff, aes(x=polarity, y=mean, fill=targetType)) + 
  geom_bar(stat="identity", position=dodge) +
  # geom_text(aes(label=c("","slow - not slow", "fast - not fast", "")), vjust=-1, size=3) + # ORDER IS WRONG
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[9], cbPalette[7]), name="Assessed entity") + # 1 4 3
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") + 
  # labs(caption = "(Value scale = default)") +
  facet_wrap(~value) +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8), limits=c(0, 0.8)) 
ggsave(file="../graphs/ns-value-human-diff-CI.png",width=4.3,height=3.4)

# adjectival variation DIFFERENCE with CI, REVERSE too (for CogSci) 
boot_agr_adj_fulll_diff <- bootstrap_results %>% 
  # filter((value=="default")) %>% 
  # droplevels() %>%
  group_by(adjectivePair, polarity, value, targetType) %>% # polarity, 
  summarise(mean = mean(diff),
            CILow = ci.low(diff),
            CIHigh = ci.high(diff)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh,
         polarity = fct_relevel(polarity, "positive", "negative"),
         adjectivePair = fct_recode(adjectivePair, "good/bad" = "good-bad", "fast/slow" = "fast-slow", "big/small" = "big-small", "long/short" = "long-short"))
ggplot(boot_agr_adj_fulll_diff, aes(x=adjectivePair, y=mean, fill=polarity))+ 
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Polarity") + # c("pink2", "skyblue2")
  xlab("Adjective") +
  ylab("Negative strengthening") +
  labs(caption = "(Value scale = default)") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8), limits=c(0, 0.8)) + 
  facet_grid(targetType~value) 
ggsave(file="../graphs/ns-adj-diff-full-CI.png",width=7, height=4)



#########
# PLOTS #
#########

dodge = position_dodge(.9)

##### NEGATIVE STRENGTHENING BY CONDITIONS #####

# basic NS (!!!)
# NOTE: REVERSE value scale is filtered out
agr_ns = d %>%
  filter(!(value=="reverse")) %>%
  droplevels() %>%
  group_by(polarity, negation) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_ns, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8))
ggsave(file="../graphs/negative-strengthening-4x3.2.png",width=4,height=3.2)
# NS exists... the rating for the desirable state conveyed by negative polarity ALSO went down... Q. what does it mean??

# basic NS: DIFFERENCE (for CAMP)
agr_ns
agr_ns_diff <- data.frame(polarity = c("positive", "negative"),
                          difference = 
                            c(agr_ns[agr_ns$polarity=="positive" & agr_ns$negation=="adj",]$mean - agr_ns[agr_ns$polarity=="positive" & agr_ns$negation=="not adj",]$mean,
                              agr_ns[agr_ns$polarity=="negative" & agr_ns$negation=="adj",]$mean - agr_ns[agr_ns$polarity=="negative" & agr_ns$negation=="not adj",]$mean)) %>%
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative"))   
agr_ns_diff 
ggplot(agr_ns_diff, aes(x=polarity, y=difference, fill=polarity))+ # fill=negation
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=rep(cbPalette[4:3], times=2), name="Polarity of adjective") +
  labs(caption = "(Context = default)") +
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) +
  theme(legend.position = "none")
ggsave(file="../graphs/ns-diff-2x3.png",width=2,height=3)


# basic NS (with NORMED state rating) (.)
# NOTE: report NORMED only if that is interesting; this is NOT the case
agr_ns_normed = d %>%
  filter(!(value=="reverse")) %>%
  droplevels() %>%
  group_by(polarity, negation) %>% 
  summarise(mean = mean(normedResponseState),
            CILow = ci.low(normedResponseState),
            CIHigh = ci.high(normedResponseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_ns_normed, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating (normed by value rating)") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1, 1.2))
ggsave(file="../graphs/negative-strengthening-normed-4x3.2.png",width=4,height=3.2)
# RESULT: no big difference... maybe smaller asymmetry?

# NS where REVERSE is NOT filtered out (!!)
agr_ns_nofilter = d %>%
  group_by(polarity, negation) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_ns_nofilter, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default/reverse)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") 
ggsave(file="../graphs/negative-strengthening-nofilter-4x3.2.png",width=4,height=3.2)
# RESULT: still a little bit of NS... Q. effect of polarity?!

# NS by humanness (NOT significant although there's TENDENCY) (!)
agr_ns_targetType = d %>% 
  filter(!(value=="reverse")) %>% 
  droplevels() %>%
  group_by(polarity, negation, targetType) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
agr_ns_targetType
# human positive - human negative
(0.876-0.213) - (0.829-0.3)
# thing positive - thing negative
(0.869-0.224) - (0.812-0.26)
# RESULT: a bit bigger asymmetry in human than nonhuman
ggplot(agr_ns_targetType, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_wrap(~targetType)
ggsave(file="../graphs/NS-by-humanness-6x4.png",width=6,height=4)
# RESULT: nonhuman & human very similar; difference between good-notgood & bad-notbad seems to be a little bit bigger for human...?
# Q. necessary?


# humanness: DIFFERENCE (for CAMP)
agr_ns_targetType
agr_ns_targetType_diff <- data.frame(polarity = rep(c("positive", "negative"), each=2),
                                     humanness = rep(c("human","non-human"), times=2),
                                     difference = 
                                       c(agr_ns_targetType[agr_ns_targetType$polarity=="positive" & agr_ns_targetType$targetType=="human" & agr_ns_targetType$negation=="adj",]$mean - agr_ns_targetType[agr_ns_targetType$polarity=="positive" & agr_ns_targetType$targetType=="human" & agr_ns_targetType$negation=="not adj",]$mean, # positive human diff
                                         agr_ns_targetType[agr_ns_targetType$polarity=="positive" & agr_ns_targetType$targetType=="nonhuman" & agr_ns_targetType$negation=="adj",]$mean - agr_ns_targetType[agr_ns_targetType$polarity=="positive" & agr_ns_targetType$targetType=="nonhuman" & agr_ns_targetType$negation=="not adj",]$mean, # positive non-human diff
                                         agr_ns_targetType[agr_ns_targetType$polarity=="negative" & agr_ns_targetType$targetType=="human" & agr_ns_targetType$negation=="adj",]$mean - agr_ns_targetType[agr_ns_targetType$polarity=="negative" & agr_ns_targetType$targetType=="human" & agr_ns_targetType$negation=="not adj",]$mean, # negative human diff
                                         agr_ns_targetType[agr_ns_targetType$polarity=="negative" & agr_ns_targetType$targetType=="nonhuman" & agr_ns_targetType$negation=="adj",]$mean - agr_ns_targetType[agr_ns_targetType$polarity=="negative" & agr_ns_targetType$targetType=="nonhuman" & agr_ns_targetType$negation=="not adj",]$mean)) %>% # negative non-human diff
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative")) 
agr_ns_targetType_diff
ggplot(agr_ns_targetType_diff, aes(x=polarity, y=difference, fill=humanness))+ 
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Evaluated entity") + # c("pink2", "skyblue2")
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") + 
  labs(caption = "(Context = default)") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) 
ggsave(file="../graphs/NS-by-humanness-diff-4x3.2.png",width=4,height=3.2) 

# NS by humanness (with NORMED state rating) (!)
agr_ns_targetType_normed = d %>% 
  filter(!(value=="reverse")) %>% 
  droplevels() %>%
  group_by(polarity, negation, targetType) %>% 
  summarise(mean = mean(normedResponseState),
            CILow = ci.low(normedResponseState),
            CIHigh = ci.high(normedResponseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
agr_ns_targetType_normed
# human positive - human negative
(1.12-0.296) - (1.01-0.378)
# thing positive - thing negative
(1.14-0.308) - (1.07-0.325)
# RESULT: a bit larger asymmetry
ggplot(agr_ns_targetType_normed, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating (normed by value rating)") +
  facet_wrap(~targetType)
ggsave(file="../graphs/NS-by-humanness-normed-6x4.png",width=6,height=4)
# RESULT: a bit bigger asymmetry?! human negative polarity adj is interpreted not as bad...

# Inseong
# NS by value scale (!!!)
agr_value = d %>% 
  group_by(polarity, negation, value) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
agr_value
ggplot(agr_value, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(.~value) +
  # theme(legend.position = "none") +
  scale_y_continuous(breaks=c(0,0.2,0.4,0.6,0.8))

view(d)
# for cogsci!!!!!!
m.honesty <- lmer(weightedResponseHonest ~ negation * polarity * value + (1 | adjective), data=d)
summary(m.honesty) 
m.honesty.result <- as.data.frame(summary(m.honesty)$coefficients) %>%
  round(digits=4) %>%
  mutate(significance = ifelse(`Pr(>|t|)`<0.001, "***", ifelse(`Pr(>|t|)`<0.01,"**", ifelse(`Pr(>|t|)`<0.05,"*", ifelse(`Pr(>|t|)`<=0.1,".","")))))
m.honesty.result

latex_m.honesty.result <- xtable(m.honesty.result, caption = "Mixed-effects linear regression results predicting the normalized honesty rating from fixed effects of value scale (default vs.~reverse), polarity, negation; by-adjective random itercepts were included.", label = "tab:regression-honesty")
print(latex_m.honesty.result)

#final cogsci
ggsave(file="../graphs/ns-value.pdf",width=4,height=3)
  #theme(strip.background = element_rect(fill=c(cbPalette[5], cbPalette[1])))
ggsave(file="../graphs/ns-by-value.png",width=6,height=4)
# RESULT: asymmetry is FLIPPED... but the size of asymmetry is smaller... in REVERSE condition
# it's almost like negation stays the same and only affirmative is flipped (the desired affirmative gets higher interpretation)
# negation of negative polarity adj does get lower interpretation in the reverse condition
# negation of positive polarity adj does NOT get higher interpreatation in the reverse condition! :(
# not exactly mirror img, but if you cf each bar from left to right facet, you see change except for negated positive polarity adj!

# value scale: DIFFERENCE (for CAMP)
agr_value
agr_value_diff <- data.frame(polarity = rep(c("positive", "negative"), each=2),
                                     value = rep(c("default","reverse"), times=2),
                                     difference = 
                                       c(agr_value[agr_value$polarity=="positive" & agr_value$value=="default" & agr_value$negation=="adj",]$mean - agr_value[agr_value$polarity=="positive" & agr_value$value=="default" & agr_value$negation=="not adj",]$mean, # positive default diff
                                         agr_value[agr_value$polarity=="positive" & agr_value$value=="reverse" & agr_value$negation=="adj",]$mean - agr_value[agr_value$polarity=="positive" & agr_value$value=="reverse" & agr_value$negation=="not adj",]$mean, # positive reverse diff
                                         agr_value[agr_value$polarity=="negative" & agr_value$value=="default" & agr_value$negation=="adj",]$mean - agr_value[agr_value$polarity=="negative" & agr_value$value=="default" & agr_value$negation=="not adj",]$mean, # negative default diff
                                         agr_value[agr_value$polarity=="negative" & agr_value$value=="reverse" & agr_value$negation=="adj",]$mean - agr_value[agr_value$polarity=="negative" & agr_value$value=="reverse" & agr_value$negation=="not adj",]$mean)) %>% # negative reverse diff
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative")) 
agr_value_diff
ggplot(agr_value_diff, aes(x=polarity, y=difference, fill=value))+ 
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Context") + # c("pink2", "skyblue2")
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) 
ggsave(file="../graphs/NS-by-value-diff-3.5x3.2.png",width=3.5,height=3.2) 


# NS by value scale (with NORMED state rating) (!)
agr_value_normed = d %>% 
  group_by(polarity, negation, value) %>% 
  summarise(mean = mean(normedResponseState),
            CILow = ci.low(normedResponseState),
            CIHigh = ci.high(normedResponseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
agr_value_normed
ggplot(agr_value_normed, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1, 1.2)) +
  xlab("Adjectival polarity") +
  ylab("Mean state rating (normed by value rating)") +
  facet_grid(.~value)
ggsave(file="../graphs/value-normed-6x4.png",width=6,height=4)
# RESULT: NO asymmetry in the REVERSE condition :<
# there is some flipping, but small size...
# negation of negative polarity adj does get a little lower in the reverse condition -- a bit more NS?
# TODO: cut at 1 when norming by value rating???

# NS by humanness & value scale (!!!)
agr = d %>% 
  group_by(polarity, negation, targetType, value) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         #polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )
ggplot(agr, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  scale_y_continuous(breaks = c(0,0.2,0.4,0.6,0.8,1)) +
  facet_grid(targetType~value)
ggsave(file="../graphs/ns-full.png",width=6,height=5)

# NS by humanness & value scale (with NORMED state rating) (!!)
agr_normed = d %>% 
  group_by(polarity, negation, targetType, value) %>% 
  summarise(mean = mean(normedResponseState),
            CILow = ci.low(normedResponseState),
            CIHigh = ci.high(normedResponseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         #polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )
ggplot(agr_normed, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating (normed by value rating)") +
  facet_grid(targetType~value)
ggsave(file="../graphs/full-NS-by-value-and-humanness-normed-6x4.png",width=6,height=4)
# RESULT: everything looks good... except human X reverse where there is no asymmetry?!
# this is too complicated... don't bother norming state rating by value rating

# NS by humanness & value scale in BOX plot
ggplot(d, aes(x = polarity, y = responseState, fill=negation)) +
  geom_boxplot() +
  labs(title = "State rating by value scale", x = "value scale", y = "state rating") +
  facet_grid(targetType~value)

##### VALUE RATING #####

# distribution of value rating by value scale (!!!) -- used for CogSci
# violin
ggplot(d, aes(x = value, y = responseValue)) +
  geom_violin() +
  labs(# title = "Value rating by value scale", 
       x = "value scale", y = "value rating") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1))
ggsave(file="../graphs/value-rating-per-value-scale-violin.png",width=2.5,height=2.5)
# box
ggplot(d, aes(x = value, y = responseValue)) +
  geom_boxplot() +
  labs(#title = "Value rating by value scale", 
    x = "value scale", y = "value rating") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1))
ggsave(file="../graphs/value-rating-per-value-scale-box.png",width=2.5,height=2.5)
# bar
agr_responseValue_value = d %>% 
  group_by(value) %>% 
  summarise(mean = mean(responseValue),
            CILow = ci.low(responseValue),
            CIHigh = ci.high(responseValue)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh)
ggplot(agr_responseValue_value, aes(x=value, y=mean, fill=value))+ 
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[1],cbPalette[5]), name="Value scale") +
  xlab("Value scale") +
  ylab("Mean value rating") +
  theme(legend.position = 'none') +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1))
# final cogsci
ggsave(file="../graphs/value-rating.pdf",width=2,height=2)

# Is value rating more extreme in human entity?
# value rating by context & humanness
agr_responseValue_value_targetType = d %>% 
  group_by(value, targetType) %>% 
  summarise(mean = mean(responseValue),
            CILow = ci.low(responseValue),
            CIHigh = ci.high(responseValue)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh)
ggplot(agr_responseValue_value_targetType, aes(x=targetType, y=mean, fill=targetType))+ 
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Type of evaluated entity") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1, 1.2)) +
  xlab("Type of evaluated entity") +
  ylab("Mean value rating") +
  facet_wrap(~value)
ggsave(file="../graphs/value-rating-per-humanness-bar-6x4.png",width=6,height=4)
ggplot(d, aes(x = value, y=responseValue, fill=targetType)) +
  geom_boxplot() +
  scale_fill_manual(values=cbPalette, name="Type of evaluated entity") +
  xlab("Value scale") +
  ylab("Value rating")
ggsave(file="../graphs/value-rating-per-humanness-box-6x4.png",width=6,height=4)
# RESULT: NO significant difference by humanness BUT HUMAN value rating seems a bit more EXTREME

##### INTENTION RATINGS #####

# raw positivity by value scale (!)
agr_positivity_value = d %>% 
  droplevels() %>%
  group_by(polarity, negation, value) %>% 
  summarise(mean = mean(responsePositive),
            CILow = ci.low(responsePositive),
            CIHigh = ci.high(responsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         # polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )
ggplot(agr_positivity_value, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Raw importance of positivity") +
  facet_grid(.~value)
ggsave(file="../graphs/raw-positivity-per-value-scale-6x4.png",width=6,height=4)
# RESULT: everything is as expected & symmetrical EXCEPT negated negative polarity adj in default value 

# relative positivity by value scale (!!!) -- used for CogSci
agr_rel_positivity_value = d %>% 
  droplevels() %>%
  group_by(polarity, negation, value) %>% 
  summarise(mean = mean(weightedResponsePositive),
            CILow = ci.low(weightedResponsePositive),
            CIHigh = ci.high(weightedResponsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         # polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )
ggplot(agr_rel_positivity_value, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of positivity") +
  facet_grid(.~value)
ggsave(file="../graphs/rel-positivity-by-value.png",width=6,height=4)
# RESULT: a bit more asymmetry... 
# in default, affirmative negative adj is the lowest; in reverse, affirmative positive adj is the lowest (as expected!)

# relative HONESTY by value scale (!!!) -- used for CogSci
agr_rel_honesty_value = d %>% 
  droplevels() %>%
  group_by(polarity, negation, value) %>% 
  summarise(mean = mean(weightedResponseHonest),
            CILow = ci.low(weightedResponseHonest),
            CIHigh = ci.high(weightedResponseHonest)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         # polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )
agr_rel_honesty_value$mean
view(agr_rel_honesty_value)
ggplot(agr_rel_honesty_value, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of honesty (vs. positivity)") +
  # theme(legend.position = "none") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8), limits=c(0,0.8)) +
  facet_grid(.~value)
# final cogsci
ggsave(file="../graphs/rel-honesty-by-value.png",width=6,height=4)





# raw positivity by humanness
agr_positivity_targetType = d %>% 
  filter(value=="default") %>%
  droplevels() %>%
  group_by(polarity, negation, targetType) %>% 
  summarise(mean = mean(responsePositive),
            CILow = ci.low(responsePositive),
            CIHigh = ci.high(responsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         # polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )
ggplot(agr_positivity_targetType, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Raw importance of positivity") +
  facet_grid(.~targetType)
ggsave(file="../graphs/raw-positivity-per-humanness-6x4.png",width=6,height=4)
# RESULT: a bit higher positivity for affirmative positive adj in human...

# relative positivity by humanness
agr_rel_positivity_targetType = d %>% 
  filter(value=="default") %>%
  droplevels() %>%
  group_by(polarity, negation, targetType) %>% 
  summarise(mean = mean(weightedResponsePositive),
            CILow = ci.low(weightedResponsePositive),
            CIHigh = ci.high(weightedResponsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         # polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )
ggplot(agr_rel_positivity_targetType, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of positivity") +
  facet_grid(.~targetType)
ggsave(file="../graphs/rel-positivity-per-humanness-6x4.png",width=6,height=4)
# RESULT: NO big difference except that 
# negative utterances (not good, bad) -> lower importance of positivity for HUMAN than for nonhuman
# Q. what does it mean?

# relative HONESTY by HUMAN (for QP2 defense draft)
# relative positivity by humanness
agr_rel_honesty_targetType = d %>% 
  filter(value=="default") %>%
  droplevels() %>%
  group_by(polarity, negation, targetType) %>% 
  summarise(mean = mean(weightedResponseHonest),
            CILow = ci.low(weightedResponseHonest),
            CIHigh = ci.high(weightedResponseHonest)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         # polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )
ggplot(agr_rel_honesty_targetType, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of honesty (vs. positivity)") +
  facet_grid(.~targetType)
ggsave(file="../graphs/rel-honesty-by-human.png",width=6,height=4)



# raw positivity by (polarity & negation), value scale, humanness
agr_positivity = d %>%
  group_by(polarity, negation, value, targetType) %>%
  summarise(mean = mean(responsePositive),
            CILow = ci.low(responsePositive),
            CIHigh = ci.high(responsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0")
  )
ggplot(agr_positivity, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Raw importance of positivity") +
  facet_grid(value~targetType)
ggsave(file="../graphs/raw-positivity-per-humanness-value-6x5.png",width=6,height=5)
#RESULT: value scale--as expected; humanness--human X reverse is a bit different than nonhuman X reverse

# relative positivity by (polarity & negation), value scale, humanness
agr_rel_positivity = d %>%
  group_by(polarity, negation, value, targetType) %>%
  summarise(mean = mean(weightedResponsePositive),
            CILow = ci.low(weightedResponsePositive),
            CIHigh = ci.high(weightedResponsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0")
  )
ggplot(agr_rel_positivity, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of positivity") +
  facet_grid(value~targetType)
ggsave(file="../graphs/rel-positivity-per-humanness-value-6x5.png",width=6,height=5)

# relative honesty by (polarity & negation), value scale, humanness (used for QP2 defense draft)
agr_rel_honesty = d %>%
  group_by(polarity, negation, value, targetType) %>%
  summarise(mean = mean(weightedResponseHonest),
            CILow = ci.low(weightedResponseHonest),
            CIHigh = ci.high(weightedResponseHonest)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0")
  )
ggplot(agr_rel_honesty, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of honesty") +
  facet_grid(targetType~value)
ggsave(file="../graphs/rel-honesty.png",width=6,height=5)


# RESULT: again, human X reverse is a bit different than nonhuman X reverse (but smaller difference...?)
# positivity is overall less important for human (X reverse) than for nonhuman (X reverse) -- NOT as expected

# raw honesty by (polarity & negation), value scale, humanness
agr_honesty = d %>%
  group_by(polarity, negation, value, targetType) %>%
  summarise(mean = mean(responseHonest),
            CILow = ci.low(responseHonest),
            CIHigh = ci.high(responseHonest)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0")
  )
ggplot(agr_honesty, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Raw importance of honesty") +
  facet_grid(value~targetType)
ggsave(file="../graphs/raw-honesty-per-humanness-value-6x5.png",width=6,height=5)
# RESULT: overall high... (human X default X not bad) and (human X reverse X good) are low...?


# raw POSITIVITY in CONTROL (!!!)
agr_ctrl_positivity = d_with_control %>%
  filter(stimulusType=="control") %>%
  droplevels() %>%
  group_by(polarity, state) %>%
  summarise(mean = mean(responsePositive),
            CILow = ci.low(responsePositive),
            CIHigh = ci.high(responsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         state = fct_recode(state, "desirable" = "positive", "undesirable" = "negative")
  )
ggplot(agr_ctrl_positivity, aes(x=state, y=mean, fill=polarity))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[2],cbPalette[6]), name="Adjectival polarity") +
  xlab("True state") +
  ylab("Mean positivity rating for control stimuli")
ggsave(file="../graphs/raw-positivity-control.pdf",width=5,height=4)

# raw HONESTY in CONTROL (!!!)
agr_ctrl_honesty = d_with_control %>%
  filter(stimulusType=="control") %>%
  droplevels() %>%
  group_by(polarity, state) %>%
  summarise(mean = mean(responseHonest),
            CILow = ci.low(responseHonest),
            CIHigh = ci.high(responseHonest)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         state = fct_recode(state, "desirable" = "positive", "undesirable" = "negative")
  )
ggplot(agr_ctrl_honesty, aes(x=state, y=mean, fill=polarity))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[2],cbPalette[6]), name="Adjectival polarity") +
  xlab("True state") +
  ylab("Mean honesty rating for control stimuli")
ggsave(file="../graphs/raw-honesty-control.pdf",width=5,height=4)
# relative positivity/honesty in CONTROL = UNNECESSARY

# state in CONTROL 
agr_ctrl_state = d_with_control %>%
  filter(stimulusType=="control") %>%
  droplevels() %>%
  group_by(state) %>% # very weird result without including `polarity`!!!
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         state = fct_recode(state, "desirable" = "positive", "undesirable" = "negative")
  )
ggplot(agr_ctrl_state, aes(x=state, y=mean, fill=state))+ # very weird result without including `polarity`!!!
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="True state") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1)) +
  xlab("True state") +
  ylab("Mean state rating for control stimuli") +
  theme(legend.position = "null")
ggsave(file="../graphs/state-control-6x4.png",width=6,height=4)

##### VARIATION #####

# --by item (!!)
agr_item = d %>% 
filter((value=="default")) %>% 
  droplevels() %>%
  group_by(polarity, negation, item, targetType) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_item, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(targetType~item)
ggsave(file="../graphs/NS-by-item-12x5.png",width=12,height=5)
# RESULT: good-bad has stronger NS; human have clearer NS! in nonhuman, only weather (good-bad) and zebra (animal!) have clear NS!

# POSITIVITY and NS by ITEM (!!)
agr_item_positivity = d %>% 
  filter((value=="default")) %>% 
  droplevels() %>%
  group_by(item, targetType) %>% 
  summarise(mean = mean(weightedResponsePositive),
            CILow = ci.low(weightedResponsePositive),
            CIHigh = ci.high(weightedResponsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh)
ggplot(agr_item_positivity, aes(x=item, y=mean))+ #, fill=item))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  #scale_fill_manual(values=cbPalette, name="???") +
  labs(caption = "(Value scale = default)") +
  xlab("Item") +
  ylab("Relative importance of positivity (vs. honesty)")
ggsave(file="../graphs/rel-positivity-by-item-6x4.png",width=6,height=4)
# TODO: calculate difference between adj & not-adj!!!
# but with bare eyes... there doesn't seem to be a correlation :(

# item, context (!)
agr_item_value = d %>% 
  group_by(polarity, negation, item, targetType, value) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_item_value, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(value~item)
ggsave(file="../graphs/NS-by-item-per-value-scale-12x5.png",width=12,height=5)
# RESULT: some random patterns...

# --by adj (!!!)
agr_adj = d %>% 
  filter((value=="default")) %>% 
  droplevels() %>%
  group_by(polarity, negation, adjectivePair) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_adj, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) +
  facet_grid(.~adjectivePair)
ggsave(file="../graphs/NS-by-adj-7x4.png",width=7,height=4)
# RESULT: good-bad has largest NS!

# adjective: DIFFERENCE (for CAMP)
agr_adj_each <- d %>% 
  filter((value=="default")) %>% 
  droplevels() %>%
  group_by(negation, adjectivePair, adjective) %>% # polarity, 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
agr_adj_each
agr_adj_diff <- data.frame(polarity = rep(c("positive", "negative"), times=4),
                             adjectivePair = rep(c("big/small", "fast/slow", "good/bad", "long/short"), each=2),
                             difference = 
                               c(agr_adj_each[agr_adj_each$adjective=="big" & agr_adj_each$negation=="adj",]$mean - agr_adj_each[agr_adj_each$adjective=="big" & agr_adj_each$negation=="not adj",]$mean, # big
                                 agr_adj_each[agr_adj_each$adjective=="small" & agr_adj_each$negation=="adj",]$mean - agr_adj_each[agr_adj_each$adjective=="small" & agr_adj_each$negation=="not adj",]$mean, # small
                                 agr_adj_each[agr_adj_each$adjective=="fast" & agr_adj_each$negation=="adj",]$mean - agr_adj_each[agr_adj_each$adjective=="fast" & agr_adj_each$negation=="not adj",]$mean, # fast
                                 agr_adj_each[agr_adj_each$adjective=="slow" & agr_adj_each$negation=="adj",]$mean - agr_adj_each[agr_adj_each$adjective=="slow" & agr_adj_each$negation=="not adj",]$mean, # slow
                                 agr_adj_each[agr_adj_each$adjective=="good" & agr_adj_each$negation=="adj",]$mean - agr_adj_each[agr_adj_each$adjective=="good" & agr_adj_each$negation=="not adj",]$mean, # good
                                 agr_adj_each[agr_adj_each$adjective=="bad" & agr_adj_each$negation=="adj",]$mean - agr_adj_each[agr_adj_each$adjective=="bad" & agr_adj_each$negation=="not adj",]$mean, # bad
                                 agr_adj_each[agr_adj_each$adjective=="long" & agr_adj_each$negation=="adj",]$mean - agr_adj_each[agr_adj_each$adjective=="long" & agr_adj_each$negation=="not adj",]$mean, # long
                                 agr_adj_each[agr_adj_each$adjective=="short" & agr_adj_each$negation=="adj",]$mean - agr_adj_each[agr_adj_each$adjective=="short" & agr_adj_each$negation=="not adj",]$mean)) %>% # short
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative")) 
agr_adj_diff
ggplot(agr_adj_diff, aes(x=adjectivePair, y=difference, fill=polarity))+ 
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Polarity") + # c("pink2", "skyblue2")
  xlab("Adjective") +
  ylab("Negative strengthening") +
  labs(caption = "(Context = default)") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) 
ggsave(file="../graphs/NS-by-adj-diff-4.5x3.2.png",width=4.5,height=3.2) 





# GOOD-BAD only (!!!)
agr_good_bad = d %>% 
  filter((adjectivePair=="good-bad")) %>% 
  droplevels() %>%
  group_by(polarity, negation, targetType, value) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative"))
ggplot(agr_good_bad, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  # labs(title = "Mean state rating for good/bad"#, caption = "(Adjectival pair = good/bad)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) +
  facet_grid(targetType~value)
ggsave(file="../graphs/ns-good-bad.png",width=6,height=5)
# RESULT: reverse X human is very weird... reverse X nonhuman shows reverse pattern


# adj, context (!!!)
agr_adj_value = d %>% 
  group_by(polarity, negation, adjectivePair, value) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_adj_value, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette[4:3], name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) +
  facet_grid(value~adjectivePair)
ggsave(file="../graphs/NS-by-adj-per-value-scale-7x5.png",width=7,height=5)
# RESULT: good-bad has strong NS in default BUT NO NS in reverse :( 

# adj, humanness (default) = same as item
agr_adj_targetType = d %>% 
  filter(value=="default") %>%
  droplevels() %>%
  group_by(polarity, negation, adjectivePair, targetType) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_adj_targetType, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) +
  facet_grid(targetType~adjectivePair)
ggsave(file="../graphs/NS-by-adj-per-humanness-7x5.png",width=7,height=5)
# RESULT: more consistent NS in human than nonhuman

# adj, humanness (reverse)
agr_adj_targetType_reverse = d %>% 
  filter(value=="reverse") %>%
  droplevels() %>%
  group_by(polarity, negation, adjectivePair, targetType) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_adj_targetType_reverse, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = reverse)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  scale_y_continuous(breaks = c(0, 0.2, 0.4, 0.6, 0.8)) +
  facet_grid(targetType~adjectivePair)
ggsave(file="../graphs/NS-by-adj-per-humanness-reverse-7x5.png",width=7,height=5)
# RESULT: messy/inconsistent NS pattern in REVERSE :(

# positivity by item
agr_positivity_item = d %>% 
  filter((value=="default")) %>% 
  group_by(polarity, negation, item, targetType) %>% 
  summarise(mean = mean(responsePositive),
            CILow = ci.low(responsePositive),
            CIHigh = ci.high(responsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_positivity_item, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Positivity intention score") +
  facet_grid(targetType~item)

# honesty by item
agr_honesty_item = d %>% 
  filter((value=="default")) %>% 
  group_by(polarity, negation, item, targetType) %>% 
  summarise(mean = mean(responseHonest),
            CILow = ci.low(responseHonest),
            CIHigh = ci.high(responseHonest)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_honesty_item, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") + 
  xlab("Adjectival polarity") +
  ylab("Honesty intention score") +
  facet_grid(targetType~item)
# RESULT: a bit confusing -> makes more sense with *relative* honesty

# relative importance of honesty by item
agr_weigtedHonesty_item = d %>% 
  filter((value=="default")) %>% 
  group_by(polarity, negation, item, targetType) %>% 
  summarise(mean = mean(weightedResponseHonest),
            CILow = ci.low(weightedResponseHonest),
            CIHigh = ci.high(weightedResponseHonest)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_weigtedHonesty_item, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of honesty (vs. positivity)") +
  facet_grid(targetType~item)

# relative importance of positivity by item
agr_weigtedPositivity_item = d %>% 
  filter((value=="default")) %>% 
  group_by(polarity, negation, item, targetType) %>% 
  summarise(mean = mean(weightedResponsePositive),
            CILow = ci.low(weightedResponsePositive),
            CIHigh = ci.high(weightedResponsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_weigtedPositivity_item, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of positivity (vs. honesty)") +
  facet_grid(targetType~item)
ggsave(file="../graphs/rel-positivity-by-item-per-humanness-12x5.png",width=12,height=5)

# positivity by ADJ
agr_positivity_adj = d %>% 
  filter((value=="default")) %>% 
  group_by(polarity, negation, adjectivePair, targetType) %>% 
  summarise(mean = mean(responsePositive),
            CILow = ci.low(responsePositive),
            CIHigh = ci.high(responsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_positivity_adj, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Positivity intention score") +
  facet_grid(targetType~adjectivePair)

# honesty by ADJ
agr_honesty_adj = d %>% 
  filter((value=="default")) %>% 
  group_by(polarity, negation, adjectivePair, targetType) %>% 
  summarise(mean = mean(responseHonest),
            CILow = ci.low(responseHonest),
            CIHigh = ci.high(responseHonest)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_honesty_adj, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") + 
  xlab("Adjectival polarity") +
  ylab("Honesty intention score") +
  facet_grid(targetType~adjectivePair)
# RESULT: again, a bit confusing --> see RELATIVE importance

# relative importance of positivity by adj
agr_weigtedPositivity_adj = d %>% 
  filter((value=="default")) %>% 
  group_by(polarity, negation, adjectivePair, targetType) %>% 
  summarise(mean = mean(weightedResponsePositive),
            CILow = ci.low(weightedResponsePositive),
            CIHigh = ci.high(weightedResponsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_weigtedPositivity_adj, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Relative importance of positivity (vs. honesty)") +
  facet_grid(targetType~adjectivePair)
ggsave(file="../graphs/rel-positivity-by-adj-per-humanness-7x5.png",width=7,height=5)
# RESULT: as expected

# VALUE rating by adj (!!)
agr_value_adj = d %>% 
  group_by(value, adjectivePair, targetType) %>% 
  summarise(mean = mean(responseValue),
            CILow = ci.low(responseValue),
            CIHigh = ci.high(responseValue)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh)
ggplot(agr_value_adj, aes(x=targetType, y=mean, fill=targetType))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="???") +
#  labs(caption = "(Value scale = default)") +
  xlab("???") +
  ylab("Mean value rating") +
  facet_grid(value~adjectivePair)
# RESULT: NO visible difference or pattern in value rating depending on humanness

# VALUE rating by item
agr_value_item = d %>% 
  group_by(value, item) %>% 
  summarise(mean = mean(responseValue),
            CILow = ci.low(responseValue),
            CIHigh = ci.high(responseValue)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh)
ggplot(agr_value_item, aes(x=value, y=mean, fill=value))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Value scale") +
  #  labs(caption = "(Value scale = default)") +
  xlab("Value scale") +
  ylab("Mean value rating") +
  facet_grid(.~item)
ggsave(file="../graphs/value-rating-by-item-12x5.png",width=12,height=5)

# by time
agr_time = d %>% 
  group_by(workerid) %>%
  mutate(time = ifelse(row_number() <= 4, "first_half", "second_half")) %>%
  filter((value=="default")) %>% 
  group_by(polarity, negation, time) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_time, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(caption = "(Value scale = default)") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(.~time)
ggsave(file="../graphs/NS-by-time-6x4.png",width=6,height=4)
# RESULT: ???

# by specific participant # TODO (graph looks weird & missing bc it actually is)
agr_participant = d %>% 
  filter(workerid=="103") %>% 
  group_by(polarity, negation, targetType, value) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))
ggplot(agr_participant, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  labs(title = "workerid 103") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(targetType~value)


##### ETC #####

# TODO: positive/honest score <-> degree of NS
d_rel_positive = d %>% 
  filter(value=="default") %>%
  droplevels() %>%
  mutate(negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))

ggplot(d_rel_positive, aes(x = weightedResponsePositive, y = responseState)) +
  geom_point() +
  facet_grid(negation~polarity)
# RESULT: ???

##### FAKE, PROTOTYPE PLOT ##### FOR CAMP
fake_ns <- data.frame(polarity  = rep(c("fun", "boring"),each=2),
                      negation = rep(c("adj", "not adj"),times=2),
                      utterance = c("fun", "not fun", "boring", "not boring"),
                      mean = c(0.9,0.3,0.9,0.5),
                      CILow = runif(n=4, min=0.01, max=0.02),
                      CIHigh = runif(n=4, min=0.01, max=0.02)
                      ) %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh) %>%
  mutate_if(is.character, as.factor) %>%
  mutate(utterance = fct_relevel(utterance, "fun", "not fun", "boring", "not boring"))
fake_ns
ggplot(fake_ns, aes(x=utterance, y=mean, fill=utterance)) + # fill=negation
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=rep(cbPalette[4:3], times=2)) + # cbPalette, name="Adjectival form") + # c("pink", "pink4", "skyblue", "skyblue4"
  # labs(caption = "(Value scale = default)") +
  xlab("Utterance") +
  ylab("Interpretation") +
  scale_y_continuous(breaks=c(0,1), limits = c(0,1)) +
  theme(legend.position = "none", panel.grid = element_blank()) 
ggsave(file="../graphs/fake-ns.png",width=2.8,height=3)

fake_ns_diff <- data.frame(polarity = c("positive", "negative"),
                           adjective = c("fun", "boring"),
                         difference = c(fake_ns[fake_ns$utterance=="fun",]$mean - fake_ns[fake_ns$utterance=="not fun",]$mean,
                                        fake_ns[fake_ns$utterance=="boring",]$mean - fake_ns[fake_ns$utterance=="not boring",]$mean)) %>%
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative"),
         adjective = fct_relevel(adjective, "fun", "boring")) 
fake_ns_diff
ggplot(fake_ns_diff, aes(x=polarity, y=difference, fill=polarity))+ # fill=negation
  geom_bar(stat="identity", position=dodge) +
  geom_text(aes(label=c("fun - not fun", "boring - not boring")), vjust=-0.5, size=3) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[2], cbPalette[6])) +  # c("pink2", "skyblue2")
  # labs(caption = "(Value scale = default)") +
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 1), limits = c(0,1)) +
  theme(legend.position = "none", panel.grid = element_blank())
ggsave(file="../graphs/fake-ns-diff.png",width=2.5,height=3)

# prediction for asymmetry
fake_pred_ns <- data.frame(polarity = c("positive", "negative"),
                           difference = c(fake_ns[fake_ns$utterance=="fun",]$mean - fake_ns[fake_ns$utterance=="not fun",]$mean,
                                          fake_ns[fake_ns$utterance=="boring",]$mean - fake_ns[fake_ns$utterance=="not boring",]$mean)) %>%
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative"))
fake_pred_ns
ggplot(fake_ns_diff, aes(x=polarity, y=difference, fill=polarity))+ # fill=negation
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[2], cbPalette[6]), name="Adjectival form") + # c("pink2", "skyblue2")
  # labs(caption = "(Value scale = default)") +
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 1), limits = c(0,1)) +
  theme(legend.position = "none", panel.grid = element_blank())
ggsave(file="../graphs/fake-ns-predicted-by-both.png",width=2,height=3) # prediction plot

# predictions for value scale
fake_value_pred_by_face <- data.frame(polarity = rep(c("positive", "negative"), each=2),
                              value = rep(c("default","reverse"), times=2),
                              difference = c(0.6, 0.4, 0.4, 0.6)) %>%
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative")) 
fake_value_pred_by_face
ggplot(fake_value_pred_by_face, aes(x=polarity, y=difference, fill=value))+ 
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[1], cbPalette[5]), name="Value scale") + # c("pink2", "skyblue2")
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 1), limits = c(0,1)) +
  theme(panel.grid = element_blank())
ggsave(file="../graphs/fake-value-predicted-by-face.png",width=4,height=3.2) 
fake_value_pred_by_pol <- data.frame(polarity = rep(c("positive", "negative"), each=2),
                                      value = rep(c("default","reverse"), times=2),
                                      difference = rep(c(0.6, 0.4), each=2)) %>%
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative")) 
fake_value_pred_by_pol
ggplot(fake_value_pred_by_pol, aes(x=polarity, y=difference, fill=value))+ 
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[1], cbPalette[5]), name="Value scale") + # c("pink2", "skyblue2")
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 1), limits = c(0,1)) +
  theme(panel.grid = element_blank())
ggsave(file="../graphs/fake-value-predicted-by-polarity.png",width=4,height=3.2) 

# predictions for entity type / humanness
fake_human_pred_by_face <- data.frame(polarity = rep(c("positive", "negative"), each=2),
                                      humanness = rep(c("non-human","human"), times=2),
                                      difference = c(0.5, 0.7, 0.4, 0.4)) %>%
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative"),
         humanness = fct_relevel(humanness, "non-human", "human")) 
fake_human_pred_by_face
ggplot(fake_human_pred_by_face, aes(x=polarity, y=difference, fill=humanness))+ 
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[9], cbPalette[7]), name="Assessed entity") + # c("pink2", "skyblue2")
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 1), limits = c(0,1)) +
  theme(panel.grid = element_blank())
ggsave(file="../graphs/fake-human-predicted-by-face.png",width=4,height=3.2) 
fake_human_pred_by_pol <- data.frame(polarity = rep(c("positive", "negative"), each=2),
                                     humanness = rep(c("human","non-human"), times=2),
                                     difference = rep(c(0.6, 0.4), each=2)) %>%
  mutate_if(is.character, as.factor) %>%
  mutate(polarity = fct_relevel(polarity, "positive", "negative"),
         humanness = fct_relevel(humanness, "non-human", "human")) 
fake_human_pred_by_pol
ggplot(fake_human_pred_by_pol, aes(x=polarity, y=difference, fill=humanness))+ 
  geom_bar(stat="identity", position=dodge) +
  # geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=c(cbPalette[9], cbPalette[7]), name="Assessed entity") + # c("pink2", "skyblue2")
  xlab("Polarity of adjective") +
  ylab("Negative strengthening") +
  scale_y_continuous(breaks = c(0, 1), limits = c(0,1)) +
  theme(panel.grid = element_blank())
ggsave(file="../graphs/fake-human-predicted-by-polarity.png",width=4,height=3.2) 

#####################
### from template ###
#####################

# generate histogram of proportion of "odd sentence" judgments
ggplot(agr, aes(x=prop_odd)) +
  geom_histogram() +
  xlab("By-item proportion of 'odd' judgments") +
  ylab("Number of cases")
ggsave(file="../graphs/histogram_means.pdf",width=4,height=3.2)
  
# is there a correlation between oddness judgments and inference strength ratings?
ggplot(agr, aes(x=prop_odd,y=mean)) +
  geom_point() +
  xlab("By-item proportion of 'odd' judgments") +
  ylab("Mean by-item rating") 

# are inference strength ratings modulated by partitive?
agr = d %>%
  group_by(partitive) %>%
  summarise(Mean = mean(response),CILow=ci.low(response),CIHigh=ci.high(response)) %>%
  ungroup() %>%
  mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(partitive = fct_recode(partitive,"partitive"="yes","non-partitive"="no"))

ggplot(agr,aes(x=partitive,y=Mean)) +
  geom_bar(stat="identity",color="black",width=.6,fill="gray60") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25,color="black") +
  scale_fill_manual(values=c("#56B4E9")) +
  ylab("Mean inference strength rating")
ggsave(file="../graphs/means_partitive.pdf",width=4,height=3.2)

# add by-participant means to the plot to display measure of variability
agr_subj = d %>%
  group_by(partitive,workerid) %>%
  summarise(Mean = mean(response),CILow=ci.low(response),CIHigh=ci.high(response)) %>%
  ungroup() %>%
  mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(partitive = fct_recode(partitive,"partitive"="yes","non-partitive"="no"))

ggplot(agr,aes(x=partitive,y=Mean)) +
  geom_bar(stat="identity",color="black",width=.6,fill="gray60") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25,color="black") +
  geom_point(data=agr_subj,alpha=.3) +
  scale_fill_manual(values=c("#56B4E9")) +
  ylab("Mean inference strength rating")
ggsave(file="../graphs/means_partitive.pdf",width=4,height=3.2)

# are inference strength ratings modulated by subjecthood?
d$subjecthood = as.factor(as.character(d$subjecthood))

agr = d %>%
  group_by(subjecthood) %>%
  summarise(Mean = mean(response),CILow=ci.low(response),CIHigh=ci.high(response)) %>%
  ungroup() %>%
  mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(subjecthood = fct_recode(subjecthood,"subject"="1","other"="0"))

agr_subj = d %>%
  group_by(subjecthood,workerid) %>%
  summarise(Mean = mean(response),CILow=ci.low(response),CIHigh=ci.high(response)) %>%
  ungroup() %>%
  mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(subjecthood = fct_recode(subjecthood,"subject"="1","other"="0"))

ggplot(agr,aes(x=subjecthood,y=Mean)) +
  geom_bar(stat="identity",color="black",width=.6,fill="gray60") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25,color="black") +
  geom_point(data=agr_subj,alpha=.3) +
  scale_fill_manual(values=c("#56B4E9")) +
  ylab("Mean inference strength rating")
ggsave(file="../graphs/means_subjecthood.pdf",width=4,height=3.2)

# are inference strength ratings modulated by discourse givenness?
d$subjecthood = as.factor(as.character(d$subjecthood))

agr = d %>%
  group_by(infoStatus) %>%
  summarise(Mean = mean(response),CILow=ci.low(response),CIHigh=ci.high(response)) %>%
  ungroup() %>%
  mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(infoStatus = fct_recode(infoStatus,"mediated"="med")) %>% 
  mutate(infoStatus = fct_relevel(infoStatus, "new", "mediated"))

agr_subj = d %>%
  group_by(infoStatus,workerid) %>%
  summarise(Mean = mean(response),CILow=ci.low(response),CIHigh=ci.high(response)) %>%
  ungroup() %>%
  mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(infoStatus = fct_recode(infoStatus,"mediated"="med")) %>% 
  mutate(infoStatus = fct_relevel(infoStatus, "new", "mediated"))

ggplot(agr,aes(x=infoStatus,y=Mean)) +
  geom_bar(stat="identity",color="black",width=.6,fill="gray60") +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.25,color="black") +
  geom_point(data=agr_subj,alpha=.3) +
  scale_fill_manual(values=c("#56B4E9")) +
  ylab("Mean inference strength rating")
ggsave(file="../graphs/means_infoStatus.pdf",width=4,height=3.2)

# are inference strength ratings modulated by strength of "some"?
agr = d %>%
  group_by(id,strengthSome) %>%
  summarise(Mean = mean(response),CILow=ci.low(response),CIHigh=ci.high(response)) %>%
  ungroup() 

ggplot(agr,aes(x=strengthSome,y=Mean)) +
  geom_point() +
  geom_smooth(method="lm") +
  ylab("Mean inference strength rating") +
  xlab("Strength of quantifier (lower is stronger)")
ggsave(file="../graphs/means_strengthSome.pdf",width=4,height=3.2)

### end: from template ###


##############
# Regression #
##############

# TODO: ///

# regression predicting value rating (for CogSci)
# maximal random effects without singularity issue (workerid does not work)
m.value <- lmer(responseValue ~ value + (1 | adjective), data=d)
summary(m.value) 
m.value.result <- as.data.frame(summary(m.value)$coefficients) %>%
  round(digits=4) %>%
  mutate(significance = ifelse(`Pr(>|t|)`<0.001, "***", ifelse(`Pr(>|t|)`<0.01,"**", ifelse(`Pr(>|t|)`<0.05,"*", ifelse(`Pr(>|t|)`<=0.1,".","")))))
m.value.result
latex_m.value.result <- xtable(m.value.result, caption = "Mixed-effects linear regression results predicting the value rating from fixed effect of value scale (default vs.~reverse); by-adjective random itercepts were included.", label = "tab:regression-value")
print(latex_m.value.result, include.rownames = TRUE)

# isSingular(m.value)

# regression predicting honesty rating (for defense draft of QP2)
# maximal random effects without singularity issue 
m.honesty.ctrl <- lmer(responseHonest ~ state*polarity + (1 | adjective) + (1 | workerid), data=d_with_control)
summary(m.honesty.ctrl) 
m.honesty.ctrl.result <- as.data.frame(summary(m.honesty.ctrl)$coefficients) %>%
  round(digits=4) %>%
  mutate(significance = ifelse(`Pr(>|t|)`<0.001, "***", ifelse(`Pr(>|t|)`<0.01,"**", ifelse(`Pr(>|t|)`<0.05,"*", ifelse(`Pr(>|t|)`<=0.1,".","")))))
m.honesty.ctrl.result

latex_m.honesty.ctrl.result <- xtable(m.honesty.ctrl.result, caption = "Mixed-effects linear regression results predicting the honesty rating from fixed effects of state (desirable vs.~undesirable), polarity (positive vs.~negative), and their interaction; by-adjective and by-participant random intercepts were included.", label = "tab:regression-honesty")
print(latex_m.honesty.ctrl.result, include.rownames = TRUE)
# isSingular(m.value)

# regression predicting honesty rating (for defense draft of QP2)
# maximal random effects without singularity issue 
m.positivity.ctrl <- lmer(responsePositive ~ state*polarity + (1 | adjective) + (1 | workerid), data=d_with_control)
summary(m.positivity.ctrl) 
m.positivity.ctrl.result <- as.data.frame(summary(m.positivity.ctrl)$coefficients) %>%
  round(digits=4) %>%
  mutate(significance = ifelse(`Pr(>|t|)`<0.001, "***", ifelse(`Pr(>|t|)`<0.01,"**", ifelse(`Pr(>|t|)`<0.05,"*", ifelse(`Pr(>|t|)`<=0.1,".","")))))
m.positivity.ctrl.result

latex_m.positivity.ctrl.result <- xtable(m.positivity.ctrl.result, caption = "Mixed-effects linear regression results predicting the positivity rating from fixed effects of state (desirable vs.~undesirable), polarity (positive vs.~negative), and their interaction; by-adjective and by-participant random intercepts were included.", label = "tab:regression-positivity")
print(latex_m.positivity.ctrl.result, include.rownames = TRUE)

# responseState ~ weightedResponsePositive + responseValue
m.rating <- lmer(responseState ~ polarity * negation * weightedResponsePositive * responseValue + (1|adjective), data=d)
summary(m.rating)

# first mean-center variables for interpretability

# Center predictors:
d = d %>%
  mutate(cNegation = as.numeric(negation) - mean(as.numeric(negation)), 
         cPolarity = as.numeric(polarity) - mean(as.numeric(polarity)), 
         cValue = as.numeric(value) - mean(as.numeric(value)), 
         cTargetType = as.numeric(targetType) - mean(as.numeric(targetType)))

summary(d$negation)
summary(d$cNegation)
summary(d$polarity)
summary(d$cPolarity)
summary(d$cValue)
summary(d$cTargetType)
summary(d$adjective)
summary(d$adjectivePair)
summary(d$workerid)

temp <- lmer(responseState100 ~ negation+polarity+value+targetType + (1|workerid), data=d)
# MINIMAL model with just random intercept for adjective
m = lmer(responseState100 ~ negation*polarity*value*targetType + (1|adjective), data=d)
summary(m)
# same but CENTERED
m.c = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1|adjective), data=d)
summary(m.c)

# This is a way of removing correlation between random effects!
# m.c = lmer(RT ~ cFrequency*cNativeLanguage + (1|Subject)  + (0+cFrequency|Subject) + (1|Word) + (0+cNativeLanguage|Word) , data=lexdec, REML=F)

# helper function does not work
# centered = cbind(d, myCenter(d[,c("negation","polarity","value","targetType")]))
# contrasts(centered$negation)
# summary(centered$negation)


# maximal model
# -> number of observations < number of random effects
# lmer(responseState ~ negation*polarity*targetType*value + (1 + negation*polarity*targetType*value | workerid) + (1 + negation*polarity*targetType*value | adjective), data=d)

# random effects of participant without interaction, random effects of adjective with interaction
# -> sigularity issue; failed to converge
# m1 = lmer(responseState ~ negation*polarity*targetType*value + (1 + negation + polarity + targetType + value | workerid) + (1 + negation*polarity*targetType*value | adjective), data=d)

contrasts(d$negation)
contrasts(d$value)
contrasts(d$targetType)
contrasts(d$polarity)
# TODO: Judith - make the reference level as the level expected to have low value


# random effects without interaction 
# -> singularity issue
# m2 = lmer(responseState ~ negation*polarity*targetType*value + (1 + negation + polarity + targetType + value | workerid) + (1 + negation + polarity + targetType + value | adjective), data=d)

# TODO: reduce random slopes for participant -> ???

# random intercepts without random slopes 
# singularity issue
# m3 = lmer(responseState ~ negation*polarity*targetType*value + (1|workerid) + (1|adjective), data=d)

# RANDOM INTERCEPT (targetType)
# random intercepts without random slopes, without workerid
m4 = lmer(responseState ~ negation*polarity*targetType*value + (1|adjective), data=d)
summary(m4)
  # p correction
m4.p <- summary(m4)$coefficients[,5]
m4.p
m4.p.correction <- p.adjust(m4.p, method = "bonferroni")
m4.p.correction
m4.p.corrected <- summary(m4)
m4.p.corrected
m4.p.corrected$coefficients[,5] <- m4.p.correction
m4.p.corrected

  # emmeans
m4.em <- emmeans(m4, ~ negation*polarity*value) %>%
  contrast(method = "pairwise") 
m4.em.ci <- confint(m4.em, level=0.95)
m4.em.df <- as.data.frame(m4.em)
m4.em.df$lower.CL <- m4.em.ci$lower.CL
m4.em.df$upper.CL <- m4.em.ci$upper.CL
m4.em.df <- m4.em.df %>%
  filter(p.value < 0.05) %>%
  droplevels()
ggplot(m4.em.df, aes(x = estimate, y=contrast)) +
  geom_errorbar(aes(xmin = lower.CL, xmax = upper.CL), colour="pink", width=.1, position=position_dodge(0.9)) +
  geom_point(colour="purple") +
  xlab("Difference") +
  ylab("Combination") +
  scale_x_continuous(breaks = c(-1, -0.5, 0, 0.5, 1))

contrasts(d$targetType)
# TODO : isn't `human` the baseline and `thing` a level?

# random slope with interaction, without workerid -> singularity issue
# m5 = lmer(responseState ~ negation*polarity*targetType*value + (1+negation*polarity*targetType*value|adjective), data=d)
# random slope without interaction, without workerid -> singularity issue
# m55 = lmer(responseState ~ negation*polarity*targetType*value + (1+negation+polarity+targetType+value|adjective), data=d)
# random slope w neg, target, value -> failed to converge
# m555 = lmer(responseState ~ negation*polarity*targetType*value + (1+negation+targetType+value|adjective), data=d)
# random slope w neg, value -> sigularity issue
# m5555 = lmer(responseState ~ negation*polarity*targetType*value + (1+negation+value|adjective), data=d)
# random slope only negation -> WORKS
m55555 = lmer(responseState ~ negation*polarity*targetType*value + (1+negation|adjective), data=d)
summary(m55555)
# random slope only value -> WORKS (WINNER)
m555555 = lmer(responseState ~ negation*polarity*targetType*value + (1+value|adjective), data=d)
summary(m555555)

final_model <- as.data.frame(summary(m555555)$coefficients) %>%
  round(digits=4) %>%
  mutate(significance = ifelse(`Pr(>|t|)`<0.001, "***", ifelse(`Pr(>|t|)`<0.01,"**", ifelse(`Pr(>|t|)`<0.05,"*", ifelse(`Pr(>|t|)`<=0.1,".","")))))
  
final_model
summary(final_model)

# latex table
latex_results <- xtable(final_model, caption = "Mixed-effects linear regression results", label = "tab:regression")
print(latex_results, include.rownames = TRUE)

# centered # NOT USE (HARDER TO INTERPRET RESULTS)
# TODO: how are the centered variables coded?
m555555.c = lmer(responseState ~ cNegation*cPolarity*cTargetType*cValue + (1+cValue|adjective), data=d)
summary(m555555.c)

predictions <- data.frame(
  "Condition" = c("was fast (default)", "wasn't fast (default)", "was slow (default)", "wasn't slow (default)", "was fast (reverse)", "wasn't fast (reverse)", "was slow (reverse)", "wasn't slow (reverse)"),
  "Predicted state rating" = c(
    final_model$Estimate[1], # was fast (default)
    final_model$Estimate[1] + final_model$Estimate[2], # wasn't fast (default)
    final_model$Estimate[1] + final_model$Estimate[3], # was slow (default)
    final_model$Estimate[1] + final_model$Estimate[2] + final_model$Estimate[3] + final_model$Estimate[6], # wasn't slow (default)
    final_model$Estimate[1] + final_model$Estimate[5], # was fast (reverse)
    final_model$Estimate[1] + final_model$Estimate[2] + final_model$Estimate[5] + final_model$Estimate[9], # wasn't fast (reverse)
    final_model$Estimate[1] + final_model$Estimate[3] + final_model$Estimate[5] + final_model$Estimate[10], # was slow (reverse)
    final_model$Estimate[1] + final_model$Estimate[2] + final_model$Estimate[3] + final_model$Estimate[5] + final_model$Estimate[6] + final_model$Estimate[9] + final_model$Estimate[10] + final_model$Estimate[13] # wasn't slow (reverse)
    )
)
predictions

latex_predictions <- xtable(predictions, caption = "Predicted state ratings", label = "tab:prediction")
print(latex_predictions, include.rownames = FALSE)


# predictions without targetType; compact format for CogSci
m6_table$Estimate

predictions_noTargetType_compact <- data.frame(
  "Utterance" = c("was fast", "wasn't fast", "was slow", "wasn't slow"),
  "Value scale1" = rep("default", times=4),
  "Prediction1" = c(
    m6_table$Estimate[1], # was fast (default)
    m6_table$Estimate[1] + m6_table$Estimate[2], # wasn't fast (default)
    m6_table$Estimate[1] + m6_table$Estimate[3], # was slow (default)
    m6_table$Estimate[1] + m6_table$Estimate[2] + m6_table$Estimate[3] + m6_table$Estimate[5] # wasn't slow (default)
  ),
  "Value scale2" = rep("reverse", times=4),
  "Prediction2" = c(
    m6_table$Estimate[1] + m6_table$Estimate[4], # was fast (reverse)
    m6_table$Estimate[1] + m6_table$Estimate[2] + m6_table$Estimate[4] + m6_table$Estimate[6], # wasn't fast (reverse)
    m6_table$Estimate[1] + m6_table$Estimate[3] + m6_table$Estimate[4] + m6_table$Estimate[7], # was slow (reverse)
    m6_table$Estimate[1] + m6_table$Estimate[2] + m6_table$Estimate[3] + m6_table$Estimate[4] + m6_table$Estimate[5] + m6_table$Estimate[6] + m6_table$Estimate[7] + m6_table$Estimate[8] # wasn't slow (reverse)
  )
)
predictions_noTargetType_compact
latex_predictions_noTargetType_compact <- xtable(predictions_noTargetType_compact, caption = "Predicted state ratings", label = "tab:prediction")
print(latex_predictions_noTargetType_compact, include.rownames = FALSE)
  
# random slope only polarity -> FAILED TO CONVERGE
# m5555555 = lmer(responseState ~ negation*polarity*targetType*value + (1+polarity|adjective), data=d)
# summary(m5555555)
# random slope only targetType -> SINGULARITY ISSUE
# m55555555 = lmer(responseState ~ negation*polarity*targetType*value + (1+targetType|adjective), data=d)
# summary(m55555555)
# other 2 random slopes don't work either
# SUMMARY: if I have targetType, only one random slope seems to work
AIC(m55555) # negation
AIC(m555555) # value --> a little bit lower --> BETTER (WINNER)

  # emmeans
m5.em <- emmeans(m555555, ~ negation*polarity*value) %>%
  contrast(method = "pairwise") 
m5.em.ci <- confint(m5.em, level=0.95)
m5.em.df <- as.data.frame(m5.em)
m5.em.df$lower.CL <- m5.em.ci$lower.CL
m5.em.df$upper.CL <- m5.em.ci$upper.CL
m5.em.df <- m5.em.df %>%
  # filter(p.value < 0.05) %>%
  # droplevels() %>%
  mutate(contrast = gsub("positive", "fast", contrast)) %>%
  mutate(contrast = gsub("negative", "slow", contrast)) %>%
  mutate(contrast = gsub("default", "(default)", contrast)) %>%
  mutate(contrast = gsub("reverse", "(reverse)", contrast)) %>%
  mutate(contrast = gsub("negation1", "not", contrast)) %>%
  mutate(contrast = gsub("negation0", "", contrast)) %>%
  mutate(contrast = fct_reorder(as.factor(contrast),estimate))
m5.em.df
# full
ggplot(m5.em.df, aes(x = estimate, y=contrast)) +
  geom_errorbar(aes(xmin = lower.CL, xmax = upper.CL), width=.1, position=position_dodge(0.9)) +
  geom_point() +
  xlab("Difference") +
  ylab("Negation, polarity, value scale") +
  scale_x_continuous(n.breaks = 7)
ggsave(file="../graphs/emmeans-full.png",width=6,height=5)

# negative strengthening
ggplot(m5.em.df[c(1,14,23,28,9,11,22,27),], aes(x = estimate, y=contrast)) +
  geom_errorbar(aes(xmin = lower.CL, xmax = upper.CL), width=.1, position=position_dodge(0.9)) +
  geom_point() +
  xlab("Difference") +
  ylab("Negation, polarity, value scale") +
  scale_x_continuous(n.breaks = 6)

# affirmative vs negation (for CogSci) (for QP defense draft)

m5.em.df.ns <- m5.em.df[c(1,14,23,28),] %>%
  mutate(contrast = sub("\\(default\\)\\s-|\\(reverse\\)\\s-", "-", contrast)) %>%
  mutate(contrast = fct_reorder(as.factor(contrast),estimate))
m5.em.df.ns
ggplot(m5.em.df.ns, aes(x = estimate, y=contrast)) +
  geom_errorbar(aes(xmin = lower.CL, xmax = upper.CL), width=.1, position=position_dodge(0.9), color = c(cbPalette[1],cbPalette[1],cbPalette[5],cbPalette[5])) +
  geom_point(color = c(cbPalette[1],cbPalette[1],cbPalette[5],cbPalette[5]), size=5) +
  xlab("Difference") +
  # ylab("Negation, polarity, value scale") +
  theme(axis.title.y = element_blank()) +
  scale_x_continuous(n.breaks = 4)
ggsave(file="../graphs/emmeans-ns.png",width=3,height=2)

# negation
ggplot(m5.em.df[c(9,11,22,27),], aes(x = estimate, y=contrast)) +
  geom_errorbar(aes(xmin = lower.CL, xmax = upper.CL), width=.1, position=position_dodge(0.9)) +
  geom_point() +
  xlab("Difference") +
  ylab("Negation, polarity, value scale") +
  scale_x_continuous(n.breaks = 4)

# affirmative
ggplot(m5.em.df[c(2,4,17,24),], aes(x = estimate, y=contrast)) +
  geom_errorbar(aes(xmin = lower.CL, xmax = upper.CL), width=.1, position=position_dodge(0.9)) +
  geom_point() +
  xlab("Difference") +
  ylab("Negation, polarity, value scale") +
  scale_x_continuous(n.breaks = 4)

# non-pairwise emmeans # NOT USE
m5.em.each <- emmeans(m555555, ~ negation*polarity*value) 
m5.em.each
plot(m5.em.each)

# RANDOM SLOPE (NO targetType)
# random slope without interaction, without workerid, without targetType 
m6 = lmer(responseState ~ negation*polarity*value + (1+negation+value|adjective), data=d)
summary(m6)

m6_table <- as.data.frame(summary(m6)$coefficients) %>%
  # round(digits=3) %>%
  mutate(significance = ifelse(`Pr(>|t|)`<0.001, "***", ifelse(`Pr(>|t|)`<0.01,"**", ifelse(`Pr(>|t|)`<0.05,"*", ifelse(`Pr(>|t|)`<=0.1,".","")))))
m6_table

# latex table
latex_results_no_targetType <- xtable(m6_table, caption = "Mixed-effects linear regression results", label = "tab:regression", digits = 3)
print(latex_results_no_targetType, include.rownames = TRUE)


  # p correction
m6.p <- summary(m6)$coefficients[,5]
m6.p
m6.p.correction <- p.adjust(m6.p, method = "bonferroni")
m6.p.correction
m6.p.corrected <- summary(m6)
m6.p.corrected
m6.p.corrected$coefficients[,5] <- m6.p.correction
m6.p.corrected

  # emmeans
m6.em <- emmeans(m6, ~ negation*polarity*value) %>%
  contrast(method = "pairwise") 
m6.em.ci <- confint(m6.em, level=0.95)
m6.em.df <- as.data.frame(m6.em)
m6.em.df$lower.CL <- m6.em.ci$lower.CL
m6.em.df$upper.CL <- m6.em.ci$upper.CL
m6.em.df <- m6.em.df %>%
  filter(p.value < 0.05) %>%
  droplevels()
ggplot(m6.em.df, aes(x = estimate, y=contrast)) +
  geom_errorbar(aes(xmin = lower.CL, xmax = upper.CL), colour="pink", width=.1, position=position_dodge(0.9)) +
  geom_point(colour="purple") +
  xlab("Difference") +
  ylab("Combination")


# (random slope for polarity -> singularity issue)
m66 = lmer(responseState ~ negation*polarity*value + (1+negation+polarity+value|adjective), data=d)
summary(m66)
# best model with removing corr btwn random effects
m666 = lmer(responseState ~ negation*polarity*value + (1|adjective) + (0+negation+value|adjective), data=d)
summary(m666)

# the best model, with centered independent variables 
# -> did not converge?! singularity issue?!
# m6centered = lmer(responseState ~ cNegation*cPolarity*cValue + (1+cNegation+cValue|adjective), data=d)

# random intercepts without random slopes, exclude targetType 
# -> singularity issue
# m7 = lmer(responseState ~ negation*polarity*value + (1|workerid) + (1|adjective), data=d)

# RANDOM INTERCEPT (NO targetType)
# random intercepts without random slopes & without workerid, exclude targetType
m8 = lmer(responseState100 ~ negation*polarity*value+(1|adjective), data=d)
summary(m8)

# random intercepts without random slopes & without adj, exclude targetType 
# -> singularity issue
# m9 = lmer(responseState ~ negation*polarity*value+(1|workerid), data=d)

# RANDOM SLOPE (targetType) -> failed to converge
# m10 = lmer(responseState ~ negation*polarity*targetType*value + (1+negation+targetType+value|adjective), data=d)

# (removed targetType from random slope) -> failed to converge; singularity issue
# m11 = lmer(responseState ~ negation*polarity*targetType*value + (1+negation+value|adjective), data=d)


# TODO: ?????
m12 = lmer(responseState ~ negation*polarity*value*weightedResponsePositive + (1|adjective), data=d)
summary(m12)


# CENTERED predictors
# TODO: make reference level as lower value (e.g. negation) before mean-centering!!! /////
contrasts(d$negation) # relevel
contrasts(d$polarity)
contrasts(d$value)
contrasts(d$targetType) # relevel


# MINIMAL model with just random intercept for adjective
summary(m.c)

# add 1 random slope
# negation
m.c.neg = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1+cNegation|adjective), data=d)
summary(m.c.neg)
# polarity -> singularity issue, did not converge
# m.c.pol = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1+cPolarity|adjective), data=d)
# value
m.c.val = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1+cValue|adjective), data=d)
summary(m.c.val)
# targetType -> singularity issue
# m.c.tar = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1+cTargetType|adjective), data=d)


# 2 randome slopes 
# negation, value -> singularity issue, did not converge
# m.c.2 = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1+cNegation+cValue|adjective), data=d)
# negation, polarity -> singularity issue
# m.c.2 = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1+cNegation+cPolarity|adjective), data=d)
# polarity, value -> singularity issue
# m.c.2 = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1+cValue+cPolarity|adjective), data=d)

# 1 random slope, remove correlation btwn random effects
# negation
m.c.neg.corr = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1|adjective) + (0+cNegation|adjective), data=d)
summary(m.c.neg.corr)
# value
m.c.val.corr = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1|adjective) + (0+cValue|adjective), data=d)
summary(m.c.val.corr) ### WINNER ###

  # extract p-values & do p correction
p <- summary(m.c.val.corr)$coefficients[,5]
p.correction <- p.adjust(p, method = "bonferroni")
p.correction
regression.results.p.corrected <- summary(m.c.val.corr)
regression.results.p.corrected
regression.results.p.corrected$coefficients[,5] <- p.correction
regression.results.p.corrected
  # fewer sig coefficients

# polarity -> singularity issue; did not converge
# m.c.pol.corr = lmer(responseState100 ~ cNegation*cPolarity*cValue*cTargetType + (1|adjective) + (0+cPolarity|adjective), data=d)

# winner without targetType ### BETTER ###
m.c.val.corr.no.tar = lmer(responseState100 ~ cNegation*cPolarity*cValue + (1|adjective) + (0+cValue|adjective), data=d)
summary(m.c.val.corr.no.tar)
# compare no targetType (nested) vs. winner
anova(m.c.val.corr.no.tar, m.c.val.corr)
# the more complex model WITH targetType is not sig better!!!
# AIC is smaller/better for the smaller model WITHOUT targetType!!!

# making it more complex without targetType
# polarity doesn't work with any other random slope
m.c.val.neg.corr.no.tar = lmer(responseState100 ~ cNegation*cPolarity*cValue + (1|adjective) + (0+cNegation+cValue|adjective), data=d)
summary(m.c.val.neg.corr.no.tar) ### REAL WINNER ###
# compare 1 vs 2 random slopes -> more complex model is better!!
anova(m.c.val.corr.no.tar, m.c.val.neg.corr.no.tar)


# compare negation vs. value
AIC(m.c.neg.corr) # negation
AIC(m.c.val.corr) # value -> slightly better

# in value, compare removing corr vs. not
AIC(m.c.val) # not remove corr
AIC(m.c.val.corr) # remove corr -> slightly better

# no random slope vs. random slope for value
anova_val_rand_slope <- anova(m.c, m.c.val.corr)
print(anova_val_rand_slope) ### WINNER ###
# the one with the random slope for value was better than the one without random slope

# model comparison (targetType): nested model, larger model
anova_targetType <- anova(m8, m4)
print(anova_targetType)
# m8 (smaller model) is better -> remove targetType

# model comparison (workerid): nested model, larger model
# anova_workerid <- anova(m8, m7)
# print(anova_workerid)
# m8 (smaller model) is better
# m7 has sigularity issue, so comparison isn't even necessary

# model comparison (random intercept vs. random slope): nested model, larger model -> m6 wins!!!
anova_randomSlopes <- anova(m8, m6)
print(anova_randomSlopes)
# m6 (larger model) is better

# reason why I discarded targetType is that it doesn't let you have random slope!

isSingular(m8, tol = 1e-4)
