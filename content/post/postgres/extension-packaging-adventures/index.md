---
title: Adventures in Extension Packaging
slug: extension-packaging-adventures
date: 2025-05-22T17:31:09Z
lastMod: 2025-05-22T17:31:09Z
description: |
  Narrative version of a PGConf.dev talk covering the many issues I stumbled
  upon while designing a universal packaging format for PostgreSQL extensions,
  maintaining pgt.dev packages, and experimenting with CloudNativePG
  immutability.
tags: [Postgres, Extensions, Packaging, PGConf.dev, CloudNativePG]
type: post
image:
  src: adventures-extension-packaging.jpeg
  title: Adventures in Extension Packaging
  alt: Cover Side for “Adventures in Extension Packaging” talk at PGConf.dev 2025.
  copyright: 2025 David E. Wheeler
  metaOnly: true
---

I gave a presentation at [PGConf.dev] last week, [Adventures in Extension
Packaging][talk]. It summarizes stuff I learned in the past year in developing
the [PGXN Meta v2 RFC][meta-v2], re-packaging all of the extensions on
[pgt.dev], and experimenting with the [CloudNativePG] community's
[proposal][cnpg-ext] to mount extension OCI images in immutable PostgreSQL
containers.

Turns out a ton of work and experimentation remains to be done.

I'll post the link to the video once it goes up, but in meantime, here are
[the slides]:

<object
  data="{{% link "adventures-extension-packaging.pdf" %}}"
  class="slides-wide"
  type="application/pdf"
  title="Adventures in Extension Packaging">
</object>

Previous work covers the first half of the talk, including:

*   A brief introduction to [PGXN], borrowing from the [State of the
    Extensions Ecosystem]
*   The metadata designed to enable automated packaging of extensions added to
    the [PGXN Meta v2 RFC][meta-v2]
*   The [Trunk Packaging Format], a.k.a., [PGXN RFC 2]
*   [OCI distribution] of Trunk packages

The rest of the talk encompasses newer work. Read on for details.

## Automated Packaging Challenges

Back in December I took over maintenance of the [Trunk registry][pgt.dev],
a.k.a., [pgt.dev], refactoring and upgrading all 200+ extensions and adding
Postgres 17 builds. This experience opened my eyes to the wide variety of
extension build patterns and configurations, even when supporting a single OS
(Ubuntu 22.04 "Jammy"). Some examples:

*   [pglogical requires] an extra `make` param to build on PostgreSQL 17:
    `make -C LDFLAGS_EX="-L/usr/lib/postgresql/17/lib"`
*   Some [pgrx] extensions require additional params, for example:
    *   [pg_search needs] the `--features` flag to enable icu
    *   [vectorscale requires] the environment variable
        `RUSTFLAGS="-C target-feature=+avx2,+fma"`
*   [pljava needs] a pointer to `libjvm`:
    `mvn clean install -Dpljava.libjvmdefault=/usr/lib/x86_64-linux-gnu/libjvm.so`
*   [plrust needs] files to be moved around, a shell script to be run, and to
    be built from a subdirectory
*   [bson also needs] files to be moved around and a pointer to `libbson`
*   [timescale requires] an environment variable and shell script to run
    before building
*   Many extensions require patching to build for various configurations and
    OSes, like [this tweak] to build [pguri] on Postgres 17 and [this patch]
    to get [duckdb_fdw] to build at all

Doubtless there's much more. These sorts of challenges led the RPM and APT
packaging systems to support explicit scripting and patches for every package.
I don't think it would be sensible to support build scripting in the [meta
spec][meta-v2].

However, the [PGXN meta SDK] I developed last year supports the merging of
multiple `META.json` files, so that downstream packagers could maintain files
with additional configurations, including explicit build steps or lists of
packages, to support these use cases.

Furthermore, the plan to add reporting to PGXN v2 means that downstream
packages could report build failures, which would appear on PGXN, where they'd
encourage some maintainers, at least, to fix issues within their control.

