--- 
date: 2006-04-02T20:45:11Z
slug: sqlonrails-macosx
title: Patch for SQL on Rails for Mac OS X
aliases: [/computers/databases/sqlonrails_macosx.html]
tags: [databases, SQL On Rails, April Fool’s Day]
type: post
---

<p>For those who have been having trouble getting <a href="http://www.sqlonrails.org/" title="SQL on Rails: Taking the VC out of MVC">SQL on Rails</a> to build on Mac OS X, I've just submitted this patch to address the issue:</p>

<pre>
--- Makefile.old        2006-04-02 13:35:23.000000000 -0700
+++ Makefile    2006-04-02 13:34:54.000000000 -0700
@@ -1 +1,2 @@
+.PHONY: install
 install:
</pre>

<p>Hope this helps other folks out!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqlonrails_macosx.html">old layout</a>.</small></p>


