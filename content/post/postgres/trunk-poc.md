---
title: "POC: PGXN Binary Distribution Format"
slug: trunk-poc
date: 2024-06-20T19:28:08Z
lastMod: 2024-06-20T19:28:08Z
description: |
  A proof of concept for "trunk", the proposed binary distribution format for
  Postgres extensions.
tags: [Postgres, PGXN, Trunk, POC, RFC, PGXS]
type: post
---

In an effort to make discussion of PGXN and related improvements as accessible
as possible, I've set up [PGXN Discussions] on GitHub. Of course GitHub
created default categories for all sorts of conversation, and all is welcome,
in accordance with the [PostgresSQL Code of Conduct].

But I hope more people will be able to find, read, comment on, and even write
their own RFCs than was possible on the [Postgres Wiki] or [on Just a Theory].
Therefore, please have a look at [Proposal-2: Binary Distribution
Format][rfc-2], which draws inspiration from the [Python wheel format] and
[Trunk] to define a packaging format that allows for platform and PostgreSQL
version matching to quickly install pre-compiled binary PostgreSQL extension
packages.

[The proposal][rfc-2] has the details, but the basic idea is that files to be
installed are stored in directories named for [pg_config] directory
configurations. Then all an installer has to do is install the files in those
subdirectories into the [pg_config]-specified directories.

## POC

I [ran this idea past some colleagues][summit-session], and they thought it
worth exploring. But the [proposal][rfc-2] itself didn't feel sufficient. I
wanted to prove that it could work.

So I created a proof-of-concept (POC) implementation in just about the
quickest way I could think of and applied it to the [semver extension] in
[PR 68]. Here's how it works.

### `trunk.mk`

A new file, [`trunk.mk`], dupes all of the install targets from [PGXS] and
rejiggers them to install into the proposed package directory format. The
[`Makefile`] simply imports `trunk.mk`:

``` diff
--- a/Makefile
+++ b/Makefile
@@ -22,6 +22,7 @@ endif
 
 PGXS := $(shell $(PG_CONFIG) --pgxs)
 include $(PGXS)
+include ./trunk.mk
 
 all: sql/$(EXTENSION)--$(EXTVERSION).sql
 
```

And now there's a `trunk` target that uses those packaging targets. Here's its
output on my amd64 Mac (after running `make`):

