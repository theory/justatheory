--- 
date: 2008-01-22T01:22:09Z
slug: postgres-gem-on-leopard
title: Using sudo to Install the Postgres Gem on Leopard
aliases: [/computers/programming/ruby/postgres_gem_on_leopard.html]
tags: [Ruby, Ruby on Rails, macOS, Postgres]
type: post
---

Been getting this error with the latest postgres gem?

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

I have, too. I've known about the fix for a while, thanks to [a post from
maintainer Jeff Davis] from last month. But I was unable to get it to work. But
then I found this gem of a comment (pun not intended) from [Gluttonous][]:

> FYI, this does NOT work with sudo since sudo strips the env var out. You must
> ‘sudo -s’ or ‘sudo su’ and run the command straight up.

D'oh! I've been doing this all this time:

    ARCHFLAGS='-arch i386' sudo gem install postgres

And getting the same failures. But this works beautifully:

    sudo env ARCHFLAGS='-arch i386' gem install postgres

And away we go!

  [a post from maintainer Jeff Davis]: https://rubyforge.org/pipermail/ruby-pg-general/2007-December/000004.html
    "[Ruby-pg-general] osx leopard"
  [Gluttonous]: https://glu.ttono.us/articles/2007/12/22/postgresql-gem-on-leopard-stock-gem-system
    "Gluttonous: postgresql gem on Leopard stock gem system"
