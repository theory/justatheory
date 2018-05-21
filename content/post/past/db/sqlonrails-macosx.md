--- 
date: 2006-04-02T20:45:11Z
slug: sqlonrails-macosx
title: Patch for SQL on Rails for Mac OS X
aliases: [/computers/databases/sqlonrails_macosx.html]
tags: [databases, SQL On Rails, April Fool’s Day]
type: post
---

For those who have been having trouble getting [SQL on Rails] to build on Mac OS
X, I've just submitted this patch to address the issue:

``` patch
--- Makefile.old        2006-04-02 13:35:23.000000000 -0700
+++ Makefile    2006-04-02 13:34:54.000000000 -0700
@@ -1 +1,2 @@
+.PHONY: install
  install:
```

Hope this helps other folks out!

  [SQL on Rails]: http://www.sqlonrails.org/ "SQL on Rails: Taking the VC out of MVC"
