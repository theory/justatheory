--- 
date: 2010-04-12T20:46:11Z
slug: bricolage-2.0-drops
title: Bricolage 2.0 Drops
aliases: [/bricolage/bricolage-2.0-drops.html]
tags: [Bricolage, Apache, MySQL, Ajax, Google Summer Of Code]
---

<p>Bricolage 2.0 was <a href="http://bricolagecms.org/news/announce/2010/04/12/bricolage-2.0.0/">released today</a>. This is a pretty big deal, and a long time coming. The most important changes, from my point of view, are:</p>

<ul>
<li><p>Revamped UI. As a 2006 <a href="http://code.google.com/soc/">Google Summer of Code</a> project, <a href="http://mroch.com/">Marshall Roch</a> added a slew of Ajaxy goodness to the Bricolage UI. It used to be that, to dig down into a document, you needed to click through reloads for every level. Now the entire structure of a document is available on a single screen, and digging down takes place in situ. This means faster, easier document editing.</p>

<p>There are other niceties too, thanks to Marshall, like as-you-type autocompletion of category URIs and keywords, popups for associating related documents, dynamic field generation for document keywords and user contacts, and animated workflow actions for moving, deleting, and publishing documents.</p>

<p>These changes mark a truly impressive improvement in usability for the people who use Bricolage every day, and will by far be the most welcome change for our users.</p></li>
<li><p>Finer content control. Thanks to another 2006 <a href="http://code.google.com/soc/">Google Summer of Code</a> project, <a href="http://www.haz.ca/">Christian Muise</a> implemented what we call “element occurrence specification.” Bricolage document structure is controlled by administrators creating document types with hierarchies of elements. Elements may contain fields—the types and value of which may also be specified (text, textarea, select list, etc.)—and other elements.</p>

<p>In previous versions of Bricolage, if an element was a subelement of a document, one could add any number of that element to a document. Fields were a bit more controlled: you could only say whether one or many instances of a field were allowed in a given element.</p>

<p>Element occurrence specification allows administrators to have much finer control over document elements by specifying the minimum and maximum number of instances of an element or field may occur. For example, one can say that a document may have only one instance of a field, or must have three, or may have between 3 and 5, or may have at least 3, or may have any number, including none.</p>

<p><a href="http://pectopah.com/">Bret Dawson</a> put it really well in the <a href="http://bricolagecms.org/news/announce/changes/bricolage-2.0.0/">Bricolage 2.0 Changes</a>:</p>

<blockquote>
  <p>Want every book review you publish to contain at least three but no more than 10 ISBN numbers? Want exactly four pull-quotes in every article? You can do that in Bricolage 2.</p>
</blockquote></li>
<li><p>MySQL support. This, too, was a 2006 <a href="http://code.google.com/soc/">Google Summer of Code</a> project, by <a href="http://www.facebook.com/people/Arsu-Andrei/1758289731">Andrei Arsu</a>. Yes, you can run Bricolage 2.0 on MySQL 5.0 if you want. This was a pretty big project, and I’m surprisingly pleased at how well it works now that all the kinks have been worked out (special thanks to <a href="http://waldo.jaquith.org/">Waldo Jaquith</a> for being brave (foolish?) enough to start a Bricolage project on MySQL and thus to shake out some bugs).</p></li>
<li><p>Apache 2 support. This was started quite some time ago by <a href="http://cuwebd.ning.com/profile/ChrisHeiland">Chris Heiland</a>, hacked on later by <a href="http://use.perl.org/~slanning/">Scott Lanning</a>, and finally finished by yours truly. I look forward to dumping Apache 1 in the future.</p></li>
</ul>

<p>There’s other stuff, too, lots of little things and not-so-little things. Altogether they go a long way toward making Bricolage better.</p>

<p>It’s been quite a day, and I’m glad to have it out the door. Four years is a long time to wait for a major release, and it happened not because of me, but thanks to the work of others who have picked up the gauntlet. Huge thanks especially to:</p>

<ul>
<li>The <a href="http://code.google.com/soc/">Google Summer of Code</a>, especially the 2006 projects (yes, we finally shipped them!).</li>
<li><a href="">Phillip Smith</a>, who spearheaded the terrific new <a href="http://www.bricolagecms.org/">bricolagecms.org</a> design, updated the Bricolage 2.0 context-sensitive help, and generally pushed forward the Bricolage marketing and social media agenda (follow <a href="http://twitter.com/bricolagecms">@bricolagecms</a>!).</li>
<li><a href="http://pectopah.com/">Bret Dawson</a>, who has been writing release announcements and put together the <a href="http://bricolagecms.org/news/announce/changes/bricolage-2.0.0/">awesomely human version of the Bricolage 2.0 change log</a>, as well as the <a href="http://bricolagecms.org/news/announce/2010/04/12/bricolage-2.0.0/">public announcement</a>.</li>
<li><a href="http://mattrolf.com/">Matt Rolf</a>, who wrote the <a href="http://bricolagecms.org/news/pr/2010/04/12/2.0-presskit/">Bricolage 2.0 press release</a> and provided a huge load of various HTML and CSS fixes to Bricolage 2.0.</li>
<li><a href="http://mroch.com/">Marshall Roch</a>, who started hacking on Bricolage in high school, worked through two summers of code, and made the UI what it is today.</li>
<li><a href="http://ca.linkedin.com/in/gossamer">Alex Krohn</a>, who provides hosting for the <a href="http://www.bricolagecms.org/">Bricolage site</a> via his <a href="http://www.gossamer-threads.com/hosting/bricolage.html">Bricolage hosting</a> product at <a href="http://www.gossamer-threads.com/">Gossamer Threads</a>, helped to diagnose and fix a number of important bugs, and has just been an all around great technical resource.</li>
</ul>

<p>Many others provided feedback, patches, and bug reports, and I appreciate all the help. I hope to see you all for Bricolage 2.2!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/bricolage/bricolage-2.0-drops.html">old layout</a>.</small></p>


