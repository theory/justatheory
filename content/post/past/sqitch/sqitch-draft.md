--- 
date: 2012-04-06T02:08:40Z
slug: sqitch-draft
title: Sqitch — VCS-powered SQL Change Management
aliases: [/computers/databases/sqitch-draft.html]
tags: [Sqitch, SQL, Migrations, Databases, VCS, Git]
type: post
---

Back in January, I [wrote][] [three][] [posts] outlining some ideas I had about
a straight-forward, sane way of managing SQL change management. The idea
revolved around specifying scripts to deploy and revert in a plan file, and
generating that plan file from VCS history. I still feel pretty good about the
ideas there, and [work] has agreed to let me write it and open-source it. Here
is the first step making it happen. I call it “Sqitch.”

Why “Sqitch”? Think of it as SQL changes with Git stuck in the middle. Of course
I expect to support VCSs other than Git (probably Subversion and Mercurial,
though I am not sure yet), but since Git is what I now have the most familiarity
with, I thought it kind of fun to kind of reference a VCS in the name, if only
obliquely.

This week, I [started work on it]. My first task is to outline a draft for the
interface. Sqitch will be a command-line tool, primarily. The remainder of this
post contains the documentation for the draft interface. Thoughts and feedback
would be greatly appreciated, especially if you think I've overlooked anything!
I do want to keep features pretty minimal for now, though, to build up a solid
core to be built on later. But other than that, your criticism is greatly
desired.

Next up, I will probably write a tutorial, just so I can make my way through
some real-life(ish) examples and notice if I missed anything else. Besides, [I'm
going to need the tutorial myself]! Watch for that next week.

Thanks!

--------------------------------------------------------------------------------

### Name [Name]

Sqitch - VCS-powered SQL change management

### Synopsis [Synopsis]

    sqitch [<options>] <command> [<command-options>] [<args>]

### Description [Description]

Sqitch is a VCS-aware SQL change management application. What makes it different
from your typical [migration]-[style] approaches? A few things:

No opinions

:   Sqitch is not integrated with any framework, ORM, or platform. Rather, it is
    a standalone change management system with no opinions on your database or
    development choices.

Native scripting

:   Changes are implemented as scripts native to your selected database engine.
    Writing a [PostgreSQL] application? Write SQL scripts for [`psql`]. Writing
    a [MySQL]-backed app? Write SQL scripts for [`mysql`].

VCS integration

:   Sqitch likes to use your VCS history to determine in what order to execute
    changes. No need to keep track of execution order, your VCS already tracks
    information sufficient for Sqitch to figure it out for you.

Dependency resolution

:   Deployment steps can declare dependencies on other deployment steps. This
    ensures proper order of execution, even when you've committed changes to
    your VCS out-of-order.

No numbering

:   Change deployment is managed either by maintaining a plan file or, more
    usefully, your VCS history. As such, there is no need to number your
    changes, although you can if you want. Sqitch does not care what you name
    your changes.

Packaging

:   Using your VCS history for deployment but need to ship a tarball or RPM?
    Easy, just have Sqitch read your VCS history and write out a plan file with
    your change scripts. Once deployed, Sqitch can use the plan file to deploy
    the changes in the proper order.

Reduced Duplication

:   If you're using a VCS to track your changes, you don't have to duplicate
    entire change scripts for simple changes. As long as the changes are
    [idempotent], you can change your code directly, and Sqitch will know it
    needs to be updated.

#### Terminology [Terminology]

`step`

:   A named unit of change. A step name must be used in the file names of its
    corresponding deployment and a reversion scripts. It may also be used in a
    test script file name.

`tag`

:   A known deployment state with a list one or more steps that define the tag.
    A tag also implies that steps from previous tags in the plan have been
    applied. Think of it is a version number or VCS revision. A given point in
    the plan may have one or more tags.

`state`

:   The current state of the database. This is represented by the most recent
    tag or tags deployed. If the state of the database is the same as the most
    recent tag, then it is considered "up-to-date".

`plan`

