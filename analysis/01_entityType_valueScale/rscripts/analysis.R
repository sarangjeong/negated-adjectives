library(tidyverse)
library(lme4)
library(lmerTest)
library(jsonlite)
library(rwebppl)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("helpers.R")
theme_set(theme_bw())
# color-blind-friendly palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") 

# load model 
code <- read_file("main_model")

# make a function
eval_webppl_main <- function(command) {
  webppl(paste(code,command,sep="\n"))
}

# running a listener/speaker model (arguments defined as in main_model)
listener_twentyfive_a1.0_b0.5_allimp_allhalos_lower_costdiff <- eval_webppl_main("pragmaticListener('twenty-five',1.0,0.5,allimp,allhalos,lowerMeanings,costdiff)")

# listener graph 
graph_listener <- function(data) {
  
  data$prob <- as.numeric(data$prob)
  data$support <-  factor(data$support)
  #  labels = c(expression(20), 
  #             expression(21), expression(22), 
  #             expression(23), expression(24), 
  #             expression(25), expression(26),
  #             expression(27), expression(28),
  #             expression(29), expression(30))
  
  labels = c(20, 
             21, 22, 
             23, 24,
             25, 26,
             27, 28,
             29, 30)
  
  p <- data %>%
    #arrange(x) %>%
    ggplot(aes(x=support,y=prob)) +
    theme_bw() +
    theme(text = element_text(size = base * expand / 2, face = "bold")) +
    geom_bar(stat="identity",position = "dodge") +
    xlab("Value") +
    ylab("Probability") +
    scale_x_discrete(labels = parse(text = labels))
  
  return(p)
  
}

# speaker graph
graph <- function(data) {
  
  data$prob <- as.numeric(data$prob)
  data$support <-  ordered(data$support, levels = c("twenty", "twenty-one", "twenty-two", "twenty-three", "twenty-four", "twenty-five", "twenty-six", "twenty-seven", "twenty-eight", "twenty-nine", "thirty"))
  levels(data$support) <- c("twenty", "twenty-one", "twenty-two", "twenty-three", "twenty-four", "twenty-five", "twenty-six", "twenty-seven", "twenty-eight", "twenty-nine", "thirty")
  
  p <- data %>%
    #arrange(x) %>%
    ggplot(aes(x=support,y=prob)) +
    theme_bw() +
    theme(text = element_text(size = base * expand / 2, face = "bold")) +
    geom_bar(stat="identity",position = "dodge") +
    xlab("Utterance") +
    ylab("Probability") 
  
  return(p)
  
}

# save the plot
p <- graph_listener(listener_twentyfive_a1.0_b0.5_allimp_allhalos_lower_costdiff)
p
ggsave("1-listener-twentyfive-a1.0-b0.5-allimp-allhalos-lower-costdiff.pdf", width = 4, height = 2, units = "in")



# load the main data
d = read_csv("../../../data/01_entityType_valueScale/negated_adjectives-merged-english-attention.csv")
nrow(d)

# load information about contextual features and merge into dataset
# context = read_csv("../../../data/01_implicature_strength/context.csv")
# d = d %>%
#   left_join(context,by=c("id"))

# limit dataset to only target trials
d = d %>% 
  filter(!stimulusType %in% c("example1","example2")) %>% 
  droplevels()
nrow(d)

# exclude control items
d = d %>% 
  filter(!stimulusType == "control") %>% 
  droplevels()
nrow(d)

# exclude continue without response
d = d %>% 
  filter(!(responseState==0.5 & responseValue==0.5 & responseHonest==0.5 & responsePositive==0.5)) %>% 
  droplevels()
nrow(d)

# create weighted intentions
d = d %>%
  mutate(weightedResponseHonest = ifelse(responseHonest + responsePositive > 0, responseHonest / (responseHonest + responsePositive), 0)) %>%
  mutate(weightedResponsePositive = ifelse(responseHonest + responsePositive > 0, responsePositive / (responseHonest + responsePositive), 0))

