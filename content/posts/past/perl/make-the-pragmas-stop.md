--- 
date: 2009-12-15T23:06:27Z
slug: make-the-pragmas-stop
title: Make the Pragmas Stop!
aliases: [/computers/programming/perl/make-the-pragmas-stop.html]
tags: [Perl, Unicode, Perl 5 Porters]
---

<p>I've been following the development of a few things in the Perl community lately, and it’s leaving me very frustrated. For years now, I've written modules that start with the same incantation:</p>

<pre>package My::Module;

use strict;
our $VERSION = &#x0027;0.01&#x0027;;
</pre>

<p>Pretty simple: declare the module name and version, and turn on strictures to make sure I'm not doing anything stupid. More recently I've added <code>use warnings;</code> as a <a href="http://oreilly.com/catalog/9780596001735" title="âPerl Best Practicesâ by Master Damian Conway, Esq.">best practice</a>. And even more recently, I've started adding <code>use utf8;</code>, too, because I like to write my code in UTF-8. And I like to turn on all of the Perl 5.10 features. It’s mildly annoying to have the same incantation at the start of every module, but I could deal with it:</p>

<pre>package My::Module;

use strict;
use warnings;
use feature &#x0027;:5.10&#x0027;;
use utf8;

our $VERSION = &#x0027;0.01&#x0027;;
</pre>

<p>Until now that is. Last year, <a href="http://www.modernperlbooks.com/" title="Modern Perl Books">chromatic</a> started something with his <a href="http://search.cpan.org/perldoc?Modern::Perl" title="Modern::Perl on CPAN">Modern::Perl</a> module. It was a decent idea for newbies to help them get started with Perl by having to have only one declaration at the tops of their modules:</p>

<pre>package My::Module;

use Modern::Perl;
our $VERSION = &#x0027;0.01&#x0027;;
</pre>

<p>Alas, it wasn’t really designed for me, but for more casual users of Perl, so that they don’t have to think about the pragmas they need to use. The fact that it doesn’t include the <code>utf8</code> pragma also made it a non-starter for me. Or did it? Someone recently suggested that the <code>utf8</code> pragma has problems (I can’t find the Perl Monks thread at the moment). Others report that the <a href="http://search.cpan.org/perldoc?encoding" title="encoding pragma on CPAN">encoding pragma</a> has issues, too. So what’s the right thing to do with regard to assuming everything is UTF8 in my program and its inputs (unless I say otherwise)? I'm not at all sure.</p>

<p>Not only that, but Modern::Perl has lead to an explosion of other pragma-like modules on CPAN that promise best pragma practices. There’s <a href="http://search.cpan.org/perldoc?common::sense" title="common::sense on CPAN">common::sense</a>, which loads <code>utf8</code> but only some of of the features of <code>strict</code>, <code>warnings</code>, and <code>feature</code>. <a href="http://search.cpan.org/perldoc?uni::perl" title="uni::perl on CPAN">uni::perl</a> looks almost exactly the same. There’s also Damian Conwayâs <a href="http://search.cpan.org/perldoc?Toolkit" title="Toolkit on CPAN">Toolkit</a>, which allows you to write your own pragma-like loader module. There’s even <a href="http://search.cpan.org/perldoc?Acme::Very::Modern::Perl" title="Acme::Very::Modern::Perl on CPAN">Acme::Very::Modern::Perl</a>, which is meant to be a joke, but is it really?</p>

<p>If I want to simplify the incantation at the top of every file, what do I use?</p>

<p>And now it’s getting worse. In addition to <code>feature</code>, Perl 5.11 introduces the <code>legacy</code> pragma, which allows one to get back behaviors from older Perls. For example, to get back the old Unicode semantics, you'd <code>use legacy 'unicode8bit';</code>. I mean, WTF?</p>

<p>I've had it. Please make the pragma explosion stop! Make it so that the best practices known at the time of the release of any given version of Perl can automatically imported if I just write:</p>

<pre>package My::Module &#x0027;0.01&#x0027;;
use 5.12;
</pre>

<p>That’s it. Nothing more.  Whatever has been deemed the best practice at the time 5.12 is released will simply be used. If the best practices change in 5.14, I can switch to <code>use 5.14;</code> and get them, or just leave it at <code>use 5.12</code> and keep what was the best practices in 5.12 (yay future-proofing!).</p>

<p>What should the best practices be? My list would include:</p>

<ul>
<li><code>strict</code></li>
<li><code>warnings</code></li>
<li><code>features</code> — all of them</li>
<li><code>UTF-8</code> — all input and output to the scope, as well as the source code</li>
</ul>


<p>Maybe you disagree with that list. Maybe I'd disagree with what Perl 5 Porters settles on. But then you can I can read what’s included and just add or removed pragmas as necessary. But surely there’s a core list of likely candidates that should be included the vast majority of the time, including for all novices.</p>

<p>In personal communication, chromatic tells me, with regard to Modern::Perl, âExperienced Perl programmers know the right incantations to get the behavior they want. Novices don’t, and I think we can provide them much better defaults without several lines of incantations.â I'm fine with the second assertion, but disagree with the first. I've been hacking Perl for almost 15 years, and I no longer have any fucking idea what incantation is best to use in my modules. Do help the novices, and make the power tools available to experienced hackers, but please make life easier for the experienced hackers, too.</p>

<p>I think that declaring the semantics of a particular version of Perl is where the Perl 5 Porters are headed. I just hope that includes handling all of the likely pragmas too, so that I don’t have to.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/make-the-pragmas-stop.html">old layout</a>.</small></p>


