---
title: Welcome dmjwk
slug: welcome-dmjwk
date: 2025-12-30T03:21:05Z
lastMod: 2025-12-30T03:21:05Z
description: |
  I wrote a dead simple demo IDP server. Never use it for real workloads. But
  you might find it useful to demo services that require Bearer Token
  authentication.
tags: [OAuth, JWT, JWK, Go, Bearer, Demo]
type: post
---

Please welcome [dmjwk] into the world. This "demo JWK" (or "dumb JWK" if you
like) service provides super simple Identity Provider APIs strictly for demo
purposes.

Say you've written a service that depends on a public JSON Web Key ([JWK]) set
to authenticate JSON Web Tokens ([JWT]) submitted as [OAuth 2 Bearer
Tokens][Bearer]. Your users will normally configure the service to use an
internal or well-known provider, such as [Auth0], [Okta], or [AWS]. Such
providers might be too heavyweight for demo purposes, however.

For my own use, I needed nothing more than a [Docker Compose] file with
local-only services. I also wanted some control over the contents of the
tokens, since my records the `sub` field from the `JWT` in an audit trail, and
something like `1a1077e6-3b87-1282-789c-f70e66dab825` (as in [Vault JWTs])
makes for less-than-friendly text to describe in a demo.

I created [dmjwk] to scratch this itch. It provides a basic [Resource Owner
Password Credentials Grant] OAuth 2 flow to create custom JWTs, a well-known
URL for the public JWK set, and a simple API that validates JWTs. None of it
is real, it's all for show, but the show's the point.

## Quick Start

The simplest way to start dmjwk is with its [OCI image] (there are [binaries
for 40 platforms], as well). It starts on port 443, since hosts commonly
reserve that port, let's map it to 4433 instead:

```sh
docker run -d -p 4433:443 --name dmjwk --volume .:/etc/dmjwk ghcr.io/theory/dmjwk
```

This command fires up dmjwk with a self-signed TLS certificate for localhost
and creates a root cert bundle, `ca.pem`, in the current directory. Use it
with your favorite HTTP client to make validated requests.

### JWK Set

For example, to fetch the JWK set:

```sh
curl -s --cacert ca.pem https://localhost:4433/.well-known/jwks.json
```

By default dmjwk creates a single JWK in the set that looks something like
this (JSON reformatted):

```json
{
  "keys": [
    {
      "kty": "EC",
      "crv": "P-256",
      "x": "Ld98DHMIIanlpdOhYf-8GljNHnxHW_i6Bq0iltw9J98",
      "y": "xxyRGhCFIjdQFD-TAs-y6uf18wsPvkq8wH_FsGY1GyU"
    }
  ]
}
```

Configure services to use this URL,
`https://localhost:4433/.well-known/jwks.json`, to to validate JWTs created by
dmjwk.

### Authorization

To fetch a JWT signed by the first key in the JWK set (just the one in this
example), make an `application/x-www-form-urlencoded` POST with the required
`grant_type`, `username`, and `password` fields:

```sh
form='grant_type=password&username=kamala&password=a2FtYWxh'
curl -s --cacert ca.pem -d "$form" https://localhost:4433/authorization
```

dmjwk stores no actual usernames and passwords; it's all for show. Provide any
username you like and [Base64]-encode the username, without trailing equal
signs, as the password.

Example successful response:

```json
{
  "access_token": "eyJhbGciOiJFUzI1NiIsImtpZCI6IiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJrYW1hbGEiLCJleHAiOjE3NjY5NDQyNzcsImlhdCI6MTc2Njk0MDY3NywianRpIjoiZ3hhNnNib292aTg5dSJ9.04efdORHDA3GIPMnWErMPy4mXXsBfbnMJlzqZsxGVEc2cRvEWI0Mt_IqHDK4RYK_14BCEu2nTMiEPtgwC2IZ5A",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "read"
}
```

Parsing the the `access_token` JWT from the response provides this header:

```json
{
  "alg": "ES256",
  "kid": "",
  "typ": "JWT"
}
```

And this payload:

```json
{
  "sub": "kamala",
  "exp": 1766944277,
  "iat": 1766940677,
  "jti": "gxa6sboovi89u"
}
```

We can further customize its contents by passing any of a few [additional
parameters]. To specify an audience and issuer, for example:

```sh
form='grant_type=password&username=kamala&password=a2FtYWxh&iss=spacely+sprockets&aud=cogswell.cogs'
curl -s --cacert ca.pem -d "$form" https://localhost:4433/authorization
```

Which returns something like:

