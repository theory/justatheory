--- 
date: 2004-06-23T00:10:00Z
slug: apache-testmb
title: Module::Build + Apache::Test is Nearly Here
aliases: [/computers/programming/perl/mod_perl/apache_testmb.html]
tags: [mod_perl, Perl, Module::Build, testing]
type: post
---

<p>Over the last couple of days, I whipped up a new class to be added to
the <a href="http://httpd.apache.org/test/" title="Apache HTTP Test Project page">Apache HTTP Test Project</a>. The new class, <code>Apache::TestMB</code>,
is actually a subclass of <a href="http://search.cpan.org/dist/Module-Build/" title="Module::Build on CPAN"><code>Module::Build</code></a>, and finally provides support
for using <code>Apache::Test</code> with <code>Module::Build</code>. You use 
it just like <code>Module::Build</code>; however, since a lot of modules
choose to install themselves even if Apache isn't installed (because they can
be used both inside and outside of <code>mod_perl</code>, e.g.,
<a href="http://www.masonhq.com/" title="The HTML::Mason site">HTML::Mason</a>),
I'm suggesting that <em>Build.PL</em> files look like this:</p>

<pre>use Module::Build;

my $build_pkg = eval { require Apache::TestMB }
  ? &quot;Apache::TestMB&quot; : &quot;Module::Build&quot;;

my $build = $build_pkg->new(
  module_name => &quot;My::Module&quot;,
)->create_build_script;</pre>

<p>Pretty simple, huh? To judge by the <a
href="http://marc.theaimsgroup.com/?t=108786695100002&r=1&w=2" title="Discussion of Apache::TestMB on test-dev@httpd.apache.org">discussion</a>,
it will soon be committed to the <code>Apache::Test</code> repository and
released to CPAN. My <a href="http://search.cpan.org/dist/MasonX-Interp-WithCallbacks/" title="MasonX::Interp::WithCallbacks on CPAN"><code>MasonX::Interp::WithCallbacks</code></a>
module will debut with a new <code>Apache::TestMB</code>-powered <em>Build.PL</em>
soon afterward.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/mod_perl/apache_testmb.html">old layout</a>.</small></p>