# adjust responseValue to -1 ~ 1
d = d %>% 
  mutate(adjustedResponseValue = (responseValue - 0.5) * 2 )
View(d)

# change independent variables into factors
d$negation = as.factor(as.character(d$negation))
d$polarity = as.factor(as.character(d$polarity))
d$targetType = as.factor(as.character(d$targetType))
d$value = as.factor(as.character(d$value))

# change participant & adjective into factors too??
d$workerid = as.factor(as.character(d$workerid))
d$adjective = as.factor(as.character(d$adjective))

# change baselines
d$polarity <- factor(d$polarity, levels = c("positive", "negative"))
d$targetType <- factor(d$targetType, levels = c("thing", "human"))
d$value <- factor(d$value, levels = c("normal", "flipped"))
d$negation <- factor(d$negation, levels = c("0", "1"))
contrasts(d$negation)
contrasts(d$polarity)


# correlation between intention and state

# only negated positive in normal context
d_normal_negated_positive = d %>%
  filter(value=="normal" & negation=="1" & polarity=="positive") %>%
  droplevels()

# effect of relative weight of positivity
plot(d_normal_negated_positive$weightedResponsePositive, d_normal_negated_positive$responseState)
# effect of relative weight of hoensty
plot(d_normal_negated_positive$weightedResponseHonest, d_normal_negated_positive$responseState)
# effect of raw weight of positivity
# plot(d_normal_negated_positive$responsePositive, d_normal_negated_positive$responseState)
# effect of raw weight of hoensty
# plot(d_normal_negated_positive$responseHonest, d_normal_negated_positive$responseState)

# relative positivity has weak POSITIVE effect
cor.test(d_normal_negated_positive$weightedResponsePositive, d_normal_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# relative honesty (redundant)
# cor.test(d_normal_negated_positive$weightedResponseHonest, d_normal_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# raw positivity is insignificant
# cor.test(d_normal_negated_positive$responsePositive, d_normal_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# raw honesty has weak NEGATIVE effect
cor.test(d_normal_negated_positive$responseHonest, d_normal_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))


# only positive in normal context
d_normal_positive = d %>%
  filter(value=="normal" & polarity=="positive") %>%
  droplevels()

# effect of negation on relative weight of positivity
plot(d_normal_positive$negation, d_normal_positive$weightedResponsePositive)
# effect of negation on relative weight of hoensty
plot(d_normal_positive$negation, d_normal_positive$weightedResponseHonest)
# effect of negation on raw positivity
plot(d_normal_positive$negation, d_normal_positive$responsePositive)
# effect of negation on raw hoensty
plot(d_normal_positive$negation, d_normal_positive$responseHonest)



# only normal context
d_normal = d %>%
  filter(value=="normal") %>%
  droplevels()

# TODO: 

# relative positivity has weak POSITIVE effect
cor.test(d_normal_negated_positive$weightedResponsePositive, d_normal_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# relative honesty (redundant)
# cor.test(d_normal_negated_positive$weightedResponseHonest, d_normal_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# raw positivity is insignificant
# cor.test(d_normal_negated_positive$responsePositive, d_normal_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))
# raw honesty has weak NEGATIVE effect
cor.test(d_normal_negated_positive$responseHonest, d_normal_negated_positive$responseState, method=c("pearson", "kendall", "spearman"))



# there's all kinds of demographic info we might want to plot, but let's head straight for the meaty bit

# TODO

# aggregate by groups of interest
agr_ns = d %>% 
  group_by(polarity, negation) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))

dodge = position_dodge(.9)
ggplot(agr_ns, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") 



agr_ns_targetType = d %>% 
  group_by(polarity, negation, targetType) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))

