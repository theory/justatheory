--- 
date: 2006-09-22T18:53:57Z
slug: gtin-0.01
title: "My First C: A GTIN Data Type for PostgreSQL"
aliases: [/computers/databases/postgresql/gtin-0.01.html]
tags: [Postgres, GTIN, data types, C, SQL, programming, EAN]
type: post
---

After all of my recent experimentation creating [UPC], [EAN], and [GTIN]
validation functions, I became interested in trying to create a GTIN PostgreSQL
data type in C. The fact that I don't know C didn't stop me from learning enough
to do some damage. And now I have a first implementation done. [Check it out!]

So how did I do this? Well, chapter six of the [Douglas Book] was a great help
to get me started. I also learned what I could by reading the source code for
the core and contributed PostgreSQL data types, as well as the EnumKit
enumerated data type builder ([download from here]). And the denizens of the
`#postgresql` channel on FreeNode were also extremely helpful. Thank you, guys!

I would be very grateful if the C hackers among you, and especially any
PostgreSQL core hackers who happen to read my blog, would download the GTIN
source code and have a look at it. This is the first C code I've written, so it
would not surprise me if there were some gotchas that I missed (memory leaks,
anyone?). And yes, I know that the new ISN contributed data types in the
forthcoming 8.2 is a far more featureful implementation of bar code data types;
I learned about it after I had nearly finished this first release of GTIN. But I
did want to learn some C and how to create PostgreSQL data types, and provide
the code for others to learn from, as well. It may also end up as the basis for
an article. Stay tuned

In the meantime, share and enjoy.

**Update:** I forgot to mention that you can check out the source code from the
[Kineticode Subversion] repository.

  [UPC]: /computers/databases/postgresql/plpgsql_upc_validation.html
    "Validating UPCs with PL/pgSQL"
  [EAN]: /computers/databases/postgresql/ean_validation.html
    "Corrected PostgreSQL EAN Functions"
  [GTIN]: /computers/programming/perl/stepped_series.html
    "Stepped Series of Numbers in Perl"
  [Check it out!]: http://pgfoundry.org/frs/?group_id=1000229
    "Download the GTIN data type"
  [Douglas Book]: https://www.amazon.com/exec/obidos/ASIN/0672327562/justatheory-20
    "“PostgreSQL (2nd Edition)” by Douglas and Douglas"
  [download from here]: http://developer.postgresql.org/~adunstan/
    "Andrew Dunstan at PostgreSQL.org"
  [Kineticode Subversion]: https://svn.kineticode.com/gtin/trunk/
    "The GTIN Subversion trunk"
