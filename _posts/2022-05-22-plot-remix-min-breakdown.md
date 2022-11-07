---
title: Plot Remix: Minutes Breakdown
subtitle: Recreate a plot for Vinicus Junior's minutes breakdown for Real Madrid
date: 2022-05-22
tags: [r, football, plot-remix]
---

This has been a breakout season for Vinicius Junior. 
He made first appearances for Real Madrid's first team during the 2018/19 season. 
Vini impressed early on, but struggled with consistency and his decision making in the final third. 
This season he's been reliable, scoring goals and providing for his teammates. As a result he's been a constant in Madrid's lineup. 
After the final matchday of the 2022 La Liga season I wanted to visualize Vini's evolution into a regular starter. 


I thought back to a plot I saw by Tom Worville ([@Worville on Twitter](https://twitter.com/Worville)) visualing Son Heung-min’s early career in Germany.

<p align ="center">
  <img src = "/figs/20220522 tom worville plot.png">
</p>


I couldn't quite find an elegant webscraping/data solution to get the data in a workable format that I wanted. 
Unfortunately I copied html tables from [Transfermarkt](https://www.transfermarkt.us/) and saved the output in Excel. 

_**Edit (9/3/2022):** I hated the fact that I wasn't able to create a fully autonomous solution to generate this plot. 
I've continued to toy around with a webscraping solution. Hoping to write a follow-up in the future._

-----------------

Here's my final plot! 
To get the Real Madrid crest I used [Thomas Mock](https://twitter.com/thomas_mock)'s `add_logo()` function from his [fantastic tutorial](https://themockup.blog/posts/2019-01-09-add-a-logo-to-your-plot/).
It took a little bit of time to understand some of the parameters, but I think it was a really nice touch. 

<p align="center">
<img src ="/figs/20220521-Vinicius-Junior-minutes-breakdown.png"; width = 600>
</p>


You can reference my source code for this plot [here](https://gist.github.com/OTStats/1b1b0a78e06089163f30a241f990a423) — I'm happy to answer any questions about my process or code. 
Thanks for reading!
