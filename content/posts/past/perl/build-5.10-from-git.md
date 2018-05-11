--- 
date: 2009-07-03T06:30:54Z
slug: build-5.10-from-git
title: Checkout and Build Perl 5.10 from Git
aliases: [/computers/programming/perl/build-5.10-from-git.html]
tags: [Perl, Perl 5 Porters, Git, hacking]
---

<p>Tonight we had
a <a href="http://mail.pm.org/pipermail/pdx-pm-list/2009-July/005542.html">Portland
Perl Mongers Perl 5.10 code sprint</a>. This was the first time I've ever
worked with the Perl 5 core code, and while things weren't exactly intuitive,
it wasn't bad to get started, either. I already had a clone of the Perl Git
repository, so here's what I did to get started.</p>

<p>Here's how to clone the Git repository, and then check out the maint-5.10
branch and build and test Perl:</p>

<pre>
git clone git://perl5.git.perl.org/perl.git
cd perl
git checkout -b maint-5.10 origin/maint-5.10
sh Configure -Ode \
 -DDEBUGGING \
 -Dprefix=/usr/local/perl/blead \
 -Dusedevel \
 -Duseithreads \
 -Dccflags=&#x0027;-I/usr/local/include&#x0027; -Dldflags=&#x0027;-L/usr/local/lib&#x0027; \
 -Dlibpth=&#x0027;/usr/local/lib /usr/lib&#x0027; \
 -Uversiononly \
 -Uinstallusrbinperl $@
make
make test
</pre>

<p>I had two test failures:</p>

<pre>
#   at ../lib/ExtUtils/CBuilder/t/00-have-compiler.t line 39.
#          got: &#x0027;0&#x0027;
#     expected: &#x0027;1&#x0027;
# Looks like you failed 1 test of 4.
FAILED at test 4
</pre>

<p>And:</p>

<pre>
#   at pod/pod2usage2.t line 235.
# Got:
# #Usage:
# #    This is a test for CPAN#33020
# #
# #Usage:
# #    And this will be also printed.
# #
# 
</pre>

<p>So the first thing I want to do is fix those failures. It took a bit of
fiddling to figure out how to get it to run a single test. On the advice of
Paul Fenwick and Schwern, I tried:</p>

<pre>
./perl -Ilib lib/ExtUtils/CBuilder/t/00-have-compiler.t
</pre>

<p>But then the test passed! So something has to be different when running
under <code>make test</code>. With help from Duke Leto, I finally figured
out the proper incantation:</p>

<pre>
make test TEST_FILES=../lib/ExtUtils/CBuilder/t/00-have-compiler.t
</pre>

<p>So the <code>TEST_FILES</code> option tells <code>make test</code> what
tests to run, relative to the <code>t/</code> directory. Shortly thereafter,
Schwern told me about:</p>

<pre>
cd t
./perl TEST ../lib/ExtUtils/CBuilder/t/00-have-compiler.t
</pre>

<p>Which is nice, because it does a lot less work.</p>

<p>Now I was ready to figure out the ExtUtils::CBuilder bug and fix it. This
is good, I thought, because ExtUtils::CBuilder is a Perl module, and while my
C is teh suck, my Perl skillz are mad. So I do some poking around, and finally
pinned down the failure to the
<code>have_compiler()</code> method in ExtUtils::CBuilder::Base. A bit more
poking and I had the error printed out:</p>

<pre>
# error building /tmp/compilet-1529033816.o from &#x0027;/tmp/compilet-1529033816.c&#x0027;
at ../../ExtUtils/CBuilder/Base.pm line 110.
</pre>

<p>Well fuck, that sure looks like a C problem. But then I added some more
debugging code to see what command it's actually running, and from where. So I
added this code:</p>

<pre>
use Cwd;
print STDERR &quot;# CWD: &quot;, getcwd, $/;
print STDERR &quot;# &quot;, join( &#x0027; &#x0027;, @cc, @flags), $/;
</pre>

<p>And then I got this output:</p>

<pre>
# CWD: /Users/david/dev/perl/lib/ExtUtils/CBuilder
# ./perl -e1 &#x002d;&#x002d; -I/Users/david/dev/perl/perl -c -fno-common -DPERL_DARWIN -no-cpp-precomp -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -O3 -o ./compilet-892348855.o
</pre>

<p>And of course, there's no <code>perl</code> in <code>lib/ExtUtils/CBuilder</code>. Why
does it think there is? The test file has this code:</p>

<pre>
$b->{config}{cc} = &quot;$^X -e1 &#x002d;&#x002d;&quot;;
$b->{config}{ld} = &quot;$^X -e1 &#x002d;&#x002d;&quot;;
</pre>

<p>Well, that cinches it. <code>$^X</code> is the path to the
currently-executing Perl, but in core--for me at least--that's a relative
path. The test changes directories away from that path, and so it can't find
it. So I just needed to get it to use the proper Perl. Frankly, this test
should fail on every platform that runs it, so I'm not sure how it got
committed to the maint-5.10 branch, but here we are.</p>

<p>So I moved up <code>use File::Spec;</code> and
assigned <code>File::Spec->rel2abs($^X)</code> to a variable before
the <code>chdir</code>, and used that variable for the <code>cc</code> mock.
And that was it, the test passed. Yay!</p>

<p>Now it was time to submit a patch to p5p. I committed the fix to my local
clone, and then, with help from Jacob, generated a patch with <code>git
format-patch -1</code>. The <code>-1</code> means just a single commit, which
is all I'd committed. This generated a file,
named <code>0001-Fixed-failing-test-for-ExtUtils-CBuilder.patch</code>. I
edited it to add a comment to the effect that the patch is targeted at the
maint-5.10 branch.</p>

<p>Next Jacob helped me get <code>git</code> configured to send mail through
my gmail account. I just added these lines to <code>~/.gitconfig</code>:</p>

<pre>
[sendemail]
        smtpserver = smtp.gmail.com
        smtpserverport = 587
        smtpuser = justatheory
        smtppass = idontthinkso!
        smtpencryption = tls
</pre>

<p>I then sent the patch with:</p>

<pre>
git send-email &#x002d;&#x002d;to perl5-porters@perl.org 0001-Fixed-failing-test-for-ExtUtils-CBuilder.patch
</pre>

<p>And that was it! You can see the result
<a href="http://www.nntp.perl.org/group/perl.perl5.porters/2009/07/msg148055.html">here</a>.
I started to fiddle with the <code>pod2usage</code> failure, but it was a bit
obscure for me. Perhaps next time.</p>

<p>And speaking of next time, I'm forking the Perl repository on GitHub, and
will probably start to use my own repository for stuff (if it can be kept up
to date; RJBS points out that it's currently way behind the core repo). I'll
likely also create a topic branch before fixing a bug, and then send the patch
from there. That way, when it's committed to the remote branch in core, I
won't have to rebase my local copy: I can just delete the topic branch. This
is a nice way to track individual bug fixes that I've worked on, while letting
the maint-5.10 branch just track the core repository, with no local
changes.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/build-5.10-from-git.html">old layout</a>.</small></p>


