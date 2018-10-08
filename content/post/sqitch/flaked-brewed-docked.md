---
title: Flaked, Brewed, and Docked
date: 2018-10-08T01:54:49Z
lastMod: 2018-10-08T01:54:49Z
description: "Sqitch v0.9998: Now with Snowflake support, an improved Homebrew tap, and the quickest way to get started: the new [Docker image](https://hub.docker.com/r/sqitch/sqitch/)."
tags: [Sqitch, Docker, Homebrew, Snowflake]
---

I released [Sqitch] v[0.9998] this week. Despite the [long list of changes],
only one new feature stands out: support for the [Snowflake Data Warehouse]
platform. A major [work] project aims to move all of our reporting data from
Postgres to Snowflake. I asked the team lead if they needed Sqitch support, and
they said something like, "**Oh hell yes,** that would save us *months* of
work!" Fortunately I had time to make it happen.

Snowflake's SQL interface ably supports all the functionality required for
Sqitch; indeed, the [implementation] required fairly little customization. And
while I did report a number of issues and shortcomings to the Snowflake support
team, they always responded quickly and helpfully --- sometimes revealing
undocumented workarounds to solve my problems. I requested that they be
documented.

The work turned out well. If you use Snowflake, consider managing your databases
with Sqitch. Start with [the tutorial] to get a feel for it.

Bundle Up
---------

Of course, you might find it a little tricky to get started. In addition to long
list of Perl dependencies, each database engines requires two external
resources: a command-line client and a driver library. For Snowflake, that means
the [SnowSQL] client and the [ODBC driver]. The PostgreSQL engine requires
[psql] and [DBD::Pg] compiled with [libpq]. MySQL calls for the [mysql client]
and [DBD::mysql] compiled with the MySQL connection library. And so on. You
likely don't care what needs to be built and installed; you just want it to
work. Ideally install a binary and go.

I do, too. So I spent the a month or so building Sqitch bundling support, to
easily install all its Perl dependencies into a single directory for
distribution as a single package. It took a while because, sadly, Perl provides
no straightforward method to build such a feature without also bundling unneeded
libraries. I plan to write up the technical details soon; for now, just know
that I made it work. If you [Homebrew], you'll reap the benefits in your next
`brew install sqitch`.

Pour One Out
------------

In fact, the bundling feature enabled a complete rewrite of the [Sqitch Homebrew
tap]. Previously, Sqitch's Homebrew formula installed the required modules in
Perl's global include path. This pattern violated Homebrew best practices, which
prefer that all the dependencies for an app, aside from configuration, reside in
a single directory, or "cellar."

The new formula follows this dictum, bundling Sqitch and its CPAN dependencies
into a nice, neat package. Moreover, it enables engine dependency selection at
build time. Gone are the separate `sqitch_$engine` formulas. Just pass the
requisite options when you build Sqitch:

``` sh
brew install sqitch --with-postgres-support --with-sqlite-support
```

