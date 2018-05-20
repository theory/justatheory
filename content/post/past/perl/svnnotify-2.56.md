--- 
date: 2006-04-05T00:14:58Z
slug: svnnotify-2.56
title: SVN::Notify 2.56 Adds Alternative Formats
aliases: [/computers/programming/perl/modules/svnnotify_2.56.html]
tags: [Perl, SVN::Notify, Subversion]
type: post
---

I've just uploaded [SVN::Notify] 2.56 to CPAN. Check a mirror near you! There
have been a lot of changes since I last posted about SVN::Notify (for the [2.50
release]), not least of which is that SourceForge has [standardized on it] for
their Subversion roll out. W00t! The result was a couple of patches from
SourceForge's David Burley to add headers and footers and to truncate diffs over
a certain size. See the [sample output] for how it looks. Thanks, David!

The change I'm most pleased with in 2.56 is the addition of
SVN::Notify::Alternative, based on a submission from Jukka Zitting. This new
subclass allows you to actually combine a number of other subclasses into a
single activity notification message. Why? Well, mainly because, though you
might like to get HTML messages with colorized diffs, some mail clients might
not care for the HTML. They would much prefer the plain text version.

SVN::Notify::Alternative allows you to have your cake and eat it too: send a
single message with `multipart/alternative` sections for both HTML output and
plain text. Plain text will always be used; to use HTML::ColorDiff with it, just
do this:

    svnnotify --repos-path "$1" --revision "$2" \
      --to developers@example.com --handler Alternative \
      --alternative HTML::ColorDiff --with-diff

This incantation will send an email with both the plain text and HTML::ColorDiff
formats. If you look at it in Mail.app, you'll see the nice colorized format,
and if you look at it in `pine`, you'll see the plain text.

For the curious, here are all of the changes since 2.50:

2.56 2006-04-04T23:16:37

:   -   Abstracted creation of the diff file handle into the new `diff_handle()`
        method.
    -   Documented use of `diff_handle()` in the output() method.
    -   Added optional second argument to `output()` to optionally suppress the
        output of the email headers. This argument is used by the new
        Alternative subclass.
    -   Added SVN::Notify::Alternative, which allows multiple versions of a
        commit email to be sent, such as text/plain plus HTML. The multiple
        versions are assembled into a single email message using the
        multipart/alternative media type. For those who want HTML messages but
        must support users that can only read plain text or rely on archives
        that ignore HTML messages, this can be very useful. Based on an
        implementation by Jukka Zitting.
    -   Fixed `use_ok()` tests that weren't running at all.
    -   Added an extra newline to separate the file list from an inline diff in
        the plain text format where `--with-diff` has been specified.
    -   Moved the `multipart/mixed` content-type header generation from
        `output_headers()` to `output_content_type()`, not only because this
        makes more sense, but also because it makes attachments behave better
        when using SVN::Notify::Alternative.
    -   Documented accessors in SVN::Notify::HTML.

2.55 2006-04-03T23:11:11

:   -   Added the `io-layer` option to specify an alternate IO layer. Will be
        most useful for those with repositories containing text in multiple
        encodings, where it should be set to “raw”.
    -   Fixed the context output in the subject for the `--subject-cx` option so
        that it's smarter about determining the longest common path. Reported by
        Max Horn.
    -   No longer modifying the values of the `to_regex_map` hash, so as not to
        mess with folks who might be passing it as a hash to more than one call
        to `new()`. Reported by Darby Felton.
    -   Added a `meta http-equiv="content-type"` tag to HTML output that
        includes the character set to help some clients in the proper display of
        the characters in an HTML email. I'm not sure if any clients actually
        need this help, but it certainly can't hurt!
    -   Added the `--css-url` option to specify an alternate style sheet for
        HTML emails. SVN::Notify::HTML's own CSS is left in the email, as well,
        so the specified style sheet can just override the default, rather than
        have to style everything itself. Yes, it takes advantage of the
        “cascading” feature of cascading style sheets! Based on a suggestion by
        Steve James.

2.54 2006-03-06T00:33:42

:   -   Added */usr/bin* to the list of paths searched for executables.
        Suggested by Nacho Barrientos.
    -   Added `--max-diff-length` option. Patch from David Burley/SourceForge.

2.53 2006-02-24T21:30:48

:   -   Added `header` and `footer` attributes and command-line options to
        specify text to be put at the head and foot of each message. For HTML
        messages, the text will be escaped, unless it starts with “\<”, in which
        case it will be assumed to be valid HTML and will therefore not be
        escaped. Either way, it will be output between `<div>` tags with the IDs
        “header” or “footer” as appropriate. Based on a patch from David
        Burley/SourceForge.
    -   Fixed the executable-searching algorithm added in 2.52 to add “.exe” to
        the name of the executable being searched for if `$^O eq 'MSWin32'`.
    -   Fixed encoding issues so that, under Perl 5.8 and later, the IO layer is
        set on file handles so as to encode input and decode output in the
        character set specified by the `charset` attribute. CPAN \# 16050,
        reported by Michael Zehrer.
    -   Added a second argument to all calls to `encode_entities()` in
        SVN::Notify::HTML and SVN::Notify::HTML::ColorDiff so that only '\>'.
        '\<', '&', and '"' are escaped.
    -   Fixed a bug in the `_find_exe()` function that was attempting to modify
        a constant variable. Patch from John Peacock.
    -   Turned the `_find_exe()` function into the `find_exe()` class method,
        since subclasses (such as SVN::Notify::Mirror) might want to use it.

2.52 2006-02-19T18:50:24

:   -   Now uses `File::Spec->path` to search for a validate *sendmail* or
        *svnlook* when they're not specified via their respective command-line
        options or environment variables. Suggested by Andreas Koenig. Not that
        they should probably be explicitly set anyway, as the `$PATH`
        environment variable tends to be non-existent when running under Apache.

2.51 2006-01-02T23:28:11

:   -   Fixed ColorDiff HTML to once again be valid XHTML 1.1.

Enjoy!

  [SVN::Notify]: http://search.cpan.org/dist/SVN-Notify/ "SVN::Notify on CPAN"
  [2.50 release]: /computers/programming/perl/modules/svnnotify_2.50.html
    "SVN::Notify 2.50 Announcement"
  [standardized on it]: http://sourceforge.net/docs/E09#svn_notify
    "SourceForge: Commit Notifications via Email (SVN::Notify)"
  [sample output]: http://www.justatheory.com/computers/programming/perl/modules/svnnotify-2.56_colordiff_example.html
    "Example output from SVN::Notify 2.56"
