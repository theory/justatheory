--- 
date: 2004-06-28T18:22:55Z
slug: apache-testmb-released
title: Apache::TestMB Released!
aliases: [/computers/programming/perl/mod_perl/apache_testmb_released.html]
tags: [mod_perl, Perl, Apache, Module::Build]
---

<p>As I <a href="/computers/programming/perl/mod_perl/apache_testmb.html"
title="Module::Build + Apache::Test is Nearly Here">mentioned</a> last week,
I've been working on a subclass of <a
href="http://search.cpan.org/dist/Module-Build/" title="Module::Build on
CPAN"><code>Module::Build</code></a> that supports testing with
<a href="http://httpd.apache.org/test/" title="Apache HTTP Test Project
page"><code>Apache::Test</code></a>. Today, <a href="http://use.perl.org/~geoff/"
title="Geoff Young's use Perl page">Geoff</a> <a
href="http://marc.theaimsgroup.com/?l=apache-test-dev;m=108844177201351;w=2"
title="The Apache::Test 1.12 announcement on test-dev">announced</a> the
release of <a href="http://search.cpan.org/dist/Apache-Test/"
title="Apache::Test on CPAN"><code>Apache::Test</code></a> 1.12. This release includes the
new <code>Module::Build</code> subclass, <a
href="http://search.cpan.org/dist/Apache-Test/lib/Apache/TestMB.pm"
title="Apache::TestMB documentation"><code>Apache::TestMB</code></a>. Now
anyone using <code>Apache::Test</code> to test their module can convert the build
system to <code>Module::Build</code>.</p>

<p>To set an example, I've just released <a
href="http://search.cpan.org/dist/MasonX-Interp-WithCallbacks"
title="MasonX::Interp::WithCallbacks on
CPAN"><code>MasonX::Interp::WithCallbacks</code></a> using the new build
module. The conversion was simple; in fact, I think
that <code>Apache::TestMB</code>is easier to use
than <code>Apache::TestMM</code> (which integrates <code>Apache::Test</code>
with <code>ExtUtils::MakeMaker</code>). My <em>Makefile.PL</em> had looked like this:</p>

<pre>#!perl -w

use strict;
use ExtUtils::MakeMaker;
use File::Spec::Functions qw(catfile catdir);
use constant HAS_APACHE_TEST =&gt; eval {require Apache::Test};

# Set up the test suite.
if (HAS_APACHE_TEST) {
    require Apache::TestMM;
    require Apache::TestRunPerl;
    Apache::TestMM-&gt;import(qw(test clean));
    Apache::TestMM::filter_args();
    Apache::TestRunPerl-&gt;generate_script();
} else {
    print &quot;Skipping Apache test setup.\n&quot;;
}

my $clean = join ' ', map { catfile('t', $_) }
  qw(mason TEST logs);

WriteMakefile(
    NAME		=&gt; 'MasonX::Interp::WithCallbacks',
    VERSION_FROM	=&gt; 'lib/MasonX/Interp/WithCallbacks.pm',
    PREREQ_PM		=&gt; { 'HTML::Mason'             =&gt; '1.23',
                                'Test::Simple'            =&gt; '0.17',
                                'Class::Container'        =&gt; '0.09',
                                'Params::CallbackRequest' =&gt; '1.11',
                              },
    clean               =&gt; { FILES =&gt; $clean },
    ($] &gt;= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM    =&gt; 'lib/MasonX/Interp/WithCallbacks.pm',
       AUTHOR           =&gt; 'David Wheeler &lt;david@kineticode.com&gt;') : ()),
);
</pre>

<p>The new <em>Build.PL</em> simplifies things quite a bit. It looks like this:</p>

<pre>use Module::Build;

my $build_pkg = eval { require Apache::TestMB }
  ? 'Apache::TestMB' : 'Module::Build';

$build_pkg-&gt;new(
    module_name        =&gt; 'MasonX::Interp::WithCallbacks',
    license            =&gt; 'perl',
    requires           =&gt; { 'HTML::Mason'             =&gt; '1.23',
                               'Test::Simple'            =&gt; '0.17',
                               'Class::Container'        =&gt; '0.09',
                               'Params::CallbackRequest' =&gt; '1.11'
                             },
    build_requires     =&gt; { Test::Simple =&gt; '0.17' },
    create_makefile_pl =&gt; 'passthrough',
    add_to_cleanup     =&gt; ['t/mason'],
)-&gt;create_build_script;
</pre>

<p>Much nicer, eh?</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/mod_perl/apache_testmb_released.html">old layout</a>.</small></p>


