--- 
date: 2009-08-19T18:23:14Z
slug: enable-csvlogging
title: Enable CSV Logging in PostgreSQL
aliases: [/computers/databases/postgresql/enable-csvlogging.html]
tags: [Postgres, logging, CSV]
type: post
---

One of the cooler features of recent versions of PostgreSQL is support for
[CSV-formatted logging]. I've never had a chance to use it, but after reading
Josh's [cool hack for determining sums of concurrent queries] using windowing
functions in PostgreSQL 8.4 to query a table generated from a CSV log, I just
had to give it a try. But while there is [decent documentation] for loading up
the contents of a CSV-formatted log file, there I couldn't find simple
information on how to set it up. So I figured it out and record it here for
posterity.

Configuration is pretty straight-forward. You need to edit only two
configuration directives (known as “GUCs” in PostgreSQL parlance) in your
*postgresql.conf* file: `log_destination` and `logging_collector`. I just
changed them from:

    log_destination = 'stderr'
    #logging_collector = off

To:

    log_destination = 'csvlog'
    logging_collector = on

Then all I had to do was cold-restart PostgreSQL; that is, stop it and start it
again. I'm told that a restart won't due for security reasons. After that, I had
a shiny new .csv log file in the `pg_log` subdirectory of my data directory. It
looks like this:

    2009-08-19 10:44:08.128 PDT,,,36596,,4a8c39e8.8ef4,1,,2009-08-19 10:44:08 PDT,,0,LOG,00000,"database system was shut down at 2009-08-19 10:44:06 PDT",,,,,,,,
    2009-08-19 10:44:08.411 PDT,,,36573,,4a8c39e7.8edd,1,,2009-08-19 10:44:07 PDT,,0,LOG,00000,"database system is ready to accept connections",,,,,,,,
    2009-08-19 10:44:08.412 PDT,,,36599,,4a8c39e8.8ef7,1,,2009-08-19 10:44:08 PDT,,0,LOG,00000,"autovacuum launcher started",,,,,,,,

Cool!

The only other thing I ought to note is that, becaus I removed the “stderr”
value from the `log_destination` GUC, the old log location I used, specified in
my start script, is no longer necessary. I was even using log rotation (in the
default Mac OS X start script that ships with PostgreSQL), but that's not
necessary anymore, either. So I just turned that stuff off.

Now I have something to refer back to, and so do you. Enjoy!

  [CSV-formatted logging]: http://www.postgresql.org/docs/current/static/runtime-config-logging.html
    "PostgreSQL Documentation: “Error Reporting and Logging”"
  [cool hack for determining sums of concurrent queries]: http://it.toolbox.com/blogs/database-soup/more-fun-with-windowing-functions-your-query-log-33467
  [decent documentation]: http://www.postgresql.org/docs/current/static/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-CSVLOG
    "PostgreSQL Documentation: “Using CSV-Format Log Output”"
