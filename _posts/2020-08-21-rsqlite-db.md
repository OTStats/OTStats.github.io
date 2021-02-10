---
title: "SQLite DB in R"
date: 2020-08-21
category: r
tags: [r]
---

A simple tutorial to creating a SQLite database in R.


# Motivation
In my current role at MNPS, I've dealt with massive flat files in various formats: CSV's, text files, and _a lot_ SAVs. ^[For those who are unfamiliar, SAVs are SPSS data files. SAVs are tricky, and I have a lot to say about SPSS after, but I'll save this for another day.] 
After a few weeks of reading data into R via `{readr}`, `data.table::fread`, and `{haven}` (I personally prefer using `{haven}` over `{foreign}` because it's part of the tidyverse). I started to lose patience waiting for files to load. 
Resaving data as `.RData` files definitely didn't help, and I opted to saving smaller dataset as `.RDS`. 
However this still didn't solve the issue for my larger data sets. And when I say large, these files are +200MB and in some cases close to 10 million rows. Much of these data have string variables, too. 
So, I saw this as an opportunity to learn something new in my free time that could improve my efficiency at work. 
There were plenty of online resources for maximizing programming efficiency in R (this includes timing code execution, etc.) and I landed on an elegant, simple solution of creating a SQLite database. 

# Here's how
I found that it's actually quite simple to create a database in R. 
There were some great examples (list examples here) that led me here. 
This process utilizes the `{dbplyr}` and `{RSQLite}` packages. 


{% highlight r %}
# ---- Load libraries
library(dbplyr)
{% endhighlight %}



{% highlight text %}
## 
## Attaching package: 'dbplyr'
{% endhighlight %}



{% highlight text %}
## The following objects are masked from 'package:dplyr':
## 
##     ident, sql
{% endhighlight %}



{% highlight r %}
library(RSQLite)
{% endhighlight %}

The actual creation of the local SQLite database is pretty easy.

{% highlight r %}
db <- "my-db.sqlite"  # This will be my database name
conn <- dbConnect(drv = SQLite(), dbname = db)
{% endhighlight %}

Next up we can write tables to our database. 
In the `dbWriteTable` command you communicate with the database connection, add the name of the table, and the data to write to the DB.


{% highlight r %}
# Write `mtcars` data to our DB named "cars"
dbWriteTable(conn, "cars", mtcars)
{% endhighlight %}

Once we have multiple tables in our database, I've found `src_dbi(conn)` to be helpful to see all the tables in the connection.

{% highlight r %}
# View tables in connection
src_dbi(conn)
{% endhighlight %}



{% highlight text %}
## src:  sqlite 3.30.1 [my-db.sqlite]
## tbls: cars
{% endhighlight %}

Finally, it's always important to disconnect from the database when you're done.

{% highlight r %}
# # Disconnect from DB
DBI::dbDisconnect(conn)
{% endhighlight %}


