--- 
date: 2007-03-29T00:44:07Z
slug: ruby-warm-standby
title: PostgreSQL Warm Standby Using Ruby
aliases: [/computers/databases/postgresql/ruby_warm_standby.html]
tags: [Postgres, Ruby, Database Replication]
type: post
---

The new PostgreSQL [Warm Standby] support is pretty nice. Since my app doesn't
currently require read access to a slave database, I've dumped Slony-I (and all
of the [headache] that went with it), and now have a warm failover server being
updated a least once per minute. W00t!

I used [Charles Duffy's] example, as well as the documentation, to build my warm
standby configuration, but unfortunately, our server OS does not have the
`usleep` utility, so rather than have 1 second sleeps, I ported Charles's shell
script to Ruby. Here it is for your enjoyment:

``` ruby
#!/usr/bin/env ruby

DELAY         = 0.01
FAILOVER_FILE = "/path/to/failover"

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
while !File.exists?(from) && !@@triggered
  sleep DELAY
  @@triggered = true if File.exists?( FAILOVER_FILE )
end

# Move the file.
move from, to
```

Just change the `DELAY` value to the number of seconds you want to sleep, and
the `FAILOVER_FILE` value to the location of a file that will trigger a
failover.

This is all well and good, but I ultimately ended up using the `pg_standby`
utility that's a new contrib utility in PostgreSQL CVS (and will therefore ship
with 8.3), as it has the nice feature of cleaning up old WAL log files. It also
does not have subsecond precision, but hey, maybe we don't really need it.

  [Warm Standby]: https://www.postgresql.org/docs/8.2/static/warm-standby.html
  [headache]: {{% ref "/post/past/db/pg/rails-and-slony" %}}
  [Charles Duffy's]: https://archives.postgresql.org/sydpug/2006-10/msg00001.php
