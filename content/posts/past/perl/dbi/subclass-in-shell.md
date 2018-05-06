--- 
date: 2006-04-18T18:32:14Z
slug: subclass-in-shell
title: "Hack: Force DBI::Shell to use a DBI Subclass"
aliases: [/computers/programming/perl/dbi/subclass_in_shell.html]
tags: [Perl, DBI, DBI::Shell]
---

<p>So I just had a need to use DBI::Shell with a subclass of the DBI. It doesn't support subclasses directly (it'd be nice to be able to specify one on the command-line or something), but I was able to hack it into using one anyway by doing this:</p>

<pre>
use My::DBI;
BEGIN {
    sub DBI::Shell::Base::DBI () { &#x0027;My::DBI&#x0027; };
}
use DBI::Shell;
</pre>

<p>Yes, it's extremely sneaky. DBI::Shell::Base uses the string constant <code>DBI</code>, as in <code>DBI-&gt;connect(...)</code>, so by shoving a constant into DBI::Shell::Base before loading DBI::Shell, I convince it to use my subclass, instead.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/dbi/subclass_in_shell.html">old layout</a>.</small></p>


