--- 
date: 2012-07-05T11:29:19Z
slug: sqitch-almost-usable
title: "Sqitch Update: Almost Usable"
aliases: [/computers/databases/sqitch-almost-usable.html]
tags: [Sqitch, SQL, change management, database, migrations]
type: post
---

<p>This week, I released v0.50 of <a href="http://sqitch.org/">Sqitch</a>, the database change management app I’ve been working on for the last couple of months. Those interested in how it works should read <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod">the tutorial</a>. A lot has changed since v0.30; here are some highlights:</p>

<ul>
<li>The plan file is now required. This can make merges more annoying, but thanks to a comment <a href="/computers/databases/sqitch-dependencies.html#comment-538970287">from Jakub Narębski </a>, I discovered that Git can be configured to use a “union merge driver”, which seems to simplify things a great deal. See <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod#emergency">the tutorial</a> for a detailed example.</li>
<li>The plan now consists solely of a list of
changes, roughly analogous to Git commits. Tags are simply pointers to specific changes.</li>
<li>Dependencies are now specified in the plan file, rather than in the deployment scripts. Once the plan file became required, this seemed like the <a href="/computers/databases/sqitch-dependencies.html">much more obvious</a> place for them.</li>
<li>The plan file now goes into the top-level directory of a project (which defaults to the current directory, assumed to be the top level directory of a VCS project), while the configuration file goes into the current directory. This allows one to have multiple top-level directories for different database engines, each with its own plan, and a single configuration file for them all.</li>
</ul>


<p>Seems like a short list, but in reality, this release is the first I would call almost usable. Most of the core functionality and infrastructure is in place, and the architectural designs have been finalized. There should be much less flux in how things work from here on in, though this is still very much a developer release. Things <em>might</em> still change, so I’m being conservative and not doing a “stable” release just yet.</p>

<h3>What works</h3>

<p>So what commands actually work at this point? All of the most important functional ones:</p>

<ul>
<li><a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-init.pod"><code>sqitch init</code></a> – Initialize a Sqitch project. Creates the project configuration file, a plan file, and directories for deploy, revert, and test scripts</li>
<li><a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-config.pod"><code>sqitch config</code></a> – Configure Sqitch. Uses the same configuration format as Git, including cascading local, user, and system-wide configuration files</li>
<li><a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-help.pod"><code>sqitch help</code></a> – Get documentation for specific commands</li>
<li><a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-add.pod"><code>sqitch add</code></a> – Add a new change to the plan. Generates deploy, revert, and test scripts based on user-modifiable templates</li>
<li><a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-tag.pod"><code>sqitch tag</code></a> – Tag the latest change in the plan, or show a list of existing tags</li>
<li><a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-deploy.pod"><code>sqitch deploy</code></a> – Deploy changes to a database. Includes a <code>--mode</code> option to control how to revert changes in the event of a deploy failure (not at all, to last tag, or to starting point)</li>
<li><a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-revert.pod"><code>sqitch revert</code></a> – Revert changes from a database</li>
<li><a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-rework.pod"><code>sqitch rework</code></a> – Copy and modify a previous change</li>
</ul>


<p>Currently, only PostgreSQL is supported by <code>deploy</code> and <code>revert</code>; I will at least add SQLite support soon.</p>

<p>The <code>rework</code> command is my solution to the problem of code duplication. It does not (yet) rely on VCS history, so it still duplicates code. However, it does so in such a way that it is still easier to see what has changed, because the new files are actually used by the <em>previous</em> instance of the command, while the new one uses the existing files. So a <code>diff</code> command, while showing the new files in toto, actually shows what changed in the existing scripts, making it easier to follow. I think this is a decent compromise, to allow Sqitch to be used with or without a VCS, and without disabling the advantages of VCS integration in the future.</p>

<p>The only requirement for reworking a change is that there must be a tag on that change or a change following it. Sqitch uses that tag in the name of the files for the previous instance of the change, as well as in internal IDs, so it’s required to disambiguate the scripts and deployment records of the two instances. The assumption here is that tags are generally used when a project is released, as otherwise, if you were doing development, you would just go back and modify the change’s scripts directly, and revert and re-deploy to get the changes in your dev database. But once you tag, this is a sort of promise that nothing will be changed prior to the tag.</p>

<p>I modify change scripts a <em>lot</em> in my own database development projects. Naturally, I think it is important to be free to change deployment scripts however one likes while doing development, and also important to promise not to change them once they have been released. As long as tags are generally thought of as marking releases or other significant milestones, it seems a reasonable promise not to change anything that appears before a tag.</p>

<p>See <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod#in-place-changes">the tutorial</a> for a detailed example. In a future release, VCS integration will be added, and the duplicated files will be unnecessary, too. But the current approach has the advantage that it will work anywhere, VCS or no. The VCS support will be backward-compatible with this design (indeed, it depends on it).</p>

<h3>Still To Do</h3>

