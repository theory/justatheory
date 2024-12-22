---
title: JSONTree Module and Playground
slug: jsontree
date: 2024-12-22T21:33:39Z
lastMod: 2024-12-22T21:33:39Z
description: |
  I'm happy to announce the release of the JSONTree Go module and Wasm-powered
  in-browser playground.
tags: [Go, JSONTree, JSONPath, Playground, RFC 9535]
type: post
---

As a follow-up to the JSONPath module and playground I released [last month],
I'm happy to announce the follow-up project, called JSONTree. I've implemented
it in the [github.com/theory/jsontree] Go package, and built a [Wasm]-powered
browser [playground] for it.

JSON*Tree*?
-----------

While a [RFC 9535 JSONPath] query selects and returns an array of values from
the end of a path expression, a JSONTree compiles multiple JSONPath queries
into a single query that selects values from multiple path expressions. It
returns results not as an array, but as a subset of the query input,
preserving the paths for each selected value.

In other words, it compiles multiple paths into a single tree of selection
paths, and preserves the tree structure of the input. Hence JSON*Tree*.

### Example

Consider this JSON:

```json
{
  "store": {
    "book": [
      {
        "category": "reference",
        "author": "Nigel Rees",
        "title": "Sayings of the Century",
        "price": 8.95
      },
      {
        "category": "fiction",
        "author": "Evelyn Waugh",
        "title": "Sword of Honour",
        "price": 12.99
      },
      {
        "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "isbn": "0-553-21311-3",
        "price": 8.99
      },
      {
        "category": "fiction",
        "author": "J. R. R. Tolkien",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99
      }
    ],
    "bicycle": {
      "color": "red",
      "price": 399
    }
  }
}
```

This JSONPath query:

``` jsonpath
$..price
```

Selects these values ([playground][play1]):

``` json
[8.95, 12.99, 8.99, 22.99, 399]
```

While this JSONPath query:

``` jsonpath
$..author
```

Selects ([playground][play2]):

``` json
[
  "Nigel Rees",
  "Evelyn Waugh",
  "Herman Melville",
  "J. R. R. Tolkien"
]
```

JSONTree compiles these two JSONPaths into a single query that merges the
`author` and `price` selectors into a single segment, which stringifies to a
[tree]-style format ([playground][play3]):

```tree
$
└── ..["author","price"]
```

This JSONTree returns the appropriate subset of the original JSON object
([playground][play4]):

``` json
{
  "store": {
    "book": [
      {
        "author": "Nigel Rees",
        "price": 8.95
      },
      {
        "author": "Evelyn Waugh",
        "price": 12.99
      },
      {
        "author": "Herman Melville",
        "price": 8.99
      },
      {
        "author": "J. R. R. Tolkien",
        "price": 22.99
      }
    ],
    "bicycle": {
      "price": 399
    }
  }
}
```

Note that the original data structure remains, but only for the subset of the
structure selected by the JSONPath queries.

Use Cases
---------

A couple of use cases drove the conception and design of JSONPath.

### Permissions

Consider an application in which [ACL]s define permissions for groups of users
to access specific branches or fields of JSON documents. When delivering a
document, the app would:

*   Fetch the groups the user belongs to
*   Convert the permissions from each into JSONPath queries
*   Compile the JSONPath queries into an JSONTree query
*   Select and return the permitted subset of the document to the user

### Selective Indexing

Consider a searchable document storage system. For large or complex documents,
it may be infeasible or unnecessary to index the entire document for full-text
search. To index a subset of the fields or branches, one would:

*   Define JSONPaths the fields or branches to index
*   Compile the JSONPath queries into a JSONTree query
*   Select and submit only the specified subset of each document to the
    indexing system

Go Example
----------

Use the [github.com/theory/jsontree] Go package together with
[github.com/theory/jsonpath] to compile and execute JSONTree queries:

```go
package main

import (
	"fmt"

	"github.com/theory/jsonpath"
	"github.com/theory/jsontree"
)

func main() {
	// JSON as unmarshaled by encoding/json.
	value := map[string]any{
		"name":  "Barrack Obama",
		"years": "2009-2017",
		"emails": []any{
			"potus@example.com",
			"barrack@example.net",
		},
	}

	// Compile multiple JSONPaths into a JSONTree.
	tree := jsontree.New(
		jsonpath.MustParse("$.name"),
		jsonpath.MustParse("$.emails[1]"),
	)

	// Select from the input value.
	js, err := json.Marshal(tree.Select(value))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%#v\n", tree.Select(value))
}
```

And the output:

```json
{"emails":["barrack@example.net"],"name":"Barrack Obama"}
```

Note that the index position of the selected email was not preserved. Replace
`New` with [`NewFixedModeTree`] to create a "fixed mode" JSONTree that
preserves index positions by filling gaps with `null`s. Its output of the
above example would be:

