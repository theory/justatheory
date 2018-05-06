--- 
date: 2006-04-05T00:14:58Z
slug: svnnotify-2.56
title: SVN::Notify 2.56 Adds Alternative Formats
aliases: [/computers/programming/perl/modules/svnnotify_2.56.html]
tags: [Perl, SVN::Notify, Subversion]
---

<p>I've just uploaded <a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">SVN::Notify</a> 2.56 to CPAN. Check a mirror near you! There have been a lot of changes since I last posted about SVN::Notify (for the <a href="/computers/programming/perl/modules/svnnotify_2.50.html" title="SVN::Notify 2.50 Announcement">2.50 release</a>), not least of which is that SourceForge has <a href="http://sourceforge.net/docs/E09#svn_notify" title="SourceForge: Commit Notifications via Email (SVN::Notify)">standardized on it</a> for their Subversion roll out. W00t! The result was a couple of patches from SourceForge's David Burley to add headers and footers and to truncate diffs over a certain size. See the <a href="http://www.justatheory.com/computers/programming/perl/modules/svnnotify-2.56_colordiff_example.html" title="Example output from SVN::Notify 2.56">sample output</a> for how it looks. Thanks, David!</p>

<p>The change I'm most pleased with in 2.56 is the addition of SVN::Notify::Alternative, based on a submission from Jukka Zitting. This new subclass allows you to actually combine a number of other subclasses into a single activity notification message. Why? Well, mainly because, though you might like to get HTML messages with colorized diffs, some mail clients might not care for the HTML. They would much prefer the plain text version.</p>

<p>SVN::Notify::Alternative allows you to have your cake and eat it too: send a single message with <code>multipart/alternative</code> sections for both HTML output and plain text. Plain text will always be used; to use HTML::ColorDiff with it, just do this:</p>

<pre>
svnnotify --repos-path &quot;$1&quot; --revision &quot;$2&quot; \
  --to developers@example.com --handler Alternative \
  --alternative HTML::ColorDiff --with-diff
</pre>

<p>This incantation will send an email with both the plain text and HTML::ColorDiff formats. If you look at it in Mail.app, you'll see the nice colorized format, and if you look at it in <code>pine</code>, you'll see the plain text.</p>

<p>For the curious, here are all of the changes since 2.50:</p>

