library(tidyverse)
library(jsonlite)
library(lubridate)

streaming_part_a <- fromJSON("~/Downloads/MyData/StreamingHistory0.json", flatten = TRUE)
streaming_part_b <- fromJSON("~/Downloads/MyData/StreamingHistory1.json", flatten = TRUE)

spotify <- bind_rows(streaming_part_a, streaming_part_b) %>% 
  as_tibble() %>% 
  mutate_at("endTime", ymd_hm) %>% 
  mutate(endTime = endTime - hours(6)) %>% 
  mutate(date = floor_date(endTime, "day") %>% as_date, 
         seconds = msPlayed / 1000, 
         minutes = seconds / 60)


spotify %>% 
  ggplot(aes(x = seconds)) + 
  geom_histogram()


spotify %>% 
  filter(date >= "2019-10-01") %>% 
  group_by(date) %>% 
  group_by(date = floor_date(date, "week")) %>%
  summarize(hours = sum(minutes) / 60) %>% 
  arrange(date) %>% 
  ggplot(aes(x = date, y = hours)) + 
  geom_col()

# install.packages("gghighlight")
library(gghighlight)
spotify %>% 
  group_by(artistName, date = floor_date(date, "month")) %>% 
  summarize(hours = sum(minutes) / 60) %>% 
  # filter(any(hours > 5))
  ggplot(aes(x = date, 
             y = hours, 
             group = artistName)) + 
  geom_line() + 
  gghighlight(artistName == "The Spanish Football Podcast")

spotify %>% 
  group_by(artistName, date = floor_date(date, "month")) %>% 
  summarize(hours = sum(minutes) / 60)

spotify %>% 
  filter(date >= "2020-01-01") %>% 
  group_by(trackName, artistName) %>% 
  summarize(minutes_listened = sum(minutes)) %>% 
  arrange(desc(minutes_listened))


spotify %>% 
  filter(date >= "2020-01-01") %>% 
  group_by(date, hour = hour(endTime)) %>% 
  summarize(minutes_listened = sum(minutes)) %>% 
  ggplot(aes(x = hour, y = date, fill = minutes_listened)) + 
  geom_tile() + 
  scale_fill_gradient2()


hours_df <- spotify %>% 
  filter(date >= "2020-01-01") %>% 
  group_by(date, hour = hour(endTime), weekday = wday(date, label = TRUE))%>% 
  summarize(minutes_listened = sum(minutes))

hours_df %>% 
  ggplot(aes(x = hour, y = minutes_listened, group = date)) + 
  geom_col(alpha = .9)

hours_df %>% 
  group_by(weekday, hour) %>% 
  summarize(minutes = sum(minutes_listened)) %>% 
  ggplot(aes(x = hour, weekday, fill = minutes)) + 
  geom_tile() + 
  scale_fill_gradient2()

hours_df %>% 
  group_by(weekday, hour) %>% 
  summarize(minutes = sum(minutes_listened)) %>% 
  ggplot(aes(x = hour, y = minutes, color = weekday)) + 
  geom_line() 

hours_df %>% 
  mutate(day_type = if_else(weekday %in% c("Sat", "Sun"), "weekend", "weekday")) %>% 
  group_by(day_type, hour) %>% 
  summarize(minutes = sum(minutes_listened)) %>% 
  ggplot(aes(x = hour, y = minutes, color = day_type)) + 
  geom_line() 
  # facet_grid(.~weekday)


# ------.


music <- spotify %>% 
  filter(str_detect(artistName, "1975|Catfish|Machine Gun")) %>% 
  janitor::clean_names()

music_feat_raw <- music %>% 
  distinct(artist_name) %>% 
  pull(artist_name) %>% 
  map_df(~get_spotify_artist(.))
music_feat <- music_feat_raw %>% 
  group_by(artist_name, track_name) %>% 
  filter(row_number() == 1) %>% 
  ungroup() %>% 
  select(artist_name, 
         track_name, 
         album_name, 
         danceability:loudness, 
         speechiness:tempo, 
         duration_ms, 
         explicit)

music %>% 
  left_join(music_feat) %>% View()
