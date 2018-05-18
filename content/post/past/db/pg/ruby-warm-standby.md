--- 
date: 2007-03-29T00:44:07Z
slug: ruby-warm-standby
title: PostgreSQL Warm Standby Using Ruby
aliases: [/computers/databases/postgresql/ruby_warm_standby.html]
tags: [Postgres, Ruby, database replication]
type: post
---

<p>The new PostgreSQL <a href="http://www.postgresql.org/docs/8.2/static/warm-standby.html">Warm Standby</a> support is pretty nice. Since my app doesn't currently require  read access to a slave database, I've dumped Slony-I (and all of the <a href="/computers/databases/postgresql/rails_and_slony.html">headache</a> that went with it), and now have a warm failover server being updated a least once per minute. W00t!</p>

<p>I used <a href="http://archives.postgresql.org/sydpug/2006-10/msg00001.php">Charles Duffy's</a> example, as well as the documentation, to build my warm standby configuration, but unfortunately, our server OS does not have the <code>usleep</code> utility, so rather than have 1 second sleeps, I ported Charles's shell script to Ruby. Here it is for your enjoyment:</p>

<pre>
#!/usr/bin/env ruby

DELAY         = 0.01
FAILOVER_FILE = &quot;/path/to/failover&quot;

@@triggered = false

require 'ftools'

def move (from, to)
  # Do not overwrite! Throws an exception on failure, existing the script.
  File.copy( from, to ) unless @@triggered || File.exists?( to )
end

from, to = ARGV

# If PostgreSQL is asking for .history, just try to move it and exit.
if from =~ /\.history$/
  move from, to
  exit
end

# Sleep while waiting for the file.
while !File.exists?(from) &amp;&amp; !@@triggered
  sleep DELAY
  @@triggered = true if File.exists?( FAILOVER_FILE )
end

# Move the file.
move from, to
</pre>

<p>Just change the <code>DELAY</code> value to the number of seconds you want to sleep, and the <code>FAILOVER_FILE</code> value to the location of a file that will trigger a failover.</p>

<p>This is all well and good, but I ultimately ended up using the <code>pg_standby</code> utility that's a new contrib utility in PostgreSQL CVS (and will therefore ship with 8.3), as it has the nice feature of cleaning up old WAL log files. It also does not have subsecond precision, but hey, maybe we don't really need it.</p>
