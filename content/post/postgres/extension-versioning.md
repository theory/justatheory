---
title: The History and Future of Extension Versioning
slug: extension-versioning
date: 2024-02-22T19:33:12Z
lastMod: 2024-02-22T19:33:12Z
description: |
  What versioning standard should be used for Postgres extension distribution?
  Some context from PostgreSQL and PGXN, a survey of the version standard
  landscape today, and a recommendation.
tags: [Postgres, Extensions, PGXN, Versioning, SemVer, CalVer]
type: post
---

Every software distribution system deals with versioning. Early in the design of
[PGXN], I decided to require [semantic versions][SemVer] (SemVer), a
clearly-defined and widely-adopted version standard, even in its [pre-1.0
specification]. I implemented the [semver data type] that would properly sort
semantic versions, later ported to C by [Sam Vilain] and eventually updated to
[semver 2.0.0].

As I've been thinking through the [jobs] and [tools] for the Postgres extension
ecosystem, I wanted to revisit this decision, the context in which it was made,
and survey the field for other options. Maybe a "PGXN v2" should do something
different?

But first that context, starting with Postgres itself.

PostgreSQL Extension Version Standard
-------------------------------------

From the introduction extensions in PostgreSQL 9.1, the project side-stepped the
need for version standardization and enforcement by requiring extension authors
to adopt a [file naming convention], instead. For example, an extension named
"pair" must have a file with its name, two dashes, then the version as listed in
its control file, like so:

```
pair--1.1.sql
```

As long as the file name is correct and the version part byte-compatible with
the control file entry, `CREATE EXTENSION` will find it. To upgrade an extension
the author must provide a second file with the extension name, the old version,
and the new version, all delimited by double dashes. For example, to upgrade our
"pair" extension to version `1.2`, the author supply all the SQL commands
necessary to upgrade it in this file:

```
pair--1.1--1.2.sql
```

This pattern avoids the whole question of version standards, ordering for
upgrades or downgrades, and all the rest: extension authors have full
responsibility to name their files correctly.

PGXN Versions
-------------

[SemVer] simplified a number of issues for PGXN in ways that the PostgreSQL
extension versioning did not (without having to re-implement the core's file
naming code). PGXN wants all metadata for an extension in its [`META.json`]
file, and not to derive it from other sources that could change over time.

Following the [CPAN model], PGXN also required that extension releases never
decrease the version.[^why] The well-defined sortability of semantic versions
made this validation trivial. PGXN [later relaxed] enforcement to allow updates
to previously-released versions. SemVer's [clearly specified sorting] made this
change possible, as the `major.minor.patch` precedence intuitively compare from
left to right.

In other words, if one had previously released version 1.2.2, then released
1.3.0, a follow-up 1.2.3 is allowed, increasing the `1.2.x` branch version, but
not, say, 1.2.1, which decreases the `1.2.x` branch version.

Overall, semantic versions have been great for clarity of versioning of PGXN
extensions. The one bit of conflict comes from extensions that use some other
other version standard in the control file, usually a two-part `x.y` version not
allowed by SemVer, which requires `x.y.z` (or, more specifically,
`major.minor.patch`).

But such versions are *usually* compatible with SemVer, and because PGXN cares
only about the contents of the `META.json`, they're free to use their own
versions in the control file, just as long as the `META.json` file uses SemVers. 

For example, the recent [nominatim_fdw v1.0.0] release, which of course lists
`"version": "1.0.0"` in [its `META.json` file], sticks to its preferred
`default_version = '1.0'` in [its control file]. The extension author simply
appends `.0` to create a valid SemVer from their preferred version, and as long
as they never use any other patch number, it remains compatible.

Versioning Alternatives
-----------------------

Surveying the versioning landscape in 2024 yields a number of approaches. Might
we prefer an alternative for future extensions distribution? Let's look at the
possibilities.

### Ad Hoc Versions

 As described above, the Postgres [file naming convention] allows ad hoc
versions. As far as I can tell, so does the [R Project]'s [CRAN]. This approach
seems fine for systems that don't need to follow version changes themselves, but
much trickier for systems that do. If I want to install the latest version of an
extension, how does the installer know what that latest version is?

The answer is that the extension author must always release them in the proper
order. But if someone releases 1.3.1 of an extension, and then 1.2.1, well then
1.2.1 is the latest, isn't it? It could get confusing pretty quickly.

Seems better to require *some system,* so that download and install clients can
get the latest version --- or the latest maintenance version of an earlier
release if they need it.

### User Choice

