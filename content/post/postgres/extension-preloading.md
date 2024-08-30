---
title: To Preload, or Not to Preload
slug: extension-preloading
date: 2024-08-07T18:25:51Z
lastMod: 2024-08-07T18:25:51Z
description: |
  When should a Postgres extension be pre-loaded and when should it not?
  Should it be loaded in user sessions or at server startup? For the Tembo
  blog, I dug into this question and wrote up my findings.
tags: [PGXN, Postgres, Extensions, Preload, Extensions Book]
type: post
link: https://tembo.io/blog/library-preloading
---

The [Tembo Blog] published [a post] by yours truly last week about when to
preload shared libraries and when not to:

> Recently I've been trying to figure out when a Postgres extension shared
> libraries should be preloaded. By "shared libraries" I mean libraries
> provided or used by Postgres extensions, whether [`LOAD`]able libraries or
> `CREATE EXTENSION` libraries written in C or [pgrx]. By "preloaded" I mean
> under what conditions should they be added to one of the [Shared Library
> Preloading] variables, especially `shared_preload_libraries`.
> 
> The answer, it turns out, comes very much down to the extension type.

I view this post as a kind of proto-chapter for an imagined book about
developing extensions that I'd like to work on someday. I learned quite a lot
researching it and responding to [extensive feedback] from more knowledgeable
community members. It resulted in updates to the PGXN Meta [preload property]
that I hope will inform binary distribution in the future. More on that soon.

  [Tembo Blog]: https://tembo.io/blog "Tembo's Blog"
  [a post]: https://tembo.io/blog/library-preloading "To Preload, or Not to Preload"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
  [`LOAD`]: https://www.postgresql.org/docs/current/sql-load.html
    "PostgreSQL Docs: LOAD"
  [Shared Library Preloading]: https://www.postgresql.org/docs/current/runtime-config-client.html#RUNTIME-CONFIG-CLIENT-PRELOAD
  [extensive feedback]: https://github.com/theory/justatheory/pull/6
    "theory/justatheory#6: Add a post on preloading for extension authors"
  [preload property]: https://github.com/pgxn/rfcs/blob/7e20662/text/0003-meta-spec-v2.md?plain=1#L513C11-L517
    "PGXN Meta Spec v2 (draft): preload"
  