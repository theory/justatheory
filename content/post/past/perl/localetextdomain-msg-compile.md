--- 
date: 2013-01-08T23:36:51Z
slug: localetextdomain-msg-compile
title: Dist::Zilla::LocaleTextDomain for Translators
aliases: [/computers/programming/perl/modules/localetextdomain-msg-compile.html]
tags: [Perl, Translation, Localization, Internationalization]
type: post
---

Here’s a followup on my post about [localizing Perl modules with
Locale::TextDomain]. [Dist::Zilla::LocaleTextDomain] was great for developers,
less so for translators. A [Sqitch] translator asked how to test the translation
file he was working on. My only reply was to compile the whole module, then
install it and test it. Ugh.

Today, I released [Dist::Zilla::LocaleTextDomain
v0.85][Dist::Zilla::LocaleTextDomain] with a new command, [`msg-compile`]. This
command allows translators to easily compile just the file they’re working on
and nothing else. For pure Perl modules in particular, it’s pretty easy to test
then. By default, the compiled catalog goes into `./LocaleData`, where
convincing the module to find it is simple. For example, I updated the [test
`sqitch` app] to take advantage of this. Now, to test, say, the French
translation file, all the translator has to do is:

    > dzil msg-compile po/fr.po
    [LocaleTextDomain] po/fr.po: 155 translated messages, 24 fuzzy translations, 16 untranslated messages.

    > LANGUAGE=fr ./t/sqitch foo
    "foo" n'est pas une commande valide

I hope this simplifies things for translators. See the [notes for translators]
for a few more words on the subject.

  [localizing Perl modules with Locale::TextDomain]: /computers/programming/perl/modules/dist-zilla-localetextdomain.html
  [Dist::Zilla::LocaleTextDomain]: https://metacpan.org/module/Dist::Zilla::LocaleTextDomain
  [Sqitch]: http://sqitch.org/ "Sqitch: Sane database change management"
  [`msg-compile`]: https://metacpan.org/module/Dist::Zilla::App::Command::msg_compile
  [test `sqitch` app]: https://github.com/theory/sqitch/blob/master/t/sqitch
  [notes for translators]: https://metacpan.org/module/Dist::Zilla::LocaleTextDomain#But-Im-a-Translator
