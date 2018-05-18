--- 
date: 2008-02-29T17:36:49Z
slug: svnnotify-2.70
title: "SVN::Notify 2.70: Output Filtering and Character Encoding"
aliases: [/computers/programming/perl/modules/svnnotify-2.70.html]
tags: [Perl, SVN::Notify, Subversion, character encoding, Trac]
type: post
---

<p>I'm very pleased to announce the release of <a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">SVN::Notify</a> 2.70. You can see an example of its colordiff output <a href="/computers/programming/perl/modules/svnnotify-2.70_colordiff_example.html" title="Example output from SVN::Notify::HTML::ColorDiff 2.70">here</a>. This is a major release that I've spent the last several weeks polishing and tweaking to get just right. There are quite a few <a href="http://search.cpan.org/src/DWHEELER/SVN-Notify-2.70/Changes" title="SVN::Notify Changes">changes</a>, but the two most important are improved character encoding support and output filtering.</p>

<h3>Improved Character Encoding Support</h3>

<p>I've had a number of bug reports regarding issues with character encodings. Particularly for folks working in Europe and Asia, but really for <em>anyone</em> using multibyte characters in their source code and log messages (and we all do nowadays, don't we?), it has been difficult to find the proper incantation to get SVN::Notify to convert data from and to their proper encodings. Using a patch from Toshikazu Kinkoh as a starting-point, and with a lot of reading and experimentation, as well as regular and patient tests on Toshikazu's and Martin Lindhe's production systems, I think I've finally got it nailed down.</p>

<p>Now you can use the <code>&#x002d;&#x002d;encoding</code> (formerly <code>&#x002d;&#x002d;charset</code>), <code>&#x002d;&#x002d;svn-encoding</code>, and <code>&#x002d;&#x002d;diff-encoding</code> options—as well as <code>&#x002d;&#x002d;language</code>—to get SVN::Notify to do the right thing. As long as your Subversion server's OS supports an appropriate locale, you should be golden (mine is old, with no UTF-8 locales :\). And if all else fails, you can still set the <code>$LANG</code> environment variable before executing <code>svnnotify</code>.</p>

<p>There is actually a fair bit to know about encodings to get it to work properly, but if you use UTF-8 throughout and your OS supports UTF-8 locales, you shouldn't have to do anything. You might have to set <code>&#x002d;&#x002d;language</code> in order to get it to use the proper locale. See the new <a href="http://search.cpan.org/dist/SVN-Notify/lib/SVN/Notify.pm#Character_Encoding_Support" title="Character Encoding Support in SVN::Notify">documentation of the encoding support</a> for all the details. And if you still have problems, please do <a href="https://rt.cpan.org/Ticket/Create.html?Queue=SVN-Notify" title="Open a Ticket for SVN::Notify">let me know</a>.</p>

<h3>Output Filtering</h3>

<p>Much sexier is the addition of output filtering in SVN::Notify 2.70. I got pretty tired of getting feature requests for what are essentially formatting modifications, such as <a href="https://rt.cpan.org/Ticket/Display.html?id=26944" title="SVN::Notify feature request for KDE keywords support">this one</a> requesting support for KDE-style <a href="http://techbase.kde.org/Policies/SVN_Commit_Policy#Special_keywords_in_SVN_log_messages" title="KDE TechBase: Special keywords in SVN log messages">keyword support</a>. I myself was using <a href="http://trac.edgewall.org/wiki/WikiFormatting" title="Trac Wiki Formatting Syntax">Trac wiki syntax</a> in commit messages on a <a href="http://iwantsandy.com/" title="Sandy: Your virtual personal assistant">recent project</a> and wanted to see them converted to HTML for messages output by SVN::Notify::HTML::ColorDiff.</p>

<p>So I finally sat down and gave some though on how to implement a simple plugin architecture for SVN::Notify. When I realized that it was generally just formatting that people wanted, it became simpler: I just needed a way to allow folks to write simple output filters. The solution I came up with was to just use Perl. Output filters are simply subroutines named for the kind of output they filter. They live in perl packages. That's it.</p>

<p>For example, say that your developers write their commit log messages in <a href="http://www.textism.com/tools/textile/" title="Textile">Textile</a>, and rather than receive them stuck inside <code>&lt;pre&gt;</code> tags, you'd like them converted to HTML. It's simple. Just put this code in a Perl module file:</p>

<pre>
package SVN::Notify::Filter::Textile;
use Text::Textile ();

sub log_message {
    my ($notifier, $lines) = @_;
    return $lines unless $notify->content_type eq &#x0027;text/html&#x0027;;
    return [ Text::Textile->new->process( join $/, @$lines ) ];
}
</pre>

<p>Put the file, <em>SVN/Notify/Filter/Textile.pm</em> somewhere in a Perl library directory. Then use the new <code>&#x002d;&#x002d;filter</code> option to <code>svnnotify</code> to put it to work:</p>

