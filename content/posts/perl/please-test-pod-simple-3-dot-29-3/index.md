--- 
date: 2015-02-11T10:53:00Z
title: Please Test Pod::Simple 3.29_3
aliases: [/2015/02/11/please-test-pod-simple-3-dot-29-3/]
tags: [Perl, Sean Burke, Karl Williamson, Pod]
topics: [Perl]
---

{{% figure src="/2015/02/please-test-podsimple-3.29_3/cpan.png" class="left" width="250" alt="Pod Book" %}}

I've just pushed [Pod-Simple] 3.29_v3 to CPAN. [Karl Williamson] did a lot of
hacking on this release, finally adding support for EBCDIC. But as part of
that work, and in coordination with Pod::Simple's original author,
[Sean Burke], as well as [pod-people], we have switched the default encoding
from [Latin-1] to [CP-1252].

On the surface, that might sound like a big change, but in truth, it's pretty
straight-forward. CP-1252 is effectively a superset of Latin-1, repurposing
30 or so unused control characters from Latin-1. Those characters are pretty
common on Windows (the home of the CP family of encodings), especially in
pastes from Word. It's nice to be able to pick those up essentially for free.

Still, Karl's done more than that. He also updated the encoding detection to
do a better job at detecting UTF-8. This is the *real* default. Pod::Simple
only falls back on CP1252 if there are no obvious UTF-8 byte sequences in
your Pod.

Overall these changes should be a great improvement. Better encoding support
is always a good idea. But it is a pretty significant change, including a
change to [the Pod spec]. Hence the test release. Please make sure it works
well with your code by installing it today:

``` sh
cpan D/DW/DWHEELER/Pod-Simple-3.29_3.tar.gz
cpanm DWHEELER/Pod-Simple-3.29_3.tar.gz
```

Oh, and one last thing: If Pod::Simple fails to properly recognize the encoding in your Pod file, you can always use the `=encoding` command early in your Pod file to make it explicit:

``` perl
=encoding CP1254
```

[Pod-Simple]: https://metacpan.org/release/Pod-Simple/
[Karl Williamson]: https://metacpan.org/author/KHW
[Sean Burke]: http://interglacial.com/
[pod-people]: http://lists.perl.org/list/pod-people.html
[Latin-1]: http://en.wikipedia.org/wiki/ISO/IEC_8859-1
[CP-1252]: http://en.wikipedia.org/wiki/Windows-1252
[the Pod spec]: https://metacpan.org/pod/distribution/perl/pod/perlpodspec.pod