``` console
$ make trunk
gmkdir -p 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/extension'
gmkdir -p 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver'
gmkdir -p 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib'
gmkdir -p 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/doc/semver'
ginstall -c -m 644 .//semver.control 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/extension/'
ginstall -c -m 644 .//sql/semver--0.10.0--0.11.0.sql .//sql/semver--0.11.0--0.12.0.sql .//sql/semver--0.12.0--0.13.0.sql .//sql/semver--0.13.0--0.15.0.sql .//sql/semver--0.15.0--0.16.0.sql .//sql/semver--0.16.0--0.17.0.sql .//sql/semver--0.17.0--0.20.0.sql .//sql/semver--0.2.1--0.2.4.sql .//sql/semver--0.2.4--0.3.0.sql .//sql/semver--0.20.0--0.21.0.sql .//sql/semver--0.21.0--0.22.0.sql .//sql/semver--0.22.0--0.30.0.sql .//sql/semver--0.3.0--0.4.0.sql .//sql/semver--0.30.0--0.31.0.sql .//sql/semver--0.31.0--0.31.1.sql .//sql/semver--0.31.1--0.31.2.sql .//sql/semver--0.31.2--0.32.0.sql .//sql/semver--0.32.1.sql .//sql/semver--0.5.0--0.10.0.sql .//sql/semver--unpackaged--0.2.1.sql  'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/'
ginstall -c -m 755  src/semver.dylib 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/'
gmkdir -p '/Users/david/.pgenv/pgsql-16.3/lib/bitcode/src/semver'
gmkdir -p 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode'/src/semver/src/
ginstall -c -m 644 src/semver.bc 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode'/src/semver/src/
cd 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode' && /opt/homebrew/Cellar/llvm/18.1.6/bin/llvm-lto -thinlto -thinlto-action=thinlink -o src/semver.index.bc src/semver/src/semver.bc
ginstall -c -m 644 .//doc/semver.mmd 'semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/doc/semver/'
ginstall -c -m 644 .//README.md .//LICENSE .//Changes 'semver-0.32.1+pg16-darwin-23.5.0-arm64/'
rm -f "semver-0.32.1+pg16-darwin-23.5.0-arm64/digests"
cd "semver-0.32.1+pg16-darwin-23.5.0-arm64/" && find * -type f | xargs shasum --tag -ba 256 > digests
tar zcvf semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk semver-0.32.1+pg16-darwin-23.5.0-arm64
a semver-0.32.1+pg16-darwin-23.5.0-arm64
a semver-0.32.1+pg16-darwin-23.5.0-arm64/LICENSE
a semver-0.32.1+pg16-darwin-23.5.0-arm64/Changes
a semver-0.32.1+pg16-darwin-23.5.0-arm64/trunk.json
a semver-0.32.1+pg16-darwin-23.5.0-arm64/README.md
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/digests
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/doc
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/extension
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.3.0--0.4.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.30.0--0.31.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.21.0--0.22.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.32.1.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.10.0--0.11.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.13.0--0.15.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.31.1--0.31.2.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.31.2--0.32.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--unpackaged--0.2.1.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.12.0--0.13.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.17.0--0.20.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.2.1--0.2.4.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.16.0--0.17.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.22.0--0.30.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.20.0--0.21.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.15.0--0.16.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.2.4--0.3.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.31.0--0.31.1.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.11.0--0.12.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/semver/semver--0.5.0--0.10.0.sql
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/share/extension/semver.control
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/doc/semver
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/doc/semver/semver.mmd
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/semver.dylib
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode/src
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode/src/semver
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode/src/semver.index.bc
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode/src/semver/src
a semver-0.32.1+pg16-darwin-23.5.0-arm64/pgsql/pkglib/bitcode/src/semver/src/semver.bc
```

The `trunk` target compresses everything into the resulting trunk file:

``` console
$ ls -1 *.trunk
semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk
```

This should work the same everywhere `PGXS` works. Here's the output in an
amd64 Linux container[^tools-setup] mounted to the same directory:

