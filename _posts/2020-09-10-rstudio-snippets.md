---
title: "RStudio Code Snippets: for the basic stuff"
date: 2020-09-10
category: r
tags: [r]
---

I first learned about [code snippets in RStudio](https://support.rstudio.com/hc/en-us/articles/204463668-Code-Snippets) from [Sean Lopp's talk about RStudio Tips and Tricks](https://www.youtube.com/watch?v=kuSQgswZdr8) at the 2017 New York R Conference. 
Ever since seeing the video I utilized the built-in `if`, `fun`, and alike, but never got around to customizing my own. 
For example, I considered writing snippets for my go-to dplyr pipe chains or my basic ggplot geoms. 
But here I was almost two years after learning about snippets and I never created any of my own... 
Until now.

Turns out the greatest motivation for creating customized snippets came from a [StackOverflow post](https://stackoverflow.com/questions/35158708/how-to-set-default-template-for-new-r-files-in-rstudio) on how to set a default template for new R files in RStudio. 
I have typically written some sort of heading to my R, SQL, Python, and SPSS scripts. 
Ever since I started my professional career I've made an effort to have comprehensive code structure. 
Roughly speaking my scripts include a header and commented purpose section, a section where installing/loading packages at the top of the script, then I dive into my cleaning and/or data analysis. 
The layouts of my headings and purpose sections have been, to say the least, inconsistent. 

I was motivated further by [Jake Daniels' blog on snippets](https://datacritics.com/2019/01/28/rstudio-snippets/) where he described writing a simple snippet for loading R packages (which he cleverly named the snippet `usual suspects`). 
These examples were simple enough and provided enough utility for me to 

Below are two simple snippets that I've incorporated into my RStudio global environment. 
The first provides a consistent heading that I can add to the beginning of my scripts, and the second allows me to quickly add/load regularly used packages.
```
snippet heading
    # ${1:scriptname}.R
    # ${2:scripttitle}
    # Author:
    # Date: Fri Sep 11 12:04:02 2020
    # Purpose:
    # --------------

snippet mainpack
    # ---- Load libraries
    library(tidyverse)
    library(lubridate)
    library(${1:package1})
    library(${2:package2})
```

I'm looking forward to expanding my arsenal of code snippets in RStudio, whether its for Rmarkdown documents/presentations templates, basic SQL setups, or even HTML/CSS/LaTeX basics. 