## Dependency Resolution

Dependencies present another challenge. The [v2 spec][meta-v2] supports third
party dependencies --- those not part of Postgres itself or the ecosystem of
extensions. Ideally, an extension like [pguri] would define its dependence on
the [uriparser] library like so:

```json
{
  "dependencies": {
    "postgres": { "version": ">= 9.3" },
    "packages": {
      "build": {
        "requires": {
          "pkg:generic/uriparser": 0,
        }
      }
    }
  }
}
```

An intelligent build client will parse the dependencies, provided as [purl]s,
to determine the appropriate OS packages to install to satisfy. For example,
building on a Debian-based system, it would know to install `liburiparser-dev`
to build the extension and require `liburiparser1` to run it.

With the aim to support multiple OSes and versions --- not to mention Postgres
versions --- the proposed PGXN binary registry would experience quite the
combinatorial explosion to support all possible dependencies on all possible
OSes and versions. While I propose to start simple (Linux and macOS, Postgres
14-18) and gradually grow, it could quickly get quite cumbersome.

So much so that I can practically hear [Christoph]'s and [Devrim]'s reactions
from here:

{{% figure
    src       = "laughing-1.jpeg"
    alt       = `Photo of Ronald Reagan and his team laughing uproariously with the white
Impact Bold-style meme text at the top that reads, "AND THEN HE SAID...",
followed by large text at the bottom that reads, "WE'LL PACKAGE EVERY
EXTENSION FOR EVERY PLATFORM!"`
    caption   = `Photo of Christoph, Devrim, and other long-time packagers laughing at me.`
%}}

Or perhaps:

{{% figure
    src       = "laughing-2.jpeg"
    alt       = `Photo of two German shepherds looking at a pink laptop and appearing to laugh
hysterically, with the white Impact Bold-style meme text at the top that
reads, "AND THEN HE SAID...", followed by large text at the bottom that reads,
"UPSTREAM MAINTAINERS WILL FIX BUILD FAILURES!"`
    caption   = `Photo of Christoph and Devrim laughing at me.`
%}}

I hardly blame them.

## A CloudNativePG Side Quest

[Gabriele Bartolini] blogged the [proposal][cnpg-ext] to deploy extensions to
[CloudNativePG] containers without violating the immutability of the
container. The introduction of the [`extension_control_path`] GUC in Postgres
18 and the [ImageVolume] feature in Kubernetes 1.33 enable the pattern, likely
to be introduced in CloudNativePG v1.27. Here's a sample CloudNativePG cluster
manifest with the proposed extension configuration:

```yaml {linenos=table}
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgresql-with-extensions
spec:
  instances: 1
  imageName: ghcr.io/cloudnative-pg/postgresql-trunk:18-devel
  postgresql:
    extensions:
      - name: vector
        image:
          reference: ghcr.io/cloudnative-pg/pgvector-18-testing
  storage:
    storageClass: standard
    size: 1Gi
```

The `extensions` object at lines 9-12 configures [pgvector] simply by
referencing an [OCI] image that contains nothing but the files for the
extension. To "install" the extension, the [proposed patch] triggers a rolling
update, replicas first. For each instance, it takes the following steps:

*   Mounts each extension as a read-only [ImageVolume] under `/extensions`; in
    this example, `/extensions/vector` provides the complete contents of the
    image

*   Updates `LD_LIBRARY_PATH` to include the path to the `lib` directory of
    the each extension, e.g., `/extensions/vector/lib`.

*   Updates the `extension_control_path` and [`dynamic_library_path`] GUCs to
    point to the `share` and `lib` directories of each extension, in this
    example:

    ```ini
    extension_control_path = '$system:/extensions/vector/share'
    dynamic_library_path   = '$libdir:/extensions/vector/lib'
    ```

