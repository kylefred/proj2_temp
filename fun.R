# count number items in df.t with party p
num.party <- function(df.t, p) {
	n <- df.t %>%
 	count(party == p) %>%
 	.[[2,2]]
  
  return(n)
}

# function to obtain top x candidate(s) from dataframe df at certain forecast date
topx <- function(df, x, state.t, forecast.t = "2018-10-20") {
  df.t <- df %>% 
    filter(state == state.t, forecastdate == forecast.t) %>%
    arrange(desc(win_probability)) %>%
    .[x,]
  return(df.t)
}

# flipped bar chart comparing top two candidates in states a through b (numbers)
plot.prob <- function(df.t, a, b) {
  pos1 = 2*a - 1
  pos2 = 2*b
  state1 = df.t$state[pos1]
  state2 = df.t$state[pos2]
  x <- seq(pos1,pos2)
  plot.t <- ggplot(df.t[x,], aes(state, win_probability, fill=party)) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(x = "State", y = "Probability of Winning", 
         title = paste("Top Two Candidates in States",state1,"Through",state2)) +
    scale_fill_manual(values=c("blue", "red")) +
    geom_hline(yintercept = 0.5, alpha = 0.5) +
    coord_flip() +
    theme_bw()
  
  return(plot.t)
}