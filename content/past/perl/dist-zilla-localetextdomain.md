--- 
date: 2012-10-01T20:50:35Z
slug: dist-zilla-localetextdomain
title: Localize Your Perl modules with Locale::TextDomain and Dist::Zilla
aliases: [/computers/programming/perl/modules/dist-zilla-localetextdomain.html]
tags: [Perl, localization, internationalization, CPAN, Dist::Zilla]
type: post
---

<p>I've just released <a href="https://metacpan.org/release/Dist-Zilla-LocaleTextDomain">Dist::Zilla::LocaleTextDomain</a> v0.80 to the CPAN. This module adds support for managing <a href="https://metacpan.org/module/Locale::TextDomain">Locale::TextDomain</a>-based localization and internationalization in your CPAN libraries. I wanted to make it as simple as possible for CPAN developers to do localization and to support translators in their projects, and <a href="https://metacpan.org/module/Dist::Zilla">Dist::Zilla</a> seemed like the perfect place to do it, since it has hooks to generate the necessary binary files for distribution.</p>

<p>Starting out with Locale::TextDomain was decidedly non-intuitive for me, as a Perl hacker, likely because of its <a href="http://www.gnu.org/software/gettext/">gettext</a> underpinnings. Now that I've got a grip on it and created the Dist::Zilla support, I think it's pretty straight-forward. To demonstrate, I wrote the following brief tutorial, which constitutes the main documentation for the <a href="https://metacpan.org/module/Dist::Zilla::LocaleTextDomain">Dist::Zilla::LocaleTextDomain</a> distribution. I hope it makes it easier for you to get started localizing your Perl libraries.</p>

<h3>Localize Your Perl modules with Locale::TextDomain and Dist::Zilla</h3>

<p><a href="https://metacpan.org/module/Locale::TextDomain">Locale::TextDomain</a> provides a nice interface for localizing your Perl applications. The tools for managing translations, however, is a bit arcane. Fortunately, you can just use <a href="https://metacpan.org/module/Dist::Zilla::LocaleTextDomain">this plugin</a> and get all the tools you need to scan your Perl libraries for localizable strings, create a language template, and initialize translation files and keep them up-to-date. All this is assuming that your system has the <a href="http://www.gnu.org/software/gettext/">gettext</a> utilities installed.</p>

<h4 id="The-Details">The Details</h4>

<p>I put off learning how to use <a href="https://metacpan.org/module/Locale::TextDomain">Locale::TextDomain</a> for quite a while because, while the <a href="http://www.gnu.org/software/gettext/">gettext</a> tools are great for translators, the tools for the developer were a little more opaque, especially for Perlers used to <a href="https://metacpan.org/module/Locale::Maketext">Locale::Maketext</a>. But I put in the effort while hacking <a href="https://metacpan.org/module/App::Sqitch">Sqitch</a>. As I had hoped, using it in my code was easy. Using it for my distribution was harder, so I decided to write Dist::Zilla::LocaleTextDomain to make life simpler for developers who manage their distributions with <a href="https://metacpan.org/module/Dist::Zilla">Dist::Zilla</a>.</p>

<p>What follows is a quick tutorial on using <a href="https://metacpan.org/module/Locale::TextDomain">Locale::TextDomain</a> in your code and managing it with Dist::Zilla::LocaleTextDomain.</p>

<h4 id="This-is-my-domain">This is my domain</h4>

<p>First thing to do is to start using <a href="https://metacpan.org/module/Locale::TextDomain">Locale::TextDomain</a> in your code. Load it into each module with the name of your distribution, as set by the <code>name</code> attribute in your <i>dist.ini</i> file. For example, if your <i>dist.ini</i> looks something like this:</p>

<pre><code>name    = My-GreatApp
author  = Homer Simpson &lt;homer@example.com&gt;
license = Perl_5</code></pre>

<p>Then, in you Perl libraries, load <a href="https://metacpan.org/module/Locale::TextDomain">Locale::TextDomain</a> like this:</p>

<pre><code>use Locale::TextDomain qw(My-GreatApp);</code></pre>

<p><a href="https://metacpan.org/module/Locale::TextDomain">Locale::TextDomain</a> uses this value to find localization catalogs, so naturally Dist::Zilla::LocaleTextDomain will use it to put those catalogs in the right place.</p>

<p>Okay, so it&#39;s loaded, how do you use it? The documentation of the <a href="https://metacpan.org/module/Locale::TextDomain#EXPORTED-FUNCTIONS">Locale::TextDomain exported functions</a> is quite comprehensive, and I think you&#39;ll find it pretty simple once you get used to it. For example, simple strings are denoted with <code>__</code>:</p>

