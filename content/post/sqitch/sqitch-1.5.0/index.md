---
title: Sqitch 1.5.0
slug: sqitch-1.5.0
date: 2025-01-09T02:30:18Z
lastMod: 2025-01-09T02:30:18Z
description: |
  Sqitch v1.5.0: out now in all the usual places!
tags: [Sqitch, MariaDB, MySQL, Yugabyte, Oracle, Snowflake]
type: post
image:
  src: sqitch-icon.svg
  alt: Sqitch Logo
  class: clear right
  width: 256px
  title: "Sqitch: Sensible database change management"
---

Released yesterday: [Sqitch] v1.5.0. This version the MySQL driver
[DBD::mysql] with [DBD::MariaDB], both for its better backward compatibility
with MySQL as well as MariaDB driver libraries and for its improved Unicode
handling. The [Docker image][Docker] likewise switched to the MariaDB `mysql`
client. I expect no compatibility issues, but you never know! Please file an
[issue] should you find any.

V1.5.0 also features a fixes for Yugabyte deployment, Oracle error handling,
existing Snowflake schemas, connecting to MySQL/MariaDB without a database
name, and omitting the `checkit` MySQL/MariaDB function when the Sqitch user
lacks sufficient permission to create it. Sqitch now will also complain when
deploying with `--log-only` and a deployment file is missing.

Find it in the usual places:

*   [sqitch.org][Sqitch]
*   [GitHub]
*   [CPAN]
*   [Docker]
*   [Homebrew]

Many thanks to everyone who has enjoyed using Sqitch and let me know in
person, via email Mastodon, bug reports, and patches. It gratifies me how
useful people find it.

  [Sqitch]: https://sqitch.org "Sqitch: Sensible database change management"
  [DBD::mysql]: https://metacpan.org/pod/DBD::mysql
    "DBD::mysql - MySQL driver for the Perl5 Database Interface (DBI)"
  [DBD::MariaDB]: https://metacpan.org/pod/DBD::MariaDB
    "DBD::MariaDB - MariaDB and MySQL driver for the Perl5 Database Interface (DBI)"
  [Docker]: https://hub.docker.com/r/sqitch/sqitch
  [issue]: https://github.com/sqitchers/sqitch/issues "Sqitch Issues"
  [GitHub]: https://github.com/sqitchers/sqitch
  [CPAN]: https://metacpan.org/dist/App-Sqitch
  [Homebrew]: https://github.com/sqitchers/homebrew-sqitch
