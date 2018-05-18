--- 
date: 2009-04-07T04:30:30Z
slug: svn-notify-future
title: The Future of SVN::Notify
aliases: [/computers/programming/perl/modules/svn-notify-future.html]
tags: [Perl, SVN::Notify, Subversion, Git, GitHub, SCM, VCS, CVS]
type: post
---

<p>This week, I imported <a href="http://pgtap.projects.postgresql.org/" title="pgTAP: PostgreSQL Unit Testing">pgTAP</a>
into <a href="http://github.com/theory/pgtap/tree/master" title="The pgTAP GitHub Repository">GitHub</a>. It took me a day or so to wrap my brain around
how it's all supposed to work, with generous
help <a href="http://support.github.com/discussions/repos/492-svn-import-hasnt-finished-after-24-hours" title="GitHub Support: SVN Import Hasn't Finished after 24 Hours">from
Tekkub</a>. But I'm starting to get the hang of it, and I like it. By the end
of the day, I had sent push requests
to <a href="http://github.com/schwern/test-more/tree/master" title="The Test::More GitHub Repository">Test::More</a>
and <a href="http://github.com/hail2u/blosxom-plugins/tree/master" title="Blosxom Plugins GitHub Repository">Blosxom Plugins</a>. I'm well on my
way to being hooked.</p>

<p>One of the things I want, however,
is <a href="http://search.cpan.org/perldoc?SVN::Notify" title="SVN::Notify on CPAN">SVN::Notify</a>-type commit emails. I know that there are feeds, but
they don't have diffs, and for however much I like using NetNewsWire to feed
by political news addiction, it never worked for me for commit activity. And
besides, why download the whole damn thing again, diffs and all (assuming that
ever happens), for every refresh. Seems like a hell of a lot unnecessary
network activity—not to mention actual CPU cycles.</p>

<p>So I would need a decent notification application. I happen to have one. I
originally wrote SVN::Notify after I had already
written <a href="search.cpan.org/perldoc?activitymail" title="activitymail on CPAN">activitymail</a>, which sends noticies for CVS commits. SVN::Notify has
changed a lot over the years, and now it's looking a bit daunting to consider
porting it to Git.</p>

<p>However, just to start thinking about it, SVN::Notify really does several
different things:</p>

<ul>
  <li>Fetches relevant information about a Subversion event.</li>
  <li>Parses that information for a number of different outputs.</li>
  <li>Writes the event information into one or more outputs (currently plain text or XHTML).</li>
  <li>Constructs an email message from the outputs</li>
  <li>Sends the email message via a specified method (<code>sendmail</code> or SMTP).</li>
</ul>

<p>For the initial implementation of SVN::Notify, this made a lot of sense,
because it was doing something fairly simple. It was designed to be extensible
by subclassing (successfully done
by <a href="http://search.cpan.org/perldoc?SVN::Notify::Config">SVN::Notify::Config</a>
and
<a href="http://search.cpan.org/perldoc?SVN::Notify::Mirror">SVN::Notify::Mirror</a>),
and, later,
by <a href="http://search.cpan.org/perldoc?SVN::Notify::Filter">output filters</a>, and that was about it.</p>

<p>But as I think about moving stuff to Git, and consider the weaknesses of
extensibility by subclassing (it's just not pretty), I'm naturally rethinking
this architecture. I wouldn't want to have to do it all over again should some
future SCM system come along in the future. So, following from a private
exchange with
<a href="http://search.cpan.org/~martijn/">Martijn Van Beers</a>, I have some
preliminary thoughts on how a hypothetical SCM::Notify (VCS::Notify?) module
might be constructed:</p>

<ul>
  <li>A single interface for fetching SCM activity information. There could be
  any number of implementations, just as long as they all provided the same
  interface. There would be a class for fetching information from Subversion,
  one for Git, one for CVS, etc.</li>
  <li>A single interface for writing a report for a given transaction. Again,
  there could be any number of implementations, but all would have the same
  interface: taking an SCM module and writing output to a file handle.</li>
  <li>A single interface for doing something with one or more outputs. Again,
  they can do things as varied as simply writing files to disk, appending to a
  feed, inserting into a database, or, of course, sending an email.</li>
  <li>The core module would process command-line arguments to determine what
  SCM is being used any necessary contextual information and just pass it on
  to the appropriate classes.</li>
</ul>

<p>In psedudo-code, what I'm thinking is something like this:</p>

<pre>
package SCM::Notify;

sub run {
    my $args = shift->getopt;
    my $scm  = SCM::Interface->new(
        scm      => $args->{scm} # e.g., &quot;SVN&quot; or &quot;Git&quot;, etc.
        revision => $args->{revision},
        context  => $args->{context} # Might include repository path for SVN.
    );

    my $report = SCM::Report->new(
        method => $opts->{method}, # e.g., SMTP, sendmail, Atom, etc.
        scm    => $scm,
        format => $args->{output}, # text, html, both, etc.
        params => $args->{params}, # to, from, subject, etc.
    );

    $report->send;
}
</pre>

<p>Then a report class just has to create report in the specified format or
formats and do something with them. For example, a Sendmail report would put
together a report as a multipart message with each format in a single part,
and then deliver it via <code>/sbin/sendmail</code>, something like this:</p>

<pre>
package SCM::Report::Sendmail;

sub send {
    my $self = shift;
    my $fh = $self->fh;
    for my $format ( $self->formats ) {
        print $fh SCM::Format->new(
            format => $format,
            scm    => $self->scm,
        );
    }

    $self->deliver;
}
</pre>

<p>So those are my rather preliminary thoughts. I think it'd actually be
pretty easy to port the logic of this stuff over from SVN::Notify; what needs
some more thought is what the command-line interface might look like and how
options are passed to the various classes, since the Sendmail report class
will require different parameters than the SMTP report class or the Atom
report class. But once that's worked out in a way that can be handled
neutrally, we'll have a much more extensible implementation that will be easy
to add on to going forward.</p>

<p>Any suggestions for passing different parameters to different classes in a
single interface? Everything needs to be able to be handled via command-line
options and not be ugly or difficult to use.</p>

<p>So, you wanna work on this? :-)</p>
