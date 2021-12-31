--- 
date: 2004-06-28T18:22:55Z
slug: apache-testmb-released
title: Apache::TestMB Released!
aliases: [/computers/programming/perl/mod_perl/apache_testmb_released.html]
tags: [mod_perl, Perl, Apache, Module::Build]
type: post
---

As I [mentioned] last week, I've been working on a subclass of [`Module::Build`]
that supports testing with [`Apache::Test`]. Today, [Geoff][] [announced] the
release of [`Apache::Test`][1] 1.12. This release includes the new
`Module::Build` subclass, [`Apache::TestMB`]. Now anyone using `Apache::Test` to
test their module can convert the build system to `Module::Build`.

To set an example, I've just released [`MasonX::Interp::WithCallbacks`] using
the new build module. The conversion was simple; in fact, I think that
`Apache::TestMB`is easier to use than `Apache::TestMM` (which integrates
`Apache::Test` with `ExtUtils::MakeMaker`). My *Makefile.PL* had looked like
this:

``` perl
#!perl -w

use strict;
use ExtUtils::MakeMaker;
use File::Spec::Functions qw(catfile catdir);
use constant HAS_APACHE_TEST => eval {require Apache::Test};

# Set up the test suite.
if (HAS_APACHE_TEST) {
    require Apache::TestMM;
    require Apache::TestRunPerl;
    Apache::TestMM->import(qw(test clean));
    Apache::TestMM::filter_args();
    Apache::TestRunPerl->generate_script();
} else {
    print "Skipping Apache test setup.\n";
}

my $clean = join ' ', map { catfile('t', $_) }
  qw(mason TEST logs);

WriteMakefile(
    NAME        => 'MasonX::Interp::WithCallbacks',
    VERSION_FROM    => 'lib/MasonX/Interp/WithCallbacks.pm',
    PREREQ_PM       => { 'HTML::Mason'             => '1.23',
                                'Test::Simple'            => '0.17',
                                'Class::Container'        => '0.09',
                                'Params::CallbackRequest' => '1.11',
                              },
    clean               => { FILES => $clean },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM    => 'lib/MasonX/Interp/WithCallbacks.pm',
        AUTHOR           => 'David Wheeler <david@kineticode.com>') : ()),
);
```

The new *Build.PL* simplifies things quite a bit. It looks like this:

``` perl
use Module::Build;

my $build_pkg = eval { require Apache::TestMB }
  ? 'Apache::TestMB' : 'Module::Build';

$build_pkg->new(
    module_name        => 'MasonX::Interp::WithCallbacks',
    license            => 'perl',
    requires           => { 'HTML::Mason'             => '1.23',
                                'Test::Simple'            => '0.17',
                                'Class::Container'        => '0.09',
                                'Params::CallbackRequest' => '1.11'
                              },
    build_requires     => { Test::Simple => '0.17' },
    create_makefile_pl => 'passthrough',
    add_to_cleanup     => ['t/mason'],
)->create_build_script;
```

Much nicer, eh?

  [mentioned]: /computers/programming/perl/mod_perl/apache_testmb.html
    "Module::Build + Apache::Test is Nearly Here"
  [`Module::Build`]: https://metacpan.org/dist/Module-Build/ "Module::Build on CPAN"
  [`Apache::Test`]: http://httpd.apache.org/test/ "Apache HTTP Test Project page"
  [Geoff]: http://use.perl.org/~geoff/ "Geoff Young's use Perl page"
  [announced]: http://marc.theaimsgroup.com/?l=apache-test-dev;m=108844177201351;w=2
    "The Apache::Test 1.12 announcement on test-dev"
  [1]: https://metacpan.org/dist/Apache-Test/ "Apache::Test on CPAN"
  [`Apache::TestMB`]: https://metacpan.org/dist/Apache-Test/lib/Apache/TestMB.pm
    "Apache::TestMB documentation"
  [`MasonX::Interp::WithCallbacks`]: https://metacpan.org/dist/MasonX-Interp-WithCallbacks
    "MasonX::Interp::WithCallbacks on CPAN"
