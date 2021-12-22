
library(tidyverse)


set.seed(3); 
base_df <- tibble(team = sample(c("a", "b"), size = 10, replace = TRUE), 
       goal = 1) %>% 
  mutate(id = row_number(), 
         score_a = if_else(team == "a", goal, 0), 
         score_a = cumsum(score_a), 
         score_b = if_else(team == "b", goal, 0), 
         score_b = cumsum(score_b)) %>% 
  add_row(team = "a", id = 0, score_a = 0, score_b = 0) %>%
  add_row(team = "b", id = 0, score_a = 0, score_b = 0) %>%
  arrange(id) %>% 
  mutate(team_curr_score = if_else(team == "a", score_a, score_b), 
         team_prev_score = if_else(team == "a", 
                                   lag(score_a, default = 0), 
                                   lag(score_b, default = 0)), 
         # opp_prev_score = if_else(team == "a", 
         #                          lag(score_b, default = 0), 
         #                          lag(score_a, default = 0)), 
         opp_curr_score = if_else(team == "a", score_b, score_a))


base_df %>% 
  select(team, id, team_curr_score:opp_curr_score) %>% 
  pivot_longer(cols = c("team_curr_score", "team_prev_score", "opp_curr_score")) %>% 
  mutate(x = case_when(team == "a" & str_detect(name, "team") ~ 1, 
                       team == "a" & str_detect(name, "opp") ~ 0, 
                       team == "b" & str_detect(name, "team") ~ 0, 
                       team == "b" & str_detect(name, "opp") ~ 1)) %>% 
  ggplot(aes(fill = team)) + 
  geom_polygon(aes(x = x, y = value, group = id), color = "#000000")
