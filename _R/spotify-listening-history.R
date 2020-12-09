library(tidyverse)
library(jsonlite)
library(lubridate)

part_a <- fromJSON("~/Downloads/MyData/StreamingHistory0.json", flatten = TRUE)
part_b <- fromJSON("~/Downloads/MyData/StreamingHistory1.json")

spotify <- bind_rows(part_a, part_b) %>% 
  as_tibble() %>% 
  mutate_at("endTime", ymd_hm) %>% 
  mutate(date = floor_date(endTime, "day") %>% as_date, 
         seconds = msPlayed / 1000, 
         minutes = seconds / 60)

spotify %>% 
  ggplot(aes(x = seconds)) + 
  geom_histogram()


spotify %>% 
  filter(date >= "2019-10-01") %>% 
  group_by(date) %>% 
  # group_by(date = floor_date(date, "week")) %>% 
  summarize(hours = sum(minutes) / 60) %>% 
  arrange(date) %>% 
  ggplot(aes(x = date, y = hours)) + 
  geom_col()