This works! Alas, the pod restart is absolutely necessary, whether or not any
extension requires it,[^preload], because:

*   Kubernetes resolves volume mounts, including [ImageVolume]s, at pod
    startup
*   The `dynamic_library_path` and `extension_control_path` GUCs require a
    Postgres restart
*   Each extension requires another path to be appended to both of these GUCs,
    as well as the `LD_LIBRARY_PATH`

Say we wanted to use five extensions. The `extensions` part of the manifest
would look something like this:

```yaml
extensions:
  - name: vector
    image:
      reference: ghcr.io/cloudnative-pg/pgvector-18-testing
  - name: semver
    image:
      reference: ghcr.io/example/semver:0.40.0
  - name: auto_explain
    image:
      reference: ghcr.io/example/auto_explain:18
  - name: bloom
    image:
      reference: ghcr.io/example/bloom:18
  - name: postgis
    image:
      reference: ghcr.io/example/postgis:18
```

To support this configuration, CNPG must configure the GUCs like so:

```ini
extension_control_path = '$system:/extensions/vector/share:/extensions/semver/share:/extensions/auto_explain/share:/extensions/bloom/share:/extensions/postgis/share'

dynamic_library_path   = '$libdir:/extensions/vector/lib:/extensions/semver/lib:/extensions/auto_explain/lib:/extensions/bloom/lib:/extensions/postgis/lib'
```

And also `LD_LIBRARY_PATH`:

```sh
LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/extensions/vector/lib:/extensions/semver/lib:/extensions/auto_explain/lib:/extensions/"
```

In other words, every additional extension requires another prefix to be
appended to each of these configurations. Ideally we could use a single prefix
for all extensions, avoiding the need to update these configs and therefore to
restart Postgres. Setting aside the [ImageVolume] limitation[^iv] for the
moment, this pattern would require no rolling restarts and no GUC updates
unless a newly-added extension requires pre-loading via
[`shared_preload_libraries`].

Getting there, however, requires a different extension file layout than
PostgreSQL currently uses.

## RFC: Extension Packaging and Lookup

Imagine this:

*   A single extension search path GUC
*   Each extension in its own eponymous directory
*   Pre-defined subdirectory names used inside each extension directory

The search path might look something like:

```ini
extension_search_path = '$system:/extensions:/usr/local/extensions'
```

Looking at one of these directories, `/extensions`, its contents would be
extension directories:

``` console
❯ ls -1 extensions
auto_explain
bloom
postgis
semver
vector
```

And the contents of one these extension directories would be something like:

```console
❯ tree extensions/semver
extensions/semver
├── doc
│   └── semver.md
├── lib
│   └── semver.so
├── semver.control
└── sql
    ├── semver--0.31.0--0.31.1.sql
    ├── semver--0.31.1--0.31.2.sql
    ├── semver--0.31.2--0.32.0.sql
    └── semver--0.5.0--0.10.0.sql
```

For this pattern, Postgres would look for the appropriately-named
directory with a control file in each of the paths. To find the `semver`
extension, for example, it would find `/extensions/semver/semver.control`.

All the other files for the extension would live in specifically-named
subdirectories: `doc` for documentation files, `lib` for shared libraries,
`sql` for SQL deployment files, plus `bin`, `man`, `html`, `include`,
`locale`, and any other likely resources.

With all of the files required for an extension bundled into well-defined
subdirectories of a single directory, it lends itself to the layout of the
proposed [binary distribution format][PGXN RFC 2]. Couple it with [OCI
distribution] and it becomes a natural fit for [ImageVolume] deployment:
simply map each extension OCI image to a subdirectory of the desired search
path and you're done. The `extensions` object in the CNPG Cluster manifest
remains unchanged, and CNPG no longer needs to manipulate any GUCs.

Some might recognize this proposal from a [previous RFC post]. It not only
simplifies the CloudNativePG use cases, but because it houses all of the files
for an extension in a single bundle, it also vastly simplifies installation
on any system:

