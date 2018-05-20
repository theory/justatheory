--- 
date: 2005-11-11T00:23:23Z
slug: svnnotify-2.50
title: SVN::Notify 2.50
aliases: [/computers/programming/perl/modules/svnnotify_2.50.html]
tags: [Perl, Subversion, SVN::Notify, ativitymail, email, diffs]
type: post
---

[SVN::Notify] 2.50 is currently making its way to CPAN. It has quite a number of
changes since I last wrote about it here, most significantly the slick new CSS
treatment introduced in 2.47, provided by Bill Lynch. I really like the look,
much better than it was before. [Have a look] at the
SVN::Notify::HTML::ColorDiff output to see what I mean. Be sure to make your
browser window rally narrow to see how all of the sections automatically get a
nice horizontal scrollbar when they're wider than the window. Neat, eh? Check
out the [2.40 output] for contrast.

Here are all of the changes since the last version:

2.50 2005-11-10T23:27:22

:   -   Added `--ticket-url` and `--ticket-regex` options to be used by those
        who want to match ticket identifers for systems other than RT, Bugzilla,
        GNATS, and JIRA. Based on a patch from Andrew O'Brien.
    -   Removed bogus `use lib` line put into *Makefile.PL* by a prerelease
        version of Module::Build.
    -   Fixed HTML tests to match either “'” or “&\#39;”, since HTML::Entities
        can be configured differently on different systems.

2.49 2005-09-29T17:26:14

:   -   Now require Getopt::Long 2.34 so that the `--to-regex-map` option works
        correctly when it is used only once on the command-line.

2.48 2005-09-06T19:14:35

:   -   Swiched from `<span class="add">` and `<span class="rem">` to `<ins>`
        and `<del>` elements in SVN::Notify::HTML::ColorDiff in order to make
        the markup more semantic.

2.47 2005-09-03T18:54:43

:   -   Fixed options tests to work correctly with older versions of
        Getopt::Long. Reported by Craig McElroy.
    -   Slick new CSS treatment used for the HTML and HTML::ColorDiff emails.
        Based on a patch from Bill Lynch.
    -   Added `--svnweb-url` option. Based on a patch from Ricardo Signes.

2.46 2005-05-05T05:22:54

:   -   Added support for “Copied” files to HTML::ColorDiff so that they display
        properly.

2.45 2005-05-04T20:38:18

:   -   Added support for links to the [GNATS] bug tracking system. Patch from
        Nathan Walp.

2.44 2005-03-18T06:10:01

:   -   Fixed Name in POD so that SVN::Notify's POD gets indexed by
        [search.cpan.org]. Reported by Ricardo Signes.

2.43 2004-11-24T18:49:40

:   -   Added `--strip-cx-regex` option to strip out parts of the context from
        the subject. Useful for removing parts of the file names you might not
        be interested in seeing in every commit message.
    -   Added `--no-first-line` option to omit the first sentence or line of the
        log message from the subject. Useful in combination with the
        `--subject-cx` option.

2.42 2004-11-19T18:47:20

:   -   Changed “Files” to “Paths” in hash returned by `file_label_map()` since
        directories can be listed as well as files.
    -   Fixed SVN::Notify::HTML so that directories listed among the changed
        paths are not links.
    -   Requiring Module::Build 0.26 to make sure that the installation works
        properly. Reported by Robert Spier.

Enjoy!

  [SVN::Notify]: http://search.cpan.org/dist/SVN-Notify/ "SVN::Notify on CPAN"
  [Have a look]: /computers/programming/perl/modules/svnnotify-2.50_colordiff_example.html
    "SVN::Notify 2.50 sample ColorDiff output"
  [2.40 output]: /computers/programming/perl/modules/svnnotify-2.40_colordiff_example.html
    "SVN::Notify 2.41 sample ColorDiff output"
  [GNATS]: http://www.gnu.org/software/gnats/ "GNATS: The GNU
            Bug Tracking System"
  [search.cpan.org]: http://search.cpan.org/ "CPAN
            Search"
