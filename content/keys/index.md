---
title: Theory's Public GPG Keys
type: about
outputs: [html, text]
---

Public GPG keys for various email addresses. To import one, copy its URL and
replace `URL` in:

```sh
curl URL | gpg --import
```

Or copy the Key ID and import it from
[keys.openpgp.org](https://keys.openpgp.org) by replacing `KEY_ID` in:

```sh
gpg --keyserver hkps://keys.openpgp.org --recv-keys KEY_ID
```

Current Keys
------------

Keys in current use.

*   [Personal Key]({{% link "theory.gpg" %}})
    *   ID: `92DF6274F8C881F1`
    *   Email: `justatheory.com`, `kineticode.com`, `cpan.org`
*   [Tembo Key]({{% link "tembo.gpg" %}})
    *   ID: `240F89E080939AC2`
    *   Email: `tembo.io`

Old Keys
--------

Discarded keys or for addresses I no longer use.

*   [New York Times Key]({{% link "nytimes.gpg" %}})
    *   ID: `7ABF773B7A54AB7B`
    *   Email: `nytimes.com`
*   [iovation Key]({{% link "iovation.gpg" %}})
    *   ID: `D26D202CCCE1301A`
    *   Email: `iovation.com`
*   [PostgreSQL Experts Key]({{% link "pgexperts.gpg" %}})
    *   ID: `8027FD303884357F`
    *   Email: `pgexperts.com`