```json
{"emails":[null,"barrack@example.net"],"name":"Barrack Obama"}
```

Status
------

The public interface of the `jsontree` module is quite minimal and stable. But
I suspect there may remain some flaws in the merging of JSONPath selectors.
Please report bugs via [GitHub issues] and I'll get them fixed up ASAP.

Otherwise, please share and enjoy!

  [last month]: {{% ref "/post/go/go-jsonpath-playground" %}}
    "Introducing RFC 9535 Go JSONPath and Playground"
  [RFC 9535 JSONPath]: https://www.rfc-editor.org/rfc/rfc9535.html
    "RFC 9535 JSONPath: Query Expressions for JSON"
  [github.com/theory/jsontree]: https://pkg.go.dev/github.com/theory/jsontree
  [github.com/theory/jsonpath]: https://pkg.go.dev/github.com/theory/jsonpath
  [Wasm]: https://webassembly.org "WebAssembly"
  [playground]: https://theory.github.io/jsontree/ "Go JSONTree Playground"
  [play1]: https://theory.github.io/jsonpath/?p=%2524..price&j=%257B%250A%2520%2520%2522store%2522%253A%2520%257B%250A%2520%2520%2520%2520%2522book%2522%253A%2520%255B%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522reference%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Nigel%2520Rees%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sayings%2520of%2520the%2520Century%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.95%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Evelyn%2520Waugh%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sword%2520of%2520Honour%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252012.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Herman%2520Melville%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Moby%2520Dick%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-553-21311-3%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522J.%2520R.%2520R.%2520Tolkien%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522The%2520Lord%2520of%2520the%2520Rings%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-395-19395-8%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252022.99%250A%2520%2520%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520%255D%252C%250A%2520%2520%2520%2520%2522bicycle%2522%253A%2520%257B%250A%2520%2520%2520%2520%2520%2520%2522color%2522%253A%2520%2522red%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522price%2522%253A%2520399%250A%2520%2520%2520%2520%257D%250A%2520%2520%257D%250A%257D&o=0
  [play2]: https://theory.github.io/jsonpath/?p=%2524..author&j=%257B%250A%2520%2520%2522store%2522%253A%2520%257B%250A%2520%2520%2520%2520%2522book%2522%253A%2520%255B%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522reference%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Nigel%2520Rees%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sayings%2520of%2520the%2520Century%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.95%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Evelyn%2520Waugh%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sword%2520of%2520Honour%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252012.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Herman%2520Melville%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Moby%2520Dick%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-553-21311-3%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522J.%2520R.%2520R.%2520Tolkien%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522The%2520Lord%2520of%2520the%2520Rings%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-395-19395-8%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252022.99%250A%2520%2520%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520%255D%252C%250A%2520%2520%2520%2520%2522bicycle%2522%253A%2520%257B%250A%2520%2520%2520%2520%2520%2520%2522color%2522%253A%2520%2522red%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522price%2522%253A%2520399%250A%2520%2520%2520%2520%257D%250A%2520%2520%257D%250A%257D&o=0
  [tree]: https://en.wikipedia.org/wiki/Tree_(command) "Wikipedia: Tree (command)"
  [play3]: https://theory.github.io/jsontree/?p=%2524..author%250A%2524..price&j=&o=2
  [play4]: https://theory.github.io/jsontree/?p=%2524..author%250A%2524..price&j=%257B%250A%2520%2520%2522store%2522%253A%2520%257B%250A%2520%2520%2520%2520%2522book%2522%253A%2520%255B%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522reference%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Nigel%2520Rees%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sayings%2520of%2520the%2520Century%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.95%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Evelyn%2520Waugh%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sword%2520of%2520Honour%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252012.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Herman%2520Melville%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Moby%2520Dick%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-553-21311-3%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522J.%2520R.%2520R.%2520Tolkien%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522The%2520Lord%2520of%2520the%2520Rings%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-395-19395-8%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252022.99%250A%2520%2520%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520%255D%252C%250A%2520%2520%2520%2520%2522bicycle%2522%253A%2520%257B%250A%2520%2520%2520%2520%2520%2520%2522color%2522%253A%2520%2522red%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522price%2522%253A%2520399%250A%2520%2520%2520%2520%257D%250A%2520%2520%257D%250A%257D&o=0
  [ACL]: https://en.wikipedia.org/wiki/Access-control_list
    "Wikipedia: Access-control list"
  [`NewFixedModeTree`]: https://pkg.go.dev/github.com/theory/jsontree#NewFixedModeTree
    "github.com/theory/jsontree: NewFixedModeTree"
  [GitHub issues]: https://github.com/theory/jsontree/issues/ "theory/jsontree: Issues"
