--- 
date: 2004-09-14T03:13:00Z
slug: utf8-trials
title: Lessons Learned with Perl and UTF-8
aliases: [/computers/programming/perl/utf8_trials.html]
tags: [Perl, Bricolage, Unicode, UTF-8]
type: post
---

I learned quite a lot last week as I was making Bricolage much more
Unicode-aware. Bricolage has always managed Unicode content and stored it in a
PostgreSQL Unicode-encoded database. And by “Unicode” I of course mean “UTF-8”.
By far the biggest nightmare was figuring out [the bug with
`Apache::Util::escape_html()`], but ultimately it came down to an interesting
lesson.

Why was I making Bricolage Unicode-aware? Well, it all started with a [bug
report] from Kang-min Liu [(a.k.a. “Gugod”)]. I had naïvely thought that if
strings were Unicode that Perl would know it and do the right thing. It turns
out I was wrong. Perl assumes that everything is binary unless you tell it
otherwise. This means that Perl operators such as `length` and `substr` will
count bytes instead of characters. And in the case of Unicode, where characters
can be multiple bytes, this can cause serious problems. Not only were strings
improperly concatenated mid-character for Gugod, but PostgreSQL could [refuse to
accept] such strings, since a chopped-up multibyte character isn't valid
Unicode!

So I had to make some decisions: Either stop using Perl operators that count
bytes, or let Perl know that all the strings that Bricolage deals with are
Unicode strings. The former wasn't really an option, of course, since users can
specify that certain content fields be a certain length of characters. So with a
lot of testing help from Gugod and his Bricolage install full of multibyte
characters, I set about doing so. The result is in the recently released
[Bricolage 1.8.2] and I'm blogging what I learned for both your reference and
mine.

Perl considers its internal representation of strings to be UTF-8 strings, and
it knows what variables contain valid UTF-8 strings because they have a special
flag set on them, called, strangely enough, `utf8`. This flag isn't set by
default, but can be set in a number of ways. The ways I've found so far are:

-   Using `Encode::decode()` to decode a string from binary to Perl's internal
    representation. The use of the word “decode” here had confused me for a
    while, because I thought it was a special encoding. But the truth is that
    it's not. Strings can have any number of encodings, such as “ISO-8859-1”,
    “GB3212”, “EUC-KR”, “UTF-8”, and the like. But when you “decode” a string,
    you're telling Perl that it's not any of those encodings, but Perl's own
    representation. I was confused because Perl's internal representation is
    UTF-8, which is an encoding. But really it's not UTF-8, It's “utf8”, which
    isn't an encoding, but Perl's own thing.

-   Cheat: Use `Encode::_set_utf8_on()`. This private function is nevertheless
    documented by the [Encode module], and therefore usable. What it does is
    simply turn on the `utf8` flag on a variable. You need be confident that the
    variable contains only valid UTF-8 characters, but if it does, then you
    should be pretty safe.

-   Using the three-argument version of `open`, such as

        open my $fh, "<utf8", "/foo/bar"
          or die "Cannot open file: $!\n"

    Now when you read lines from this file, they will automatically be decoded
    to `utf8`.

-   Using `binmode` to set the mode on a file handle:

        binmode $fh, ":utf8";

    As with the three-argument version of `open` this forces Perl to decode the
    strings read from the file handle.

-   `use utf8;`. This Perl pragma indicates that everything within its scope is
    UTF-8, and therefore should be decoded to `utf8`.

So I started applying these approaches in various places. The first thing I did
was to set the `utf8` flag on data coming from the browser with
`Encode::_set_utf8_on()`. Shitty browsers can of course send shitty data, but
I'm deciding, for the moment at least, to trust browser to send only UTF-8 when
I tell them that's what I want. This solved Gugod's immediate problem, and I
happily closed the bug. But then he started to run into places where strings
appeared properly in some places but not in others. We spent an entire day
(night for Gugod--I really appreciated the help!) tracking down the problem, and
there turned out to be two of them. One was the the bug with
`Apache::Util::escape_html()` that I've [described elsewhere][the bug with
`Apache::Util::escape_html()`], but the other proved more interesting.

It seems that if you concatenate a UTF-8 string with the `utf8` flagged turned
on with a UTF-8 string without `utf8` turned on, the text in the unflagged
variable turns to crap! I have no idea why this is, but Gugod noticed that
strings pulled into the UI from the Bricolage zh\_tw localization library simply
didn't display properly. I had him add `use utf8;` to the zh\_tw module, and the
problem went away!