``` console
# make trunk
mkdir -p 'semver-0.32.1+pg16-linux-amd64/pgsql/share/extension'
mkdir -p 'semver-0.32.1+pg16-linux-amd64/pgsql/share/semver'
mkdir -p 'semver-0.32.1+pg16-linux-amd64/pgsql/pkglib'
mkdir -p 'semver-0.32.1+pg16-linux-amd64/pgsql/doc/semver'
install -c -m 644 .//semver.control 'semver-0.32.1+pg16-linux-amd64/pgsql/share/extension/'
install -c -m 644 .//sql/semver--0.10.0--0.11.0.sql .//sql/semver--0.11.0--0.12.0.sql .//sql/semver--0.12.0--0.13.0.sql .//sql/semver--0.13.0--0.15.0.sql .//sql/semver--0.15.0--0.16.0.sql .//sql/semver--0.16.0--0.17.0.sql .//sql/semver--0.17.0--0.20.0.sql .//sql/semver--0.2.1--0.2.4.sql .//sql/semver--0.2.4--0.3.0.sql .//sql/semver--0.20.0--0.21.0.sql .//sql/semver--0.21.0--0.22.0.sql .//sql/semver--0.22.0--0.30.0.sql .//sql/semver--0.3.0--0.4.0.sql .//sql/semver--0.30.0--0.31.0.sql .//sql/semver--0.31.0--0.31.1.sql .//sql/semver--0.31.1--0.31.2.sql .//sql/semver--0.31.2--0.32.0.sql .//sql/semver--0.32.1.sql .//sql/semver--0.5.0--0.10.0.sql .//sql/semver--unpackaged--0.2.1.sql  'semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/'
install -c -m 755  src/semver.so 'semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/'
mkdir -p '/usr/lib/postgresql/16/lib/bitcode/src/semver'
mkdir -p 'semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode'/src/semver/src/
install -c -m 644 src/semver.bc 'semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode'/src/semver/src/
cd 'semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode' && /usr/lib/llvm-16/bin/llvm-lto -thinlto -thinlto-action=thinlink -o src/semver.index.bc src/semver/src/semver.bc
install -c -m 644 .//doc/semver.mmd 'semver-0.32.1+pg16-linux-amd64/pgsql/doc/semver/'
install -c -m 644 .//README.md .//LICENSE .//Changes 'semver-0.32.1+pg16-linux-amd64/'
rm -f "semver-0.32.1+pg16-linux-amd64/digests"
cd "semver-0.32.1+pg16-linux-amd64/" && find * -type f | xargs shasum --tag -ba 256 > digests
tar zcvf semver-0.32.1+pg16-linux-amd64.trunk semver-0.32.1+pg16-linux-amd64
semver-0.32.1+pg16-linux-amd64/
semver-0.32.1+pg16-linux-amd64/LICENSE
semver-0.32.1+pg16-linux-amd64/Changes
semver-0.32.1+pg16-linux-amd64/trunk.json
semver-0.32.1+pg16-linux-amd64/README.md
semver-0.32.1+pg16-linux-amd64/pgsql/
semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/
semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode/
semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode/src/
semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode/src/semver/
semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode/src/semver/src/
semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode/src/semver/src/semver.bc
semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/bitcode/src/semver.index.bc
semver-0.32.1+pg16-linux-amd64/pgsql/pkglib/semver.so
semver-0.32.1+pg16-linux-amd64/pgsql/doc/
semver-0.32.1+pg16-linux-amd64/pgsql/doc/semver/
semver-0.32.1+pg16-linux-amd64/pgsql/doc/semver/semver.mmd
semver-0.32.1+pg16-linux-amd64/pgsql/share/
semver-0.32.1+pg16-linux-amd64/pgsql/share/extension/
semver-0.32.1+pg16-linux-amd64/pgsql/share/extension/semver.control
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.3.0--0.4.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.30.0--0.31.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.21.0--0.22.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.32.1.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.10.0--0.11.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.13.0--0.15.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.31.1--0.31.2.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.31.2--0.32.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--unpackaged--0.2.1.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.12.0--0.13.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.17.0--0.20.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.2.1--0.2.4.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.16.0--0.17.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.22.0--0.30.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.20.0--0.21.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.15.0--0.16.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.2.4--0.3.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.31.0--0.31.1.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.11.0--0.12.0.sql
semver-0.32.1+pg16-linux-amd64/pgsql/share/semver/semver--0.5.0--0.10.0.sql
semver-0.32.1+pg16-linux-amd64/digests
```

Pretty much the same, as expected. Now we have two trunks:

``` console
$ ls -1 *.trunk
semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk
semver-0.32.1+pg16-linux-amd64.trunk
```

The package name format is:

```
{package}-{version}+{pgversion}-{os}-{os_version}-{architecture}.trunk
```

Here you see the same package, version, and Postgres version, but then the
OSes differ, macOS includes the optional OS version, and then the
architectures differ. This will allow an install client to download the
appropriate trunk.

Note the directories into which files are copied under a top-level directory
with that format (without the `.trunk` extension):

*   SHAREDIR files go into `pgsql/share`
*   DOCDIR files go into `pgsql/doc`
*   PKGLIB files go into `pgsql/pkglib`

What else is there?

``` console
$ ls -lah semver-0.32.1+pg16-linux-amd64
total 64
-rw-r--r--@ 1 david  staff    12K Jun 20 13:56 Changes
-rw-r--r--@ 1 david  staff   1.2K Jun 20 13:56 LICENSE
-rw-r--r--@ 1 david  staff   3.5K Jun 20 13:56 README.md
-rw-r--r--  1 david  staff   3.2K Jun 20 13:56 digests
drwxr-xr-x  5 david  staff   160B Jun 20 13:56 pgsql
-rw-r--r--  1 david  staff   1.1K Jun 20 13:56 trunk.json
```

