--- 
date: 2004-10-08T00:54:09Z
slug: libreadline
title: Compiling libreadline on Mac OS X
aliases: [/computers/os/macosx/libreadline.html]
tags: [macOS, readline, Postgres]
type: post
---

I just realized that I never posted my recipe for configuring and installing
`libreadline` on Mac OS X. I need it for use with [PostgreSQL], and don't fully
understand why Apple has not yet included it with Mac OS X. Maybe it'll be in
Tiger?

In the meantime, it turns out to be pretty easy to configure it and build it
yourself, assuming you have the developer tools (“Xcode”) installed. The only
thing that's different from any other Unix is that the *support/shobj-conf* must
be modified to be able to find other libraries installed on Mac OS X. Here's a
shell script I whipped up that can do the whole thing for you, soup-to-nuts.

    #!/usr/bin/sh
    export VERSION=4.3
    curl -O ftp://ftp.gnu.org/pub/gnu/readline/readline-$VERSION.tar.gz
    tar zxvf readline-$VERSION.tar.gz
    cd readline-$VERSION
    perl -i.bak -p -e \
      "s/SHLIB_LIBS=.*/SHLIB_LIBS='-lSystem -lncurses -lcc_dynamic'/g" \
      support/shobj-conf
    ./configure
    make
    sudo make install

Hope that this helps others!

  [PostgreSQL]: http://www/postgresql.org/ "PostgreSQL Website"