Quite a few registries allow users to choose their own versioning standards, but
generally with some very specific recommendations to prevent confusion for
users.

*   [Python Packaging] is fairly liberal in the versions it allows, but strongly
    recommends [semantic versioning][SemVer] or [calendar versioning][CalVer]
    (more on that below).
*   [CPAN (Perl)] is also fairly liberal, due to its long history of module
    distribution, but currently requires "Decimal versions", which are evaluated
    as floating-point numbers, or dotted integer versions, which require
    three dot-separated positive integers and must begin with the letter `v`.
*   [RubyGems] does not enforce a versioning policy, but warns that "using an
    'irrational' policy will only be a disservice to those in the community who
    use your gems." The project therefore urges developers to follow [SemVer].

These three venerable projects date from an earlier period of registration and
distribution, and have made concessions to times when no policies existed. Their
solutions either try to cover as many legacy examples as possible while
recommending better patterns going forward (Python, Perl), or simply make
recommendations and punt responsibility to developers.

### SemVer

More recently-designed registries avoid this problem by requiring some level of
versioning standard from their inception. Nearly all use [SemVer], including:

*   [Go Modules], where "Each version starts with the letter v, followed by a
    semantic version."
*   [Cargo (Rust)], which "uses SemVer for specifying version numbers. This
    establishes a common convention for what is compatible between different
    versions of a package."
*   [npm], where the "version must be parseable by [node-semver], which is
    bundled with npm as a dependency."

### CalVer

[CalVer] eschews context-free incrementing integers in favor of
semantically-meaningful versions, at least for some subset of a version string.
In other words: make the version date-based. CalVer-versioned projects usually
include the year and sometimes the month. Some examples:

*   [Ubuntu] uses `YY.0M.MICRO`, e.g., `23.04`, released in April 2023, and
    `23.10.1`, released in October 2023
*   [Twisted] uses `YY.MM.MICRO`, e.g., `22.4.0`, released in April 2022

Ultimately, adoption of a CalVer format is a more choice about embedding
calendar-based meaning into a version more than standardizing a specific format.
One can of course use CalVer semantics in a semantic version, as in the Twisted
example, which is fully-SemVer compliant.

In other words, adoption of CalVer need not necessitate rejection of SemVer.

### Package Managers

What about package managers, like RPM and Apt? Some canonical examples:

*   [RPM] packages use the format:

    ```
    <name>-<version>-<release>.<architecture>
    ```

    Here `<version>` is the upstream version, but RPM practices a reasonable (if
    baroque) [version comparison] of all its parts. But it does not impose a
    standard on upstream packages, since they of course vary tremendously
    between communities and projects.

*   [Apt] packages use a similar format:

    ```
    [epoch:]upstream_version[-debian_revision]
    ```
    
    Again, `upstream_version` is the version of the upstream package, and not
    enforced by Apt.

*   [APK (Alpine Linux)] packages use the format

    ```
    {digit}{.digit}...{letter}{_suf{#}}...{-r#}
    ```
    
    I believe that `{digit}{.digit}...{letter}` is the upstream package version.

This pattern makes perfect sense for registries that repackage software from
dozens of upstream sources that may or may not have their own policies. But a
system that defines the standard for a specific ecosystem, like Rust or
PostgreSQL, need not maintain that flexibility.

Recommendation
--------------

Given this survey, I'm inclined to recommend that the PostgreSQL community
follow the PGXN (and Go, and Rust, and npm) precedent and continue to rely on
and require [semantic versions][SemVer] for extension distribution. It's not
perfect, given the contrast with the core's lax version requirements. [CalVer]
partisans can still use it, though with fewer formatting options (SemVer forbids
leading zeros, as in the Ubuntu `23.04` example).

But with its continuing adoption, and especially its requirement by more recent,
widely-used registries, and capacity to support date-based semantics for those
who desire it, I think it continues to make the most sense.

### Wrong!