`Changes`, `LICENSE`, `README.md` are simply copied from the source. The
`digests` file contains checksums in the [BSD digest format] for every file in
the package, aside from `digests` itself. Here are the first 3:

``` console
$ head -3 semver-0.32.1+pg16-linux-amd64/digests
SHA256 (Changes) = 98b5e87b8dc71604df4b743b1d80ef2fe40d96809a5fbad2a89ab97584bd9c01
SHA256 (LICENSE) = ff48c81463d79e2a57da57ca1af983c3067e51a8ff84c60296c6fbf0624a0531
SHA256 (README.md) = 99f7c59f796986777f873e78f47f7d44f5ce2deee645b4be3199f0a08dedc22d
```

This format makes it easy to validate all the files and well as adjust and
update the hash algorithm over time.

Finally, the `trunk.json` file contains metadata about the extension and the
system and Postgres on which the system was built:

``` json
{
  "trunk": "0.1.0",
  "package": {
    "name": "semver",
    "version": "0.32.1",
    "language": "c",
    "license": "PostgreSQL"
  },
  "postgres": {
    "version": "16.3",
    "major": "16",
    "number": 160003,
    "libs": "-lpgcommon -lpgport -lselinux -lzstd -llz4 -lxslt -lxml2 -lpam -lssl -lcrypto -lgssapi_krb5 -lz -lreadline -lm ",
    "cppflags": "-I. -I./ -I/usr/include/postgresql/16/server -I/usr/include/postgresql/internal  -Wdate-time -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -I/usr/include/libxml2 ",
    "cflags": "-Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wimplicit-fallthrough=3 -Wcast-function-type -Wshadow=compatible-local -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -fvisibility=hidden",
    "ldflags": "-L/usr/lib/x86_64-linux-gnu -Wl,-z,relro -Wl,-z,now -L/usr/lib/llvm-16/lib  -Wl,--as-needed"
  },
  "platform": {
    "os": "linux",
    "arch": "amd64"
  }
}
```

The [trunk proposal][rfc-2] doesn't specify the contents (yet), but the idea
is to include information for an installing application to verify that a
package is appropriate to install on a platform and Postgres version.

### `install_trunk`

Now we have some packages in the proposed format. How do we install them?
[`install_trunk`] script is a POC installer. Let's take it for a spin on
macOS:

``` console {linenos=table}
$ ./install_trunk semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk 
Unpacking semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk
Verifying all checksums...Changes: OK
LICENSE: OK
README.md: OK
pgsql/pkglib/bitcode/src/semver/src/semver.bc: OK
pgsql/pkglib/bitcode/src/semver.index.bc: OK
pgsql/pkglib/semver.dylib: OK
pgsql/doc/semver/semver.mmd: OK
pgsql/share/extension/semver.control: OK
pgsql/share/semver/semver--0.3.0--0.4.0.sql: OK
pgsql/share/semver/semver--0.30.0--0.31.0.sql: OK
pgsql/share/semver/semver--0.21.0--0.22.0.sql: OK
pgsql/share/semver/semver--0.32.1.sql: OK
pgsql/share/semver/semver--0.10.0--0.11.0.sql: OK
pgsql/share/semver/semver--0.13.0--0.15.0.sql: OK
pgsql/share/semver/semver--0.31.1--0.31.2.sql: OK
pgsql/share/semver/semver--0.31.2--0.32.0.sql: OK
pgsql/share/semver/semver--unpackaged--0.2.1.sql: OK
pgsql/share/semver/semver--0.12.0--0.13.0.sql: OK
pgsql/share/semver/semver--0.17.0--0.20.0.sql: OK
pgsql/share/semver/semver--0.2.1--0.2.4.sql: OK
pgsql/share/semver/semver--0.16.0--0.17.0.sql: OK
pgsql/share/semver/semver--0.22.0--0.30.0.sql: OK
pgsql/share/semver/semver--0.20.0--0.21.0.sql: OK
pgsql/share/semver/semver--0.15.0--0.16.0.sql: OK
pgsql/share/semver/semver--0.2.4--0.3.0.sql: OK
pgsql/share/semver/semver--0.31.0--0.31.1.sql: OK
pgsql/share/semver/semver--0.11.0--0.12.0.sql: OK
pgsql/share/semver/semver--0.5.0--0.10.0.sql: OK
trunk.json: OK
Done!
Verifying compatibility with Trunk package 0.1.0
Verifying compatibility with PostgreSQL 16.3
Verifying compatibility with darwin/arm64:23.5.0 
Installing doc into /Users/david/.pgenv/pgsql-16.3/share/doc...Done
Installing pkglib into /Users/david/.pgenv/pgsql-16.3/lib...Done
Installing share into /Users/david/.pgenv/pgsql-16.3/share...Done
```