<p>I think I might hold off a bit on the VCS integration, since the <code>rework</code> command no longer requires it. There also needs to be support for database engines other than PostgreSQL. But otherwise, mostly what needs to be done is the informational commands, packaging, and testing:</p>

<ul>
<li><a href="https://github.com/theory/sqitch/issues/11"><code>sqitch status</code></a> – Show the current deployment status of a database</li>
<li><a href="https://github.com/theory/sqitch/issues/12"><code>sqitch log</code></a> – Show the deploy and revert history of a database</li>
<li><a href="https://github.com/theory/sqitch/issues/14"><code>sqitch bundle</code></a> – Bundle up the configuration, plan, and scripts for distribution packaging</li>
<li><a href="https://github.com/theory/sqitch/issues/15"><code>sqitch test</code></a> – Test changes. Mostly hand-wavy; see below</li>
<li><a href="https://github.com/theory/sqitch/issues/13"><code>sqitch check</code></a> – Validate a database deployment history against the plan</li>
</ul>


<p>I will likely be working on the <code>status</code> and <code>log</code> commands next, as well as an SQLite engine, to make sure I have the engine encapsulation right.</p>

<h3>Outstanding Questions</h3>

<p>I’m still pondering some design decisions. Your thoughts and comments greatly appreciated.</p>

<ul>
<li><p>Sqitch now requires a URI, which is set in the local configuration file by the <code>init</code> command. If you don’t specify one, it just creates a UUID-based URI. The URI is required to make sure that changes have unique IDs across projects (a change may have the same name as in another project). But maybe this should be more flexible? Maybe, like Git, Sqitch should require a user name and email address, instead? They would have to be added to the change lines of the plan, which is what has given me pause up to now. It would be annoying to parse.</p></li>
<li><p>How should testing work? When I do PostgreSQL stuff, I am of course rather keen on <a href="http://pgtap.org/">pgTAP</a>. But I don’t think it makes sense to require a particular format of output or anything of that sort. It just wouldn’t be engine-neutral enough. So maybe test scripts should just run and considered passing if the engine client exits successfully, and failing if it exited unsuccessfully? That would allow one to use whatever testing was supported by the engine, although I would have to find some way to get pgTAP to make <code>psql</code> exit non-zero on failure.</p>

<p>Another possibility is to require expected output files, and to diff them. I’m not too keen on this approach, as it makes it much more difficult to write tests to run on multiple engine versions and platforms, since the output might vary. It’s also more of a PITA to maintain separate test and expect files and keep them in sync. Still, it’s a tried-and-true approach.</p></li>
</ul>


<h3>Help Wanted</h3>

<p>Contributions would be warmly welcomed. See <a href="https://github.com/theory/sqitch/issues?labels=todo&amp;page=1&amp;state=open">the to-do list</a> for what needs doing. Some highlights and additional items:</p>

<ul>
<li><a href="https://github.com/theory/sqitch/issues/17">Convert to Dist::Zilla</a></li>
<li>Implement the <a href="http://metacpan.org/module/Locale::TextDomain">Locale::TextDomain</a>-based localization build. Should be done at distribution build time, not install time. Ideally, there would be a Dist::Zilla plugin to do it, based pattern implemented in <a href="https://metacpan.org/source/GUIDO/libintl-perl-1.20/sample/simplecal/po/Makefile">this example <code>Makefile</code></a> (see also <a href="https://metacpan.org/source/GUIDO/libintl-perl-1.20/sample/README">this README</a>).</li>
<li><a href="http://sqitch.org/">The web site</a> could use some updating, though I realize it will regularly need changing until most of the core development has completed and more documentation has been written.</li>
<li>Handy with graphics? The project <a href="https://twitter.com/theory/statuses/197383050680745984">could use a logo</a>. Possible themes: SQL, databases, change management, baby Sasquatch.</li>
<li>Packaging. It would greatly help developers and system administrators who don’t do CPAN if they could just use their familiar OS installers to get Sqitch. So <a href="https://en.wikipedia.org/wiki/RPM_Package_Manager">RPM</a>, <a href="http://www.debian.org/doc/manuals/debian-reference/ch02">Debian package</a>, <a href="http://mxcl.github.com/homebrew/">Homebrew</a>, <a href="https://en.wikipedia.org/wiki/FreeBSD_Ports">BSD Ports</a>, and Windows distribution support would be hugely appreciated.</li>
</ul>


<h3>Take it for a Spin!</h3>

<p>Please do install the v0.51 developer release from the CPAN (run <code>cpan D/DW/DWHEELER/App-Sqitch-0.51-TRIAL.tar.gz</code>) and kick the tires a bit. Follow along <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod">the tutorial</a> to get a feel for it, or even just review the tutorial example’s <a href="https://github.com/theory/sqitch-intro/commits/master">Git history</a> to get a feel for it. And if there is something you want out of Sqitch that you don’t see, please feel free to <a href="https://github.com/theory/sqitch/issues">file an issue</a> with your suggestion.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-almost-usable.html">old layout</a>.</small></p>


