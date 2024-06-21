---
title: "POC: Distributing Trunk Binaries via OCI"
slug: trunk-oci-poc
date: 2024-06-21T20:36:27Z
lastMod: 2024-06-21T20:36:27Z
description: |
  Would it be possible to distribute Postgres extension binaries via Open
  Container Registries? Tune in to find out!
tags: [Postgres, PGXN, Trunk, POC, OCI]
type: post
---

A couple months ago, Álvaro Hernández [suggested] that Postgres extensions
should be distributed as OCI (née Docker) images:

> It's all about not reinventing the wheel, and leveraging the ecosystem
> around OCI. Many of the problems (solutions) in building, packaging and
> distributing extensions are already solved by OCI: there's a whole ecosystem
> of tools around OCI that provide additional benefits in terms of tooling,
> infrastructure and common knowledge.

As a relatively experienced Docker image builder and distributor, I found this
idea intriguing. I wasn't familiar with the [OCI Image Manifest
Specification], which defines how to build OCI images containing arbitrary
files, or "artifacts". But if we could adopt an existing protocol and federated
registry system like OCI/Docker, it would save pretty significant development
time over building our own --- plus we'd be adopting and potentially
contributing to a standard.

After PGConf.dev, I decided to see if I could work out how to distribute
packages in the [recently-proposed trunk format][trunk] such that an
OCI/Docker-style image URL could be used to install a version of an extension
compiled for the appropriate architecture.

Thanks to the denizens of the `#oras` and `#zot` channels on the [CNCF Slack],
I extended the [trunk format POC][trunk] in [pg-semver PR 69] to build the
necessary JSON manifest files, push them to a registry, and then pull and
install the architecturally-appropriate package. Here's how it works.

## Metadata generation

First, I extended [`trunk.mk`], which [builds a trunk package][trunk], with a
few more targets that create the JSON files with metadata necessary to build
OCI manifests. The files that `make trunk` now also generates are:

`{extension}_annotations.json`
:   OCI standard annotations describing a package, including license, vendor,
    and URLs. The `semver_annotations.json` file looks like this:

    ``` json
    {
      "org.opencontainers.image.created": "2024-06-20T18:07:24Z",
      "org.opencontainers.image.licenses": "PostgreSQL",
      "org.opencontainers.image.title": "semver",
      "org.opencontainers.image.description": "A Postgres data type for the Semantic Version format with support for btree and hash indexing.",
      "org.opencontainers.image.source": "https://github.com/theory/pg-semver",
      "org.opencontainers.image.vendor": "PGXN",
      "org.opencontainers.image.ref.name": "0.32.1",
      "org.opencontainers.image.version": "0.32.1",
      "org.opencontainers.image.url": "https://github.com/theory/pg-semver"
    }
    ```

`{package_name}_config.json`
:   An object with fields appropriate for OCI platform specification, plus the
    creation date. Here are the content of
    `semver-0.32.1+pg16-darwin-23.5.0-arm64_config.json`:

:   ```json
    {
      "os": "darwin",
      "os.version": "23.5.0",
      "architecture": "arm64",
      "created": "2024-06-20T18:07:24Z"
    }
    ```

`{package_name}_annotations.json`
:   An object defining annotations to use in an image, built for a specific
    platform, all under the special key `$manifest` to be used later by the
    [ORAS] CLI to put them in the right place.
    `semver-0.32.1+pg16-darwin-23.5.0-arm64_annotations.json` example:

:   ```json
    {
      "$manifest": {
        "org.opencontainers.image.created": "2024-06-20T18:07:24Z",
        "org.opencontainers.image.title": "semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk",
        "org.opencontainers.image.licenses": "PostgreSQL",
        "org.opencontainers.image.description": "A Postgres data type for the Semantic Version format with support for btree and hash indexing.",
        "org.opencontainers.image.source": "https://github.com/theory/pg-semver",
        "org.opencontainers.image.vendor": "PGXN",
        "org.opencontainers.image.ref.name": "0.32.1",
        "org.opencontainers.image.version": "0.32.1",
        "org.opencontainers.image.url": "https://github.com/theory/pg-semver",
        "org.pgxn.trunk.pg.version": "16.3",
        "org.pgxn.trunk.pg.major": "16",
        "org.pgxn.trunk.pg.version_num": "160003",
        "org.pgxn.trunk.version": "0.1.0"
      }
    }
    ```
  
:   The `org.opencontainers.image` keys are the same as in
    `semver_annotations.json`, while the new `org.pgxn.trunk` annotations are
    intended for an install client to find the image appropriate for the
    version of Postgres, although that functionality isn't part of this POC.