1.  Download the extension package
2.  Validate its signature & contents
3.  Unpack its contents into a directory named for the extension in the
    extension search path

Simple!

## Fun With Dependencies

Many extensions depend on external libraries, and rely on the OS to find them.
OS packagers follow the dependency patterns of their packaging systems:
require the installation of other packages to satisfy the dependencies.

How could a pattern be generalized by the [Trunk Packaging Format] to work on
all OSes? I see two potential approaches:

1.  List the dependencies as [purl]s that the installing client translates to
    the appropriate OS packages it installs.
2.  Bundle dependencies in the Trunk package itself

Option 1 will work well for most use cases, but not immutable systems like
[CloudNativePG]. Option 2 could work for such situations. But perhaps you
noticed the omission of `LD_LIBRARY_PATH` manipulation in the packaging and
lookup discussion above. Setting aside the multitude of reasons to avoid
`LD_LIBRARY_PATH`[^ld], how else could the OS find shared libraries needed by
an extension?

Typically, one installs shared libraries in one of a few directories known to
tools like [ldconfig], which must run after each install to cache their
locations. But one cannot rely on `ldconfig` in immutable environments,
because the cache of course cannot be mutated.

We could, potentially, rely on [rpath], a feature of modern dynamic linkers
that reads a list of known paths from the header of a binary file. In fact,
most modern OSes [support] `$ORIGIN` as an `rpath` value[^windows] (or
`@loader_path` on Darwin/macOS), which refers to the same directory in which
the binary file appears. Imagine this pattern:

*   The Trunk package for an extension includes dependency libraries alongside
    the extension module
*   The module is compiled with `rpath=$ORIGIN`

To test this pattern, let's install the Postgres 18 beta and try the pattern
with the [pguri] extension. First, remove the `$libdir/` prefix (as [discussed
previously]) and patch the extension for Postgres 17+:

```sh
perl -i -pe 's{\$libdir/}{}' pguri/uri.control pguri/*.sql
perl -i -pe 's/^(PG_CPPFLAGS.+)/$1 -Wno-int-conversion/' pguri/Makefile
```

Then compile it with `CFLAGS` to set `rpath` and install it with a `prefix`
parameter:

``` sh
make CFLAGS='-Wl,-rpath,\$$ORIGIN'
make install prefix=/usr/local/postgresql
```

With the module installed, move the `liburiparser` shared library from OS
packaging to the `lib` directory under the prefix, resulting in these
contents:

```console
❯ ls -1 /usr/local/postgresql/lib
liburiparser.so.1
liburiparser.so.1.0.30
uri.so
```

The [chrpath] utility shows that the extension module, `uri.so`, has its
`RUNPATH` (the modern implementation of `rparth`) properly configured:

```console
❯ chrpath /usr/local/postgresql/lib/uri.so 
uri.so: RUNPATH=$ORIGIN
```

Will the OS be able to find the dependency? Use [ldd] to find out:

```console
❯ ldd /usr/local/postgresql/lib/uri.so 
	linux-vdso.so.1
	liburiparser.so.1 => /usr/local/postgresql/lib/liburiparser.so.1
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6
	/lib/ld-linux-aarch64.so.1
```

The second line of output shows that it does in fact find `liburiparser.so.1`
where we put it. So far so good. Just need to tell the GUCs where to find them
and restart Postgres:

```ini
extension_control_path = '$system:/usr/local/postgresql/share'
dynamic_library_path   = '$libdir:/usr/local/postgresql/lib'
```

And then it works!

```console
❯ psql -c "CREATE EXTENSION uri"
CREATE EXTENSION
❯ psql -c "SELECT 'https://example.com/'::uri"
         uri          
----------------------
 https://example.com/
```

Success! So we can adopt this pattern, yes?

### A Wrinkle
 
