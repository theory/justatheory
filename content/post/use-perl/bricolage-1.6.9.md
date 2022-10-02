---
date: 2004-02-06T21:13:15Z
description: Desirable bugfixes all around.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.6.9
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.6.9
---

I'm pleased to announce the release of Bricolage 1.6.9. This
maintenance release addresses a number issues discovered since the
release of version 1.6.8. Here is the complete list of changes for this
release:

*   Fixed installation and upgrade scripts to use the same perl binary
    as was used to execute Makefile.PL. This ensures that all necessary
    CPAN modules will be correctly installed and located. [Simon
    Wilcox]

*   Story profile JavaScript validation works again. Thanks to Simon
    Wilcox for the spot! [David]

*   Eliminated the need for the Apache::ConfigFile module, and thus
    some annoying problems with the CPAN indexer when trying to install
    it. [David]

*   Fixed order of SQL statement execution upon installation so that
    dependencies are properly handled. [Mark]

*   New file resources created for distribution are now created with
    the proper media type. [Mark]

*   The German localization module (Bric::Util::Language::de_de) had
    the wrong package name, which meant that attempts to use it failed
    with the error "Can't locate class method
    'Bric::Util::Language::de_de::new' via package
    'Bric::Util::Language::de_de'". [Dave Rolsky]

*   Added new path to find PostgreSQL installed by some Debian
    packages. [Cinly Ooi]

*   Workflows with special characters such as "+" and "&" now work
    properly in the side navigation. Thanks to Patrick Walsh for the
    spot! [David]

*   Start desks can no longer be removed from workflows. This prevents
    workflows from having no desks, thus avoiding problems adding desks
    to such workflows. Reported by Patrick Walsh. [David]

*   Pushing the cancel button in a desk profile and then in a workflow
    profile no longer redirects back to the desk profile. [David]

*   Made publish_date not be empty when publish is done through the
    SOAP API and no publish_date argument is passed. [Scott]

*   Fixed CPAN installer to correctly update the list of modules to be
    installed after a module has been successfully installed. Reported
    by Perrin Harkins. [David]

*   Checkout checkboxes no longer appear for assets that users don't
    have permission to check out. Thanks to Alexander Ling for the
    spot! [David]

*   Bric::Biz::AssetType::Parts::Data's "lookup()" method now returns
    deactivated objects, as it should. Thanks to Nuno Barreto for the
    spot. [David]

*   Events with attributes with the same name as attributes of the
    object the event was triggered on (a common occurrence) no longer
    confuses the two. Thanks to Todd Tyree for the spot. [David]

*   Users granted permission to access the members of a group via two
    user group associations now always get the highest priority
    permission, as it should be. Thanks to Patrick Walsh for the spot.
    [David]

*   Textarea fields in elements no longer lose some of their default
    data after editing the field in the element manager. Reported by
    Todd Tyree. [David]

*   Media assets now properly remember their class, which means that
    autopopulated fields (such as "height" and "width" for images) are
    autopopulated when a new image file is uploaded. Thanks to Patrick
    Walsh for the spot! [David]

*   Updated Chinese Traditional localization. [Kang-min Liu]

See the [changes page]
for a complete history of Bricolage changes.

**ABOUT BRICOLAGE**

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete [HTML::Mason] and [HTML::Template] support for
flexibility, and many other features. It operates in an [Apache]/[mod_perl]
environment, and uses the [PostgreSQL] RDBMS for its repository. A
comprehensive, actively-developed open source CMS, Bricolage has been hailed as
"Most Impressive" in 2002 by *eWeek*.

Learn more about Bricolage and download it from the [Bricolage home page].

Enjoy!

David

*Originally published [on use Perl;]*

  [changes page]: http://sourceforge.net/project/shownotes.php?release_id=215294
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/17255/
    "use.perl.org journal of Theory: “Bricolage 1.6.9”"
