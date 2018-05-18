--- 
date: 2010-03-15T18:33:18Z
description: I'm tired of having to remember to set USE_PGXS=1 when building third-party PostgreSQL extensions like pgTAP. Aren’t you?
slug: no-more-use-pgxs
title: No more USE_PGXS=1?
aliases: [/computers/databases/postgresql/no_more_use_pgxs.html]
tags: [Postgres, Makefile]
type: post
---

<p>I've become very tired of having to set <code>USE_PGXS=1</code> every time I build pgTAP outside the <code>contrib</code> directory of a PostgreSQL distribution:</p>

<pre><code>make USE_PGXS=1
make USE_PGXS=1 install
make USE_PGXS=1 installcheck
</code></pre>

<p>I am forever forgetting to set it, and it’s just not how one normally expects
a build incantation to work. It was required because that’s how the core
<a href="http://www.postgresql.org/docs/8.4/static/contrib.html" title="PostgreSQL Documentation: “Additional Supplied Modules”">contrib extensions</a> work: They all have
this code in their <code>Makefile</code>s, which those of us who develop third-party
modules have borrowed:</p>

<pre><code>ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/citext
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
</code></pre>

<p>They generally expect <code>../../src/Makefile.global</code> to exist, and if it doesn’t,
you have to tell it so. I find this annoying, because third-party extensions
are almost never built from the <code>contrib</code> directory, so one must always remember to specify <code>USE_PGXS=1</code>.</p>

<p>I'd like to propose, instead, that those of us who maintain third-party extensions like <a href="http://pgtap.org">pgTAP</a>, <a href="http://github.com/leto/plparrot/">PL/Parrot</a>, and <a href="http://temporal.projects.postgresql.org/">Temporal PostgreSQL</a> not force our users to have to remember this special variable by instead checking to see if it’s needed ourselves. As such, I've just <a href="http://github.com/theory/pgtap/commit/400db6d2db7ebabb90fbc528100bb9e518f7fbc3">added</a> this code to pgTAP’s <code>Makefile</code>:</p>

<pre><code>ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
else
ifeq (exists, $(shell [ -e ../../src/bin/pg_config/pg_config ] &amp;&amp; echo exists) ) 
top_builddir = ../..
PG_CONFIG := $(top_builddir)/src/bin/pg_config/pg_config
else
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
endif
endif
</code></pre>

<p>So it still respects <code>USE_PGXS=1</code>, but if it’s not set, it looks to see if it
can find <code>pg_config</code> where it would expect it to be if built from the
<code>contrib</code> directory. If it’s not there, it simply uses <code>pg_config</code> as if
<code>USE_PGXS=1</code> was set. This makes building from the <code>contrib</code> directory or from
anywhere else the same process:</p>

<pre><code>make
make install
make installcheck
</code></pre>

<p>Much better, much easier to remember.</p>

<p>Is there any reason why third-party PostgreSQL extensions should <em>not</em> adopt this pattern? I don’t think it makes sense for contrib extensions in core to do it, but for those that will never be in core, I think it makes a lot of sense.</p>

<p>Comments?</p>