Well, maybe. Try it with a second extension, [http], once again building it
with `rpath=$ORIGIN` and installing it in the custom lib directory:

```sh
perl -i -pe 's{$libdir/}{}g' *.control
make CFLAGS='-Wl,-rpath,\$$ORIGIN'
make install prefix=/usr/local/postgresql
```

Make sure it took:

```console
❯ chrpath /usr/local/postgresql/lib/http.so 
http.so: RUNPATH=$ORIGIN
```

Now use [ldd] to see what shared libraries it needs:

```console
❯ ldd /usr/local/postgresql/lib/http.so
	linux-vdso.so.1 
	libcurl.so.4 => not found
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6
```

Naturally it needs `libcurl`; let's copy it from another system and try again:

```console {linenos=table,hl_lines=[4,7]}
❯ scp dev:libcurl.so.4 /usr/local/postgresql/lib/
❯ ldd /usr/local/postgresql/lib/http.so
	linux-vdso.so.1
	libcurl.so.4 => /usr/local/postgresql/lib/libcurl.so.4
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6
	/lib/ld-linux-aarch64.so.1
	libnghttp2.so.14 => not found
	libidn2.so.0 => /lib/aarch64-linux-gnu/libidn2.so.0
	librtmp.so.1 => not found
	libssh.so.4 => not found
	libpsl.so.5 => not found
	libssl.so.3 => /lib/aarch64-linux-gnu/libssl.so.3
	libcrypto.so.3 => /lib/aarch64-linux-gnu/libcrypto.so.3
	libgssapi_krb5.so.2 => /lib/aarch64-linux-gnu/libgssapi_krb5.so.2
	libldap.so.2 => not found
	liblber.so.2 => not found
	libzstd.so.1 => /lib/aarch64-linux-gnu/libzstd.so.1
	libbrotlidec.so.1 => not found
	libz.so.1 => /lib/aarch64-linux-gnu/libz.so.1
```

Line 4 shows it found `libcurl.so.4` where we put it, but the rest of the
output lists a bunch of new dependencies that need to be satisfied. These did
not appear before because the `http.so` module doesn't depend on them; the
`libcurl.so` library does. Let's add `libnghttp2` and try again:

```console {linenos=table,hl_lines=[7]}
❯ scp dev:libnghttp2.so.14 /usr/local/postgresql/lib/
❯ ldd /usr/local/postgresql/lib/http.so
	linux-vdso.so.1
	libcurl.so.4 => /usr/local/postgresql/lib/libcurl.so.4
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6
	/lib/ld-linux-aarch64.so.1
	libnghttp2.so.14 => not found
	libidn2.so.0 => /lib/aarch64-linux-gnu/libidn2.so.0
	librtmp.so.1 => not found
	libssh.so.4 => not found
	libpsl.so.5 => not found
	libssl.so.3 => /lib/aarch64-linux-gnu/libssl.so.3
	libcrypto.so.3 => /lib/aarch64-linux-gnu/libcrypto.so.3
	libgssapi_krb5.so.2 => /lib/aarch64-linux-gnu/libgssapi_krb5.so.2
	libldap.so.2 => not found
	liblber.so.2 => not found
	libzstd.so.1 => /lib/aarch64-linux-gnu/libzstd.so.1
	libbrotlidec.so.1 => not found
	libz.so.1 => /lib/aarch64-linux-gnu/libz.so.1
```

Sadly, as line 7 shows, it still can't find `libnghttp2.so`.

It turns out that [rpath] works only for immediate dependencies. To solve this
problem, `liburl` and all other shared libraries must also be compiled with
`rpath=$ORIGIN` --- which means we can't simply copy those libraries from OS
packages[^pkg-rpath]. In th meantime, only deirect dependencies could be
bundled with an extension.

## Project Status

