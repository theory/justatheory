--- 
date: 2006-05-04T23:13:30Z
slug: kinosearch
title: Search Powered by KinoSearch
aliases: [/computers/blog/kinosearch.html]
Tags: [Just a Theory, Kinosearch, Google, Lucene, Doug Cutting, Marvin Humphries]
type: post
---

On a whim yesterday, I decided to give [KinoSearch] a try. I've had the module
installed from CPAN for a while, so I can say that it installed very easily. So
then all I did was to cut and paste the sample programs from the [tutorial],
tweak a few things for my blog entries, and try it.

And lo and behold, it worked! After a mere 30 minutes work, it worked so well
that I was willing to spend the couple of hours it took this morning to get the
results nicely formatted wrapped in my Blosxom templates. So now this site is
fully indexed and searchable, and all I have to do is reindex it every time I
publish a new entry. So now the search field at the bottom of every page uses
KinoSearch, or you can just go to [the search page] to perform the search.
Sweet!

So give it a try. Search for [“iraq”] or [“svn”] to see how it works. And check
out those [KinoSearch benchmarks], too. This thing is fast!

  [KinoSearch]: http://www.rectangular.com/kinosearch/
    "KinoSearch: A Perl search engine library"
  [tutorial]: http://search.cpan.org/dist/KinoSearch/lib/KinoSearch/Docs/Tutorial.pod
    "KinoSearch::Docs::Tutorial - sample indexing and search applications"
  [the search page]: /search.cgi "Search Just a Theory"
  [“iraq”]: /search.cgi?q=iraq "Search for “iraq”"
  [“svn”]: /search.cgi?q=svn "Search for “svn”"
  [KinoSearch benchmarks]: http://www.rectangular.com/kinosearch/benchmarks.html
