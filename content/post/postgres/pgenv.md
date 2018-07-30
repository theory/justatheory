---
title: "pgenv"
date: 2018-07-30T21:51:53Z
lastMod: 2018-07-30T21:51:53Z
description: A simple PostgreSQL binary manager. You should try it.
tags: [Postgres, pgenv, plenv]
type: post
---

For years, I've managed multiple versions of PostgreSQL by regularly editing and
running a [simple script] that builds each major version from source and
installs it in `/usr/local`. I would shut down the current version, symlink the
one I wanted to `/usr/local/pgsql` and start it up again.

I've used this pattern for years. It's a pain in the ass.

*   I had to manually edit the script to get the versions I wanted.
*   It assumed a system `postgres` user, which may or may not be available on a
    system.
*   I had to remember where the start script was and remember to shut down the
    current version before changing the symlink and starting again. More than
    once I forgot to do this and had to take more steps to revert, shut down,
    and switch.
*   Whenever I changed computers, I had to start all over again. Not a biggie, I
    had the script, but backups would have been nice.

Recently I wiped my work computer (because reasons) and started installing all
my usual tools again. As part of the process, I started using [plenv] to manage
multiple versions of Perl. This was a bit of a revelation:

*   Installation and configuration was easy: I just cloned the
    [plenv repository] into `~/.plenv`, edited my shell startup script, and was
    ready to go.
*   To get a new version of Perl -- any version -- I just ran
    `plenv install $version` and a few minutes later, it was there.
*   All the versions of Perl I built -- all the way back to 5.8.9 -- were
    installed in a subdirectory of `~/.plenv`, rather than in `/usr/local`.
*   Naturally, they were all owned by me, too -- no more need to teach the
    CPAN client to use `sudo` to install stuff!
*   When I wanted to switch versions, I just ran `plenv global perl-$version`
    and continued working.

For use cases that don't require running system-managed applications -- which
means, for me as a developer, almost all use cases -- this was ideal. changing
versions is quick and painless, and I can just focus on my work.

So when it came time for me to install PostgreSQL on my clean new system, I
decided I no longer need to run it as the `postgres` user from `/usr/local`.
What would be much nicer, when it came time to test [pgTAP] against all
supported versions of Postgres, would be to use a tool like plenv to do all the
work for me.

A quick DuckDuckGoing and I found [Pgenv]. But it wasn't quite what I wanted. It
requires a Postgres compiled from a clone of its Git repository, which you had
to clone and compile manually, and had rather more verbose commands than I'd
like, such as `pgenv.sh pgstart`. I wanted something to manage any version by
downloading the appropriate release tarball, and to easily switch versions.

So I wrote [pgenv]. Just like plenv, you clone it into `~/.pgenv` (or wherever
you want) and add its bin directories to your `$PATH` environment variable:

``` sh
$ echo 'export PATH="$HOME/.pgenv/bin:$HOME/.pgenv/pgsql/bin:$PATH"' >> ~/.bash_profile
```

Then you're ready to go:

```
pgenv build 10.4
```

A few minutes later, it's there:

```
$ pgenv versions
pgsql-10.4
```

Let's use it:

```
$ pgenv use 10.4
The files belonging to this database system will be owned by user "david".
This user must also own the server process.
# initdb output elided
waiting for server to start.... done
server started
PostgreSQL 10.4 started
```

Now I can just connect:

```
$ psql -U postgres
psql (10.4)
Type "help" for help.

postgres=# 
```

Easy. Each version you install -- as far back as 8.0.26 -- has the default super
user `postgres` for compatibility with the usual system-installed version. It
also builds all contrib modules, including PL/Perl using `/usr/bin/perl`.

With this little app in place, I quickly built all the versions I need. Check it
out:

```
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
directory. There is no other configuration. Versions are downloaded and built in
the `~/.pgenv/src` directory, and the tarballs and compiled source left in
place, in case they're needed for development or testing. pgenv never uses them
again unless you delete a version and `pgenv build` it again, in which case the
old build directory is deleted and unpacked from the tarball again.

Works for Me!
-------------

Over the last week, I hacked on pgenv a bit in my spare time to get all of these
commands working. And it's working very well for my needs. I was thinking it
might make sense to add support for an optional configuration file, though. It
would allow one to change the name of the default superuser, the location Perl
(required for building PL/Perl), and perhaps a method to change
`postgresql.conf` settings following an `initdb`. I don't know when or if I'll
need that stuff, though. Maybe you do, though? [Pull requests] welcome!

But even if you don't, give it a whirl and [let me know] if you find any
issues.

  [simple script]: 
  [plenv]: https://github.com/tokuhirom/plenv "plenv - Perl binary manager"
  [plenv repository]: https://github.com/tokuhirom/plenv
  [pgTAP]: https://pgtap.org/ "pgTAP: Unit testing for PostgreSQL"
  [Pgenv]: 
  [pgenv]: https://github.com/theory/pgenv "pgenv - PostgreSQL binary manager"
  [the docs]: https://github.com/theory/pgenv#readme "pgenv README"
  [Pull requests]: 
  [let me know]: https://github.com/theory/pgenv/issues "pgenv Issues"
