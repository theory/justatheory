--- 
date: 2004-10-05T00:00:31Z
slug: svnnotify-2.0
title: SVN::Notify 2.0 Hitting CPAN
aliases: [/computers/programming/perl/modules/svnnotify_2.0.html]
tags: [Perl, Subversion, activitymail, SVN::Notify]
type: post
---

My latest Perl module, SVN::Notify 2.00, has hit [CPAN]. This is a port of my
widely-used [*activitymail*] CVS notification script to [Subversion]. But it
underwent quite a few changes over the port, including:

Modularization
:   The old monolithic *activitymail* script is gone. It has been replaced with
    a Perl class, SVN::Notify, that does most of the work. The new script,
    *svnnotify*, is essentially just a wrapper around the class; all it does is
    process command-line arguments and then pass the results to SVN::Notify.

Simplification
:   Subversion's system for hooking in to commit transactions is far better
    thought-out than that of CVS. It's now easy to capture the results of an
    entire commit in a single transaction, without having to write out temp
    files to keep track of where we are and to concatenate diffs. As a result,
    SVN::Notify has a much simpler architecture and implementation that requires
    fewer third-party modules to do its work. In addition, the move to a class
    should make it much easier to build on SVN::Notify in the future than it was
    with activitymail. [Autrijus Tang] already suggested a number of ideas on
    IRC, including SVN::Notify::Jabber or SVN::Notify::Export. Have at it,
    everyone!

Reduced Resource Usage
:   I had heard some complaints that, on very large commits, *activitymail*
    could end up taking up a huge amount of memory. As best I could figure, this
    was because it was loading everything into memory, including the diff for
    the commit! SVN::Notify avoids this problem by using a file handle to read
    in a diff an print it to *sendmail* one line at a time. This should keep
    resource usage by SVN::Notify way below what activitymail used.

Context-Specific Notifications
:   SVN::Notify has added support for mapping email addresses to regular
    expressions. Whenever a regular expression matches the name of one or more
    of the directories affected in a single commit, the corresponding email
    address will be added to the list of recipients of the notification. This is
    a great way to get notification messages sent to particular email addressed
    based on what part of the Subversion tree was affected by a commit. I intend
    to use this to set it up so that a list of translators only get notification
    about a commit when it changes a directory related to localization in my
    projects, so that they can ignore commits to other parts of the application.

These are the major changes, but SVN::Notify also features a number of smaller
improvements over its *activitymail* ancestor, including character set support,
user domain support for the “From” header, explicit specification of a “From”
header, properly escaped content when sending HTML-formatted notifications, and
a maximum subject length configuration.

So what did it lose? Just a few things:

-   [*syncmail*]-like behavior. Did anyone ever use this? If so, feel free to
    implement SVN::Notify::Syncmail.
-   Arguments to *diff*. SVN::Notify just uses `svnlook diff` to generate a
    diff. Support for other diffs could be added in a future version, if people
    really need it.
-   New directories and imports can no longer be ingored, because in Subversion
    they're really no different from any other commit.
-   Limit on the maximum size of the email. This is because SVN::Notify no
    longer loads the entire email into memory to measure it.
-   Excluding certain files from the diff. Subversion handles this itself by
    paying attention to the media type of each file.
-   Windows support. Actually, I'm not sure if *activitymail* was ever used on
    Windows, but the new method of using pipes to communicate with other
    processes isn't supported by Windows, as near as I can tell. There are
    comments in the code for those who wish to do the port; it would probably be
    easy using Win32::Process.

Not too much, eh? Let me know what you think, and send feedback!

  [CPAN]: http://search.cpan.org/dist/SVN-Notify/ "SVN::Notify on CPAN"
  [*activitymail*]: http://search.cpan.org/dist/activitymail/
    "activitymail on CPAN"
  [Subversion]: http://subversion.tigris.org/ "Subversion Website"
  [Autrijus Tang]: http://www.autrijus.org/ "Autrijus.Home"
  [*syncmail*]: http://sourceforge.net/projects/cvs-syncmail "syncmail Website"
