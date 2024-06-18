---
title: 🏔 Extension Ecosystem Summit 2024
slug: extension-ecosystem-summit
date: 2024-06-18T17:08:35Z
lastMod: 2024-06-18T17:08:35Z
description: |
  A brief report on the PostgreSQL Extension Ecosystem Summit at PGConf.dev
  2024 in Vancouver, Canada.
tags: [Postgres, PGXN, Extensions, PGConf, Vancouver, Summit]
type: post
image:
  src: /shared/extension-ecosystem-summit/pgconf.dev.png
  link: https://pgconf.dev
  title: PGConf.dev
  alt: Logo for PGConf.dev
  copyright: 2024 PGConf.dev
  metaOnly: false
---

The PostgreSQL [Extension Ecosystem Summit] took place at PGConf.dev in
Vancouver on May 28, 2024 and it was great! Around 35 extension developers,
users, and fans gathered for an [open-space technology] (OST)-style
[unconference]. I opened with a brief presentation ([slides]) to introduce the
Summit Theme:

> *   Extension issues, designs and features
> *   Development, packaging, installation, discovery, docs, etc.
> *   Simplify finding, understanding, and installing
> *   Towards ideal ecosystem of the future
> *   For authors, packagers, DBAs, and users
> *   Lots of problems, challenges, decisions
> *   Which do you care about?
> *   Collaborate, discover, discuss, document
> *   Find answers, make decisions, set directions
> *   Inform the PGXN v2 project

Before the Summit my co-organizers and I had put up large sticky notes with
potential topics, and after reviewing the [four principles] and one law of
[OST], we collectively looked them over and various people offered to lead
discussions. Others volunteered to take notes and later published them on the
[community wiki]. Here's our report.

Extension Metadata
------------------

Samay Sharma of Tembo took point on this discussion, while David Wagoner of
EDB took [notes][metadata-notes]. The wide-ranging discussion among the five
participants covered taxonomies, versioning, system dependencies, packaging &
discoverability, development & compatibility, and more.

The discoverability topic particularly engaged the participants, as they
brainstormed features such as user comments & ratings, usage insights, and
test reporting. They settled on the idea of two types of metadata:
developer-provided metadata such as external dependencies (software packages,
other extensions the extension depends on etc.) and user metadata such as
ratings. I'm gratified how closely this hews to the [metadata sketch]'s
proposed [packaging] (author) and [registry] (third party) metadata.

Binary Distribution Format
--------------------------

I led this session, while Andreas "ads" Scherbaum took [notes][binary-notes].
I proposed to my four colleagues an idea I'd been mulling for a couple months
for an extension binary distribution format inspired by [Python wheel]. It
simply includes pre-compiled files in subdirectories named for each
`pg_config` directory config. The other half of the idea, inspired by an
[Álvaro Hernández blog post], is to distribute these packages via [OCI] --- in
other words, just like Docker images. The participants agreed it was an
interesting idea to investigate.

We spent much of the rest of the time reviewing and trying to understand the
inherent difficulty of upgrading binary extensions: there's a period between
when an extension package is upgraded (from Yum, Apt, etc.) and `ALTER
EXTENSION UPDATE` updates it in the database. If the new binary doesn't work
with old versions, it will break (and potentially crash Postgres!) until they
update. This can be difficult in, say, a data analytics environment with uses
of the extension in multiple databases and functions, and users may not have
the bandwidth to `ALTER EXTENSION UPDATE` any code that depends on the
extension.

This issue is best solved by defensive coding of the C library to keep it
working for new and old versions of an extension, but this complicates
maintenance.

Other topics included the lack of support for multiple versions of extensions
at one time (which could solve the upgrade problem), and determining the
upgrade/downgrade order of versions, because the Postgres core enforces no
version standard.

ABI/API discussion
------------------

