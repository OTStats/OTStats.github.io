# About

This houses code to render [my blog](https://otstats.github.io/). My blog is powered by [Jekyll](https://jekyllrb.com/) and built on the [Minimal Mistakes theme](https://mmistakes.github.io/minimal-mistakes/). Originally, my blog posts were created solely using markdown. I was inspired by [David Robinson's blog](http://varianceexplained.org/), where he compiles his blog posts with [knitr](http://yihui.name/knitr/) and R markdown using [this script](https://github.com/dgrtwo/dgrtwo.github.com/blob/master/_scripts/knitpages.R). I [modified that script](https://github.com/otstats/otstats.github.io/blob/master/_scripts/knitpages.R) and now compile all of my posts in R markdown.

The purpose of my blog is to share analyses that I have conducted in my free time, document my learning as a R programmer, and improve my written communication. Feel free to contact me if you have questions about the blog or a post.

# Repository Structure

There are a number of files/sub-directories within this repository that are used for formatting and rendering my blog. The remaining sub-directories/scripts I've created and modified for my own purpose. This repository has the following main components:

- `_R`: contains raw R markdown scripts containing source code and text for individual blog posts
- `_pages`: contains markdown files for essential pages on my blog (i.e. "About" page, "Error 404" page, etc.)
- `_posts`: houses the rendered R markdown scripts (from `_R`); these are markdown files
- `_scripts`: currently houses a script used to knit non-rendered R markdown files in `_R` and a template R markdown file for future blog posts
- `assets`: miscellaneous blog images and resources
- `figs`: location of images/figures rendered from R markdown posts

If you have questions about the process feel free to let me know. The structure of my site is inspired by David Robinson's [blog](http://varianceexplained.org/) (a link to his repository is [here](https://github.com/dgrtwo/dgrtwo.github.com)).