Include as many engines as you need ([here's the list]). Find yourself with only
Postgres support but now need Oracle, too? Just reinstall:

``` sh
export HOMEBREW_ORACLE_HOME=$ORACLE_HOME
brew reinstall sqitch --with-postgres-support --with-oracle-support
```

In fact, the old `sqitch_oracle` formula hasn't worked in quite some time, but
the new `$HOMEBREW_ORACLE_HOME` environment variable does the trick (provided
you [disable SIP]; see [the instructions] for details).

I recently became a Homebrew user myself, and felt it important to make Sqitch
build "the right way". I expect this formula to be more reliable and better
maintained going forward.

Still, despite its utility, Homebrew Sqitch lives up to its name: It downloads
and builds Sqitch from source. To attract newbies with a quick and easy method
to get started, we need something even simpler.

Dock of the Bae
---------------

Which brings me to the installer that excites me most: The new [Docker image].
Curious about Sqitch and want to download and go? Use Docker? Try this:

```
curl -L https://git.io/fAX6Z -o sqitch && chmod +x sqitch
./sqitch help
```

That's it. On first run, [the script] pulls down the Docker image, which
includes full support for PostgreSQL, MySQL, Firebird, and SQLite, and weighs in
at just 164 MB (54 MB compressed). Thereafter, it works just as if Sqitch was
locally-installed. It uses a few tricks to achieve this bit of magic:

*   It mounts the current directory, so it acts on the Sqitch project you
    intend it to
*   It mounts your home directory, so it can read the usual configuration files
*   It syncs the [environment variables] that Sqitch cares about

The script even syncs your username, full name, and host name, in case you
haven't configured your name and email address with [`sqitch config`]. The only
outwardly obvious difference is the editor:[^sqitch-docker-localhost] If you add
a change and let the editor open, it launches [nano] rather than your preferred
editor. This limitation allows the image ot remain as small as possible.

I invested quite a lot of effort into the Docker image, to make it as small as
possible while maximizing out-of-the-box database engine support --- without
foreclosing support for proprietary databases. To that end, the [repository]
already contains `Dockerfile`s to support [Oracle] and [Snowflake]: simply
download the required binary files, built the image, and push it to your private
registry. Then set `$SQITCH_IMAGE` to the image name to transparently run it
with the magic [shell script][the script].

Docker Docket
-------------

I plan to put more work into the Sqitch Docker repository over the next few
months. [Exasol] and [Vertica] `Dockerfile`s come next. Beyond that, I envision
matrix of different images, one for each database engine, to minimize download
and runtime size for folx who need only one engine --- especially for production
deployments. Adding [Alpine]-based images also tempts me; they'd be even
smaller, though unable to support most (all?) of the commercial database
engines. Still: *tiny!*

Container size obsession is a thing, right?

At [work], we believe the future of app deployment and execution belongs to
containerization, particularly on Docker and [Kubernetes]. I presume that
conviction will grant me time to work on these improvements.

  [^sqitch-docker-localhost]: Well, that and connecting to a service on your
    host machine is a little fussy. For example, to use Postgres on your local
    host, you can't connect to Unix sockets. The [shell script][the script]
    enables [host networking], so on Linux, at least, you should be able to
    connect to `localhost` to deploy your changes. On [macOS] and [Windows], use
    the `host.docker.internal` host name.

  [Sqitch]: https://sqitch.org/
  [0.9998]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.9998
    "App-Sqitch v0.9998"
  [long list of changes]:
    https://metacpan.org/source/DWHEELER/App-Sqitch-0.9998/Changes
    "Sqitch v0.9998 Changes"
  [Snowflake Data Warehouse]: https://www.snowflake.net/
  [work]: https://iovation.com/ "iovation, Inc."
  [implementation]:
    https://github.com/sqitchers/sqitch/blob/master/lib/App/Sqitch/Engine/snowflake.pm
    "App::Sqitch::Engine::snowflake"
  [the tutorial]: https://metacpan.org/pod/sqitchtutorial-snowflake
    "A tutorial introduction to Sqitch change management on Snowflake"
  [SnowSQL]: https://docs.snowflake.net/manuals/user-guide/snowsql.html
    "SnowSQL Client for Snowflake"
  [ODBC driver]: https://docs.snowflake.net/manuals/user-guide/odbc.html
    "ODBC Driver for Snowflake"
  [psql]: https://www.postgresql.org/docs/current/static/app-psql.html
  [DBD::Pg]: https://metacpan.org/module/DBD::Pg
  [libpq]: https://www.postgresql.org/docs/current/static/libpq.html
  [mysql client]: https://dev.mysql.com/doc/refman/5.7/en/mysql.html
  [DBD::mysql]: https://metacpan.org/module/DBD::mysql
  [Homebrew]: https://brew.sh/
  [Sqitch Homebrew tap]: https://github.com/sqitchers/homebrew-sqitch
  [here's the list]: https://github.com/sqitchers/homebrew-sqitch#supported-database-engines
    "Sqitch Homebrew: Supported Database Engines"
  [disable SIP]: https://www.imore.com/how-turn-system-integrity-protection-macos
  [the instructions]: https://github.com/sqitchers/homebrew-sqitch/#--with-oracle-support
    "Sqitch Homebrew Oracle support"
  [Docker image]: https://hub.docker.com/r/sqitch/sqitch/
    "Sqitch on Docker Hub"
  [the script]:
    https://github.com/sqitchers/docker-sqitch/blob/master/docker-sqitch.sh
    "Sqitch Docker Shell Script"
  [environment variables]: https://metacpan.org/pod/sqitch-environment
    "Environment variables recognized by Sqitch"
  [`sqitch config`]: http://metacpan.org/pod/sqitch-config
  [nano]: https://www.nano-editor.org "Nano Text Editor"
  [repository]: https://github.com/sqitchers/docker-sqitch
    "Sqitch Docker Packaging on GitHub"
  [Oracle]: https://github.com/sqitchers/docker-sqitch/tree/master/oracle/
  	"Sqitch Oracle Docker instructions"
  [Exasol]: https://www.exasol.com/
  [Vertica]: https://my.vertica.com/ 
  [Alpine]: https://alpinelinux.org/ "Alpine Linux"
  [Snowflake]: https://github.com/sqitchers/docker-sqitch/tree/master/snowflake/
  	"Sqitch Snowflake Docker instructions"
  [Kubernetes]: https://kubernetes.io/
  [host networking]: https://docs.docker.com/network/host/
    "Docker documentation: “Use host networking”"
  [macOS]: https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds
    "Docker documentation: “Networking features in Docker for Mac”"
  [Windows]: https://docs.docker.com/docker-for-windows/networking/#use-cases-and-workarounds
    "Docker documentation: “Networking features in Docker for Windows”"
