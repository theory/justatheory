--- 
date: 2007-03-26T06:53:40Z
slug: rails-and-slony
title: Rails Migrations with Slony?
aliases: [/computers/databases/postgresql/rails_and_slony.html]
tags: [Postgres, Ruby on Rails, Slony, Migrations]
type: post
---

The new app I'm developing is written in Ruby on Rails and runs on PostgreSQL.
We're replicating our production database using [Slony-I], but we've run into a
bit of a snag: database schema updates must be run as plain SQL through a Slony
script in order to ensure proper replication of the schema changes within a
transaction, but Rails migrations run as Ruby code updating the database via the
Rails database adapter.

So how do others handle Rails migrations with their Slony-I replication setups?
How do you update the Slony-I configuration file for the changes? How do you
synchronize changes to the master schema out to the slaves? Do you shut down
your apps, shut down Slony-I, make the schema changes to both the master and the
slaves, and then restart Slony-I and your apps?

For that matter, people running Slony for their Bricolage databases must have
the same issue, because the Bricolage upgrade scripts are just Perl using the
DBI, not SQL files. Can anyone shed a little light on this for me?

Oh, and one last question: Why is this such a PITA? Can't we have decent
replication that replicates *everything*, including schema changes? *Please?*

  [Slony-I]: https://slony.info/ "Slony-I PostgreSQL Replication"
