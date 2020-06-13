---
title: Analyzing UWW Men's Soccer Results
subtitle: A web scraping exercise
date: 2018-12-05
tags: 
  - R
  - football
---
# Introduction

I played four years of college soccer at the University of Wisconsin-Whitewater. After I graduated in 2017 I was always interested in exploring how well the team performed while I was a member of the program. 
About a year ago, I manually _scraped_ the [men's soccer homepage](https://uwwsports.com/schedule.aspx?path=msoc&) on the UWW Athletics website. Copy and pasting scores, game locations, and results into a Google Sheet... 

![](/fig/2018-12-06-uww-soccer/UWW_Results_Screenshot.png)  

I spent hours switching between screens copy and pasting data these data... The following process took me a half hour to get the exact same data.

# Planning

Questions I wanted to investigate:  
**List them out here!**




## Accessing the data... the right way. 
In order to scrape game results, we need the data in a digestible format. I found the [Men's Soccer Archives](https://uwwsports.com/sports/2009/9/9/sidebar_432.aspx?path=msoc) to be most helpful, with data in html format. 

![](/fig/2018-12-06-uww-soccer/Screenshot-2018-12-05-019.32.56.png)

## Let R do the work
    library(rvest)                # Web scraping
    library(tidyverse)            # Data wrangling
    library(magrittr)             # Forward-pipe operator
    
    url2009 <- "https://static.uwwsports.com/custompages/msoc/2009/TEAMSTAT.HTM?path=msoc&path=msoc"
    download.file(url = url2009, destfile = "UWW2009.html")


    read_html("UWW2009.html") %>%             # Read the file and 
      html_table(header = T) -> raw           ## specify file is html table with header
    
Let's see how we did: 

    head(raw)
    # [[1]]  
    #          Date           Location                                  Result             
    # 1    11/15/09 River Forest, Ill. Dominican University 1, UW-Whitewater 0 Box score  
    # 2    11/14/09 River Forest, Ill.     UW-Whitewater 1, St. Olaf College 0 Box score  
    # 3     11/7/09      Oshkosh, Wis.           UW-Whitewater 1, UW-Oshkosh 0 Box score  
    # 4    10/27/09     Whitewater, WI UW-Whitewater 3, Northwood University 2 Box score  
    # 5  10/25/2009      Chicago, Ill.              UW-Whitewater 2, Chicago 1 Box score  

Great! Looks like we successfully downloaded the file and all the data we want is there. If you look closely, you'll notice a few things: 
1. our object _raw_ is a list with one element, our table of results - we'll have to extract the table
1. the Date format inconsistent - four dates have the 2-digit year and one has a 4-digit year (oh boy...)
1. the Location field is also inconsistent - Oshkosh and Whitewater are both cities in Wisconsin, one instance is abbrevated "Wis." and another as "WI"
1. the Result field is a character string listing the winning university followed by the winning university's number of goals, followed by the losing university and the losing university's goals
1. Box Score offers no insight, so we can drop this field

Next we can extract the game results and drop Box Score from our table:

    raw[[1]] %>%                             # Extract table and
      select(-4) -> results                  ## drop unnecessary field

Write a loop to download html files for 2009 through 2018, appending the results to the `results` table.

    for (i in 10:18) {
      paste0("https://static.uwwsports.com/custompages/msoc/20", 
             str_pad(i, width = 2, side = "left", pad = "0"), 
             "/TEAMSTAT.HTM?path=msoc&path=msoc") -> url                          # Construct urls for scraping loop
      dest <- paste0("UWW20", str_pad(i, width = 2, side = "left", pad = "0"))    # Customize destination name
      download.file(url, destfile = dest)                                         # Download (html) file
      read_html(dest) %>%                                                         # Read file
        html_table(header = T) -> raw                                             ## as a html table.
      raw[[1]] %>%                                                                # Extract table and
        select(-4) -> clean                                                       ## drop unnecessary field
      bind_rows(clean, results) -> results                                        # Append seasons to results table
    }

There is also one instance where a period in the abbreviation of University is a comma. We can correct this in one line:

    matches[66, 3] <- "Wis.-Whitewater 3, Univ. of Dubuque 2"


Now let's tidy our data. In order to get our data in a digestible format we will have to identify the two teams (one of which is guarenteed to be UWW) and their respective goals scored. From there we can determine when where the game was played, that is whether the game is playing in Whitewater at Fiskum Field or elsewhere, and the result of the game from the perspective of UWW. 

    results %<>% 
      mutate(
        Date = parse_date_time(Date, c('%b %d, %Y', "%m/%d/%y")),
        Season = year(Date), 
        team1 = (str_split(Result, pattern = ",") %>% 
                       unlist() %>% 
                       matrix(ncol = 2, byrow = T))[, 1],
             team2 = (str_split(Result, pattern = ",") %>% 
                       unlist() %>% 
                       matrix(ncol = 2, byrow = T))[, 2], 
             atUWW = str_detect(Location, pattern = "Whitewater"), 
             team1Goals = str_extract(team1, pattern = "[:digit:]"), 
             team2Goals = str_extract(team2, pattern = "[:digit:]"), 
             uwwGoals = case_when(
              str_detect(team1, pattern = "Whitewater") == 1 ~ team1Goals,
              str_detect(team2, pattern = "Whitewater") == 1 ~ team2Goals), 
             oppGoals = case_when(
               str_detect(team1, pattern = "Whitewater") == 0 ~ team1Goals,
               str_detect(team2, pattern = "Whitewater") == 0 ~ team2Goals), 
             uwwResult = case_when(
               uwwGoals > oppGoals ~ "W", 
               uwwGoals == oppGoals ~ "D", 
               uwwGoals < oppGoals ~ "L"
               )
        )

# Summarizing UWW Men's Soccer seasons

# Results by Season
Let's aggregate results by season. 

    results %>% 
      select(Date, Season, uwwResult) %>% 
      group_by(Season, uwwResult) %>% 
      count() %>% 
      spread(uwwResult, n, fill = 0) %>% 
      rowwise() %>% 
      transmute(Season, 
                Record = paste(W, L, D, sep = "-"))
    
    ## A tibble: 10 x 2
    #   Season Record
    #    <dbl> <chr> 
    # 1   2009 12-6-3
    # 2   2010 13-2-5
    # 3   2011 12-8-0
    # 4   2012 8-5-3 
    # 5   2013 14-6-1
    # 6   2014 14-5-4
    # 7   2015 14-4-2
    # 8   2016 14-5-3
    # 9   2017 10-6-4
    #10   2018 13-5-1
