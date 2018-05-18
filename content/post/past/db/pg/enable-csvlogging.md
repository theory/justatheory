--- 
date: 2009-08-19T18:23:14Z
slug: enable-csvlogging
title: Enable CSV Logging in PostgreSQL
aliases: [/computers/databases/postgresql/enable-csvlogging.html]
tags: [Postgres, logging, CSV]
type: post
---

<p>One of the cooler features of recent versions of PostgreSQL is support for
<a href="http://www.postgresql.org/docs/current/static/runtime-config-logging.html"
title="PostgreSQL Documentation: “Error Reporting and Logging”">CSV-formatted
logging</a>. I've never had a chance to use it, but after reading
Josh's <a href="http://it.toolbox.com/blogs/database-soup/more-fun-with-windowing-functions-your-query-log-33467"
title="">cool hack for determining sums of concurrent queries</a> using
windowing functions in PostgreSQL 8.4 to query a table generated from a CSV
log, I just had to give it a try. But while there
is <a href="http://www.postgresql.org/docs/current/static/runtime-config-logging.html#RUNTIME-CONFIG-LOGGING-CSVLOG"
title="PostgreSQL Documentation: “Using CSV-Format Log Output”">decent
documentation</a> for loading up the contents of a CSV-formatted log file,
there I couldn't find simple information on how to set it up. So I figured it
out and record it here for posterity.</p>

<p>Configuration is pretty straight-forward. You need to edit only two
configuration directives (known as “GUCs” in PostgreSQL parlance) in your
<em>postgresql.conf</em> file: <code>log_destination</code>
and <code>logging_collector</code>. I just changed them from:</p>

<pre>
log_destination = &#x0027;stderr&#x0027;
#logging_collector = off
</pre>

<p>To:</p>

<pre>
log_destination = &#x0027;csvlog&#x0027;
logging_collector = on
</pre>

<p>Then all I had to do was cold-restart PostgreSQL; that is, stop it and start it again.
I'm told that a restart won't due for security reasons. After that, I had a shiny new .csv
log file in the <code>pg_log</code> subdirectory of my data directory. It looks like this:</p>

<pre>
2009-08-19 10:44:08.128 PDT,,,36596,,4a8c39e8.8ef4,1,,2009-08-19 10:44:08 PDT,,0,LOG,00000,&quot;database system was shut down at 2009-08-19 10:44:06 PDT&quot;,,,,,,,,
2009-08-19 10:44:08.411 PDT,,,36573,,4a8c39e7.8edd,1,,2009-08-19 10:44:07 PDT,,0,LOG,00000,&quot;database system is ready to accept connections&quot;,,,,,,,,
2009-08-19 10:44:08.412 PDT,,,36599,,4a8c39e8.8ef7,1,,2009-08-19 10:44:08 PDT,,0,LOG,00000,&quot;autovacuum launcher started&quot;,,,,,,,,
</pre>

<p>Cool!</p>

<p>The only other thing I ought to note is that, becaus I removed the “stderr”
value from the <code>log_destination</code> GUC, the old log location I used,
specified in my start script, is no longer necessary. I was even using
log rotation (in the default Mac OS X start script that ships with PostgreSQL),
but that's not necessary anymore, either. So I just turned that stuff off.</p>

<p>Now I have something to refer back to, and so do you. Enjoy!</p>
