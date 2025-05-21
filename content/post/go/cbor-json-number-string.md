---
title: CBOR Tag for JSON Number Strings
slug: cbor-json-number-string
date: 2025-05-18T19:32:06Z
lastMod: 2025-05-18T19:32:06Z
description:
  Use the new IANA-registered tag to preserve JSON numbers represented as
  strings when encoding in Concise Binary Object Representation.
tags: [Go, CBOR, JSON, IETF, IANA]
type: post
---

For a side project, I'm converting JSON inputs to [CBOR], or Concise Binary
Object Representation, defined by [RFC 8949], in order to store a more compact
representation in the database. This go Go app uses [encoding/json] package's
[`UseNumber`] decoding option to preserve numbers as strings, rather tha
`float64`s. Alas, CBOR has no support for such a feature, so such values
cannot survive a round-trip to CBOR and back, as demonstrating by this example
using the [github.com/fxamacker/cbor] package ([playground][play1])

```go {linenos=table}
// Decode JSON number using json.Number.
input := bytes.NewReader([]byte(`{"temp": 98.6}`))
dec := json.NewDecoder(input)
dec.UseNumber()
var val map[string]any
if err := dec.Decode(&val); err != nil {
	log.Fatalf("Err: %v", err)
}

// Encode as CBOR.
data, err := cbor.Marshal(val)
if err != nil {
	log.Fatalf("Err: %v", err)
}

// Decode back into Go.
var newVal map[string]any
if err := cbor.Unmarshal(data, &newVal); err != nil {
	log.Fatalf("Err: %v", err)
}

// Encode as JSON.
output, err := json.Marshal(newVal)
if err != nil {
	log.Fatalf("Err: %v", err)
}

fmt.Printf("%s\n", output)
```

The output:

```json
{"temp":"98.6"}
```

Note that the input on line 2 contains the number `98.6`, but once the value
has been transformed to CBOR and back it becomes the string `"98.6"`.

I wanted to preserve JSON numbers treated as strings. Fortunately, [CBOR] uses
numeric tags to identify data types, and includes a [registry] maintained by
[IANA]. I [proposed] a new tag for JSON numbers as strings and, through a few
iterations, the [CBOR group] graciously accepted the [formal description of
semantics] and assigned tag `284` in the [registry].

Now any system that handles JSON numbers as strings can use this tag to
preserve the numeric representation in JSON output.
 
Here's how to use the tag customization features of
[github.com/fxamacker/cbor] to transparently round-trip `json.Number` values
[playground][play2]:

```go {linenos=table}
// Create tag 284 for JSON Number as string.
tags := cbor.NewTagSet()
tags.Add(
    cbor.TagOptions{
        EncTag: cbor.EncTagRequired,
        DecTag: cbor.DecTagRequired,
    },
    reflect.TypeOf(json.Number("")),
    284,
)

// Create a custom CBOR encoder and decoder:
em, _ := cbor.EncOptions{}.EncModeWithTags(tags)
dm, _ := cbor.DecOptions{
    DefaultMapType: reflect.TypeOf(map[string]any(nil)),
}.DecModeWithTags(tags)

// Decode JSON number using json.Number.
input := bytes.NewReader([]byte(`{"temp": 98.6}`))
dec := json.NewDecoder(input)
dec.UseNumber()
var val map[string]any
if err := dec.Decode(&val); err != nil {
    log.Fatalf("Err: %v", err)
}

// Encode as CBOR.
data, err := em.Marshal(val)
if err != nil {
    log.Fatalf("Err: %v", err)
}

// Decode back into Go.
var newVal map[string]any
if err := dm.Unmarshal(data, &newVal); err != nil {
    log.Fatalf("Err: %v", err)
}

// Encode as JSON.
output, err := json.Marshal(newVal)
if err != nil {
    log.Fatalf("Err: %v", err)
}

fmt.Printf("%s\n", output)
```

Lines 1-16 contain the main difference from the previous example. They create
a CBOR encoder (`em`) and decoder (`dm`) with tag `284` assigned to
`json.Number` values. The code then uses them rather than the `cbor` package
to `Marshal` and `Unmarshal` the values on lines 28 and 35. The result:

```
{"temp":98.6}
```

Et voilà! `json.Number` values are once again preserved.

I believe these custom CBOR encoder and decoder configurations bring full
round-trip compatibility to any regular JSON value decoded by [encoding/json].
The other important config for that compatibility is the `DefaultMapType`
decoding option on line 15, which ensures maps use `string` values for map
keys rather the CBOR-default `any` values.

  [CBOR]: https://cbor.io "CBOR — Concise Binary Object Representation"
  [RFC 8949]: https://www.rfc-editor.org/rfc/rfc8949.html
    "RFC 8949 Concise Binary Object Representation"
  [encoding/json]: https://pkg.go.dev/encoding/json
  [`UseNumber`]: https://pkg.go.dev/encoding/json#Decoder.UseNumber
  [github.com/fxamacker/cbor]: https://pkg.go.dev/github.com/fxamacker/cbor/v2
  [play1]: https://go.dev/play/p/a0ukEGoQFSG
  [registry]: https://www.iana.org/assignments/cbor-tags/cbor-tags.xhtml
    "Concise Binary Object Representation (CBOR) Tags"
  [IANA]: https://www.iana.org "Internet Assigned Numbers Authority"
  [proposed]: https://mailarchive.ietf.org/arch/msg/cbor/BjA7Bc0CSubgIDGyzyiTJeLSGaQ/
  [CBOR group]: https://mailman3.ietf.org/mailman3/lists/cbor@ietf.org/
  [formal description of semantics]: https://gist.github.com/theory/ef667af1c725240e6e30d525786d58e6
    "JSON Number String Tag for CBOR"
  [play2]: https://go.dev/play/p/o2-4a76fE_5
