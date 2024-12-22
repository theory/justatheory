---
title: Introducing RFC 9535 Go JSONPath and Playground
slug: go-jsonpath-playground
date: 2024-11-04T18:23:07Z
lastMod: 2024-11-04T18:23:07Z
description: |
  I've made a RFC 9535 JSONPath JSONPath Go package, and compiled it into Wasm to
  build an in-browser playground for it.
tags: [Go, JSONPath, Playground, RFC 9535]
type: post
---

I've written and release a [RFC 9535 JSONPath][RFC] JSONPath Go package,
[github.com/theory/jsonpath]. Why? For a personal project, I needed a simpler
JSONPath engine to complement to the [Go SQL/JSON Path] package, and quickly
found myself implementing most of the [RFC]. So I decided do the whole thing.

Yes, yet another JSONPath package in Go. I really appreciate the idea of a
standard --- plus its support for features not included in the [original
design] from 2007, [such as object slices][slices]! But I could find no
reference to the RFC on pkg.go.dev. Today [the search] shows one!

Example
-------

Usage is straightforward; here's a quick example ([Go playground]):

``` go
package main

import (
	"fmt"
	"log"

	"github.com/theory/jsonpath"
)

func main() {
	// Parse a jsonpath query.
	p, err := jsonpath.Parse(`$["name", "slogan"]`)
	if err != nil {
		log.Fatal(err)
	}

	// Select values from unmarshaled JSON input.
	json := map[string]any{
		"name":   "Kamala Harris",
		"title":  "Vice President of the United States",
		"home":   "California",
		"slogan": "We are not going back!",
	}
	items := p.Select(json)

	// Show the result.
	fmt.Printf("%#v\n", items)
}
```

And the output:

```go
[]interface {}{"Kamala Harris", "We are not going back!"}
```

🛝 Playground
-------------

No need to write code to try it out, though. I've also written a [playground
webapp] to encourage experimentation and exploration of the syntax and
behavior of the package. The implementation follows the precedents set by the
[Go SQL/JSON Playground] and design of the [Rust JSONPath Playground].
Moreover, thanks to [TinyGo], the [Wasm] file comes in at a mere 254K!

The webapp loads sample JSON from the [RFC], and randomly rotates through a
few example JSONPath queries. Fill in your own and tap the "Permalink" button
to share links. The Playground is a *stateless* JavaScript/Wasm web
application: data persists only in permalink URLs.[^github]

**🛝 Try this [example Playground permalink][slices] right now!**

Status
------

The root `jsonpath` package is stable and ready for use. Other packages remain
in flux, as I refactor and rejigger things in the coming weeks as part of the
aforementioned personal project. But for actual JSONPath execution and
querying, it should continue to work as-is for the foreseeable future.

I hope you find it useful.

  [^github]: And whatever data [GitHub Pages collect] 😔.

  [RFC]: https://www.rfc-editor.org/rfc/rfc9535.html
    "RFC 9535 JSONPath: Query Expressions for JSON"
  [github.com/theory/jsonpath]: https://pkg.go.dev/github.com/theory/jsonpath
  [Go SQL/JSON Path]: {{% ref "/post/postgres/go-sqljson-path" %}}
    "Introducing Go SQL/JSON Path and Playground"
  [original design]: https://goessner.net/articles/JsonPath/
    "Stefan Gössner: JSONPath - XPath for JSON"
  [slices]: https://theory.github.io/jsonpath/?p=%2524.store.book%255B%253F%2540.author%2520%253D%253D%2520%27Herman%2520Melville%27%255D%255B%27title%27%252C%2520%27author%27%252C%2520%27price%27%255D&j=%257B%250A%2520%2520%2522store%2522%253A%2520%257B%250A%2520%2520%2520%2520%2522book%2522%253A%2520%255B%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522reference%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Nigel%2520Rees%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sayings%2520of%2520the%2520Century%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.95%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Evelyn%2520Waugh%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Sword%2520of%2520Honour%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252012.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522Herman%2520Melville%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522Moby%2520Dick%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-553-21311-3%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%25208.99%250A%2520%2520%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522category%2522%253A%2520%2522fiction%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522author%2522%253A%2520%2522J.%2520R.%2520R.%2520Tolkien%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522title%2522%253A%2520%2522The%2520Lord%2520of%2520the%2520Rings%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522isbn%2522%253A%2520%25220-395-19395-8%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522price%2522%253A%252022.99%250A%2520%2520%2520%2520%2520%2520%257D%250A%2520%2520%2520%2520%255D%252C%250A%2520%2520%2520%2520%2522bicycle%2522%253A%2520%257B%250A%2520%2520%2520%2520%2520%2520%2522color%2522%253A%2520%2522red%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522price%2522%253A%2520399%250A%2520%2520%2520%2520%257D%250A%2520%2520%257D%250A%257D&o=1
  [the search]: https://pkg.go.dev/search?q=RFC+9535 "pkg.go.dev search: RFC 9535"
  [Go playground]: https://go.dev/play/p/wmJvZdOl28D
  [playground webapp]: https://theory.github.io/jsonpath/ "Go JSONPath Playground"
  [TinyGo]: https://tinygo.org/ "TinyGo - A Go Compiler For Small Places"
  [Wasm]: https://webassembly.org/ "WebAssembly"
  [Go SQL/JSON Playground]: https://theory.github.io/sqljson/playground/
  [Rust JSONPath Playground]: https://serdejsonpath.lives
