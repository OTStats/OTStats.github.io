

# -- Load libraries
library(tidyverse)
library(lubridate)
library(spotifyr)
library(httr)
library(rvest)

# -- Source Spotify API tokens
source("~/Credentials/ot-spotify-credentials.R")

Sys.setenv(SPOTIFY_CLIENT_ID = spotify_credentials()[[1]])
Sys.setenv(SPOTIFY_CLIENT_SECRET = spotify_credentials()[[2]])

# Retrieve Spotify access token
access_token <- get_spotify_access_token()

# -- Source Genius API tokens
source("~/Credentials/ot-genius-credentials.R")
token <- genius_credentials()$genius_api_token


artist_spotify_genius <- function(artist_name) {
  
  # -- Gather Spotify audio features
  get_spotify_artist = function(spotify_artist) {
    
    data = get_artist_audio_features(spotify_artist) %>% 
      as_tibble() %>% 
      filter(str_detect(track_name, pattern = "- Live", negate = T), 
             str_detect(album_name, pattern = "- Live", negate = T)) %>% 
      mutate(album_release_date = ymd(album_release_date), 
             track_name = str_to_title(track_name)) %>% 
      unnest(available_markets) %>% 
      filter(available_markets == "US") %>% 
      arrange(album_release_year, track_number)
    return(data)
  }
  
  artist_spotify_songs = get_spotify_artist(spotify_artist = artist_name)
  
  
  # Getting artist ID on Genius
  genius_get_artists = function(artist_name, n_results = 10) {
    baseURL = 'https://api.genius.com/search?q=' 
    requestURL = paste0(baseURL, gsub(' ', '%20', artist_name),
                        '&per_page=', n_results,
                        '&access_token=', token)
    
    res = GET(requestURL) %>% content %>% .$response %>% .$hits
    
    map_df(1:length(res), function(x) {
      tmp = res[[x]]$result$primary_artist
      list(
        artist_id = tmp$id,
        artist_name = tmp$name
      )
    }) %>% unique()
  }
  
  
  genius_artists = genius_get_artists(artist_name)
  
  
  # Getting track urls
  baseURL = 'https://api.genius.com/artists/' 
  requestURL = paste0(baseURL, genius_artists$artist_id[1], '/songs')
  
  track_lyric_urls = list()
  i = 1
  while (i > 0) {
    tmp = GET(requestURL, query = list(access_token = token, per_page = 50, page = i)) %>% 
      content %>% 
      .$response
    track_lyric_urls = c(track_lyric_urls, tmp$songs)
    if (!is.null(tmp$next_page)) {
      i = tmp$next_page
    } else {
      break
    }
  }
  
  
  
  filtered_track_lyric_urls = c()
  filtered_track_lyric_titles = c()
  index = c()
  
  for (i in 1:length(track_lyric_urls)) {
    if (track_lyric_urls[[i]]$primary_artist$name == artist_name) {
      filtered_track_lyric_urls = append(filtered_track_lyric_urls, track_lyric_urls[[i]]$url)
      filtered_track_lyric_titles = append(filtered_track_lyric_titles, track_lyric_urls[[i]]$title)
      
      index = append(index, i)
    }
  }
  
  
  # (some indexes might need to be changed since Spotify data has changed)
  lyrics = tibble(filtered_track_lyric_urls, 
                  filtered_track_lyric_titles) %>% 
    inner_join(artist_spotify_songs %>% 
                 select(track_name), 
               by = c("filtered_track_lyric_titles" = "track_name"))
  
  
  # Webscraping lyrics using rvest 
  lyric_text = rep(NA, nrow(lyrics))
  for (i in 1:nrow(lyrics)) {
    lyric_text[i] <- read_html(lyrics$filtered_track_lyric_urls[i]) %>% 
      html_nodes(".lyrics p") %>% 
      html_text()
  }
  
  # -- Clean Genius lyrics
  genius_data = lyrics %>% 
    select(track_name = filtered_track_lyric_titles) %>% 
    mutate(lyric_text = lyric_text %>% 
             str_replace_all("([a-z])([A-Z])", "\\1 \\2") %>%  # Separate words
             str_replace_all("\n|'", " ") %>% 
             str_replace_all("\\[.*?\\]", " ") %>% 
             str_to_lower() %>% 
             str_remove_all(pattern = ",|\\.") %>% 
             str_replace_all(" {2,}", " ") %>% 
             str_trim(side = "both"))
  
  return(full_join(genius_data, artist_spotify_songs, by = "track_name"))
}

# ---- Get music features from my favorite artists
nineteen <- artist_spotify_genius("The 1975")
struts <- artist_spotify_genius("The Struts")
mumford <- artist_spotify_genius("Mumford & Sons")
luke <- artist_spotify_genius("Luke Combs")
catfish <- artist_spotify_genius("Catfish and the Bottlemen")

# ---- Save favorite music data
saveRDS(nineteen, "Projects/the-nineteen-seventy-five-music.RDS")
saveRDS(struts, "Projects/the-struts-music.RDS")
saveRDS(mumford, "Projects/mumford-and-sons-music.RDS")
saveRDS(luke, "Projects/luke-combs-music.RDS")
saveRDS(catfish, "Projects/catfish-and-the-bottlemen-music.RDS")

# #### Example
# > luke <- artist_spotify_genius("Luke Combs")
# > luke
# # A tibble: 29 x 38
# track_name lyric_text artist_name artist_id album_id album_type
#         <chr>      <chr>      <chr>       <chr>     <chr>    <chr>     
#  1 1, 2 Many  "well i g… Luke Combs  718COspg… 1LVNYhj… album     
#  2 All Over … "feels so… Luke Combs  718COspg… 1LVNYhj… album     
#  3 Be Carefu… couldn't … Luke Combs  718COspg… 1lhNch5… album     
#  4 Beer Can   i’ve been… Luke Combs  718COspg… 1lhNch5… album     
#  5 Beer Neve… i've had … Luke Combs  718COspg… 1LVNYhj… album     
#  6 Better To… "a 40 hp … Luke Combs  718COspg… 1LVNYhj… album     
#  7 Blue Coll… we were j… Luke Combs  718COspg… 1LVNYhj… album     
#  8 Dear Today dear toda… Luke Combs  718COspg… 1LVNYhj… album     
#  9 Every Lit… "this fut… Luke Combs  718COspg… 1LVNYhj… album     
# 10 Honky Ton… midnight … Luke Combs  718COspg… 1lhNch5… album     
# # … with 19 more rows, and 32 more variables:
# #   album_release_date <date>, album_release_year <dbl>,
# #   album_release_date_precision <chr>, danceability <dbl>,
# #   energy <dbl>, key <int>, loudness <dbl>, mode <int>,
# #   speechiness <dbl>, acousticness <dbl>, instrumentalness <dbl>,
# #   liveness <dbl>, valence <dbl>, tempo <dbl>, track_id <chr>,
# #   analysis_url <chr>, time_signature <int>, disc_number <int>,
# #   duration_ms <int>, explicit <lgl>, track_href <chr>,
# #   is_local <lgl>, track_preview_url <chr>, track_number <int>,
# #   type <chr>, track_uri <chr>, external_urls.spotify <chr>,
# #   album_name <chr>, key_name <chr>, mode_name <chr>, key_mode <chr>,
# #   available_markets <chr>



music <- bind_rows(catfish, luke, mumford, nineteen, struts)

