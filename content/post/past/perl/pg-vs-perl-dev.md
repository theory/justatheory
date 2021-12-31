--- 
date: 2009-07-13T21:16:17Z
slug: pg-vs-perl-dev
title: "PostgreSQL Development: Lessons for Perl?"
aliases: [/computers/databases/postgresql/perl/pg-vs-perl-dev.html]
tags: [Perl, Postgres, Open Source, Software, Development, Hacking, Perl 5 Porters, pgsql-hackers, Pumpking]
type: post
---

### Pondering Conservatism

I've been following chromatic's [new blog] since it launched, and have read with
particular interest his posts on the Perl 5 development and release process. The
very long time between releases of stable versions of Perl has concerned me for
a while, though I hadn't paid much attention until recently. There has been a
fair amount of discussion about what it means for a release to be “stable,”
from, among others, now-resigned Perl Pumpking [Rafael Garcia-Suarez] and Perl 5
contributor [chromatic]. Reading this commentary, I started to ponder what other
major open-source projects might consider “stable,” and how they manage
stability in their development and release processes. And it occurred to me that
the Perl 5 code base is simultaneously treated too conservatively and -- more
importantly -- *not conservatively enough*. What open-source projects treat
their code highly conservatively?

If you think about most software needs, you will seldom find more conservatism
than in the use of relational databases. It's not just that the code needs to
continue to work version after version, but that the *data* needs to remain
intact. If your application doesn't work quite right on a new version of Perl,
you might lose some time reverting to an older version of Perl. Hell, for a
massive deployment, you might lose a lot of time. But if something happens to
the data in your RDBMS, you could lose your *whole business!* So database
developers need to be extremely careful about their releases -- even more
careful than Perl developers -- so as not to kill off entire businesses with
regressions.

The [PostgreSQL RDBMS] is especially noted for its stability over time. So I
thought it might be worthwhile to look at [how the PostgreSQL project works].

### PostgreSQL Development Organization

First, there is no one person in charge of PostgreSQL development. There is no
[benevolent dictator], no [Pumpking], just a [7-member core team] that
collectively makes decisions about release schedules, security issues, and,
whatnot. Several members of the team are of course core hackers, but some handle
PR or release management and are less familiar with internals. The core team has
a moderated mail list on which they can discuss issues amongst themselves, such
as when to put out new releases. But most development and contribution issues
are discussed on the [pgsql-hackers] mail list, which corresponds to the
[perl5-porters] list. The vast majority of the decisions about what does and
does not get into the core takes place on this list, leaving the core team to
take on only those issues which are irresolvable by the community at large.

After each major release of PostgreSQL (most recently, [8.4 two weeks ago]), the
pgsql-hackers list [discusses] and [agrees to] a commit fest and release
schedule for the next major version of PostgreSQL. The schedule is typically for
about a year, and despite the [occasional worry] about the increasing time
between major releases (up to 16 months between 8.3 and 8.4), there is in fact a
major new release of PostgreSQL -- with [significant new features] -- every 9-18
months. That's an incredibly aggressive release cycle; I'd *love* to see Perl
5.10 followed by 5.12 just a year later.

This is the liberal part of the PostgreSQL development process: freely accepting
patches and working them in to the core via commit fests over the course of 6-8
months and relying on the [build farm] to quickly address regressions. The
commit fests were introduced for the 8.4 schedule to make it easier for the core
hackers to track, review, and commit contributed patches. They last for a month
and take place every other month, and while there were some hiccups with them
the first time around, they were enough of a success that a [dedicated Webapp]
has been built to manage them for 8.5 and beyond. Community members are
[encouraged to independently test patches], just to confirm that things work as
expected before one of the committers dedicates the time. This allows new
development to progress quickly over the course of 6-8 months before a feature
freeze is declared and the project enters a beta- and release-candidate release
cycle. Once a release candidate goes for two weeks or so without a major
regression, it's declared done, the x.x.0 release drops, and CVS HEAD is [opened
for development] of the next major version.

#### PostgreSQL's Code Conservatism

