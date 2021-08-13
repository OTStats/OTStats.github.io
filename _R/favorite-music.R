# References
# https://twitter.com/NerdyWithData/status/1258251929601413120
# https://github.com/NerdyWithData/tidytuesday/blob/master/2020w19%20-%20Animal%20Crossing/2020w19%20-%20Animal%20Crossing.R
# https://towardsdatascience.com/rip-wordclouds-long-live-chatterplots-e76a76896098
# https://msmith7161.github.io/what-is-speechiness/
# https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/
# https://github.com/charlie86/spotifyr


# ---- Load libraries
library(tidyverse)


# ----- Read music data
nineteen <- readRDS("Projects/the-nineteen-seventy-five-music.RDS")
struts <- readRDS("Projects/the-struts-music.RDS")
mumford <- readRDS("Projects/mumford-and-sons-music.RDS")
luke <- readRDS("Projects/luke-combs-music.RDS")
catfish <- readRDS("Projects/catfish-and-the-bottlemen-music.RDS")

music <- bind_rows(luke, mumford, nineteen, struts, catfish) %>% 
  mutate(ablum_name = fct_reorder(album_name, album_release_year))

# ---- Data viz ----.

# Density ridges of artist valence by album
library(ggridges)
library(ggthemes)
music %>% 
  ggplot(aes(x = valence, y = fct_reorder(album_name, album_release_year, .desc = T))) + 
  geom_density_ridges_gradient(scale = 0.75) + 
  scale_y_discrete(labels = function(x) str_wrap(x, width = 30)) + 
  theme_fivethirtyeight() + 
  xlim(0,1) +
  facet_wrap(~artist_name, scales = "free") + 
  theme_ridges() + 
  ylab("") + 
  theme(legend.position = "none")

# -- Sonic score
# Compare artists and albums
music %>% 
  mutate(sonic_score = valence + danceability + energy) %>% 
  ggplot(aes(x = fct_reorder(album_name, album_release_year), y = sonic_score)) + 
  geom_boxplot(alpha = 0) + 
  geom_jitter() + 
  ylim(0, 2.5) + 
  scale_x_discrete(labels = function(x) str_wrap(x, width = 20)) + 
  facet_wrap(~artist_name, scales = "free_x") + 
  labs(y = "Sonic Score")

# Compare artists
music %>% 
  mutate(sonic_score = valence + danceability + energy) %>% 
  ggplot(aes(x = fct_reorder(artist_name, sonic_score, .desc = T), y = sonic_score)) + 
  geom_jitter() + 
  geom_boxplot(alpha = 0) + 
  theme_minimal() + 
  expand_limits(y = 0) + 
  labs(x = "Artist", 
       y = "Sonic Score")

# ------------. 
library(tidytext)
music_words <- music %>% 
  unnest_tokens(word, lyric_text) %>% 
  anti_join(stop_words, by = "word") %>% 
  filter(!word %in% c("uh", "yeah", "hey", "baby", "ooh", "wanna", "gonna", 
                      "ah", "ahh", "ha", "la", "mmm", "whoa", "haa", "ain", 
                      "isn", "ll", "ve", "don", "didn"))

music_words %>% 
  count(artist_name, word, sort = T) %>% 
  group_by(artist_name) %>% 
  top_n(10) %>% 
  # mutate(word = reorder_within(word, by = n, within = artist_name) %>% str_remove_all("_.+$")) %>% 
  ggplot(aes(x = reorder_within(word, by = n, within = artist_name), y = n)) + 
  geom_col() + 
  scale_x_reordered() + 
  coord_flip() + 
  facet_wrap(~artist_name, scales = "free_y")


music %>% 
  select(artist_name, lyric_text) %>% 
  drop_na(lyric_text) %>% 
  unnest_tokens(bigram, lyric_text, token = "ngrams", n = 2) %>% 
  separate(bigram, c("word1", "word2"), sep = " ") %>% 
  anti_join(stop_words, by = c("word1" = "word")) %>% 
  anti_join(stop_words, by = c("word2" = "word")) %>% 
  filter(!word1 %in% c("uh", "yeah", "hey", "baby", "ooh", "wanna", "gonna", 
                      "ah", "ahh", "ha", "la", "mmm", "whoa", "haa", "ain", 
                      "isn", "ll", "ve", "don", "didn")) %>% 
  filter(!word2 %in% c("uh", "yeah", "hey", "baby", "ooh", "wanna", "gonna", 
                       "ah", "ahh", "ha", "la", "mmm", "whoa", "haa", "ain", 
                       "isn", "ll", "ve", "don", "didn")) %>% 
  unite(bigram, word1, word2, sep = " ")

music_words %>% 
  left_join(get_sentiments("bing"), by = "word") %>% 
  filter(!is.na(sentiment)) %>% 
  group_by(artist_name, sentiment) %>% 
  count(word) %>% 
  top_n(5) %>% 
  mutate(n = if_else(sentiment == "negative", n*-1, as.double(n))) %>% 
  ungroup() %>% 
  mutate(word = reorder_within(word, by = n, within = artist_name)) %>% 
  ggplot(aes(x = word, y = n, fill = sentiment)) + 
  geom_col(show.legend = F) + 
  scale_x_reordered() + 
  coord_flip() + 
  facet_wrap(~artist_name, scales = "free")
