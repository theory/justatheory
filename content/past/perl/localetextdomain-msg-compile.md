--- 
date: 2013-01-08T23:36:51Z
slug: localetextdomain-msg-compile
title: Dist::Zilla::LocaleTextDomain for Translators
aliases: [/computers/programming/perl/modules/localetextdomain-msg-compile.html]
tags: [Perl, translation, localization, internationalization]
type: post
---

<p>Here’s a followup on my post about <a href="/computers/programming/perl/modules/dist-zilla-localetextdomain.html">localizing Perl modules with Locale::TextDomain</a>. <a href="https://metacpan.org/module/Dist::Zilla::LocaleTextDomain">Dist::Zilla::LocaleTextDomain</a> was great for developers, less so for translators. A <a href="http://sqitch.org/" title="Sqitch: Sane database change management">Sqitch</a> translator asked how to test the translation file he was working on. My only reply was to compile the whole module, then install it and test it. Ugh.</p>

<p>Today, I released <a href="https://metacpan.org/module/Dist::Zilla::LocaleTextDomain">Dist::Zilla::LocaleTextDomain v0.85</a> with a new command, <a href="https://metacpan.org/module/Dist::Zilla::App::Command::msg_compile"><code>msg-compile</code></a>. This command allows translators to easily compile just the file they’re working on and nothing else. For pure Perl modules in particular, it’s pretty easy to test then. By default, the compiled catalog goes into <code>./LocaleData</code>, where convincing the module to find it is simple. For example, I updated the <a href="https://github.com/theory/sqitch/blob/master/t/sqitch">test <code>sqitch</code> app</a> to take advantage of this. Now, to test, say, the French translation file, all the translator has to do is:</p>

<pre><code>&gt; dzil msg-compile po/fr.po
[LocaleTextDomain] po/fr.po: 155 translated messages, 24 fuzzy translations, 16 untranslated messages.

&gt; LANGUAGE=fr ./t/sqitch foo
"foo" n'est pas une commande valide
</code></pre>

<p>I hope this simplifies things for translators. See the <a href="https://metacpan.org/module/Dist::Zilla::LocaleTextDomain#But-Im-a-Translator">notes for translators</a> for a few more words on the subject.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/modules/localetextdomain-msg-compile.html">old layout</a>.</small></p>


