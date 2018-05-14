--- 
date: 2010-06-06T01:12:29Z
slug: atom-sources
title: Atom Sources
aliases: [/computers/internet/weblogs/atom-sources.html]
tags: [Meta, Atom, RSS, RSS2, source code, XML, feeds]
type: post
---

<p>I'm working on a project where I aggregate entries from a slew of feeds into a single feed. The output feed will be a valid <a href="http://www.atomenabled.org/">Atom</a> feed, and of course I want to make sure that I maintain all the appropriate metadata for each entry I collect. The <a href="http://www.atomenabled.org/developers/syndication/#optionalEntryElements"><code>&lt;source&gt;</code></a> element seems to be exactly what I need:</p>

<blockquote><p>If an entry is copied from one feed into another feed, then the source feed’s metadata (all child elements of feed other than the entry elements) should be preserved if the source feed contains any of the child elements author, contributor, rights, or category and those child elements are not present in the source entry.</p>

<pre><code>&lt;source&gt;
  &lt;id&gt;http://example.org/&lt;/id&gt;
  &lt;title&gt;Fourty-Two&lt;/title&gt;
  &lt;updated&gt;2003-12-13T18:30:02Z&lt;/updated&gt;
  &lt;rights&gt;© 2005 Example, Inc.&lt;/rights&gt;
&lt;/source&gt;
</code></pre></blockquote>

<p>That’s perfect: It allows me to keep the title, link, rights, and icon of the originating blog associated with each entry.</p>

<p>Except, maybe it’s the <a href="http://www.pgexperts.com/">database expert</a> in me, but I'd like to be able to have it be more normalized. My feed might have 1000 entries in it from 100 sources. Why would I want to dupe that information for every single entry from a given source? Is there now better way to do this, say to have the source data once, and to reference the source ID only for each entry? That would make for a much smaller feed, I expect, and a lot less duplication.</p>

<p>Is there any way to do this in an Atom feed?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/internet/weblogs/atom-sources.html">old layout</a>.</small></p>