<pre>
svnnotify -p "$1" -r "$2" &#x002d;&#x002d;handler HTML::ColorDiff &#x002d;&#x002d;filter Textile
</pre>

<p>Yep, that's it! SVN::Notify will find the filter module, load it, register its filtering subroutine, and then call it at the appropriate time. Of course, there are a lot of things you can filter; consult the  <a href="http://search.cpan.org/dist/SVN-Notify/lib/SVN/Notify/Filter.pm" title="SVN::Notify Output Filtering Documentation">complete documentation</a> for all of the details. But hopefully this gives you a flavor for how easy it is to write new filters for SVN::Notify. I'm hoping that all those folks who want features can now stop bugging me and writing their own filters to do the job, and uploading them to CPAN for all to share!</p>

<p>To get things started, I scratched my own itch, writing a <a href="http://search.cpan.org/dist/SVN-Notify/lib/SVN/Notify/Filter/Trac.pm" title="SVN::Notify::Filter::Trac Documentation">Trac filter</a> myself. The filter is almost as simple as the Textile example above, but I also spent quite a bit of time tweaking the CSS so that most of the Trac-generated HTML looks good. You can see an example <a href="/computers/programming/perl/modules/svnnotify-2.70_trac_example.html" title="Example output from SVN::Notify 2.70 and modified by the Trac filter">right here</a>. Thanks to a number of bug fixes in  <a href="http://search.cpan.org/dist/Text-Trac/">Text::Trac</a>, as well as Trac-specific CSS added via a filter on CSS output, it works beautifully. If I'm feeling motivated in the next week or so, I'll create a separate CPAN distribution with just a Markdown filter and upload it. That will create a nice distribution example for folks to copy to create their own. Or maybe someone on the Lazy Web Will do it for me! Maybe <em>you?</em></p>

<p>I wish I'd thought to do this from the beginning; it would have saved me from having to add so many features/cruft to SVN::Notify over the years. Here's a quick list of the features that likely could have been implemented via filters instead of added to the core:</p>

<ul>
  <li><code>&#x002d;&#x002d;user-domain</code>: Combine the SVN username with a domain for the <q>From</q> header.</li>
  <li><code>&#x002d;&#x002d;add-header</code>: Add a header to the message.</li>
  <li><code>&#x002d;&#x002d;reply-to</code>: Add a specific header to the message.</li>
  <li>SVN::Notify::HTML::ColorDiff: Frankly, looking back on it, I don't know why I didn't just put this support right into SVN::Notify::HTML. But even if I hadn't, it could have been implemented via filters.</li>
  <li><code>&#x002d;&#x002d;subject-prefix:</code>: Modify the message subject.</li>
  <li><code>&#x002d;&#x002d;subject-cx</code>: Add the commit context to the subject.</li>
  <li><code>&#x002d;&#x002d;strip-cx-regex</code>: More subject context modification.</li>
  <li><code>&#x002d;&#x002d;no-first-line</code>: Another subject filter.</li>
  <li><code>&#x002d;&#x002d;max-sub-length</code>: Yet another!</li>
  <li><code>&#x002d;&#x002d;max-diff-length</code>: A filter could truncate the diff, although this might be tricky with the HTML formatting.</li>
  <li><code>&#x002d;&#x002d;author-url</code>: Modify the metadata section to add a link to the author URL.</li>
  <li><code>&#x002d;&#x002d;revision-url</code>: Ditto for the revision URL.</li>
  <li><code>&#x002d;&#x002d;ticket-map</code>: Filter the log message for various ticketing system strings to convert to URLs. This also encompasses the old <code>&#x002d;&#x002d;rt-url</code>, <code>&#x002d;&#x002d;bugzilla-url</code>, <code>&#x002d;&#x002d;gnats-url</code>, and <code>&#x002d;&#x002d;jira-url</code> options.</li>
  <li><code>&#x002d;&#x002d;header</code>: Filter the beginning of the message.</li>
  <li><code>&#x002d;&#x002d;footer</code>: Filter the end of the message.</li>
  <li><code>&#x002d;&#x002d;linkize</code>: Filter the log message to convert URLs to links for HTML messages.</li>
  <li><code>&#x002d;&#x002d;css-url</code>: Filter the CSS to modify it, or filter the start of the HTML to add a link to an external CSS URL.</li>
  <li><code>&#x002d;&#x002d;wrap-log</code>: Reformat the log message for HTML.</li>
</ul>

<p>Yes, <em>really!</em> That's about half the functionality right there. I'm glad that I won't have to add any more like that; filters are a <em>much</em> better way to go.</p>

<p>So download it, install it, write some filters, get your multibyte characters output properly, and enjoy! And as usual, send me your <a href="https://rt.cpan.org/Ticket/Create.html?Queue=SVN-Notify" title="Open a Ticket for SVN::Notify">bug reports</a>, but implement your own improvements using filters!</p>
