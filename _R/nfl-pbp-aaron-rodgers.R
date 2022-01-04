
# -- Load libraries
install.packages(c("nflfastR", "furrr"))
library(tidyverse)
library(nflfastR)
library(furrr)  # required for parallel processing for `nflfastR::fast_scraper`

# future::plan("multisession")  # Use this for parallel processing

# -- Get Green Bay games from 2005 to present
gb_results <- fast_scraper_schedules(2005:2021) %>% 
  filter(away_team == "GB" | home_team == "GB")

gb_pbp <- gb_results %>% 
  pull(game_id) %>% 
  fast_scraper()

beepr::beep()

aaron_td <- gb_pbp %>% 
  filter(passer_player_name == "A.Rodgers", 
         td_team == "GB", 
         pass_touchdown == 1) #%>% 
  filter(season_type == "REG")

gb_results %>% 
  transmute(game_id, 
            season, 
            gameday, 
            weekday, 
            opponent = if_else(home_team == "GB", away_team, home_team))

aaron_td

aaron_td %>% 
  ggplot(aes(x = air_yards, y = yards_after_catch)) + 
  geom_point()

# vars:
# - air_yards
# - yards_after_catch


aaron_td %>% 
  count(receiver_player_name, sort = T)

# aaron_td %>% 
#   group_by( = receiver_player_name) %>% 
#   summarize(n_seasons = n_distinct(season), 
#             seasons = str_c(min(season), "-", max(season)), 
#             touchdowns = n()) %>% 
#   arrange(desc(touchdowns))
