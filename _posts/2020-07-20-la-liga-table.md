---
title: "2020 La Liga Table"
date: 2020-07-20
category: r
tags: [r, football]
---



Yesterday was the final matchday of the 2019/20 La Liga season. Real Madrid claimed their 34th La Liga title, Atleti qualify for the UCL for the 8th consecutive season, and Espanyol are back to la Segunda after 27 seasons in Spain's top-flight.

Let's sum up this season with some data cleaning. 

***

There are plenty of quality resources online demonstrating how to clean match fixtures to create a league tables for completed soccer seasons:

- James Curleys: [Spanish La Liga Dataset](https://rpubs.com/jalapic/laliga)
- Jona's (aka Opisthokonta) blog: [R functions for soccer league tables and result matrix](http://opisthokonta.net/?p=18)

While these are great examples of how to create a generic league table, La Liga has unique tie-break rules for teams that end the season level on points. The examples that I shared above resort to manually editing teams' final league positions. I wanted to come up with a systematic approach using the specific tie-breaking rules for La Liga to create a final league table for any La Liga season.

For this analysis I accessed FiveThirtyEight's SPI matches data. 

{% highlight r %}
# Load Packages
library(tidyverse)

# Read Data
spi_raw <- read_csv("https://projects.fivethirtyeight.com/soccer-api/club/spi_matches.csv")

glimpse(spi_raw)
{% endhighlight %}



{% highlight text %}
## Rows: 34,284
## Columns: 23
## $ season      <dbl> 2016, 2016, 2016, 2016, 2016, 2016, 2016, 2016, 2016, 20…
## $ date        <date> 2016-08-12, 2016-08-12, 2016-08-13, 2016-08-13, 2016-08…
## $ league_id   <dbl> 1843, 1843, 2411, 2411, 2411, 2411, 2411, 2411, 1843, 24…
## $ league      <chr> "French Ligue 1", "French Ligue 1", "Barclays Premier Le…
## $ team1       <chr> "Bastia", "AS Monaco", "Hull City", "Crystal Palace", "E…
## $ team2       <chr> "Paris Saint-Germain", "Guingamp", "Leicester City", "We…
## $ spi1        <dbl> 51.16, 68.85, 53.57, 55.19, 68.02, 69.49, 56.32, 58.98, …
## $ spi2        <dbl> 85.68, 56.48, 66.81, 58.66, 73.25, 59.33, 60.35, 59.74, …
## $ prob1       <dbl> 0.0463, 0.5714, 0.3459, 0.4214, 0.3910, 0.5759, 0.4380, …
## $ prob2       <dbl> 0.8380, 0.1669, 0.3621, 0.2939, 0.3401, 0.1874, 0.2692, …
## $ probtie     <dbl> 0.1157, 0.2617, 0.2921, 0.2847, 0.2689, 0.2367, 0.2927, …
## $ proj_score1 <dbl> 0.91, 1.82, 1.16, 1.35, 1.47, 1.91, 1.30, 1.37, 1.39, 2.…
## $ proj_score2 <dbl> 2.36, 0.86, 1.24, 1.14, 1.38, 1.05, 1.01, 1.05, 1.14, 0.…
## $ importance1 <dbl> 32.4, 53.7, 38.1, 43.6, 31.9, 34.1, 33.9, 36.5, 37.9, 73…
## $ importance2 <dbl> 67.7, 22.9, 22.2, 34.6, 48.0, 30.7, 32.5, 29.1, 44.2, 27…
## $ score1      <dbl> 0, 2, 2, 0, 1, 1, 1, 0, 3, 2, 1, 3, 0, 3, 1, 0, 3, 1, 0,…
## $ score2      <dbl> 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 0, 2, 1, 2, 3, 3, 4, 0, 0,…
## $ xg1         <dbl> 0.97, 2.45, 0.85, 1.11, 0.73, 1.05, 1.40, 1.24, 1.03, 2.…
## $ xg2         <dbl> 0.63, 0.77, 2.77, 0.68, 1.11, 0.22, 0.55, 1.84, 1.84, 1.…
## $ nsxg1       <dbl> 0.43, 1.75, 0.17, 0.84, 0.88, 1.52, 1.13, 1.71, 1.10, 1.…
## $ nsxg2       <dbl> 0.45, 0.42, 1.25, 1.60, 1.81, 0.41, 1.06, 1.56, 2.26, 0.…
## $ adj_score1  <dbl> 0.00, 2.10, 2.10, 0.00, 1.05, 1.05, 1.05, 0.00, 3.12, 2.…
## $ adj_score2  <dbl> 1.05, 2.10, 1.05, 1.05, 1.05, 1.05, 1.05, 1.05, 2.10, 1.…
{% endhighlight %}

This data is fantastic. Each observation includes a match date, league id's, team names, team SPIs, teams' likelihood of winning, as well as xG/NSxG for each team. In order to make this data more useful, I've used the following cleaning steps to provide a "tidy" table. 



{% highlight r %}
matches <- spi_raw %>% 
  transmute(date, 
            league, 
            league_id, 
            team = team1, 
            opponent = team2, 
            teamGoal = score1, 
            oppGoal = score2, 
            result = case_when(score1 > score2  ~ "W", 
                               score1 < score2  ~ "L", 
                               score1 == score2 ~ "D"), 
            ha = "Home") %>% 
  bind_rows(
    spi_raw %>% 
      transmute(date, 
                league, 
                league_id, 
                team = team2, 
                opponent = team1, 
                teamGoal = score2, 
                oppGoal = score1, 
                result = case_when(score1 < score2  ~ "W", 
                                   score1 > score2  ~ "L", 
                                   score1 == score2 ~ "D"), 
                ha = "Away")) %>% 
  mutate(game_goal_diff = teamGoal - oppGoal) %>% 
  mutate(result_points = case_when(result == "W" ~ 3, 
                                   result == "D" ~ 1, 
                                   TRUE ~ 0))

glimpse(matches)
{% endhighlight %}



{% highlight text %}
## Rows: 68,568
## Columns: 11
## $ date           <date> 2016-08-12, 2016-08-12, 2016-08-13, 2016-08-13, 2016…
## $ league         <chr> "French Ligue 1", "French Ligue 1", "Barclays Premier…
## $ league_id      <dbl> 1843, 1843, 2411, 2411, 2411, 2411, 2411, 2411, 1843,…
## $ team           <chr> "Bastia", "AS Monaco", "Hull City", "Crystal Palace",…
## $ opponent       <chr> "Paris Saint-Germain", "Guingamp", "Leicester City", …
## $ teamGoal       <dbl> 0, 2, 2, 0, 1, 1, 1, 0, 3, 2, 1, 3, 0, 3, 1, 0, 3, 1,…
## $ oppGoal        <dbl> 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 0, 2, 1, 2, 3, 3, 4, 0,…
## $ result         <chr> "L", "D", "W", "L", "D", "D", "D", "L", "W", "W", "W"…
## $ ha             <chr> "Home", "Home", "Home", "Home", "Home", "Home", "Home…
## $ game_goal_diff <dbl> -1, 0, 1, -1, 0, 0, 0, -1, 1, 1, 1, 1, -1, 1, -2, -3,…
## $ result_points  <dbl> 0, 1, 3, 0, 1, 1, 1, 0, 3, 3, 3, 3, 0, 3, 0, 0, 0, 3,…
{% endhighlight %}

We now have a two observations per team, per match. We now can think observation from the perspective of a team, now with details about whether the match was played home or away (`ha`), the team's opponent, goals for and against, and the result of the match. I also included a field for team's goal differential for the game (`game_goal_diff`). 

One thing that 538 doesn't include is a variable for season, so we'll have to filter to include only matches played for this season and for La Liga (which has the league id 1869). 


{% highlight r %}
## Filter to only include this La Liga season
liga <- matches %>% 
  filter(league_id == 1869, between(date, as.Date("2019-08-15"), as.Date("2020-07-20")))
{% endhighlight %}

Let's now create a traditional league table for the end of the season:


{% highlight r %}
table_1 <- liga %>% 
  group_by(team) %>% 
  summarise(MP = n(), 
            W = sum(result == "W"), 
            D = sum(result == "D"), 
            L = sum(result == "L"), 
            GF = sum(teamGoal), 
            GA = sum(oppGoal),  
            GD = GF - GA, 
            Pts = sum(result_points)) %>% 
  arrange(desc(Pts))

table_1
{% endhighlight %}



{% highlight text %}
## # A tibble: 20 x 9
##    team               MP     W     D     L    GF    GA    GD   Pts
##    <chr>           <int> <int> <int> <int> <dbl> <dbl> <dbl> <dbl>
##  1 Real Madrid        38    26     9     3    70    25    45    87
##  2 Barcelona          38    25     7     6    86    38    48    82
##  3 Atletico Madrid    38    18    16     4    51    27    24    70
##  4 Sevilla FC         38    19    13     6    54    34    20    70
##  5 Villarreal         38    18     6    14    63    49    14    60
##  6 Granada            38    16     8    14    52    45     7    56
##  7 Real Sociedad      38    16     8    14    56    48     8    56
##  8 Getafe             38    14    12    12    43    37     6    54
##  9 Valencia           38    14    11    13    46    53    -7    53
## 10 Osasuna            38    13    13    12    46    54    -8    52
## 11 Athletic Bilbao    38    13    12    13    41    38     3    51
## 12 Levante            38    14     7    17    47    53    -6    49
## 13 Eibar              38    11     9    18    39    56   -17    42
## 14 Real Valladolid    38     9    15    14    32    43   -11    42
## 15 Real Betis         38    10    11    17    48    60   -12    41
## 16 Alavés             38    10     9    19    34    59   -25    39
## 17 Celta Vigo         38     7    16    15    37    49   -12    37
## 18 Leganes            38     8    12    18    30    51   -21    36
## 19 Mallorca           38     9     6    23    40    65   -25    33
## 20 Espanyol           38     5    10    23    27    58   -31    25
{% endhighlight %}

Looking good! But as I noted before, the tie-breaking rules for La Liga are unique. In other leagues around the world (e.g. the English Premier League), goal difference is the primary tie-breaker, however in Spain the first tie breaker is head-to-head results for teams with the same number of points. For example, if Valencia and Levante were to level on points but Valencia managed to beat Levante in both fixtures, Valencia would beat Levante head-to-head. Here's the full breakdown for league classification:

> Rules for classification: 1) Points; 2) Head-to-head points; 3) Head-to-head goal difference; 4) Goal difference; 5) Goals scored; 6) Fair-play points (Note: Head-to-head record is used only after all the matches between the teams in question have been played)^[2]