<pre><code>say __ &#39;Hello&#39;;</code></pre>

<p>If you need to specify variables, use <code>__x</code>:</p>

<pre><code>say __x(
    &#39;You selected the color {color}&#39;,
    color =&gt; $color
);</code></pre>

<p>Need to deal with plurals? Use <code>__n</code></p>

<pre><code>say __n(
    &#39;One file has been deleted&#39;,
    &#39;All files have been deleted&#39;,
    $num_files,
);</code></pre>

<p>And then you can mix variables with plurals with <code>__nx</code>:</p>

<pre><code>say __nx(
    &#39;One file has been deleted.&#39;,
    &#39;{count} files have been deleted.&#39;&quot;,
    $num_files,
    count =&gt; $num_files,
);</code></pre>

<p>Pretty simple, right? Get to know these functions, and just make it a habit to use them in user-visible messages in your code. Even if you never expect to translate those messages, just by doing this you make it easier for someone else to come along and start translating for you.</p>

<h5 id="The-setup">The setup</h5>

<p>Now you&#39;re localizing your code. Great! What&#39;s next? Officially, nothing. If you never do anything else, your code will always emit the messages as written. You can ship it and things will work just as if you had never done any localization.</p>

<p>But what&#39;s the fun in that? Let&#39;s set things up so that translation catalogs will be built and distributed once they&#39;re written. Add these lines to your <i>dist.ini</i>:</p>

<pre><code>[ShareDir]
[LocaleTextDomain]</code></pre>

<p>There are actually quite a few attributes you can set here to tell the plugin where to find language files and where to put them. For example, if you used a domain different from your distribution name, e.g.,</p>

<pre><code>use Locale::TextDomain &#39;com.example.My-GreatApp&#39;;</code></pre>

<p>Then you would need to set the <code>textdomain</code> attribute so that the <code>LocaleTextDomain</code> does the right thing with the language files:</p>

<pre><code>[LocaleTextDomain]
textdomain = com.example.My-GreatApp</code></pre>

<p>Consult the <a href="https://metacpan.org/module/Dist::Zilla::Plugin::LocaleTextDomain#Configuration"><code>LocaleTextDomain</code> configuration docs</a> for details on all available attributes.</p>

<blockquote><p>(Special note until <a href="https://rt.cpan.org/Public/Bug/Display.html?id=79461">this Locale::TextDomain patch</a> is merged: set the <code>share_dir</code> attribute to <code>lib</code> instead of the default value, <code>share</code>. If you use <a href="https://metacpan.org/module/Module::Build">Module::Build</a>, you will also need a subclass to do the right thing with the catalog files; see <a href="https://metacpan.org/module/Dist::Zilla::Plugin::LocaleTextDomain#Installation">&quot;Installation&quot; in Dist::Zilla::Plugin::LocaleTextDomain</a> for details.)</p></blockquote>

<p>What does this do including the plugin do? Mostly nothing. You might see this line from <code>dzil build</code>, though:</p>

<pre><code>[LocaleTextDomain] Skipping language compilation: directory po does not exist</code></pre>

<p>Now at least you know it was looking for something to compile for distribution. Let&#39;s give it something to find.</p>

<h5 id="Initialize-languages">Initialize languages</h5>

<p>To add translation files, use the <a href="https://metacpan.org/module/Dist::Zilla::App::Command::msg_init"><code>msg-init</code></a> command:</p>

<pre><code>&gt; dzil msg-init de
Created po/de.po.</code></pre>

<p>At this point, the <a href="http://www.gnu.org/software/gettext/">gettext</a> utilities will need to be installed and visible in your path, or else you&#39;ll get errors.</p>

<p>This command scans all of the Perl modules gathered by Dist::Zilla and initializes a German translation file, named <i>po/de.po</i>. This file is now ready for your German-speaking public to start translating. Check it into your source code repository so they can find it. Create as many language files as you like:</p>

<pre><code>&gt; dzil msg-init fr ja.JIS en_US.UTF-8
Created po/fr.po.
Created po/ja.po.
Created po/en_US.po.</code></pre>

<p>As you can see, each language results in the generation of the appropriate file in the <i>po</i> directory, sans encoding (i.e., no <i>.UTF-8</i> in the <code>en_US</code> file name).</p>

