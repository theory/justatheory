--- 
date: 2005-11-30T02:02:53Z
slug: howto-avoid-tigers-readline
title: How Do I Avoid Tiger's readline When Compiling PostgreSQL?
aliases: [/computers/databases/postgresql/howto_avoid_tigers_readline.html]
tags: [Postgres, readline, psql, segfaults, history]
---

<p>I was delighted to find that Mac OS X 10.4 <q>Tiger</q> includes the readline library. So I was able to just compile PostgreSQL and have <em>psql</em> just work. Only it kinda doesn't. For reasons that Tom Lane <a href="http://archives.postgresql.org/pgsql-hackers/2005-08/msg01013.php" title="Tom Lane explains why Tiger's readline library causes a segfualt or error on exiting psql">has explained</a>, Tiger's readline implementation is somewhat buggy. I've reported the issue to <a href="http://bugreporter.apple.com/" title="Apple Bug Reporter">Apple</a> (Radar # 4356545), but in the meantime, I've compiled and installed GNU readline 5.0 and wan to use it, instead.</p>

<p>The only problem is that there is no easy way to do it with environment variables or options when configuring PostgreSQL. I've tried:</p>

<pre>
./configure &#x002d;-includes=/usr/local/include &#x002d;with-libs=/usr/local/lib
</pre>

<p>And:</p>

<pre>
CFLAGS=-L/usr/local/lib LDFLAGS=-I/usr/local/include; ./configure
</pre>

<p>Neither approach worked. In both cases, it still compiled in Apple's buggy readline library. The only approach I've found to work is the brute force approach:</p>

<pre>
mv /usr/lib/libreadline.* /tmp
mv /usr/include/readline /tmp
./configure
make
make install
mv /tmp/libreadline.* /usr/lib
mv /tmp/readline /usr/include
</pre>

<p>But surely I'm missing something! Is there no better way to do it?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/howto_avoid_tigers_readline.html">old layout</a>.</small></p>


