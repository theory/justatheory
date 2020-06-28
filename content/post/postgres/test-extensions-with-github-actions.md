---
title: "Test Extensions With GitHub Actions"
date: 2020-06-21T17:54:15Z
lastMod: 2020-06-21T17:54:15Z
description: I finally made the jump from Travis CI to GitHub Actions. Here’s how you can, too.
tags: [Postgres, PGXN, GitHub Actions, Automation, CI/CD]
type: post
draft: true
---

I first heard about [GitHub Actions] a couple years ago, but it has taken till
the last few weeks to fully embrace them. Part of the challenge for me has been
a lack of simple examples, and quite a lot of complicated-looking
JavaScript-based actions that seemed like overkill. But I was motivated to
figure out enough to update my [PGXN] projects to automatically test on multiple
versions of Postgres, as well as to bundle and release them. The first draft of
that effort is a Docker image, [pgxn/pgxn-tools][^may-rename], with scripts to
build and run any version of PostgreSQL between 8.4 and 12, install additional
dependencies, build, test, bundle, and release an extension.

Here's how I've put it to use in a [GitHub workflow for semver], the
[Semantic Version] data type:

{{< highlight yaml "linenos=true" >}}
name: CI
on: [push, pull]
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
{{< / highlight >}}

The important bits are in the `jobs.test` object. Under `strategy.matrix`, which
defines the build matrix, the `pg` array defines each version to be tested. The
job will run once for each version, and can be referenced via `${{matrix.pg }}`
elsewhere in the job. Line 16 specifies that the job runs a [pgxn/pgxn-tools]
container, and the `steps` the things to do inside the container, which are:

*   Line 18: Install, and start the specified major version of PostgreSQL.
*   Line 19: Clone the [semver repository]
*   Line 20: Build and test the extension

The intent here is to cover the vast majority of cases for testing PostgreSQL
extensions, where a project uses [PGXS] `Makefile`. The `pg-build-test` script
does just that.

A few notes on the scripts included in [pgxn/pgxn-tools]:

*   `pg-start` installs, initializes, and starts the specified version of Postgres.
    If you need other dependencies, simply list their [Debian package names]
    after the major Postgres version number.

*   [`pgxn`] is a client for the PGXN itself. You can use it to install
    other dependencies from PGXN.

*   `pg-build-test` simply builds, installs, and tests a PostgreSQL extension or
    other code in the current directory. Effectively the equivalent of
    `make && make install && make installcheck`.

*   `pgxn-bundle` validates the PGXN `META.json` file and bundles up the
    project into a zip file for release to PGXN.

*   `pgxn-release` uploads a release zip file to PGXN.

The idea is that yo use the first three utilities to handle dependencies and
test your extension, and the last to to release it on PGXN. On GitHub, simply
set secrets with your PGXN credentials, named `PGXN_USERNAME` and
`PGXN_PASSWORD`, and the script will handle the rest. Here's how a release job
might look:

{{< highlight yaml "linenos=true,linenostart=15" >}}
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
{{< / highlight >}}

Note that lines 24-25 require that the `test` job defined above pass, and ensure
the job runs only on a push even to the [main branch], which in this example
would be where a final release would be pushed. We set `PGXN_USERNAME` and
`PGXN_PASSWORD` from the secrets of the same name, and then, in lines 33-38,
check out the project, bundle it into a zip file for release, and release it on
PGXN.

There are a few more features of the image, so [read the docs][pgxn/pgxn-tools]
for all the details. Still, this is a first cut PGXN [CI/CD]. As I get more
experience and build and release more extensions in the coming year, I expect to
work out integration with publishing [GitHub releases], and perhaps build and
publish relevant actions on the [GitHub Marketplace].


  [GitHub Actions]: https://github.com/features/actions
  [PGXN]: https://pgxn.org/ "PGXN: The PostgreSQL Extension Network"
  [pgxn/pgxn-tools]: https://hub.docker.com/repository/docker/pgxn/pgxn-tools
  [GitHub workflow for semver]: https://github.com/theory/pg-semver/blob/c56d76dcbe85e0348b44c6c098560a0df7ab25a5/.github/workflows/ci.yml
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
  [GitHub releases]: https://help.github.com/en/github/administering-a-repository/managing-releases-in-a-repository
  [GitHub Marketplace]: https://github.com/marketplace

  [^may-rename]: Not a great name, I know, will probably change as I learn more.