With all the activity around adding new features and the occasional backward
incompatibility to PostgreSQL, you might wonder wherein lies the conservatism I
mentioned. Well, it's this: every time a major new version of PostgreSQL ships,
a maintenance branch is forked for it; and thereafter only bug fixes and
security issues are committed to it. **Nothing else.** PostgreSQL's maintenance
branches are treated *very* conservatively; even documentation patches are
accepted only for CVS HEAD.

How do things get applied to maintenance branches? When a committer applies a
patch to CVS HEAD, he or she also evaluates whether the patch is relevant to
actively maintained earlier versions of PostgreSQL, and applies the patch (with
appropriate modifications) to those versions. All such changes are committed all
at once, or in a series of commits with exactly the same commit message. For
example, here's a [commit by Tom Lane] fixing a bug in PL/pgSQL last October and
back-patching it through all supported versions except 7.4, which did not have
the problem. As you can see, there is no cherry-picking of commits from HEAD
here. It is the responsibility of the committer to ensure that bug fixes are
applied to all supported branches of PostgreSQL -- at the same time.

The upshot of this approach is that the PostgreSQL project can be explicit about
what versions of PostgreSQL it maintains (in terms of regular releases with bug
fixes and security patches) and can quickly deliver new releases of those
versions. Because so little changes in maintenance branches other than
demonstrable bug fixes, there is little concern over breaking people's
installations. For example, on March 2 of this year, Tom Lane [fixed a bug] in
all supported versions of PostgreSQL that addressed a [security vulnerability].
The core hackers decided that this issue was important enough that they
[delivered new releases] of all of those versions of PostgreSQL (8.3.7, 8.2.13,
8.1.17, 8.0.21 and 7.4.25 -- yes, there have been 26 releases of 7.4!) on March
17, just two weeks later. More serious security issues have been addressed by
new releases within a day or two of being fixed.

In short, thanks to its formal support policy and its insistence on applying
only bug fixes to supported versions and applying them to all maintenance
branches at once, the PostgreSQL project can regularly and quickly deliver
stable new releases of PostgreSQL.

### An Insight

Now let's contrast PostgreSQL development practice with the Perl approach. I had
assumed that major versions of Perl (5.8.x, 5.10.x) were maintained as stable
releases, with just bug fixes going into releases after the .0 versions. After
all, the PostgreSQL practice isn't so uncommon; we do much the same thing for
[Bricolage]. So I was stunned last weekend to see [this post], by Perl 5.10
Pumpking Dave Mitchell, suggesting that inclusion of autodie in the core be
pushed back from 5.10.1 to 5.10.2. The fact that a major new module/pragma is
being added to a minor release (and it looks like things were worked out so that
autodie can stay in 5.10.1) highlights the fact that minor releases of Perl are
not, in fact, *maintenance* releases. They are, rather, **major new versions of
Perl.**

This probably should have been obvious to me already because, notwithstanding
Nicholas Clark's heroic delivery of new versions of Perl 5.8 every three months
for close to two years, minor releases of Perl tend to come out infrequently.
Perl 5.10.0 was released over a year and a half ago, and it looks like 5.10.1
will be out in August. That's a standard timeline for *major* releases. No
wonder it's so bloody much work to put together a new release of Perl! This
insight also helps to explain David Golden's [suggestion] to change Perl version
number scheme to support, for example, 5.10.0.1. I couldn't see the point at
first, but now I understand the motivation. I'm not sure it's the best idea, but
the ability to have proper bug-fix-only maintenance releases of officially
supported versions of Perl would be a definite benefit.

Last week came a new surprise: Rafael Garcia-Suarez has [resigned as Perl 5.12
Pumpking]. This is a sad event for Perl 5, as Rafael has done a ton of great
work over the last five years -- most recently with the [smart-match operator]
borrowed from Perl 6. But I think that it's also an opportunity, a time to
re-evaluate how Perl 5 development operates, and to consider organizational and
structural changes to development and release management. (And, yes, I also want
to see 5.10.1 out the door before just about anything else.)