This season there are a few teams that ended with the same number of points:
* 60pts: Atleti and Sevilla
* 56pts: Granda and La Real
* 42pts: Eibar and Valladolid

I'll deal with these tie-breaks by considering teams with the same number of points as a group, and creating a mini league table for each group, providing teams with a rank within their group, and joining the mini league table back to the main league table.


{% highlight r %}
# Table with all teams level on points, with an id unique to teams 
# with the same final point total
team_ties <- table_1 %>% 
  group_by(Pts) %>% 
  filter(n() > 1) %>% 
  mutate(id = cur_group_id()) %>% 
  ungroup() %>% 
  select(team, id)

team_ties
{% endhighlight %}



{% highlight text %}
## # A tibble: 6 x 2
##   team               id
##   <chr>           <int>
## 1 Atletico Madrid     3
## 2 Sevilla FC          3
## 3 Granada             2
## 4 Real Sociedad       2
## 5 Eibar               1
## 6 Real Valladolid     1
{% endhighlight %}

In these steps, we'll filter for only matches where teams within the same points-group are playing each other. In other words we're looking for the two matches Atleti and Sevilla played each other, the two matches between Granda and La Real, and the two matches between Eibar and Valladolid. After we have matches, we'll summarise points and goal differential by the points-group.


{% highlight r %}
tie_break_table <- team_ties %>% 
  rename(team_id = id) %>% 
  inner_join(liga, by = "team") %>% 
  inner_join(team_ties %>% rename(opponent = team, opponent_id = id), by = "opponent") %>% 
  filter(team_id == opponent_id) %>% 
  mutate(game_goal_diff = teamGoal - oppGoal) %>% 
  group_by(team_id, team) %>% 
  summarise(tie_break_pts = sum(result_points), 
            tie_break_gd = sum(game_goal_diff), 
            .groups = "drop") %>% 
  arrange(team_id, tie_break_pts, tie_break_gd) %>% 
  select(team, tie_break_pts, tie_break_gd)
{% endhighlight %}

