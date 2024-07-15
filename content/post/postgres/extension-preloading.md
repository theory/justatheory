---
title: Extension Preloading
slug: extension-preloading
date: 2024-07-15T21:03:01Z
lastMod: 2024-07-15T21:03:01Z
description: When should a Postgres extension be pre-loaded and when should it not?
tags: [Postgres, Extensions, Preload]
type: post
---

Recently I've been trying to figure out when a Postgres extension module
should be preloaded. By "extension" I mean, more generally, shared libraries
provided or used by extensions to Postgres, whether a `CREATE EXTENSION`
extension written in C or [pgrx] or a [`LOAD`]able module. By "preloaded" I
mean under what conditions should it be added to one of the [Shared Library
Preloading] variables:

*   `local_preload_libraries`
*   `session_preload_libraries`
*   `shared_preload_libraries`

The answer, it turns out, comes very much down to the extension type.

Normal Extensions
-----------------

If your extension includes no loadable modules, congratulations! You don't
have to worry about this question at all.

If your extension's shared library provides functionality only via functions
called from SQL, you also don't need to worry about this preloading. Custom
types, operators, and functions generally follow this pattern. The DDL that
creates the SQL object, such as [`CREATE FUNCTION`], uses the `AS 'obj_file',
'link_symbol'` syntax to tell that PostgreSQL what library to load when it's
needed.

Hook Extensions
---------------

If your extension's shared library makes calls to PostgreSQL without
PostgreSQL first calling it, then the library must be loaded before it's used.
This is typically the case for libraries that modifies the server's behavior
through "hooks" rather than providing a set of functions.

### Session Preloading

If your extension is intended for debugging or performance-measurement, it
likely doesn't need to be preloaded for every connection. In this case, a DBA
might allow specific users to load it by either:

*   Adding it to the [`session_preload_libraries`] variable for the user via
    [`ALTER ROLE`], so it loads for every connection for that user:

    ```sql
    ALTER ROLE role_name
      SET session_preload_libraries TO '$libdir/mylib';
    ```

*   Granting the user role the ability to set `session_preload_libraries`
    which would allow them to use it (and any other shared library) in
    `PGOPTIONS`:

    ```sql
    GRANT SET ON PARAMETER session_preload_libraries
       TO role_name;
    ```

As an extension author, you don't need to do any special configuration, as
long as your module is installed in the usual location via the [`MODULES`]
`Makefile` variable. Still, it will be useful to document these options so
that DBAs quickly see how to set things up for the users who need them.

### Local Preloading

As a special case, a DBA might want to make your debugging or
performance-measurement extension available to any user who needs it, even
unprivileged users. All they need to do is move it from `$libdir` to
`$libdir/plugins`.

Then any Postgres user can load it via the [`LOAD`] command or include it in
their [`local_preload_libraries`] configuration via either [`PGOPTIONS`] or,
for every connection, via `ALTER ROLE SET`:

```sql
ALTER ROLE role_name
  SET local_preload_libraries TO '$libdir/plugins/mylib';
```

As an extension author, you don't need to do any special configuration; there
is no `Makefile` variable to install it in the the `$libdir/plugins`
directory. But it might be handy for DBAs to document this option *in addition
to* the [session preloading](#session-preloading) options. But emphasize that
it should be used if and *only if* they want to allow any and all of their
users to load your extension library without any further intervention.

### Shared Preloading

The last preloading variable is [`shared_preload_libraries`], which should be
required for modules to run in every session or to perform operations only
available at service start up, such as [shared memory and lightweight locks]
or starting [background workers].

As an extension author, if your extension requires `shared_preload_libraries`
preloading, the documentation should say so explicitly, and explain why. For
examples of wording, see [pg_stat_statements], [sepgsql], and [auth_delay].

Beyond these limited cases, any other modules can be added to
[`shared_preload_libraries`] for efficiency purposes. However, since shared
preload modules are loaded into every server process --- even if that process
never uses the library --- preloading them is recommended only for libraries
used in most sessions.

As an extension author, it will be kind to DBAs to include this information,
and to describe the circumstances under which they *might* want to preload
your library in every service --- along with the caveat that doing so requires
a server restart. For example wording, see [PL/Perl] and [auto_explain]

### A Final Note

One more requirement to carefully document is dependence on shared libraries
provided by *other* extensions. For example, [Shaun Thomas] tells me that the
[BDR] extension used to rely on [pglogical] being loaded first. The
implication for preloading was that [pglogical] had to appear in the
`shared_preload_libraries` variable *before* [BDR].

So if your preload-requiring extension depends on other extensions, be sure to
document the importance of load order and the impact on the format of the 
`shared_preload_libraries` variable.



  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
  [`LOAD`]: https://www.postgresql.org/docs/current/sql-load.html
    "PostgreSQL Docs: LOAD"
  [Shared Library Preloading]: https://www.postgresql.org/docs/current/runtime-config-client.html#RUNTIME-CONFIG-CLIENT-PRELOAD
    "PostgreSQL Docs: Shared Library Preloading"
  [`CREATE FUNCTION`]: https://www.postgresql.org/docs/current/sql-createfunction.html
    "PostgreSQL Docs: `MODULES`"
  [`session_preload_libraries`]: https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-SESSION-PRELOAD-LIBRARIES
    "PostgreSQL Docs: `session_preload_libraries`"
  [`ALTER ROLE`]: https://www.postgresql.org/docs/current/sql-alterrole.html
    "PostgreSQL Docs: ALTER ROLE"
   [`PGOPTIONS`]: https://www.postgresql.org/docs/current/config-setting.html#CONFIG-SETTING-SHELL
     "PostgreSQL Docs: Parameter Interaction via the Shell"
  [`local_preload_libraries`]: https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-LOCAL-PRELOAD-LIBRARIES
    "PostgreSQL Docs: `local_preload_libraries`"
  [`MODULES`]: https://www.postgresql.org/docs/current/extend-pgxs.html#EXTEND-PGXS-MODULES
    "PostgreSQL Docs: CREATE FUNCTION"
  [`shared_preload_libraries`]: https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-SHARED-PRELOAD-LIBRARIES
    "PostgreSQL Docs: `shared_preload_libraries`"
  [background workers]: https://www.postgresql.org/docs/current/bgworker.html
    "PostgreSQL Docs: Background Worker Processes"
  [shared memory and lightweight locks]: https://www.postgresql.org/docs/16/xfunc-c.html#XFUNC-SHARED-ADDIN
    "PostgreSQL Docs: Shared Memory and LWLocks"
  [pg_stat_statements]: https://www.postgresql.org/docs/16/pgstatstatements.html
    "PostgreSQL Docs: pg_stat_statements"
  [sepgsql]: https://www.postgresql.org/docs/16/sepgsql.html#SEPGSQL-INSTALLATION
    "PostgreSQL Docs: sepgsql"
  [auth_delay]: https://www.postgresql.org/docs/16/auth-delay.html
    "PostgreSQL Docs: auth_delay"
  [PL/Perl]: https://www.postgresql.org/docs/16/plperl-under-the-hood.html#GUC-PLPERL-ON-INIT
    "PostgreSQL Docs: plperl.on_init"
  [auto_explain]: https://www.postgresql.org/docs/16/auto-explain.html
    "PostgreSQL Docs: auto_explain"
  [Shaun Thomas]: http://bonesmoses.org
  [BDR]: https://wiki.postgresql.org/wiki/BDR_Project
    "PostgreSQL Wiki: BDR Project"
  [pglogical]: https://github.com/2ndQuadrant/pglogical
    "Logical Replication extension for PostgreSQL"
