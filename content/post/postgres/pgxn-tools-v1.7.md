---
title: 🛠️ PGXN Tools v1.7
slug: pgxn-tools-v1.7
date: 2026-01-24T22:53:11Z
lastMod: 2026-01-24T22:53:11Z
description: |
  Just released the PGXN test and build OCI image upgraded to Trixie and
  improving PGXS build parallelization.
tags: [Postgres, PGXN, Docker, GitHub Workflow]
type: post
---

Today I released v1.7.0 of the [pgxn-tools OCI image], which simplifies
Postgres extension testing and [PGXN] distribution. The new version includes
just a few updates and improvements:

*   Upgraded the Debian base image from Bookworm to Trixie
*   Set the `PGUSER` environment variable to `postgres` in the `Dockerfile`,
    removing the need for users to remember to do it.
*   Updated [`pg-build-test`]  to set `MAKEFLAGS="-j $(nprocs)"` to shorten
    build runtimes.
*   Also updated [`pgrx-build-test`] to pass `-j $(nprocs)`, for the same
    reason.
*   Upgraded the pgrx test extension to v0.16.1 and test it on Postgres
    versions 13-16.

Just a security and quality of coding life release. Ideally existing workflows
will continue to work as they always have.

  [pgxn-tools OCI image]: https://hub.docker.com/r/pgxn/pgxn-tools
  [PGXN]: https://pgxn.org "PostgreSQL Extension Network"
  [`pg-build-test`]: https://github.com/pgxn/docker-pgxn-tools?tab=readme-ov-file#pg-build-test
  [`pgrx-build-test`]: https://github.com/pgxn/docker-pgxn-tools?tab=readme-ov-file#pgrx-build-test