The only change to the `Makefile` to support these annotations are the
addition of a `DESCRIPTION` variable to populate
`org.opencontainers.image.description` and a `REPO_URL` to populate
`org.opencontainers.image.source`. `trunk.mk` includes a couple other new
variables, too: `TITLE` (defaults to `EXTENSION`), `VENDOR` (defaults to
"PGXN"), and `URL` (defaults to `REPO-URL`).

## Publishing Images

The new shell script [`push_trunk`] uses the [ORAS] CLI and `jq` to build the
necessary manifest files and push them to an OCI registry. It currently works
only two trunk files like those built in the [trunk POC][trunk]. It first
"pushes" the trunks to a locally-created [OCI layout], then constructs
manifests associated the SHA ID of each just-pushed image with annotations and
platform configurations and writes them into an [image index] manifest.
Finally, it pushes the complete OCI layout described by the index to a remote
registry.

If that sounds like a lot of steps, you're right, it adds up. But the result,
following a precedent established by [Homebrew] (as described in [this issue])
is multiple images for different platforms indexed at a single URI. Once we
publish the two trunks:

``` sh
./push_trunk localhost:5000/theory/semver:0-32.1 \
    semver-0.32.1+pg16-darwin-23.5.0-arm64 \
    semver-0.32.1+pg16-linux-amd64
```

We can fetch the manifests. The address for the image index is that first
parameter, `localhost:5000/theory/semver:0-32.1`; we fetch the manifest with
the command

``` sh
oras manifest fetch localhost:5000/theory/semver:0-32.1
```

Which returns:

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.index.v1+json",
  "manifests": [
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 1285,
      "digest": "sha256:1a14997eb380f9641cba6193c001eb630319f345d76ef07aee37f86fafcdbe0b",
      "platform": {
        "os": "linux",
        "architecture": "amd64"
      },
      "annotations": {
        "org.pgxn.trunk.pg.version": "16.3",
        "org.pgxn.trunk.pg.major": "16",
        "org.pgxn.trunk.pg.version_num": "160003",
        "org.pgxn.trunk.version": "0.1.0"
      }
    },
    {
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 1302,
      "digest": "sha256:385fcfe6b33c858c3f126fb4284afe23ba8c2f7c32db8a50a607dfece6dd9162",
      "platform": {
        "os": "darwin",
        "os.version": "23.5.0",
        "architecture": "arm64"
      },
      "annotations": {
        "org.pgxn.trunk.pg.version": "16.3",
        "org.pgxn.trunk.pg.major": "16",
        "org.pgxn.trunk.pg.version_num": "160003",
        "org.pgxn.trunk.version": "0.1.0"
      }
    }
  ],
  "annotations": {
    "org.opencontainers.image.created": "2024-06-21T13:55:01Z",
    "org.opencontainers.image.licenses": "PostgreSQL",
    "org.opencontainers.image.title": "semver",
    "org.opencontainers.image.description": "A Postgres data type for the Semantic Version format with support for btree and hash indexing.",
    "org.opencontainers.image.source": "https://github.com/theory/pg-semver",
    "org.opencontainers.image.vendor": "PGXN",
    "org.opencontainers.image.ref.name": "0.32.1",
    "org.opencontainers.image.version": "0.32.1",
    "org.opencontainers.image.url": "https://github.com/theory/pg-semver"
  }
}
```

Note the `manifests` array, which lists images associated with this URI. The
first one is for amd64 linux and the second for arm64 darwin. They also
contain the `org.pgxn.trunk` annotations that would allow filtering for an
appropriate Postgres version. The idea is to download an index like this, find
the manifest information for the appropriate platform and Postgres version,
and download it. To get the darwin image, pull it by its digest:

``` sh
oras pull localhost:5000/theory/semver:0-32.1@sha256:385fcfe6b33c858c3f126fb4284afe23ba8c2f7c32db8a50a607dfece6dd9162
```

Which downloads the file:

``` console
$ ls -l *.trunk
semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk
```

Nice! The OCI protocol allows for filtering on platform directly, skipping the
need to download and examine the image index. This is how `docker pull
--platform` works, but is general to OCI. We can fetch a manifest with this
command:

```sh
oras manifest fetch --platform linux/amd64 localhost:5000/theory/semver:0-32.1
```

Which returns not the image index, but the manifest for the Linux image:

``` json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "artifactType": "application/vnd.pgxn.trunk.layer.v1",
  "config": {
    "mediaType": "application/vnd.oci.image.config.v1+json",
    "digest": "sha256:90c8d6f2e67cba09f8178648ad95a6b31e51c0d902058bf396f9e7e5f50c8dfd",
    "size": 84
  },
  "layers": [
    {
      "mediaType": "application/vnd.oci.image.layer.v1.tar+gzip",
      "digest": "sha256:b52b292cabe3ca479673ab68d3ea647802a86f15059c3e19ed24d5a7688159c3",
      "size": 61983,
      "annotations": {
        "org.opencontainers.image.title": "semver-0.32.1+pg16-linux-amd64.trunk"
      }
    }
  ],
  "annotations": {
    "org.opencontainers.image.created": "2024-06-21T17:55:13Z",
    "org.opencontainers.image.description": "A Postgres data type for the Semantic Version format with support for btree and hash indexing.",
    "org.opencontainers.image.licenses": "PostgreSQL",
    "org.opencontainers.image.ref.name": "0.32.1",
    "org.opencontainers.image.source": "https://github.com/theory/pg-semver",
    "org.opencontainers.image.title": "semver-0.32.1+pg16-linux-amd64.trunk",
    "org.opencontainers.image.url": "https://github.com/theory/pg-semver",
    "org.opencontainers.image.vendor": "PGXN",
    "org.opencontainers.image.version": "0.32.1",
    "org.pgxn.trunk.pg.major": "16",
    "org.pgxn.trunk.pg.version": "16.3",
    "org.pgxn.trunk.pg.version_num": "160003",
    "org.pgxn.trunk.version": "0.1.0"
  }
}
```

Or we can pull the file by platform with:

``` sh
rm *.trunk
oras pull --platform linux/amd64 localhost:5000/theory/semver:0-32.1
```

And now the Linux image has been downloaded:

``` console
$ ls -1 *.trunk
semver-0.32.1+pg16-linux-amd64.trunk
```

Pretty nice! These examples use [zot] running in a local Docker container, but
could just as easily use the Docker registry (`docker.io`) or the GitHub
registry (`ghcr.io`) --- which is where Homebrew stores its images (e.g.,
[sqlite 3.46.0]).

Installation
------------

With these manifests configured and pushed, changes to [`install_trunk`] use
this knowledge to download from the registry instead of relying on an existing
file (as implemented for the [trunk POC][trunk]). Now we call it like so:

``` sh
./install_trunk localhost:5000/theory/semver:0-32.1
```

First, it assembles platform information from `uname`, then pulls the
platform-specific image with this `oras` command:

``` sh
oras pull --no-tty --plain-http \
     --format 'go-template={{(first .files).path}}' 
     --platform "$platform" "$trunk"
