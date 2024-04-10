---
title: Mini Summit Two
slug: mini-summit-two
date: 2024-03-25T21:49:44Z
lastMod: 2024-03-25T21:49:44Z
description: |
  A rough transcript my Ian Stanton's talk, "Building Trunk: A Postgres
  Extension Registry and CLI", along with interspersed chat comments.
tags: [Postgres, PGXN, Extensions, PGConf, Summit, trunk]
type: post
---

We had such thoughtful and engaged discussion at this week's [Postgres Extension
Ecosystem Mini-Summit][mini-summit]! I did learn that one has to reserve a spot
for each mini-summit individually, however. Eventbrite sends reminders for each
one you sign up for, not all of them.

To reserve a spot and be reminded for forthcoming meetings, hit the [Eventbrite
page][mini-summit] and select a date and hit "Reserve a Spot" for each date
you'd like to attend.

Back to this week's meetup. My colleague [Ian Stanton] of [Tembo] gave a great
talk, "Building Trunk: A Postgres Extension Registry and CLI", that provided
background on the motivations and problems that inspired the creation of
[trunk], a binary packaging system for Postgres extensions.

The presentation was followed by 35+ minutes of questions, discussion, and
brainstorming, which I've summarized below. But first, links!

*   [Video](https://www.youtube.com/watch?v=k3VC_RFL1bQ)
*   [PDF Slides]({{% link "/shared/extension-ecosystem-summit/building-trunk.pdf" %}})

Now down to business.

## Introduction

*   I opened the meeting and introduced Ian Stanton.

## Presentation

*   Ian introduced himself and [trunk], "an extension registry and CLI
    supporting [Tembo Cloud]. Wants to tell a story, starting with backstory.

*   [Tembo] founded November 2022, provide managed Postgres solution called
    [Tembo Cloud]. Idea is Postgres can be used for *so* many different things
    through the power of extensions, so built use-case optimized "stacks"
    flavors of Postgres powered by extensions and configurations. Super proud of
    them, including [Message Queue], for which we build an open-source
    extension.

*   Envisioned ability to install any extension, including user-provided
    extensions. Knew we'd need an extension management solution. So we built it.

*   It's called [trunk], an extension registry and CLI, an open-source app for
    the community that hosts binary packages for extensions, and powers Tembo
    Cloud's extension management.

*   Q1 2023 had build Tembo CLoud v1 with all extensions bundled in containers.
    But wanted way to install them on the fly, ideally with installable packages.
    Explored the ecosystem for tool we could use.

*   PGXN first we found. Love it, backed by the community, been around since
    2011, but hosted source code, not binaries. Also little development since 2012.

*   [Apt] and [Yum] repositories are community-backed and are binaries, just what we
    wanted, but smaller subset of extensions relative to the 1000s available.
    Thought it would be too time-consuming to add them all through the community
    process.

    *   *Steven Miller: in chat: "Also with apt packaging, it requires to
        install to a specific path, but we needed to customize the install
        path based on what pg_config shows for share lib and package lib dir.
        That way we could persist extension installations on tembo cloud"

*   Weighed pros and cons of building one. Pros:

    *   Full control over integration with Tembo Cloud
    *   Binary distribution
    *   We could build new features quickly
    *   We could publish new extensions quickly

    Cons:

    *   How will the community react?
    *   Recreating the wheel?

*   Expected to publish 2--3 extension a day, only do-able with a solution we
    built.

*   Want to build something meaningful for Tembo Cloud and the community.

*   [Astronomer Registry for Airflow]: Built by Astronomer to find modules
    for Airflow, very well received by the community.

*   [PGXN], [Apt], and [Yum] repos: Wanted to take the best of them and build on
    it.

*   [crates.io]: Wanted a similar great experience for Postgres extensions.

*   Vision boiled down to discoverability, categories, ratings system,
    certification, and indexing of cloud provider support.

*   Want to package any extension, whether SQL, C/SQL, or [pgrx].

*   Simple experience, like `cargo publish` and `cargo install cargo-pgrx`.

    *Eric* in chat: "❤️"

*   Hopes and Dreams: had idea people would magically show up, contribute to the
    code, and publish their extensions. Wanted to support multiple platforms,
    architectures, and Postgres versions, and for it to be a one-stop shop for
    Postgres extensions.

*   How it works.

*   CLI and Registry, written in Rust, uses Docker to build extensions. Packages
    named `<trunk-project-name>-<version>-<pg-version>.tar.gz`. Published with
    `trunk publish` and installed with `trunk install`, putting all the files in
    the right places.

    *   *Steven Miller* in chat: "The approach to use docker for building has
        been nice. It allows for cross-compile, for example, building for any
        platform docker supports with the —platform flag"

*   Registry stores metadata and service web site and API, and uses S3 bucket
    for the tar-gzip files.

*   Example building [semver] extension:

    ```
    Create Trunk bundle:
    bitcode/src/semver/src/semver.bc
    bitcode/src/semver.index.bc
    semver.so
    licenses/LICENSE
    extension/semver--0.10.0--0.11.0.sql
    extension/semver--0.11.0--0.12.0.sql
    extension/semver--0.12.0--0.13.0.sql
    extension/semver--0.13.0--0.15.0.sql
    extension/semver--0.15.0--0.16.0.sql
    extension/semver--0.16.0--0.17.0.sql
    extension/semver--0.17.0--0.20.0.sql
    extension/semver--0.2.1--0.2.4.sql
    extension/semver--0.2.4--0.3.0.sql
    extension/semver--0.20.0--0.21.0.sql
    extension/semver--0.21.0--0.22.0.sql
    extension/semver--0.22.0--0.30.0.sql
    extension/semver--0.3.0--0.4.0.sql
    extension/semver--0.30.0--0.31.0.sql
    extension/semver--0.31.0--0.31.1.sql
    extension/semver--0.31.1--0.31.2.sql
    extension/semver--0.31.2--0.32.0.sql
    extension/semver--0.32.1.sql
    extension/semver--0.5.0--0.10.0.sql
    extension/semver--unpackaged--0.2.1. sql
    extension/semver.control
    extension/semver.sql
    manifest. json
    Packaged to •/. trunk/pg_semver-0.32.1-pg15.tar.gz
    ```

    Package up SQL files, control file, SO files, bitcode files into gzip file.

*   Once it's published, API [surfaces all this information]:

    ``` json
    [
      {
        "name": "pg_semver",
        "description": "A semantic version data type for PostgreSQL.",
        "documentation_link": "https://github.com/theory/pg-semver",
        "repository_link": "https://github.com/theory/pg-semver",
        "version": "0.32.0",
        "postgres_versions": [
          15
        ],
        "extensions": [
          {
            "extension_name": "semver",
            "version": "0.32.0",
            "trunk_project_name": "pg_semver",
            "dependencies_extension_names": null,
            "loadable_libraries": null,
            "configurations": null,
            "control_file": {
              "absent": false,
              "content": ""
            }
          }
        ],
        "downloads": [
          {
            "link": "https://cdb-plat-use1-prod-pgtrunkio.s3.amazonaws.com/extensions/pg_semver/pg_semver-pg15-0.32.0.tar.gz",
            "pg_version": 15,
            "platform": "linux/amd64",
            "sha256": "016249a3aeec1dc431fe14b2cb3c252b76f07133ea5954e2372f1a9f2178091b"
          }
        ]
      },
      {
        "name": "pg_semver",
        "description": "A semantic version data type for PostgreSQL.",
        "documentation_link": "https://github.com/theory/pg-semver",
        "repository_link": "https://github.com/theory/pg-semver",
        "version": "0.32.1",
        "postgres_versions": [
          15,
          14,
          16
        ],
        "extensions": [
          {
            "extension_name": "semver",
            "version": "0.32.1",
            "trunk_project_name": "pg_semver",
            "dependencies_extension_names": null,
            "loadable_libraries": null,
            "configurations": null,
            "control_file": {
              "absent": false,
              "content": "# semver extension\ncomment = 'Semantic version data type'\ndefault_version = '0.32.1'\nmodule_pathname = '$libdir/semver'\nrelocatable = true\n"
            }
          }
        ],
        "downloads": [
          {
            "link": "https://cdb-plat-use1-prod-pgtrunkio.s3.amazonaws.com/extensions/pg_semver/pg_semver-pg14-0.32.1.tar.gz",
            "pg_version": 14,
            "platform": "linux/amd64",
            "sha256": "f412cfb4722eac32a38dbcc7cd4201d95f07fd88b7abc623cd84c77aecc8d4bb"
          },
          {
            "link": "https://cdb-plat-use1-prod-pgtrunkio.s3.amazonaws.com/extensions/pg_semver/pg_semver-pg15-0.32.1.tar.gz",
            "pg_version": 15,
            "platform": "linux/amd64",
            "sha256": "9213771ffc44fb5a88726770f88fd13e62118b0f861e23271c3eeee427a23be9"
          },
          {
            "link": "https://cdb-plat-use1-prod-pgtrunkio.s3.amazonaws.com/extensions/pg_semver/pg_semver-pg16-0.32.1.tar.gz",
            "pg_version": 16,
            "platform": "linux/amd64",
            "sha256": "8ffe4fa491f13a1764580d274e9f9909af4461aacbeb15857ab2fa235b152117"
          }
        ]
      }
    ]
    ```

    Includes different tar-gzip files for different versions of Postgres, the
    contents of the control file, dependencies; loadable libraries and
    configurations; and the one extension in this package --- some can have many
    like [PostGIS]. Then Postgres version support and some other metadata.

*   What it looks like [on the web site], includes README contents, data from
    the last slide, install command, etc.

*   This is what installation looks like:

    ``` console
    $ trunk install pg_semver
    Using pkglibdir: "/usr/lib/postgresql/16/lib"
    Using sharedir: "/usr/share/postgresql/16"
    Using Postgres version: 16
    info: Downloading from: https://cdb-plat-usel-prod-pgtrunkio.s3.amazonaws.com/extensions/pg_semver/pg_semver-pg16-0.32.1.tar.gz
    info: Dependent extensions to be installed: []
    info: Installing pg_semver 0.32.1
    [+] bitcode/src/semver/src/semver.bc => /usr/lib/postgresql/16/lib
    [+] bitcode/src/semver. index.bc => /usr/lib/postgresql/16/lib
    [+] semver.so => /usr/lib/postgresql/16/lib
    info: Skipping license file licenses/LICENSE
    [+] extension/semver--0.10.0--0.11.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.11.0--0.12.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.12.0--0.13.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.13.0--0.15.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.15.0--0.16.0.sql = /usr/share/postgresql/16
    [+] extension/semver--0.16.0--0.17.0.sql => /us/share/postgresql/16
    [+] extension/semver--0.17.0--0.20.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.2.1--0.2.4.sql => /usr/share/postgresql/16
    [+] extension/semver--0.2.4--0.3.0.sql > /us/share/postgresql/16
    [+] extension/semver--0.20.0--0.21.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.21.0--0.22.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.22.0--0.30.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.3.0--0.4.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.30.0--0.31.0.sql = /usr/share/postgresql/16
    [+] extension/semver--0.31.0--0.31.1.sql => /usr/share/postgresql/16
    [+] extension/semver--0.31.1--0.31.2.sql => /usr/share/postgresql/16
    [+] extension/semver--0.31.2--0.32.0.sql => /usr/share/postgresql/16
    [+] extension/semver--0.32.1.sql => /usr/share/postgresql/16
    [+] extension/semver--0.5.0--0.10.0.sql => /usr/share/postgresql/16
    [+] extension/semver--unpackaged--0.2.1.sql => /usr/share/postgresql/16
    [+] extension/semver.control => /usr/share/postgresql/16
    [+] extension/semver.sql => /usr/share/postgresql/16

    ***************************
    * POST INSTALLATION STEPS *
    ***************************

    Install the following system-level dependencies:
            On systems using apt:
                libc6

    Enable the extension with:
           CREATE EXTENSION IF NOT EXISTS semver CASCADE;
    ```

    CLI pulls down the tar-gzip, unpacks it, and puts the files in the right
    places and tells the users what other commands are needed to enable the
    extension.

*   Pause to take a sip of water.

    *   *David Wheeler (he/him)* in chat: "STAY HYDRATED PEOPLE!"

*   State of the project. Trunk powers extension management for Tembo Cloud, 200
    extensions on the platform, install and enable on the fly. Tembo Cloud likely
    trunk's #1 user.

*   Get lots of site traffic, especially around categorization, addresses the
    discoverability problem set set out to solve.

    *   *Jeremy S* in chat: "Interested in insights from site traffic - you
        mentioned that 'categorization' was popular - any other things that
        traffic patterns seem to suggest you might have done really well, or
        clearly is needed?"

*   But pretty minimal community involvement, out fault for not involving the
    community early on.

*   Did we solve the problem?

    *   For Tembo Cloud: yes! Trunk is core component of the Tembo Cloud
        platform that lest us offer high number of extensions.
    *   For the community: no! But helped bring more awareness to the
        opportunities to improve the ecosystem as a community.
    *   Saw other solutions arise around the same time, including [dbdev] and
        [pgxman], and Yurri at [Omnigres] is working on something as well. Huge
        opportunity to solve this together.
    *   *Steven Miller* in chat: "I think it is very nice way to install other
        extensions via an extension how dbdev works"
    *   *David Wheeler (he/him)* in chat: "GRANT!"
    *   *Grant Holly* in chat: "Oh hi"

*   Lessons Learned

    *   It's a really hard problem to solve! As you add more layers of
        complexity, like different architectures, versions of Postgres,
        it gets harder and harder.

        *   *Steven Miller* in chat, Replying to "The approach to use ...": "The
            downside for this approach includes missing chip-specific
            instruction support, for example AVX512, which optimizes performance
            on some extensions. However if you are building with docker on the
            same architecture as the host, then it still includes these
            instructions."

        *   *David Wheeler (he/him)* in chat, Replying to "The approach to use
            ..." "Also presumably no support for building for non-Linux
            platforms, yes?"

    *   The extension ecosystem truly is the wild west, not really best
        practices around building, versioning, and releasing, and when you're
        collecting and housing them, it makes things difficult. A huge
        opportunity for us to come up with those standards and share them with
        the community.

    *   Community involvement is crucial, wish we'd done it better early on,
        that's why we're all here today! Solution to build together doesn't
        happen if we don't tackle it as a community.

    *   Similarly, wish we'd reached out to folks like David and Devrim early
        on, to get more insight from them and bring the community into the
        project from the beginning

*   The future of trunk

    *   Registry and CLI will continue to serve Tembo Cloud

    *   Has paved the way for binary packaging and distribution in PGXN v2 that
        David is spearheading, will at least will inform and perhaps be the
        basis for that part of the project.

*   That's all, thank you, back to you, David!

## Discussion

*   David Wheeler (he/him): Thanks for history an context, Ian! Questions or
    discussion topics? Some comments in the thread from Steven and Tobias.

    *   *Tobias Bussmann:* in chat: speaking of paths: it would be super helpful
        if postgresql would support loading extensions from additional paths
        beside the $SHAREDIR/extension and $PKGLIBDIR directories. At least
        following directory symlinks within...

    *   *Steven Miller* in chat, Replying to "The approach to use ...": I tried
        to make it work for Mac, for example, but the docker support didn’t work
        basically. I think it might work for Windows, since they have better
        container support. However I didn’t try that yet.

*   David Wheeler (he/him): *Reads Tobias's comment.* You can specify a
    subdirectory in the `sharedir` and *maybe the `moduledir`?* But it's a
    little hinky right now. Steve, do you want to talk about the us of Docker to
    build images?

*   Steven Miller: Yeah, I'd love to. To Tobias's point, agree, on Tembo Cloud,
    we have a persistent directory where wer're sintalling extensions, but
    because there is no way for an extra `sharedir` or package dir, we're
    persisting *all* of the library files, including Postgres core. Not ideal,
    especially for upgrades.

    Approach for building ind Docker: been nice, do the build ina Dockerfile,
    start the container, then install and compare the difference between layers
    and zip up all the new files. Great for cross-compile but, not working for
    mac or other systems. Will need a fallback option to do a local build.

    *   *Jeremy S:* in chat, Replying to "speaking of paths: i...": Exactly same
        point was also mentioned just this morning on slack by Matthias

*   David Wheeler (he/him): Makes sense, thanks. What other bits do you feel
    like could be useful for packaging binaries at a community level?

*   Steven Miller: Sometimes we install binaries with trunk, but then difficult
    to know what has been installed. Nothing like apt where there is a history
    of what is installed or uninstall. Would be nice to do something like `trunk
    list` and see everything that has been installed. Also, future should be not
    just install but management, including turning extensions on, and there are
    a lot of ways to turn them on.

*   Ian Stanton: `uninstall` would be useful, too.

*   David Wheeler (he/him): Other questions about trunk or challenges to binary
    distribution it brings?

    *   *Tobias Bussmann in chat, Replying to "speaking of paths: i...": this
        would allow an immutable PostgreSQL base package and still allow to
        install extensions on top. This is esp. important if you need to have
        singned packages like on macOS

    *   *nils in chat, Replying to "speaking of paths: i...": Guess there is
        some prior art in how search_path in pg work, or the PATH in unix’s.

        Should be doable to allow to specify some kind of ordered search path,
        where Postgres will look for extensions. That way, Postgres can protect
        it’s own libs to no be overwritten by external libs, but allow for
        loading them from extra paths.

*   Yurri: There is `CREATE EXTENSION` and other extensions like logical
    decoding plugins. Does trunk handle them?

*   Steven Miller: We think of it as four types extensions into 2x2 matrix: 1\.
    Does it require `CREATE EXTENSION` true or false; and 2\. Does it have a
    loadable library true or false. The false/false category is output plugins;
    The true/true category, e.g. `pg_partman`, `pg_cron`; `CREATE EXTENSION` false
    and loadable library true, e.g., `autoexplain`, just a library, no upgrade
    concerns; and then `CREATE EXTENSION` true and loadable library false is the
    default case.

*   Ian Stanton: Steven wrote [a blog](https://tembo.io/blog/four-types-of-extensions)
    on this.

    *   *Eric* in chat: Does pgrx make the process of building easier or harder
        and is there anything we can do today to make rust extension building
        better?

    *   *Jason Petersen* in chat: Yeah, it sounds like we need some sort of
        system database like apt has; would enable management, uninstall,
        version list, whether upgrades are available, etc

*   Yurri: That would be great. What other modules are there without extensions,
    like `autoexplain`?

*   Ian Stanton: auth delay is another, base backup to shell, considered parts of
    postgres, but we have trouble categorizing them. There are 10-15 I've come
    across.

*   Yurri: ARe these categories on Tembo, can you click a button?

*   Ian Stanton: Not a category, but would be a good one to add.

    *   *Steven Miller* in chat: This one! https://tembo.io/blog/four-types-of-extensions

        It’s in the API metadata

        Sorry if I mispronounced your name Tobias

    *   *David Wheeler (he/him)* in chat: SAME

*   Yurri: Did you say output plugins are handled with Tembo:

*   Steven Miller: YOu can install them with trunk, yes.

*   Yurri: And you have the build pipeline that will work without plugins too,
    yeah, cool.

*   David Wheeler (he/him): Tobias, did you want to say more about the path
    issues?

*   Tobias Bussmann: Sure! We are building the Postgres.app, distribution for
    macOS, working different from Linux systems. We distribute some extensions
    directly, but also allow building and installing extensions on it. Works
    nicely, even with pgxn client, but it's built within the application, which
    breaks the code signature.

    We always have to fight against a breaking system to allow that. Possible,
    but would be much cleaner to specify an extra directory where extensions
    could be loaded, and we could distribute packages with binary extensions
    that the user could download and install separately from the Postgres.app.

*   David Wheeler (he/him): You're not suggesting a different directory for
    every extension with a module, but just another path in the search path
    that's not subject to the signature verification.

*   Tobias Bussmann: Yes, that would be an option, but with a flexible system
    could use one per extension or just specify a second directory. Contrib
    extensions sometimes seen as part of Postgres, and they're all stuffed in
    the same directory with third party extensions, which gets confusing and
    hard to manage.

    *   *Steven Miller* in chat: In the previous extensions mini summit, Yuri
        mentioned that he was working on a patch to postgres for extra libdir,
        extra share dir, but I have not been tracking this one

*   nils: That's what I was saying in chat, there is prior art in Postgres and
    Unix systems where you can specify a search path in postgres for a list of
    schemas, and in Unix the path is to find binaries. Give me a delimited list
    of directories on my system. Could be super user only, where they can
    specify where they're installed, and we can go through the list ot find an
    extension.

*   David Wheeler (he/him): I might be imagining this, but I seem to recall
    there was a proposal to have extensions in their own directories, which
    would be nice for packaging, but then every time you add one you have to add
    another directory to the list and there is some fear the lookup time could
    be too long.

    *   *Jeremy S* in chat, replying to "speaking of paths: i...": (Or like
        LD_LIBRARY_PATH )

    *   *David Wheeler (he/him)* in chat, replying to "speaking of paths: i...":
        LD_LIBRARY_PATH is all but dead on macOS

*   Jason Petersen: If it happens at startup I can't imagine that being a
    concern. If the list changes you reboot. It's not gonna be a performance
    problem, I hope.

*   *David Wheeler (he/him): Or HUP it if you don't want downtime.

*   Jason Petersen: Sure, but it doesn't need to be on every command.

*   *David Wheeler (he/him): Eric, do you want to pose your question about pgrx?

*   Eric: Sure. Wanted to know, were there stumbling blocks to get pgrx support
    built into trunk, and does it make things easy or difficult? Different from
    C path, are there things we could do to make things easier today?

*   Ian Stanton: Yeah, I think the issue is mostly on our end. We have a
    separate image for each version of pgrx, and keeping up with the releases is
    challenging. We need to rethink our image building strategy. Shouldn't be
    one image for each version of pgrx. That's the biggest thing I've noticed,
    mostly on our side.

*   *David Wheeler (he/him): Because you need the install the version of pgrx
    that the extension requires before you do the build, and that's just too slow?

*   Ian Stanton: Could be too slow. We've known about this problem for some
    time, just hasn't been addressed yet.

*   Eric: Okay, maybe we can talk about it offline one day, be happy to chat. I
    think we're close to being able to have the CLI, cargo-pgrx, be a different
    version than whatever version the extension uses.

*   Ian Stanton: That would be super useful!

*   Eric: Yeah, I think we're close to being at that point, if not there
    already. We can talk about that offline.

*   Ian Stanton: Nice! We'll reach out in Discord.

*   *David Wheeler (he/him): Other comments or questions, or people who have
    worked on other kinds of binary registry things, would love to hear more
    from other perspectives. Devrim is going to talk about the Yum repository
    next week [ed. correction: in two weeks].

*   *Steven Miller* in chat: Daniele last time mentioned Pip is good example of
    mixing source and binary distributions

*   Eric: I have a random question related to this. In the past and recent
    history, has hackers talked about some way of storing extension in the
    database rather than relying on the file system?

*   *David Wheeler (he/him): Yes! In [this long thread from 2011][] [ed.
    Correction: 2013] Dimitri was proposing a "unit", a placeholder name, where
    the object would be stored in the database. Very long thread, I didn't read
    the whole thing, lot of security challenges with it. If it needs a shared
    object library loading having to be written to the file system it's just not
    going to happen. I don't know whether that'd be required or not.

    Dimitri also worked on a project called [pginstall] where you could install
    extensions from the database like [dbdev], but not just TLEs, but anything.
    The idea is a build farm would build binaries and the function in the
    database would go to the registry and pull down the binaries and put them
    in the right places on the file system.

    There were a lot of interesting ideas floating around, but because of the
    legacy of the PGXS stuff, it has always been a bit of a struggle to decide
    *not* to use it, to support something not just on the machine, but do
    something over libpq or in SQL. Lot of talk, not a lot of action.

    *   *Tobias Bussmann in chat in response to "In the previous ex...": still
        searching on hacker for it. Meanwhile I found:
        https://commitfest.postgresql.org/5/170/

    *   *Steven Miller* in chat: That approach is very awesome (install via
        extension)

*   Eric: I can see why it would take some time to sort it all out. One thing to
    require super user privileges to create an extension, but also having root
    on the box itself? Yeah.

*   Yurri: TLE plugs into that a little bit for a non-shared object. Not exactly
    storing it in the database, but does provide a SQL based/function method of
    installing from inside the database, but only for trusted languages, not
    shared objects.

*   *David Wheeler (he/him): `dbdev install` does download it from database.dev
    and stores it in the database, and has hooks into the `CREATE EXTENSION`
    command and pulls it out of its own catalog. Was a similar model with
    `pginstall`, but with binary support, too.

*   Yurri: Back to trunk. When you start building, and have to deal with
    binaries, pgxn you can put the source up there, but I want to get to the
    whole matrix of all the different versions. Every extension author does it a
    little different. Some extensions have versions for Postgres 15, another for
    14, some have the same version across all the majors, sometimes an extension
    works for some majors and others. Has trunk expanded to other Postgres
    versions to support the whole exploding matrix of stuff that does and
    doesn't work, 5-6 majors, gets to be a large matrix, a lot to keep track of.
    How's that working out for the builds and managing that matrix.


    *   *Steven Miller* in chat: Dimensions I think are:
        - pg version
        - architecture
        - chip-specific instructions (edge case for native builds?)

*   *Steven Miller* in chat: We just announced support for 14 and 16

    *David Wheeler (he/him)* in chat, replying to "Dimensions I think a...": OS,
    OS version

*   *Steven Miller* in chat,: Replying to "Dimensions I think a...": Ah right

*   Ian Stanton: Steven do you want to take that one?

*   Steven Miller: Oh yeah. We've started toe-dipping on this one. Started with
    Tembo Cloud's platform, but have no released Postgres 14 and 16, and also
    trunk has built-in support for other architectures, such as arm, or whatever
    the Docker `--platform` flag supports. We looked at mac builds, not working
    yet, might work for Windows, which ahs better container support, but I don't
    know, and also there is an edge case for pg_vector especially, which
    compiles to include ship-specific instructions for AVX512, which helps with
    vector. So that's another dimension to consider.

*   Yurri: Part of the idea behind this forum is to see if we can chart a path
    forward, maybe not solve everything. What can we solve, how can we make
    something a little better for Postgres at large?

    *   *Eric* in chat: Even as a Mac user I don’t know the answer to this…
        what’s the common Postgres package there?  Postgres dot app, homebrew,
        something else?

    *   *David Wheeler (he/him)* in chat: [pgenv]! (self-promotion)


    *   *Eric* in chat: I assume folks don’t use macOS in prod but developers are important too

    *   *nils* in chat, Replying to "Even as a Mac user I...":

        ```
        $ git clone ..
        $ ./configure
        $ make
        $ make install
        ```

        At least that is what I do 😄

*   Steven Miller: In my opinion, the way to approach it is to know all the
    dimensions you need, and in the metadata API say which binaries are
    available. Then get through it with testing and badging If we let things get
    built, to what extent is it tested and used? That can help. Daniele was in
    the previous call, said we could look to Pip and Wheel files for
    inspiration, and Adam on our team has said the same. This is something that
    has some binary and some source, and falls back on doing the build when it
    needs to.

*   *David Wheeler (he/him): I've been thinking about this quite a bit lately.
    Can see needing to take advantage of multiple platforms available through
    GitHub workflow nodes or the [community's build farm], which has a vast
    array of different architectures and platforms to build stuff. There are
    precedents!

    I imagine a system where, when something is published on PGXN, another
    system is notified and queues it up to all its build farm members to build
    binaries, ideally without full paths like trunk, and making them available
    for those platforms. Building out that infrastructure will take a fair bit
    of effort, I think. With cross-compiling is available it might be…doable?
    But most modules and for SQL and maybe Rust or Go extensions, but a
    challenge for C extensions.

    This is a problem I'd like us to solve in the next year or two.

    *   *Steven Miller* in chat, replying to "I assume folks don’t...": Yeah
        exactly, like trunk install after brew install postgres

    *   *Tobias Bussmann* in chat, replying to "Even as a Mac user...": this
        seems to be quite spread. There are also people that prefer docker based
        installs

    *   *Eric* in chat: pgrx supports cross compilation

        With a caveat or two!

    *   *Eric* in chat, replying to "Even as a Mac user I…" @nils same. For v9.3
        though 16!

*   *David Wheeler (he/him): What else? Reading the comments.

*   Yurri: I think maybe that PGXN JSON file, I know you've been spending time
    on it, David, including the [proposal on namespacing] a few days ago. That
    feels like it could be helpful to be part of this. IF it could be something
    we could center around… The first time I wanted to put an extension on PGXN,
    it took me a long time to figure out that JSON file. I didn't find the blog
    post that goes through it in nice detail till like two weeks after. If I'd
    found it sooner I could have skipped so many things I tried to figure out on
    my own.

    If we can center around that file, it'll draw more attention to it, more
    links back to it, more examples people blog about here and there, it helps
    going forward. The trick is getting it right not being this massive thing no
    one can figure out, or has too many options, but hits all the points we
    need.

    *   *nils* in chat, replying to "Even as a Mac user I...": Well, mostly for
        extension, for Postgres I rely on David’s pgenv

    *   *Eric * in chat, replying to "Even as a Mac user I…": @Tobias Bussmann
        hmm. Makes it difficult to get an extension installed.

*   *David Wheeler (he/him): I've been thinking about this a lot, drafted a doc
    some of my colleagues at Tembo have read over and I hope to publish soon
    [ed. Note: [now published]], thinking through what a v2 of the [PGXN Meta
    Spec] might include. I think we should extend with list of external libraries
    required, or the architectures it supports, or it's a loadable library or an
    app that doesn't even go into the database.

    I would like soon to draft an actual revision of the spec, and document it
    well but also turn it into a JSON Schema document so we can automate
    publishing it and verification in the same place. I also imagine building an
    eventual replacement or evolution of the PGXN client or trunk client or some
    client that you can use to manage that thing. I think pgrx does that, adding
    metadata via the client rather than parse and understand the whole file.

    I'm with you it could get really complicated, but I'm not sure I see an
    alternative other than building good tooling to minimize the pain.

*   Ian Stanton: I think automatically pulling that information when it's
    readily available would be super helpful. We use it as an app to just take
    care of things for people.

*   *David Wheeler (he/him): Right, and then if we're successful in getting it
    done it's getting people to take up the tools and start using them. There's
    only so much we can infer. I can tell how to do a build if there's a
    `Makefile` or a `configure` file or a `cargo.toml`, but that doesn't reveal
    what libraries are required. This is why there's a lot of hand-tuning of
    RPM and Apt spec files.

    *   *Steven Miller* in chat: We are calling this “system dependencies”

        Ssl and glibc the main ones 🙂

    *   *Jason Petersen* in chat: And sometimes the package names aren’t even
        1—1 mappings

    *   *Eric* in chat: Ha!  Try relying on elasticsearch as a runtime
        dependency!  😞

*   Yurri: That's another thing to touch on. A lot of extensions are just a thin
    layer of glue between Postgres and some OSS library that someone else
    maintains. But the trick, when you want to build a Yum package, the
    dependency has a different name than the rest of the RedHat ecosystem vs.
    the Debian ecosystem. So part of what Devrim has to do to maintain the RPM
    packages is manually sort all that out, because you can't automatically...
    *libc*! It's called `glibc` in RedHat and just `libc` in Debian, and every
    package has slightly different names. Do how do you manage that in trunk? Do
    you pull the source for any dependencies? Does your Docker image...I don't
    know how this is working.

    *   *David Wheeler (he/him)* in chat: I want to build a json schema
        validation extension in Rust using
        https://github.com/Stranger6667/jsonschema-rs or something

    *   *Tobias Bussmann* in chat, replying to "Ha!  Try relying o...": or V8 🤯

*   Ian Stanton: Two sides to that one is build time dependencies, and there
    there are runtime dependencies. I just dropped an example for some random
    extension. Tthe way we've been building this is to write out a `Dockerfile`
    that can include build time dependencies. [hunts for link...]

    *   *Ian Stanton* in chat: https://github.com/tembo-io/trunk/blob/main/contrib/age/Dockerfile

*   Ian Stanton: We specify them all there. But for runtime, we don't know
    what's required until we test the thing. We have stuff in our CI pipelines
    to install and enable the extension to see if it works. If it doesn't, it
    will report a missing dependency. Then we know we need to add it to our
    Postgres images. Not the best flow for finding these dependencies. Steven,
    want to add anything more to the build time dependency piece?

    *   *David Wheeler (he/him)* in chat, replying to "Ha!  Try relying on ...":
        Next version of plv8 released on PGXN will have v8 bundled

*   Steven Miller: A lot share the same ones, SSL and glibc, so we just build
    with the same versions we run on Tembo Cloud. In the metadata we list all
    system dependencies, that's what we build towards, and include them in the
    Docker image. If you pick a different stack, like the Machine Learning
    stack, it has all the Python stuff in the base image. We don't really love
    this, but this is something where Python wheel might inspire us, becaus it
    has packaging and system dependencies.

    *   *Eric* in chat, replying to "I want to build a js…": I feel like I’ve
        seen one already?

    *   *David Wheeler (he/him)* in chat, replying to "I want to build a js...":
        GIMME

*   Yurri: If you really want to od this right, just like in the RPM
    repositories, you have to know what the dependencies are. David, I'm
    curious, what your thoughts are, if this is to be done right, there has to
    be a way to indicate dependencies in the `META.json` file, but then I'm
    talking about Debian and RedHat, but what about Mac? Windows doesn't really
    have a packaging system. There are BSDs, other places Postgres can run,
    probably have to narrow the scope a bit to solve something.

*   *Tobias Bussmann* in chat, responding to "Ha!  Try relying o..." Sounds
    promising, but for which architectures? I have good hope for pljs as
    replacement for plv8

*   Ian Stanton in chat:
    https://github.com/tembo-io/trunk/blob/d199346/contrib/fuzzystrmatch/Trunk.toml#L13

*   David Wheeler (he/him): Fortunately there are only around 1100 extensions in
    the world, a relatively low barrier at this point. Some of these other
    things have thousands or millions of extensions.

*   Yurri: I guess when you put it that way! But I wasn't going to go through
    all 1000 of them one-at-a-time.

*   David Wheeler (he/him): No. I posted about this on Ivory a few weeks ago
    [ed. correction: he means [on Mastodon]]: how does one do this in a
    platform-neutral way. There are some emerging standards where people are
    trying to figure this stuff out. One is called [purl], where you specify
    dependencies by packing URLs, or "purls", and then it's up to the installing
    client to resolve them vai whatever the packaging system it depends on.

    I would assume on Windows we'd have to say "it works great as long as you
    use [Chocolatey]" or something like that. But it's certainly a difficult
    problem. I'm looking forward to your talk about your unique approach to
    solving it, Yurrii [ed. note: that's the May 1 mini-summit], that's going to
    be super interesting.

*   David G. Johnston: Ultimately you just crowd sourcing. If we just say "this
    is what we call this thing in PostgreSQL world", then if people need to
    compile it on Chocolatey on Windows, they figure it out and contribute it.
    Or on Debian or RedHat. Just facilitate crowd-sourcing, metadata in a
    database.

*   David Wheeler (he/him): My initial idea was a global registry that people
    contribute to just by editing files in a GitHub repository.

*   David G. Johnston: HashiCorp has to have something like that already,
    there's stuff out there, no need to reinvent the wheel. This is a global
    problem if we open-source it we can solve it.

*   David Wheeler (he/him): Right. Really appreciate everyone coming. Great
    discussion, I appreciate it. In two weeks, Devrim Gündüz is going to talk
    about the Yum Community Repository and the challenges of RPMifying
    extensions. I had this idea of automating adding extensions to the Yum and
    Apt repositories, an Devrim is a little skeptical. So super look forward to
    his perspective on this stuff. Two weeks from today at noon [ed.:
    America/New_York]. Thanks for coming!


    *   *Eric* in chat: Thanks a ton!  This is exciting stuff.
    *   *Tobias Bussmann* in chat: Thanks all!

    *   *Grant Holly* in chat: Thanks everyone. Great discussion

    *   *Jeremy S*: in chat: Thanks david

    *   *Steven Miller* in chat: Thanks all! Cya next time

    *   *Jeremy S* in chat: Isn’t bagel supposed to come for the end

    *   *Ian Stanton* in chat: Thanks all :)

  [mini-summit]: https://www.eventbrite.com/e/851125899477/
    "Postgres Extension Ecosystem Mini-Summit"
  [Ian Stanton]: https://www.linkedin.com/in/istanton
  [Tembo]: https://tembo.io "Tembo: Goodbye Database Sprawl, Hello Postgres"
  [trunk]: https://pgt.dev "trunk: A Postgres Extension Registry"
  [Tembo Cloud]: https://cloud.tembo.io
  [Message Queue]: https://tembo.io/docs/product/stacks/transactional/message-queue
    "tembo Docs: Message Queue"
  [PGXN]: https://pgxn.org "PGXN — PostgreSQL Extension Network"
  [Apt]: https://wiki.postgresql.org/wiki/Apt
    "PostgreSQL packages for Debian and Ubuntu"
  [Yum]: https://yum.postgresql.org "PostgreSQL Yum Repository"
  [Astronomer Registry for Airflow]: https://registry.astronomer.io
  [crates.io]: https://crates.io "The Rust community’s crate registry"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "Build Postgres Extensions with Rust!"
  [surfaces all this information]: https://registry.pgtrunk.io/api/v1/trunk-projects/pg_semver
  [on the web site]: https://pgt.dev/extensions/pg_semver
  [dbdev]: https://database.dev "The Database Package Manager"
  [pgxman]: https://pgxman.com/ "npm for PostgreSQL"
  [Omnigres]: https://omnigres.com "Omnigres: Postgres as a Platform"
  [this long thread from 2011]: https://www.postgresql.org/message-id/flat/m2r49a5uh8.fsf_-_%402ndQuadrant.fr#3ceccb32533e81a1be084122ebf8d96f
  [pginstall]: https://github.com/dimitri/pginstall
  [pgenv]: https://github.com/theory/pgenv
  [community's build farm]: https://buildfarm.postgresql.org
  [proposal on namespacing]: {{% ref "/post/postgres/extension-namespace-rfc" %}}
    "Extension Registry Namespacing RFC"
  [Now published]: {{% ref "/post/postgres/rfc-pgxn-metadata-sketch" %}}
    "RFC: PGXN Metadata Sketch"
  [PGXN Meta Spec]: https://pgxn.org/spec/
  [on Mastodon]: https://xoxo.zone/@theory/111983275190519842
  [purl]: https://github.com/package-url/purl-spec
    "purl-spec: A minimal specification for purl a.k.a. a package “mostly universal” URL"
  [Chocolatey]: https://chocolatey.org "The Package Manager for Windows"
  [semver]: https://pgxn.org/dist/semver "semver on PGXN"
  [PostGIS]: https://postgis.net
