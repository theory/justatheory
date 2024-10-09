---
title: PGXN Certifications RFC
slug: pgxn-certifications-rfc
date: 2024-10-09T16:26:48Z
lastMod: 2024-10-09T16:26:48Z
description: |
  A request for comments on a new PGXN RFC for signing releases, plus a link to
  an initial implementation.
tags: [Postgres, PGXN, RFC, JWS]
type: post
---

A couple weeks ago, I drafted [PGXN RFC–5 — Release Certification], which
proposes to replace the simple inclusion of a SHA-1 hash digests in PGXN
release `META.json` files with a [JWS]-signed release payload. From the
introduction: 

> This RFC therefore proposes to extend [v2] distribution metadata with a
> single additional property, `certs`, that contains one or more
> *certifications* that attest to the authenticity or other characteristics of
> a release on PGXN.
> 
> The `certs` value is an object that contains at least one property, `pgxn`,
> which itself contains a PGXN-generated [RFC 7515][JWS] JSON Web Signature in
> the [JWS JSON Serialization] format. The `pgxn` property will allow clients
> not only to assemble the release URL and verify the downloaded file against
> checksums, but also validate it against a public key provided by PGXN.
> 
> The design allows multiple signatures, certifications, or other
> attestations, which in the future **MAY** allow authors or other entities to
> sign releases with their own keys. The new format appends a structure such
> as this to the distribution `META.json` file:
> 
> ``` json
> {
>   "certs": {
>     "pgxn": {
>       "payload": "eyJ1c2VyIjoidGhlb3J5IiwiZGF0ZSI6IjIwMjQtMDktMTNUMTc6MzI6NTVaIiwidXJpIjoiZGlzdC9wYWlyLzAuMS43L3BhaXItMC4xLjcuemlwIiwiZGlnZXN0cyI6eyJzaGE1MTIiOiJiMzUzYjVhODJiM2I1NGU5NWY0YTI4NTllN2EyYmQwNjQ4YWJjYjM1YTdjMzYxMmIxMjZjMmM3NTQzOGZjMmY4ZThlZTFmMTllNjFmMzBmYTU0ZDdiYjY0YmNmMjE3ZWQxMjY0NzIyYjQ5N2JjYjYxM2Y4MmQ3ODc1MTUxNWI2NyJ9fQ",
>       "signature": "cC4hiUPoj9Eetdgtv3hF80EGrhuB__dzERat0XF9g2VtQgr9PJbu3XOiZj5RZmh7AAuHIm4Bh-rLIARNPvkSjtQBMHlb1L07Qe7K0GarZRmB_eSN9383LcOLn6_dO--xi12jzDwusC-eOkHWEsqtFZESc6BfI7noOPqvhJ1phCnvWh6IeYI2w9QOYEUipUTI8np6LbgGY9Fs98rqVt5AXLIhWkWywlVmtVrBp0igcN_IoypGlUPQGe77Rw"
>     }
>   }
> }
> ```

Review and feedback would be very much appreciated, especially on the list of
unresolved questions toward the end.

Thanks to [David Christensen] and [Steven Miller] for the early reviews!

Meanwhile, I've released [pgxn_meta v0.4.0], which adds support for this
format, as well as code to rewrite PGXN v1 release fields to the new format.
It doesn't actually do signature verification, yet, as the server back end
hasn't been updated with the pattern and PKI. But I expect to modify it in
response to feedback and get it implemented in early 2025.

  [PGXN RFC–5 — Release Certification]: https://github.com/pgxn/rfcs/pull/5
    "pgxn/rfcs#5 Add RFC for JWS-signing PGXN releases"
  [JWS]: https://www.rfc-editor.org/rfc/rfc7515.html "JSON Web Signature (JWS)"
  [v2]: https://github.com/pgxn/rfcs/pull/3 "pgxn/rfcs#3 PGXN Meta Spec v2"
  [JWS JSON Serialization]: https://www.rfc-editor.org/rfc/rfc7515.html#section-7.2
    "RFC 7515: JWS JSON Serialization"
  [pgxn_meta v0.4.0]: https://crates.io/crates/pgxn_meta/0.4.0
    "crates.io: pgxn_meta crate"
  [David Christensen]: https://www.crunchydata.com/blog/author/david-christensen
  [Steven Miller]: https://github.com/sjmiller609 "GitHub: Steven Miller"
