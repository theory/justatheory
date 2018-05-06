--- 
date: 2004-10-19T23:40:38Z
slug: svn-notify-2.30
title: SVN::Notify 2.30 Adds Issue Tracking Links
aliases: [/computers/programming/perl/modules/svn_notify_2.30.html]
tags: [Perl, SVN::Notify, CVSspam, Request Tracker, Bugzilla, Subversion, email, JIRA, ViewCVS, Autrijus Tang, Audrey Tang]
---

<p>I released a new version of <a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">SVN::Notify</a> last night, 2.30. This new version has a few things going for it.</p>

<p>First, and most obviously from the point of view of users of the HTML subclass, I've added new options for specifying <a href="http://www.bestpractical.com/rt/" title="RT at Best Practical">Request Tracker</a>, <a href="http://bugzilla.mozilla.org/" title="Bugzilla home page">Bugzilla</a>, and <a href="http://www.atlassian.com/software/jira/" title="JIRA Website">JIRA</a> URLs. The <code>--rt-url</code>, <code>--bugzilla-url</code>, and <code>--jira-url</code> options have an effect much like the parallel feature in <a href="http://www.badgers-in-foil.co.uk/projects/cvsspam/" title="CVSspam Home Page">CVSspam</a>: pass in a string with the spot for the ID represented by <code>%s</code>, such as <code>http://rt.cpan.org/NoAuth/Bugs.html?id=%s</code> for RT or <code>http://bugzilla.mozilla.org/show_bug.cgi?id=%s</code> for Bugzilla. SVN::Notify::HTML will then look for the appropriate strings (such as <q>Ticket # 1234</q> for RT or <q>Bug # 4321</q> for Bugzilla) and turn them into URLs.</p>

<p>This functionality has been extended to the old <code>--viewcvs-url</code> option, to. For the sake of consistency, it now also requires a URL of the same form (although if SVN::Notify doesn't see <code>%s</code> in the string, it will append a default and emit a warning), and will be used to create links for strings like <q>Revision 654</q> in the log message.</p>

<p>SVN::Notify::HTML has an additional new option, <code>--linkize</code>, that will force any email addresses or URLs it finds in the log message to be turned into links. Again, this works like it does for CVSspam; I'm grateful to Jeffrey Friedl's <cite><a href="http://www.amazon.com/exec/obidos/ASIN/0596002890/justatheory-20" title="Buy &#x201c;Mastering Regular Expressions, Second Edition&#x201d; on Amazon.com">Mastering Regular Expressions, Second Edition</a></cite> for the excellent regular expressions for matching URLs and email addresses.</p>

<p>All of this was made possible by moving the processing of options from <em>svnnotify</em> to <code>SVN::Notify->get_options</code> and adding a new class method, <code>SVN::Notify->register_attributes</code>. This second method allows Bricolage subclasses to easily add new attributes; <code>register_attributes()</code> will create accessor methods and add command-line option processing for each new attribute required by a subclass. Then, when you execute <code>svnnotify --handler HTML</code>, <code>SVN::Notify->get_options</code> processes the default options, loads the SVN::Notify::Handler subclass, and then processes any options specified by the subclass. The short story is that all of this is the detail-oriented way of saying that it is easier to subclass SVN::Notify and be able to automatically load the necessary options and attributes via the same executable, <em>svnnotify</em>.</p>

<p>This change was motivated not only by my desire to add the new features to SVN::Notify::HTML, but also by Autrijus' new modules, <a href="http://search.cpan.org/dist/SVN-Notify-Snapshot/" title="SVN::Notify::Snapshot on CPAN">SVN::Notify::Snapshot</a> and <a href="http://search.cpan.org/dist/SVN-Notify-Config/" title="SVN::Notify::Config on CPAN">SVN::Notify::Config</a>. Thanks Autrijus!</p>

<p>I'll try to get a nice example of all this functionality up in the next few days; if anyone else creates one first, send it to me! But in the meantime, enjoy!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/modules/svn_notify_2.30.html">old layout</a>.</small></p>


