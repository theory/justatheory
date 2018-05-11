--- 
date: 2004-10-05T00:00:31Z
slug: svnnotify-2.0
title: SVN::Notify 2.0 Hitting CPAN
aliases: [/computers/programming/perl/modules/svnnotify_2.0.html]
tags: [Perl, Subversion, activitymail, SVN::Notify]
---

<p>My latest Perl module, SVN::Notify 2.00, has hit <a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">CPAN</a>. This is a port of my widely-used <a href="http://search.cpan.org/dist/activitymail/" title="activitymail on CPAN"><em>activitymail</em></a> CVS notification script to <a href="http://subversion.tigris.org/" title="Subversion Website">Subversion</a>. But it underwent quite a few changes over the port, including:</p>

<dl>
  <dt>Modularization</dt>
  <dd>The old monolithic <em>activitymail</em> script is gone. It has been replaced with a Perl class, SVN::Notify, that does most of the work. The new script, <em>svnnotify</em>, is essentially just a wrapper around the class; all it does is process command-line arguments and then pass the results to SVN::Notify.</dd>

  <dt>Simplification</dt>
  <dd>Subversion's system for hooking in to commit transactions is far better thought-out than that of CVS. It's now easy to capture the results of an entire commit in a single transaction, without having to write out temp files to keep track of where we are and to concatenate diffs. As a result, SVN::Notify has a much simpler architecture and implementation that requires fewer third-party modules to do its work. In addition, the move to a class should make it much easier to build on SVN::Notify in the future than it was with activitymail. <a href="http://www.autrijus.org/" title="Autrijus.Home">Autrijus Tang</a> already suggested a number of ideas on IRC, including SVN::Notify::Jabber or SVN::Notify::Export. Have at it, everyone!</dd>

  <dt>Reduced Resource Usage</dt>
  <dd>I had heard some complaints that, on very large commits, <em>activitymail</em> could end up taking up a huge amount of memory. As best I could figure, this was because it was loading everything into memory, including the diff for the commit! SVN::Notify avoids this problem by using a file handle to read in a diff an print it to <em>sendmail</em> one line at a time. This should keep resource usage by SVN::Notify way below what activitymail used.</dd>

  <dt>Context-Specific Notifications</dt>
  <dd>SVN::Notify has added support for mapping email addresses to regular expressions. Whenever a regular expression matches the name of one or more of the directories affected in a single commit, the corresponding email address will be added to the list of recipients of the notification. This is a great way to get notification messages sent to particular email addressed based on what part of the Subversion tree was affected by a commit. I intend to use this to set it up so that a list of translators only get notification about a commit when it changes a directory related to localization in my projects, so that they can ignore commits to other parts of the application.</dd>
</dl>

<p>These are the major changes, but SVN::Notify also features a number of smaller improvements over its <em>activitymail</em> ancestor, including character set support, user domain support for the <q>From</q> header, explicit specification of a <q>From</q> header, properly escaped content when sending HTML-formatted notifications, and a maximum subject length configuration.</p>

<p>So what did it lose? Just a few things:</p>

<ul>
  <li><a href="http://sourceforge.net/projects/cvs-syncmail" title="syncmail Website"><em>syncmail</em></a>-like behavior. Did anyone ever use this? If so, feel free to implement SVN::Notify::Syncmail.</li>
  <li>Arguments to <em>diff</em>. SVN::Notify just uses <code>svnlook diff</code> to generate a diff. Support for other diffs could be added in a future version, if people really need it.</li>
  <li>New directories and imports can no longer be ingored, because in Subversion they're really no different from any other commit.</li>
  <li>Limit on the maximum size of the email. This is because SVN::Notify no longer loads the entire email into memory to measure it.</li>
  <li>Excluding certain files from the diff. Subversion handles this itself by paying attention to the media type of each file.</li>
  <li>Windows support. Actually, I'm not sure if <em>activitymail</em> was ever used on Windows, but the new method of using pipes to communicate with other processes isn't supported by Windows, as near as I can tell. There are comments in the code for those who wish to do the port; it would probably be easy using Win32::Process.</li>
</ul>

<p>Not too much, eh? Let me know what you think, and send feedback!</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/modules/svnnotify_2.0.html">old layout</a>.</small></p>


