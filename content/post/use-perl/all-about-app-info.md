---
date: 2002-06-04T23:49:10Z
description: An API for Collecting Application Metadata.
lastMod: 2022-10-02T22:39:29Z
slug: all-about-app-info
tags:
  - use Perl
  - Perl
  - App::Info
title: All about App::Info
---

Yesterday I released [App::Info] to the CPAN. I started it on Friday, and put
the finishing touches on it just yesterday. It was a busy weekend.

I got the idea for App::Info after looking at the work [Sam Tregar] has done
building an [installer] for Bricolage. He had done all this work to determine
whether and how Apache, PostgreSQL, Expat, and `libiconv` had been installed,
and it seemed a shame not to take that code and generalize it for use by others.
So I whipped up App::Info, with the idea of building a framework for aggregating
data about applications of all kinds, specifically for the purpose of
determining dependencies before installing software.

I think it has turned out rather well so far. I added code to determine the
version numbers of `libiconv` and Expat, although it's imperfect (and that
accounts for the CPAN-Testers failures -- I'll have a better release with some
of the bugs fixed shortly). But overall the idea is for this to be a uniform
architecture for learning about software installed on a system, and I'd like to
invite folks to contribute new App::Info subclasses that provide metadata for
the applications for which they're most familiar.

That said, this is a new module, and still in flux. I've been talking to [Dave
Rolsky] about it, as he has been thinking about the need for something like
this, himself. In the past, Dave and I have talked about creating a generalized
API for installing software, and Dave has even set up a [Savannah project] for
that purpose. In truth, I had envisioned App::Info as one part of such an
initiative -- the part responsible for determining what's already installed. And
while the API I've created is good for this, Dave points out that it's not
enough. We need something that can also prompt the user for information -- to
determine if the right copy of an application was found, for example.

I think I can work this in to App::Info relatively easily, however. Currently,
if App::Info can't find the data it needs, it issues warnings. But this isn't
the best approach, I think. Sometimes, you might want such errors to trigger
exceptions. Other times, you might want them totally silent. So I was planning
to add a flag to the API such that you can specify the behavior for such errors.
Something like DBI's `RaiseError` or `PrintError` options. But then, it's just
another step to add a prompting option. Such an option can be changed to prompt
for new data at every step of the process, or only at important points (like
finding the proper copy of `httpd` on the file system) or only when data can't
be found.

So I hope to find the tuits to add this functionality in the next week. In the
meantime, I'm going to try to keep up-to-date on my journal more.

*Originally published [on use Perl;]*

  [App::Info]: http://search.cpan.org/search?dist=App-Info
  [Sam Tregar]: http://use.perl.org/user/samtregar/
  [installer]: http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/bricolage/bricolage/inst/
  [Dave Rolsky]: http://use.perl.org/user/autarch/
  [Savannah project]: https://savannah.gnu.org/projects/perlappinst/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/5423/
    "use.perl.org journal of Theory: “All about App::Info”"
