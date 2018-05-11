--- 
date: 2004-10-08T00:54:09Z
slug: libreadline
title: Compiling libreadline on Mac OS X
aliases: [/computers/os/macosx/libreadline.html]
tags: [macOS, readline, Postgres]
---

<p>I just realized that I never posted my recipe for configuring and installing <code>libreadline</code> on Mac OS X. I need it for use with <a href="http://www/postgresql.org/" title="PostgreSQL Website">PostgreSQL</a>, and don't fully understand why Apple has not yet included it with Mac OS X. Maybe it'll be in Tiger?</p>

<p>In the meantime, it turns out to be pretty easy to configure it and build it yourself, assuming you have the developer tools (<q>Xcode</q>) installed. The only thing that's different from any other Unix is that the <em>support/shobj-conf</em> must be modified to be able to find other libraries installed on Mac OS X. Here's a shell script I whipped up that can do the whole thing for you, soup-to-nuts.</p>

<pre>
#!/usr/bin/sh
export VERSION=4.3
curl -O ftp://ftp.gnu.org/pub/gnu/readline/readline-$VERSION.tar.gz
tar zxvf readline-$VERSION.tar.gz
cd readline-$VERSION
perl -i.bak -p -e \
  &quot;s/SHLIB_LIBS=.*/SHLIB_LIBS=&#x0027;-lSystem -lncurses -lcc_dynamic&#x0027;/g&quot; \
  support/shobj-conf
./configure
make
sudo make install
</pre>

<p>Hope that this helps others!</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/os/macosx/libreadline.html">old layout</a>.</small></p>


