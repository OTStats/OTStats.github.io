---
title: "UCL 2022 Group Strength"
date: 2022-08-26
tags: [r, football, dataviz]
---

The UEFA Champions League group draw is complete! 
I'm very excited for this new season to start and for Real Madrid to defend their title. 
Every season I keep a close eye on [FiveThirtyEight's Club Soccer Predictions](https://projects.fivethirtyeight.com/soccer-predictions), and after the groups have been determined I always check out how teams' odds have changed to make it to the knockout stage and beyond. 
The football/soccer community always speculates on which group is the "group of death", and which European giant lucked out with the easiest group. 
Today I scraped 538's UCL Predictions page and SPI ratings and took a look for myself.

----------

<p align ="center">
  <img src = "/figs/20220826a-UCL group strength-OT.png">
</p>

A few memorable notes about this process:
- I was a little annoyed using `geom_image` as some of the team crests were being distorted
- A handful of manual adjustments took place in order to deal with overlaps
- I usually rely on FotMob's figures library for club crests, so I had to manually look up the proper club names (as defined by FotMob) to eventually sync up with their FotMob ID and reference their crest


You can reference my source code for this plot [here](https://gist.github.com/OTStats/44e5947ecb3a9cd0feb6b43c7567bdfd) — I'm happy to answer any questions about my process or code. 
Thanks for reading!
