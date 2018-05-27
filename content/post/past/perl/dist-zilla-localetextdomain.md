--- 
date: 2012-10-01T20:50:35Z
slug: dist-zilla-localetextdomain
title: Localize Your Perl modules with Locale::TextDomain and Dist::Zilla
aliases: [/computers/programming/perl/modules/dist-zilla-localetextdomain.html]
tags: [Perl, Localization, Internationalization, CPAN, Dist::Zilla]
type: post
---

I've just released [Dist::Zilla::LocaleTextDomain] v0.80 to the CPAN. This
module adds support for managing [Locale::TextDomain]-based localization and
internationalization in your CPAN libraries. I wanted to make it as simple as
possible for CPAN developers to do localization and to support translators in
their projects, and [Dist::Zilla] seemed like the perfect place to do it, since
it has hooks to generate the necessary binary files for distribution.

Starting out with Locale::TextDomain was decidedly non-intuitive for me, as a
Perl hacker, likely because of its [gettext] underpinnings. Now that I've got a
grip on it and created the Dist::Zilla support, I think it's pretty
straight-forward. To demonstrate, I wrote the following brief tutorial, which
constitutes the main documentation for the [Dist::Zilla::LocaleTextDomain][1]
distribution. I hope it makes it easier for you to get started localizing your
Perl libraries.

## Localize Your Perl modules with Locale::TextDomain and Dist::Zilla

[Locale::TextDomain] provides a nice interface for localizing your Perl
applications. The tools for managing translations, however, is a bit arcane.
Fortunately, you can just use [this plugin][1] and get all the tools you need to
scan your Perl libraries for localizable strings, create a language template,
and initialize translation files and keep them up-to-date. All this is assuming
that your system has the [gettext] utilities installed.

### The Details

I put off learning how to use [Locale::TextDomain] for quite a while because,
while the [gettext] tools are great for translators, the tools for the developer
were a little more opaque, especially for Perlers used to [Locale::Maketext].
But I put in the effort while hacking [Sqitch]. As I had hoped, using it in my
code was easy. Using it for my distribution was harder, so I decided to write
Dist::Zilla::LocaleTextDomain to make life simpler for developers who manage
their distributions with [Dist::Zilla].

What follows is a quick tutorial on using [Locale::TextDomain] in your code and
managing it with Dist::Zilla::LocaleTextDomain.

### This is my domain

First thing to do is to start using [Locale::TextDomain] in your code. Load it
into each module with the name of your distribution, as set by the `name`
attribute in your *dist.ini* file. For example, if your *dist.ini* looks
something like this:

``` ini
name    = My-GreatApp
author  = Homer Simpson <homer@example.com>
license = Perl_5
```

Then, in you Perl libraries, load [Locale::TextDomain] like this:

``` perl
use Locale::TextDomain qw(My-GreatApp);
```

[Locale::TextDomain] uses this value to find localization catalogs, so naturally
Dist::Zilla::LocaleTextDomain will use it to put those catalogs in the right
place.

Okay, so it's loaded, how do you use it? The documentation of the
[Locale::TextDomain exported functions] is quite comprehensive, and I think
you'll find it pretty simple once you get used to it. For example, simple
strings are denoted with `__`:

``` perl
say __ 'Hello';
```

If you need to specify variables, use `__x`:

``` perl
say __x(
    'You selected the color {color}',
    color => $color
);
```

Need to deal with plurals? Use `__n`

``` perl
say __n(
    'One file has been deleted',
    'All files have been deleted',
    $num_files,
);
```

And then you can mix variables with plurals with `__nx`:

``` perl
say __nx(
    'One file has been deleted.',
    '{count} files have been deleted.',
    $num_files,
    count => $num_files,
);
```

Pretty simple, right? Get to know these functions, and just make it a habit to
use them in user-visible messages in your code. Even if you never expect to
translate those messages, just by doing this you make it easier for someone else
to come along and start translating for you.

