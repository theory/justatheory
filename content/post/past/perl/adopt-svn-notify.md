--- 
date: 2011-07-13T05:07:30Z
slug: adopt-svn-notify
title: "Up for Adoption: SVN::Notify"
aliases: [/computers/programming/perl/modules/adopt-svn-notify.html]
tags: [Perl, Subversion, SVN::Notify]
type: post
---

I’ve kept my various Perl modules in a Subversion server run by my Bricolage
support company, [Kineticode], for many years. However, I’m having to shut down
the server I’ve used for all my services, including Subversion, so I’ve moved
them all to [GitHub]. As such, I no longer use Subversion in my day-to-day work.

It no longer seems appropriate that I maintain [SVN::Notify]. This has probably
been my most popular modules, and I know that it’s used a *lot.* It’s also
relatively stable, with few bug reports or complaints. Nevertheless, there
certainly could be some things that folks want to add, like [TLS support],
[I18N], and [inline CSS].

Therefore, SVN::Notify is formally up for adoption. If you’re a Subversion
users, it’s a great tool. Just look at [this sample output]. If you’d like to
take over maintenance, make it even better, please get in touch. Leave a comment
on this post, or `@theory` me on [Twitter], or [send an email].

PS: Would love it if someone also could take over [activitymail], the CVS
notification script from which SVN::Notify was derived — and which I have even
*less* right to maintain, given that I haven’t used CVS in *years.*

  [Kineticode]: https://kineticode.com/
  [GitHub]: https://github.com/theory/
  [SVN::Notify]: http://search.cpan.org/dist/SVN-Notify/
  [TLS support]: https://rt.cpan.org/Ticket/Display.html?id=40188
  [I18N]: https://rt.cpan.org/Ticket/Display.html?id=51450
  [inline CSS]: https://rt.cpan.org/Ticket/Display.html?id=52121
  [this sample output]: /computers/programming/perl/modules/svnnotify-2.70_trac_example.html
  [Twitter]: https://twitter.com/
  [send an email]: http://search.cpan.org/~dwheeler/
  [activitymail]: http://search.cpan.org/dist/activitymail/
