--- 
date: 2005-11-11T00:23:23Z
slug: svnnotify-2.50
title: SVN::Notify 2.50
aliases: [/computers/programming/perl/modules/svnnotify_2.50.html]
tags: [Perl, Subversion, SVN::Notify, ativitymail, email, diffs]
---

<p><a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">SVN::Notify</a> 2.50 is currently making its way to CPAN. It has quite a number of changes since I last wrote about it here, most significantly the slick new CSS treatment introduced in 2.47, provided by Bill Lynch. I really like the look, much better than it was before. <a href="/computers/programming/perl/modules/svnnotify-2.50_colordiff_example.html" title="SVN::Notify 2.50 sample ColorDiff output">Have a look</a> at the SVN::Notify::HTML::ColorDiff output to see what I mean. Be sure to make your browser window rally narrow to see how all of the sections automatically get a nice horizontal scrollbar when they're wider than the window. Neat, eh? Check out the <a href="/computers/programming/perl/modules/svnnotify-2.40_colordiff_example.html" title="SVN::Notify 2.41 sample ColorDiff output">2.40 output</a> for contrast.</p>

<p>Here are all of the changes since the last version:</p>

<dl>

  <dt>2.50  2005-11-10T23:27:22</dt>
  <dd>
    <ul>
      <li>Added <code>--ticket-url</code> and <code>--ticket-regex</code>
        options to be used by those who want to match ticket identifers for
        systems other than RT, Bugzilla, GNATS, and JIRA. Based on a patch
        from Andrew O'Brien.</li>
      <li>Removed bogus <code>use lib</code> line put
        into <em>Makefile.PL</em> by a prerelease version of Module::Build.</li>
      <li>Fixed HTML tests to match either <q>&#x0027;</q>
        or <q>&amp;#39;</q>, since HTML::Entities can be configured
        differently on different systems.</li>
    </ul>
  </dd>

  <dt>2.49  2005-09-29T17:26:14</dt>
  <dd>
    <ul>
      <li>Now require Getopt::Long 2.34 so that
        the <code>--to-regex-map</code> option works correctly when it is used
        only once on the command-line.</li>
    </ul>
  </dd>

  <dt>2.48  2005-09-06T19:14:35</dt>
  <dd>
    <ul>
      <li>Swiched from <code>&lt;span class=&quot;add&quot;&gt;</code> and
        <code>&lt;span class=&quot;rem&quot;&gt;</code>
        to <code>&lt;ins&gt;</code> and <code>&lt;del&gt;</code> elements in
        SVN::Notify::HTML::ColorDiff in order to make the markup more
        semantic.</li>
    </ul>
  </dd>

  <dt>2.47  2005-09-03T18:54:43</dt>
  <dd>
    <ul>
      <li>Fixed options tests to work correctly with older versions of
        Getopt::Long. Reported by Craig McElroy.</li>
      <li>Slick new CSS treatment used for the HTML and HTML::ColorDiff emails.
        Based on a patch from Bill Lynch.</li>
      <li>Added <code>--svnweb-url</code> option. Based on a patch from
      Ricardo Signes.</li>
    </ul>
  </dd>

  <dt>2.46  2005-05-05T05:22:54</dt>
  <dd>
    <ul>
      <li>Added support for <q>Copied</q> files to HTML::ColorDiff so that
        they display properly.</li>
    </ul>
  </dd>

  <dt>2.45  2005-05-04T20:38:18</dt>
  <dd>
    <ul>
      <li>Added support for links to
        the <a href="http://www.gnu.org/software/gnats/" title="GNATS: The GNU
        Bug Tracking System">GNATS</a> bug tracking system. Patch from Nathan
        Walp.</li>
    </ul>
  </dd>

  <dt>2.44  2005-03-18T06:10:01</dt>
  <dd>
    <ul>
      <li>Fixed Name in POD so that SVN::Notify's POD gets indexed by
        <a href="http://search.cpan.org/" title="CPAN
        Search">search.cpan.org</a>. Reported by Ricardo Signes.</li>
    </ul>
  </dd>

  <dt>2.43  2004-11-24T18:49:40</dt>
  <dd>
    <ul>
      <li>Added <code>--strip-cx-regex</code> option to strip out parts of the
        context from the subject. Useful for removing parts of the file names
        you might not be interested in seeing in every commit message.</li>
      <li>Added <code>--no-first-line</code> option to omit the first sentence
        or line of the log message from the subject. Useful in combination
        with the <code>--subject-cx</code> option.</li>
    </ul>
  </dd>

  <dt>2.42  2004-11-19T18:47:20</dt>
  <dd>
    <ul>
      <li>Changed <q>Files</q> to <q>Paths</q> in hash returned by
        <code>file_label_map()</code> since directories can be listed as well
        as files.</li>
      <li>Fixed SVN::Notify::HTML so that directories listed among the
        changed paths are not links.</li>
      <li>Requiring Module::Build 0.26 to make sure that the installation
        works properly. Reported by Robert Spier.</li>
    </ul>
  </dd>
</dl>

<p>Enjoy!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/modules/svnnotify_2.50.html">old layout</a>.</small></p>


