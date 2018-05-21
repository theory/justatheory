--- 
date: 2010-06-06T01:12:29Z
slug: atom-sources
title: Atom Sources
aliases: [/computers/internet/weblogs/atom-sources.html]
Tags: [Just a Theory, Atom, RSS, RSS2, source code, XML, feeds]
type: post
---

I'm working on a project where I aggregate entries from a slew of feeds into a
single feed. The output feed will be a valid [Atom] feed, and of course I want
to make sure that I maintain all the appropriate metadata for each entry I
collect. The [`<source>`] element seems to be exactly what I need:

> If an entry is copied from one feed into another feed, then the source feed’s
> metadata (all child elements of feed other than the entry elements) should be
> preserved if the source feed contains any of the child elements author,
> contributor, rights, or category and those child elements are not present in
> the source entry.
>
>     <source>
>       <id>http://example.org/</id>
>       <title>Fourty-Two</title>
>       <updated>2003-12-13T18:30:02Z</updated>
>       <rights>© 2005 Example, Inc.</rights>
>     </source>

That’s perfect: It allows me to keep the title, link, rights, and icon of the
originating blog associated with each entry.

Except, maybe it’s the [database expert] in me, but I'd like to be able to have
it be more normalized. My feed might have 1000 entries in it from 100 sources.
Why would I want to dupe that information for every single entry from a given
source? Is there now better way to do this, say to have the source data once,
and to reference the source ID only for each entry? That would make for a much
smaller feed, I expect, and a lot less duplication.

Is there any way to do this in an Atom feed?

  [Atom]: http://www.atomenabled.org/
  [`<source>`]: http://www.atomenabled.org/developers/syndication/#optionalEntryElements
  [database expert]: http://www.pgexperts.com/