<p>Now let your translators go wild with all the languages they speak, as well as the regional dialects. (Don&#39;t forget to colour your code with <code>en_UK</code> translations!)</p>

<p>Once you have translations and they&#39;re committed to your repository, when you build your distribution, the language files will automatically be compiled into binary catalogs. You&#39;ll see this line output from <code>dzil build</code>:</p>

<pre><code>[LocaleTextDomain] Compiling language files in po
po/fr.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.
po/ja.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.
po/en_US.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.</code></pre>

<p>You&#39;ll then find the catalogs in the shared directory of your distribution:</p>

<pre><code>&gt; find My-GreatApp-0.01/share -type f
My-GreatApp-0.01/share/LocaleData/de/LC_MESSAGES/App-Sqitch.mo
My-GreatApp-0.01/share/LocaleData/en_US/LC_MESSAGES/App-Sqitch.mo
My-GreatApp-0.01/share/LocaleData/ja/LC_MESSAGES/App-Sqitch.mo</code></pre>

<p>These binary catalogs will be installed as part of the distribution just where <code>Locale::TextDomain</code> can find them.</p>

<p>Here&#39;s an optional tweak: add this line to your <code>MANIFEST.SKIP</code>:</p>

<pre><code>^po/</code></pre>

<p>This prevents the <i>po</i> directory and its contents from being included in the distribution. Sure, you can include them if you like, but they&#39;re not required for the running of your app; the generated binary catalog files are all you need. Might as well leave out the translation files.</p>

<h5 id="Mergers-and-acquisitions">Mergers and acquisitions</h5>

<p>You&#39;ve got translation files and helpful translators given them a workover. What happens when you change your code, add new messages, or modify existing ones? The translation files need to periodically be updated with those changes, so that your translators can deal with them. We got you covered with the <a href="https://metacpan.org/module/Dist::Zilla::App::Command::msg_merge"><code>msg-merge</code></a> command:</p>

<pre><code>&gt; dzil msg-merge
extracting gettext strings
Merging gettext strings into po/de.po
Merging gettext strings into po/en_US.po
Merging gettext strings into po/ja.po</code></pre>

<p>This will scan your module files again and update all of the translation files with any changes. Old messages will be commented-out and new ones added. Just commit the changes to your repository and notify the translation army that they&#39;ve got more work to do.</p>

<p>If for some reason you need to update only a subset of language files, you can simply list them on the command-line:</p>

<pre><code>&gt; dzil msg-merge po/de.po po/en_US.po
Merging gettext strings into po/de.po
Merging gettext strings into po/en_US.po</code></pre>

<h5 id="Whats-the-scan-man">What&#39;s the scan, man</h5>

<p>Both the <code>msg-init</code> and <code>msg-merge</code> commands depend on a translation template file to create and merge language files. Thus far, this has been invisible: they will create a temporary template file to do their work, and then delete it when they&#39;re done.</p>

<p>However, it&#39;s common to also store the template file in your repository and to manage it directly, rather than implicitly. If you&#39;d like to do this, the <a href="https://metacpan.org/module/Dist::Zilla::App::Command::msg_scan"><code>msg-scan</code></a> command will scan the Perl module files gathered by Dist::Zilla and make it for you:</p>

<pre><code>&gt; dzil msg-scan
gettext strings into po/My-GreatApp.pot</code></pre>

<p>The resulting <i>.pot</i> file will then be used by <code>msg-init</code> and <code>msg-merge</code> rather than scanning your code all over again. This actually then makes <code>msg-merge</code> a two-step process: You need to update the template before merging. Updating the template is done by exactly the same command, <code>msg-scan</code>:</p>

<pre><code>&gt; dzil msg-scan
extracting gettext strings into po/My-GreatApp.pot
&gt; dzil msg-merge
Merging gettext strings into po/de.po
Merging gettext strings into po/en_US.po
Merging gettext strings into po/ja.po</code></pre>

<h5 id="Ship-It-">Ship It!</h5>

<p>And that&#39;s all there is to it. Go forth and localize and internationalize your Perl apps!</p>

<h3>Acknowledgements</h3>

My thanks to <a href="http://rjbs.manxome.org">Ricardo Signes</a> for invaluable help plugging in to Dist::Zilla, to <a href="http://guido-flohr.net/">Guido Flohr</a> for providing feedback on this tutorial and being open to my pull requests, to <a href="http://www.dagolden.com/">David Golden</a> for I/O capturing help, and to <a href="https://metacpan.org/author/JQUELIN">Jérôme Quelin</a> for his patience as I wrote code to do the same thing as <a href="https://metacpan.org/module/Dist::Zilla::Plugin::LocaleMsgfmt">Dist::Zilla::Plugin::LocaleMsgfmt</a> without ever noticing that it already existed.</p>







<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/modules/dist-zilla-localetextdomain.html">old layout</a>.</small></p>