### The setup

Now you're localizing your code. Great! What's next? Officially, nothing. If you
never do anything else, your code will always emit the messages as written. You
can ship it and things will work just as if you had never done any localization.

But what's the fun in that? Let's set things up so that translation catalogs
will be built and distributed once they're written. Add these lines to your
*dist.ini*:

``` ini
[ShareDir]
[LocaleTextDomain]
```

There are actually quite a few attributes you can set here to tell the plugin
where to find language files and where to put them. For example, if you used a
domain different from your distribution name, e.g.,

``` perl
use Locale::TextDomain 'com.example.My-GreatApp';
```

Then you would need to set the `textdomain` attribute so that the
`LocaleTextDomain` does the right thing with the language files:

``` ini
[LocaleTextDomain]
textdomain = com.example.My-GreatApp
```

Consult the [`LocaleTextDomain` configuration docs] for details on all available
attributes.

> (Special note until [this Locale::TextDomain patch] is merged: set the
> `share_dir` attribute to `lib` instead of the default value, `share`. If you
> use [Module::Build], you will also need a subclass to do the right thing with
> the catalog files; see ["Installation" in
> Dist::Zilla::Plugin::LocaleTextDomain] for details.)

What does this do including the plugin do? Mostly nothing. You might see this
line from `dzil build`, though:

    [LocaleTextDomain] Skipping language compilation: directory po does not exist

Now at least you know it was looking for something to compile for distribution.
Let's give it something to find.

### Initialize languages

To add translation files, use the [`msg-init`] command:

    > dzil msg-init de
    Created po/de.po.

At this point, the [gettext] utilities will need to be installed and visible in
your path, or else you'll get errors.

This command scans all of the Perl modules gathered by Dist::Zilla and
initializes a German translation file, named *po/de.po*. This file is now ready
for your German-speaking public to start translating. Check it into your source
code repository so they can find it. Create as many language files as you like:

    > dzil msg-init fr ja.JIS en_US.UTF-8
    Created po/fr.po.
    Created po/ja.po.
    Created po/en_US.po.

As you can see, each language results in the generation of the appropriate file
in the *po* directory, sans encoding (i.e., no *.UTF-8* in the `en_US` file
name).

Now let your translators go wild with all the languages they speak, as well as
the regional dialects. (Don't forget to colour your code with `en_UK`
translations!)

Once you have translations and they're committed to your repository, when you
build your distribution, the language files will automatically be compiled into
binary catalogs. You'll see this line output from `dzil build`:

    [LocaleTextDomain] Compiling language files in po
    po/fr.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.
    po/ja.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.
    po/en_US.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.

You'll then find the catalogs in the shared directory of your distribution:

    > find My-GreatApp-0.01/share -type f
    My-GreatApp-0.01/share/LocaleData/de/LC_MESSAGES/App-Sqitch.mo
    My-GreatApp-0.01/share/LocaleData/en_US/LC_MESSAGES/App-Sqitch.mo
    My-GreatApp-0.01/share/LocaleData/ja/LC_MESSAGES/App-Sqitch.mo

These binary catalogs will be installed as part of the distribution just where
`Locale::TextDomain` can find them.

Here's an optional tweak: add this line to your `MANIFEST.SKIP`:

    ^po/

This prevents the *po* directory and its contents from being included in the
distribution. Sure, you can include them if you like, but they're not required
for the running of your app; the generated binary catalog files are all you
need. Might as well leave out the translation files.

### Mergers and acquisitions

You've got translation files and helpful translators given them a workover. What
happens when you change your code, add new messages, or modify existing ones?
The translation files need to periodically be updated with those changes, so
that your translators can deal with them. We got you covered with the
[`msg-merge`] command:

    > dzil msg-merge
    extracting gettext strings
    Merging gettext strings into po/de.po
    Merging gettext strings into po/en_US.po
    Merging gettext strings into po/ja.po

