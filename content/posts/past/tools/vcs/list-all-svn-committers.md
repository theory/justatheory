--- 
date: 2009-04-09T20:03:11Z
slug: list-all-svn-committers
title: List All Subversion Committers
aliases: [/computers/tricks/list-all-svn-committers.html]
tags: [Subversion, Git]
---

<p>In preparation for migrating a large Subversion repository to GitHub, I
needed to get a list of all of the Subversion committers throughout history,
so that I could create a file mapping them to Git users. Here's how I did
it:</p>

<pre>
svn log &#x002d;&#x002d;quiet http://svn.example.com/ \
| grep &#x0027;^r&#x0027; | awk &#x0027;{print $3}&#x0027; | sort | uniq > committers.txt
</pre>

<p>Now I just have edit <code>committers.txt</code> and I have my mapping file.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/tricks/list-all-svn-committers.html">old layout</a>.</small></p>


