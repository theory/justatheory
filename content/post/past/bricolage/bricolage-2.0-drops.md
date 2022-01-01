--- 
date: 2010-04-12T20:46:11Z
slug: bricolage-2.0-drops
title: Bricolage 2.0 Drops
aliases: [/bricolage/bricolage-2.0-drops.html]
tags: [Bricolage, Apache, MySQL, Ajax, Google Summer Of Code]
type: post
---

Bricolage 2.0 was [released today]. This is a pretty big deal, and a long time
coming. The most important changes, from my point of view, are:

-   Revamped UI. As a 2006 [Google Summer of Code] project, [Marshall Roch]
    added a slew of Ajaxy goodness to the Bricolage UI. It used to be that, to
    dig down into a document, you needed to click through reloads for every
    level. Now the entire structure of a document is available on a single
    screen, and digging down takes place in situ. This means faster, easier
    document editing.

    There are other niceties too, thanks to Marshall, like as-you-type
    autocompletion of category URIs and keywords, popups for associating related
    documents, dynamic field generation for document keywords and user contacts,
    and animated workflow actions for moving, deleting, and publishing
    documents.

    These changes mark a truly impressive improvement in usability for the
    people who use Bricolage every day, and will by far be the most welcome
    change for our users.

-   Finer content control. Thanks to another 2006 [Google Summer of Code]
    project, [Christian Muise] implemented what we call “element occurrence
    specification.” Bricolage document structure is controlled by administrators
    creating document types with hierarchies of elements. Elements may contain
    fields—the types and value of which may also be specified (text, textarea,
    select list, etc.)—and other elements.

    In previous versions of Bricolage, if an element was a subelement of a
    document, one could add any number of that element to a document. Fields
    were a bit more controlled: you could only say whether one or many instances
    of a field were allowed in a given element.

    Element occurrence specification allows administrators to have much finer
    control over document elements by specifying the minimum and maximum number
    of instances of an element or field may occur. For example, one can say that
    a document may have only one instance of a field, or must have three, or may
    have between 3 and 5, or may have at least 3, or may have any number,
    including none.

    [Bret Dawson] put it really well in the [Bricolage 2.0 Changes][]:

    > Want every book review you publish to contain at least three but no more
    > than 10 ISBN numbers? Want exactly four pull-quotes in every article? You
    > can do that in Bricolage 2.

-   MySQL support. This, too, was a 2006 [Google Summer of Code] project, by
    [Andrei Arsu]. Yes, you can run Bricolage 2.0 on MySQL 5.0 if you want. This
    was a pretty big project, and I’m surprisingly pleased at how well it works
    now that all the kinks have been worked out (special thanks to [Waldo
    Jaquith] for being brave (foolish?) enough to start a Bricolage project on
    MySQL and thus to shake out some bugs).

-   Apache 2 support. This was started quite some time ago by [Chris Heiland],
    hacked on later by [Scott Lanning], and finally finished by yours truly. I
    look forward to dumping Apache 1 in the future.

There’s other stuff, too, lots of little things and not-so-little things.
Altogether they go a long way toward making Bricolage better.

It’s been quite a day, and I’m glad to have it out the door. Four years is a
long time to wait for a major release, and it happened not because of me, but
thanks to the work of others who have picked up the gauntlet. Huge thanks
especially to:

-   The [Google Summer of Code], especially the 2006 projects (yes, we finally
    shipped them!).
-   [Phillip Smith], who spearheaded the terrific new [bricolagecms.org] design,
    updated the Bricolage 2.0 context-sensitive help, and generally pushed
    forward the Bricolage marketing and social media agenda (follow
    [@bricolagecms]!).
-   [Bret Dawson], who has been writing release announcements and put together
    the [awesomely human version of the Bricolage 2.0 change log][Bricolage 2.0
    Changes], as well as the [public announcement][released today].
-   [Matt Rolf], who wrote the [Bricolage 2.0 press release] and provided a huge
    load of various HTML and CSS fixes to Bricolage 2.0.
-   [Marshall Roch], who started hacking on Bricolage in high school, worked
    through two summers of code, and made the UI what it is today.
-   [Alex Krohn], who provides hosting for the [Bricolage
    site][bricolagecms.org] via his [Bricolage hosting] product at [Gossamer
    Threads], helped to diagnose and fix a number of important bugs, and has
    just been an all around great technical resource.

Many others provided feedback, patches, and bug reports, and I appreciate all
the help. I hope to see you all for Bricolage 2.2!

  [released today]: http://bricolagecms.org/news/announce/2010/04/12/bricolage-2.0.0/
  [Google Summer of Code]: http://code.google.com/soc/
  [Marshall Roch]: http://mroch.com/
  [Christian Muise]: http://www.haz.ca/
  [Bret Dawson]: http://pectopah.com/
  [Bricolage 2.0 Changes]: http://bricolagecms.org/news/announce/changes/bricolage-2.0.0/
  [Andrei Arsu]: http://www.facebook.com/people/Arsu-Andrei/1758289731
  [Waldo Jaquith]: http://waldo.jaquith.org/
  [Chris Heiland]: http://cuwebd.ning.com/profile/ChrisHeiland
  [Scott Lanning]: http://use.perl.org/~slanning/
  [Phillip Smith]: http://www.phillipadsmith.com/
  [bricolagecms.org]: http://bricolagecms.org/
  [@bricolagecms]: https://twitter.com/bricolagecms
  [Matt Rolf]: http://mattrolf.com/
  [Bricolage 2.0 press release]: http://bricolagecms.org/news/pr/2010/04/12/2.0-presskit/
  [Alex Krohn]: http://ca.linkedin.com/in/gossamer
  [Bricolage hosting]: http://www.gossamer-threads.com/hosting/bricolage.html
  [Gossamer Threads]: http://www.gossamer-threads.com/
