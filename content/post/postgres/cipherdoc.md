---
title: "CipherDoc: A Searchable, Encrypted JSON Document Service on Postgres"
slug: cipherdoc
date: 2023-10-01T21:36:13Z
lastMod: 2023-10-01T21:36:13Z
description: I gave a talk at PGCon this year on a privacy-first data storage service I designed and implemented. Perhaps the encryption and searching patterns will inspire others.
tags: [Postgres, PGCon, CipherDoc, Privacy, Encryption]
type: post
---

Over the last year, I designed and implemented a simple web service, code-named
"CipherDoc", that provides a [CRUD] API for creating, updating, searching, and
deleting [JSON] documents. The app enforces document structure via [JSON
schema], while [JSON/SQL Path] powers the search API by querying a hashed subset
of the schema stored in a [GIN-indexed] [JSONB] column in [Postgres].

In may I gave a public presentation on the design and implementation of the
service at [PGCon]: *CipherDoc: A Searchable, Encrypted JSON Document Service on
Postgres*. Links:

*   [Description]
*   [Slides]
*   [Video]

I enjoyed designing this service. The ability to dynamically change the JSON
schema at runtime without database changes enables more agile development cycles
for busy teams. Its data privacy features required a level of intellectual
challenge and raw problem-solving (a.k.a., *engineering*) that challenge and
invigorate me.

Two minor updates since May:

1.  I re-implemented the [JSON/SQL Path] parser using the original Postgres
    [path grammar], replacing the hand-written parser roundly castigated in the
    presentation.
2.  The service has yet to be open-sourced, but I remain optimistic, and
    continue to work with leadership at *The Times* towards an open-source
    policy to enable its release.

  [CRUD]: https://en.wikipedia.org/wiki/Create,_read,_update_and_delete
    "Wikipedia: “Create, read, update, and delete”"
  [JSON]: https://json.org "ECMA-404 The JSON Data Interchange Standard"
  [JSON schema]: https://json-schema.org
    "JSON Schema is a declarative language that allows you to annotate and validate JSON documents"
  [JSON/SQL Path]: https://www.postgresql.org/docs/12/datatype-json.html#DATATYPE-JSONPATH
    "PostgreSQL Docs: jsonpath Type"
  [GIN-indexed]: https://www.postgresql.org/docs/current/gin.html
    "PostgreSQL Docs: GIN Indexes"
  [JSONB]: https://www.postgresql.org/docs/current/datatype-json.html
    "PostgresSQL Docs: JSON Types"
  [Postgres]: https://www.postgresql.org/
    "PostgreSQL: The World's Most Advanced Open Source Relational Database"
  [PGCon]: https://www.pgcon.org/ "PGCon - PostgreSQL Conference for Users and Developers"
  [Description]: https://www.pgcon.org/events/pgcon_2023/schedule/session/360-a-pattern-for-a-searchable-encrypted-json-document-service/
    "PGCon 2023 — CipherDoc: A Searchable, Encrypted JSON Document Service on Postgres"
  [Slides]: https://www.pgcon.org/events/pgcon_2023/sessions/session/360/slides/73/cipher-doc.pdf
  [Video]: https://www.youtube.com/watch?v=SUyHnjpr-0Q
    "CipherDoc: A Pattern for a Searchable, Encrypted JSON Document Service: David E Wheeler - PGCon 2023"
  [path grammar]: https://github.com/postgres/postgres/blob/REL_15_4/src/backend/utils/adt/jsonpath_gram.y
    "jsonpath_gram.y: Grammar definitions for jsonpath datatype"