:   A list of one or more tags and associated steps that define the order of
    deployment execution. Sqitch reads the plan to determine what steps to
    execute to change the database from one state to another. The plan may be
    represented by a ["Plan File"] or by VCS history.

`deploy`

:   The act of deploying database changes to reach a tagged deployment point.
    Sqitch reads the plan, checks the current state of the database, and applies
    all the steps necessary to change the state to the specified tag.

`revert`

:   The act of reverting database changes to reach an earlier tagged deployment
    point. Sqitch checks the current state of the database, reads the plan, and
    applies reversion scripts for all steps to return the state to an earlier
    tag.

### Options [Options]

    -p --plan-file  FILE    Path to a deployment plan file.
    -e --engine     ENGINE  Database engine.
    -c --client     PATH    Path to the engine command-line client.
    -d --db-name    NAME    Database name.
    -u --username   USER    Database user name.
    -h --host       HOST    Database server host name.
    -n --port       PORT    Database server port number.
       --sql-dir    DIR     Path to directory with deploy and revert scripts.
       --deploy-dir DIR     Path to directory with SQL deployment scripts.
       --revert-dir DIR     Path to directory with SQL reversion scripts.
       --test-dir   DIR     Path to directory with SQL test scripts.
       --extension  EXT     SQL script file name extension.
       --dry-run            Execute command without making any changes.
    -v --verbose            Increment verbosity.
    -V --version            Print the version number and exit.
    -H --help               Print a usage statement and exit.
    -M --man                Print the complete documentation and exit.

### Options Details [Options-Details]

`-p`

:   

`--plan-file`

:   sqitch --plan-file plan.conf
        sqitch -p sql/deploy.conf

    Path to the deployment plan file. Defaults to *./sqitch.plan*. If this file
    is not present, Sqitch will attempt to read from VCS files. If no supported
    VCS system is in place, an exception will be thrown. See ["Plan File"] for a
    description of its structure.

`-e`

:   

`--engine`

:   sqitch --engine pg
        sqitch -e sqlite

    The database engine to use. Supported engines include:

    -   `pg` - [PostgreSQL]

    -   `mysql` - [MySQL]

    -   `sqlite` - [SQLite]

`-c`

:   

`--client`

:   sqitch --client /usr/local/pgsql/bin/psql
        sqitch -c /usr/bin/sqlite3

    Path to the command-line client for the database engine. Defaults to a
    client in the current path named appropriately for the specified engine.

`-d`

:   

`--db-name`

:   Name of the database. For some engines, such as [PostgreSQL] and [MySQL],
    the database must already exist. For others, such as [SQLite], the database
    will be automatically created on first connect.

`-u`

:   

`--user`

:   

`--username`

:   User name to use when connecting to the database. Does not apply to all
    engines.

`-h`

:   

`--host`

:   Host name to use when connecting to the database. Does not apply to all
    engines.

`-n`

:   

`--port`

:   Port number to connect to. Does not apply to all engines.

`--sql-dir`

:   sqitch --sql-dir migrations/

    Path to directory containing deployment, reversion, and test SQL scripts. It
    should contain subdirectories named `deploy`, `revert`, and (optionally)
    `test`. These may be overridden by `--deploy-dir`, `--revert-dir`, and
    `--test-dir`. Defaults to `./sql`.

`--deploy-dir`

:   sqitch --deploy-dir db/up

    Path to a directory containing SQL deployment scripts. Overrides the value
    implied by `--sql-dir`.

`--revert-dir`

:   sqitch --revert-dir db/up

    Path to a directory containing SQL reversion scripts. Overrides the value
    implied by `--sql-dir`.

`--test-dir`

:   sqitch --test-dir db/t

    Path to a directory containing SQL test scripts. Overrides the value implied
    by `--sql-dir`.

`--extension`

:   sqitch --extension ddl

    The file name extension on deployment, reversion, and test SQL scripts.
    Defaults to `sql`.

`--dry-run`