Yurii Rashkovskii took point on this session while David Christensen took
[notes][api-notes]. Around 25 attendees participated. The discussion focused
in issues of API and [ABI] compatibility in the Postgres core. Today virtually
the entire code base is open for use by extension developers --- anything in
header files. Some [recent research] revealed a few potentially-incompatible
changes in minor releases of Postgres, leading some to conclude that
extensions must be compiled and distributed separately for every minor
release. The group brainstormed improvements for this situation. Ideas
included:

*   Spelunking the source to document and categorize APIs for extensions
*   Documenting color-coded safety classifications for APIs: green, yellow, or
    red
*   Designing and providing a better way to register and call hooks
    (observability, administration, isolation, etc.), rather than the simple
    functions Postgres offers today
*   Developing a test farm to regularly build and tests extensions, especially
    ahead of a core release
*   And of course creating *more* hooks, such as custom relation type
    handling, per-database background workers, a generic node visitor pattern,
    and better dependency handling

Including/Excluding Extensions in Core
--------------------------------------

Keith Fiske led the discussion and took [notes][corext-notes] for this
session, along with 10-15 or so attendees. It joined two topics: When should
an extension be brought into core and when should a contrib extension be
removed from core. The central point was the adoption of new features in core
that replace the functionality of and therefore reduce the need for some
extensions.

Replacing an extension with core functionality simplifies things for users.
However, the existence of an extension might prevent core from ever adding its
features. Extensions can undergo faster, independent development cycles
without burdening the committers with more code to maintain. This independence
encourages more people to develop extensions, and potentially compels core to
better support extensions overall (e.g., through better APIs/ABIs).

Contrib extensions currently serve, in part, to ensure that the extension
infrastructure itself is regularly tested. Replacing them with core features
would reduce the test coverage, although one participant proposed a patch to
add such tests to core itself, rather than as part of contrib extensions.

The participants collaborated on a list of contrib extensions to consider
merging into core:

*   amcheck
*   pageinspect
*   pg_buffercache
*   pg_freespacemap
*   pg_visibility
*   pg_walinspect
*   pgstattuple

They also suggested moving extension metadata (SQL scripts and control files)
from disk to catalogs and adding support for installing and using multiple
versions of an extension at one time (complicated by shared libraries),
perhaps by the adoption of more explicit extension namespacing.

Potential core changes for extensions, namespaces, etc.
-------------------------------------------------------

Yurii Rashkovskii and David Christensen teamed up on this session, as well
([notes][core-notes]). 15-20 attendees brainstormed core changes to improve
extension development and management. These included:

*   File organization/layout, such as putting all the files for an extension
    in a single directory and moving some files to the system catalog.
*   Provide a registry of "safe" extensions that can be installed without a
    superuser.
*   Adding a GUC to configure a second directory for extensions, to enable
    immutable Postgres images (e.g., Docker, Postgres.app). The attendees
    consider this a short term fix, but still useful. (Related: I started a
    [pgsql-hackers thread] in April for a patch to to just this).
*   The ability to support multiple versions of an extension at once, via
    namespacing, came up in this session, as well.
*   Participants also expressed a desire to support duplicate names through
    deeper namespacing. Fundamentally, the problem of namespace collision
    redounds to issues un-relocatable extensions.

Until Next Time
---------------

I found it interesting how many topics cropped up multiple times in separate
sessions. By my reading most cited topics were:

*   The need to install and use multiple versions of an extension
*   A desire for deeper namespacing, in part to allow for multiple versions of
    an extension
*   A pretty strong desire for an [ABI] compatibility policy and clearer
    understanding of extension-friendly APIs

I expect to put some time into these topics; indeed, I've already started a
[Hackers thread proposing an ABI policy].

I greatly enjoyed the discussions and attention given to a variety of
extension-related topics at the Summit. So much enthusiasm and intelligence in
one places just makes my day!