Finally, we join the tie-break table to the final table, arrange the teams by the sort criteria, and remove unnecessary columns.


{% highlight r %}
final_table <- table_1 %>% 
  left_join(tie_break_table, by = "team") %>% 
  arrange(desc(Pts), desc(tie_break_pts), desc(tie_break_gd), desc(GD), desc(GF)) %>% 
  mutate(Rank = row_number()) %>% 
  select(Rank, everything(), -tie_break_pts, -tie_break_gd)

final_table
{% endhighlight %}



{% highlight text %}
## # A tibble: 20 x 10
##     Rank team               MP     W     D     L    GF    GA    GD   Pts
##    <int> <chr>           <int> <int> <int> <int> <dbl> <dbl> <dbl> <dbl>
##  1     1 Real Madrid        38    26     9     3    70    25    45    87
##  2     2 Barcelona          38    25     7     6    86    38    48    82
##  3     3 Atletico Madrid    38    18    16     4    51    27    24    70
##  4     4 Sevilla FC         38    19    13     6    54    34    20    70
##  5     5 Villarreal         38    18     6    14    63    49    14    60
##  6     6 Real Sociedad      38    16     8    14    56    48     8    56
##  7     7 Granada            38    16     8    14    52    45     7    56
##  8     8 Getafe             38    14    12    12    43    37     6    54
##  9     9 Valencia           38    14    11    13    46    53    -7    53
## 10    10 Osasuna            38    13    13    12    46    54    -8    52
## 11    11 Athletic Bilbao    38    13    12    13    41    38     3    51
## 12    12 Levante            38    14     7    17    47    53    -6    49
## 13    13 Real Valladolid    38     9    15    14    32    43   -11    42
## 14    14 Eibar              38    11     9    18    39    56   -17    42
## 15    15 Real Betis         38    10    11    17    48    60   -12    41
## 16    16 Alavés             38    10     9    19    34    59   -25    39
## 17    17 Celta Vigo         38     7    16    15    37    49   -12    37
## 18    18 Leganes            38     8    12    18    30    51   -21    36
## 19    19 Mallorca           38     9     6    23    40    65   -25    33
## 20    20 Espanyol           38     5    10    23    27    58   -31    25
{% endhighlight %}

