---
title: "pgenv"
date: 2018-08-02T04:31:03Z
lastMod: 2018-08-02T04:31:03Z
description: I wrote a simple PostgreSQL binary manager. You should try it.
tags: [Postgres, pgenv]
type: post
---

For years, I've managed multiple versions of PostgreSQL by regularly editing and
running a [simple script] that builds each major version from source and
installs it in `/usr/local`. I would shut down the current version, remove the
symlink to `/usr/local/pgsql`, symlink the one I wanted, and start it up again.

This is a pain in the ass.

Recently I wiped my work computer (because reasons) and started reinstalling all
my usual tools. PostgreSQL, I decided, no longer needs to run as the `postgres`
user from `/usr/local`. What would be much nicer, when it came time to test
[pgTAP] against all supported versions of Postgres, would be to use a tool like
[plenv] or [rbenv] to do all the work for me.

So I wrote [pgenv]. To use it, clone it into `~/.pgenv` (or wherever you want)
and add its `bin` directories to your `$PATH` environment variable:

``` console
$ git clone https://github.com/theory/pgenv.git
echo 'export PATH="$HOME/.pgenv/bin:$HOME/.pgenv/pgsql/bin:$PATH"' >> ~/.bash_profile
```

Then you're ready to go:

``` console
$ pgenv build 10.4
```

A few minutes later, it's there:

``` console
$ pgenv versions
pgsql-10.4
```

Let's use it:

``` console
$ pgenv use 10.4
The files belonging to this database system will be owned by user "david".
This user must also own the server process.
#    (initdb output elided)
waiting for server to start.... done
server started
PostgreSQL 10.4 started
```

Now connect:

``` console
$ psql -U postgres
psql (10.4)
Type "help" for help.

postgres=# 
```

Easy. Each version you install -- as far back as 8.0 -- has the default super
user `postgres` for compatibility with the usual system-installed version. It
also builds all contrib modules, including PL/Perl using `/usr/bin/perl`.

With this little app in place, I quickly built all the versions I need. Check it
out:

``` console
$ pgenv versions
     pgsql-10.3
  *  pgsql-10.4
     pgsql-11beta2
     pgsql-8.0.26
     pgsql-8.1.23
     pgsql-8.2.23
     pgsql-8.3.23
     pgsql-8.4.22
     pgsql-9.0.19
     pgsql-9.1.24
     pgsql-9.2.24
     pgsql-9.3.23
     pgsql-9.4.18
     pgsql-9.5.13
     pgsql-9.6.9
```

Other commands include `start`, `stop`, and `restart`, which act on the
currently active version; `version`, which shows the currently-active version
(also indicated by the asterisk in the output of the `versions` command);
`clear`, to clear the currently-active version (in case you'd rather fall back
on a system-installed version, for example); and `remove`, which will remove a
version. See [the docs] for details on all the commands.

How it Works
------------

All this was written in an uncomplicated Bash script. I've ony tested it on a
couple of Macs, so YMMV, but as long as you have Bash, Curl, and `/usr/bin/perl`
on a system, it ought to just work.

*How* it works is by building each version in its own directory:
`~/.pgenv/pgsql-10.4`, `~/.pgenv/pgsql-11beta2`, and so on. The currently-active
version is nothing more than symlink, `~/.pgenv/pgsql`, to the proper version
directory. There is no other configuration. pgenv downloads and builds versions
in the `~/.pgenv/src` directory, and the tarballs and compiled source left in
place, in case they're needed for development or testing. pgenv never uses them
again unless you delete a version and `pgenv build` it again, in which case
pgenv deletes the old build directory and unpacks from the tarball again.

Works for Me!
-------------

Over the last week, I hacked on pgenv to get all of these commands working. It
works very well for my needs. Still, I think it might be useful to add support
for a configuration file. It might allow one to change the name of the default
superuser, the location Perl, and perhaps a method to change `postgresql.conf`
settings following an `initdb`. I don't know when (or if) I'll need that stuff,
though. Maybe you do, though? [Pull requests] welcome!

But even if you don't, give it a whirl and [let me know] if you find any
issues.

  [simple script]: https://github.com/theory/my-cap/blob/master/bin/perl-regress.sh
  [pgTAP]: https://pgtap.org/ "pgTAP: Unit testing for PostgreSQL"
  [plenv]: https://github.com/tokuhirom/plenv "plenv - Perl binary manager"
  [rbenv]: https://github.com/rbenv/rbenv "rbenv - Groom your app's Ruby environment"
  [pgenv]: https://github.com/theory/pgenv "pgenv - PostgreSQL binary manager"
  [the docs]: https://github.com/theory/pgenv#readme "pgenv README"
  [Pull requests]: https://github.com/theory/pgenv/pulls "pgenv Pull Requests"
  [let me know]: https://github.com/theory/pgenv/issues "pgenv Issues"
