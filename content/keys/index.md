---
title: Theory's Public GPG Keys
type: about
outputs: [html, text]
---

Public GPG keys for various email addresses I have or have had. To import one,
copy its URL and replace `URL` in:

```sh
curl URL | gpg --import
```

Or copy the Key ID and get from [keys.openpgp.org](https://keys.openpgp.org)
by replacing `KEY_ID` in:

```sh
gpg --keyserver hkps://keys.openpgp.org --recv-keys KEY_ID
```

*   [Personal Key]({{% link "theory.gpg" %}})
    *   Key ID: `92DF6274F8C881F1`
    *   Email domains: `justatheory.com`, `kineticode.com`, `cpan.org`
*   [Tembo Key]({{% link "tembo.gpg" %}})
    *   Key ID: `240F89E080939AC2`
    *   Email domains: `tembo.io`
*   [NYTimes Key]({{% link "nytimes.gpg" %}})
    *   Key ID: `7ABF773B7A54AB7B`
    *   Email domains: `nytimes.com`
*   [iovation Key]({{% link "iovation.gpg" %}})
    *   Key ID: `D26D202CCCE1301A`
    *   Email domains: `iovation.com`
*   [PostgreSQL Experts Key]({{% link "pgexperts.gpg" %}})
    *   Key ID: `8027FD303884357F`
    *   Email domains: `pgexperts.com`
