---
title: "Sqitch v1.0.0"
date: 2019-06-04T16:27:22Z
lastMod: 2022-06-12T03:26:54Z
description: After seven years of development and production database deployments, I finally put in the effort to release v1.0.0.
tags: [Sqitch, Databases, Change Management, Finally]
type: post
image:
  src: sqitch-logo.svg
  alt: Sqitch Logo
  title: "Sqitch: Sensible database change management"
---

After seven years of development and hundreds of production database
deployments, I finally decide it was time to release [Sqitch v1.0.0], and
today's the day. I took the opportunity to resolve all known bugs in previous
releases, so there's no new functionality since [v0.9999]. Still, given the
typical attention given to a significant milestone release like 1.0.0, my
employer published a [blog post] describing a bit of the history and philosophy
behind Sqitch.

The [new site] goes into great detail describing [how to install Sqitch],
but the important links are:

*   [CPAN] --- Install Sqitch from CPAN
*   [Docker] --- Run Sqitch from a Docker container
*   [Homebrew] --- Homebrew Sqitch on macOS
*   [GitHub] --- Sqitch releases on GitHub

Thanks to everyone who helped get Sqitch to this point, I appreciate it
tremendously. I'm especially grateful to:

*   [Kurk Spendlove], my manager when I started at iovation in late 2011, who
    gave me the space and the time to figure this thing out for most of 2012.
*   [Ștefan Suciu] has contributed a ton, notably [Firebird support].
*   [Shawn Sorichetti] has lately taken on the task of merge manager,
    reviewing and approving all recent Sqitch pull requests.
*   [Johan Wärlander] contributed [Exasol support].
*   [Luca Ferrari] and [@BeaData] provided the Italian localization.
*   [Thomas Iguchi] provided the German localization.
*   [Dave Rolsky] and [Curtis Poe], as well as Ștefan and Shawn, who have agreed
    to help manage the project, ensuring a stable and productive future for the
    project.
*   [Craig Brewster] gave me super useful feedback on the [new site] design and
    [logos].
*   [Stephen Lovell] and [Gaston Figueroa] helped me diagnose and fix issues
    with the [new site] in MSIE/Edge.
*   The dozens of [other contributors] who have helped make Sqitch a success.
*   The countless people who have reported, commented on, and helped diagnose
    [Sqitch issues].

Thanks a million for all your help and support!

  [Sqitch v1.0.0]: https://metacpan.org/release/DWHEELER/App-Sqitch-v1.0.0
  [v0.9999]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.9999
  [blog post]:
    https://web.archive.org/web/20200513005649/https://www.iovation.com/blog/out-of-incubation-and-ready-for-broad-adoption-sqitch-1-released
    "Out of Incubation and Ready for Broad Adoption; Sqitch 1.0 Released"
  [new site]: https://sqitch.org/
  [how to install Sqitch]: https://sqitch.org/download/ "Download Sqitch"
  [CPAN]: https://metacpan.org/release/App-Sqitch "Sqitch on CPAN"
  [Docker]: https://hub.docker.com/r/sqitch/sqitch "Sqitch on docker hub"
  [Homebrew]: https://github.com/sqitchers/homebrew-sqitch/ "Sqitch Homebrew Tap"
  [GitHub]: https://github.com/sqitchers/sqitch/releases "Sqitch on GitHub"
  [Kurk Spendlove]: https://linkedin.com/in/kurksp/
  [Ștefan Suciu]: http://stefansuciu.ro/
  [Firebird support]: https://sqitch.org/docs/manual/sqitchtutorial-firebird/
    "Sqitch Firebird tutorial"
  [Shawn Sorichetti]: https://ssoriche.com/
  [Johan Wärlander]: https://github.com/jwarlander
  [Luca Ferrari]: https://fluca1978.github.io
  [@BeaData]: https://github.com/BeaData
  [Thomas Iguchi]: https://www.nobu-games.com
  [Exasol support]: https://sqitch.org/docs/manual/sqitchtutorial-exasol/
    "Sqitch Exasol tutorial"
  [Dave Rolsky]: http://blog.urth.org/
  [Curtis Poe]: https://ovid.github.io/
  [other contributors]: https://github.com/sqitchers/sqitch/graphs/contributors
    "Sqitch Contributors"
  [Craig Brewster]: https://linkedin.com/in/craig-brewster-02b6b95/
  [logos]: https://sqitch.org/download/logos/ "Sqitch Logos"
  [Stephen Lovell]: http://stephencreates.com
  [Gaston Figueroa]: http://www.gastonfig.com
  [Sqitch issues]: https://github.com/sqitchers/sqitch/issues