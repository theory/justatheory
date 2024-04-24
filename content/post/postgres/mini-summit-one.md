---
title: Mini Summit One
slug: mini-summit-one
date: 2024-03-15T20:05:37Z
lastMod: 2024-04-24T17:15:21Z
description: |
  A rough transcript of my talk "State of the Extension Ecosystem", along with
  interspersed chat comments and appearances by Bagel.
tags: [Postgres, PGXN, Extensions, PGConf, Summit, Bagel]
type: post
---

Great turnout and discussion for the first in a series of [community talks and
discussions][mini-summit] on the postgres extension ecosystem leading up to the
[Extension Ecosystem Summit][the summit] at pgconf.dev on May 28. Thank you!

The talk, "State of the Extension Ecosystem", was followed by 15 minutes or so
of super interesting discussion. Here are the relevant links:

*   [Video](https://www.youtube.com/watch?v=6o1N1-Eq-Do)
*   [Keynote]({{% link "/shared/extension-ecosystem-summit/state-of-the-ecosystem.key" %}})
*   [PDF Slides]({{% link "/shared/extension-ecosystem-summit/state-of-the-extension-ecosystem.pdf" %}})

For posterity, I listened through my droning and tried to capture the general
outline, posted here along with interspersed chat history and some relevant
links. Apologies in advance for any inaccuracies or missed nuance; i'm happy to
update these notes with your corrections.

And now, to the notes!

## Introduction

*   Introduced myself, first Mini Summit, six leading up to the [in-person
    summit][the summit] on May 28 at PGConf.dev in Vancouver, Canada.

*   Thought I would get it things started, provide a bit of history of
    extensions and context for what's next.

## Presentation

*   Postgres has a long history of extensibility, originally using pure SQL or
    [shared preload libraries]. Used by a few early adopters, perhaps a couple
    dozen, including ...

*   Explicit extension support added in Postgres 9.1 by Dimitri Fontaine, with
    [PGXS], [`CREATE EXTENSION`], and [`pg_dump`] & [`pg_restore`] support.

*   Example `pair--1.0.0.sql`:

    ``` sql
    -- complain if script is sourced in psql and not CREATE EXTENSION
    \echo Use "CREATE EXTENSION pair" to load this file. \quit

    CREATE TYPE pair AS ( k text, v text );

    CREATE FUNCTION pair(text, text)
    RETURNS pair LANGUAGE SQL AS 'SELECT ROW($1, $2)::pair;';

    CREATE OPERATOR ~> (LEFTARG = text, RIGHTARG = text, FUNCTION = pair);
    ```

*   [Bagel] makes an appearance.

*   Example `pair.control`:

    ``` ini
    # pair extension
    comment = 'A key/value pair data type'
    default_version = '1.0'
    module_pathname = '$libdir/pair'
    relocatable = true
    ```

*   Example `Makefile`:

    ```makefile
    EXTENSION    = pair
    MODULEDIR    = $(EXTENSION)
    DOCS         = README.md
    DATA         = sql/pair--1.0.sql
    TESTS        = test/sql/base.sql
    REGRESS      = base
    REGRESS_OPTS = --inputdir=test
    MODULES      = src/pair
    PG_CONFIG   ?= pg_config

    PGXS := $(shell $(PG_CONFIG) --pgxs)
    include $(PGXS)
    ```

*   Build and Install:

    ``` console
    $ make
    make: Nothing to be done for `all'.

    $ make install
    mkdir -p '/pgsql/share/extension'
    mkdir -p '/pgsql/share/pair'
    mkdir -p '/pgsql/share/doc/pair'
    install -c -m 644 pair.control '/pgsql/share/extension/'
    install -c -m 644 sql/pair--1.0.sql  '/pgsql/share/pair/'
    install -c -m 644 README.md '/pgsql/share/doc/pair/'

    $ make installcheck
    # +++ regress install-check in  +++
    # using postmaster on Unix socket, default port
    ok 1         - base                                       15 ms
    1..1
    # All 1 tests passed.
    ```

*   `CREATE EXTENSION`:

    ``` console
    $ psql -d try -c 'CREATE EXTENSION pair'
    CREATE EXTENSION

    $ pg_dump -d try
    --
    -- Name: pair; Type: EXTENSION; Schema: -; Owner: -
    --
    CREATE EXTENSION IF NOT EXISTS pair WITH SCHEMA public;

    --
    -- Name: EXTENSION pair; Type: COMMENT; Schema: -; Owner:
    --
    COMMENT ON EXTENSION pair IS 'A key/value pair data type';
    ```

*   Many of us saw opportunity in this new feature.

    > PostgreSQL today is not merely a database, it’s an application development
    > platform.
    >
    > --- Me, 2010

*   Proposed to build [PGXN]. Raised funds to build it in late 2010. Launched
    site April 2011; [Daniele Varrazzo] released CLI, and [Dickson Guedes]
    released the dev CLI.

*   Problems PGXN set out to solve:

    *   Source code distribution with user registration and namespacing
    *   Discovery: Search, read docs, brows tags
    *   Installation: CLI to compile and install using PGXS or Configure

*   PGXN Components:

    *   [Meta Spec]
    *   [Manager]
    *   [Root Mirror]
    *   [API Server]
    *   [Site][PGXN]
    *   [Client]
    *   [Utils CLI]
    *   [CI/CD Image][pgxn-utils]

*   Problems out of scope for PGXN:

    *   Binary packaging and distribution
        *   Defer to apt/yum
    *   Developer tooling (though dev utils helped)
    *   Build tooling
        *   Defer to core ([PGXS])

*   PGXN Shortcomings:

    *   Little development since 2012
    *   Search limitations
        *   Docs preferred
        *   Most distributions have few docs
        *   Some issues [addressed in last few weeks]
    *   Source of Record
        *   Minority of available extensions on PGXN
        *   Releases uneven or neglected

    > In classic SDLC fashion, PGXN POC shipped as an MVP and was neglected.
    >
    > --- Me, Just Now

*   Been peripheral to Postgres extensions for the last 10-12 years, but some
    things have happened.

*   Non-Core extension counts:

    *   [Azure]: 25
    *   [GCP]: 29
    *   [AWS]: 48
    *   [PGXN][stats]: 382
    *   [joelonsql/PostgreSQL-EXTENSIONs.md][gist]: 1,186

*   Daniele asks about that last source, which is just a list in a [gist].

*   Joe Nelson links to the [gist] in Zoom chat. It is not his list, contrary to
    my off-the-cuff guess

*   **Why haven't extensions taken off?**

*   Lost Opportunities

    *   No one canonical source to discover and install extensions
    *   Difficult to find and discover extensions without canonical registry
    *   Most extensions are under-documented and difficult to understand
    *   They are also hard to configure and install; most people don't want or
        need a compiler
    *   The maturity of extensions can be difficult to gauge, not systematized,
        must each be independently researched
        *   *David Christensen* in Chat "attention economy/awareness, NIH, etc"
        *   *Jeremy S* in chat: "Maybe some people don’t know they are using
            extensions (I think that’s possible to some degree)"
    *   There is no comprehensive binary packaging
    *   Centralized source distribution is insufficient (even if it were complete)
        *   *jubilee* in chat: Trust aspect?
        *   *David Johnson* in chat: To seem legit you need to touch the repo at
            least annually to ensure it works on the newest major release.  Even
            if you just do your compile and update the readme.
        *   I mention using [pgxn-utils] and GitHub workflows to ensure my
            extensions continue working
    *   There is insufficient developer tooling; pgxn-utils not well-maintained,
        don't build on recent Rubies, but [pgrx] has a lot of Rust-oriented
        tooling
        *   *Eric* in chat: ❤️
        *   *jubilee* in chat: 🦀 mentioned!

*   Filling the Gaps

*   [dbdev]: "The Database Package Manager for Trusted Language Extensions":
    Includes only TLEs, no binary extensions
*   [trunk]: "A Postgres Extension Registry": Binary distribution of curated
    extensions, desires to be comprehensive and cross-platform
*   [pgxman]: "npm for PostgreSQL": Binary Apt package distribution of curated
    extensions packaged with, desires to be comprehensive and cross-platform

*   Emphases: Ease of Use. Screenshot from [pgxman]:

    > ``` console
    > $ curl -sfL https://install.pgx.sh | sh -
    > 👏🎉 pgxman successfully installed
    > $ pgxman install pgvector
    > The following Debian packages will be installed:
    > postgresql-14-pgxman-pgvector=0.5.1
    > Do you want to continue? [Y/n] y
    > pgvector has been successfully installed.
    > ```

    *   *Daniele* in chat: "Missing a "curl | sudo sh" there.... 👀"
    *   *Greg Mullane (CrunchyData) [he/him]* in chat: "Really not a fan of that
        "pipe curl stuff from internet into sh" system."
    *   *Jeremy S* in chat: "Someone recently reprimanded me for putting curl |
        psql in an extension README.  From a security perspective it probably
        sets a better example to do curl >file.sql … psql file.sql (encourage
        users not to run from Internet but read/review first)" *   *jubilee* in
        chat: "apt/yum install is just a better UI over curl | sh :^)"
    *   *Jeremy S* in chat: "Yes and once you’re to that point there’s already
        more supply chain verification happening"
    *   *Jeremy S* in chat: "It’s usually just the initial bootstrap into any
        system, if the setup wasn’t already in your distro"

*   Emphases: Platform neutrality. Screenshot from [trunk]:

    > |                  |               |
    > | ---------------- | ------------- |
    > | Architecture     | x86-64        |
    > | Operating system | Debian/Ubuntu |

*   Emphases: Stats. Screenshot from [dbdev]:

    > ### Downloads
    > -----
    > 20 all time downloads
    > 0 downloads in last 30 days
    > 1 download in last 90 days
    > 0 downloads in last 180 days


*   Emphases: Curation. Screenshot from [trunk]:

    > |                        |     |
    > | ---------------------- | --: |
    > | Featured               |   7 |
    > | Analytics              |  13 |
    > | Auditing / Logging     |   7 |
    > | Data Change Capture    |   6 |
    > | Connectors             |  27 |
    > | Data / Transformations |  49 |

    *   *Damien Clochard* in chat: gtg, see you later guys !

*   MVPs

    *   [trunk]: Manual integration,  Currently Debian-only
    *   [pgxman]: Form-based submission, Currently Apt-only
    *   [dbdev]: TLEs only, CLI publishing

    *   *David Christensen* in chat: "go has a pretty good extensions infra,
        imho, wrt discovery/docs, etc. also has the benefit of the package names
        being the URL to access it, which is a nice convention."

*   New Opportunities Today

    What are the community opportunities for the extension ecosystem?

    Some ideas:

    *   Improved dev tools: More than pgxn-utils and [pgrx]
    *   Canonical registry: All publicly-available extensions in one pac3
    *   Easy publishing: auto-discovery or CI/CD pipeline publishing
    *   Continuous Delivery: CI/CD pipeline publishing
    *   File-free installation: TLEs
    *   Documentation: Something like Go docs or Rust docs
    *   File management: Put all the files for an extension in one directory
    *   Improved metadata
        *   Library Dependencies: utilities used by extensions
        *   Platform Dependencies: system packages
        *   Build pipelines: [PGXS], [pgrx], [make], [cpan], [pypi], etc.
        *   Artifacts: Binaries build on release
        *   Classification: Curated in addition to tags
        *   Extension Types: Extensions, apps, background workers, loadable libraries
    *   Derived Services
        *   Binary Packaging: Distributed binaries for many platforms
        *   Ratings & Reviews: Stars, thumbs, comments
        *   Aggregated Stats: Repository stats, etc.
        *   Smoke Testing: Matrix of multi-platform test results
        *   Security Scanning: Reporting vulnerabilities
        *   Badging & Curation: Third-party classification, badging various statuses

*   [Extension Ecosystem Summit][the summit]

    > Collaborate to examine the ongoing work on PostgreSQL extension
    > distribution, examine its challenges, identify questions, propose
    > solutions, and agree on directions for execution.

* 🏔️ Your Summit Organizers

    *   [David Wheeler], Tembo, [PGXN]
    *   [Jeremy Schneider], AWS, [dsef]
    *   [David Christensen], Crunchy Data, [pg_kaboom]
    *   [Keith Fiske], Crunchy Data, [pg_partman]
    *   [Devrim Gündüz], EnterpriseDB, [yum.postgresql.org]

*   *Devrim Gunduz* in chat: Thanks David!

*   Schedule:

    *   March 6: [David Wheeler], PGXN: "State of the Extension Ecosystem”
    *   March 20: [Ian Stanton], Tembo: "Building Trunk: A Postgres Extension
        Registry and CLI"
    *   April 3: [Devrim Gündüz]: "yum.postgresql.org and the challenges
        RPMifying extensions"
    *   April 17: [Jonathan Katz]: "TLE Vision and Specifics"
    *   May 1: [Yurii Rashkovskii], Omnigres: "Universally buildable extensions:
        dev to prod"
    *   May 15: [David Wheeler], PGXN: "Community Organizing  Summit Topics"

*   Ultimately want to talk about what's important to *you*, the members of the
    community to make extensions successful.

## Discussion

*   *Eric*: I'm Eric Ridge, one of the developers behind pgrx, as you're going
    through this process of building a modern extension ecosystem, let us know
    what we can do on the Rust side to help make your lives easier, we're happy
    to help any way we can.

*   *Steven Miller* in chat:

    > These are some areas of interest we noticed building Tembo
    >
    > Binary packaging / distribution:
    >
    > - Variable installation location
    > - System dependencies / uncommon system dependencies or versions
    > - Chip specific instructions (e.g. vector compiled with avx512)
    > - Extension-specific file types / extra data files (e.g. anonymizer .csv
    >   data)
    >
    > Turning on extensions automatically
    >
    > - Different ways to enable extensions
    > - does it need load (shared_preload_libraries, session_… etc)?
    > - Does it use create extension framework?
    > - Does it require a specific schema?
    > - What about turning on in multiple DBs at the same time in the same
    >   cluster, with background worker?
    > - Disabling, what data will be lost?
    > - Validating safety / user feedback on upgrade?
    >
    > In cloud / SaaS:
    >
    > - Installing + enabling extensions quickly, without restart
    > - Persisting extension files
    > - Extension-specific files (e.g. libraries) versus postgres’ libraries
    > - Updating
    > - Troubleshooting crashes / core dumps
    >
    > Anyone else have similar problems / tips?

*   *Steven Miller*: These were just things I noted during the presentation.
    Curious if these are interesting to others on the call.

*   *Daniele* in chat: "Regards binary distributions, [python wheels] might be a
    useful reference."

*   *Steven Miller*: That's good point! What do people think of idea to just
    install extensions onto servers, not packages, persisted on the disk, next
    to PGDATA so they go into a single persistent volume, and the rest is
    managed by an immutable container.

*   *Daniele*: Had experience on Crunchy where we had to replace an image to get
    an extension. Looked for feature to have a sidecar or a volume with the
    extension.

*   *Steven Miller*: Didn't have a separate directory just for extensions, it's
    just `pg_config --libdir` fore everything. Had to persist entire directory,
    including those files form the base build, their internal files. Would have
    been nice to have a separate directory, extra-libdr or extra-sharedir,
    something like that.

*   *Yurii Rashkovskii*: I was working on a patch to do exactly that, but
    haven't completed it. Was going to introduce additional directories to
    search for this stuff.

*   *Steven Miller*: That would be really awesome.

*   *Jeremy S* in chat: "Advantage of that is that a single image can be shared
    among systems with different needs"

*   *Eric* in chat: "Thoughts around “enterprise repositories” that could be
    self-hosted and disconnected from the internet?"

    *   *Ian Stanton* in chat: "I'll touch on this in the next talk, it's
        crossed our minds when building the Trunk registry"

*   *Steven Miller*: I think that's a great idea.

*   [Bagel] reappears.

*   *David Wheeler*: [PGXN] originally designed so anyone could run Manager and
    their own root mirror, and maybe rsync from the community one. Don't know
    that anyone ever did, it's a little complicated and most people don't want
    to work with Perl. [Chuckles]. Definitely think there's space for that. If
    you work with Java or Go or maybe Rust, lots of orgs like Artifactory that
    provide internal registries. Could be cool use case for Postgres extensions.

*   *David Christensen* in chat: "something that could support extension
    batches; like groups of related extensions that could be installed in bulk
    or loaded in bulk (so could accommodate the shared systems with different
    individual extension needs, but could be shared_preload_library configured)"

*   "Steven Miller" in chat: "Sounds familiar"

*   *Greg Mullane (CrunchyData) [he/him]* in chat: "All these items remind me of
    CPAN. We should see what things it (and other similar systems) get right and
    wrong. I've learned from CPAN that ratings, reviews, and badging are going
    to be very difficult."
    *   *David Christensen* in chat: "I’d assumed at the time that it was
        largely lifted (at least in philosophy/design) from CPAN. 🙂"
    *   *David Wheeler (he/him)* in chat: "yes"

*   *Jeremy S*: I think this is mostly focused on developers, but I had recent
    experience where multiple people in the past few months, new to Postgres,
    are trying to understand extensions. They install a version and then see
    there are like 15 versions installed, so confused. Goes back to the install
    file. Bit of UX angle where there are sharp edges where people trying to
    make sense of extensions, the flexibility makes it hard to understand. Some
    might be some nice guides, some architectural things explaining PGXS, or
    improvements to make to the design. Related, not main topic, but good to
    keep end user UX and devs building on Postgres but not Postgres developers,
    who run their businesses.

*   *David Wheeler*: Yeah all the files can be confusing, which is why I think
    [trunk] and [pgxman] trying to simplify: Just run this command and then you
    have it.

*   *Steven Miller* in chat: "I really agree with what Jeremy is saying. Right
    now PGXN and Trunk are taking and approach like “whatever an extension could
    do / how it may work, it should work on this registry”. But I think more
    standards / “what is a normal extension” would make the UX much easier."

*   *Jeremy S*: Even with that the available extensions view is still there. Some
    of that is just schema management, and that's how core is doing schema
    management.

*   *Steven Miller* in chat: I exactly agree about the concern about multiple
    extensions within a package. Also version and name mismatches

*   *David Wheeler*: And not everything is an extension, you just want to work, or
    your extension is just utility like pg_top you just want to use. Extensions
    I think were a tremendous contribution to Postgres itself, but a lot of it
    was wrangling the existing system for building Postgres itself to make it
    work for that. Could be very interesting, though quite long term --- and I
    know Dimitri has tried this multiple times --- to build a proper package
    management system within Postgres itself, to eas a lot of that pain and
    burden.

*   *Tobias Bussmann* in chat: "Thank you for the great overview and for taking
    this topic further! Unfortunately, I'll not be able to join at pgConf.dev
    but will follow whatever results this will lead to. As a package maintainer,
    I am constantly looking in a easy way to allow users to use extensions
    without having to package everything ;)"

*   *Steven Miller* in chat: "Like auto explain for example right. i.e. a LOAD
    only “extension”"

*   *Yurii Rashkovskii: An interesting topic, what extensions are capable of
    doing and how they can be more self-contained. Like Steven was saying in
    chat: how easy is it to load and unload extensions. Example: want an
    extension to hook into a part of Postgres: executor, planner, etc. How do
    you go about enabling them? How you unload them, introspect, list of hooks.

    Omni extension provides a list of all hooks, and when you remove an
    extension it removes the hooks that provide the extension, but still not
    part of the core. Hooks one of the greatest ways to expand the functionality
    of Postgres, allows us to experiment with Postgres before committing to the
    full cycle of getting a patch into Postgres. Lets us get it to users today
    to try. if it makes a lot of sense and people want it, time to commit to the
    process of getting a patch committed. But if we don't hve this venue, how to
    get extensions in, our ability to try things is limited.

*   *jubilee* in chat: Hmm. It seems my audio is not working.

*   *David Wheeler*: The next session is two weeks from today: Ian Stanton is
    going to talk about "Building Trunk: A Postgres Extension Registry and CLI".
    Will be interesting because a number of people have decided to build a
    binary packaging system for extensions, just to air out what the challenges
    were, what problems they wanted to solve, what problems remain, and where
    they want to take it in the future.

*   Jeremy S* in chat: "Bagel clearly has something to say"

*   *David Wheeler: jubileee I see your audio issues, do you just want to type
    your question into chat? We can also discuss things in the [#extensions]
    channel on the [Postgres Slack]

*   *David Wheeler*: Thank you all for coming!

*   *jubilee* in chat: "I had a question which is about: Does Postgres actually
    *support* docs for extensions? Like, a lot of people don't really WANT to
    read a README. Can you get docstrings for a function in psql?"

*   *Ian Stanton* in chat: "Thank you David!"

*   *jubilee* in chat: And if not, why not?

## Post Presentation Discussion

[From Slack](https://postgresteam.slack.com/archives/C056ZA93H1A/p1709762608926059):

*   *David Wheeler*: I see now that "jubilee" left their question in the Zoom chat.
*   *David Wheeler*: The closest attempt at this I've seen is [pg_readme], which
    will generate Markdown for an extension from comments in the catalog and
    write it out to a file.
*   *David G. Johnson*: The [comment on] command adds in database comments that psql
    describe commands should display.

Also [on Slack](https://postgresteam.slack.com/archives/C056ZA93H1A/p1709748156307179),
Greg Sabino Mullane started a longish thread on the things we want to do and build.


  [mini-summit]: https://www.eventbrite.com/e/851125899477/
    "Postgres Extension Ecosystem Mini-Summit"
  [the summit]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/191
  [shared preload libraries]: https://www.postgresql.org/docs/current/sql-load.html
    "PostgreSQL Docs: “LOAD”"
  [Bagel]: https://www.instagram.com/iambagelkitty/
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Extension Building Infrastructure"
  [`CREATE EXTENSION`]: https://www.postgresql.org/docs/current/sql-createextension.html
    "PostgreSQL Docs: “CREATE EXTENSION”"
  [`pg_dump`]: https://www.postgresql.org/docs/16/app-pgdump.html
    "PostgreSQL Docs: “pg_dump”"
  [`pg_restore`]: https://www.postgresql.org/docs/16/app-pgrestore.html
    "PostgreSQL Docs: “pg_restore”"
  [PGXN]: https://pgxn.org/ "The PostgreSQL Extension Network"
  [Daniele Varrazzo]: https://www.varrazzo.com
  [Dickson Guedes]: https://github.com/guedes
  [Meta Spec]:  https://pgxn.org/spec/
  [Manager]: https://manager.pgxn.org
  [Root Mirror]: https://pgxn.org/mirroring/
  [API Server]: https://github.com/pgxn/pgxn-api/wiki
  [Client]: https://github.com/pgxn/pgxnclient
  [Utils CLI]: https://github.com/pgxn/pgxn-utils
  [pgxn-utils]: https://github.com/pgxn/docker-pgxn-tools
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Docs: Extension Building Infrastructure"
  [addressed in last few weeks]: https://blog.pgxn.org/post/743059495415119873/recent-work
    "PGXN Blog: “Recent PGXN Improvements”"
  [Azure]: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-extensions
  [GCP]: https://cloud.google.com/sql/docs/postgres/extensions
  [AWS]: https://docs.aws.amazon.com/AmazonRDS/latest/PostgreSQLReleaseNotes/postgresql-extensions.html
  [stats]: https://pgxn.org/about/
  [gist]: https://gist.github.com/joelonsql/e5aa27f8cc9bd22b8999b7de8aee9d47
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
  [pgxman]: https://pgxman.com/ "npm for PostgreSQL"
  [dbdev]: https://database.dev "The Database Package Manager"
  [trunk]: https://pgt.dev "Trunk — A Postgres Extension Registry"
  [make]: https://www.gnu.org/software/make/
  [cpan]: https://www.cpan.org
  [pypi]: https://pypi.org
  [David Wheeler]: / "Just a Theory"
  [Ian Stanton]: https://www.linkedin.com/in/istanton
  [Devrim Gündüz]: https://github.com/devrimgunduz
  [yum.postgresql.org]: https://yum.postgresql.org
  [Jonathan Katz]: https://jkatz05.com
  [Yurii Rashkovskii]: https://ca.linkedin.com/in/yrashk
  [Jeremy Schneider]: https://about.me/jeremy_schneider
  [dsef]: https://pgxn.org/dist/dsef/
  [David Christensen]: https://www.crunchydata.com/blog/author/david-christensen
  [pg_kaboom]: https://pgxn.org/dist/pg_kaboom/
  [Keith Fiske]: https://pgxn.org/user/keithf4
  [pg_partman]: https://pgxn.org/dist/pg_partman/
  [python wheels]: https://pythonwheels.com
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [pg_readme]: https://pgxn.org/dist/pg_readme/0.6.6/README.html
  [comment on]: https://www.postgresql.org/docs/current/sql-comment.html
