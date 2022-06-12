--- 
date: 2004-10-09T22:54:00Z
lastMod: 2022-06-12T22:42:22Z
slug: svnnotify-2.20
title: SVN::Notify 2.20 Adds Colorized Diffs
aliases: [/computers/programming/perl/modules/svnnotify_2.20.html]
tags: [Perl, Subversion, CVSspam, SVN::Notify, diffs, Color, HTML]
type: post
---

After getting prodded by [Erik Hatcher], I went ahead and added another subclass
to SVN::Notify. This one adds a pretty colorized diff to the message, instead of
just the plain text one. See an example [here]. I've also added links from the
lists of affected files into the diffs in the HTML and new HTML::ColorDiff
layouts.

Enjoy!

**Update:** And now I've released SVN::Notify 2.21 with a few minor fixes,
including XHTML 1.1 compliance.

  [Erik Hatcher]: https://web.archive.org/web/20041102032812/http://www.blogscene.org/erik/
    "Erik Hatcher - Blog"
  [here]: {{% link "/code/svnnotify/svnnotify_colordiff_example.html" %}}
    "SVN::Notify::HTML::ColorDiff example"
