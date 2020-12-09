library(tidyverse)
install.packages(c("nflfastR", "furrr"))
library(nflfastR)
library(furrr)  # required for parallel processing for `nflfastR::fast_scraper`

gb_results <- fast_scraper_schedules(2005:2020) %>% 
  filter(away_team == "GB" | home_team == "GB")

gb_pbp <- gb_results %>% 
  pull(game_id) %>% 
  fast_scraper(pp = TRUE)

aaron_td <- gb_pbp %>% 
  filter(passer_player_name == "A.Rodgers", 
         td_team == "GB", 
         pass_touchdown == 1) %>% 
  filter(season_type == "REG")


aaron_td %>% 
  ggplot(aes(x = air_yards, y = yards_after_catch)) + 
  geom_point()

# vars:
# - air_yards
# - yards_after_catch


aaron_td %>% 
  count(receiver_player_name, sort = T)

rodgers %>% 
  group_by(receiver) %>% 
  summarize(n_seasons = n_distinct(season), 
            seasons = str_c(min(season), "-", max(season)), 
            touchdowns = n()) %>% 
  arrange(desc(touchdowns))