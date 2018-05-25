--- 
date: 2009-07-03T06:30:54Z
slug: build-perl-5.10-from-git
title: Checkout and Build Perl 5.10 from Git
aliases: [/computers/programming/perl/build-5.10-from-git.html]
tags: [Perl, Perl 5 Porters, Git, Hacking]
type: post
---

Tonight we had a [Portland Perl Mongers Perl 5.10 code sprint]. This was the
first time I've ever worked with the Perl 5 core code, and while things weren't
exactly intuitive, it wasn't bad to get started, either. I already had a clone
of the Perl Git repository, so here's what I did to get started.

Here's how to clone the Git repository, and then check out the maint-5.10 branch
and build and test Perl:

    git clone git://perl5.git.perl.org/perl.git
    cd perl
    git checkout -b maint-5.10 origin/maint-5.10
    sh Configure -Ode \
     -DDEBUGGING \
     -Dprefix=/usr/local/perl/blead \
     -Dusedevel \
     -Duseithreads \
     -Dccflags='-I/usr/local/include' -Dldflags='-L/usr/local/lib' \
     -Dlibpth='/usr/local/lib /usr/lib' \
     -Uversiononly \
     -Uinstallusrbinperl $@
    make
    make test

I had two test failures:

    #   at ../lib/ExtUtils/CBuilder/t/00-have-compiler.t line 39.
    #          got: '0'
    #     expected: '1'
    # Looks like you failed 1 test of 4.
    FAILED at test 4

And:

    #   at pod/pod2usage2.t line 235.
    # Got:
    # #Usage:
    # #    This is a test for CPAN#33020
    # #
    # #Usage:
    # #    And this will be also printed.
    # #
    # 

So the first thing I want to do is fix those failures. It took a bit of fiddling
to figure out how to get it to run a single test. On the advice of Paul Fenwick
and Schwern, I tried:

    ./perl -Ilib lib/ExtUtils/CBuilder/t/00-have-compiler.t

But then the test passed! So something has to be different when running under
`make test`. With help from Duke Leto, I finally figured out the proper
incantation:

    make test TEST_FILES=../lib/ExtUtils/CBuilder/t/00-have-compiler.t

So the `TEST_FILES` option tells `make test` what tests to run, relative to the
`t/` directory. Shortly thereafter, Schwern told me about:

    cd t
    ./perl TEST ../lib/ExtUtils/CBuilder/t/00-have-compiler.t

Which is nice, because it does a lot less work.

Now I was ready to figure out the ExtUtils::CBuilder bug and fix it. This is
good, I thought, because ExtUtils::CBuilder is a Perl module, and while my C is
teh suck, my Perl skillz are mad. So I do some poking around, and finally pinned
down the failure to the `have_compiler()` method in ExtUtils::CBuilder::Base. A
bit more poking and I had the error printed out:

    # error building /tmp/compilet-1529033816.o from '/tmp/compilet-1529033816.c'
    at ../../ExtUtils/CBuilder/Base.pm line 110.

Well fuck, that sure looks like a C problem. But then I added some more
debugging code to see what command it's actually running, and from where. So I
added this code:

``` perl
use Cwd;
print STDERR "# CWD: ", getcwd, $/;
print STDERR "# ", join( ' ', @cc, @flags), $/;
```

And then I got this output:

    # CWD: /Users/david/dev/perl/lib/ExtUtils/CBuilder
    # ./perl -e1 -- -I/Users/david/dev/perl/perl -c -fno-common -DPERL_DARWIN -no-cpp-precomp -fno-strict-aliasing -pipe -fstack-protector -I/usr/local/include -O3 -o ./compilet-892348855.o

And of course, there's no `perl` in `lib/ExtUtils/CBuilder`. Why does it think
there is? The test file has this code:

``` perl
$b->{config}{cc} = "$^X -e1 --";
$b->{config}{ld} = "$^X -e1 --";
```

Well, that cinches it. `$^X` is the path to the currently-executing Perl, but in
core--for me at least--that's a relative path. The test changes directories away
from that path, and so it can't find it. So I just needed to get it to use the
proper Perl. Frankly, this test should fail on every platform that runs it, so
I'm not sure how it got committed to the maint-5.10 branch, but here we are.

So I moved up `use File::Spec;` and assigned `File::Spec->rel2abs($^X)` to a
variable before the `chdir`, and used that variable for the `cc` mock. And that
was it, the test passed. Yay!

Now it was time to submit a patch to p5p. I committed the fix to my local clone,
and then, with help from Jacob, generated a patch with `git format-patch -1`.
The `-1` means just a single commit, which is all I'd committed. This generated
a file, named `0001-Fixed-failing-test-for-ExtUtils-CBuilder.patch`. I edited it
to add a comment to the effect that the patch is targeted at the maint-5.10
branch.

Next Jacob helped me get `git` configured to send mail through my gmail account.
I just added these lines to `~/.gitconfig`:

    [sendemail]
            smtpserver = smtp.gmail.com
            smtpserverport = 587
            smtpuser = justatheory
            smtppass = idontthinkso!
            smtpencryption = tls

I then sent the patch with:

    git send-email --to perl5-porters@perl.org 0001-Fixed-failing-test-for-ExtUtils-CBuilder.patch

And that was it! You can see the result [here]. I started to fiddle with the
`pod2usage` failure, but it was a bit obscure for me. Perhaps next time.

And speaking of next time, I'm forking the Perl repository on GitHub, and will
probably start to use my own repository for stuff (if it can be kept up to date;
RJBS points out that it's currently way behind the core repo). I'll likely also
create a topic branch before fixing a bug, and then send the patch from there.
That way, when it's committed to the remote branch in core, I won't have to
rebase my local copy: I can just delete the topic branch. This is a nice way to
track individual bug fixes that I've worked on, while letting the maint-5.10
branch just track the core repository, with no local changes.

  [Portland Perl Mongers Perl 5.10 code sprint]: http://mail.pm.org/pipermail/pdx-pm-list/2009-July/005542.html
  [here]: http://www.nntp.perl.org/group/perl.perl5.porters/2009/07/msg148055.html