This will scan your module files again and update all of the translation files
with any changes. Old messages will be commented-out and new ones added. Just
commit the changes to your repository and notify the translation army that
they've got more work to do.

If for some reason you need to update only a subset of language files, you can
simply list them on the command-line:

    > dzil msg-merge po/de.po po/en_US.po
    Merging gettext strings into po/de.po
    Merging gettext strings into po/en_US.po

### What's the scan, man

Both the `msg-init` and `msg-merge` commands depend on a translation template
file to create and merge language files. Thus far, this has been invisible: they
will create a temporary template file to do their work, and then delete it when
they're done.

However, it's common to also store the template file in your repository and to
manage it directly, rather than implicitly. If you'd like to do this, the
[`msg-scan`] command will scan the Perl module files gathered by Dist::Zilla and
make it for you:

    > dzil msg-scan
    gettext strings into po/My-GreatApp.pot

The resulting *.pot* file will then be used by `msg-init` and `msg-merge` rather
than scanning your code all over again. This actually then makes `msg-merge` a
two-step process: You need to update the template before merging. Updating the
template is done by exactly the same command, `msg-scan`:

    > dzil msg-scan
    extracting gettext strings into po/My-GreatApp.pot
    > dzil msg-merge
    Merging gettext strings into po/de.po
    Merging gettext strings into po/en_US.po
    Merging gettext strings into po/ja.po

#### Ship It!

And that's all there is to it. Go forth and localize and internationalize your
Perl apps!

## Acknowledgements

My thanks to [Ricardo Signes] for invaluable help plugging in to Dist::Zilla, to
[Guido Flohr] for providing feedback on this tutorial and being open to my pull
requests, to [David Golden] for I/O capturing help, and to [Jérôme Quelin] for
his patience as I wrote code to do the same thing as
[Dist::Zilla::Plugin::LocaleMsgfmt] without ever noticing that it already
existed.

  [Dist::Zilla::LocaleTextDomain]: https://metacpan.org/release/Dist-Zilla-LocaleTextDomain
  [Locale::TextDomain]: https://metacpan.org/module/Locale::TextDomain
  [Dist::Zilla]: https://metacpan.org/module/Dist::Zilla
  [gettext]: http://www.gnu.org/software/gettext/
  [1]: https://metacpan.org/module/Dist::Zilla::LocaleTextDomain
  [Locale::Maketext]: https://metacpan.org/module/Locale::Maketext
  [Sqitch]: https://metacpan.org/module/App::Sqitch
  [Locale::TextDomain exported functions]: https://metacpan.org/module/Locale::TextDomain#EXPORTED-FUNCTIONS
  [`LocaleTextDomain` configuration docs]: https://metacpan.org/module/Dist::Zilla::Plugin::LocaleTextDomain#Configuration
  [this Locale::TextDomain patch]: https://rt.cpan.org/Public/Bug/Display.html?id=79461
  [Module::Build]: https://metacpan.org/module/Module::Build
  ["Installation" in Dist::Zilla::Plugin::LocaleTextDomain]: https://metacpan.org/module/Dist::Zilla::Plugin::LocaleTextDomain#Installation
  [`msg-init`]: https://metacpan.org/module/Dist::Zilla::App::Command::msg_init
  [`msg-merge`]: https://metacpan.org/module/Dist::Zilla::App::Command::msg_merge
  [`msg-scan`]: https://metacpan.org/module/Dist::Zilla::App::Command::msg_scan
  [Ricardo Signes]: http://rjbs.manxome.org
  [Guido Flohr]: http://guido-flohr.net/
  [David Golden]: http://www.dagolden.com/
  [Jérôme Quelin]: https://metacpan.org/author/JQUELIN
  [Dist::Zilla::Plugin::LocaleMsgfmt]: https://metacpan.org/module/Dist::Zilla::Plugin::LocaleMsgfmt
