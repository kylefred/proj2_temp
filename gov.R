---
title: "Investigating the Potential Blue Wave in the 2018 Governor Elections"
author: "Kyle Grosser"
date: "10/20/2018"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
options(scipen = 10)

source("fun.R")

library(tidyverse)
library(knitr)
library(cowplot)
```

Given the divisive presidency of Republican Donald Trump, some American citizens are expecting a so-called "Blue Wave," an electoral landslide for the Democratic Party, to take place in the 2018 midterms. Using data from FiveThirtyEight, we look at whether the supposed "Blue Wave" is expected to take place within the gubernatorial landscape of the midterm elections.

```{r, warning=F}
# data on current governorships
current <- read.csv("current-gov.csv")

# number of governors from each party
cur.D <- num.party(current,'D')
cur.R <- num.party(current,'R')
```

As it stands now, there are `r cur.D` Democratic governors, `r cur.R` Republican governors, and `r 50 - cur.D - cur.R` Independent governor. In the 2018 midterms, there are 36 gubernatorial elections taking place across the US (in the other 14 states, these seats are not up for reelection). Using the data obtained form FiveThirtyEight, we look only at the most recent polls (as of 10/20/2018) and then only at the two candidates with the highest chance of winning, according to the dataset.

```{r, warning = F}
# data on 2018 governor races
GOV <- read.csv("governors.csv") %>%
  filter(model == "classic") %>%
  select(-district, -special, -model, -voteshare, -p10_voteshare, -p90_voteshare)

# states with governor elections in 2018
states <- unique(GOV$state)

# dataframe for top 2 candidates from each state
top2.df <- data.frame()
for (i in seq_along(states)) 
  top2.df <- rbind(top2.df,topx(GOV,1:2,states[i]))

# show first 6 lines
top2.df.t <- top2.df
colnames(top2.df.t) <- c("Forecast Date", "State", "Candidate", 
                         "Party", "Incumbent", "Chance of Winning")
kable(head(top2.df.t))
```

Using this data, we now want to compare the chance of winning for the top two candidates in each state.

```{r fig1, fig.align='center', fig.height=7, fig.width=10}
# first 18 states, latter 18 states
plot1 <- plot.prob(top2.df,1,18)
plot2 <- plot.prob(top2.df,19,36)

# plot in grid
plot_grid(plot1,plot2)
```

If we simply compare chances of winning for the top two candidates, we can see the number of governor races each of the two major parties is expected to win. 

```{r}
# top candidate from each state
top1.df <- data.frame()
for (i in seq_along(states)) 
  top1.df <- rbind(top1.df,topx(GOV,1,states[i]))

# this helps later
current[,2] <- factor(current[,2], levels = levels(top1.df[,4]))

# number of states with D in lead
win.D <- num.party(top1.df,'D')

# number of states with R in lead
win.R <- num.party(top1.df,'R')
```

By this estimation, the Democrats are expected to win `r win.D` governorships and the Republicans are expected to win `r win.R`. Given the 14 states with governor seats not up for election, which are evenly split between Democrat and Republican, this means we expect to see `r win.D + 7` Democratic governors and `r win.R + 7` Republican governors following the 2018 midterms. While this is not the Democratic majority those anticipating the "Blue Wave" may hope for, it is certainly an increase from the current `r cur.D`:`r cur.R` split. Let's look at which states are predicted to flip in this regard:

```{r,warning=F}
# States with different expected party than current party
flip.df <- left_join(top1.df,current,by="state") %>%
  mutate(flip = (party.x != party.y)) %>%
  filter(flip) %>%
  select(state,party.y,party.x)

colnames(flip.df) <- c("State Expected to Flip","Current Party","Party Expected to Win")

kable(flip.df)
```

We can see from the table above that Florida, Iowa, Illinois, Maine, Michigan, New Mexico, and Wisconsin are expected to flip from Republican to Democrat, and Arkansas is expected to lose its independent governor in favor of a Republican. This aligns perfectly with the numbers we see above; Democrats are expected to gain 7, whereas Republicans are expected to lose those 7 seats to Democrats but nonetheless gain one seat from an independent.

Finally, let's examine whether the model used by FiveThirtyEight to generate this dataset takes into consideration the so-called "Incumbent Effect," whereby incumbents typically have a much higher chance of winning an election than an unelected challenger. 

```{r}
# Incumbent chance of winning
incumb <- top1.df %>% 
  filter(incumbent == "true") %>%
  select(win_probability, incumbent, candidate)

# Challenger chance of winning
newbie <- top1.df %>%
  filter(incumbent == "false") %>%
  select(win_probability, incumbent, candidate)

# dataframe for boxplot
df.box <- rbind(incumb,newbie)

# rank sum test
wrs.results <- wilcox.test(incumb[,1],newbie[,1],alternative = "greater")
```


```{r fig2, fig.align='center', fig.height=5.25, fig.width=7.5}
# boxplot
ggplot(df.box, aes(incumbent, win_probability)) +
  geom_boxplot() +
  geom_jitter(aes(color = incumbent), alpha = 0.4) +
  labs(x = "Incumbent?", y = "Probability of Winning", 
       title = "Probability of Winning Given Incumbency") +
  scale_color_manual(values=c("blue", "red")) +
  theme_bw()
```

Using a comparative boxplot, we examine the distributions of the chance of winning for those leading the polls in their respective states, based on whether they are an incumbent. We consider only those leading the polls so as to remove the dependency between opponents. It certainly appears that incumbents typically have a higher chance of winning. 

In fact, the results of a Wilcoxon Rank Sum test suggests this may be the case. If we denote the distributions of incumbent chance of winning $F_i$ and non-incumbent chance of winning $F_c$, we conduct this test with hypotheses $H_0: F_i = F_c$ and $H_A: F_i \gt F_c$. The p-value for this test is `r signif(wrs.results$p.value,3)`, which suggests that there is a significant difference between the chance of winning for incumbents compared to non-incumbents according to the FiveThirtyEight model.

In summation, we see that although the anticipated "Blue Wave" may not lead to a Democratic majority of governorships, we are likely to see a significant number of states flip from Republican governors to Democratic ones. Specifically, according to this model, we may see the number of Democratic governors increase from 16 to 23 in the coming midterms. Though not a majority, this is nonetheless quite a jump, especially given the strength of the incumbency effect that we observe. It's possible that the divisive Trump administration has motivated many left-leaning Americans to take to the polls in November. 
