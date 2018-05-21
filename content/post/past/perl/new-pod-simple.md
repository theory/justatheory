--- 
date: 2009-10-27T23:21:49Z
slug: new-pod-simple
title: Pod::Simple 3.09 Hits the CPAN
aliases: [/computers/programming/perl/modules/new-pod-simple.html]
tags: [Perl, Pod, Pod::Simple, Allison Randal]
type: post
---

I spent some time over the last few days helping Allison fix bugs and close
tickets for a new version of [Pod::Simple]. I'm not sure how I convinced Allison
to suddenly dedicate her day to fixing Pod::Simple bugs and putting out a new
release. She must've had some studies or Parrot spec work she wanted to get out
of or something.

Either way, it's got some useful fixes and improvements:

-   The XHTML formatter now supports tables of contents (via the
    poorly-named-but-consistent-with-the-HTML-formatter `index` parameter).

-   You can now reformat verbatim blocks via the `strip_verbatim_indent`
    parameter/method. Because you have to indent verbatim blocks (code examples)
    with one or more spaces, you end up with those spaces remaining in output.
    Just have a look at [an example] on search.cpan.org. See how the code in the
    Synopsis is indented? That's because it's indented in the POD. But maybe you
    don't want it to be indented in your final output. If not, you can strip out
    leading spaces via `strip_verbatim_indent`. Pass in the text to strip out:

    ``` perl
    $parser->strip_verbatim_indent('  ');
    ```

    Or a code reference that figures out what to strip out. I'm fond of
    stripping based on the indentation of the first line, like so:

    ``` perl
    $new->strip_verbatim_indent(sub {
        my $lines = shift;
        (my $indent = $lines->[0]) =~ s/\S.*//;
        return $indent;
    });
    ```

-   You can now use the `nocase` parameter to Pod::Simple::PullParser to tell
    the parser to ignore the case of POD blocks when searching for author,
    title, version, and description information. This is a hack that Graham has
    used for a while on search.cpan.org, in part because I nagged him about my
    modules, which don't use uppercase `=head1` text. Thanks Graham!

-   Fixed entity encoding in the XHTML formatter. It was failing to encode
    entities everywhere except code spans and verbatim blocks. Oops. It also now
    properly encodes `E<sol>` and `E<verbar>`, as well as numeric entities.

-   Multiparagraph items now work properly in the XHTML formatter, as do text
    items (definition lists).

-   A POD tag found inside a complex POD tag (e.g., `C<<<     C<foo> >>>`) is
    now properly parsed as text and entities instead of a tag embedded in a tag
    (e.g., `<foo>`). This is in compliance with [perlpod].

This last item is the only change I think might lead to problems. I fixed it in
response to a [bug report] from Schwern. The relevant bit from the [perlpod]
spec is:

> A more readable, and perhaps more “plain” way is to use an alternate set of
> delimiters that doesn’t require a single “\>” to be escaped. With the Pod
> formatters that are standard starting with perl5.5.660, doubled angle brackets
> (“\<\<” and “\>\>”) may be used if and only if there is whitespace right after
> the opening delimiter and whitespace right before the closing delimiter! For
> example, the following will do the trick:
> 
>     C<< $a <=> $b >>
>
> In fact, you can use as many repeated angle‐brackets as you like so long as
> you have the same number of them in the opening and closing delimiters, and
> make sure that whitespace immediately follows the last ’\<’ of the opening
> delimiter, and immediately precedes the first “\>” of the closing delimiter.
> (The whitespace is ignored.) So the following will also work:
>
>     C<<< $a <=> $b >>>
>     C<<<<  $a <=> $b     >>>>
> 
> And they all mean exactly the same as this:
>
>     C<$a E<lt>=E<gt> $b>

Although all of the examples use `C<< >>`, it seems pretty clear that it applies
to all of the span tags (`B<< >>`, `I<< >>`, `F<< >>`, etc.). So I made the
change so that tags embedded in these “complex” tags, as comments in Pod::Simple
call them, are not treated as tags. That is, all `<` and `>` characters are
encoded.

Unfortunately, despite what the perlpod spec says (at least in my reading), Sean
had quite a few pathological examples in the tests that expected POD tags
embedded in complex POD tags to work. Here's an example:

    L<<< Perl B<Error E<77>essages>|perldiag >>>

Before I fixed the bug, that was expected to be output as this XML:

    <L to="perldiag" type="pod">Perl <B>Error Messages</B></L>

After the bug fix, it's:

    <L content-implicit="yes" section="Perl B&#60;&#60;&#60; Error E&#60;77&#62;essages" type="pod">&#34;Perl B&#60;&#60;&#60; Error E&#60;77&#62;essages&#34;</L>

Well, there's a lot more crap that Pod::Simple puts in there, but the important
thing to note is that neither the `B<>` nor the `E<>` is evaluated as a POD tag
inside the `L<<< >>>` tag. If that seems inconsistent at all, just remember that
POD tags still work inside non-complex POD tags (that is, when there is just one
set of angle brackets):

    L<Perl B<Error E<77>essages>|perldiag>

I'm pretty sure that few users were relying on POD tags working inside complex
POD tags anyway. At least I hope so. I'm currently working up a patch for blead
that updates Pod::Simple in core, so it will be interesting to see if it breaks
anyone's POD. Here's to hoping it doesn't!

  [Pod::Simple]: http://search.cpan.org/perldoc?Pod::Simple
    "Pod::Simple on CPAN"
  [an example]: http://search.cpan.org/perldoc?DBIx::Connector "DBix::Connector"
  [perlpod]: http://search.cpan.org/perldoc?perlpod
  [bug report]: https://rt.cpan.org/Public/Bug/Display.html?id=12239
    "C<<< C<<foo>> >>> not rendered properly."
