---
title: "Test Extensions With GitHub Actions"
date: 2020-06-28T17:52:14Z
lastMod: 2020-06-28T17:52:14Z
description: I finally made the jump from Travis CI to GitHub Actions for my Postgres extensions. Here’s how you can, too.
tags: [Postgres, PGXN, GitHub Actions, Automation, CI/CD]
type: post
---

I first heard about [GitHub Actions] a couple years ago, but fully embraced them
only in the last few weeks. Part of the challenge has been the paucity of simple
but realistic examples, and quite a lot of complicated-looking JavaScript-based
actions that seem like overkill. But through trial-and-error, I figured out
enough to update my Postgres extensions projects to automatically test on
multiple versions of Postgres, as well as to bundle and release them on [PGXN].
The first draft of that effort is [pgxn/pgxn-tools][^may-rename], a Docker image
with scripts to build and run any version of PostgreSQL between 8.4 and 12,
install additional dependencies, build, test, bundle, and release an extension.

Here's how I've put it to use in a [GitHub workflow for semver], the
[Semantic Version] data type:

```yaml {linenos=true,hl_lines=[7 10 "12-14"]}
name: CI
on: [push, pull_request]
jobs:
  test:
    strategy:
      matrix:
        pg: [12, 11, 10, 9.6, 9.5, 9.4, 9.3, 9.2]
    name: 🐘 PostgreSQL ${{ matrix.pg }}
    runs-on: ubuntu-latest
    container: pgxn/pgxn-tools
    steps:
      - run: pg-start ${{ matrix.pg }}
      - uses: actions/checkout@v2
      - run: pg-build-test
```

The important bits are in the `jobs.test` object. Under `strategy.matrix`, which
defines the build matrix, the `pg` array defines each version to be tested. The
job will run once for each version, and can be referenced via `${{ matrix.pg }}`
elsewhere in the job. Line 10 has the job a [pgxn/pgxn-tools] container, where
the `steps` run. The are are:

*   Line 12: Install and start the specified version of PostgreSQL
*   Line 13: Clone the [semver repository]
*   Line 14: Build and test the extension

The intent here is to cover the vast majority of cases for testing Postgres
extensions, where a project uses [PGXS] `Makefile`. The `pg-build-test` script
does just that.

A few notes on the scripts included in [pgxn/pgxn-tools]:

*   `pg-start` installs, initializes, and starts the specified version of Postgres.
    If you need other dependencies, simply list their [Debian package names]
    after the Postgres version.

*   [`pgxn`] is a client for PGXN itself. You can use it to install other
    dependencies required to test your extension.

*   `pg-build-test` simply builds, installs, and tests a PostgreSQL extension or
    other code in the current directory. Effectively the equivalent of
    `make && make install && make installcheck`.

*   `pgxn-bundle` validates the [PGXN `META.json`] file, reads the distribution
    name and version, and bundles up the project into a zip file for release to
    PGXN.

*   `pgxn-release` uploads a release zip file to [PGXN].

In short, use the first three utilities to handle dependencies and test your
extension, and the last two to release it on PGXN. Simply set [GitHub secrets]
with your PGXN credentials, pass them in environment variables named
`PGXN_USERNAME` and `PGXN_PASSWORD`, and the script will handle the rest. Here's
how a release job might look:

```yaml {linenos=true,linenostart=15}
  release:
    name: Release on PGXN
    # Release pon push to main when the test job succeeds.
    needs: test
    if: github.ref == 'refs/heads/main' && github.event_name == 'push' && needs.test.result == 'success'
    runs-on: ubuntu-latest
    container:
      image: pgxn/pgxn-tools
      env:
        PGXN_USERNAME: ${{ secrets.PGXN_USERNAME }}
        PGXN_PASSWORD: ${{ secrets.PGXN_PASSWORD }}
    steps:
      - name: Check out the repo
        uses: actions/checkout@v2
      - name: Bundle the Release
        run: pgxn-bundle
      - name: Release on PGXN
        run: pgxn-release
```

Note that lines 18-19 require that the `test` job defined above pass, and ensure
the job runs only on a push event to the [main branch], where  we push final
releases. We set `PGXN_USERNAME` and `PGXN_PASSWORD` from the secrets of the
same name, and then, in lines 27-32, check out the project, bundle it into a zip
file, and release it on PGXN.

There are a few more features of the image, so [read the docs][pgxn/pgxn-tools]
for the details. As a first cut at PGXN [CI/CD] tools, I think it's fairly
robust. Still, as I gain experience and build and release more extensions in the
coming year, I expect to work out integration with publishing [GitHub releases],
and perhaps build and publish relevant actions on the [GitHub Marketplace].

  [GitHub Actions]: https://github.com/features/actions
  [PGXN]: https://pgxn.org/ "PGXN: The PostgreSQL Extension Network"
  [pgxn/pgxn-tools]: https://hub.docker.com/repository/docker/pgxn/pgxn-tools
  [GitHub workflow for semver]:
    https://github.com/theory/pg-semver/blob/c56d76dcbe85e0348b44c6c098560a0df7ab25a5/.github/workflows/ci.yml
  [Semantic Version]: https://semver.org
  [semver repository]: https://github.com/theory/pg-semver
  [Debian package names]: https://www.debian.org/distrib/packages#search_packages
    "Search Debian Packages"
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Extension Building Infrastructure"
  [`pgxn`]: https://github.com/pgxn/pgxnclient
  [main branch]: https://www.hanselman.com/blog/EasilyRenameYourGitDefaultBranchFromMasterToMain.aspx
    "Easily rename your Git default branch from master to main"
  [CI/CD]: https://en.wikipedia.org/wiki/CI/CD "Wikipedia: “CI/CD”"
  [GitHub releases]:
    https://help.github.com/en/github/administering-a-repository/managing-releases-in-a-repository
  [GitHub Marketplace]: https://github.com/marketplace
  [GitHub secrets]:
    https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets
  [PGXN `META.json`]: http://manager.pgxn.org/howto "PGXN How To"

  [^may-rename]: Not a great name, I know, will probably change as I learn more.