I'm thinking maybe we should plan to do it again next year. What do you think?
Join the [#extensions] channel on the [Postgres Slack] with your ideas!

  [Extension Ecosystem Summit]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/191/
    "PGConf.dev: Extensions Ecosystem Summit: Enabling comprehensive indexing, discovery, and binary distribution"
  [PGConf.dev]: https://2024.pgconf.dev "PostgreSQL Development Conference 2024"
  [open-space technology]: https://en.wikipedia.org/wiki/Open_space_technology
    "Wikipedia: Open space technology"
  [unconference]: https://en.wikipedia.org/wiki/Unconference "Wikipedia: Unconference"
  [slides]: {{% link "/shared/extension-ecosystem-summit/extension-summit-2024.pdf" %}}
    "🏔 PostgreSQL Extension Summit: An Unconference"
  [four principles]: https://www.facilitator.school/blog/open-space-technology#open-space-technology-principles
    "Open Space Technology Principles"
  [community wiki]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Extension_Summit
    "PostgreSQL Wiki: PGConf.dev 2024 Extension Summit"
  [metadata-notes]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Extension_Summit#Extension_Metadata
    "PostgreSQL Wiki: PGConf.dev 2024 Extension Summit --- Extension Metadata"
  [Metadata Sketch]: {{% ref "/post/postgres/rfc-pgxn-metadata-sketch" %}}
    "RFC: PGXN Metadata Sketch"
  [packaging]: {{% ref "/post/postgres/rfc-pgxn-metadata-sketch" %}}#package-metadata
    "RFC: PGXN Metadata Sketch --- Packaging Metadata"
  [registry]: {{% ref "/post/postgres/rfc-pgxn-metadata-sketch" %}}#registry-metadata
    "RFC: PGXN Metadata Sketch --- Registry Metadata"
  [binary-notes]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Extension_Summit#Binary_Distribution_Format
    "PostgreSQL Wiki: PGConf.dev 2024 Extension Summit --- Binary Distribution Format"
  [Python wheel]: https://packaging.python.org/en/latest/specifications/binary-distribution-format/
    "Python Packaging Guide: Binary distribution format"
  [Álvaro Hernández blog post]: https://www.ongres.com/blog/why-postgres-extensions-should-be-distributed-and-packaged-as-oci-images/
    "OnGres Blog: Why Postgres Extensions should be packaged and distributed as OCI images"
  [OCI]: https://github.com/opencontainers/distribution-spec/blob/main/spec.md
    "Open Container Initiative Distribution Specification"
  [ABI]: https://en.wikipedia.org/wiki/Application_binary_interface
    "Wikipedia: Application binary interface"
  [api-notes]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Extension_Summit#ABI.2FAPI_discussion
    "PostgreSQL Wiki: PGConf.dev 2024 Extension Summit --- ABI/API discussion"
  [recent research]: {{% ref "/post/postgres/mini-summit-five" %}} "Mini Summit Five"
  [corext-notes]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Extension_Summit#Including.2FExcluding_Extensions_in_Core
    "PostgreSQL Wiki: PGConf.dev 2024 Extension Summit --- Including/Excluding Extensions in Core"
  [core-notes]: https://wiki.postgresql.org/wiki/PGConf.dev_2024_Extension_Summit#Potential_core_changes_for_extensions.2C_namespaces.2C_etc
    "PostgreSQL Wiki: PGConf.dev 2024 Extension Summit --- Potential core changes for extensions, namespaces, etc"
  [pgsql-hackers thread]: https://www.postgresql.org/message-id/flat/E7C7BFFB-8857-48D4-A71F-88B359FADCFD%40justatheory.com
    "pgsql-hackers: RFC: Additional Directory for Extensions"
  [Hackers thread proposing an ABI policy]: https://www.postgresql.org/message-id/flat/5DA9F9D2-B8B2-43DE-BD4D-53A4160F6E8D%40justatheory.com
    "pgsql-hackers: Proposal: Document ABI Compatibility"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
