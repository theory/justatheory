---
title: "PGXN v2: Go or Rust?"
slug: pgxn-language-choices
date: 2024-03-28T20:14:12Z
lastMod: 2024-10-08T19:54:48Z
description: |
  What programming language(s) should we use to build new and revamp existing
  PGXN services and tools: Rust or Go? Vote your preference!
tags: [Postgres, PGXN, Go, Rust, Perl]
type: post
---

TL;DR: I'd like Postgres community input on a decision: Should we build PGXN
v2 services and tools in Go or Rust? Context for the question and some
weighing of options constitutes the rest of this post, but to skip to the end,
[🗳️ Vote] your choice! Poll closes April 12 at the end of the day (midnight)
New York time.

----

The [PGXN v2 project] now under way requires developing or updating several
services and tools, including:

*   A [root registry] for source distribution
*   A [package registry] for binary distribution
*   A [command line client] for developing, building, and distributing
    extension packages
*   An [interactions service] for notifications and stats aggregation

And more. Historically, the PGXN tools were written in [Perl], which was an
ideal choice for me back in 2011, and quite familiar to many members of the
core team, but also deeply foreign to most everyone else. Furthermore, its
dynamic nature and need for dozens of dependencies in most apps makes
installation and packaging a challenge, to say the least.[^community]

In the last ten years I've become quite proficient in [Go]. I appreciate its
near system-level performance, memory safety, robust standard library,
concurrency design, and short learning curve --- especially for web services.
But perhaps most eye-opening to me, as a long-time user of dynamic languages,
is that, like C, Go compiles an application into a single static binary. Not
only that, but Go provides [cross compilation] natively. This makes
distribution incredibly simple.

Distribution Digression
-----------------------

Compare, for example, [the `Dockerfile`] for [Sqitch], the database change
management system I wrote and maintain in Perl. It's...a *lot.* Sure there are
a ton of system dependencies, but what's invisible in this file is the weeks
of work that went into [Module::Build::Sqitch], which performs a bunch of
tricks to build the Sqitch "app" as a single directory with all of its Perl
dependencies. Don't get me wrong, the work was worth it for Sqitch, and powers
the [Homebrew formula], as well. But even there, I've not been able to get
Sqitch into the [Homebrew core] because every single dependency requires a
checksum, and I've not had the time (or energy) to figure out how to generate
them.

Contrast with this `Dockerfile` for a Go service compiled into a binary named
`thinko`:

``` Dockerfile
FROM gcr.io/distroless/base-debian12:latest

# TARGETOS and TARGETARCH: https://docs.docker.com/build/guide/multi-platform/
ARG TARGETOS
ARG TARGETARCH

COPY "_build/${TARGETOS}-${TARGETARCH}/thinko" /thinko/bin/
USER nonroot:nonroot
ENTRYPOINT [ "/thinko/bin/thinko" ]
```

That's the *whole thing*. There are no dependencies at all, aside from
a few included in [distroless] image. And where does that image come from?
This is the relevant from the project `Makefile`:

``` makefile
.PHONY: all # Build all binaries
all: local linux darwin windows freebsd

linux: thinko-linux
darwin: thinko-darwin
windows: thinko-windows
freebsd: thinko-freebsd

thinko-linux: _build/linux-amd64/thinko _build/linux-arm64/thinko
thinko-darwin: _build/darwin-amd64/thinko _build/darwin-arm64/thinko
thinko-windows: _build/windows-amd64/thinko _build/windows-arm64/thinko
thinko-freebsd: _build/freebsd-amd64/thinko _build/freebsd-arm64/thinko

# Build Thinko for specific platform
_build/%/thinko: cmd/thinko
	GOOS=$(word 1,$(subst -, ,$*)) GOARCH=$(word 2,$(subst -, ,$*)) $(GO) build -o $@ ./$<
```

This configuration allows me to build `thinko` for every OS and architecture
at once:

``` console
$ make thinko
go build -o _build/local/thinko ./cmd/thinko
GOOS=linux GOARCH=amd64 go build -o _build/linux-amd64/thinko ./cmd/thinko
GOOS=linux GOARCH=arm64 go build -o _build/linux-arm64/thinko ./cmd/thinko
GOOS=darwin GOARCH=amd64 go build -o _build/darwin-amd64/thinko ./cmd/thinko
GOOS=darwin GOARCH=arm64 go build -o _build/darwin-arm64/thinko ./cmd/thinko
GOOS=windows GOARCH=amd64 go build -o _build/windows-amd64/thinko ./cmd/thinko
GOOS=windows GOARCH=arm64 go build -o _build/windows-arm64/thinko ./cmd/thinko
GOOS=freebsd GOARCH=amd64 go build -o _build/freebsd-amd64/thinko ./cmd/thinko
GOOS=freebsd GOARCH=arm64 go build -o _build/freebsd-arm64/thinko ./cmd/thinko
```

Those first two commands build `thinko` for Linux on amd64 and arm64, right
where the `Dockerfile` expects them. Building then is easy; a separate `make`
target runs the equivalent of:

``` console
$ docker buildx build --platform linux/arm64 -f dist/Dockerfile .
$ docker buildx build --platform linux/amd64 -f dist/Dockerfile .
```

The `--platform` flag sets the `TARGETOS` and `TARGETARCH` arguments in the
`Dockerfile`, and because the directories into which each binary were compiled
have these same terms, the binary compiled for the right OS and architecture
can be copied right in.

And that's it, it's ready to ship! No mucking with dependencies, tweaking
system issues, removing unneeded stuff from the image. It's just the bare
minimum.

This pattern works not just for Docker images, of course. See, for example,
how [Hugo], the Go blog generator, [releases] tarballs for a bunch of OSes and
architectures, each containing nothing more than a `README.md`, `LICENSE.md`,
and the `hugo` binary itself. This pattern allows both the [Hugo Homebrew
formula] and its [`Dockerfile`] to be incredibly simple.

