--- 
date: 2013-11-26T20:14:00Z
title: Toward A Database URI Standard
url: /rfc/2013/11/26/toward-a-database-uri-standard/

categories: [rfc]
---

As part of my effort to improve [Sqitch], I plan to add support for [specifying
deployment targets via URIs]. Inspired by [Git remotes], targets will greatly
simplify the specification of databases to update --- especially when stored as
named targets in the configuration file.

Before implementing it, though, I started casting about for a standard
[URI Scheme] for database connections. Imagine my surprise[^1] to find that
there is none! The closest thing to a standard is [JDBC URLs]. Formally, their
format is simply:

    jdbc:<jdbc-specific-stuff>

Turns out that JDBC URLs are [barely URLs at all]. I mean, fine, according to
[RFC 3986] they start with the `jdbc:` scheme followed by whatever. According
to the [JDBC docs], what comes after the scheme is defined as follows:

    jdbc:<subprotocol>:<subname>

The "subprotocol" is simply a driver name, while the the format of the "subname
can vary, depending on the subprotocol, and it can have any internal syntax the
driver writer chooses, including a subsubname." In other words, it can be
anything at all. Not very satisfying, or particularly "standard."[^2]

In poking around the net, however, I found a fair number of database URI
formats defined by various projects:

* [PostgreSQL libpq URIs]
  `postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]`

* [SQLAlchemy URLs]:
  `dialect[+driver:]//[username[:password]@host[:port]/database`
  
* [Stackato database URLs]:
  `protocol://[username[:password]@host[:port]/database_name`
  
* [Django database URLs]:
  `ENGINE://[USER[:PASSWORD]@][HOST][:PORT]/DATABASE`

* [Rails database URLs]:
  `adapter://[userinfo@][hostname][:port]/database`

All very similar, right? Most database engines support all or a subset of these
connection parts in common:

* username
* password
* host address
* port
* database name
* configuration parameters

So why not define a standard database URI format with all those parts, and use
them where appropriate for each engine? It's all right there, just like
[http URLs].

The Proposal
------------

Here's [my proposal]. Formally, it's an opaque URI like JDBC. All database URIs
start with the scheme `db:`. But in this case, the opaque part is an embedded
URI that may be in one of two formats:

    engine://[username[:password]@]host[:port][/dbname][?params]
    engine:[dbname][?params]

In other words, a pretty typical http- or mailto-style URI format. We embed it
in a `db:` URI in order to identify the URI as a database URI, and to have a
single reasonable scheme to register. Informally, it's simplest to think of a
database URI as a single URI starting with the combination of the scheme and
the engine, e.g., `db:mysql`.

Some notes on the formats:

* The Database URI *scheme* is `db`. Consequently, database URIs always start
  with `db:`. This is the [URI scheme] that defines a database URI.

* Next comes the database *engine*. This part is a string naming the type of
  database engine for the database. It must always be followed by a colon, `:`.
  There is no formal list of supported engines, though certain implementations
  may specify engine-specific semantics, such as a default port.

* The *authority* part is separated from the engine by a double slash, `//`,
  and terminated by the next slash or end of the URI. It consists of an
  optional user-information part, terminated by `@` (e.g.,
  `username:password@`); a required host address (e.g., domain name or IP
  address); and an optional port number, preceded by a colon, `:`.

* The *path* part specifies the database name or path. For URIs that contain
  an authority part, a path specifying a file name must be absolute. URIs
  without an authority may use absolute or relative paths.

* The optional *query* part, separated by a question mark, `?`, contains
  `key=value` pairs separated by a semicolon, `;`, or ampersand, `&`. These
  parameters may be used to configure a database connection with parameters not
  directly supported by the rest of the URI format.

### Examples ###

Here are some database URIs without an authority part, which is typical for
non-server engines such as [SQLite], where the path part is a relative or
absolute file name:

* `db:sqlite:`
* `db:sqlite:foo.db`
* `db:sqlite:../foo.db`
* `db:sqlite:/var/db/foo.sqlite`

Other engines may use a database name rather than a file name:

* `db:ingres:mydb`
* `db:postgresql:template1`

When a URI includes an authority part, it must be preceded by a double slash:

* `db:postgresql://example.com`
* `db:mysql://root@localhost`
* `db:pg://postgres:secr3t@example.net`

To add the database name, separate it from the authority by a single slash:

* `db:postgresql://example.com/template1`
* `db:mongodb://localhost:27017/myDatabase`
* `db:oracle://scott:tiger@foo.com/scott`

Some databases, such as Firebird, take both a host name and a file path.
These paths must be absolute:

* `db:firebird://localhost/tmp/test.gdb`
* `db:firebird://localhost/C:/temp/test.gdb`

Any URI format may optionally have a query part containing key/value pairs:

* `db:sqlite:foo.db?foreign_keys=ON;journal_mode=WAL`
* `db:pg://localhost:5433/postgres?client_encoding=utf8;connect_timeout=10`

Issues
------

In discussing this proposal with various folks, I've become aware of a few
challenges to standardization.

