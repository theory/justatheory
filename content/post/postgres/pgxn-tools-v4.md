---
title: PGXN Tools v1.4
slug: pgxn-tools-v1.4
aliases: [/2024/01/pgxn-tools-v4/index.html]
date: 2024-01-31T17:13:40Z
lastMod: 2024-01-31T17:13:40Z
description: The pgxn-tools Docker image has seen some recent bug fixes and improvements.
tags: [Postgres, PGXN, Docker, GitHub Workflow]
type: post
link: https://blog.pgxn.org/post/741049567045468160/pgxn-tools-v4
---

Over on the [PGXN Blog] I've [posted a brief update] on recent bug fixes and
improvements to the [pgxn-tools Docker image], which is used fairly widely these
days to test, bundle, and release Postgres extensions to [PGXN]. This fix is
especially important for Git repositories:

> v1.4.1 fixes an issue where `git archive` was never actually used to build a
> release zip archive. This changed at some point without noticing due to the
> introduction of the `safe.directory` configuration in recent versions of Git.
> Inside the container the directory was never trusted, and the `pgxn-bundle`
> command caught the error, decided it wasn't working with a Git repository, and
> used the `zip` command, instead.

I also posted a [gist listing PGXN distributions with a `.git` directory].

  [PGXN Blog]: https://blog.pgxn.org/
  [posted a brief update]: https://blog.pgxn.org/post/741049567045468160/pgxn-tools-v4
    "PGXN Blog: “PGXN Tools Docker Image Updated”"
  [pgxn-tools Docker image]: https://hub.docker.com/r/pgxn/pgxn-tools
  [PGXN]: https://pgxn.org "PostgreSQL Extension Network"
  [gist listing PGXN distributions with a `.git` directory]: https://gist.github.com/theory/93c93571200aad02e93170c6d2c93cbe
    "PGXN distributions that contain a .git directory"