<dl>
  <dt>2.56  2006-04-04T23:16:37</dt>
  <dd>
    <ul>
      <li>Abstracted creation of the diff file handle into the new <code>diff_handle()</code>
        method.</li>
      <li>Documented use of <code>diff_handle()</code> in the output() method.</li>
      <li>Added optional second argument to <code>output()</code> to optionally suppress the
        output of the email headers. This argument is used by the new
        Alternative subclass.</li>
      <li>Added SVN::Notify::Alternative, which allows multiple versions of a
        commit email to be sent, such as text/plain plus HTML. The multiple
        versions are assembled into a single email message using the
        multipart/alternative media type. For those who want HTML messages but
        must support users that can only read plain text or rely on archives
        that ignore HTML messages, this can be very useful. Based on an
        implementation by Jukka Zitting.</li>
      <li>Fixed <code>use_ok()</code> tests that weren't running at all.</li>
      <li>Added an extra newline to separate the file list from an inline diff
        in the plain text format where <code>--with-diff</code> has been specified.</li>
      <li>Moved the <code>multipart/mixed</code> content-type header generation from
        <code>output_headers()</code> to <code>output_content_type()</code>, not only because this makes
        more sense, but also because it makes attachments behave better when
        using SVN::Notify::Alternative.</li>
      <li>Documented accessors in SVN::Notify::HTML.</li>
    </ul>
  </dd>

  <dt>2.55  2006-04-03T23:11:11</dt>
  <dd>
    <ul>
      <li>Added the <code>io-layer</code> option to specify an alternate IO layer. Will be
        most useful for those with repositories containing text in multiple
        encodings, where it should be set to <q>raw</q>.</li>
      <li>Fixed the context output in the subject for the <code>--subject-cx</code> option
        so that it's smarter about determining the longest common path.
        Reported by Max Horn.</li>
      <li>No longer modifying the values of the <code>to_regex_map</code> hash, so as not
        to mess with folks who might be passing it as a hash to more than one
        call to <code>new()</code>. Reported by Darby Felton.</li>
      <li>Added a <code>meta http-equiv=&quot;content-type&quot;</code> tag to HTML output that
        includes the character set to help some clients in the proper display
        of the characters in an HTML email. I'm not sure if any clients
        actually need this help, but it certainly can't hurt!</li>
      <li>Added the <code>--css-url</code> option to specify an alternate style sheet for
        HTML emails. SVN::Notify::HTML's own CSS is left in the email, as
        well, so the specified style sheet can just override the default,
        rather than have to style everything itself. Yes, it takes advantage
        of the <q>cascading</q> feature of cascading style sheets! Based on a
        suggestion by Steve James.</li>
    </ul>
  </dd>

  <dt>2.54  2006-03-06T00:33:42</dt>
  <dd>
    <ul>
      <li>Added <em>/usr/bin</em> to the list of paths searched for executables.
        Suggested by Nacho Barrientos.</li>
      <li>Added <code>--max-diff-length</code> option. Patch from David Burley/SourceForge.</li>
    </ul>
  </dd>

  <dt>2.53  2006-02-24T21:30:48</dt>
  <dd>
    <ul>
      <li>Added <code>header</code> and <code>footer</code> attributes and command-line options to
        specify text to be put at the head and foot of each message. For HTML
        messages, the text will be escaped, unless it starts with <q>&lt;</q>, in
        which case it will be assumed to be valid HTML and will therefore not
        be escaped. Either way, it will be output between <code>&lt;div&gt;</code> tags with the
        IDs <q>header</q> or <q>footer</q> as appropriate. Based on a patch from David
        Burley/SourceForge.</li>
      <li>Fixed the executable-searching algorithm added in 2.52 to add <q>.exe</q>
        to the name of the executable being searched for if <code>$^O eq &#x0027;MSWin32&#x0027;</code>.</li>
      <li>Fixed encoding issues so that, under Perl 5.8 and later, the IO layer
        is set on file handles so as to encode input and decode output in the
        character set specified by the <code>charset</code> attribute. CPAN # 16050,
        reported by Michael Zehrer.</li>
      <li>Added a second argument to all calls to <code>encode_entities()</code> in
        SVN::Notify::HTML and SVN::Notify::HTML::ColorDiff so that only &#x0027;&gt;&#x0027;.
        &#x0027;&lt;&#x0027;, &#x0027;&amp;&#x0027;, and &#x0027;&quot;&#x0027; are escaped.</li>
      <li>Fixed a bug in the <code>_find_exe()</code> function that was attempting to modify
        a constant variable. Patch from John Peacock.</li>
      <li>Turned the <code>_find_exe()</code> function into the <code>find_exe()</code> class method,
        since subclasses (such as SVN::Notify::Mirror) might want to use it.</li>
    </ul>
  </dd>

  <dt>2.52  2006-02-19T18:50:24</dt>
  <dd>
    <ul>
      <li>Now uses <code>File::Spec-&gt;path</code> to search for a validate <em>sendmail</em> or <em>svnlook</em>
        when they're not specified via their respective command-line options or
        environment variables. Suggested by Andreas Koenig. Not that they
        should probably be explicitly set anyway, as the <code>$PATH</code> environment
        variable tends to be non-existent when running under Apache.</li>
    </ul>
  </dd>

  <dt>2.51  2006-01-02T23:28:11</dt>
  <dd>
    <ul>
      <li>Fixed ColorDiff HTML to once again be valid XHTML 1.1.</li>
    </ul>
  </dd>
</dl>

<p>Enjoy!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/modules/svnnotify_2.56.html">old layout</a>.</small></p>