Most of the output here is verification:

*   Lines 3-32 verify each the checksums of each file in the package
*   Line 33 verifies the version of the Trunk format
*   Line 34 verifies Postgres version compatibility
*   Line 35 verifies platform compatibility

And now, with all the verification complete, it installs the files. It does so
by iterating over the subdirectories of the `pgsql` directory and installing
them into the appropriate directory defined by `pg_config`. Two whit:

*   Line 36 installs files from `pgsql/doc` into `pg_config --docdir`
*   Line 37 installs files from `pgsql/pkglib` into `pg_config --pkglibdir`
*   Line 38 installs files from `pgsql/share` into `pg_config --sharedir`

And that's it. Here's where it put everything:

``` console
❯ (cd ~/.pgenv/pgsql-16.3 && find . -name '*semver*')
./lib/bitcode/src/semver
./lib/bitcode/src/semver/src/semver.bc
./lib/bitcode/src/semver.index.bc
./lib/semver.dylib
./share/extension/semver.control
./share/semver
./share/semver/semver--0.3.0--0.4.0.sql
./share/semver/semver--0.30.0--0.31.0.sql
./share/semver/semver--0.21.0--0.22.0.sql
./share/semver/semver--0.32.1.sql
./share/semver/semver--0.10.0--0.11.0.sql
./share/semver/semver--0.13.0--0.15.0.sql
./share/semver/semver--0.31.1--0.31.2.sql
./share/semver/semver--0.31.2--0.32.0.sql
./share/semver/semver--unpackaged--0.2.1.sql
./share/semver/semver--0.12.0--0.13.0.sql
./share/semver/semver--0.17.0--0.20.0.sql
./share/semver/semver--0.2.1--0.2.4.sql
./share/semver/semver--0.16.0--0.17.0.sql
./share/semver/semver--0.22.0--0.30.0.sql
./share/semver/semver--0.20.0--0.21.0.sql
./share/semver/semver--0.15.0--0.16.0.sql
./share/semver/semver--0.2.4--0.3.0.sql
./share/semver/semver--0.31.0--0.31.1.sql
./share/semver/semver--0.11.0--0.12.0.sql
./share/semver/semver--0.5.0--0.10.0.sql
./share/doc/semver
./share/doc/semver/semver.mmd
```

Looks like everything's installed in the right place. Does it work?

``` console
# psql -c "CREATE EXTENSION semver; SELECT '1.2.3'::semver"
CREATE EXTENSION
 semver 
--------
 1.2.3
(1 row)
```

Very nice. What about on Linux?