First, the requirement that the authority part must include a host address
prevents the specification of a URI with a username that can be used to connect
to a Unix socket. PostgreSQL and MySQL, among others provide authenticated
socket connections. While [RFC 3986] requires the host name, its predecessor,
[RFC 2396], does not. Furthermore, as a precedent, neither do [file URIs]. So
I'm thinking of allowing something like this to connect to a PostgreSQL database

    db:pg://postgres:secr3t@/

In short, it makes sense to allow the user information without a host name.

The second issue is the disallowing of relative file names in the path part
following an authority part. The problem here is that most database engines
don't use paths for database names, so a leading slash makes no sense. For
example, in `db:pg:localhost/foo`, the PostgreSQL database name is `foo`, not
`/foo`. Yet in `db:firebird:localhost/foo`, the Firebird database name *is* a
path, `/foo`. So each engine implementation must know whether or not the path
part is a file name.

But some databases may in fact allow a path to be specified for a local
connection, and a name for a remote connection. [Informix] appears to support
such variation. So how is one to know whether the path is a file path or a
named database? The two variants cannot be distinguished.

[RFC 2396] is quite explicit that the path part must be absolute when following
an authority part. But [RFC 3986] forbids the double slash only when there is
no authority part. Therefore, I think it might be best to require a second
slash for absolute paths. Engines that use a simple name or relative path can
have it just after the slash, while an absolute path could use a second slash:

* Absolute: db:firebird://localhost//tmp/test.gdb
* Relative: db:firebird://localhost/db/test.gdb
* Name: db:postgresql://localhost/template1

That's It
---------

The path issue aside, I feel like this is a pretty simple proposal, and could
have wide utility. I've already knocked out a Perl reference implementation,
[URI::db]. Given the wide availability of URI parsers in various programming
languages, I wouldn't expect it to be difficult to port, either.

The [uri-db project] is the canonical home for the proposal for now, so check
there for updates. And your feedback would be appreciated! What other issues
have I overlooked? What have I got wrong? Let me know!

[^1]: As in not surprised at all. Though I was hoping!
[^2]: DSNs for Perl's [DBI](https://metacpan.org/module/DBI "MetaCPAN: DBI") aren't much better: `dbi:<driver>:<driver-specific-stuff>`.

[Sqitch]: http://sqitch.org/ "Sane database change management"
[specifying deployment targets via URIs]: https://github.com/theory/sqitch/issues/100 "Issue #100: “Add target command to configure target databases”"
[Git remotes]: http://git-scm.com/book/en/Git-Basics-Working-with-Remotes "Git Basics - Working with Remotes"
[URI Scheme]: http://en.wikipedia.org/wiki/URI_scheme "Wikipedia: “URI Scheme”"
[JDBC URLs]: http://www.jguru.com/faq/view.jsp?EID=690 "jGuru: “What is a database URL?”"
[barely URLs at all]: https://groups.google.com/forum/#!topic/comp.lang.java.programmer/twkIYNaDS64 "comp.lang.java.programmer: ”JDBC URLs ...not really URLs?“"
[RFC 3986]: http://www.ietf.org/rfc/rfc3986.txt "Uniform Resource Identifier (URI): Generic Syntax"
[RFC 2396]: http://www.ietf.org/rfc/rfc3986.txt "Uniform Resource Identifiers (URI): Generic Syntax"
[JDBC docs]: http://docs.oracle.com/javase/6/docs/technotes/guides/jdbc/getstart/connection.html#997649 "Getting Started with the JDBC API: “JDBC URLs”" 
[PostgreSQL libpq URIs]: http://www.postgresql.org/docs/9.3/static/libpq-connect.html#LIBPQ-CONNSTRING "PostgreSQL Documentation: “Connection Strings”"
[SQLAlchemy URLs]: http://docs.sqlalchemy.org/en/rel_0_9/core/engines.html#database-urls "SQLAlchemy Documentation: “Database Urls”"
[Stackato database URLs]: http://docs.stackato.com/3.0/user/services/data-services.html#database-url "Stackato Documentation: “DATABASE_URL”"
[Django database URLs]: https://github.com/kennethreitz/dj-database-url "DJ-Database-URL on GitHub"
[Rails database URLs]: https://github.com/glenngillen/rails-database-url "rails-database-url on GitHub"
[http URLs]: http://tools.ietf.org/html/rfc2616#page-19 "RFC 2616: “http URL”"
[my proposal]: https://github.com/theory/uri-db "Database URI on GitHub"
[URI scheme]: http://en.wikipedia.org/wiki/URI_scheme "Wikipedia: “URI scheme”"
[SQLite]: http://sqlite.org/ "SQLite Home Page"
[file URIs]: http://en.wikipedia.org/wiki/File_URI_scheme#Examples "Wikipedia: “File URI Scheme: Examples”"
[Informix]: https://metacpan.org/pod/DBD::Informix#INFORMIX-CONNECTION-SEMANTICS "MetaCPAN: “Informix Connection Semantics”"
[URI::db]: https://github.com/theory/uri-db/blob/master/lib/URI/db.pm "URI::db on GitHub"
[uri-db project]: https://github.com/theory/uri-db/ "uri-db on GitHub"