The vision of accessible, easy-install extensions everywhere remains intact.
I'm close to completing a first release of the PGXN v2 [build SDK] with
support for meta spec v1 and v2, [PGXS], and [pgrx] extensions. I expect the
first deliverable to be a command-line client to complement and eventuallly
replace the [original CLI]. It will be put to work building all the extensions
currently distributed on [PGXN], which will surface new issues and patterns
that inform the development and completion of the [v2 meta spec][PGXN RFC 2].

In the future, I'd also like to:

*   Finish working out Trunk format and dependency patterns
*   Develop and submit the prroposed `extension_search_path` patch
*   Submit [ImageVolume] feedback to Kubernetes to allow runtime mounting
*   Start building and distributing OCI Trunk packages
*   Make the pattern available for distributed registries, so anyone can build
    their own Trunk releases!
*   Hack fully-dynamic extension loading into [CloudNativePG]

## Let's Talk

I recognize the ambition here, but feel equal to it. Perhaps not every bit
will work out, but I firmly believe in setting a clear vision and executing
toward it while pragmatically revisiting and revising it as experience
warrants.

If you'd like to contribute to the project or employ me to continue working on
it, let's talk! Hit me up via one of the services listed on the [about page].

  [^preload]: The feature does not yet support pre-loading shared libraries.
    Presumably a flag will be introduced to add the extension to
    [`shared_preload_libraries`].

  [^iv]: Though we should certainly [request] the ability to add new
    `ImageVolume` mounts without a restart. We can't be the only ones thinking
    about kind of feature, right?

  [^ld]: In general, one should avoid `LD_LIBRARY_PATH` for variety of
    reasons, not least of which its [bluntness]. For various security reasons,
    macOS ignores it unless [sip] is disabled, and SELinux [prevents its
    propagation] to new processes.

  [^windows]: Although not Windows, alas.

  [^pkg-rpath]: Unless packagers could be pursuaded to build all libraries
    with `rpath=$ORIGIN`, which seems like a tall order.

  [talk]: https://www.pgevents.ca/events/pgconfdev2025/schedule/session/331-adventures-in-extension-packaging/
  [PGConf.dev]: https://2025.pgconf.dev "PostgreSQL Development Conference 2025"
  [PGXN]: http://pgxn.org/ "PostgreSQL Extension Network"
  [meta-v2]: https://github.com/pgxn/rfcs/pull/3 "RFC: Meta Spec v2"
  [pgt.dev]: https://pgt.dev "Trunk: A Postgres Extension Registry"
  [CloudNativePG]: https://cloudnative-pg.io "Run PostgreSQL. The Kubernetes way."
  [cnpg-ext]: https://www.gabrielebartolini.it/articles/2025/03/the-immutable-future-of-postgresql-extensions-in-kubernetes-with-cloudnativepg/
    "The Immutable Future of PostgreSQL Extensions in Kubernetes with CloudNativePG"
  [the slides]: {{% link "adventures-extension-packaging.pdf" %}}
  [State of the Extensions Ecosystem]: {{% ref "/post/postgres/2025-mini-summit-one" %}}#state-of-the-extensions-ecosystem
  [Trunk Packaging Format]: {{% ref "/post/postgres/trunk-poc" %}}
    "POC: PGXN Binary Distribution Format"
  [PGXN RFC 2]: https://github.com/pgxn/rfcs/pull/2
  [OCI distribution]: {{% ref "/post/postgres/trunk-oci-poc" %}}
    "POC: Distributing Trunk Binaries via OCI"
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
  [pglogical requires]: https://github.com/tembo-io/trunk/blob/5f3de6d/contrib/pg_search/Dockerfile#L18
  [pljava needs]: https://github.com/tembo-io/trunk/blob/5f3de6d/contrib/pljava/Dockerfile#L18
  [pg_search needs]: https://github.com/tembo-io/trunk/blob/5f3de6d/contrib/pg_search/Dockerfile#L18
  [vectorscale requires]: https://github.com/tembo-io/trunk/blob/5f3de6d/contrib/vectorscale/Dockerfile#L25
  [plrust needs]: https://github.com/tembo-io/trunk/blob/5f3de6d/contrib/plrust/Dockerfile#L41-L46
  [bson also needs]: https://github.com/tembo-io/trunk/blob/39b385d/contrib/postgresbson/Dockerfile#L15-L18
  [timescale requires]: https://github.com/tembo-io/trunk/blob/39b385d/contrib/timescaledb/Dockerfile#L14
  [this tweak]: https://github.com/tembo-io/trunk/blob/39b385d/contrib/pguri/Dockerfile#L15
  [this patch]: https://github.com/tembo-io/trunk/blob/39b385d/contrib/duckdb_fdw/Dockerfile#L18
  [pgxn Meta SDK]: https://github.com/pgxn/meta
  [pguri]: https://github.com/petere/pguri
  [uriparser]: https://uriparser.github.io
  [duckdb_fdw]: https://github.com/alitrack/duckdb_fdw/
  [Christoph]: https://www.df7cb.de "Christoph Berg"
  [Devrim]: https://people.planetpostgresql.org/devrim/ "Devrim Gündüz"
  [Gabriele Bartolini]: https://www.gabrielebartolini.it
  [`extension_control_path`]: https://github.com/postgres/postgres/commit/4f7f7b0
  [ImageVolume]: https://kubernetes.io/docs/concepts/storage/volumes/#image
  [pgvector]: https://pgxn.org/dist/vector/
  [proposed patch]: https://github.com/cloudnative-pg/cloudnative-pg/pull/6546
    "cloudnative-pg/cloudnative-pg#6546: feat: add support for configuring PostgreSQL extensions via Image Volume"
  [OCI]: https://opencontainers.org "Open Container Initiative"
  [`dynamic_library_path`]: https://www.postgresql.org/docs/crrent/runtime-config-client.html#GUC-DYNAMIC-LIBRARY-PATH
  [`shared_preload_libraries`]: https://www.postgresql.org/docs/17/runtime-config-client.html#GUC-SHARED-PRELOAD-LIBRARIES
  [bluntness]: https://blogs.oracle.com/solaris/post/ld_library_path-just-say-no
    "Oracle Solaris Blog: LD_LIBRARY_PATH - just say no"
  [sip]: https://support.apple.com/guide/security/system-integrity-protection-secb7ea06b49/web
    "Apple Platform Security: System Integrity Protection"
  [prevents its propagation]: https://selinux.tycho.nsa.narkive.com/yQnAv3QF/policy-regarding-ld-library-path#
    "SELinux policy regarding LD_LIBRARY_PATH"
  [request]: https://github.com/kubernetes/enhancements/issues/4639#issuecomment-2898844498
  [previous RFC post]: {{% ref "/post/postgres/rfc-extension-packaging-lookup" %}}
    "RFC: Extension Packaging & Lookup"
  [purl]: https://github.com/package-url/purl-spec
    "purl-spec: A minimal specification for purl a.k.a. a package “mostly universal” URL"
  [ldconfig]: https://www.man7.org/linux/man-pages/man8/ldconfig.8.html
  [rpath]: https://en.wikipedia.org/wiki/Rpath "Wikipedia: rpath"
  [discussed previously]: {{% ref "/post/postgres/update-control" %}}
    "Update Your Control Files"
  [support]: https://lekensteyn.nl/rpath.html "RPATH support"
  [chrpath]: https://linux.die.net/man/1/chrpath
  [ldd]: https://linux.die.net/man/1/ldd
  [http]: https://github.com/pramsey/pgsql-http 
    "HTTP client for PostgreSQL, retrieve a web page from inside the database."
  [build SDK]: https://github.com/pgxn/build/
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Docs: Extension Building Infrastructure"
  [original CLI]: https://pgxn.github.io/pgxnclient/
  [about page]: {{% ref "/about" %}} "About Just a Theory"
