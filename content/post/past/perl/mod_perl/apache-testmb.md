--- 
date: 2004-06-23T00:10:00Z
slug: apache-testmb
title: Module::Build + Apache::Test is Nearly Here
aliases: [/computers/programming/perl/mod_perl/apache_testmb.html]
tags: [mod_perl, Perl, Module::Build, testing]
type: post
---

Over the last couple of days, I whipped up a new class to be added to the
[Apache HTTP Test Project]. The new class, `Apache::TestMB`, is actually a
subclass of [`Module::Build`], and finally provides support for using
`Apache::Test` with `Module::Build`. You use it just like `Module::Build`;
however, since a lot of modules choose to install themselves even if Apache
isn't installed (because they can be used both inside and outside of `mod_perl`,
e.g., [HTML::Mason]), I'm suggesting that *Build.PL* files look like this:

    use Module::Build;

    my $build_pkg = eval { require Apache::TestMB }
      ? "Apache::TestMB" : "Module::Build";

    my $build = $build_pkg->new(
      module_name => "My::Module",
    )->create_build_script;

Pretty simple, huh? To judge by the [discussion], it will soon be committed to
the `Apache::Test` repository and released to CPAN. My
[`MasonX::Interp::WithCallbacks`] module will debut with a new
`Apache::TestMB`-powered *Build.PL* soon afterward.

  [Apache HTTP Test Project]: http://httpd.apache.org/test/
    "Apache HTTP Test Project page"
  [`Module::Build`]: http://search.cpan.org/dist/Module-Build/
    "Module::Build on CPAN"
  [HTML::Mason]: http://www.masonhq.com/ "The HTML::Mason site"
  [discussion]: http://marc.theaimsgroup.com/?t=108786695100002&r=1&w=2
    "Discussion of Apache::TestMB on test-dev@httpd.apache.org"
  [`MasonX::Interp::WithCallbacks`]: http://search.cpan.org/dist/MasonX-Interp-WithCallbacks/
    "MasonX::Interp::WithCallbacks on CPAN"