``` console
./install_trunk semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk 
Unpacking semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk
Verifying all checksums...Changes: OK
LICENSE: OK
README.md: OK
pgsql/pkglib/bitcode/src/semver/src/semver.bc: OK
pgsql/pkglib/bitcode/src/semver.index.bc: OK
pgsql/pkglib/semver.dylib: OK
pgsql/doc/semver/semver.mmd: OK
pgsql/share/extension/semver.control: OK
pgsql/share/semver/semver--0.3.0--0.4.0.sql: OK
pgsql/share/semver/semver--0.30.0--0.31.0.sql: OK
pgsql/share/semver/semver--0.21.0--0.22.0.sql: OK
pgsql/share/semver/semver--0.32.1.sql: OK
pgsql/share/semver/semver--0.10.0--0.11.0.sql: OK
pgsql/share/semver/semver--0.13.0--0.15.0.sql: OK
pgsql/share/semver/semver--0.31.1--0.31.2.sql: OK
pgsql/share/semver/semver--0.31.2--0.32.0.sql: OK
pgsql/share/semver/semver--unpackaged--0.2.1.sql: OK
pgsql/share/semver/semver--0.12.0--0.13.0.sql: OK
pgsql/share/semver/semver--0.17.0--0.20.0.sql: OK
pgsql/share/semver/semver--0.2.1--0.2.4.sql: OK
pgsql/share/semver/semver--0.16.0--0.17.0.sql: OK
pgsql/share/semver/semver--0.22.0--0.30.0.sql: OK
pgsql/share/semver/semver--0.20.0--0.21.0.sql: OK
pgsql/share/semver/semver--0.15.0--0.16.0.sql: OK
pgsql/share/semver/semver--0.2.4--0.3.0.sql: OK
pgsql/share/semver/semver--0.31.0--0.31.1.sql: OK
pgsql/share/semver/semver--0.11.0--0.12.0.sql: OK
pgsql/share/semver/semver--0.5.0--0.10.0.sql: OK
trunk.json: OK
Done!
Verifying compatibility with Trunk package 0.1.0
Verifying compatibility with PostgreSQL 16.3
Verifying compatibility with linux/amd64:6.5.11-linuxkit 
Trunk package contains darwin binaries but this host runs linux
```

Looks goo---oops! look at that last line. It detected an attempt to install
Darwin binaries and rejected it. That's because I tried to install
`semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk` 🤦🏻‍♂️.

Works with the right binary, though:

``` console
# ./install_trunk semver-0.32.1+pg16-linux-amd64.trunk 
Unpacking semver-0.32.1+pg16-linux-amd64.trunk
Verifying all checksums...Changes: OK
LICENSE: OK
README.md: OK
pgsql/pkglib/bitcode/src/semver/src/semver.bc: OK
pgsql/pkglib/bitcode/src/semver.index.bc: OK
pgsql/pkglib/semver.so: OK
pgsql/doc/semver/semver.mmd: OK
pgsql/share/extension/semver.control: OK
pgsql/share/semver/semver--0.3.0--0.4.0.sql: OK
pgsql/share/semver/semver--0.30.0--0.31.0.sql: OK
pgsql/share/semver/semver--0.21.0--0.22.0.sql: OK
pgsql/share/semver/semver--0.32.1.sql: OK
pgsql/share/semver/semver--0.10.0--0.11.0.sql: OK
pgsql/share/semver/semver--0.13.0--0.15.0.sql: OK
pgsql/share/semver/semver--0.31.1--0.31.2.sql: OK
pgsql/share/semver/semver--0.31.2--0.32.0.sql: OK
pgsql/share/semver/semver--unpackaged--0.2.1.sql: OK
pgsql/share/semver/semver--0.12.0--0.13.0.sql: OK
pgsql/share/semver/semver--0.17.0--0.20.0.sql: OK
pgsql/share/semver/semver--0.2.1--0.2.4.sql: OK
pgsql/share/semver/semver--0.16.0--0.17.0.sql: OK
pgsql/share/semver/semver--0.22.0--0.30.0.sql: OK
pgsql/share/semver/semver--0.20.0--0.21.0.sql: OK
pgsql/share/semver/semver--0.15.0--0.16.0.sql: OK
pgsql/share/semver/semver--0.2.4--0.3.0.sql: OK
pgsql/share/semver/semver--0.31.0--0.31.1.sql: OK
pgsql/share/semver/semver--0.11.0--0.12.0.sql: OK
pgsql/share/semver/semver--0.5.0--0.10.0.sql: OK
trunk.json: OK
Done!
Verifying compatibility with Trunk package 0.1.0
Verifying compatibility with PostgreSQL 16.3
Verifying compatibility with linux/amd64:6.5.11-linuxkit 
Installing doc into /usr/share/doc/postgresql-doc-16...Done
Installing pkglib into /usr/lib/postgresql/16/lib...Done
Installing share into /usr/share/postgresql/16...Done

# psql -U postgres -c "CREATE EXTENSION semver; SELECT '1.2.3'::semver"
CREATE EXTENSION
 semver 
--------
 1.2.3
(1 row)
```

