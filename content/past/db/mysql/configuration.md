--- 
date: 2006-04-11T04:43:00Z
slug: configuration
title: Intelligent MySQL Configuration
aliases: [/computers/databases/mysql/configuration.html]
tags: [MySQL, ANSI, Unicode, UTF-8, UTC, time zones]
type: post
---

<p>James Duncan Davidson's <a href="http://blog.duncandavidson.com/2006/04/configuring_mys.html" title="James Duncan Davidson on MySQL Configuration">Configuring MySQL on MacOS X</a> post earlier today reminded me that I wanted to blog about the configuration I came up with while installing MySQL 5 on my box. Nothing has irritated me more than when MySQL's syntax has violated the ANSI SQL standards in the most blatant ways, or when transactions have appeared to work, but mysteriously not worked. Yes, I use Duncan's settings to make sure that the MySQL box on my PowerBook only listens on local sockets, but I additionally add this configuration to <em>/etc/my.cnf</em>:</p>

<pre>
[mysqld]
sql-mode=ansi,strict_trans_tables,no_auto_value_on_zero,no_zero_date,no_zero_in_date,only_full_group_by
character-set-server=utf8
default-storage-engine=InnoDB
default-time-zone=utc
</pre>

<p>That last configuration can actually only be added after running this command:</p>

<pre>
/usr/local/mysql/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo | \
mysql -u root mysql
</pre>

<p>But then the upshot is that I have everything configured to be as compliant as possible (although the time zone stuff is just my personal preference):</p>

<pre>
mysql&gt; SELECT @@global.sql_mode;
mysql> SELECT @@global.sql_mode;
+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+
| @@global.sql_mode                                                                                                                                     |
+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+
| REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,NO_AUTO_VALUE_ON_ZERO,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE |
+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+
1 row in set (0.00 sec)

mysql&gt; show variables like &#x0027;%character_set\_%&#x0027;;
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
| Variable_name            | Value  |
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
| character_set_client     | utf8   |
| character_set_connection | utf8   |
| character_set_database   | utf8   |
| character_set_filesystem | binary |
| character_set_results    | utf8   |
| character_set_server     | utf8   |
| character_set_system     | utf8   |
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
7 rows in set (0.01 sec)

mysql&gt; show variables like &#x0027;%table_ty%&#x0027;;
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
| Variable_name | Value  |
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
| table_type    | InnoDB |
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
1 row in set (0.00 sec)

mysql&gt; show variables like &#x0027;time_zone%&#x0027;;
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
| Variable_name | Value |
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
| time_zone     | utc   |
+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+
1 row in set (0.00 sec)
</pre>

<p>Now that's the way things should be! Or at least as close as I'm going to get to it in MySQL 5.</p>

<p><strong>Update 2006-11-04:</strong> Ask Bj&oslash;rn Hansen turned me on to the <q><a href="http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_strict_trans_tables" title="MySQL Reference Manual: STRICT_TRANS_TABLES">strict_trans_tables</a></q> mode, which prevents MySQL from trying to guess what you mean when you leave out a value for a required column. So I've now updated my configuration with <code>sql-mode=ansi,strict_trans_tables</code>.</p>

<p><strong>Update 2009-11-05:</strong> I found myself configuring MySQL again today, and there were some other settings I found it useful to add:</p>

<ul>
  <li><a href="http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_no_auto_value_on_zero" title="MySQL Reference Manual: NO_AUTO_VALUE_ON_ZERO">no_auto_value_on_zero</a> forces <code>AUTO_INCREMENT</code> columns to increment only when inserting a <code>NULL</code>, rather than when inserting a <code>NULL</code> or a zero(!).</li>
  <li><a href="http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_no_zero_date" title="MySQL Reference Manual: NO_ZERO_DATE">no_zero_date</a> and <a href="http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_no_zero_in_date" title="MySQL Reference Manual: NO_ZERO_IN_DATE">no_zero_in_date</a> disallow dates where the the year or month are set to 0.</li>
  <li><a href="http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_only_full_group_by" title="MySQL Reference Manual: NO_ONLY_FULL_GROUP_BY">only_full_group_by</a> requires that non-aggregated columns in a select list be included in a <code>GROUP BY</code> clause, as is mandated by the SQL standard. This only applies if an <a href="http://dev.mysql.com/doc/refman/5.1/en/group-by-functions.html" title="MySQL Reference Manual: GROUP BY (Aggregate) Functions">aggregate function</a> is used in a query</li>
</ul>

<p>I've added all of these to the example above.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/mysql/configuration.html">old layout</a>.</small></p>