### Modest Proposals

I'm a newcomer to the Perl 5 Porters list, but not to Perl (I started hacking
Perl in 1995, my first programming language). So I hope that it's not too
impertinent of me to draw on the example of PostgreSQL to make some suggestions
as to how things might be reorganized to the benefit of the project and the
community.

Create a cabal.

:   It seems to me that the pressure of managing the direction of Perl
    development is too great for one person. The history of Perl is littered
    with the remains of Perl Pumpkings. I can think of only two former Pumpkings
    who are still actively involved in the project: [Nicholas Clark] and [Chip
    Salzenberg]. Most (all?) of the others are gone, and even Chip [took a
    break] for a few years. Tim Bunce is still active in the project, but not in
    core development. I'm loathe to recommend design-by-committee, but the
    nature of the perl5-porters list reveals that such is *already* the case,
    and the committee is too big. Why should one person alone take on the stress
    of dealing with it all, of defending executive decisions?

    I think that PostgreSQL gets this one right (or at least more right) with
    its core team. It's intentionally limited to a very small group, and each of
    the members has equal say. The group sets parameters for things like release
    scheduling and makes decisions that the community at large can't agree to,
    but otherwise is fairly hands-off. Responsibility is shared by all members,
    and they help each other or refer to decisions made between them in the
    context of heated discussions on the pgsql-hackers list. It's more of a
    guiding structure than a leadership role, and it works well for an
    unstructured project like open-source development.

    Rather than make just one person responsible for each major version of Perl,
    handling all executive decisions, managing commits and back-patches and
    defending decisions, wouldn't it work better to have a small group of people
    doing it? Couldn't you see RGS, Dave Mitchell (who, it seems, has also
    suggested [breaking up the Pumpking role]), Chip, Nicholas, and a few other
    parties with a significant investment in the development and maintenance of
    the Perl core (mst? Jesse Vincent? Larry???) gently guiding development and
    community participation, not to mention maintenance and release management?
    Perl is a big project: the huge responsibility for maintaining it should be
    distributed among a number of people, rather than be a heavy burden for one
    person who then burns out.

Establish a policy for supported versions.

:   What is the oldest major version of Perl that's officially supported by the
    project? I don't know, either. I guess it's 5.8, but only because Nicholas
    picked up the gauntlet and got 5.8.9 out last year. 5.6? Not so much (we got
    5.6.2 a couple years back, but will there be a 5.6.3?). 5.4? Forget about
    it. I can guess what's supported because of my familiarity with the project,
    but who knows for sure? What does the community (read: perl5-porters) commit
    to continuing to fix and release? There is no official statement.

    It would be really beneficial to know -- that is, for an explicit
    maintenance policy to be articulated and maintained. Such a policy would
    allow third parties to know exactly what versions of Perl will continue to
    work and what versions will be deprecated and dropped. Of course, to do this
    realistically, it will have to get easier to deliver maintenance releases,
    and that means the project will have to…

Use minor versions for bug fixes only.

:   The fact that there are effectively no bug-fix-only releases of Perl is, in
    my opinion, a huge problem. Regressions can sit for months or even years
    with fixes without seeing a release. You can't just tell people to apply a
    patch or rely on distribution packagers to fix up the patches (hell, certain
    packagers tend to break Perl by leaving such patches in place for years!).

    So the Perl project needs maintenance branches that are actively maintained
    by back-patching all bug fixes as appropriate *as they are committed to
    blead*. The maintenance branches always ought to be in a state such that
    they're identical to their initial releases plus bug fixes. This also goes
    for any dual-life modules: no new features, just bug fixes. By adhering to a
    strict regimen for maintaining such branches, the core team can tag a
    release at any time with just a few steps. Such will be important to fix
    serious security issues, bugs, or performance regressions in a timely
    manner, and will likely help prevent package maintainers from wandering too
    far from core releases.

    Ideally, such branches would be for a major version number. For example,
    there would be a branch for 5.10 and one for 5.8. For the 5.10 branch,
    maintenance releases would be 5.10.2, 5.10.3, etc. If that's not do-able
    because of the current practice of the minor release numbers actually being
    major releases, perhaps the branch would be 5.10.1 and maintenance releases
    would be 5.10.1.1, 5.10.1.2, etc. Such is the path the Git project follows,
    for example. Or perhaps we could change the numbers altogether: make the
    next major release “Perl 5 v10.1.0,” the maintenance branch v10.1, and the
    next maintenance release 10.1.2. The next major release would be 10.2.0 or,
    eventually, 12.0.0.

    That last suggestion probably won't fly, and the first option would,
    frankly, be more to my liking, but the point is to have *some* logical
    versioning system to make it easy to identify major releases and maintenance
    releases. Ultimately it doesn't really matter what version numbers are used,
    as long as their use is consistent.