:   sqitch --dry-run

    Execute the Sqitch command without making any actual changes. This allows
    you to see what Sqitch would actually do, without doing it. Implies a
    verbosity level of 1; add extra `--verbose`s for greater verbosity.

`-v`

:   

`--verbose`

:   sqitch --verbose -v

    A value between 0 and 3 specifying how verbose Sqitch should be. The default
    is 0, meaning that Sqitch will be silent. A value of 1 causes Sqitch to
    output some information about what it's doing, while 2 and 3 each cause
    greater verbosity.

`-H`

:   

`--help`

:   sqitch --help
        sqitch -H

    Outputs a brief description of the options supported by `sqitch` and exits.

`-M`

:   

`--man`

:   sqitch --man
        sqitch -M

    Outputs this documentation and exits.

`-V`

:   

`--version`

:   sqitch --version
        sqitch -V

    Outputs the program name and version and exits.

### Sqitch Commands [Sqitch-Commands]

`init`

:   Initialize the database and create deployment script directories if they do
    not already exist.

`status`

:   Output information about the current status of the deployment, including a
    list of tags, deployments, and dates in chronological order. If any deploy
    scripts are not currently deployed, they will be listed separately.

`check`

:   Sanity check the deployment scripts. Checks include:

    -   Make sure all deployment scripts have complementary reversion scripts.

    -   Make sure no deployment script appears more than once in the plan file.

`deploy`

:   Deploy changes. Configuration properties may be specified under the
    `[deploy]` section of the configuration file, or via `sqitch config`:

        sqitch config deploy.$property $value

    Options and configuration properties:

    `--to`

    :   Tag to deploy up to. Defaults to the latest tag or to the VCS `HEAD`
        commit. Property name: `deploy.to`.

`revert`

:   Revert changes. Configuration properties may be specified under the
    `[revert]` section of the configuration file, or via `sqitch config`:

        sqitch config revert.$property $value

    Options and configuration properties:

    `--to`

    :   Tag to revert to. Defaults to reverting all changes. Property name:
        `revert.to`.

`test`

:   Test changes. All SQL scripts in `--test-dir` will be run. \[XXX Not sure
    whether to have subdirectories for tests and expected output and to diff
    them, or to use some other approach.\]

`config`

:   Set configuration options. By default, the options will be written to the
    local configuration file, *sqitch.ini*. Options:

    `--get`

    :   Get the value for a given key. Returns error code 1.

    `--unset`

    :   Remove the line matching the key from config file.

    `--list`

    :   List all variables set in config file.

    `--global`

    :   For writing options: write to global *\~/.sqitch/config.ini* file rather
        than the local *sqitch.ini*.

        For reading options: read only from global *\~/.sqitch/config.ini*
        rather than from all available files.

    `--system`

    :   For writing options: write to system-wide *$prefix/etc/sqitch.ini* file
        rather than the local *sqitch.ini*.

        For reading options: read only from system-wide *$prefix/etc/sqitch.ini*
        rather than from all available files.

    `--config-file`

    :   Use the given config file.

`package`

:   Package up all deployment and reversion scripts and write out a plan file.
    Configuration properties may be specified under the `[package]` section of
    the configuration file, or via `sqitch config package.$property $value`
    command. Options and configuration properties:

    `--from`

    :   Tag to start the plan from. All tags and steps prior to that tag will
        not be included in the plan, and their change scripts Will be omitted
        from the package directory. Useful if you've rejiggered your deployment
        steps to start from a point later in your VCS history than the beginning
        of time. Property name: `package.from`.

    `--to`

    :   Tag with which to end the plan. No steps or tags after that tag will be
        included in the plan, and their change scripts will be omitted from the
        package directory. Property name: `package.to`.

    `--tags-only`

    :   Write the plan file with deployment targets listed under VCS tags,
        rather than individual commits. Property name: `package.tags_only`.

    `--destdir`

    :   Specify a destination directory. The plan file and `deploy`, `revert`,
        and `test` directories will be written to it. Defaults to "package".
        Property name: `package.destdir`.

### Configuration [Configuration]