I'm probably wrong. I'm often mistaken in one way or another, on the details or
the conclusion. Please tell me how I've messed up! Find me on the [#extensions]
channel on the [Postgres Slack] or ping me [on Mastodon].

  [^why]: Why? Because every module on CPAN has one and only one entry in the
    index file. [Ricardo Signes explains].

  [PGXN]: https://pgxn.org "The postgreSQL Extension Network"
  [SemVer]: https://semver.org "Semantic Versioning"
  [pre-1.0 specification]: https://semver.org/spec/v1.0.0-beta.html
    "Semantic Versioning 1.0.0-beta"
  [semver data type]: https://pgxn.org/dist/semver
    "semver: A semantic version data type / PostgreSQL Extension Network"
  [semver 2.0.0]: https://semver.org/spec/v2.0.0.html
    "Semantic Versioning 2.0.0"
  [jobs]: https://tembo.io/blog/pgxn-ecosystem-jobs
    "The Jobs to be Done by the Ideal Postgres Extension Ecosystem"
  [tools]: https://gist.github.com/theory/898c8802937ad8361ccbcc313054c29d#tools
    "Extension Ecosystem: Jobs and Tools"
  [Sam Vilain]: http://vilain.net
    "Sam Vilain: Free Software Programmer - Wood Craftsman - Open Water Swimmer - Science Enthusiast"
  [file naming convention]: https://www.postgresql.org/docs/current/extend-extensions.html#EXTEND-EXTENSIONS-UPDATES
    "PostgreSQL Docs: “Packaging Related Objects into an Extension — Extension Updates”"
  [`META.json`]: https://pgxn.org/spec/ "PGXN Meta Spec - The PGXN distribution metadata specification"
  [later relaxed]: https://github.com/pgxn/pgxn-manager/commit/d2bd3bf
    "pgxn/pgxn-manager@d2bd3bf: Allow updates to old versions"
  [clearly specified sorting]: https://semver.org/#spec-item-11
    "Semantic Versioning 2.0.0: Precedence refers to how versions are compared to each other when ordered."
  [CPAN model]: https://github.com/andk/pause/blob/master/doc/operating-model.md#35-factors-considering-in-the-indexing-phase
    "The PAUSE Operating Model v2: Factors considering in the indexing phase"
  [nominatim_fdw v1.0.0]: https://pgxn.org/dist/nominatim_fdw/1.0.0/
    "nominatim_fdw 1.0.0: Nominatim Foreign Data Wrapper for PostgreSQL / PostgreSQL Extension Network"
  [its `META.json` file]: https://api.pgxn.org/src/nominatim_fdw/nominatim_fdw-1.0.0/META.json
    "nominatim_fdw 1.0.0 META.json"
  [its control file]: https://api.pgxn.org/src/nominatim_fdw/nominatim_fdw-1.0.0/nominatim_fdw.control
    "nominatim_fdw 1.0.0 nominatim_fdw.control"
  [R Project]: https://www.r-project.org "The R Project for Statistical Computing"
  [CRAN]: https://cran.r-project.org/doc/manuals/r-release/R-exts.html#The-DESCRIPTION-file
    "The Comprehensive R Archive Network: Writing R Extensions"
  [Python Packaging]: https://packaging.python.org/en/latest/discussions/versioning/
    "Python Packaging User Guide: Versioning"
  [CPAN (Perl)]: https://metacpan.org/pod/CPAN::Meta::Spec#VERSION-NUMBERS
    "CPAN::Meta::Spec: Version Numbers"
  [RubyGems]: https://guides.rubygems.org/patterns/#semantic-versioning
    "RubyGems Patterns: Semantic Versioning"
  [Go Modules]: https://go.dev/ref/mod#versions
  [Cargo (Rust)]: https://doc.rust-lang.org/cargo/reference/resolver.html#semver-compatibility
  [npm]: https://docs.npmjs.com/cli/v6/configuring-npm/package-json#version
  [PGXN]: https://pgxn.org/spec/#Version.Numbers
  [node-semver]: https://github.com/isaacs/node-semver
    "semver(1) -- The semantic versioner for npm"
  [CalVer]: https://calver.org "CalVer: Timely Project Versioning"
  [Ubuntu]: https://ubuntu.com/about/release-cycle
    "The Ubuntu lifecycle and release cadence"
  [Twisted]: https://pypi.org/project/Twisted/#history "Twisted Release History"
  [RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager#Package_filename_and_label
    "Wikipedia: “RPM Package Manager — Package filename and label"
  [version comparison]: https://blog.jasonantman.com/2014/07/how-yum-and-rpm-compare-versions/
    "How Yum and RPM Compare Versions"
  [Apt]: https://www.debian.org/doc/debian-policy/ch-controlfields.html#standards-version
  [APK (Alpine Linux)]: https://wiki.alpinelinux.org/wiki/APKBUILD_Reference#pkgver
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [on Mastodon]: {{% param "mastodon.url" %}} "{{% param "mastodon.user" %}}"
  [Ricardo Signes explains]: https://social.semiotic.systems/@rjbs/111971794172471384
    "@rjbs@social.semiotic.systems thread reply to @theory@xoxo.zone"