Update smoke testers to simplify regression tracking.

:   Like the PostgreSQL [build farm], we need a way to quickly see what works
    and what doesn't for all maintained versions of Perl. I'm not familiar with
    the smoke testing configuration, so maybe it does this already. But ideally,
    the system would be easy to set up, would check out and build every
    officially supported version of Perl, run the test suite, and send the
    results back to a central database. Via the interface for that database, you
    could see what versions and revisions of Perl are passing or failing tests
    on every reporting platform at any moment in time. And finally, you'd be
    able to see the full TAP output of all tests (or maybe just particular test
    scripts?) so that it's easy to jump down into the test results and see
    failure diagnostics, to allow a developer go get an early start on fixing
    failures without having to ask the server owner to run the tests again.

    Bonus points for plugging in results from cpan-testers for each version,
    too.

Fix and record as you go.

:   I alluded to this already, but it deserves its own section: Back-patch bug
    fixes to all appropriate maintenance branches as you go. And as you make
    those fixes, record them in a changes file, so that the release manager
    doesn't have to dig through the commit logs to figure out what's changed
    from version to version. The existing practice -- where the Pumpking decides
    it's time for a release and spends weeks or months cherry-picking fixes from
    blead and trolling through the logs for changes -- just doesn't scale: it
    puts all the work onto one person, leading directly to the very real
    possibility for burnout. Getting a release ready is hard enough without all
    the extra busy work. The only effective way to keep things up-to-date and
    well recorded at all times is to, well, *keep things up-to-date and well
    recorded at all times.*

    If the project committers adhere to this practice, it will always be easy to
    get a maintenance release out with just a day's worth of work -- and perhaps
    less. If the code is always ready for release, it can always be released.
    Perhaps the smoke farm is given a day or two to show that there are no
    regressions, but otherwise, release early, release often.

### The Goal

These are some of the lessons I take away from observing the differences between
PostgreSQL development and Perl development. There are other changes that might
be worthwhile, such as eliminating the overhead created by dual-life modules and
articulating an explicit deprecation policy. Such issues have been covered
elsewhere, however, and not practiced by or relevant to the PostgreSQL example.

As for the comparison, I recognize that there are no exact parallels (one hacker
I know who has worked on both projects says that the PostgreSQL source code is a
*lot* cleaner and easier to work with than the Perl soure, and therefore it's
easier to maintain and prep for release), but surely ideas can be borrowed and
put to good use. Ultimately, I'd really like to see changes to the Perl
development and release process to enable:

-   More frequent stable releases of Perl
-   More rapid development and delivery of major releases of Perl
-   Less work and stress for core maintainers
-   Greater predictability and accessibility for users

There's a lot here, but if you take only two things away from this essay, let
them be these suggestions:

1.  establish a cabal to spread the burden of responsibility and decision
    making, and
2.  maint should be *much* more conservative about changes

Both are very simple and very effective. What do you think?