```

As before, it downloads the image appropriate for the platform. The `--format`
option, meanwhile, causes it to also download annotations and extract the path
for the downloaded file. So in addition to downloading the file, it also emits
its full path:

```
/tmp/pgxn/semver-0.32.1+pg16-darwin-23.5.0-arm64.trunk
```

the script proceeds to unpack the image with that file name and continues with
the installation process as [before].

## Demo

The last new file in [the PR][pg-semver PR 69] is [`docker_compose.yml`],
which sets up an amd64 Linux container for building an extension for Postgres
16, and a [zot] container to push to and pull from. I used it to build this
POC and record this demo:

<video controls muted width="676" x-webkit-airplay="allow"
webkit-playsinline="" preload="none" poster="{{% link "trunk-oci-poc-poster.png" %}}">
  <source src="{{% link "trunk-oci-poc-demo.mp4" %}}" type="video/mp4" />
	<source src="{{% link "trunk-oci-poc-demo.webm" %}}" type="video/webm" />
  <source src="{{% link "trunk-oci-poc-demo.mov" %}}" type="video/quicktime" />
</video>

To use it yourself, run these commands with `docker_compose.yml`:

``` sh
git clone https://github.com/theory/pg-semver.git
cd pg-semver
git checkout -b trunk-oci origin/trunk-oci
docker compose up -d
```

This clones the [pg-semver] repository, checks out the `trunk-oci` branch,
fires up the containers. Wait a couple minutes for Postgres to start and be
configured, then, assuming you can build against Postgres 16 on your local
machine, you can follow the same steps. The commands in the demo are:

``` sh
make trunk
docker compose exec linux bash
make clean
make trunk
exit
ls -1 *.trunk
ls -1 *.json
./push_trunk localhost:5000/theory/semver:0.32.1 \
    semver-0.32.1+pg16-darwin-23.5.0-arm64 \
    semver-0.32.1+pg16-linux-amd64