Back to PGXN
------------

I very much want these advantages for the next generation of PGXN tools. Not
only the services, but also the command-line client, which would become very
easy to distribute to a wide variety of platforms with minimal effort.

But there are other variables to weigh in the choice of language for the PGXN
servers and tools, including:

*   **Familiarity** to other developers: Ideally someone can quickly
    contribute to a project because they're familiar with the language, or
    there's a short learning curve.

*   **Safety** from common issues and vulnerabilities such as buffer overflows,
    and dangling pointers.

*   **Tooling** for robust and integrated development, including dependency
    management, testing, distribution, and of course cross-compilation.

Decisions, Decisions
--------------------

In my experience, there are two language that fulfill these requirements
very well:

*   🐿️ [Go][][^gopher]
*   🦀 [Rust]

Which should we use? Some relevant notes:

*   I expect to do the bulk of the initial development on PGXN v2, as the only
    person currently dedicated full time to the project, and I'm most familiar
    with Go --- indeed I enjoy writing web services and CLIs in Go!. I'd
    therefore be able go ship Go tools more quickly.
    
*   But I've played around with Rust a number of times over the years, and
    very much would like to learn more. Its syntax and long feature list
    steepen the learning curve, but given my background in Perl --- another
    language with unique syntax and context-sensitive features --- I'm certain
    I could become incredibly proficient in Rust after a few months.

*   My employer, [Tembo], is a Rust shop, and we'll likely borrow heavily from
    the [trunk] project, especially for the CLI and binary registry. It would
    also be easier for my coworkers to contribute.

*   [pgrx], the tooling to build Postgres extensions in Rust, has taken the
    community by storm, rapidly building familiarity with the language among
    extensions developers. Perhaps some of those developers would also be
    willing to turn their expertise to PGXN Rust contributions, as well.
    It's likely some features could be borrowed, as well.

*   Sadly, the [plgo] project appears to have stalled, so has not built
    up the same community momentum.

This leaves me torn! But it's time to start coding, so it's also time to
make some decisions. Should PGXN v2 services and tool be:

1.  🐿️ Written in Go
2.  🦀 Written in Rust
3.  🐿️ + 🦀 Some of each (e.g., Go for web services and Rust for CLIs)

What do you think? If you were to contribute to PGXN, what language would
you like to work in? Do you think one language or the other would be more
compatible with community direction or core development?[^core]

Got an opinion? [🗳️ Vote]! Poll closes April 12 at the end of the day (midnight)
New York time.

And if those choices aren't enough for you, please come yell at me [on
Mastodon], or via the [#extensions] channel on the [Postgres Slack]. Thanks!

  [^community]: Ever wonder why PGXN isn't hosted by community servers? It's
    because I screwed up the installation trying to balance all the
    dependencies without wiping out Perl modules the systems depend on. 🤦🏻‍♂️

  [^gopher]: Pity there's no gopher emoji yet.

  [^core]: I can imagine a future where an extension CLI was included in core.

  [PGXN v2 project]: https://github.com/orgs/pgxn/projects/1/views/1
  [root registry]: https://github.com/pgxn/planning/issues/8
    "PGXN v2 Planning: #8: Implement Root Registry"
  [package registry]: https://github.com/pgxn/planning/issues/11
    "PGXN v2 Planning: #11: Implement Packaging Registry"
  [command line client]: https://github.com/pgxn/planning/labels/client
    "PGXN v2 Planning: #cli"
  [interactions service]: https://github.com/pgxn/planning/issues/20
      "PGXN v2 Planning: #20: Implement Interactions Service"
  [Perl]: https://www.perl.org "The Perl Programming Language"
  [Go]: https://go.dev "The Go Programming Language"
  [cross compilation]: https://en.wikipedia.org/wiki/Cross_compiler
    "Wikipedia: “Cross compiler”"
  [the `Dockerfile`]: https://github.com/sqitchers/docker-sqitch/blob/main/Dockerfile
  [Sqitch]: https://sqitch.org "Sqitch: the sensible database change management system"
   [Module::Build::Sqitch]: https://github.com/sqitchers/sqitch/blob/develop/inc/Module/Build/Sqitch.pm
  [Homebrew formula]: https://github.com/sqitchers/homebrew-sqitch/blob/main/Formula/sqitch.rb
  [Homebrew core]: https://github.com/Homebrew/homebrew-core/pull/129128
    "homebrew-core#129128 sqitch 1.3.1 (new formula)"
  [distroless]: https://github.com/GoogleContainerTools/distroless
    "distroless: 🥑 Language focused docker images, minus the operating system"
  [releases]: https://github.com/gohugoio/hugo/releases "Hugo Releases"
  [Hugo Homebrew formula]: https://github.com/Homebrew/homebrew-core/blob/8fb177a/Formula/h/hugo.rb
  [`Dockerfile`]: https://github.com/gohugoio/hugo/blob/master/Dockerfile
    "Hugo base Dockerfile"
  [Rust]: https://www.rust-lang.org "Rust Programming Language"
  [Tembo]: https://tembo.io/ "Tembo: Goodbye Database Sprawl, Hello Postgres"
  [trunk]: https://github.com/tembo-io/trunk 
    "trunk: Package manager and registry for Postgres extensions"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
  [plgo]: https://gitlab.com/microo8/plgo "plgo: easily create postgresql extensions in golang"
  [🗳️ Vote]: https://dev.star.vote/Election/tqkv3v "Poll: What language should PGXN v2 tools and services be written in?"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [on Mastodon]: {{% param "mastodon.url" %}} "{{% param "mastodon.user" %}}"
