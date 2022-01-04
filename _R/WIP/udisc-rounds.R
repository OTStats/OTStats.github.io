

# -- Load libraries
library(tidyverse)
install.packages("ggheatmap")
source("https://raw.githubusercontent.com/iascchen/VisHealth/master/R/calendarHeat.R")
# Time Series Calendar Maps:
# http://www.columbia.edu/~sg3637/blog/Time_Series_Heatmaps.html

df <- read_csv("~/Downloads/UDisc Scorecards (1).csv") %>% 
  janitor::clean_names()

long_df <- df %>% 
  pivot_longer(cols = contains("hole"), 
               names_to = "hole", 
               values_to = "score") %>% 
  mutate(hole = str_remove(hole, "hole") %>% as.double()) %>% 
  filter(!is.na(score)) %>% 
  select(-c(x, total))

par_df <- long_df %>% 
  filter(player_name == "Par") %>% 
  rename(par = score) %>% 
  select(-player_name)

long_score_df <- long_df %>% 
  filter(player_name != "Par") %>% 
  left_join(par_df, 
            by = c("course_name", "layout_name", "date", "hole"))

date_count <- df %>% 
  filter(str_detect(player_name, "OT|Owen")) %>% 
  group_by(date = lubridate::as_date(date)) %>% 
  count()

summary_score_df <- long_score_df %>% 
  filter(str_detect(player_name, "OT|Owen")) %>% 
  filter(score != 0) %>% 
  mutate(diff = score - par) %>% 
  group_by(date = lubridate::as_date(date)) %>% 
  summarize(sum_diff = sum(diff))


calendarHeat(dates = date_count$date, 
             values = date_count$n, 
             color = "r2b", 
             ncolors = 2, 
             varname = "Disc Golf Rounds")
calendarHeat(dates = summary_score_df$date, 
             values = summary_score_df$sum_diff, 
             color = "r2b", 
             ncolors = 5, 
             varname = "Scores")
