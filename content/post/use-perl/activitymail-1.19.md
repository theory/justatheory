---
date: 2004-03-11T17:54:26Z
description: Now with file includes and excludes.
lastMod: 2022-10-02T22:39:29Z
slug: activitymail-1.19
tags:
  - use Perl
  - Perl
  - activitymail
title: activitymail 1.19
---

I'm pleased to announce the release of [activitymail] 1.19, currently finding
its way to a CPAN mirror near you. This release has a new feature I've been
wanted to add for a long time, ever since [Ask] mentioned it to me a couple of
years ago. A patch from Gary Meyer ported `log_accume`'s `-I` and `-E` options,
which specify files with a list of regular expressions that can be used to
exclude certain files from being processed via a commit. Now, this was the
feature I wanted, but wasn't exactly how I wanted to do it.

So starting with Gary's patch, I've modified the `-I` and `-E` options to
instead take one or more regular expressions right on the command line. These
regular expressions are then compared to each file processed during the CVS
activity, and then either include the file (in the case of a `-I` regular
expression) or exclude the file (in the case of a `-E` regular expression).
Needless to say, both `-I` and `-E` cannot be included in a single invocation of
activitymail. You can even pass multiple regular expressions to a single `-I` or
`-E` option, delimited by an empty space. This means you can't use spaces in
your regular expressions, though; use `\s`, instead.

The expected use for these new options is in combination with the regular
expressions in the CVS `loginfo` file. You can specify that activitymail be
executed for a particular directory, and then use `-I` or `-E` to include or
exclude specific files in that directory.

One other new feature of activitymail 1.19 is the new `-q` and `-Q` options.
Both options enable a quiet mode for activitymail, eliminating the status
messages typically printed out during a commit (such as "Collecting file
lists..." and "Sending email"). The `-q` option can be used for most cases; the
`-Q` option is exactly the same, except that it also silences the status message
output when an email is larger than the size specified by the `-M` option.

Enjoy!

David

*Originally published [on use Perl;]*

  [activitymail]: http://search.cpan.org/dist/activitymail/
  [Ask]: http://www.askbjoernhansen.com/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/17859/
    "use.perl.org journal of Theory: “activitymail 1.19”"