## RFC

Any [PGXS] project can try out the pattern; please do! Just download
[`trunk.mk`] and [`install_trunk`], import `trunk.mk` into your `Makefile`,
install `shasum`, `jq` and `rsync` (if you don't already have them) and give
it a try.

The intent of this POC is to prove the pattern; this is not a complete or
shippable solution. Following a comment period, I expect to build a proper
command-line client (and SDK) to package up artifacts generated from a few
build systems, including [PGXS] and [pgrx].

Whether you try it out or not, I welcome a review of the [proposal][rfc-2] and
your comments on it. I'd like to get this right, and have surely overlooked
some details. Let's get to the best binary packaging format we can.

  [^tools-setup]: I used the [pgxn-tools] image and started Postgres and
    installed the necessary tools with the command `pg-start 16 rsync jq`.

  [PGXN Discussions]: https://github.com/orgs/pgxn/discussions
  [PostgresSQL Code of Conduct]: https://www.postgresql.org/about/policies/coc/
  [Postgres Wiki]: https://wiki.postgresql.org/ "PostgreSQL Wiki"
  [on Just a Theory]: {{% ref "/post/postgres/rfc-pgxn-metadata-sketch" %}}
    "RFC: PGXN Metadata Sketch"
  [rfc-2]: https://github.com/orgs/pgxn/discussions/2 "Proposal-2: Binary Distribution Format"
  [Python wheel format]: https://packaging.python.org/en/latest/specifications/binary-distribution-format/
    "Python Binary distribution format"
  [Trunk]: https://pgt.dev "Trunk — A Postgres Extension Registry"
  [pg_config]: https://www.postgresql.org/docs/current/app-pgconfig.html
    "PostgreSQL Docs: pg_config"
  [summit-session]: {{% ref "/post/postgres/rfc-pgxn-metadata-sketch" %}}#binary-distribution-format
    "🏔 Extension Ecosystem Summit 2024 — Binary Distribution Format"
  [semver extension]: https://github.com/theory/pg-semver "A semantic version data type for PostgreSQL"
  [PR 68]: https://github.com/theory/pg-semver/pull/68
    "theory/pg-semver#68: POC Trunk binary distribution format"
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "Postgres Docs: Extension Building Infrastructure"
  [`trunk.mk`]: https://github.com/theory/pg-semver/pull/68/files#diff-3f827bb78f3b94ffb22530202fd79242800814585635d00d5d9154bb302d279c
  [`Makefile`]: https://github.com/theory/pg-semver/pull/68/files#diff-76ed074a9305c04054cdebb9e9aad2d818052b07091de1f20cad0bbac34ffb52
  [BSD digest format]: https://stackoverflow.com/q/1299833/79202
    "StackOverflow: BSD md5 vs GNU md5sum output format?"
  [pgxn-tools]: https://hub.docker.com/r/pgxn/pgxn-tools
  [`install_trunk`]: https://github.com/theory/pg-semver/pull/68/files#diff-1ef82a7c5bea66c6f95d8b5c65cca31e46671f4ef073fb8ab8d64c9a5f56f147
  [pgrx]: https://github.com/pgcentralfoundation/pgrx
    "pgrx: Build Postgres Extensions with Rust!"
