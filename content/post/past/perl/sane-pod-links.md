--- 
date: 2010-01-16T19:36:39Z
slug: sane-perl-pod-links
title: "Pod: Now with Sane Web Links"
aliases: [/computers/programming/perl/sane-pod-links.html]
tags: [Perl, Pod, Documentation, URLs]
type: post
---

A couple months ago, [RJBS] and I collaborated on adding a new feature to Pod:
[sane URL links]. For, well, *ever*, the case has been that to link to URLs or
any other `scheme:` links in Pod, You had to do something like this:

``` perl
For more information, consult the pgTAP documentation:
L<https://pgtap.org/documentation.html>
```

The reasons why you couldn't include text in the link to server as the link text
has never been really well spelled-out. [Sean Burke], the most recent author of
the Pod spec, had only said that the support wasn't there "for various reasons."

Meanwhile, I accidentally discovered that Pod::Simple has in fact supported such
formats for a long time. At some point Sean added it, but didn't update the
spec. Maybe he thought it was fragile. I have no idea. But since the support was
already there, and most of the other Pod tools already support it or want to, it
was a simple change to make to the spec, and it was released in Perl 5.11.3 and
Pod::Simple 3.11. It's now officially a part of the spec. The above Pod can now
be written as:

``` perl
For more information, consult the
L<pgTAP documentation|https://pgtap.org/documentation.html>.
```

So much better! And to show it off, I've just updated all the links in
SVN::Notify and released a new version. Check it out on [CPAN Search]. See how
the links such as to "HookStart.exe" and "Windows Subversion + Apache +
TortoiseSVN + SVN::Notify HOWTO" are nice links? They no longer use the URL for
the link text. Contrast with the [previous version].

And as of yesterday, the last piece to allow this went into place. [Andy] gave
me maintenance of [Test::Pod], and I immediately released a new version to allow
the new syntax. So update your `t/pod.t` file to require Test::Pod 1.41, update
your links, and celebrate the arrival of sane links in Pod documentation.

  [RJBS]: http://rjbs.manxome.org/ "Ricardo Signes"
  [sane URL links]: http://perl5.git.perl.org/perl.git/commitdiff/f6e963e4dd62b8e3c01b31f4a4dd57e47e104997
    "Perl Git Commit f6e963e: remove prohibition against L<text|href>"
  [Sean Burke]: http://interglacial.com/~sburke/ "Sean M. Burke"
  [CPAN Search]: https://metacpan.org/pod/SVN::Notify
    "SVN::Notify on CPAN"
  [previous version]: https://metacpan.org/release/DWHEELER/SVN-Notify-2.79/view/lib/SVN/Notify.pm
    "SVN::Notify 2.79 on CPAN"
  [Andy]: http://petdance.com/ "Andy Lester"
  [Test::Pod]: https://metacpan.org/pod/Test::Pod "Test::Pod on CPAN"
