---
title: "Accelerate Perl Github Workflows with Caching"
slug: cache-perl-github-workflows
date: 2021-11-28T16:43:20Z
lastMod: 2023-02-20T23:55:17Z
description: A quick tip for speeding up Perl builds in GitHub workflows by caching dependencies.
tags: [Perl, GitHub, GitHub Actions, GitHub Workflows, Caching]
type: post
---

I've spent quite a few hours evenings and weekends recently building out a
comprehensive suite of [GitHub Actions for Sqitch]. They cover a dozen versions
of Perl, nearly 70 database versions amongst nine database engines, plus a
coverage test and a release workflow. A pull request can expect over 100 actions
to run. Each build requires over 100 direct dependencies, plus all *their*
dependencies. Installing them for every build would make any given run
untenable.

Happily, GitHub Actions include a [caching feature], and thanks to a
[recent improvement to shogo82148/actions-setup-perl][perl-version],
it's quite easy to use in a version-independent way. Here's an example:

``` yaml
name: Test
on: [push, pull_request]
jobs:
  OS:
    strategy:
      matrix:
        os: [ ubuntu, macos, windows ]
        perl: [ 'latest', '5.34', '5.32', '5.30', '5.28' ]
    name: Perl ${{ matrix.perl }} on ${{ matrix.os }}
    runs-on: ${{ matrix.os }}-latest
    steps:
      - name: Checkout Source
        uses: actions/checkout@v3
      - name: Setup Perl
        id: perl
        uses: shogo82148/actions-setup-perl@v1
        with: { perl-version: "${{ matrix.perl }}" }
      - name: Cache CPAN Modules
        uses: actions/cache@v3
        with:
          path: local
          key: perl-${{ steps.perl.outputs.perl-hash }}
      - name: Install Dependencies
        run: cpm install --verbose --show-build-log-on-failure --no-test --cpanfile cpanfile
      - name: Run Tests
        env: { PERL5LIB: "${{ github.workspace }}/local/lib/perl5" }
        run: prove -lrj4
```

This workflow tests every permutation of OS and Perl version specified in
`jobs.OS.strategy.matrix`, resulting in 15 jobs. The `runs-on` value determines
the OS, while the `steps` section defines steps for each permutation. Let's take
each step in turn:

*   "Checkout Source" checks the project out of GitHub. Pretty much required for
    any project.
*   "Setup Perl" sets up the version of Perl using the value from the matrix.
    Note the `id` key set to `perl`, used in the next step.
*   "Cache CPAN Modules" uses the [cache action] to cache the directory named
    `local` with the key `perl-${{ steps.perl.outputs.perl-hash }}`. The key
    lets us keep different versions of the `local` directory based on a unique
    key. Here we've used the `perl-hash` output from the `perl` step defined
    above. The `actions-setup-perl` action outputs this value, which contains a
    hash of the output of `perl -V`, so we're tying the cache to a very specific
    version and build of Perl. This is important since compiled modules are not
    compatible across major versions of Perl.
*   "Install Dependencies" uses [`cpm`] to quickly install Perl dependencies. By
    default, it puts them into the `local` subdirectory of the current directory
    --- just where we configured the cache. On the first run for a given OS and
    Perl version, it will install all the dependencies. But on subsequent runs
    it will find the dependencies already present, thank to the cache, and
    quickly exit, reporting "All requirements are satisfied." In [this Sqitch
    job], it takes less than a second.
*   "Run Tests" runs the tests that require the dependencies. It requires the
    `PERL5LIB` environment variable to point to the location of our cached
    dependencies.

That's the whole deal. The first run will be the slowest, depending on the
number of dependencies, but subsequent runs will be much faster, up to the
seven-day caching period. For a complex project like Sqitch, which uses the same
OS and Perl version for most of its actions, this results in a tremendous build
time savings. CI configurations we've used in the past often took an hour or
more to run. Today, most builds take only a few minutes to test, with longer
times determined not by dependency installation but by container and database
latency.

  [GitHub Actions for Sqitch]: https://github.com/sqitchers/sqitch/actions
  [caching feature]:
     https://docs.github.com/en/actions/advanced-guides/caching-dependencies-to-speed-up-workflows
     "GitHub Actions: “Caching dependencies to speed up workflows”"
  [perl-version]: https://github.com/shogo82148/actions-setup-perl/pull/892
  [cache action]: https://github.com/actions/cache
  [`cpm`]: https://metacpan.org/dist/App-cpm/view/script/cpm
    "cpm - a fast CPAN module installer"
  [this Sqitch job]:
    https://github.com/sqitchers/sqitch/runs/4275487924?check_suite_focus=true