Sqitch configuration information is stored in standard `INI` files. The `#` and
`;` characters begin comments to the end of line, blank lines are ignored.

The file consists of sections and properties. A section begins with the name of
the section in square brackets and continues until the next section begins.
Section names are not case sensitive. Only alphanumeric characters, `-` and `.`
are allowed in section names. Each property must belong to some section, which
means that there must be a section header before the first setting of a
property.

All the other lines (and the remainder of the line after the section header) are
recognized as setting properties, in the form `name = value`. Leading and
trailing whitespace in a property value is discarded. Internal whitespace within
a property value is retained verbatim.

All sections are named for commands except for one, named "core", which contains
core configuration properties.

Here's an example of a configuration file that might be useful checked into a
VCS for a project that deploys to PostgreSQL and stores its deployment scripts
with the extension *ddl* under the `migrations` directory. It also wants
packages to be created in the directory *\_build/sql*, and to deploy starting
with the "gamma" tag:

    [core]
        engine    = pg
        db        = widgetopolis
        sql_dir   = migrations
        extension = ddl

    [revert]
        to        = gamma

    [package]
        from      = gamma
        tags_only = yes
        dest_dir  = _build/sql

#### Core Properties [Core-Properties]

This is the list of core variables, which much appear under the `[core]`
section. See the documentation for individual commands for their configuration
options.

`plan_file`

:   The plan file to use. Defaults to *sqitch.ini* or, if that does not exist,
    uses the VCS history, if available.

`engine`

:   The database engine to use. Supported engines include:

    -   `pg` - [PostgreSQL]

    -   `mysql` - [MySQL]

    -   `sqlite` - [SQLite]

`client`

:   Path to the command-line client for the database engine. Defaults to a
    client in the current path named appropriately for the specified engine.

`db_name`

:   Name of the database.

`username`

:   User name to use when connecting to the database. Does not apply to all
    engines.

`password`

:   Password to use when connecting to the database. Does not apply to all
    engines.

`host`

:   Host name to use when connecting to the database. Does not apply to all
    engines.

`port`

:   Port number to connect to. Does not apply to all engines.

`sql_dir`

:   Path to directory containing deployment, reversion, and test SQL scripts. It
    should contain subdirectories named `deploy`, `revert`, and (optionally)
    `test`. These may be overridden by `deploy_dir`, `revert_dir`, and
    `test_dir`. Defaults to `./sql`.

`deploy_dir`

:   Path to a directory containing SQL deployment scripts. Overrides the value
    implied by `sql_dir`.

`revert_dir`

:   Path to a directory containing SQL reversion scripts. Overrides the value
    implied by `sql_dir`.

`test_dir`

:   Path to a directory containing SQL test scripts. Overrides the value implied
    by `sql_dir`.

`extension`

:   The file name extension on deployment, reversion, and test SQL scripts.
    Defaults to `sql`.

### Plan File [Plan-File]

A plan file describes the deployment tags and scripts to be run against a
database. In general, if you use a VCS, you probably won't need a plan file,
since your VCS history should be able to provide all the information necessary
to derive a deployment plan. However, if you really do need to maintain a plan
file by hand, or just want to better understand the file as output by the
`package` command, read on.

#### Format [Format]

The contents of the plan file are plain text encoded as UTF-8. It is divided up
into sections that denote deployment states. Each state has a bracketed,
space-delimited list of one or more tags to identify it, followed by any number
of deployment steps. Here's an example of a plan file with a single state and a
single step:

    [alpha]
    users_table

The state has one tag, named "alpha", and one step, named "users\_table". A
state may of course have many steps. Here's an expansion:

    [root alpha]
    users_table
    insert_user
    update_user
    delete_user

This state has two tags, "root" and "alpha", and four steps, "users\_table",
"insert\_user", "update\_user", and "delete\_user".

Most plans will have multiple states. Here's a longer example with three states:

    [root alpha]
    users_table
    insert_user
    update_user
    delete_user

    [beta]
    widgets_table
    list_widgets

    [gamma]
    ftw

