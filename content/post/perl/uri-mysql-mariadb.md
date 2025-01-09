---
title: Should URI::mysql Switch to DBD::MariaDB?
slug: uri-mysql-mariadb
date: 2025-01-01T22:47:31Z
lastMod: 2025-01-01T22:47:31Z
description: |
  Should Sqitch and URI::mysql use DBD::MariaDB instead of DBD::mysql? If so,
  what are the implications for Sqitch deployment and usage?
tags: [Perl, Sqitch, URI::db, MySQL, MariaDB]
type: post
link: https://www.perlmonks.org/?node_id=11163487
---

I seek the wisdom of the Perl Monks:

> The Sqitch project got [a request][sqitch-825] to switch from [DBD::mysql]
> to [DBD::MariaDB]. DBD::mysql 5's requirement to build from the MySQL 8
> client library provides the impetus for the request, but in poking around, I
> found a [blogs.perl.org post] highlighting some Unicode fixes in
> DBD::MariaDB, as well.
>
> Now, Sqitch likely doesn't have the Unicode issue (it always works with Perl
> Unicode strings), but it depends on [URI::db] to provide the DBI connection
> string. For MySQL URIs, the [URI::mysql dbi_driver] method returns `mysql`.
>
> Should it be changed to return `MariaDB`, instead? Is there general
> community consensus that DBD::MariaDB provides better compatibility with
> both MySQL and MariaDB these days?
>
> I'm also curious what the impact of this change would be for Sqitch.
> Presumably, if DBD::MariaDB can build against either the MariaDB or MySQL
> client library, it is the more flexible choice to continue supporting both
> databases going forward.

Feedback appreciated [via PerlMonks] or the [Sqitch issue][sqitch-825].

> [!NOTE] Update 2025-01-08
>
> [URI-db 0.23] uses [DBD::MariaDB] instead of [DBD::mysql] for both
> URI::mysql and URI::MariaDB.
>
> Similarly, [Sqitch v1.5.0] always uses [DBD::MariaDB] when connecting to
> MySQL or MariaDB, even when using older versions of URI::db. Thanks everyone
> for the feedback and suggestions!

  [sqitch-825]: https://github.com/sqitchers/sqitch/issues/825
    "sqitchers/sqitch#825 Support DBD::MariaDB"
  [DBD::mysql]: https://metacpan.org/pod/DBD::mysql
  [DBD::MariaDB]: https://metacpan.org/pod/DBD::MariaDB
  [blogs.perl.org post]: https://blogs.perl.org/users/grinnz/2023/12/migrating-from-dbdmysql-to-dbdmariadb.html
  [URI::db]: https://metacpan.org/pod/URI::db
  [URI::mysql dbi_driver]: https://metacpan.org/dist/URI-db/source/lib/URI/mysql.pm#L6
  [via PerlMonks]: https://www.perlmonks.org/?node_id=11163487
  [URI-db 0.23]: https://metacpan.org/release/DWHEELER/URI-db-0.23
  [Sqitch v1.5.0]: https://github.com/sqitchers/sqitch/releases/tag/v1.5.0