Venga vamos! Tenemos la final tabla de la temporada! We have a final league table for the season. Now what's the use doing this once? Let's create a function that matches for a La Liga season and produces the end of season league table.


{% highlight r %}
la_liga_table <- function(matches){
  table_1 = matches %>% 
    group_by(team) %>% 
    summarise(MP = n(), 
              W = sum(result == "W"), 
              D = sum(result == "D"), 
              L = sum(result == "L"), 
              GF = sum(teamGoal), 
              GA = sum(oppGoal),  
              GD = GF - GA, 
              Pts = sum(result_points)) %>% 
  arrange(desc(Pts))

  
  team_ties = table_1 %>% 
    group_by(Pts) %>% 
    filter(n() > 1) %>% 
    mutate(id = cur_group_id()) %>% 
    ungroup() %>% 
    select(team, id)
  
  tie_break_table = team_ties %>% 
    rename(team_id = id) %>% 
    inner_join(matches, by = "team") %>% 
    inner_join(team_ties %>% rename(opponent = team, opponent_id = id), by = "opponent") %>% 
    filter(team_id == opponent_id) %>% 
    mutate(game_goal_diff = teamGoal - oppGoal) %>% 
    group_by(team_id, team) %>% 
    summarise(tie_break_pts = sum(result_points), 
              tie_break_gd = sum(game_goal_diff), 
              .groups = "drop") %>% 
    arrange(team_id, tie_break_pts, tie_break_gd) %>% 
    select(team, tie_break_pts, tie_break_gd)
  
  final_table = table_1 %>% 
    left_join(tie_break_table, by = "team") %>% 
    arrange(desc(Pts), 
            desc(tie_break_pts), 
            desc(tie_break_gd), 
            desc(GD), 
            desc(GF)) %>% 
    mutate(Rank = row_number()) %>% 
    select(Rank, everything(), -tie_break_pts, -tie_break_gd)
  
  return(final_table)
}
{% endhighlight %}

