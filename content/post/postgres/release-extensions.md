---
title: "Automate Postgres Extension Releases on GitHub and PGXN"
slug: release-postgres-extensions-with-github-actions
date: 2020-10-25T23:48:36Z
lastMod: 2020-10-25T23:48:36Z
description: Go beyond testing and fully automate the release of Postgres extensions on both GitHub and PGXN using GitHub actions.
tags: [Postgres, PGXN, GitHub, GitHub Actions, Automation, CI/CD]
type: post
---

Back in June, I wrote about [testing Postgres extensions][pgxn-tools] on
multiple versions of Postgres using [GitHub Actions]. The pattern relies on
Docker image, [pgxn/pgxn-tools], which contains scripts to build and run any
version of PostgreSQL, install additional dependencies, build, test, bundle, and
release an extension. I've since updated it to support testing on the the latest
development release of Postgres, meaning one can test on any major version from
8.4 to (currently) 14. I've also created GitHub workflows for all of my PGXN
extensions (except for [pgTAP], which is complicated). I'm quite happy with it.

But I was never quite satisfied with the release process. Quite a number of
Postgres extensions also release on GitHub; indeed, [Paul Ramsey] told me
straight up that he did not want to manually upload extensions like [pgsql-http]
and [PostGIS] to PGXN, but for PGXN to automatically pull them in when they were
published on GitHub. It's pretty cool that newer packaging systems like
[pkg.go.dev] auto-index any packages on GibHub. Adding such a feature to PGXN
would be an interesting exercise.

But since I'm low on TUITs for such a significant undertaking, I decided instead
to work out how to automatically publish a release on GitHub *and* PGXN via
[GitHub Actions]. After experimenting for a few months, I've worked out a
straightforward method that should meet the needs of most projects. I've proven
the pattern via the [pair extension]'s [`release.yml`], which successfully
published the v0.1.7 release today on both [GitHub][gh-release] and
[PGXN][pgxn-release]. With that success, I updated the [pgxn/pgxn-tools]
documentation with a starter example. It looks like this:

```yaml {linenos=true}
name: Release
on:
  push:
    tags:
      - 'v*' # Push events matching v1.0, v20.15.10, etc.
jobs:
  release:
    name: Release on GitHub and PGXN
    runs-on: ubuntu-latest
    container: pgxn/pgxn-tools
    env:
      # Required to create GitHub release and upload the bundle.
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    steps:
    - name: Check out the repo
      uses: actions/checkout@v2
    - name: Bundle the Release
      id: bundle
      run: pgxn-bundle
    - name: Release on PGXN
      env:
        # Required to release on PGXN.
        PGXN_USERNAME: ${{ secrets.PGXN_USERNAME }}
        PGXN_USERNAME: ${{ secrets.PGXN_PASSWORD }}
      run: pgxn-release
    - name: Create GitHub Release
      id: release
      uses: actions/create-release@v1
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        body: |
          Changes in this Release
          - First Change
          - Second Change
    - name: Upload Release Asset
      uses: actions/upload-release-asset@v1
      with:
        # Reference the upload URL and bundle name from previous steps.
        upload_url: ${{ steps.release.outputs.upload_url }}
        asset_path: ./${{ steps.bundle.outputs.bundle }}
        asset_name: ${{ steps.bundle.outputs.bundle }}
        asset_content_type: application/zip
```

Here's how it works:

*   Lines 4-5 trigger the workflow only when a tag starting with the letter v is
    pushed to the repository. This follows the common convention of tagging
    releases with version numbers, such as `v0.1.7` or `v4.6.0-dev`. This
    assumes that the tag represents the commit for the release.

*   Line 10 specifies that the job run in the [pgxn/pgxn-tools] container, where
    we have our tools for building and releasing extensions.

*   Line 13 passes the `GITHUB_TOKEN` variable into the container. This is the
    GitHub [personal access token] that's automatically set for every build. It
    lets us call the [GitHub API] via actions later in the workflow.

*   Step "Bundle the Release", on Lines 17-19, validates the extension
    `META.json` file and creates the release zip file. It does so by simply
    reading the distribution name and version from the `META.json` file and
    archiving the Git repo into a zip file. If your process for creating a
    release file is more complicated, you can do it yourself here; just be sure
    to include an `id` for the step, and emit a line of text so that later
    actions know what file to release. The output should look like this, with
    `$filename` representing the name of the release file, usually
    `$extension-$version.zip`:

    ```
    ::set-output name=bundle::$filename
    ```

*   Step "Release on PGXN", on lines 20-25, releases the extension on PGXN. We
    take this step first because it's the strictest, and therefore the most
    likely to fail. If it fails, we don't end up with an orphan GitHub release
    to clean up once we've fixed things for PGXN.

*   With the success of a PGXN release, step "Create GitHub Release", on lines
    26-35, uses the GitHub [create-release] action to create a release
    corresponding to the tag. Note the inclusion of `id: release`, which will be
    referenced below. You'll want to customize the body of the release; for the [pair extension], I added a simple [make target] to generate a file, then pass it
    via the `body_path` config:

    ``` yaml
    - name: Generate Release Changes
      run: make latest-changes.md
    - name: Create GitHub Release
      id: release
      uses: actions/create-release@v1
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        body_path: latest-changes.md
    ```

*   Step "Upload Release Asset", on lines 36-43, adds the release file to the
    GitHub release, using output of the `release` step to specify the URL to
    upload to, and the output of the `bundle` step to know what file to upload.

Lotta steps, but works nicely. I only wish I could require that the testing
workflow finish before doing a release, but I generally tag a release once it
has been thoroughly tested in previous commits, so I think it's acceptable.

Now if you'll excuse me, I'm off to add this workflow to my other PGXN
extensions.

  [pgxn-tools]: /2020/06/test-extensions-with-github-actions/
    "Test Postgres Extensions With GitHub Actions"
  [GitHub Actions]: https://github.com/features/actions
  [pgxn/pgxn-tools]: https://hub.docker.com/repository/docker/pgxn/pgxn-tools
  [pgTAP]: https://pgtap.org
  [Paul Ramsey]: http://blog.cleverelephant.ca
  [pgsql-http]: https://github.com/pramsey/pgsql-http
  [PostGIS]: http://postgis.net
  [pkg.go.dev]: https://pkg.go.dev
  [pair extension]: https://github.com/theory/kv-pair/
  [`release.yml`]: https://github.com/theory/kv-pair/blob/main/.github/workflows/release.yml
  [gh-release]: https://github.com/theory/kv-pair/releases/tag/v0.1.7
  [pgxn-release]: https://pgxn.org/dist/pair/0.1.7/
  [personal access token]: https://github.com/settings/tokens/new
  [GitHub API]: https://docs.github.com/
  [create-release]: https://github.com/actions/create-release
  [make target]:
    https://github.com/theory/kv-pair/blob/798cd00e76b5b029967262101b9bb2c4add0e9d2/Makefile#L28-L29
