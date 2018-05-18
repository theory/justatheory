--- 
date: 2012-04-16T22:08:26Z
slug: use-timestamptz
title: Always Use TIMESTAMP WITH TIME ZONE
aliases: [/computers/databases/postgresql/use-timestamptz.html]
tags: [Postgres, time zones, database, best practices, recommendations]
type: post
---

<p>My recommendations for sane time zone management in PostgreSQL:</p>

<ul>
<li>Set <code>timezone = 'UTC'</code> in <code>postgresq.conf</code>. This makes UTC the default time zone for all connections.</li>
<li>Use <a href="http://www.postgresql.org/docs/current/static/datatype-datetime.html"><code>timestamp with time zone</code> (aka <code>timestamptz</code>) and <code>time with time zone</code> (aka <code>timetz</code>)</a>. They store values as UTC, but convert them on selection to whatever your time zone setting is.</li>
<li>Avoid <code>timestamp without time zone</code> (aka <code>timestamp</code>) and <code>time without time zone</code> (aka <code>time</code>). These columns do not know the time zone of a value, so different apps can insert values in different zones no one would ever know.</li>
<li>Always specify a time zone when inserting into a <code>timestamptz</code> or <code>timetz</code> column. Unless the zone is UTC. But even then, append a "Z" to your value: it's more explicit, and will keep you sane.</li>
<li>If you need to get <code>timestamptz</code> or <code>timetz</code> values in a zone other than UTC, use the <a href="http://www.postgresql.org/docs/current/static/functions-datetime.html#FUNCTIONS-DATETIME-ZONECONVERT"><code>AT TIME ZONE</code> expression in your query</a>. But be aware that the returned value will be a <code>timestamp</code> or <code>time</code> value, with no more time zone. Good for reporting and queries, bad for storage.</li>
<li>If your app <em>always</em> needs data in some other time zone, have it <a href="http://www.postgresql.org/docs/9.1/static/runtime-config-client.html#GUC-TIMEZONE"><code>SET timezone = 'UTC'</code></a> on connection. All values then retrieved from the database will be in the configured time zone. The app should still include the time zone in values sent to the database.</li>
</ul>

<p>The one exception to the rule preferring <code>timestamptz</code> and <code>timetz</code> is a special case: partitioning. When partitioning data on timestamps, you <em>must not</em> use <code>timestamptz</code>. Why? Because almost no expression involving <code>timestamptz</code> comparison is immutable. Use one in a <code>WHERE</code> clause, and <a href="http://www.postgresql.org/docs/9.1/static/ddl-partitioning.html#DDL-PARTITIONING-CONSTRAINT-EXCLUSION">constraint exclusion</a> may well <a href="http://comments.gmane.org/gmane.comp.db.postgresql.performance/29681">be ignored</a> and all partitions scanned. This is usually something you want to avoid.</p>

<p>So in <strong>this one case</strong> and <strong>only in this one case</strong>, use a <code>timestamp without time zone</code> column, but <em>always insert data in UTC</em>. This will keep things consistent with the <code>timestamptz</code> columns you have everywhere else in your database. Unless your app changes the value of the <a href="http://www.postgresql.org/docs/9.1/static/runtime-config-client.html#GUC-TIMEZONE"><code>timestamp</code> GUC</a> when it connects, it can just assume that everything is always UTC, and should always send updates as UTC.</p>
