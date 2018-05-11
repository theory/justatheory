--- 
date: 2006-09-22T18:53:57Z
slug: gtin-0.01
title: "My First C: A GTIN Data Type for PostgreSQL"
aliases: [/computers/databases/postgresql/gtin-0.01.html]
tags: [Postgres, GTIN, data types, C, SQL, programming, EAN]
---

<p>After all of my recent experimentation creating <a href="/computers/databases/postgresql/plpgsql_upc_validation.html" title="Validating UPCs with PL/pgSQL">UPC</a>, <a href="/computers/databases/postgresql/ean_validation.html" title="Corrected PostgreSQL EAN Functions">EAN</a>, and <a href="/computers/programming/perl/stepped_series.html" title="Stepped Series of Numbers in Perl">GTIN</a> validation functions, I became interested in trying to create a GTIN PostgreSQL data type in C. The fact that I don't know C didn't stop me from learning enough to do some damage. And now I have a first implementation done. <a href="http://pgfoundry.org/frs/?group_id=1000229" title="Download the GTIN data type">Check it out!</a></p>

<p>So how did I do this? Well, chapter six of the <a href="https://www.amazon.com/exec/obidos/ASIN/0672327562/justatheory-20" title="&#x201c;PostgreSQL (2nd Edition)&#x201d; by Douglas and Douglas">Douglas Book</a> was a great help to get me started. I also learned what I could by reading the source code for the core and contributed PostgreSQL data types, as well as the EnumKit enumerated data type builder (<a href="http://developer.postgresql.org/~adunstan/" title="Andrew Dunstan at PostgreSQL.org">download from here</a>). And the denizens of the <code>#postgresql</code> channel on FreeNode were also extremely helpful. Thank you, guys!</p>

<p>I would be very grateful if the C hackers among you, and especially any PostgreSQL core hackers who happen to read my blog, would download the GTIN source code and have a look at it. This is the first C code I've written, so it would not surprise me if there were some gotchas that I missed (memory leaks, anyone?). And yes, I know that the new ISN contributed data types in the forthcoming 8.2 is a far more featureful implementation of bar code data types; I learned about it after I had nearly finished this first release of GTIN. But I did want to learn some C and how to create PostgreSQL data types, and provide the code for others to learn from, as well. It may also end up as the basis for an article. Stay tuned</p>

<p>In the meantime, share and enjoy.</p>

<p><strong>Update:</strong> I forgot to mention that you can check out the source code from the <a href="https://svn.kineticode.com/gtin/trunk/" title="The GTIN Subversion trunk"> Kineticode Subversion</a> repository.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/gtin-0.01.html">old layout</a>.</small></p>