My thanks to Bruce Momjian, Tim Bunce, chromatic, and Nicholas Clark for
reviewing earlier drafts of this essay and providing invaluable feedback and
suggestions -- many of which I accepted. Any errors of course remain completely
my own.

  [new blog]: http://modernperlbooks.com/mt/index.html "Modern Perl Books"
  [Rafael Garcia-Suarez]: http://consttype.blogspot.com/2009/07/time-based-releases-in-open-source.html
    "ConstType: “Time-based releases in open source”"
  [chromatic]: http://www.modernperlbooks.com/mt/2009/06/what-does-stable-mean.html
    "Modern Perl Books: “What does \"Stable\" Mean?"
  [PostgreSQL RDBMS]: https://www.postgresql.org/
  [how the PostgreSQL project works]: http://wiki.postgresql.org/wiki/Image:How_the_PostgreSQL_Project_Works.pdf
  [benevolent dictator]: http://www.wired.com/wired/archive/11.11/linus.html
    "Wired:“Leader of the Free World”"
  [Pumpking]: http://www.perlfoundation.org/perl5/index.cgi?pumpking
    "Perl 5 Wiki: “Pumpking”"
  [7-member core team]: https://www.postgresql.org/community/contributors/
    "PostgreSQL Contributor Profiles"
  [pgsql-hackers]: http://archives.postgresql.org/pgsql-hackers/
    "pgsql-hackers Archives"
  [perl5-porters]: http://www.nntp.perl.org/group/perl.perl5.porters/
    "perl5-porters Archives"
  [8.4 two weeks ago]: https://www.postgresql.org/about/news.1108
    "PostgreSQL 8.4 Released: Now Easier to Use than Ever"
  [discusses]: http://archives.postgresql.org/pgsql-hackers/2009-06/msg01484.php
    "pgsql-hackers: “8.5 development schedule”"
  [agrees to]: http://archives.postgresql.org/pgsql-hackers/2009-06/msg01542.php
  [occasional worry]: http://archives.postgresql.org/pgsql-hackers/2009-07/msg00020.php
  [significant new features]: https://www.postgresql.org/about/press/features84.html
    "PostgreSQL 8.4 Feature List"
  [build farm]: http://buildfarm.postgresql.org/cgi-bin/show_status.pl
    "PostgreSQL BuildFarm Status"
  [dedicated Webapp]: http://commitfest.postgresql.org/ "PostgreSQL CommitFest"
  [encouraged to independently test patches]: http://wiki.postgresql.org/wiki/RRReviewers
    "PostgreSQL Wiki: “Round-Robin Reviewers”"
  [opened for development]: http://archives.postgresql.org/pgsql-hackers/2009-07/msg00083.php
    "pgsql-hackers: “HEAD is open for 8.5 development”"
  [commit by Tom Lane]: http://archives.postgresql.org/pgsql-committers/2008-10/msg00079.php
  [fixed a bug]: http://archives.postgresql.org/pgsql-committers/2009-03/msg00008.php
  [security vulnerability]: http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-0922
    "CVE-2009-0922"
  [delivered new releases]: https://www.postgresql.org/about/news.1065
    "PostgreSQL 2009-03-16 Security Update"
  [Bricolage]: http://www.bricolagecms.org/
    "Bricolage content management and publishing system"
  [this post]: http://www.nntp.perl.org/group/perl.perl5.porters/2009/07/msg148133.html
    "perl5-porters: “Re: Coring Variable::Magic / autodie fights with string eval inPerl 5.10.x”"
  [suggestion]: http://www.nntp.perl.org/group/perl.perl5.porters/2009/06/msg147448.html
    "perl5-porters, David Golden: “Re: 5.10.1”"
  [resigned as Perl 5.12 Pumpking]: http://consttype.blogspot.com/2009/07/resigning.html
    "ConstType: “Resigning”"
  [smart-match operator]: http://perltraining.com.au/tips/2008-04-18.html
    "Paul Fenwick: “Smart-match”"
  [Nicholas Clark]: http://www.ccl4.org/~nick/
  [Chip Salzenberg]: http://use.perl.org/~chip/
  [took a break]: http://use.perl.org/~chip/journal/17291 "From under the hood to behind the wheel"
  [breaking up the Pumpking role]: http://www.nntp.perl.org/group/perl.perl5.porters/2009/06/msg147929.html
