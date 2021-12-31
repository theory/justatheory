--- 
date: 2004-10-07T23:04:23Z
slug: svnnotify-2.10
title: SVN::Notify 2.10 Generalizes Behavior
aliases: [/computers/programming/perl/modules/svnnotify_2.10.html]
tags: [Perl, Subversion, SVN::Notify, activitymail]
type: post
---

It's all [Autrijus'] fault.

As I [mentioned] last week when I released SVN::Notify 2.0, Autrijus has
suggested using SVN::Notify as the base class for modules that do other things,
such as send instant messages or update a checkout for backup purposes.
Instantly seeing the value in this, I further realized that I could greatly
simplify the support for HTML notification emails by moving the HTML-specific
code to a subclass and then just let polymorphism do the work.

The result [SVN::Notify] 2.10. To simplify the move to a subclass for the HTML
notifications, I broke up the old `send()` method into a large number of other
methods that affect various parts of the composition of the email, such as
headers, starting the message, outputting the log message, the file list, and
outputting or attaching the diff. Then I just overrode the few methods that need
different behavior in the subclass, and it all worked!

I realized, as I worked on it, I also realized that I was following the same
principals that [Ovid] has [written about] with regard to the use of `if`. I was
able to remove quite a few of them by moving HTML to a subclass. Of course,
there are still some to enable diffs to be either included in an email or
attached, but I didn't want to split things up too much, or I'd have a geometric
explosion of subclasses!

The *svnnotify* script, in the meantime, remains largely unmodified. The only
change is the deprecation of the `--format` option in favor of a new option,
`--handler`. Use this option to specify what subclass of SVN::Notify should
handle the notification. So far, there's just one, `--format HTML`, but I'm sure
that Autrijus will soon add `--format Jabber`, and I'd like to add
`--format HTML::ColorDiff`, myself. I might have to move the processing of
command-line arguments out of *svnnotify* and into SVN::Notify, instead, so that
subclasses can add new options. We'll see what comes up.

Other changes to SVN::Notify include:

-   Added code to Build.PL to set the shebang line in the test scripts. Reported
    by Robert Spier.
-   Changed name of attached diff file to be named for the revision and the
    committer, rather than the committer and the date. Suggested by Robert
    Spier.
-   Added Author, Date, and Revision information to the top of each message.
-   The ViewCVS URL is no longer output for each file. A single link for the
    entire revision number is put at the top of the email, instead. ViewCVS
    Revision URL syntax pointed out by Peter Valdemar Morch.
-   Changed the `send()` method to `execute()` to better reflect its generalized
    use as the method that executes actions in response to Subversion activity.
-   The tests no longer require HTML::Entities to run. The HTML email tests will
    be skipped if it is not installed.
-   Added accessor methods for the attributes of SVN::Notify.

Enjoy!

  [Autrijus']: http://www.autrijus.org/ "Autrijus.Home"
  [mentioned]: /computers/programming/perl/modules/svnnotify_2.0.html
    "SVN::Notify 2.0 Hitting CPAN"
  [SVN::Notify]: https://metacpan.org/dist/SVN-Notify/ "SVN::Notify on CPAN"
  [Ovid]: http://use.perl.org/~Ovid/ "Ovid's Journal"
  [written about]: http://www.perlmonks.org/index.pl?node_id=392248
    "“if” Considered Harmful in OO programming"
