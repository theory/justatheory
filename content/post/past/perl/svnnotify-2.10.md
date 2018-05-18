--- 
date: 2004-10-07T23:04:23Z
slug: svnnotify-2.10
title: SVN::Notify 2.10 Generalizes Behavior
aliases: [/computers/programming/perl/modules/svnnotify_2.10.html]
tags: [Perl, Subversion, SVN::Notify, activitymail]
type: post
---

<p>It's all <a href="http://www.autrijus.org/" title="Autrijus.Home">Autrijus'</a> fault.</p>

<p>As I <a href="/computers/programming/perl/modules/svnnotify_2.0.html" title="SVN::Notify 2.0 Hitting CPAN">mentioned</a> last week when I released SVN::Notify 2.0, Autrijus has suggested using SVN::Notify as the base class for modules that do other things, such as send instant messages or update a checkout for backup purposes. Instantly seeing the value in this, I further realized that I could greatly simplify the support for HTML notification emails by moving the HTML-specific code to a subclass and then just let polymorphism do the work.</p>

<p>The result <a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">SVN::Notify</a> 2.10. To simplify the move to a subclass for the HTML notifications, I broke up the old <code>send()</code> method into a large number of other methods that affect various parts of the composition of the email, such as headers, starting the message, outputting the log message, the file list, and outputting or attaching the diff. Then I just overrode the few methods that need different behavior in the subclass, and it all worked!</p>

<p>I realized, as I worked on it, I also realized that I was following the same principals that <a href="http://use.perl.org/~Ovid/" title="Ovid's Journal">Ovid</a> has <a href="http://www.perlmonks.org/index.pl?node_id=392248" title="&#x201c;if&#x201d; Considered Harmful in OO programming">written about</a> with regard to the use of <code>if</code>. I was able to remove quite a few of them by moving HTML to a subclass. Of course, there are still some to enable diffs to be either included in an email or attached, but I didn't want to split things up too much, or I'd have a geometric explosion of subclasses!</p>

<p>The <em>svnnotify</em> script, in the meantime, remains largely unmodified. The only change is the deprecation of the <code>--format</code> option in favor of a new option, <code>--handler</code>. Use this option to specify what subclass of SVN::Notify should handle the notification. So far, there's just one, <code>--format HTML</code>, but I'm sure that Autrijus will soon add <code>--format Jabber</code>, and I'd like to add <code>--format HTML::ColorDiff</code>, myself. I might have to move the processing of command-line arguments out of <em>svnnotify</em> and into SVN::Notify, instead, so that subclasses can add new options. We'll see what comes up.</p>

<p>Other changes to SVN::Notify include:</p>

<ul>
  <li>Added code to Build.PL to set the shebang line in the test
        scripts. Reported by Robert Spier.</li>
  <li>Changed name of attached diff file to be named for the revision
        and the committer, rather than the committer and the date.
        Suggested by Robert Spier.</li>
  <li>Added Author, Date, and Revision information to the top of each
        message.</li>
  <li>The ViewCVS URL is no longer output for each file. A single link
        for the entire revision number is put at the top of the email,
        instead. ViewCVS Revision URL syntax pointed out by Peter
        Valdemar Morch.</li>
  <li>Changed the <code>send()</code> method to <code>execute()</code> to better reflect
        its generalized use as the method that executes actions in
        response to Subversion activity.</li>
  <li>The tests no longer require HTML::Entities to run. The HTML
        email tests will be skipped if it is not installed.</li>
  <li>Added accessor methods for the attributes of SVN::Notify.</li>
</ul>

<p>Enjoy!</p>
