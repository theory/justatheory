---
title: "New JSONPath Feature: SelectLocated"
slug: jsonpath-located
date: 2025-01-01T20:43:50Z
lastMod: 2025-01-01T20:43:50Z
description: |
  New in the jsonpath Go package and Playground: "Located" results that pair
  selected values with normalized paths to their locations.
tags: [Go, JSONPath, Playground, RFC 9535]
type: post
---

Happy New Year! 🎉🥳🍾🥂

The [JSONPath RFC][RFC] includes a section on defining [normalized paths],
which use a subset of JSONPath syntax to define paths to the location of a
node in a JSON value. I hadn't thought much about it, but noticed that the
[serde JSONPath Sandbox] provides a "Located" switch adds them to query
results. For the sake of complementarity, I added the same feature to the [Go
JSONPath Playground].

🛝 See it in action with [this example], where instead of the default output:

``` json
[
  8.95,
  12.99,
  8.99,
  22.99,
  399
]
```

The located result is:

```json
[
  {
    "node": 8.95,
    "path": "$['store']['book'][0]['price']"
  },
  {
    "node": 12.99,
    "path": "$['store']['book'][1]['price']"
  },
  {
    "node": 8.99,
    "path": "$['store']['book'][2]['price']"
  },
  {
    "node": 22.99,
    "path": "$['store']['book'][3]['price']"
  },
  {
    "node": 399,
    "path": "$['store']['bicycle']['price']"
  }
]
```

[v0.3.0] of the `github.com/theory/jsonpath` Go package enables this feature
via its new [`SelectLocated`] method, which returns a [`LocatedNodeList`] that
shows off a few of the benfits of pairing JSONPath query results with paths
that uniquely identify their locations in a JSON value, including sorting and
deduplication. It also takes advantage of [Go v1.23 iterators], providing
methods to range over all the results, just the node values, and just the
paths. As a result, v0.3.0 now requires Go 1.23.

The [serde_json_path Rust crate] inspired the use of [`LocatedNodeList`]
rather than a simple slice of [`LocatedNode`] structs, but I truly embraced it
once I noticed the the focus on "nodelists" in the [RFC's overview], which
provides this definition:

> A JSONPath *expression* is a string that, when applied to a JSON value (the
> *query argument*), selects zero or more nodes of the argument and outputs
> these nodes as a nodelist.

It regularly refers to nodelists thereafter, and it seemed useful to have an
object to which more features can be added in the future.
`github.com/theory/jsonpath` [v0.3.0] thererfore also changes the result value
of [`Select`] from `[]any` to the new [`NodeList`] struct, an alias for
`[]any`. For now it adds a single method, `All`, which again relies on [Go
v1.23 iterators] to iterate over selected nodes.

While the data type has changed, usage otherwise has not. One can iterate
directly over values just as before:

```go
for _, val := range path.Select(jsonInput) {
    fmt.Printf("%v\n", val)
}
```

But `All` removes the need to alias-away the index value with `_`:

```go
for val := range path.Select(jsonInput).All() {
    fmt.Printf("%v\n", val)
}
```

I don't expect any further incompatible changes to the main `jsonpath` module,
but adding these return values now allows new features to be added to the
selected node lists in the future.

May you find it useful!

  [RFC]: https://www.rfc-editor.org/rfc/rfc9535.html
    "RFC 9535 JSONPath: Query Expressions for JSON"
  [normalized paths]: https://www.rfc-editor.org/rfc/rfc9535#name-normalized-paths
    "RFC 9535 JSONPath: Normalized Paths"
  [serde JSONPath Sandbox]: https://serdejsonpath.live
  [Go JSONPath Playground]: https://theory.github.io/jsonpath/
  [this example]: https://theory.github.io/jsonpath/?p=%2524..price&j=%257B%250A%2520%2520%2522store%2522%253A%2520%257B%250A%2520%2520%2520%2520%2522book%2522%253A%2520%255B%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522reference%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Nigel%2520Rees%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sayings%2520of%2520the%2520Century%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.95%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Evelyn%2520Waugh%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sword%2520of%2520Honour%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252012.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Herman%2520Melville%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Moby%2520Dick%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-553-21311-3%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522J.%2520R.%2520R.%2520Tolkien%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522The%2520Lord%2520of%2520the%2520Rings%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-395-19395-8%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252022.99%250A%2520%2520%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520%255D%252C%250A%2520%2520%2520%2520%2522bicycle%2522%253A%2520%257B%250A%2520%2520%2520%2520%2520%2520%2522color%2522%253A%2520%2522red%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522price%2522%253A%2520399%250A%2520%2520%2520%2520%257D%250A%2520%2520%257D%250A%257D&o=1
  [v0.3.0]: https://pkg.go.dev/github.com/theory/jsonpath@v0.3.0
  [`SelectLocated`]: https://pkg.go.dev/github.com/theory/jsonpath@v0.3.0#Path.SelectLocated
  [`LocatedNodeList`]: https://pkg.go.dev/github.com/theory/jsonpath@v0.3.0#LocatedNodeList
  [Go v1.23 iterators]: https://go.dev/blog/range-functions
  [serde_json_path Rust crate]: https://crates.io/crates/serde_json_path
  [`LocatedNode`]: https://pkg.go.dev/github.com/theory/jsonpath@v0.3.0/spec#LocatedNode
  [RFC's overview]: https://www.rfc-editor.org/rfc/rfc9535#name-overview
    "RFC 9535 JSONPath: Overview"
  [`Select`]: https://pkg.go.dev/github.com/theory/jsonpath@v0.3.0#Path.Select
  [`NodeList`]: https://pkg.go.dev/github.com/theory/jsonpath@v0.3.0#NodeList