---
title: Introducing Go SQL/JSON Path and Playground
slug: go-sqljson-path
date: 2024-07-08T13:59:10Z
lastMod: 2024-07-08T13:59:10Z
description: |
  Introducing the SQL/JSON Path package, a PostgresSQL-compatible jsonpath
  parser and executor in Go. Also: a Wasm-based playground!
tags: [Postgres, SQL/JSON, JSON Path, Go, Playground]
type: post
---

For a personal project, I needed to parse and execute PostgreSQL-compatible
[jsonpath] expressions.[^why] So I've spent just about every spare evening and
weekend the last several months porting Postgres jsonpath to Go, and it's
finally ready to ship.

Introducing [Go SQL/JSON], featuring the [path package]. This project provides
full support for all of the PostgresSQL 17 jsonpath features[^nearly] in the
Go programming language. An [example]:

``` go
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/theory/sqljson/path"
	"github.com/theory/sqljson/path/exec"
)

func main() {
	// Parse some JSON.
	var value any
	err := json.Unmarshal([]byte(`{"a":[1,2,3,4,5]}`), &value)
	if err != nil {
		log.Fatal(err)
	}

	// Parse a path expression and execute it on the JSON.
	p := path.MustParse("$.a[*] ? (@ >= $min && @ <= $max)")
	res, err := p.Query(
		context.Background(),
		value,
		exec.WithVars(exec.Vars{"min": float64(2), "max": float64(4)}),
	)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%v\n", res)
    // Output: [2 3 4]
}
```

I think the API is decent, but may implement better patterns as I discover
them. Overall I'm quite satisfied with how it turned out, and just how well
its implementation and performance compare to the original.

🛝 Playground
-------------

But why stop there? One of the nice things about this project is that Go
supports compiling applications into [WebAssembly] (a.k.a. Wasm) via [Go
WebAssembly]. Borrowing from the [Goldmark] project, I created and published
the [sqljson/path playground] and populated [the docs] with links for all of
its examples.

Now anyone can experiment with SQL/JSON path expressions, and share links to
demonstrate patterns and techniques. The Playground is a *stateless*
JavaScript/Wasm web application: data persists only in permalink
URLs.[^github]

**🛝 Try this [example Playground permalink] right now!**[^mdm]

The Path Ahead
--------------

I've enjoyed learning how to implement a lexer, a [goyacc] parser, an [AST],
and an execution engine. The Playground was a bonus bit of fun!

I'm stoked to build cool stuff on this package, but don't know whether anyone
else will find it useful. If you do --- or just enjoy messing about on the
Playground, let me know!

  [^why]: "Whatever for," you ask? Well, aside from wanting to see if I could
    do it, [this post] describes a POC. Now I'm working to create the real
    thing --- done right and entirely from scratch.
  [^nearly]: Well, nearly full. The only [missing] feature is the
    `datetime(template)` method. See also the comprehensive [compatibility
    notes].
  [^github]: And whatever data [GitHub Pages collect] 😔.
  [^mdm]: JSON [borrowed from MDM].

  [jsonpath]: https://www.postgresql.org/docs/16/datatype-json.html#DATATYPE-JSONPATH
    "PostgreSQL Docs: jsonpath Type"
  [this post]: {{% ref "/post/postgres/cipherdoc" %}}
    "CipherDoc: A Searchable, Encrypted JSON Document Service on Postgres"
  [Go SQL/JSON]: https://github.com/theory/sqljson
    "theory/gosqljson: PostgreSQL-compatible SQL-standard SQL/JSON in Go"
  [path package]: https://pkg.go.dev/github.com/theory/sqljson/path
    "go.pkg.dev: github.com/theory/sqljson/path"
  [missing]: https://github.com/theory/sqljson/issues/1
    "/theory/sqljson#1: Implement datetime(template)"
  [compatibility notes]: https://github.com/theory/sqljson/blob/main/path/README.md#compatibility
  [example]: https://pkg.go.dev/github.com/theory/sqljson/path#example-package-WithVars
  [WebAssembly]: https://webassembly.org
  [Go WebAssembly]: https://go.dev/wiki/WebAssembly "Go Wiki: WebAssembly"
  [Goldmark]: https://github.com/yuin/goldmark/ 
    "yuin/goldmark: 🏆 A markdown parser written in Go"
  [sqljson/path playground]: https://theory.github.io/sqljson/playground
  [the docs]: https://github.com/theory/sqljson/blob/main/path/README.md
    "Go SQL/JSON Path: The SQL/JSON Path Language"
  [example Playground permalink]: https://theory.github.io/sqljson/playground/?p=%2524.members%255B*%255D%2520%253F%28%2540.age%2520%253C%252030%2520%257C%257C%2520exists%28%2540.powers%255B*%255D%2520%253F%28%2520%2540%2520%253D%253D%2520%2522Inferno%2522%29%29%29.name&j=%257B%250A%2520%2520%2522squadName%2522%253A%2520%2522Super%2520hero%2520squad%2522%252C%250A%2520%2520%2522homeTown%2522%253A%2520%2522Metro%2520City%2522%252C%250A%2520%2520%2522formed%2522%253A%25202016%252C%250A%2520%2520%2522secretBase%2522%253A%2520%2522Super%2520tower%2522%252C%250A%2520%2520%2522active%2522%253A%2520true%252C%250A%2520%2520%2522members%2522%253A%2520%255B%250A%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2522name%2522%253A%2520%2522Molecule%2520Man%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522age%2522%253A%252029%252C%250A%2520%2520%2520%2520%2520%2520%2522secretIdentity%2522%253A%2520%2522Dan%2520Jukes%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522powers%2522%253A%2520%255B%2522Radiation%2520resistance%2522%252C%2520%2522Turning%2520tiny%2522%252C%2520%2522Radiation%2520blast%2522%255D%250A%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2522name%2522%253A%2520%2522Madame%2520Uppercut%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522age%2522%253A%252039%252C%250A%2520%2520%2520%2520%2520%2520%2522secretIdentity%2522%253A%2520%2522Jane%2520Wilson%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522powers%2522%253A%2520%255B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Million%2520tonne%2520punch%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Damage%2520resistance%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Superhuman%2520reflexes%2522%250A%2520%2520%2520%2520%2520%2520%255D%250A%2520%2520%2520%2520%257D%252C%250A%2520%2520%2520%2520%257B%250A%2520%2520%2520%2520%2520%2520%2522name%2522%253A%2520%2522Eternal%2520Flame%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522age%2522%253A%25201000000%252C%250A%2520%2520%2520%2520%2520%2520%2522secretIdentity%2522%253A%2520%2522Unknown%2522%252C%250A%2520%2520%2520%2520%2520%2520%2522powers%2522%253A%2520%255B%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Immortality%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Heat%2520Immunity%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Inferno%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Teleportation%2522%252C%250A%2520%2520%2520%2520%2520%2520%2520%2520%2522Interdimensional%2520travel%2522%250A%2520%2520%2520%2520%2520%2520%255D%250A%2520%2520%2520%2520%257D%250A%2520%2520%255D%250A%257D%250A&a=&o=1
  [borrowed from MDM]: https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Objects/JSON
    "MDN Web Docs: Working with JSON"
  [GitHub Pages collect]: https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages#data-collection
    "Github Docs: About GitHub Pages — Data Collection"
  [goyacc]: https://pkg.go.dev/golang.org/x/tools/cmd/goyacc
    "pkg.go.dev: golang.org/x/tools/cmd/goyacc"    
  [AST]: https://en.wikipedia.org/wiki/Abstract_syntax_tree
    "Wikipedia: Abstract syntax tree"
