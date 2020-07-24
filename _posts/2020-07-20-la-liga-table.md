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
## $ season      [3m[38;5;246m<dbl>[39m[23m 2016, 2016, 2016, 2016, 2016, 2016, 2016, 2016, 2016, 2…
## $ date        [3m[38;5;246m<date>[39m[23m 2016-08-12, 2016-08-12, 2016-08-13, 2016-08-13, 2016-0…
## $ league_id   [3m[38;5;246m<dbl>[39m[23m 1843, 1843, 2411, 2411, 2411, 2411, 2411, 2411, 1843, 2…
## $ league      [3m[38;5;246m<chr>[39m[23m "French Ligue 1", "French Ligue 1", "Barclays Premier L…
## $ team1       [3m[38;5;246m<chr>[39m[23m "Bastia", "AS Monaco", "Hull City", "Crystal Palace", "…
## $ team2       [3m[38;5;246m<chr>[39m[23m "Paris Saint-Germain", "Guingamp", "Leicester City", "W…
## $ spi1        [3m[38;5;246m<dbl>[39m[23m 51.16, 68.85, 53.57, 55.19, 68.02, 69.49, 56.32, 58.98,…
## $ spi2        [3m[38;5;246m<dbl>[39m[23m 85.68, 56.48, 66.81, 58.66, 73.25, 59.33, 60.35, 59.74,…
## $ prob1       [3m[38;5;246m<dbl>[39m[23m 0.0463, 0.5714, 0.3459, 0.4214, 0.3910, 0.5759, 0.4380,…
## $ prob2       [3m[38;5;246m<dbl>[39m[23m 0.8380, 0.1669, 0.3621, 0.2939, 0.3401, 0.1874, 0.2692,…
## $ probtie     [3m[38;5;246m<dbl>[39m[23m 0.1157, 0.2617, 0.2921, 0.2847, 0.2689, 0.2367, 0.2927,…
## $ proj_score1 [3m[38;5;246m<dbl>[39m[23m 0.91, 1.82, 1.16, 1.35, 1.47, 1.91, 1.30, 1.37, 1.39, 2…
## $ proj_score2 [3m[38;5;246m<dbl>[39m[23m 2.36, 0.86, 1.24, 1.14, 1.38, 1.05, 1.01, 1.05, 1.14, 0…
## $ importance1 [3m[38;5;246m<dbl>[39m[23m 32.4, 53.7, 38.1, 43.6, 31.9, 34.1, 33.9, 36.5, 37.9, 7…
## $ importance2 [3m[38;5;246m<dbl>[39m[23m 67.7, 22.9, 22.2, 34.6, 48.0, 30.7, 32.5, 29.1, 44.2, 2…
## $ score1      [3m[38;5;246m<dbl>[39m[23m 0, 2, 2, 0, 1, 1, 1, 0, 3, 2, 1, 3, 0, 3, 1, 0, 3, 1, 0…
## $ score2      [3m[38;5;246m<dbl>[39m[23m 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 0, 2, 1, 2, 3, 3, 4, 0, 0…
## $ xg1         [3m[38;5;246m<dbl>[39m[23m 0.97, 2.45, 0.85, 1.11, 0.73, 1.05, 1.40, 1.24, 1.03, 2…
## $ xg2         [3m[38;5;246m<dbl>[39m[23m 0.63, 0.77, 2.77, 0.68, 1.11, 0.22, 0.55, 1.84, 1.84, 1…
## $ nsxg1       [3m[38;5;246m<dbl>[39m[23m 0.43, 1.75, 0.17, 0.84, 0.88, 1.52, 1.13, 1.71, 1.10, 1…
## $ nsxg2       [3m[38;5;246m<dbl>[39m[23m 0.45, 0.42, 1.25, 1.60, 1.81, 0.41, 1.06, 1.56, 2.26, 0…
## $ adj_score1  [3m[38;5;246m<dbl>[39m[23m 0.00, 2.10, 2.10, 0.00, 1.05, 1.05, 1.05, 0.00, 3.12, 2…
## $ adj_score2  [3m[38;5;246m<dbl>[39m[23m 1.05, 2.10, 1.05, 1.05, 1.05, 1.05, 1.05, 1.05, 2.10, 1…
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
## $ date           [3m[38;5;246m<date>[39m[23m 2016-08-12, 2016-08-12, 2016-08-13, 2016-08-13, 201…
## $ league         [3m[38;5;246m<chr>[39m[23m "French Ligue 1", "French Ligue 1", "Barclays Premie…
## $ league_id      [3m[38;5;246m<dbl>[39m[23m 1843, 1843, 2411, 2411, 2411, 2411, 2411, 2411, 1843…
## $ team           [3m[38;5;246m<chr>[39m[23m "Bastia", "AS Monaco", "Hull City", "Crystal Palace"…
## $ opponent       [3m[38;5;246m<chr>[39m[23m "Paris Saint-Germain", "Guingamp", "Leicester City",…
## $ teamGoal       [3m[38;5;246m<dbl>[39m[23m 0, 2, 2, 0, 1, 1, 1, 0, 3, 2, 1, 3, 0, 3, 1, 0, 3, 1…
## $ oppGoal        [3m[38;5;246m<dbl>[39m[23m 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 0, 2, 1, 2, 3, 3, 4, 0…
## $ result         [3m[38;5;246m<chr>[39m[23m "L", "D", "W", "L", "D", "D", "D", "L", "W", "W", "W…
## $ ha             [3m[38;5;246m<chr>[39m[23m "Home", "Home", "Home", "Home", "Home", "Home", "Hom…
## $ game_goal_diff [3m[38;5;246m<dbl>[39m[23m -1, 0, 1, -1, 0, 0, 0, -1, 1, 1, 1, 1, -1, 1, -2, -3…
## $ result_points  [3m[38;5;246m<dbl>[39m[23m 0, 1, 3, 0, 1, 1, 1, 0, 3, 3, 3, 3, 0, 3, 0, 0, 0, 3…
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
            `Record (W-D-L)` = str_c(sum(result == "W"), 
                                     sum(result == "D"), 
                                     sum(result == "L"), 
                                     sep = "-"), 
            `GF-GA` = str_c(sum(teamGoal), sum(oppGoal), sep = "-"),  
            GD = sum(teamGoal) - sum(oppGoal), 
            Pts = sum(result_points)) %>% 
  arrange(desc(Pts))

