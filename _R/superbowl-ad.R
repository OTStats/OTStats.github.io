
# Motivation
# https://projects.fivethirtyeight.com/super-bowl-ads/
# -- Load libraries
library(tidyverse)
library(ggthemes)
library(extrafont)

extrafont::loadfonts('win')
extrafont::font_import()

# -- Read data
ads <- read_csv("https://raw.githubusercontent.com/fivethirtyeight/superbowl-ads/main/superbowl-ads.csv")

# Color Blind Palette from R Cookbook (http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/)
palette <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
             "#0072B2", "#D55E00", "#CC79A7")

# Group by year, summarize average across characteristics
by_year_summary <- ads %>% 
  group_by(year = as.integer(year)) %>% 
  summarise(total = n(), across(where(is.logical), mean))

# Pivot data
by_year_long <- by_year_summary %>% 
  pivot_longer(cols = where(is.double), 
               names_to = "characteristic", 
               values_to = "proportion") %>% 
  mutate(characteristic = str_replace_all(characteristic, "_", " ") %>% str_to_title)

# Visualize
plot <- by_year_long %>% 
  ggplot(aes(x = year, y = proportion, color = characteristic)) + 
  geom_line(show.legend = FALSE) + 
  scale_y_continuous(labels = scales::percent_format()) + 
  facet_wrap(~characteristic) + 
  scale_colour_manual(values = palette) + 
  theme_fivethirtyeight() + 
  labs(title = "", 
       subtitle = "", 
       caption = "\nCreated by Owen Thompson\nGithub/Twitter: @OTStats\nSource: FiveThirtyEight") + 
  theme(plot.caption = element_text(hjust = 0, family = "Tahoma"), 
        plot.margin = unit(c(0.5, .5, .5, .5), "cm"), 
        panel.spacing.x = unit(1, "lines"))


print(plot)
grid::grid.text("your text", gp = grid::gpar(), x = 0.75, y = 0.25)

