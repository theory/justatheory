---
title: "Testing Perl Projects on Travis Windows"
date: 2019-01-20T22:21:15Z
lastMod: 2019-01-20T22:21:15Z
description: A [sample project](https://github.com/theory/winperl-travis) demonstrates a few techniques for testing Perl projects in the Travis CI Windows environment.
tags: [Perl, Travis CI, Windows, Strawberry Perl]
---

A few months ago, [Travis CI announced] early access for a [Windows build
environment]. In the last couple weeks, I spent some time to figure out how to
test Perl projects there by installing [Strawberry Perl] from [Chocolatey].

The result is the the sample project [winperl-travis]. It demonstrates three
`.travis.yml` configurations to test Perl projects on Windows:

1.  Use Windows instead of Linux to test multiple versions of Perl. This is the
    simplest configuration, but useful only for projects that never expect to
    run on a Unix-style OS.
2.  Add a Windows [build stage] that runs the tests against the latest version
    of [Strawberry Perl]. This pattern is ideal for projects that already test
    against multiple versions of Perl on Linux, and just want to make sure
    things work on windows.
3.  Add a [build stage] that tests against multiple versions of [Strawberry
    Perl] in separate jobs.

See the results of each of the three approaches in the [CI build]. A peek:

{{% figure
  src     = "winperl-travis-ci.png"
  alt     = "winperl-travis CI build results"
  class   = "frame"
  caption = "The Travis CI-default “Test” stage is the default, and runs tests on two versions of Perl on Windows. The “Windows” stage tests on a single version of Windows Perl, independent of the “Test” stage. And the “Strawberry” stage tests on multiple versions of Windows Perl independent of the “Test” stage."
%}}

If, like me, you just want to validate that your Perl project builds and its
tests pass on Windows (option 2), I adopted the formula in [text-markup
project]. The complete [`.travis.yml`]:

``` yaml
language: perl
perl:
  - "5.28"
  - "5.26"
  - "5.24"
  - "5.22"
  - "5.20"
  - "5.18"
  - "5.16"
  - "5.14"
  - "5.12"
  - "5.10"
  - "5.8"

before_install:
  - sudo pip install docutils
  - sudo apt-get install asciidoc
  - eval $(curl https://travis-perl.github.io/init) --auto

jobs:
  include:
    - stage: Windows
      os: windows
      language: shell
      before_install:
        - cinst -y strawberryperl
        - export "PATH=/c/Strawberry/perl/site/bin:/c/Strawberry/perl/bin:/c/Strawberry/c/bin:$PATH"
      install:
        - cpanm --notest --installdeps .
      script:
        - cpanm -v --test-only .
```

The files starts with the typical [Travis Perl] configuration: select the
language (Perl) and the versions to test. The `before_install` block installs a
couple of dependencies and executes the [travis-perl helper] for more flexible
Perl testing. This pattern practically serves as boilerplate for new Perl
projects.

The new bit is the `jobs.include` section, which declares a new build stage
named "Windows". This stage runs independent of the default phase, which runs on
Linux, and declares `os: windows` to run on Windows.

The `before_install` step uses the pre-installed [Chocolatey] package manager to
install the latest version of [Strawberry Perl] and update the `$PATH`
environment variable to include the paths to Perl and build tools. Note that the
Travis CI Window environment runs inside the [Git Bash] shell environment; hence
the Unix-style path configuration.

The `install` phase installs all dependencies for the project via [cpanminus], then
the `script` phase runs the tests, again using [cpanminus].

And with the stage set, the [text-markup build] has a nice new stage that ensures
all tests pass on Windows.

The use of [cpanminus], which ships with [Strawberry Perl], keeps things simple,
and is essential for installing dependencies. But projects can also perform the
usual `gmake test`[^strawberry-gmake-issue] or `perl Build.PL && ./Build test`
dance. Install [Dist::Zilla] via [cpanminus] to manage `dzil`-based projects.
Sadly, `prove` currently [does not work] under Git Bash[^prove-git-bash-workaround].

Perhaps Travis will add [full Perl support] and things will become even easier.
In the meantime, I'm pleased that I no longer have to guess about Windows
compatibility. The new Travis Windows environment enables a welcome increase in
cross-platform confidence.

  [^strawberry-gmake-issue]: Although versions of [Strawberry Perl] prior to
    5.26 have trouble installing `Makefile.PL`-based modules, including
    dependencies. I spent a fair bit of time trying to work out how to make it
    work, but ran out of steam. See [issue #1] for details.
  [^prove-git-bash-workaround]: I worked around this issue for [Sqitch] by
    simply adding [a copy of `prove`] to the repository.

  [Travis CI announced]: https://blog.travis-ci.com/2018-10-11-windows-early-release
    "Windows is Available (Early Release)"
  [Windows build environment]: https://docs.travis-ci.com/user/reference/windows/
  [Sqitch]: https://sqitch.org/
  [Strawberry Perl]: http://strawberryperl.com
    "Strawberry Perl: The Perl for MS Windows, free of charge!"
  [Chocolatey]: https://chocolatey.org
    "Chocolatey: The package manager for Windows"
  [winperl-travis]: https://github.com/theory/winperl-travis
  [build stage]: https://docs.travis-ci.com/user/build-stages/
    "Travis CI Docs: “Build Stages”"
  [CI build]: https://travis-ci.com/theory/winperl-travis
  [text-markup project]: https://github.com/theory/text-markup
  [`.travis.yml`]: https://github.com/theory/text-markup/blob/master/.travis.yml
  [Travis Perl]: https://docs.travis-ci.com/user/languages/perl/
    "Travis CI Docs: ”Building a Perl Project“"
  [travis-perl helper]: https://github.com/travis-perl/helpers
    "Perl Module Travis-CI Helper"
  [cpanminus]: https://github.com/miyagawa/cpanminus
  [text-markup build]: https://travis-ci.org/theory/text-markup
  [issue #1]: https://github.com/theory/winperl-travis/issues/1
    "wintravis-perl issue #1: “Strawberry Perl 5.24 Makefile.PL Builds Fail”"
  [Git Bash]: https://gitforwindows.org "git for Windows"
  [does not work]: https://rt.cpan.org/Ticket/Display.html?id=128221
     "Perl-Dist-Strawberry issue #128221: “Prove Perl Script not Installed”"
  [a copy of `prove`]: https://github.com/sqitchers/sqitch/blob/master/dev/prove
  [full Perl support]: https://travis-ci.community/t/perl-support-on-windows/321
    "Travis CI Community: “Perl support on Windows”"