./install_trunk localhost:5000/theory/semver:0.32.1
docker compose exec linux bash
./install_trunk zot:5000/theory/semver:0.32.1
exit
```
You might need to adjust the first trunk image name if your local
configuration is not the same as mine.

Concept Proven
--------------

Honestly, this POC far exceeded my expectations. It worked *great*! Not only
does the [trunk format][trunk] seem to work well, but distributing via OCI
registries is even better! It brings a bunch of benefits:

*   We could build a community registry that automatically builds images for
    PGXN releases for a variety of platforms. This could grow to become the
    default method for installing extensions, perhaps via a command such as
    `pgxn trunk install theory/semver`.
*   Anyone can use any other registry, and the tooling will work with it. Just
    as you can pull Docker images from `docker.io`, you can also pull them
    from `ghcr.io`, `quay.io`, or any other OCI-compliant registry. The same
    applies here. Extension authors can build and publish trunks to their own
    registries if they like.
*   Better yet, organizations can build extension registries for their own use
    cases, to complement the community registry. Think internal registries for
    private extensions, or commercial registries that additional features,
    such as security scans or curation.

Super promising! I'm just about ready to get to work building this stuff,
though I anticipate a few challenges:

*   We'll need a way to find the latest version (tag) of a release. I'm sure
    this is do-able, since Homebrew does it. There must be some other index
    for tags (`ghcr.io/homebrew/core/sqlite:latest` doesn't return a result,
    alas).
*   In addition to filtering on platform specification when pulling an image,
    it would be nice to filter on other attributes, such as the
    `org.pgxn.trunk` annotations defining Postgres the version. For now it
    will be fine for the CLI to download an image index and find the right
    image, but additional server-side filtering would be very nice.
*   Will need to support extensions that can run on any architecture, such as
    pure SQL extensions. I think this will be pretty easy by publishing a
    single tagged image instead of an image index.
*   If we build a community registry, where should it be hosted? Homebrew uses
    `ghcr.io`, presumably avoiding hosting costs, but it might be nice to have
    a specific community registry, perhaps at `trunk.pgxn.org` or perhaps
    `oci.postgresql.org`.
*   If we do host a registry, might we want to allow extension authors to
    publish their own trunks within their namespaces? How might that be
    organized?

I can imagine workable solutions to these relatively minor challenges. As long
as we can encapsulate them into the commands for a single command-line client,
it should work out well.

Can't wait to get started. What do you think? 

  [suggested]: https://www.ongres.com/blog/why-postgres-extensions-should-be-distributed-and-packaged-as-oci-images/
    "Álvaro Hernández: Why Postgres Extensions should be packaged and distributed as OCI images"
  [OCI Image Manifest Specification]: https://github.com/opencontainers/image-spec/blob/main/manifest.md
  [trunk]: {{% ref "/post/postgres/trunk-poc" %}} "POC: PGXN Binary Distribution Format"
  [CNCF Slack]: https://communityinviter.com/apps/cloud-native/cncf
  [pg-semver PR 69]: https://github.com/theory/pg-semver/pull/69
    "theory/pg-semver#69: POC pushing & pulling trunk from an OSI registry"
  [`trunk.mk`]: https://github.com/theory/pg-semver/pull/69/files#diff-3f827bb78f3b94ffb22530202fd79242800814585635d00d5d9154bb302d279c
  [`push_trunk`]: https://github.com/theory/pg-semver/pull/69/files#diff-543b555ee5586af46bdf528b1f907c07f8f044ebe57e63ba518190d3cfd9b917
  [ORAS]: https://oras.land "Distribute Artifacts Across OCI Registries With Ease"
  [OCI layout]: https://github.com/opencontainers/image-spec/blob/main/image-layout.md
    "OCI Image Layout Specification"
  [image index]: https://github.com/opencontainers/image-spec/blob/main/image-index.md
    "OCI Image Index Specification"
  [Homebrew]: https://brew.sh "Homebrew: The Missing Package Manager for macOS (or Linux)"
  [this issue]: https://github.com/oras-project/oras/issues/237
    "oras-project/oras#237: Pushing an image index"
  [sqlite 3.46.0]: https://github.com/Homebrew/homebrew-core/pkgs/container/core%2Fsqlite/221454310?tag=3.46.0
    "ghcr.io/Homebrew/homebrew-core/core/sqlite:3.46.0"
  [zot]: https://zotregistry.dev/ "OCI-native container image registry, simplified"
  [`install_trunk`]: https://github.com/theory/pg-semver/pull/69/files#diff-1ef82a7c5bea66c6f95d8b5c65cca31e46671f4ef073fb8ab8d64c9a5f56f147
  [before]: {{% ref "/post/postgres/trunk-poc" %}}#install-trunk
    "POC: PGXN Binary Distribution Format — install_trunk"
  [`docker_compose.yml`]: https://github.com/theory/pg-semver/pull/69/files#diff-e45e45baeda1c1e73482975a664062aa56f20c03dd9d64a827aba57775bed0d3
  [pg-semver]: https://github.com/theory/pg-semver.git
