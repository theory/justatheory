---
title: Extension Registry Namespacing RFC
slug: extension-namespace-rfc
date: 2024-03-19T21:55:46Z
lastMod: 2024-03-19T21:55:46Z
description: |
  A proposal for an additional level of name uniqueness for Postgres
  extensions, based on URIs.
tags: [Postgres, PGXN, PGXN v2, Extensions, Go, Namespacing, Registry]
type: post
---

A few weeks ago I [brainstormed] about decentralized Postgres extension
publishing, inspired in part by an examination of [Go decentralized publishing].
It was...*a lot.* I've been deeply [pondering the future] of PGXN and the
broader extension ecosystem, and want to start to nail down some decisions. To
that end, I'd like to propose an update to extension namespacing.

## Status Quo

There are currently three ways in which an extension is considered unique:

1.  Only one extension can have a given name within a single Postgres cluster.
    Names are defined by the name of the [control file]. It is therefore not
    possible to have two extensions with the same name in the same Postgres
    cluster.
2.  [PGXN] follows this pattern: Only one extension can have a given name in the
    PGXN registry. The first person to release an extension then "owns" its
    name, and no one else can release an extension with the same name.[^grant]
    I think [dbdev] follows the same pattern.
3.  Other registries like [trunk] and [pgxman] define an extension by the
    _distribution_ name, at least for the purposes of selecting a binary to
    install. Thus when you `trunk install postgis`, you get all of the
    extensions included, as you'd expect, while
    `trunk install address_standardizer` wouldn't work at all. In the few places
    that `trunk` supports installation by extension name, it prompts the user to
    use the appropriate package name if there's a conflict.

## A Modest Proposal

I'd like to propose the following changes to the [PGXN Meta Spec] to start to
move away from extension uniqueness in the broader extension ecosystem and more
toward package name.

*   Add a new field, call it `module_path`, `project_path`, `project_uri`, that,
    if present, uniquely identifies an extension project and all of its parts.
    It should be to a [Go-style module path] (or URI) that identifies the
    project repository path where a `META.json` file lives.
*   Retain the [`provides`] object where keys identify extensions, but those
    keys will no longer be globally unique to the registry. In other words, the
    combination of `module_path` and extension name uniquely identifies an
    extension, including an empty `module_path`.

### How it Works

Some examples. Let's say there is an existing extension named `pair`, included
in the distribution named `pg_pair`:

``` json
{
  "name": "pg_pair",
  "version": "1.2.3",
  "provides": {
    "pair": {
      "file": "pair.sql",
      "version": "1.2.0"
    }
  }
}
```

The extension name `pair` is unique, and `pgxn install pair` will download
the pg_pair v1.2.3 bundle and compile and install pair v1.2.0.

Now someone else comes along and wants to make their own pair with this
metadata:

``` json
{
  "name": "my_pair",
  "version": "0.2.3",
  "provides": {
    "pair": {
      "file": "pair.sql",
      "version": "0.2.3"
    }
  }
}
```

Just like today, this upload would be rejected, because there is already a
registered `pair` extension. Under my proposal, they can disambiguate by
providing a `module_path`:


``` json
{
  "name": "my_pair",
  "module_path": "github/example/pair",
  "version": "0.2.3",
  "provides": {
    "pair": {
      "file": "pair.sql",
      "version": "0.2.3"
    }
  }
}
```

This upload would be allowed. With these two releases, someone attempting to
install `pair` would see something like this:

``` console
$ pgxn install pair
ERROR: Duplicate extension name “pair”. Install one of these instead:
       * pgxn.org/dist/pair
       * github/example/pair
```

Note the the module path `pgxn.org/dist/pair` in the the first option. This is
the default module path for distributions without a module path.[^implied] But
now the user can select the proper one to install:

``` console
$ pgxn install pgxn.org/dist/pair
INFO: latest version: pgxn.org/dist/pair@1.2.3
INFO: building extension
INFO: installing extension
INFO: done!
```

Furthermore, the PGXN client will prevent the user from later installing a
conflicting extension. The failure would look something like:

``` console
$ pgxn install github/example/pair
INFO: latest version: pgxn.org/dist/pair@0.2.3
ERROR: Cannot install extension “pair” from pgxn.org/dist/pair:
ERROR: A conflicting extension named “pair” is already installed
ERROR: from pgxn.org/dist/pair
```

## Features with Benefits

I see a number of benefits to this change:

*   Compatibility with the v1 metadata spec, so that no data migration or
    distribution indexing is required.
*   It loosens up extension namespacing (or name registration, if you prefer)
    while adding additional metadata to help users evaluate the quality of an
    extension. For example, does it come from a well-known developer? You can
    see it right in the module path.
*   It creates a pattern to eventually allow auto-indexing of extensions. For
    example, if you run `pgxn install github.com/example/pew`, and PGXN doesn't
    have it, it can look for a `META.json` file in that repository and, if it
    exists, and there's a semver release tag, it could try to index it and let
    the user install it. There are ownership issues to be worked out, but it
    has possibilities.
*   It preserves the Postgres core concept of extension identity while putting
    in place a well-established (by [Go modules] and widespread use of URIs in
    general) that the Postgres core could eventually adopt to allow more
    flexible extension namespacing.

## Request for Comments

What do you think? Good idea? Terrible idea? Please hit me with your thoughts
[on Mastodon], or via the [#extensions] channel on the [Postgres Slack]. I'd
like to get this decision (and a few others, stay tuned!) nailed down soon and
start development, so don't hesitate? I need your help to prevent me from making
a huge mistake.

  [^grant]: Unless the owner would like to share ownership with someone else, in
    which case they can email me to request that another user be granted
    "co-ownership". They can also request to transfer ownership to another user,
    after which the original owner will no longer be able to release the
    extension.

  [^implied]: Or, if the `META.json` file has a [repository resource] with a
    URL, PGXN could index it as the implied module path. Or, failing that, maybe
    it should fall back on the distribution name instead of a `pgxn.org` path,
    and prompt with `pg_pair/pair`.

  [brainstormed]: {{% ref "/post/postgres/decentralized-extension-publishing/index" %}}
    "Contemplating Decentralized Extension Publishing"
  [Go decentralized publishing]: https://go.dev/doc/modules/developing#decentralized
    "go.dev: Developing and publishing modules"
  [pondering the future]: https://www.pgevents.ca/events/pgconfdev2024/schedule/session/91/
    "pgconf.dev: “The Future of the Extension Ecosystem”"
  [control file]: https://www.postgresql.org/docs/current/extend-extensions.html#EXTEND-EXTENSIONS-FILES
    "PostgreSQL Docs: Extension Files"
  [PGXN]: https://pgxn.org "PGXN — PostgreSQL Extension Network"
  [dbdev]: https://database.dev "The Database Package Manager"
  [trunk]: https://pgt.dev "Trunk — A Postgres Extension Registry"
  [pgxman]: https://pgxman.com/ "npm for PostgreSQL"
  [PGXN Meta Spec]: https://pgxn.org/spec
  [Go-style module path]: https://go.dev/ref/mod#module-path
  [`provides`]: https://pgxn.org/spec#provides "PGXN Meta Spec: provides"
  [repository resource]: https://pgxn.org/spec#resources "PGXN Meta Spec: resources"
  [Go modules]: https://go.dev/ref/mod "Go Modules Reference"
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
  [on Mastodon]: {{% param "mastodon.url" %}} "{{% param "mastodon.user" %}}"
