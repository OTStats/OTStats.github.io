
# -- Load libraries
library(tidyverse)

df <- read_csv("Downloads/UDisc Scorecards.csv") %>% 
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

long_df %>% 
  filter(player_name != "Par") %>% 
  left_join(par_df, 
            by = c("course_name", "layout_name", "date", "hole"))

            
