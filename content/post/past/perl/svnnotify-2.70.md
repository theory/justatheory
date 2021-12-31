--- 
date: 2008-02-29T17:36:49Z
slug: svnnotify-2.70
title: "SVN::Notify 2.70: Output Filtering and Character Encoding"
aliases: [/computers/programming/perl/modules/svnnotify-2.70.html]
tags: [Perl, SVN::Notify, Subversion, Character Encoding, Trac]
type: post
---

I'm very pleased to announce the release of [SVN::Notify] 2.70. You can see an
example of its colordiff output [here]. This is a major release that I've spent
the last several weeks polishing and tweaking to get just right. There are quite
a few [changes], but the two most important are improved character encoding
support and output filtering.

### Improved Character Encoding Support

I've had a number of bug reports regarding issues with character encodings.
Particularly for folks working in Europe and Asia, but really for *anyone* using
multibyte characters in their source code and log messages (and we all do
nowadays, don't we?), it has been difficult to find the proper incantation to
get SVN::Notify to convert data from and to their proper encodings. Using a
patch from Toshikazu Kinkoh as a starting-point, and with a lot of reading and
experimentation, as well as regular and patient tests on Toshikazu's and Martin
Lindhe's production systems, I think I've finally got it nailed down.

Now you can use the `--encoding` (formerly `--charset`), `--svn-encoding`, and
`--diff-encoding` options—as well as `--language`—to get SVN::Notify to do the
right thing. As long as your Subversion server's OS supports an appropriate
locale, you should be golden (mine is old, with no UTF-8 locales :\\). And if
all else fails, you can still set the `$LANG` environment variable before
executing `svnnotify`.

There is actually a fair bit to know about encodings to get it to work properly,
but if you use UTF-8 throughout and your OS supports UTF-8 locales, you
shouldn't have to do anything. You might have to set `--language` in order to
get it to use the proper locale. See the new [documentation of the encoding
support] for all the details. And if you still have problems, please do [let me
know].

### Output Filtering

Much sexier is the addition of output filtering in SVN::Notify 2.70. I got
pretty tired of getting feature requests for what are essentially formatting
modifications, such as [this one] requesting support for KDE-style [keyword
support]. I myself was using [Trac wiki syntax] in commit messages on a [recent
project] and wanted to see them converted to HTML for messages output by
SVN::Notify::HTML::ColorDiff.

So I finally sat down and gave some though on how to implement a simple plugin
architecture for SVN::Notify. When I realized that it was generally just
formatting that people wanted, it became simpler: I just needed a way to allow
folks to write simple output filters. The solution I came up with was to just
use Perl. Output filters are simply subroutines named for the kind of output
they filter. They live in perl packages. That's it.

For example, say that your developers write their commit log messages in
[Textile], and rather than receive them stuck inside `<pre>` tags, you'd like
them converted to HTML. It's simple. Just put this code in a Perl module file:

    package SVN::Notify::Filter::Textile;
    use Text::Textile ();

    sub log_message {
        my ($notifier, $lines) = @_;
        return $lines unless $notify->content_type eq 'text/html';
        return [ Text::Textile->new->process( join $/, @$lines ) ];
    }

Put the file, *SVN/Notify/Filter/Textile.pm* somewhere in a Perl library
directory. Then use the new `--filter` option to `svnnotify` to put it to work:

    svnnotify -p "$1" -r "$2" --handler HTML::ColorDiff --filter Textile

Yep, that's it! SVN::Notify will find the filter module, load it, register its
filtering subroutine, and then call it at the appropriate time. Of course, there
are a lot of things you can filter; consult the [complete documentation] for all
of the details. But hopefully this gives you a flavor for how easy it is to
write new filters for SVN::Notify. I'm hoping that all those folks who want
features can now stop bugging me and writing their own filters to do the job,
and uploading them to CPAN for all to share!

To get things started, I scratched my own itch, writing a [Trac filter] myself.
The filter is almost as simple as the Textile example above, but I also spent
quite a bit of time tweaking the CSS so that most of the Trac-generated HTML
looks good. You can see an example [right here]. Thanks to a number of bug fixes
in [Text::Trac], as well as Trac-specific CSS added via a filter on CSS output,
it works beautifully. If I'm feeling motivated in the next week or so, I'll
create a separate CPAN distribution with just a Markdown filter and upload it.
That will create a nice distribution example for folks to copy to create their
own. Or maybe someone on the Lazy Web Will do it for me! Maybe *you?*

I wish I'd thought to do this from the beginning; it would have saved me from
having to add so many features/cruft to SVN::Notify over the years. Here's a
quick list of the features that likely could have been implemented via filters
instead of added to the core:

-   `--user-domain`: Combine the SVN username with a domain for the “From”
    header.
-   `--add-header`: Add a header to the message.
-   `--reply-to`: Add a specific header to the message.
-   SVN::Notify::HTML::ColorDiff: Frankly, looking back on it, I don't know why
    I didn't just put this support right into SVN::Notify::HTML. But even if I
    hadn't, it could have been implemented via filters.
-   `--subject-prefix:`: Modify the message subject.
-   `--subject-cx`: Add the commit context to the subject.
-   `--strip-cx-regex`: More subject context modification.
-   `--no-first-line`: Another subject filter.
-   `--max-sub-length`: Yet another!
-   `--max-diff-length`: A filter could truncate the diff, although this might
    be tricky with the HTML formatting.
-   `--author-url`: Modify the metadata section to add a link to the author URL.
-   `--revision-url`: Ditto for the revision URL.
-   `--ticket-map`: Filter the log message for various ticketing system strings
    to convert to URLs. This also encompasses the old `--rt-url`,
    `--bugzilla-url`, `--gnats-url`, and `--jira-url` options.
-   `--header`: Filter the beginning of the message.
-   `--footer`: Filter the end of the message.
-   `--linkize`: Filter the log message to convert URLs to links for HTML
    messages.
-   `--css-url`: Filter the CSS to modify it, or filter the start of the HTML to
    add a link to an external CSS URL.
-   `--wrap-log`: Reformat the log message for HTML.

Yes, *really!* That's about half the functionality right there. I'm glad that I
won't have to add any more like that; filters are a *much* better way to go.

So download it, install it, write some filters, get your multibyte characters
output properly, and enjoy! And as usual, send me your [bug reports][let me
know], but implement your own improvements using filters!

  [SVN::Notify]: https://metacpan.org/dist/SVN-Notify "SVN::Notify on MetaCPAN"
  [here]: {{% link "/code/svnnotify/svnnotify-2.70_colordiff_example.html" %}}
    "Example output from SVN::Notify::HTML::ColorDiff 2.70"
  [changes]: https://github.com/theory/svn-notify/blob/v2.70/Changes
    "SVN::Notify Changes"
  [documentation of the encoding support]: https://metacpan.org/dist/SVN-Notify/lib/SVN/Notify.pm#Character_Encoding_Support
    "Character Encoding Support in SVN::Notify"
  [let me know]: https://rt.cpan.org/Ticket/Create.html?Queue=SVN-Notify
    "Open a Ticket for SVN::Notify"
  [this one]: https://rt.cpan.org/Ticket/Display.html?id=26944
    "SVN::Notify feature request for KDE keywords support"
  [keyword support]: http://techbase.kde.org/Policies/SVN_Commit_Policy#Special_keywords_in_SVN_log_messages
    "KDE TechBase: Special keywords in SVN log messages"
  [Trac wiki syntax]: http://trac.edgewall.org/wiki/WikiFormatting
    "Trac Wiki Formatting Syntax"
  [recent project]: http://iwantsandy.com/
    "Sandy: Your virtual personal assistant"
  [Textile]: http://www.textism.com/tools/textile/ "Textile"
  [complete documentation]: https://metacpan.org/dist/SVN-Notify/lib/SVN/Notify/Filter.pm
    "SVN::Notify Output Filtering Documentation"
  [Trac filter]: https://metacpan.org/dist/SVN-Notify/lib/SVN/Notify/Filter/Trac.pm
    "SVN::Notify::Filter::Trac Documentation"
  [right here]: /code/svnnotify/svnnotify-2.70_trac_example.html
    "Example output from SVN::Notify 2.70 and modified by the Trac filter"
  [Text::Trac]: https://metacpan.org/dist/Text-Trac/
