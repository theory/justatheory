---
title: "RFC: Extension Packaging & Lookup"
slug: rfc-extension-packaging-lookup
date: 2024-11-25T19:00:36Z
lastMod: 2024-11-25T19:00:36Z
description: |
  A proposal to modify the PostgreSQL core so that all files required for an
  extension live in a directory named for the extension, along with a search
  path to find extension directories.
tags: [Postgres, Extensions, RFC, Packaging, Kubernetes, OCI, Packaging, Postgres.app]
type: post
draft: true
---

Several weeks ago, I started [a pgsql-hackers thread] proposing a new
extension file organization and a search path [GUC] for finding extensions.
The [discussion] of [Christoph Berg]'s [`extension_destdir` patch][destdir]
inspired this proposal. These threads cover quite a lot of territory, so I
want to pull together a more unified, public proposal.

Here goes.

## Challenges

A number of challenges face extension users, thanks to extension file
organization in the Postgres core. The common thread among them is the need to
add extensions without changing the contents of the Postgres installation
itself.

### Packager Testing

On Debian systems, the user account that creates extension packages lacks
permission to add files to Postgres install. But testing extensions requires
installing the extension where Postgres can find it. Moreover, extensions
ideally build against a clean Postgres install; adding an extension in order
to run `make installcheck` would pollute it.

