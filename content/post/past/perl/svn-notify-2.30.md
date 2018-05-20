--- 
date: 2004-10-19T23:40:38Z
slug: svn-notify-2.30
title: SVN::Notify 2.30 Adds Issue Tracking Links
aliases: [/computers/programming/perl/modules/svn_notify_2.30.html]
tags: [Perl, SVN::Notify, CVSspam, Request Tracker, Bugzilla, Subversion, email, JIRA, ViewCVS, Autrijus Tang, Audrey Tang]
type: post
---

I released a new version of [SVN::Notify] last night, 2.30. This new version has
a few things going for it.

First, and most obviously from the point of view of users of the HTML subclass,
I've added new options for specifying [Request Tracker], [Bugzilla], and [JIRA]
URLs. The `--rt-url`, `--bugzilla-url`, and `--jira-url` options have an effect
much like the parallel feature in [CVSspam][]: pass in a string with the spot
for the ID represented by `%s`, such as
`http://rt.cpan.org/NoAuth/Bugs.html?id=%s` for RT or
`http://bugzilla.mozilla.org/show_bug.cgi?id=%s` for Bugzilla. SVN::Notify::HTML
will then look for the appropriate strings (such as “Ticket \# 1234” for RT or
“Bug \# 4321” for Bugzilla) and turn them into URLs.

This functionality has been extended to the old `--viewcvs-url` option, to. For
the sake of consistency, it now also requires a URL of the same form (although
if SVN::Notify doesn't see `%s` in the string, it will append a default and emit
a warning), and will be used to create links for strings like “Revision 654” in
the log message.

SVN::Notify::HTML has an additional new option, `--linkize`, that will force any
email addresses or URLs it finds in the log message to be turned into links.
Again, this works like it does for CVSspam; I'm grateful to Jeffrey Friedl's
*[Mastering Regular Expressions, Second Edition]* for the excellent regular
expressions for matching URLs and email addresses.

All of this was made possible by moving the processing of options from
*svnnotify* to `SVN::Notify->get_options` and adding a new class method,
`SVN::Notify->register_attributes`. This second method allows Bricolage
subclasses to easily add new attributes; `register_attributes()` will create
accessor methods and add command-line option processing for each new attribute
required by a subclass. Then, when you execute `svnnotify --handler HTML`,
`SVN::Notify->get_options` processes the default options, loads the
SVN::Notify::Handler subclass, and then processes any options specified by the
subclass. The short story is that all of this is the detail-oriented way of
saying that it is easier to subclass SVN::Notify and be able to automatically
load the necessary options and attributes via the same executable, *svnnotify*.

This change was motivated not only by my desire to add the new features to
SVN::Notify::HTML, but also by Autrijus' new modules, [SVN::Notify::Snapshot]
and [SVN::Notify::Config]. Thanks Autrijus!

I'll try to get a nice example of all this functionality up in the next few
days; if anyone else creates one first, send it to me! But in the meantime,
enjoy!

  [SVN::Notify]: http://search.cpan.org/dist/SVN-Notify/ "SVN::Notify on CPAN"
  [Request Tracker]: http://www.bestpractical.com/rt/ "RT at Best Practical"
  [Bugzilla]: http://bugzilla.mozilla.org/ "Bugzilla home page"
  [JIRA]: http://www.atlassian.com/software/jira/ "JIRA Website"
  [CVSspam]: http://www.badgers-in-foil.co.uk/projects/cvsspam/
    "CVSspam Home Page"
  [Mastering Regular Expressions, Second Edition]: https://www.amazon.com/exec/obidos/ASIN/0596002890/justatheory-20
    "Buy “Mastering Regular Expressions, Second Edition” on Amazon.com"
  [SVN::Notify::Snapshot]: http://search.cpan.org/dist/SVN-Notify-Snapshot/
    "SVN::Notify::Snapshot on CPAN"
  [SVN::Notify::Config]: http://search.cpan.org/dist/SVN-Notify-Config/
    "SVN::Notify::Config on CPAN"