Let's test it for the 2017/18 La Liga season:


{% highlight r %}
## Filter to only include the 2017-18 La Liga Season
liga_2017 <- matches %>% 
  filter(league_id == "1869", date >= as.Date("2017-07-31") & date < as.Date("2018-07-31"))

cat("2017/18 La Liga Table")
{% endhighlight %}



{% highlight text %}
## 2017/18 La Liga Table
{% endhighlight %}



{% highlight r %}
la_liga_table(liga_2017)
{% endhighlight %}



{% highlight text %}
## # A tibble: 20 x 10
##     Rank team                   MP     W     D     L    GF    GA    GD   Pts
##    <int> <chr>               <int> <int> <int> <int> <dbl> <dbl> <dbl> <dbl>
##  1     1 Barcelona              38    28     9     1    99    29    70    93
##  2     2 Atletico Madrid        38    23    10     5    58    22    36    79
##  3     3 Real Madrid            38    22    10     6    94    44    50    76
##  4     4 Valencia               38    22     7     9    65    38    27    73
##  5     5 Villarreal             38    18     7    13    57    50     7    61
##  6     6 Real Betis             38    18     6    14    60    61    -1    60
##  7     7 Sevilla FC             38    17     7    14    49    58    -9    58
##  8     8 Getafe                 38    15    10    13    42    33     9    55
##  9     9 Eibar                  38    14     9    15    44    50    -6    51
## 10    10 Girona FC              38    14     9    15    50    59    -9    51
## 11    11 Espanyol               38    12    13    13    36    42    -6    49
## 12    12 Real Sociedad          38    14     7    17    66    59     7    49
## 13    13 Celta Vigo             38    13    10    15    59    60    -1    49
## 14    14 Alavés                 38    15     2    21    40    50   -10    47
## 15    15 Levante                38    11    13    14    44    58   -14    46
## 16    16 Athletic Bilbao        38    10    13    15    41    49    -8    43
## 17    17 Leganes                38    12     7    19    34    51   -17    43
## 18    18 Deportivo La Coruña    38     6    11    21    38    76   -38    29
## 19    19 Las Palmas             38     5     7    26    24    74   -50    22
## 20    20 Málaga                 38     5     5    28    24    61   -37    20
{% endhighlight %}

Ahh, there was a unique case this year where three teams finished with 49 points; and by checking the final league table our function handled these ties correctly. I'm already looking forward to the next La Liga season.

***

I didn't address the final tie-breaker: fair-play points. This would take a little more time to incorporate seeing as 538 doesn't include data on discipline (yellow/red cards, fouls, etc).
