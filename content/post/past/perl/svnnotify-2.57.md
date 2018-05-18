--- 
date: 2006-04-06T23:08:12Z
slug: svnnotify-2.57
title: SVN::Notify 2.57 Supports Windows
aliases: [/computers/programming/perl/modules/svnnotify-2.57.html]
tags: [Perl, Subversion, SVN::Notify, Windows]
type: post
---

<p>So I finally got 'round to porting <a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">SVN::Notify</a> to Windows. Version 2.57 is making is way to CPAN right now. The solution turned out to be dead simple: I just had to use a different form of piping <code>open()</code> on Windows, i.e., <code>open FH, &quot;$cmd|&quot;</code> instead of <code>open FH, &quot;-|&quot;; exec($cmd);</code>. It's silly, really, but it works. It really makes me wonder why <code>-|</code> and <code>|-</code> haven't been emulated on Windows. Whatever.</p>

<p>'Course the other thing I realized, after I made this change and all the tests pass, was that there is no equivalent of <em>sendmail</em> on Windows. So I added the <code>--smtp</code> option, so that now email can be sent to an SMTP server rather than to a local <em>sendmail</em>. I tested it out, and it seems to work, but I'd be especially interested to hear from folks using wide characters in their repositories: do they get printed properly to Net::SMTP's connection?</p>

<p>The whole list of changes in 2.57 (the output remains the same as in <a href="http://www.justatheory.com/computers/programming/perl/modules/svnnotify-2.56_colordiff_example.html" title="Example output from SVN::Notify 2.56">2.56</a>):</p>

<ul>
      <li>Finally ported to Win32. It was actually a simple matter of changing
        how command pipes are created.</li>
      <li>Added <code>--smtp</code> option to enable sending messages to an SMTP server
        rather than to the local <em>sendmail</em> application. This is essential for
        Windows support.</li>
      <li>Added <code>--io-layer</code> to the usage statement in <em>svnnotify</em>.</li>
      <li>Fixed single-dash arguments in documentation so that they're all
        documented with a single dash in SVN::Notify.</li>
</ul>

<p>Enjoy!</p>
