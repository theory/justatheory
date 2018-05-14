--- 
date: 2012-08-20T22:36:57Z
slug: sqitch-depend-on-it
title: "Sqitch: Depend On It!"
aliases: [/computers/databases/sqitch-depend-on-it.html]
tags: [Sqitch, SQL, change management]
type: post
---

<p><a href="https://metacpan.org/release/App-Sqitch">Sqitch v0.90</a> dropped last week (updated to v0.902 today). The focus of this release of the “sane database change management” app was cross-project dependencies. <a href="http://jim.nasby.net/">Jim Nasby</a> first put the idea for this feature into my head, and then I discovered that our first Sqitch-using project at <a href="http://iovation.com/">work</a> needs it, so blame them.</p>

<h3>Depend On It</h3>

<p>Earlier versions of Sqitch allow you to declare dependencies on other changes within a project. For example, if your project has a change named <code>users_table</code>, you can create a new change that requires it like so:</p>

<pre><code>sqitch add --requires users_table widgets_table
</code></pre>

<p>As of v0.90, you can also require a change from <em>different</em> Sqitch project. Say that you have a project that installs a bunch of utility functions, and that you want to require it in your current Sqitch project. To do so, just prepend the project name to the name of the change you want to require:</p>

<pre><code>sqitch add --requires utils:uuidgen widgets_table
</code></pre>

<p>When you go to deploy your project, Sqitch will not deploy the <code>widgets_table</code> change if the <code>uuidgen</code> change from the <code>utils</code> project is not already present.</p>

<p>Sqitch discriminates projects simply by name, as required since v0.80. When you initialize a new Sqitch project, you have to declare its name, too:</p>

<pre><code>siqtch init --name utils
</code></pre>

<p>I’ve wondered a bit as to whether that was sufficient. Within a small organization, it’s probably no big deal, as there is unlikely to be much namespace overlap. But thinking longer term, I could foresee folks developing and distributing interdependent open-source Sqitch projects. And without a central name registry, conflicts are likely to pop up. To a certain degree, the risks can be minimized by <a href="https://github.com/theory/sqitch/issues/38">comparing project URIs</a>, but that works only for project registration, not dependency specification. But perhaps it’s enough. Thoughts?</p>

<h3>It’s All Relative</h3>

<p>Next up I plan to implement the <a href="http://sqlite.org/">SQLite</a> support and the <a href="https://github.com/theory/sqitch/issues/14">bundle command</a>. But first, I want to support relative change specifications. Changes have an order, both in the plan and as deployed to the database. I want to be able to specify relative changes, kind of like you can specify relative commits in Git. So, if you want to revert just one change, you could say something like this:</p>

<pre><code>sqitch revert HEAD^
</code></pre>

<p>And that would revert one change. I also think the ability to specify later changes might be useful. So if you wanted to deploy to the change <em>after</em> change <code>foo</code>, you could say something like:</p>

<pre><code>sqitch deploy foo+
</code></pre>

<p>You can use <code>^</code> or <code>+</code> any number of times, or specify numbers for them. These would both revert three changes:</p>

<pre><code>sqitch revert HEAD^^^
sqitch revert HEAD^3
</code></pre>

<p>I like <code>^</code> because of its use in Git, although perhaps <code>~</code> is more appropriate (Sqitch does not have concepts of branching or multiple parent changes). But <code>+</code> is not a great complement. Maybe <code>-</code> and <code>+</code> would be better, if a bit less familiar? Or maybe there is a better complement to <code>^</code> or <code>~</code> I haven’t thought of? (I don’t want to use characters that have special meaning in the shell, like <code>&lt;&gt;</code>, if I can avoid it.) Suggestions greatly appreciated.</p>

<h3>Oops</h3>

<p>A discovered a bug late in the development of v0.90. Well, not so much a bug as an oversight: Sqitch does not validate dependencies in the <code>revert</code> command. That means it’s possible to revert a change without error when some other change depends on it. Oops. Alas, <a href="https://github.com/theory/sqitch/issues/36">fixing this issue is not exactly trivial</a>, but it’s something I will have to give attention to soon. While I’m at it, I will probably make <a href="https://github.com/theory/sqitch/issues/39">dependency failures fail earlier</a>. Watch for those fixes soon.</p>

<h3>And You?</h3>

<p>Still would love help getting a <a href="https://github.com/theory/sqitch/issues/34"><code>dzil</code> plugin to build Local::TextDomain l01n files</a>. I suspect this would take a knowledgable Dist::Zilla user a couple of hours to do. (And thanks to <a href="https://twitter.com/notbenh">@notbenh</a> and <a href="http://rjbs.manxome.org/">@RJBS</a> for getting Sqitch on Dist::Zilla!) And if anyone really wanted to dig into Sqitch, Implementing a <a href="https://github.com/theory/sqitch/issues/14"><code>bundle</code> command</a> would be a great place to start.</p>

<p>Or just give it a try! You can install it from CPAN with <code>cpan App::Sqitch</code>. Read <a href="https://metacpan.org/module/sqitchtutorial">the tutorial</a> for an overview of what Sqitch is and how it works. Thanks!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-depend-on-it.html">old layout</a>.</small></p>