[Christoph's patch][destdir] solves these problems by adding a second lookup
path for extensions and dynamic modules, so that Postgres can load them
directly from the package build directory.

Alas, the patch isn't ideal, because it simply specifies a prefix and appends
the full `pg_config` directory paths to it. For example, if `--sharedir`
outputs `/opt/share` and `extension_destdir` GUC is set to `/tmp/build/myext`,
the patch will search in `/tmp/build/myext/opt/share`. This approach works for
the packaging use case, which explicitly uses full paths with a prefix, but
would be weird for other use cases.

Peter Eisentraut proposed an [alternate patch][pe patch] with a new `GUC`,
`extension_control_path`, that provides a more typical search path pattern to
find extension control files, but doesn't account for shared modules that ship
with an extension, requiring that they still live in the
[`dynamic_library_path`]. Installing into custom directories requires the
undocumented `datadir` and `pkglibdir` variables:

``` sh
make install datadir=/else/where/share pkglibdir=/else/where/lib
```

This pattern can probably be simplified.

### OCI Immutability

[OCI] (née Docker) images are immutable, while a container image runs on a
writeable but non-persistent file system. To install persistent extensions in
a container, one must create a persistent volume, map it to
`SHAREDIR/extensions`, and copy over all the extensions it needs (or muck with
[symlink magic]). Then do it again for shared object libraries (`PKGLIBDIR`),
and perhaps also for other `pg_config` directories, like `--bindir`. Once it's
all set up, one can install a new extension and its files will be distributed
to the relevant persistent volumes.

This pattern makes upgrades tricky, because the core extensions are mixed in
with third-party extensions. Worse, the number of directories that must be
mounted into volumes depends on the features of an extension, increasing
deployment configuration complexity. It would be preferable to have all the
files for an extension in one place, rather than scattered across multiple
persistent volumes.

[Peter Eisentraut's patch][pe patch] addresses much of this issue by adding a
search path for extension control files and related data/share files
(generally SQL files). One can create a single volume with a `lib` directory
for shared modules and `share/extension` directory for control and data/share
files.

### OCI Extension Images

However, an additional wrinkle is the ambition from the [CloudNativePg][CNPG]
([CNPG]) community to eliminate the need for a persistent volume, and rely
instead on mounting images that each contain all the files for a single
extension as their own volumes, perhaps using [Kubernetes image volume
feature], (currently in alpha).

This feature requires all the file in an extension to live in a single
directory, a volume mounted to an extension image contains all the files
required to use the extension. The search path patches proposed so far do not
enable this behavior.

### Postgres.app Immutability

The macOS [Postgres.app] supports extensions. But installing one into
`SHAREDIR/extensions` changes the contents of the Postgres.app bundle,
breaking Apple-required signature validation. The OS will no longer be able to
validate that the app is legit and refuse to start it.

Peter Eisentraut's [new patch][pe patch] addresses this issue as well, with
all the same caveats as for the [packager testing](#packager-testing)
challenges.

## Solution

To further address these issues, this RFC proposes to change file organization
and lookup patterns for PostgreSQL extensions.

### Extension Directories

First, when an extension is installed, by default all of its files will live
in a single directory named for the extension. The contents include:

*   The Control file that describes extension
*   Subdirectories for SQL, shared modules, docs, binaries, etc.

Subdirectories roughly correspond to the `pg_config --*dir` options:

*   `bin`: Executables
*   `doc`: Documentation files
*   `html`: HTML documentation files
*   `lib`: Dynamically loadable modules
*   `locale`: Locale support files
*   `man`: Manual pages
*   `share`: SQL and other architecture-independent support files

This layout reduces the cognitive overhead for understanding what files belong
to what extension. Want to know what's included in the `widget` extension?
Everything is in the `widget` directory. It also simplifies installation of an
extension: one need add only a directory named for and containing the files
required by the extension.

### Configuration Parameter

Add a new `pg_config` value that returns the directory into which extensions
will by default be installed:

```
 --extdir   show location of extensions
```

Its default value would be `$(pg_config --sharedir)/extension`, but could be
set at compile time like other configuration parameters. Its contents consist
of subdirectories that each contain an extension, as described in [Extension
Directories](#extension-directories). With a few extensions installed, it
would look something like:

``` console
❯ ls -1 "$(pg_config --extdir)"
auto_explain
bloom
isn
pair
plperl
plpgsql
plv8
xml2
semver
vector
```

### Extension Path

Add an extension lookup path GUC akin to [`dynamic_library_path`], called
`extension_path`. It lists all the directories that Postgres will search for
extensions and their files. The default value for this GUC will be:

``` ini
extension_path = '$extdir'
```

The special string `$extdir` corresponds to the `pg_config` option of the same
name, and function exactly as `$libdir` does for the `dynamic_library_path`
GUC, substituting the appropriate value.

### Lookup Execution

Update PostgreSQL's `CREATE EXTENSION` command to search the directories in
`extension_path` for an extension. For each directory in the list, it will
look for the extension control file in a directory named for the extension:

``` sh
$dir/$extension/$extension.control
```

The first match will be considered the canonical location for the extension.
For example, if Postgres finds the control file for the `pair` at
`/opt/pg17/ext/pair/pair.control`, it will load files only from the
appropriate subdirectories, e.g.:

*   SQL files from `/opt/pg17/ext/pair/share`
*   Shared module files from `/opt/pg17/ext/pair/lib`

### PGXS

Update the extension installation behavior of [PGXS] to install extension
files into the new layout. A new variable, `$EXTDIR`, will define the
directory into which to install extension directories, and default to
`$(pg_config --extdir)`. It can be set to any literal path, which must exist
and be accessible by the PostgreSQL service.

The `$EXTENSION` variable will be changed to allow only one extension name. If
it's set, the installation behavior will be changed for the following
variables:

*   `EXTENSION`: Creates `$EXTDIR/$EXTENSION`, installs
    `$EXTDIR/$EXTENSION/$EXTENSION.control`
*   `MODULES` and `MODULE_big`: Installed into `$EXTDIR/$EXTENSION/lib`
*   `MODULEDIR`: Removed
*   `DATA` and `DATA_built`: Installed into `$EXTDIR/$EXTENSION/share`
*   `DATA_TSEARCH`: Installed into `$EXTDIR/$EXTENSION/share/tsearch_data`
*   `DOCS`: Installed into `$EXTDIR/$EXTENSION/doc`
*   `PROGRAM`, `SCRIPTS` and `SCRIPTS_built`: Installed into
    `$EXTDIR/$EXTENSION/bin`

Each of these locations can still be overridden by setting one of the
(currently undocumented) [installation location options] (e.g., `datadir`,
`pkglibdir`, etc.).

> [!NOTE] External projects that install extensions without using PGXS, like
> [pgrx], must also be updated to either follow the same pattern or to
> delegate installation to [PGXS].

### Control File

The `directory` control file parameter will be deprecated and ignored.

The `module_pathname` parameter should only name a shared module in the `lib`
subdirectory of an extension directory. Any existing use of a `$libdir` prefix
will be stripped out and ignored before replacing the `MODULE_PATHNAME` string
in SQL files. The implication for loading extension dynamic modules[^modules]
differs from the [existing behavior] as follows:

1.  If the name is an absolute path, the given file is loaded.
2.  If the name does not contain a directory part, the file is searched for in
    the in the `lib` subdirectory of the extension's directory
    (`$EXTDIR/$EXTENSION/lib`).
3.  Otherwise (the file was not found in the path, or it contains a
    non-absolute directory part), the dynamic loader will try to take the name
    as given, which will most likely fail. (It is unreliable to depend on the
    current working directory.)

## Use Cases

Here's how the proposed file layout and `extension_path` GUC addresses the
[use cases](#challenges) that inspired this RFC.

### Packager Testing

A packager who wants to run tests without modifying a PostgreSQL install would
follow these steps:

*   Prepend a directory under the packaging install to the `extension_path`
    GUC. The resulting value would be something like
    `$RPM_BUILD_ROOT/$(pg_config --extdir):$extdir`.
*   Install the extension into that directory:
    `make install EXTDIR=$RPM_BUILD_ROOT`
*   Make sure the PostgreSQL server can access the directory, then run
    `make installcheck`

This will allow PostgreSQL to find and load the extension during the tests.
The Postgres installation will not have been modified; only the
`extension_path` will have changed.

### OCI/Kubernetes

To allow extensions to be added to a OCI container and to persist beyond its
lifetime, one or more [volumes] could be used. Some examples:

*   Mount a persistent volume for extensions and prepend the path to that
    directory to the `extension_path` GUC. Then Postgres can find any
    extensions installed there, and they will persist. Files for all
    extensions will live on a single volume.
*   Or, to meet a desire to keep some extensions separate (e.g., open-source
    vs company-internal extensions), two or more persistent volumes could be
    mounted, as long as they're all included in `extension_path`, are
    accessible by PostgreSQL, and users take care to install extensions in the
    proper locations.

### CNPG Extension Images

To meet the [CNPG] ambition to "install" an extension by mounting a single
directory for each, create separate images for each extension, then use the
[Kubernetes image volume feature] (currently in alpha) to mount each as a
read-only volume in the appropriate subdirectory of a directory included in
`extension_path`. Thereafter, any new containers would simply have to mount
all the same extension image volumes to provide the same extensions to all
containers.

### Postgres.app

To allow extension installation without invalidating the Postgres.app bundle
signature, the default configuration could prepend a well-known directory
outside the app bundle, such as `/Library/Application Support/Postgres`, to
`extension_path`. Users wishing to install new extensions would then need to
point the `EXTDIR` parameter to that location, e.g.,

```console
$ make install EXTDIR="/Library/Application Support/Postgres"`
```

Or the app could get trickier, setting the `--extdir` value to that location
so that users don't need to use `EXTDIR`. As long as `extension_path` includes
both the bundle's own extension directory and this external directory,
Postgres will be able to find and load all extensions.

## Extension Directory Examples

A core extension like [citext] would have a structure similar to:

``` tree
citext
├── citext.control
├── lib
│   ├── citext.dylib
│   └── bitcode
│       ├── citext
│       │   └── citext.bc
│       └── citext.index.bc
└── share
    ├── citext--1.0--1.1.sql
    ├── citext--1.1--1.2.sql
    ├── citext--1.2--1.3.sql
    ├── citext--1.3--1.4.sql
    ├── citext--1.4--1.5.sql
    ├── citext--1.4.sql
    └── citext--1.5--1.6.sql
```

The subdirectory for a pure SQL extension named "pair" in a directory named
“pair” that looks something like this:

``` tree
pair
├── LICENSE.md
├── README.md
├── pair.control
├── doc
│   ├── html
│   │   └── pair.html
│   └── pair.md
└── share
    ├── pair--1.0--1.1.sql
    └── pair--1.1.sql
```

A binary application like [pg_top] would live in the `pg_top` directory,
structured something like:

```
pg_top
├── HISTORY.rst
├── INSTALL.rst
├── LICENSE
├── README.rst
├── bin
│   └── pg_top
└── doc
    └── man
        └── man3
            └── pg_top.3
```

And a C extension like [semver] would live in the semver directory and be
structured something like:

``` tree
semver
├── LICENSE
├── README.md
├── semver.control
├── doc
│   └── semver.md
├── lib
│   ├── semver.dylib
│   └── bitcode
│       ├── semver
│       │   └── semver.bc
│       └── semver.index.bc
└── share
    ├── semver--1.0--1.1.sql
    └── semver--1.1.sql
```

## Phase Two: Preloading

The above-proposed [solution](#solution) does not allow shared modules
distributed with extensions to compatibly be loaded via [shared library
preloading], because extension modules wil no longer live in the
[`dynamic_library_path`]. Users can specify full paths, however. For example,
instead of:

``` ini
shared_preload_libraries = 'pg_partman_bgw'
```

One could use the path to the `lib` subdirectory of the extension's directory:

```ini
shared_preload_libraries = '/opt/postgres/extensions/pg_partman_bgw/lib/pg_partman_bgw'
```

But users will likely find this pattern cumbersome, especially for extensions
with multiple shared modules. Perhaps some special syntax could be added to
specify a single extension module, such as:

```ini
shared_preload_libraries = '$extension_path::pg_partman_bgw'
```

But this overloads the semantics of `shared_preload_libraries` and the code
that processes it rather heavily, not to mention the [`LOAD`] command.

Therefore, as a follow up to the [solution](#solution) proposed above, this
RFC proposes additional changes to PostgreSQL.

### Extension Preloading

Add new GUCs that complement [shared library preloading], but for *extension*
module preloading:

*   `shared_preload_extensions`
*   `session_preload_extensions`
*   `local_preload_extensions`

Each takes a list of extensions for which to preload shared modules. In
addition, another new GUC, `local_extensions`, will contain a list of
administrator-approved extensions users are allowed to include in
`local_preload_extensions`. This GUC complements [`local_preload_libraries`]'s
use of a `plugins` directory.

Then modify the preloading code to also preload these files. For each
extension in a list, it would:

*   Search each path in `extension_path` for the extension.
*   When found, load all the shared libraries from `$extension/lib`.

For example, to load all shared modules in the `pg_partman` extension, set:

```ini
shared_preload_extensions = 'pg_partman'
```

To load a single shared module from an extension, give its name after the
extension name and two colons. This example will load only the
`pg_partman_bgw` shared module from the `pg_partman` extension:

```ini
shared_preload_extensions = 'pg_partman::pg_partman_bgw'
```

This change requires a one-time change to existing preload configurations on
upgrade.

## Future: Deprecate LOAD

For a future change, consider modifying `CREATE EXTENSION` to support shared
module-only extensions. This would allow extensions with no SQL component,
such as `auto_explain`, to be handled like any other extension; it would live
under one of the directories in `extension_path` with a structure like this:

``` tree
auto_explain
├── auto_explain.control
└── lib
   ├── auto_explain.dylib
   └── bitcode
       ├── auto_explain
       │   └── auto_explain.bc
       └── auto_explain.index.bc
```

Note the `auto_explain.control` file. It would need a new parameter to
indicate that the extension includes no SQL files, so `CREATE EXTENSION` and
related commands wouldn't try to find them.

With these changes, extensions could become the primary, recommended interface
for extending PostgreSQL. Perhaps the `LOAD` command could be deprecated, and
the `*_preload_libraries` GUCs along with it.

## Compatibility Issues

*   The `module_pathname` control file variable would prefer the name of a
    shared module. The code that replaces the `MODULE_PATHNAME` string in SQL
    files would to strip out the `$libdir/` prefix, if present.
*   The behavior of loading dynamic modules that ship with extensions (i.e.,
    the value of the `AS` part of `CREATE FUNCTION`) would change to look for
    a library name (with no directory part) in the `lib` subdirectory of the
    extension directory.
*   The `directory` control file parameter and the `MODULEDIR` PGXS variable
    would be deprecated and ignored.
*   `*_preload_libraries` would no longer be used to find extension modules
    without full paths. Administrators would have to remove module names from
    these GUCs and add the relevant extension names to the new
    `*_preload_extensions` variables. To ease upgrades, we might consider
    adding a PGXS variable that, when true, would symlink shared modules into
    `--pkglibdr`.
*   `LOAD` would no longer be able to find shared modules included with
    extensions, unless we add a PGXS variable that, when true, would symlink
    shared modules into `--pkglibdr`.
*   The `EXTENSION` PGXS variable will no longer support multiple extension
    names.
*   The change in extension installation locations must also be adopted by
    projects that don't use PGXS for installation, like [pgrx]. Or perhaps
    they could be modified to also use PGXS. Long term it might be useful to
    replace the `Makefile`-based PGXS with another installation system,
    perhaps a CLI.

## Out of Scope

This RFC does not include or attempt to address the following issue:

*   How to manage third-party shared libraries. Making system dependencies
    consistent in a OCI/Kubernetes environment or for non-system binary
    packaging patterns presents its own challenges, though they're not
    specific to PostgreSQL or the patterns described here. Research is ongoing
    into potential solutions, and will be addressed elsewhere.

  [^modules]: But not non-extension modules; see [Phase
    Two](#phase-two-preloading) and [Future](#future-deprecate-load) for
    further details on preloading extension modules and eventually deprecating
    non-extension modules.

## Acknowledgements

A slew of PostgreSQL community members contributed feedback, asked hard
questions, and suggested moderate to significant revisions to this RFC
via the the pgsql-hackers list, in-person discussion at PGConf.eu, and [pull
request] comments. I'd especially like to thank:

*   [Yurii Rashkovskii] and [David Christensen] for [highlighting] this issue
    at the [Extension Ecosystem Summit]
*   [Christoph Berg] for the original patch, calling attention to the
    permission issues when building Debian packages, and various lists discussions
*   [Tobias Bussmann] for calling attention to the immutability issues with
    [Postgres.app]
*   [Christoph Berg], [Gabriele Bartolini], [Peter Eisentraut], and [Andres
    Freund] for detailed discussion at PGConf.eu on extension location issues
    and getting to consensus on a genera approach to solving it
*   [Douglas J Hunley], [Shaun Thomas], and [Keith Fiske] for [pull request]
    reviews and corrections
*   [Álvaro Hernández Tortosa] for a very close review and ton of substantive
    feedback on the [pull request]
*   [Paul Ramsey], [Tristan Partin], [Ebru Aydin Gol], and [Peter Eisentraut] for
    pgsql-hackers list discussions.
*   [Tembo] for supporting my work on this and many other extension-related
    issues

All remaining errors and omissions remain my own.

  [a pgsql-hackers thread]: https://postgr.es/m/2CAD6FA7-DC25-48FC-80F2-8F203DECAE6A%40justatheory.com
  [GUC]: https://pgpedia.info/g/guc.html "GUC - Grand Unified Configuration"
  [discussion]: https://postgr.es/m/E7C7BFFB-8857-48D4-A71F-88B359FADCFD@justatheory.com
  [Christoph Berg]: https://www.df7cb.de
  [destdir]: https://commitfest.postgresql.org/50/4913/
  [pe patch]: https://postgr.es/m/0d384836-7e6e-4932-af3b-8dad1f6fee43@eisentraut.org
  [OCI]: https://opencontainers.org "Open Container Initiative"
  [symlink magic]: https://speakerdeck.com/ongres/postgres-extensions-in-kubernetes?slide=14
    "Postgres Extensions in Kubernetes: StackGres"
  [Kubernetes image volume feature]: https://kubernetes.io/docs/tasks/configure-pod-container/image-volumes/
    "Kubernetes Docs: Use an Image Volume With a Pod"
  [Postgres.app]: https://postgresapp.com
    "Postgres.app: The easiest way to get started with PostgreSQL on the Mac"
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Docs: Extension Building Infrastructure"
  [`dynamic_library_path`]: https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-DYNAMIC-LIBRARY-PATH
  [pgrx]: https://github.com/pgcentralfoundation/pgrx "pgrx: Build Postgres Extensions with Rust!"
  [citext]: https://www.postgresql.org/docs/17/citext.html
    "PostgreSQL Docs: citext — a case-insensitive character string type"
  [pg_top]: https://pgxn.org/dist/pg_top/ "PGXN: pg_top"
  [semver]: https://pgxn.org/dist/semver/ "PGXN: semver"
  [volumes]: https://docs.docker.com/engine/storage/volumes/
    "Docker Docs: Volumes"
  [shared library preloading]: https://www.postgresql.org/docs/current/runtime-config-client.html#RUNTIME-CONFIG-CLIENT-PRELOAD
    "PostgreSQL Docs: Shared Library Preloading"
  [`local_preload_libraries`]: https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-LOCAL-PRELOAD-LIBRARIES
    "PostgreSQL Docs: local_preload_libraries"
  [`LOAD`]: https://www.postgresql.org/docs/17/sql-load.html
    "PostgreSQL Docs: LOAD"
  [auto_explain]: https://www.postgresql.org/docs/current/auto-explain.html
    "PostgreSQL Docs: auto_explain— log execution plans of slow queries"
  [installation location options]: https://github.com/postgres/postgres/blob/master/src/Makefile.global.in#L82-L90
  [CNPG]: https://cloudnative-pg.io "CloudNativePG — PostgreSQL Operator for Kubernetes"
  [existing behavior]: https://www.postgresql.org/docs/current/xfunc-c.html#XFUNC-C-DYNLOAD
    "PostgreSQL Docs: Dynamic Loading"
  [pull request]: https://github.com/theory/justatheory/pull/7
    "theory/justatheory#7 RFC for Postgres extension directory structure and search path"
  [Gabriele Bartolini]: https://www.gabrielebartolini.it
  [Peter Eisentraut]: https://peter.eisentraut.org
  [Andres Freund]: https://www.linkedin.com/in/andres-freund/
  [Yurii Rashkovskii]: https://ca.linkedin.com/in/yrashk
  [David Christensen]: https://www.crunchydata.com/blog/author/david-christensen
  [highlighting]: {{% ref "/post/postgres/extension-ecosystem-summit-2024" %}}#potential-core-changes-for-extensions-namespaces-etc
    "Potential core changes for extensions, namespaces, etc."
  [Extension Ecosystem Summit]: {{% ref "/post/postgres/extension-ecosystem-summit-2024" %}}    
    "🏔 Extension Ecosystem Summit 2024"
  [Tobias Bussmann]: https://github.com/tbussmann
  [Douglas J Hunley]: https://hunleyd.github.io
  [Shaun Thomas]: http://bonesmoses.org
  [Keith Fiske]: https://www.keithf4.com
  [Álvaro Hernández Tortosa]: https://www.aht.es
  [Paul Ramsey]: http://blog.cleverelephant.ca
  [Tristan Partin]: https://tristan.partin.io
  [Ebru Aydin Gol]: https://www.linkedin.com/in/ebru-aydin-gol-71a7a21a
  [Tembo]: https://tembo.io