```json
{
  "access_token": "eyJhbGciOiJFUzI1NiIsImtpZCI6IiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzcGFjZWx5IHNwcm9ja2V0cyIsInN1YiI6ImthbWFsYSIsImF1ZCI6WyJjb2dzd2VsbC5jb2dzIl0sImV4cCI6MTc2NzAzNDIyNCwiaWF0IjoxNzY3MDMwNjI0LCJqdGkiOiIxNXZmaDhzYm41YWFxIn0.IGRdD5HGiWLOXggZhb9zPlLK40WWy8R0-HmSuIhaObD6WEwA2WXIBWg_MqtFFQISKLXrjNDHphXtEJsx6FZBOQ",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "read"
}
```

Now the JWT payload is:

```json
{
  "iss": "spacely sprockets",
  "sub": "kamala",
  "aud": [
    "cogswell.cogs"
  ],
  "exp": 1767034206,
  "iat": 1767030606,
  "jti": "8ri9vfsg5f8mj"
}
```

This allows customization appropriate for your service, which might determine
authorization based on the contents of the various JWT fields.

A request that fails to authenticate the username and password, e.g.:

```sh
form='grant_type=password&username=kamala&password=nope'
curl -s --cacert ca.pem -d "$form" https://localhost:4433/authorization
```

Will return an appropriate response:

```json
{
  "error": "invalid_request",
  "error_description": "incorrect password"
}
```

### Resource

For simple JWT validation, POST a JWT returned from the
[authorization](#authorization) API as a [Bearer token][Bearer] to
`/resource`:

```sh
tok=$(curl -s --cacert ca.pem -d "$form" https://localhost:4433/authorization | jq -r .access_token)
curl -s --cacert ca.pem -H "Authorization: Bearer $tok" https://localhost:4433/resource -d 'HELLO WORLD
'
```

The response simply returns the request body:

```
HELLO WORLD
```

A request that fails to authenticate, say with an invalid Bearer token:

```sh
curl -s --cacert ca.pem -H "Authorization: Bearer NOT" https://localhost:4433/resource -d 'HELLO WORLD'
```

Returns an appropriate error response:

```json
{
  "error": "invalid_token",
  "error_description": "token is malformed: token contains an invalid number of segments"
}
```

## That's It

dmjwk includes a fair number of [configuration options], including external
certificates, custom host naming (useful with [Docker Compose]), and multiple
key generation. If you find it useful for your demos (but not for production
--- **DON'T DO THAT**) --- let me know. And if not, that's fine, too. This is
a bit of my pursuit of a [thick desire], made mainly for me, but it pleases me
if others find it helpful too.

  [dmjwk]: https://github.com/theory/dmjwk "dmjwk: Simple OAuth 2 JWK/JWT demo service"
  [JWK]: https://www.rfc-editor.org/rfc/rfc7517 "RFC 7517: JSON Web Key (JWK)"
  [JWT]: https://www.rfc-editor.org/rfc/rfc7519 "RFC 7519 JSON Web Token (JWT)"
  [Bearer]: https://datatracker.ietf.org/doc/html/rfc6750
    "RFC 6750 --- The OAuth 2.0 Authorization Framework: Bearer Token Usage"
  [Auth0]: https://auth0.com/docs/secure/tokens/json-web-tokens/json-web-key-sets
    "Auth0 Docs: JSON Web Key Sets"
  [Okta]: https://developer.okta.com/docs/guides/validate-id-tokens/main/#retrieve-the-json-web-key-set
    "Okta Docs: Retrieve the JSON Web Key Set"
  [AWS]: https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-tokens-verifying-a-jwt.html
    "Amazon Cognito Docs: Verifying JSON web tokens"
   [Docker Compose]: https://docs.docker.com/compose/ "Docker Manuals: Docker Compose"
   [Vault JWTs]: https://stackoverflow.com/q/79838080/79202
     "Stack OVerflow: How do I customize core claims in Hashi Vault JWTs?"
  [Resource Owner Password Credentials Grant]: https://datatracker.ietf.org/doc/html/rfc6749#section-4.3
  [OCI image]: https://ghcr.io/theory/dmjwk "dmjwk OCI Packages"
  [binaries for 40 platforms]: https://github.com/theory/dmjwk/releases "dmjwk Releases"
  [Base64]: https://en.wikipedia.org/wiki/Base64 "Wikipedia: Base64"
  [additional parameters]: https://github.com/theory/dmjwk?tab=readme-ov-file#form-fields
    "dmjwk Docs: /authorization Form Fields"
  [configuration options]: https://github.com/theory/dmjwk?tab=readme-ov-file#configuration
    "dmjwk: Configuration"
  [thick desire]: https://www.joanwestenberg.com/thin-desires-are-eating-your-life/
    "JA Westenberg: “Thin Desires Are Eating Your Life”"
