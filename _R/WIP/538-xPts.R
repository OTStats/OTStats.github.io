# Load Packages
library(tidyverse)
# Read Data
spi_raw <- read_csv("https://projects.fivethirtyeight.com/soccer-api/club/spi_matches.csv")
glimpse(spi_raw)


matches <- spi_raw %>% 
  transmute(date, 
            league, 
            league_id, 
            team = team1, 
            spi = spi1, 
            opponent = team2, 
            teamGoal = score1, 
            oppGoal = score2, 
            result = case_when(score1 > score2  ~ "W", 
                               score1 < score2  ~ "L", 
                               score1 == score2 ~ "D"), 
            prob_win = prob1, 
            prob_draw = probtie, 
            prob_lose = prob2, 
            ha = "Home") %>% 
  bind_rows(
    spi_raw %>% 
      transmute(date, 
                league, 
                league_id, 
                team = team2, 
                spi = spi2, 
                opponent = team1, 
                teamGoal = score2, 
                oppGoal = score1, 
                result = case_when(score1 < score2  ~ "W", 
                                   score1 > score2  ~ "L", 
                                   score1 == score2 ~ "D",), 
                prob_win = prob2, 
                prob_draw = probtie, 
                prob_lose = prob1, 
                ha = "Away")) %>% 
  mutate(game_goal_diff = teamGoal - oppGoal) %>% 
  mutate(result_points = case_when(result == "W" ~ 3, 
                                   result == "D" ~ 1, 
                                   TRUE ~ 0))
glimpse(matches)



matches %>% 
  filter(team %in% c("Atletico Madrid", 
                     "Barcelona", 
                     "Real Madrid")) %>% filter(max(date) == date)
  ggplot(aes(x = date, 
             y = spi)) + 
  geom_step(aes(color = team), direction = "hv")


matches %>% 
  filter(date > "2018-07-01", league_id == 1845) %>% 
  ggplot(aes(x = teamGoal)) + 
  geom_bar() + 
  facet_wrap(~team)





matches %>% 
  filter(date < "2017-07-01", 
         league_id == 1869) %>% 
  arrange(date) %>% 
  group_by(team) %>% 
  mutate(matchday = row_number()) %>% 
  rowwise() %>% 
  mutate(pts = case_when(
    result == "W" ~ 3, 
    result == "D" ~ 1, 
    result == "L" ~ 0), 
    xPts = sum(prob_win * 3, prob_draw * 1),) -> temp

temp %>% 
  group_by(team) %>% 
  mutate(cumxPts = cumsum(xPts), 
         cumPts = cumsum(pts)) -> xPtsLiga
xPtsLiga %>% 
  ggplot(aes(x = matchday)) + 
  geom_area(aes(y = cumxPts), alpha = 0.5) + 
  geom_line(aes(y = cumPts), size = 1) + 
  facet_wrap(~team) + 
  labs(title = "2018/19 La Liga: Cumulative Points vs. Expected Points", 
       subtitle = "Expected Points = Shaded Area | Actual Points = Line | Created by @OTStats",
       caption = "Data: FiveThirtyEight.com", 
       x = "Matchday", 
       y = "Cumulative Pts")
