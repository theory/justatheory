--- 
date: 2008-01-22T01:22:09Z
slug: postgres-gem-on-leopard
title: Using sudo to Install the Postgres Gem on Leopard
aliases: [/computers/programming/ruby/postgres_gem_on_leopard.html]
tags: [Ruby, Ruby on Rails, macOS, Postgres]
---

<p>Been getting this error with the latest postgres gem?</p>

<pre>
% sudo gem install postgres
Bulk updating Gem source index for: http://gems.rubyforge.org
Building native extensions.  This could take a while...
ERROR:  While executing gem ... (Gem::Installer::ExtensionBuildError)
   ERROR: Failed to build gem native extension.

ruby extconf.rb install postgres
checking for main() in -lpq... yes
checking for libpq-fe.h... yes
checking for libpq/libpq-fs.h... yes
checking for PQsetClientEncoding()... no
checking for pg_encoding_to_char()... no
checking for PQfreemem()... no
checking for PQserverVersion()... no
checking for PQescapeString()... no
creating Makefile
</pre>

<p>I have, too. I've known about the fix for a while, thanks
to <a href="http://rubyforge.org/pipermail/ruby-pg-general/2007-December/000004.html" title="[Ruby-pg-general] osx leopard">a post from maintainer Jeff Davis</a>
from last month. But I was unable to get it to work. But then I found this gem
of a comment (pun not intended) from <a href="http://glu.ttono.us/articles/2007/12/22/postgresql-gem-on-leopard-stock-gem-system" title="Gluttonous: postgresql gem on Leopard stock gem system">Gluttonous</a>:</p>

<blockquote><p>FYI, this does NOT work with sudo since sudo strips the env var
out. You must ‘sudo -s’ or ‘sudo su’ and run the command straight
up.</p></blockquote>

<p>D'oh! I've been doing this all this time:</p>

<pre>
ARCHFLAGS=&#x0027;-arch i386&#x0027; sudo gem install postgres
</pre>

<p>And getting the same failures. But this works beautifully:</p>

<pre>
sudo env ARCHFLAGS=&#x0027;-arch i386&#x0027; gem install postgres
</pre>

<p>And away we go!</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/ruby/postgres_gem_on_leopard.html">old layout</a>.</small></p>


