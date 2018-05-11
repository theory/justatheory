--- 
date: 2010-01-16T19:36:39Z
slug: sane-pod-links
title: "Pod: Now with Sane Web Links"
aliases: [/computers/programming/perl/sane-pod-links.html]
tags: [Perl, Pod, documentation, URLs]
---

<p>A couple months ago, <a href="http://rjbs.manxome.org/" title="Ricardo Signes">RJBS</a> and I collaborated on adding a new feature to Pod: <a href="http://perl5.git.perl.org/perl.git/commitdiff/f6e963e4dd62b8e3c01b31f4a4dd57e47e104997" title="Perl Git Commit f6e963e: remove prohibition against L<text|href>">sane URL links</a>. For, well, <em>ever</em>, the case has been that to link to URLs or any other <code>scheme:</code> links in Pod, You had to do something like this:</p>

<pre>
For more information, consult the pgTAP documentation:
L&lt;http://pgtap.projects.postgresql.org/documentation.html&gt;
</pre>

<p>The reasons why you couldn't include text in the link to server as the link text has never been really well spelled-out. <a href="http://interglacial.com/~sburke/" title="Sean M. Burke">Sean Burke</a>, the most recent author of the Pod spec, had only said that the support wasn't there "for various reasons."</p>

<p>Meanwhile, I accidentally discovered that Pod::Simple has in fact supported such formats for a long time. At some point Sean added it, but didn't update the spec. Maybe he thought it was fragile. I have no idea. But since the support was already there, and most of the other Pod tools already support it or want to, it was a simple change to make to the spec, and it was released in Perl 5.11.3 and Pod::Simple 3.11. It's now officially a part of the spec. The above Pod can now be written as:</p>

<pre>
For more information, consult the L&lt;pgTAP
documentation|http://pgtap.projects.postgresql.org/documentation.html&gt;.
</pre>

<p>So much better! And to show it off, I've just updated all the links in SVN::Notify and released a new version. Check it out on <a href="http://search.cpan.org/perldoc?SVN::Notify" title="SVN::Notify on CPAN">CPAN Search</a>. See how the links such as to "HookStart.exe" and "Windows Subversion + Apache + TortoiseSVN + SVN::Notify HOWTO" are nice links? They no longer use the URL for the link text. Contrast with the <a href="http://search.cpan.org/~dwheeler/SVN-Notify-2.79/lib/SVN/Notify.pm" title="SVN::Notify 2.79 on CPAN">previous version</a>.</p>

<p>And as of yesterday, the last piece to allow this went into place. <a href="http://petdance.com/" title="Andy Lester">Andy</a> gave me maintenance of <a href="http://search.cpan.org/perldoc?Test::Pod" title="Test::Pod on CPAN">Test::Pod</a>, and I immediately released a new version to allow the new syntax. So update your <code>t/pod.t</code> file to require Test::Pod 1.41, update your links, and celebrate the arrival of sane links in Pod documentation.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/sane-pod-links.html">old layout</a>.</small></p>


