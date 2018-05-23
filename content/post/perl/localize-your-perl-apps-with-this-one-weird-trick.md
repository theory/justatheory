--- 
date: 2014-09-06T18:10:00Z
title: Localize Your Perl Apps with this One Weird Trick
aliases: [/l10n/2014/09/06/localize-your-perl-apps-with-this-one-weird-trick/]
tags: [Perl, localization, internationalization, Perl Advent Calendar]
type: post
---

Nota Bene: This is a republication of a [post that originally appeared in the
[2013 Perl Advent Calendar].

---

These days, [gettext] is far and away the most widely-used localization
([l10n]) and internationalization ([i18n]) library for open-source software. So
far, it has not been widely used in the Perl community, even though it's the
most flexible, capable, and easy-to use solution, thanks to
[Locale::TextDomain].[^1l10n:maketext] How easy? Let's get started!

### Module Internationale ###

First, just *use* Locale::TextDomain. Say you're creating an awesome new
module, Awesome::Module. These CPAN distribution will be named
`Awesome-Module`, so that's the "domain" to use for its localizations. Just let
Locale::TextDomain know:

``` perl
use Locale::TextDomain 'Awesome-Module';
```

Locale::TextDomain will later use this string to look for the appropriate
translation catalogs. But don't worry about that just yet. Instead, start using
it to translate user-visible strings in your code. With the assistance of the
Locale::TextDomain's [comprehensive documentation], you'll find it second nature
to internationalize your modules in no time. For example, simple strings are
denoted with `__`:

``` perl
say __ 'Greetings puny human!';
```

If you need to specify variables, use `__x`:

``` perl
say __x(
   'Thank you {sir}, may I have another?',
   sir => $username,
);
```

Need to manage plurals? Use `__n`:

``` perl
say __n(
    'I will not buy this record, it is scratched.',
    'I will not buy these records, they are scratched.',
    $num_records
);
```

If `$num_records` is 1, the first phrase will be used. Otherwise the second.

Sometimes you gotta do both, mix variables and plurals. `__nx` has got you
covered there:

``` perl
say __nx(
    'One item has been grokked.',
    '{count} items have been grokked.',
    $num_items,
    count => $num_items,
);
```

Congratulations! Your module is now internationalized. Wasn't that easy? Make a
habit of using these functions in all the modules in your distribution, always
with the `Awesome-Module` domain, and you'll be set.

#### Encode da Code ####

Locale::TextDomain is great, but it dates from a time when Perl character
encoding was, shall we say, sub-optimal. It therefore took it upon itself to
try to do the right thing, which is to to detect the locale from the runtime
environment and automatically encode as appropriate. Which might work okay if
all you ever do is print localized messages --- and never anything else.

If, on the other hand, you will be manipulating localized strings in your code,
or emitting unlocalized text (such as that provided by the user or read from a
database), then it's probably best to coerce Locale::TextDomain to return Perl
strings, rather than encoded bytes. There's no formal interface for this in
Locale::TextDomain, so we have to hack it a bit: set the `$OUTPUT_CHARSET`
environment variable to "UTF-8" and then bind a filter. Don't know what that
means? Me neither. Just put this code somewhere in your distribution where it
will always run early, before anything gets localized:

``` perl
use Locale::Messages qw(bind_textdomain_filter);
use Encode;
BEGIN {
    $ENV{OUTPUT_CHARSET} = 'UTF-8';
    bind_textdomain_filter 'Awesome-Module' => \&Encode::decode_utf8;
}
```

You only have to do this once per domain. So even if you use Locale::TextDomain
with the `Awesome-Module` domain in a bunch of your modules, the presence of
this code in a single early-loading module ensures that strings will always be
returned as Perl strings by the localization functions.

#### Environmental Safety ####

So what about output? There's one more bit of boilerplate you'll need to throw
in. Or rather, put this into the `main` package that uses your modules to begin
with, such as the command-line script the user invokes to run an application.

First, on the shebang line, follow [Tom Christiansen's advice] and put `-CAS`
in it (or set the `$PERL_UNICODE` environment variable to `AS`). Then use the
[POSIX `setlocale`] function to the appropriate locale for the runtime
environment. How? Like this:

``` perl
#!/usr/bin/perl -CAS

use v5.12;
use warnings;
use utf8;
use POSIX qw(setlocale);
BEGIN {
    if ($^O eq 'MSWin32') {
        require Win32::Locale;
        setlocale POSIX::LC_ALL, Win32::Locale::get_locale();
    } else {
        setlocale POSIX::LC_ALL, '';
    }
}

use Awesome::Module;
```

Locale::TextDomain will notice the locale and select the appropriate
translation catalog at runtime.

### Is that All There Is? ###

Now what? Well, you could do nothing. Ship your code and those
internationalized phrases will be handled just like any other string in your
code.

But what's the point of that? The real goal is to get these things translated.
There are two parts to that process:

1. Parsing the internationalized strings from your modules and creating
   language-specific translation catalogs, or "[PO files]", for translators to
   edit. These catalogs should be maintained in your source code repository.

2. Compiling the PO files into binary files, or "[MO files]", and distributing
   them with your modules. These files should *not* be maintained in
   your source code repository.

Until a year ago, there was no Perl-native way to manage these processes.
Locale::TextDomain ships with a [sample Makefile] demonstrating the appropriate
use of the [GNU gettext] command-line tools, but that seemed a steep price for
a Perl hacker to pay.

A better fit for the Perl hacker's brain, I thought, is Dist::Zilla. So I wrote
[Dist::Zilla::LocaleTextDomain] to encapsulate the use of the gettext
utiltiies. Here's how it works.

First, configuring Dist::Zilla to compile localization catalogs for
distribution: add these lines to your `dist.ini` file:

``` ini
[ShareDir]
[LocaleTextDomain]
```

There are [configuration attributes] for the `LocaleTextDomain` plugin, such as
where to find the PO files and where to put the compiled MO files. In case you
didn't use your distribution name as your localization domain in your modules,
for example:

``` perl
use Locale::TextDomain 'com.example.perl-libawesome';
```

Then you'd set the `textdomain` attribute so that the `LocaleTextDomain` plugin
can find the translation catalogs:

``` ini
[LocaleTextDomain]
textdomain = com.example.perl-libawesome
```

Check out the [configuration docs] for details on all available attributes.

At this point, the plugin doesn't do much, because there are no translation
catalogs yet. You might see this line from `dzil build`, though:

``` sh
[LocaleTextDomain] Skipping language compilation: directory po does not exist
```

Let's give it something to do!

### Locale Motion ###

To add a French translation file, use the [`msg-init`] command[^l10n:gettext]:

``` sh
% dzil msg-init fr
Created po/fr.po.
```

The `msg-init` command uses the [GNU gettext] utilities to scan your Perl
source code and initialize the French catalog, `po/fr.po`. This file is now
ready translation! Commit it into your source code repository so your
agile-minded French-speaking friends can find it. Use `msg-init` to create as
many language files as you like:

``` sh
% dzil msg-init de ja.JIS en_US.UTF-8 en_UK.UTF-8
Created po/de.po.
Created po/ja.po.
Created po/en_US.po.
Created po/en_UK.po.
```

Each language has its on PO file. You can even have region-specific catalogs,
such as the `en_US` and `en_UK` variants here. Each time a catalog is updated,
the changes should be committed to the repository, like code. This allows the
latest translations to always be available for compilation and distribution.
The output from `dzil build` now looks something like:

``` sh
po/fr.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.
po/ja.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.
po/en_US.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.
po/en_UK.po: 10 translated messages, 1 fuzzy translation, 0 untranslated messages.
```

The resulting MO files will be in the shared directory of your distribution:

``` sh
% find Awesome-Module-0.01/share -type f
Awesome-Module-0.01/share/LocaleData/de/LC_MESSAGES/Awesome-Module.mo
Awesome-Module-0.01/share/LocaleData/en_UK/LC_MESSAGES/Awesome-Module.mo
Awesome-Module-0.01/share/LocaleData/en_US/LC_MESSAGES/Awesome-Module.mo
Awesome-Module-0.01/share/LocaleData/ja/LC_MESSAGES/Awesome-Module.mo
```

From here [Module::Build] or [ExtUtils::MakeMaker] will install these MO files
with the rest of your distribution, right where Locale::TextDomain can find
them at runtime. The PO files, on the other hand, won't be used at all, so you
might as well exclude them from the distribution. Add this line to your
`MANIFEST.SKIP` to prevent the `po` directory and its contents from being
included in the distribution:

``` perl
^po/
```

### Mergers and Acquisitions ###

Of course no code base is static. In all likelihood, you'll change your code
--- and end up adding, editing, and removing localizable strings as a result.
You'll need to periodically merge these changes into all of your translation
catalogs so that your translators can make the corresponding updates. That's
what the the [`msg-merge`] command is for:

``` sh
% dzil msg-merge
extracting gettext strings
Merging gettext strings into po/de.po
Merging gettext strings into po/en_UK.po
Merging gettext strings into po/en_US.po
Merging gettext strings into po/ja.po
```

This command re-scans your Perl code and updates all of the language files. Old
messages will be commented-out and new ones added. Commit the changes and give
your translators a holler so they can keep the awesome going.

#### Template Scan ####

The `msg-init` and `msg-merge` commands don't actually scan your source code.
Sort of lied about that. Sorry. What they actually do is merge a template file
into the appropriate catalog files. If this template file does not already
exist, a temporary one will be created and discarded when the initialization or
merging is done.

But projects commonly maintain a permanent template file, stored in the source
code repository along with the translation catalogs. For this purpose, we have
the [`msg-scan`] command. Use it to create or update the template, or POT file:

``` sh
% dzil msg-scan
extracting gettext strings into po/Awesome-Module.pot
```

From here on in, the resulting `.pot` file will be used by `msg-init` and
`msg-merge` instead of scanning your code all over again. But keep in mind that,
if you do maintain a POT file, future merges will be a two-step process: First
run `msg-scan` to update the POT file, then `msg-merge` to merge its changes
into the PO files:

``` sh
% dzil msg-scan
extracting gettext strings into po/Awesome-Module.pot
% dzil msg-merge
Merging gettext strings into po/de.po
Merging gettext strings into po/en_UK.po
Merging gettext strings into po/en_US.po
Merging gettext strings into po/ja.po
```

### Lost in Translation ###

One more thing, a note for translators. They can, of course, also use
`msg-scan` and `msg-merge` to update the catalogs they're working on. But how
do they test their translations? Easy: use the [`msg-compile`] command to
compile a single catalog:

``` sh
% dzil msg-compile po/fr.po
[LocaleTextDomain] po/fr.po: 195 translated messages.
```

The resulting compiled catalog will be saved to the `LocaleData` subdirectory
of the current directory, so it's easily available to your app for testing.
Just be sure to tell Perl to include the current directory in the search path,
and set the `$LANGUAGE` environment variable for your language. For example,
here's how I test the [Sqitch] French catalog:

``` sh
% dzil msg-compile po/fr.po              
[LocaleTextDomain] po/fr.po: 148 translated messages, 36 fuzzy translations, 27 untranslated messages.
% LANGUAGE=fr perl -Ilib -CAS -I. bin/sqitch foo
"foo" n'est pas une commande valide
```

Just be sure to delete the `LocaleData` directory when you're done --- or at
least don't commit it to the repository.

### TL;DR ###

This may seem like a lot of steps, and it is. But once you have the basics in
place --- Configuring the [Dist::Zilla::LocaleTextDomain] plugin, setting up
the "textdomain filter", setting and the locale in the application --- there
are just a few habits to get into:

* Use the functions `__`, `__x`, `__n`, and `__nx` to internationalize
  user-visible strings
* Run `msg-scan` and `msg-merge` to keep the catalogs up-to-date
* Keep your translators in the loop.

The [Dist::Zilla::LocaleTextDomain] plugin will do the rest.

  [^1l10n:maketext]: What about [Locale::Maketext], you ask? It has not, alas,
    withsthood the test of time. For details, see Nikolai Prokoschenko's epic 2009
    polemic, "[On the state of i18n in Perl]." See also Steffen Winkler's
    presentation, [Internationalisierungs-Framework auswählen]
    \(and the [English translation] by [Aristotle Pagaltzis]), from
    [German Perl Workshop 2010].

  [^l10n:gettext]: The `msg-init` function --- like all of the `dzil msg-*`
    commands --- uses the [GNU gettext] utilities under the hood. You'll need a
    reasonably modern version in your path, or else it won't work.

  [2013 Perl Advent Calendar]: http://perladvent.org/2013/2013-12-09.html
  [gettext]: http://en.wikipedia.org/wiki/Gettext "Wikipedia: “gettext”"
  [l10n]: http://en.wikipedia.org/wiki/Language_localisation
    "Wikipedia: “Localization”"
  [i18n]: http://en.wikipedia.org/wiki/Internationalization_and_localization
    "Wikipedia: “Internationalization and Localization”"
  [Locale::TextDomain]: https://metacpan.org/module/Locale::TextDomain
    "Locale::TextDomain on CPAN"
  [comprehensive documention]:
    https://metacpan.org/pod/Locale::TextDomain#EXPORTED-FUNCTIONS
    "Locale::TextDomain Exported Functions"
  [Tom Christiansen's advice]: http://stackoverflow.com/a/6163129/79202
    "Perl UTF-8 Recommendations on Stack Overflow"
  [POSIX `setlocale`]: https://metacpan.org/pod/POSIX#setlocale
    "POSIX on CPAN"
  [PO files]: https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html
    "GNU gettext: PO Files"
  [MO files]: https://www.gnu.org/software/gettext/manual/html_node/MO-Files.html
    "GNU gettext: MO Files"
  [sample Makefile]:
    https://metacpan.org/source/GUIDO/libintl-perl-1.23/sample/simplecal/po/Makefile
    "Sample Locale::TextDomain Makefile"
  [GNU gettext]: https://www.gnu.org/software/gettext/
  [Dist::Zilla::LocaleTextDomain]:
    https://metacpan.org/module/Dist::Zilla::LocaleTextDomain
    "Dist::Zilla::LocaleTextDomain on CPAN"
  [configuration attributes]:
    https://metacpan.org/pod/Dist::Zilla::Plugin::LocaleTextDomain#Configuration
    "Dist::Zilla LocaleTextDomain Configuration"
  [configuration docs]:
    https://metacpan.org/pod/Dist::Zilla::Plugin::LocaleTextDomain#Configuration
    "Dist::Zilla LocaleTextDomain Configuration"
  [`msg-init`]: https://metacpan.org/pod/Dist::Zilla::App::Command::msg_init
    "dzil msg-init documentation on CPAN"
  [`msg-merge`]: https://metacpan.org/pod/Dist::Zilla::App::Command::msg_merge
    "dzil msg-merge documentation on CPAN"
  [`msg-scan`]: https://metacpan.org/pod/Dist::Zilla::App::Command::msg_scan
    "dzil msg-scan documentation on CPAN"
  [`msg-compile`]: https://metacpan.org/pod/Dist::Zilla::App::Command::msg_compile
    "dzil msg-compile documentation on CPAN"
  [Module::Build]: https://metacpan.org/module/Module::Build
    "Module::Build on CPAN"
  [ExtUtils::MakeMaker]: https://metacpan.org/module/ExtUtils::MakeMaker
    "ExtUtils::MakeMaker on CPAN"
  [Locale::Maketext]: https://metacpan.org/module/Locale::Maketext
    "Locale::Maketext on CPAN"
  [On the state of i18n in Perl]: http://rassie.org/archives/247
  [Internationalisierungs-Framework auswählen]:
    http://download.steffen-winkler.de/dpws2010/I18N_STEFFENW.pod
  [English translation]: https://gist.github.com/ap/909197
  [Aristotle Pagaltzis]:
    http://blogs.perl.org/users/aristotle/2011/04/stop-using-maketext.html
  [German Perl Workshop 2010]: http://conferences.yapceurope.org/gpw2010/
  [GNU gettext]: https://www.gnu.org/software/gettext/
