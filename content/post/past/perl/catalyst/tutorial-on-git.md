--- 
date: 2009-11-06T18:58:47Z
slug: tutorial-on-git
title: Tutorial on GitHub
aliases: [/computers/programming/perl/catalyst/tutorial-on-git.html]
tags: [Perl, Catalyst, Git, GitHub, Template::Declare, DBIx::Connector]
type: post
---

Following a very good [suggestion from Pedro Melo], I've created a Git
repository for this tutorial and put it [on GitHub]. I replayed each step,
making each into its own [commit], and tagged the state of the code for each
entry:

-   [Create Catalyst Views with Template::Declare]
-   [Catalyst with DBIx::Connector and Template::Declare]
-   [Create a Template::Declare Wrapper]
-   [My Catalyst Tutorial: Add Authors to the View]

So as I continue to make modifications, I'll keep this repository up-to-date,
and tag things as of each blog entry. This will make it easy for you to follow
along; you can simply clone [the repository] and `git pull` for each post.

More soon.

  [suggestion from Pedro Melo]: /computers/programming/perl/catalyst/sql-view-aggregate-magic.html#tb
    "My Catalyst Tutorial: Add Authors to the View—Comments"
  [on GitHub]: http://github.com/theory/catalyst-tutorial
    "Catalyst Tutorial on GitHub"
  [commit]: http://github.com/theory/catalyst-tutorial/commits/master
    "Commit History for Catalyst Tutorial"
  [Create Catalyst Views with Template::Declare]: http://github.com/theory/catalyst-tutorial/commits/part-01
  [Catalyst with DBIx::Connector and Template::Declare]: http://github.com/theory/catalyst-tutorial/commits/part-02
  [Create a Template::Declare Wrapper]: http://github.com/theory/catalyst-tutorial/commits/part-03
  [My Catalyst Tutorial: Add Authors to the View]: http://github.com/theory/catalyst-tutorial/commits/part-04
  [the repository]: git://github.com/theory/catalyst-tutorial.git