Using this plan, to deploy to the "beta" tag, the "root"/"alpha" state steps
must be deployed, as must the "beta" steps. To then deploy to the "gamma" tag,
the "ftw" step must be deployed. If you then choose to revert to the "alpha"
tag, then the "gamma" step ("ftw") and all of the "beta" steps will be reverted
in reverse order.

Using this model, steps cannot be repeated between states. One can repeat them,
however, if the contents for a file in a given tag can be retrieved from a VCS.
An example:

    [alpha]
    users_table

    [beta]
    add_widget
    widgets_table

    [gamma]
    add_user

    [44ba615b7813531f0acb6810cbf679791fe57bf2]
    widgets_created_at

    [HEAD epsilon master]
    add_widget

This example is derived from a Git log history. Note that the "add\_widget" step
is repeated under the state tagged "beta" and under the last state. Sqitch will
notice the repetition when it parses this file, and then, if it is applying all
changes, will fetch the version of the file as of the "beta" tag and apply it at
that step, and then, when it gets to the last tag, retrieve the deployment file
as of its tags and apply it. This works in reverse, as well, as long as the
changes in this file are always [idempotent].

#### Grammar [Grammar]

Here is the EBNF Grammar for the plan file:

    plan-file   = { <state> | <empty-line> | <comment> }* ;

    state       = <tags> <steps> ;

    tags        = "[" <taglist> "]" <line-ending> ;
    taglist     = <name> | <name> <white-space> <taglist> ;

    steps       = { <step> | <empty-line> | <line-ending> }* ;
    step        = <name> <line-ending> ;

    empty-line  = [ <white-space> ] <line-ending> ;
    line-ending = [ <comment> ] <EOL> ;
    comment     = [ <white-space> ] "#" [ <string> ] ;

    name        = ? non-white space characters ? ;
    white-space = ? white space characters ? ;
    string      = ? non-EOL characters ? ;

### See Also [See-Also]

The original design for Sqitch was sketched out in a number of blog posts:

-   [Simple SQL Change Management][wrote]

-   [VCS-Enabled SQL Change Management][three]

-   [SQL Change Management Sans Duplication][posts]

Other tools that do database change management include:

[Rails migrations]

:   Numbered migrations for [Ruby on Rails].

[Module::Build::DB][migration]

:   Numbered changes in pure SQL, integrated with Perl's [Module::Build] build
    system. Does not support reversion.

[DBIx::Migration][style]

:   Numbered migrations in pure SQL.

[Versioning]

:   PostgreSQL-specific dependency-tracking solution by [depesz].

### Author [Author]

David E. Wheeler \<david@justatheory.com\>

### License [License]

Copyright (c) 2012 iovation Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  [wrote]: /computers/databases/simple-sql-change-management.html
  [three]: /computers/databases/vcs-sql-change-management.html
  [posts]: /computers/databases/sql-change-management-sans-redundancy.html
  [work]: http://iovation.com/
  [started work on it]: https://github.com/theory/sqitch
  [I'm going to need the tutorial myself]: https://www.pgcon.org/2012/schedule/events/479.en.html
  [migration]: http://search.cpan.org/perldoc?Module::Build::DB
  [style]: http://search.cpan.org/perldoc?DBIx::Migration
  [PostgreSQL]: http://postgresql.org/
  [`psql`]: http://www.postgresql.org/docs/current/static/app-psql.html
  [MySQL]: http://mysql.com/
  [`mysql`]: http://dev.mysql.com/doc/refman/5.6/en/mysql.html
  [idempotent]: https://en.wikipedia.org/wiki/Idempotence
  ["Plan File"]: #Plan-File
  [SQLite]: http://sqlite.org/
  [Rails migrations]: http://guides.rubyonrails.org/migrations.html
  [Ruby on Rails]: http://rubyonrails.org/
  [Module::Build]: http://search.cpan.org/perldoc?Module::Build
  [Versioning]: http://www.depesz.com/2010/08/22/versioning/
  [depesz]: http://www.depesz.com/
