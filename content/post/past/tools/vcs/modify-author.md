--- 
date: 2008-04-10T20:33:55Z
lastMod: 2022-05-22T21:36:50Z
slug: svn-modify-author
title: How to Globally Change a Subversion Username
aliases: [/computers/vcs/svn/modify_author.html]
tags: [Subversion]
type: post
---

I successfully migrated the Kineticode Subversion repository to a new server
yesterday. Everything works great. But after my first commit, I realized that,
while my username on the old server was “theory,” on the new server it's
“david”. Subversion works fine, of course, and I was able to start committing
from old checkouts using the new username, but I realized that sites like
[Ohloh] would pick up the two usernames as separate usernames. So I wanted to
update all of the 3630 existing revisions that were mine to use the new
username.

Unfortunately, I couldn't find much on how to do this in a quick Googling. But I
quickly figured out that what I need to do was to `svnadmin dump` my repository,
modify the dump, and then load it again. The Subversion dump format has all
these fields for tracking the content-lengths of various, so doing the update
was a bit tricky. But I wrote the script here to track things, and it worked
great for me. So here it is for others to reference and use.

``` perl
#!/usr/bin/perl -w

use strict;
use warnings;

while (<>) {
    print;
    next unless /^Revision-number:\s+\d+$/;

    # Grab the content lengths. Examples:
    # Prop-content-length: 139
    # Content-length: 139
    my $plen_line = <>;
    my $clen_line = <>;

    unless ( $plen_line =~ /^Prop-content-length:\s+\d+$/ ) {
        # Nothing we want to change.
        print $plen_line, $clen_line;
        next;
    }

    my @lines;
    while ( <> ) {
        if ( /^PROPS-END$/ ) {
            # finish.
            print $plen_line, $clen_line, @lines, $_;
            last;
        }

        push @lines, $_;

        if ( /^svn:author$/ ) {
            # Grab the author content length. Example:
            # V 6
            my $alen_line = <>;

            # Grab the author name.
            my $auth = <>;

            if ( $auth =~ s/^theory$/david/ ) {
                # Adjust the content lengths.
                for my $line ( $plen_line, $clen_line, $alen_line ) {
                    $line =~ s/(\d+)$/$1 - 1/e;
                }
            }
            print $plen_line, $clen_line, @lines, $alen_line, $auth;
            last;
        }
    }
}
```

To use it, save it to a file, say *svn\_author*, then change line 40 to your old
and new usernames. Then, on line 43, change the `$1 - 1` bit to be correct for
the difference between the usernames you're changing. For example, if you're
changing your username from, say, “shane” to “chromatic,” the new name is five
characters longer, so you'd make it `$1 + 5`.

Now, run it like so:

``` sh
svnadmin dump /path/to/svnroot > svndump.out
perl svn_author svndump.out > svndump.in
svnadmin create /path/to/new/svnroot
svnadmin load /path/to/new/svnroot < svndump.in
```

And that's it! Feel free to take this code and do with it what you like,
including fix any bugs, add command-line options, support changing multiple
authors at once, or whatever. Share and enjoy.

  [Ohloh]: https://web.archive.org/web/20100106064341/http://www.ohloh.net/
    "ohloh, the open source network"