dodge = position_dodge(.9)
ggplot(agr_ns_targetType, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_wrap(~targetType)





dodge = position_dodge(.9)

# full plot

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
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(targetType~value)
ggsave(file="../graphs/full.png",width=6,height=4)



# Is responseValue a negative value in flipped context?
agr_value = d %>% 
  group_by(value) %>% 
  summarise(mean = mean(responseValue),
            CILow = ci.low(responseValue),
            CIHigh = ci.high(responseValue)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         #negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         #polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )

ggplot(agr_value, aes(x=value, y=mean, fill=value))+ #fill=negation
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Value context") +
  xlab("Value context") +
  ylab("Mean value rating")
  #facet_grid(.~targetType)


# What affects relative weight of positivity? value = normal, (negation = 1)
View(d)
agr_positivity = d %>% 
  filter(value=="normal") %>%
  droplevels() %>%
  group_by(polarity, negation, targetType) %>% 
  summarise(mean = mean(weightedResponsePositive),
            CILow = ci.low(weightedResponsePositive),
            CIHigh = ci.high(weightedResponsePositive)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"),
         polarity = fct_recode(polarity, "good" = "positive", "bad" = "negative")
  )

View(agr_positivity)

ggplot(agr_positivity, aes(x=negation, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Negation") +
  ylab("Relative importance of positivity") +
  facet_grid(polarity~targetType)

ggplot(agr_positivity, aes(x=negation, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Negation") +
  ylab("Relative importance of positivity") +
  facet_grid(polarity~targetType)


# negative strengthening plot

agr_ns = d %>% 
  filter(!(value=="flipped")) %>% 
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
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating")
ggsave(file="../graphs/negative_strengthening.png",width=4,height=3.2)



# --by item
agr_item = d %>% 
filter(!(value=="flipped")) %>% 
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
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(targetType~item)


# positivity by item/////
agr_positivity_item = d %>% 
  filter(!(value=="flipped")) %>% 
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
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(targetType~item)



# by time

agr_time = d %>% 
  group_by(workerid) %>%
  mutate(time = ifelse(row_number() <= 4, "first_half", "second_half")) %>%
  filter((value=="normal")) %>% 
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
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(.~time)



# by specific participant # TODO
agr_participant = d %>% 
  filter((value=="normal" & workerid=="101")) %>% 
  group_by(polarity, negation, workerid) %>% 
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
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(.~workerid)



# normal vs flipped plot
agr_value = d %>% 
  group_by(polarity, negation, value) %>% 
  summarise(mean = mean(responseState),
            CILow = ci.low(responseState),
            CIHigh = ci.high(responseState)) %>%
  ungroup() %>%
  mutate(YMin = mean - CILow,
         YMax = mean + CIHigh, 
         negation = fct_recode(negation, "not adj" = "1", "adj" = "0"))

ggplot(agr_value, aes(x=polarity, y=mean, fill=negation))+
  geom_bar(stat="identity", position=dodge) +
  geom_errorbar(aes(ymin=YMin, ymax=YMax), position=dodge, width=.2) +
  scale_fill_manual(values=cbPalette, name="Adjectival form") +
  xlab("Adjectival polarity") +
  ylab("Mean state rating") +
  facet_grid(.~value)

ggsave(file="../graphs/value.png",width=6,height=3.2)


View(agr_ns)

agr_targetType = d %>% 
  group_by(polarity, negation, targetType) %>% 
  summarise(mean = mean(responseState))

View(agr_targetType)

agr_targetType_value = d %>% 
  group_by(polarity, negation, targetType, value) %>% 
  summarise(mean = mean(responseState))

View(agr_targetType_value)

agr_value = d %>% 
  group_by(polarity, negation, value) %>% 
  summarise(mean = mean(responseState))
View(agr_value)


ggplot(agr_ns, aes(x = interaction(negation, polarity), y=mean)) +
  geom_bar(stat = "identity") +
  xlab("negation X polarity") +
  ylab("responseState") +
  labs(title = "Negative Strengthening")

ggplot(agr_targetType, aes(x = interaction(negation, polarity, targetType), y=mean)) +
  geom_bar(stat = "identity") +
  xlab("negation X polarity X targetType") +
  ylab("responseState") +
  labs(title = "Human vs Thing")

# Too complicated
ggplot(agr_targetType_value, aes(x = interaction(negation, polarity, targetType, value), y=mean)) +
  geom_bar(stat = "identity") +
  xlab("negation X polarity X targetType X value") +
  ylab("responseState") +
  labs(title = "Human vs Thing, Normal vs Flipped")

ggplot(agr_value, aes(x = interaction(negation, polarity, value), y=mean)) +
  geom_bar(stat = "identity") +
  xlab("negation X polarity X value") +
  ylab("responseState") +
  labs(title = "Normal vs Flipped")





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


# To run the regression reported in Degen 2015:


# first mean-center variables for interpretability
# TODO : do I need to do this? I have binary varibles only 
centered = cbind(d, myCenter(d[,c("strengthSome","logSentenceLength","subjecthood","partitive")]))

# maximal model: number of random effects > number of main(?) effects
# m = lmer(responseState ~ negation*polarity*targetType*value + (1 + negation*polarity*targetType*value | workerid) + (1 + negation*polarity*targetType*value | adjective), data=d)

# random effects of participant without interaction, random effects of adjective with interaction -> TODO (it must have singularity issue too)
# m1 = lmer(responseState ~ negation*polarity*targetType*value + (1 + negation + polarity + targetType + value | workerid) + (1 + negation*polarity*targetType*value | adjective), data=d)
# summary(m1)

# random effects without interaction -> boundary (singular) fit: see ?isSingular (singularity issue)
# m2 = lmer(responseState ~ negation*polarity*targetType*value + (1 + negation + polarity + targetType + value | workerid) + (1 + negation + polarity + targetType + value | adjective), data=d)
# summary(m2)

# TODO: reduce random slopes for participant

# random intercepts without random slopes -> boundary (singular) fit: see ?isSingular (singularity issue)
# m3 = lmer(responseState ~ negation*polarity*targetType*value + (1|workerid) + (1|adjective), data=d)
# summary(m3)

# random intercepts without random slopes, without workerid
m4 = lmer(responseState ~ negation*polarity*targetType*value + (1|adjective), data=d)
summary(m4)

contrasts(d$polarity)
contrasts(d$negation)
contrasts(d$targetType)
contrasts(d$value)

# random slope with interaction, without workerid -> singularity issue
# m5 = lmer(responseState ~ negation*polarity*targetType*value + (1+negation*polarity*targetType*value|adjective), data=d)
# summary(m5)

# random slope without interaction, without workerid, without targetType (no random slope for polarity bc it makes no sense)
m6 = lmer(responseState ~ negation*polarity*value + (1+negation+value|adjective), data=d)
summary(m6)

# random intercepts without random slopes, exclude targetType -> singularity issue
m7 = lmer(responseState ~ negation*polarity*value + (1|workerid) + (1|adjective), data=d)
summary(m7)

# random intercepts without random slopes & without workerid, exclude targetType
m8 = lmer(responseState ~ negation*polarity*value+(1|adjective), data=d)
summary(m8)

# random intercepts without random slopes & without adj, exclude targetType
m9 = lmer(responseState ~ negation*polarity*value+(1|workerid), data=d)
summary(m9)


# model comparison (targetType): nested model, larger model
anova_targetType <- anova(m8, m4)
print(anova_targetType)

# model comparison (workerid): nested model, larger model
anova_workerid <- anova(m8, m7)
print(anova_workerid)

# model comparison (random intercept vs. random slope): nested model, larger model -> m6 wins!!!
anova_randomSlopes <- anova(m8, m6)
print(anova_randomSlopes)
      
isSingular(m6, tol = 1e-4)
