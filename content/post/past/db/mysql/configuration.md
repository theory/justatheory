--- 
date: 2006-04-11T04:43:00Z
slug: intelligent-mysql-configuration
title: Intelligent MySQL Configuration
aliases: [/computers/databases/mysql/configuration.html]
tags: [MySQL, ANSI, Unicode, UTF-8, UTC, time zones]
type: post
---

James Duncan Davidson's [Configuring MySQL on MacOS X] post earlier today
reminded me that I wanted to blog about the configuration I came up with while
installing MySQL 5 on my box. Nothing has irritated me more than when MySQL's
syntax has violated the ANSI SQL standards in the most blatant ways, or when
transactions have appeared to work, but mysteriously not worked. Yes, I use
Duncan's settings to make sure that the MySQL box on my PowerBook only listens
on local sockets, but I additionally add this configuration to */etc/my.cnf*:

    [mysqld]
    sql-mode=ansi,strict_trans_tables,no_auto_value_on_zero,no_zero_date,no_zero_in_date,only_full_group_by
    character-set-server=utf8
    default-storage-engine=InnoDB
    default-time-zone=utc

That last configuration can actually only be added after running this command:

    /usr/local/mysql/bin/mysql_tzinfo_to_sql /usr/share/zoneinfo | \
    mysql -u root mysql

But then the upshot is that I have everything configured to be as compliant as
possible (although the time zone stuff is just my personal preference):

    mysql> SELECT @@global.sql_mode;
    mysql> SELECT @@global.sql_mode;
    +-------------------------------------------------------------------------------------------------------------------------------------------------------+
    | @@global.sql_mode                                                                                                                                     |
    +-------------------------------------------------------------------------------------------------------------------------------------------------------+
    | REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI,NO_AUTO_VALUE_ON_ZERO,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE |
    +-------------------------------------------------------------------------------------------------------------------------------------------------------+
    1 row in set (0.00 sec)

    mysql> show variables like '%character_set\_%';
    +--------------------------+--------+
    | Variable_name            | Value  |
    +--------------------------+--------+
    | character_set_client     | utf8   |
    | character_set_connection | utf8   |
    | character_set_database   | utf8   |
    | character_set_filesystem | binary |
    | character_set_results    | utf8   |
    | character_set_server     | utf8   |
    | character_set_system     | utf8   |
    +--------------------------+--------+
    7 rows in set (0.01 sec)

    mysql> show variables like '%table_ty%';
    +---------------+--------+
    | Variable_name | Value  |
    +---------------+--------+
    | table_type    | InnoDB |
    +---------------+--------+
    1 row in set (0.00 sec)

    mysql> show variables like 'time_zone%';
    +---------------+-------+
    | Variable_name | Value |
    +---------------+-------+
    | time_zone     | utc   |
    +---------------+-------+
    1 row in set (0.00 sec)

Now that's the way things should be! Or at least as close as I'm going to get to
it in MySQL 5.

**Update 2006-11-04:** Ask Bjørn Hansen turned me on to the
“[strict\_trans\_tables]” mode, which prevents MySQL from trying to guess what
you mean when you leave out a value for a required column. So I've now updated
my configuration with `sql-mode=ansi,strict_trans_tables`.

**Update 2009-11-05:** I found myself configuring MySQL again today, and there
were some other settings I found it useful to add:

-   [no\_auto\_value\_on\_zero] forces `AUTO_INCREMENT` columns to increment
    only when inserting a `NULL`, rather than when inserting a `NULL` or a
    zero(!).
-   [no\_zero\_date] and [no\_zero\_in\_date] disallow dates where the the year
    or month are set to 0.
-   [only\_full\_group\_by] requires that non-aggregated columns in a select
    list be included in a `GROUP BY` clause, as is mandated by the SQL standard.
    This only applies if an [aggregate function] is used in a query

I've added all of these to the example above.

  [Configuring MySQL on MacOS X]: http://blog.duncandavidson.com/2006/04/configuring_mys.html
    "James Duncan Davidson on MySQL Configuration"
  [strict\_trans\_tables]: http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_strict_trans_tables
    "MySQL Reference Manual: STRICT_TRANS_TABLES"
  [no\_auto\_value\_on\_zero]: http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_no_auto_value_on_zero
    "MySQL Reference Manual: NO_AUTO_VALUE_ON_ZERO"
  [no\_zero\_date]: http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_no_zero_date
    "MySQL Reference Manual: NO_ZERO_DATE"
  [no\_zero\_in\_date]: http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_no_zero_in_date
    "MySQL Reference Manual: NO_ZERO_IN_DATE"
  [only\_full\_group\_by]: http://dev.mysql.com/doc/refman/5.1/en/server-sql-mode.html#sqlmode_only_full_group_by
    "MySQL Reference Manual: NO_ONLY_FULL_GROUP_BY"
  [aggregate function]: http://dev.mysql.com/doc/refman/5.1/en/group-by-functions.html
    "MySQL Reference Manual: GROUP BY (Aggregate) Functions"
