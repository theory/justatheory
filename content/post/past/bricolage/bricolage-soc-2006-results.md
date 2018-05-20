--- 
date: 2006-09-07T17:43:21Z
slug: bricolage-soc-2006-results
title: Bricolage GSoC Projects Completed
aliases: [/bricolage/soc_2006_results.html]
tags: [Bricolage, Google Summer Of Code, MySQL, Ajax, Marshall Roch, Christian Muise, Andrei Arsu]
type: post
---

I'm very pleased to report that the Google Summer of Code Bricolage projects
have all been successfully completed. The contributions of the three Summer of
Coders, Marshall Roch, Christian Muise, and Andrei Arsu, will be included in the
next major release of Bricolage. On behalf of the Bricolage community, like to
extend my gratitude to Google for sponsoring these three excellent students to
dramatically improve the interface, capabilities, and compatibility of
Bricolage.

So what got done? Here's a rundown:

-   Marshall Roch added many slick Ajax features to Bricolage. The story profile
    now manages the editing of all elements and subelements in a single screen,
    with no loading of a separate screen for subelements. You can navigate to
    subelements by clicking on a tree structure right in the story profile.
    Subelements more than three levels down will be loaded dynamically when you
    get to them. You can also drag and drop fields and elements to reorder them.

    Other stuff that Marshall Ajaxified:

    -   Document and category keyword editing

    -   Document category association

    -   Document output channel associations

    -   Organizations in the source profile

    -   The “Add More” sections of the user, contributor, media type, and alert
        type profiles

    -   Roles in the contributor profile

    -   Assets on desks and My Workspace

    Marshall worked hard to integrate more interactive features into this
    2000-era application, and I, for one, appreciate his hard work. Great job,
    Marshall!

-   Christian Muise added support for an occurrence specification to element
    types and field types. That means that when you make an element type a
    subelement of another element type, you can specify the minimum and/or
    maximum number of times that it can be a subelement. So when an element of
    the parent type is created, it will automatically add the minimum number of
    instances of a subelement specified for that parent type. This will allow an
    entire element tree to be pre-populated as soon as you create a new story or
    media document. Leaving the min and max occurrence set to 0 (zero) maintains
    the old behavior (no required subelements and an unlimited number can be
    added).

    Christian did the same for field types, too. The old “Required” and
    “Repeatable” attributes are gone; now you just specify a minimum number to
    require that number of instances of a field, and a maximum number to limit
    the number of instances. Together with the element type occurrence
    specification, this functionality allows Bricolage administrators to have a
    lot more control over the structure of the documents created by editors.

    Christian worked hard to complete this project, despite other huge demands
    on his time this summer (including a full-time job!). But thanks to his
    active participation on the developer mail list and his willingness to ask
    questions of his mentor, Scott Lanning, and myself, he overcame all
    obstacles to implement these features. He even wrote a number of new tests
    to ensure that it works properly and will continue to do so for the
    foreseeable future.

    Excellent work, Christian, and thank you so much for your contribution!

-   Andrei Arsu ported Bricolage to MySQL 5. Bricolage has always run on
    PostgreSQL and used a number of PostgreSQL-specific features to ensure that
    it ran properly and well. Andrei took these on, converting the existing
    PostgreSQL DDL files to work on MySQL, figuring out how to convince MySQL to
    work with some of their idiosyncrasies, and writing compatibility functions
    in the MySQL driver and upgrade module so that things should largely “just
    work.” As a result, for the first time ever, you can now build and run
    Bricolage on MySQL. Can compatibility with other databases be far behind?

    Andrei picked up Perl very quickly during this project, and was able to
    understand how such horrible code as the Bricolage installer worked without
    running screaming from the project. His code was well-written and his
    approaches to compatibility flexible and scalable. Well done, Andrei!

### Future Plans

The next tasks toward getting this code integrated and released are as follows:

-   Andrei will merge his MySQL port into subversion trunk. This should actually
    be fairly straight-forward.

-   Marshall will merge his Ajaxification work into trunk. I don't expect that
    there will be any conflicts with Andrei's work, as the two projects were
    orthogonal.

-   Christian will merge his occurrence specification work into trunk. This will
    require that he work some with Andrei to ensure that his changes to the
    PostgreSQL DDLs are propagated to the new MySQL DDLS. He will also then need
    to work with Marshall to make sure that the occurrence specification works
    properly with the Ajaxified UI.

Once these tasks have been completed, we'll be ready to release a development
version of Bricolage with all three of these major improvements. The development
release will allow members of the Bricolage community to start to play with the
new features, report bugs, and make further suggestions for improvement. Expect
the release sometime in the next six weeks or so.

Again, my thanks to Marshall, Christian, and Andrei for their hard work this
summer, and for all that they have contributed to the Bricolage community and
project. I hope that each will remain involved in the community, not only to
support the features they've added, but to work with other members of the
community to add new features, help newbies, and generally to spread the word.