table_1
{% endhighlight %}



{% highlight text %}
## # A tibble: 20 x 6
##    team               MP `Record (W-D-L)` `GF-GA`    GD   Pts
##    <chr>           <int> <chr>            <chr>   <dbl> <dbl>
##  1 Real Madrid        38 26-9-3           70-25      45    87
##  2 Barcelona          38 25-7-6           86-38      48    82
##  3 Atletico Madrid    38 18-16-4          51-27      24    70
##  4 Sevilla FC         38 19-13-6          54-34      20    70
##  5 Villarreal         38 18-6-14          63-49      14    60
##  6 Granada            38 16-8-14          52-45       7    56
##  7 Real Sociedad      38 16-8-14          56-48       8    56
##  8 Getafe             38 14-12-12         43-37       6    54
##  9 Valencia           38 14-11-13         46-53      -7    53
## 10 Osasuna            38 13-13-12         46-54      -8    52
## 11 Athletic Bilbao    38 13-12-13         41-38       3    51
## 12 Levante            38 14-7-17          47-53      -6    49
## 13 Eibar              38 11-9-18          39-56     -17    42
## 14 Real Valladolid    38 9-15-14          32-43     -11    42
## 15 Real Betis         38 10-11-17         48-60     -12    41
## 16 Alavés             38 10-9-19          34-59     -25    39
## 17 Celta Vigo         38 7-16-15          37-49     -12    37
## 18 Leganes            38 8-12-18          30-51     -21    36
## 19 Mallorca           38 9-6-23           40-65     -25    33
## 20 Espanyol           38 5-10-23          27-58     -31    25
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
{% endhighlight %}



{% highlight text %}
## Error: arrange() failed at implicit mutate() step. 
## x Could not create a temporary column for `..5`.
## ℹ `..5` is `GF`.
{% endhighlight %}



{% highlight r %}
final_table
{% endhighlight %}



{% highlight text %}
## Error in eval(expr, envir, enclos): object 'final_table' not found
{% endhighlight %}

Venga vamos! Tenemos la final tabla de la temporada! We have a final league table for the season. Now what's the use doing this once? Let's create a function that matches for a La Liga season and produces the end of season league table.


{% highlight r %}
la_liga_table <- function(matches){
  table_1 = matches %>% 
    group_by(team) %>% 
    summarise(MP = n(), 
              summarise(MP = n(), 
                        `Record (W-D-L)` = str_c(sum(result == "W"), 
                                                 sum(result == "D"), 
                                                 sum(result == "L"), 
                                                 sep = "-"), 
                        `GF-GA` = str_c(sum(teamGoal), sum(oppGoal), sep = "-"),  
                        GD = sum(teamGoal) - sum(oppGoal), 
                        Pts = sum(result_points)) %>% 
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



{% highlight text %}
## Error: <text>:13:21: unexpected '='
## 12:                         Pts = sum(result_points)) %>% 
## 13:                 Pts =
##                         ^
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
## Error in la_liga_table(liga_2017): could not find function "la_liga_table"
{% endhighlight %}

Ahh, there was a unique case this year where three teams finished with 49 points; and by checking the final league table our function handled these ties correctly. I'm already looking forward to the next La Liga season.

***

I didn't address the final tie-breaker: fair-play points. This would take a little more time to incorporate seeing as 538 doesn't include data on discipline (yellow/red cards, fouls, etc).