So the lesson learned here is: If you're going to make Perl strings
Unicode-aware, then **all** of your Perl strings need to be Unicode-aware. It's
an all or nothing kind of thing.

So while setting the `utf8` flag on browser submits and adding `use utf8;` to
the localization modules got us part of the way toward a solution, it turned out
to be trickier than I expected to get the `utf8` flag set on everything. The
places I needed to get it working were in the UI Mason components, in templates,
and in strings pulled from the database.

It took a bit of research, but I think I successfully figured out how to make
the UI Mason components UTF-8 aware. I just added `preamble => "use utf8\n;"` to
the creation of the Mason interpretor. This gets passed on to is compiler, and
now that string is added to the beginning of every template. This made things
behave better in the UI. I applied the same approach to the interpreter created
for Mason templates with equal success.

I'm less confident that I pulled it off for the HTML::Template and Template
Toolkit templating architectures. In a [discussion] on the templates mailing
list, Andy Wardley [suggested] that it wasn't currently possible. But I wasn't
so sure. It seemed to me that, since Bricolage reads in the templates and asks
TT to execute them within a certain scope, that I could just set the mode to
`utf8` on the file handle and then execute the template within the scope of a
`use utf8;` statement. So that's what I did. Feedback on whether it works or not
would be warmly welcomed.

I tried a similar approach with the HTML::Template burner. Again, the burner
reads the templates from files and passes them to HTML::Template for execution
(as near as I could tell, anyway; I'm not an HTML::Template template user).
Hopefully it'll just work.

So that just left the database. Since the database is Unicode-only, all I needed
to do was to turn on the `utf8` flag for all content pulled from the database.
Amazingly, this hasn't come up as an issue for people very much, because DBI
doesn't do anything about Unicode. I [picked up an older discussion] started by
Matt Sergeant on the dbi-dev mail list, but it looks like it might be a while
before DBI has fast, integrated support for turning `utf8` on and off for
various database handles and columns. I look forward to it, though, because it's
likely to be very efficient. I greatly look forward to seeing the results of
[Tim's work] in the next release of DBI. I opened another [bug report][1] to
remind myself to take advantage of the new feature when it's ready.

So in the meantime, I needed to find another solution. Fortunately, my fellow
PostgreSQL users had run into it before, and added what I needed to [DBD::Pg]
back in version 1.22. The `pg_enable_utf8` database handle parameter forces the
`utf8` flag to be turned on for all string data returned from the database. I
added this parameter to Bricolage, and now all data pulled from the database is
`utf8`. And so are the UI components, templates, localization libraries, and
data submitted from browsers. I think that nailed everything, but I know that
Unicode issues are a slippery slope. I can't wait until I have to deal with them
again!

**Not.**

  [the bug with `Apache::Util::escape_html()`]: /computers/programming/perl/mod_perl/escape_html_utf8.html
    "Apache::Util::escape_html() Doesn't Like Perl UTF-8 Strings"
  [bug report]: http://bugs.bricolage.cc/show_bug.cgi?id=648
    "substr() either crap utf8 string or mis-count the length in bytes."
  [(a.k.a. “Gugod”)]: http://gugod.org/blog/ "Gugod's blog: The Mind Of Random"
  [refuse to accept]: http://bugs.bricolage.cc/show_bug.cgi?id=709#c14
    "Two bugs in
    one!"
  [Bricolage 1.8.2]: /bricolage/announce/1.8.2.html "Bricolage 1.8.2 Released"
  [Encode module]: http://search.cpan.org/dist/Encode/ "Encode on CPAN"
  [discussion]: http://www.template-toolkit.org/pipermail/templates/2004-September/006583.html
    "Add utf8 to All Templates?"
  [suggested]: http://www.template-toolkit.org/pipermail/templates/2004-September/006584.html
    "Andy Wardley Replies"
  [picked up an older discussion]: http://www.mail-archive.com/dbi-dev@perl.org/msg03451.html
    "UTF-8
    flags (again)"
  [Tim's work]: http://www.mail-archive.com/dbi-dev@perl.org/msg03452.html
    "Tim Bunce Responds"
  [1]: http://bugs.bricolage.cc/show_bug.cgi?id=802
    "Set SvUTF8_on on Data Fetched from Database"
  [DBD::Pg]: http://search.cpan.org/dist/DBD-Pg/ "DBD::Pg on CPAN"
