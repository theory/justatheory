---
title: Compiling Postgres with LLVM
slug: compile-postgres-llvm
date: 2024-06-18T18:45:26Z
lastMod: 2024-06-18T18:45:26Z
description: |
  I decided to compile Postgres with LLVM this week but ran into failing tests
  due to server crashes. Here's how to avoid the issue.
tags: [Postgres, LLVM, Clang]
type: post
---

A quick post on the need to use a compatible [Clang] compiler when building
Postgres with [LLVM] support. TL;DR: always point the `CLANG` variable to the
correct Clang binary when compiling Postgres `--with-llvm`.

The Problem
-----------

I'm working on a POC for Postgres binary packaging (more on that soon) and
wanted to try it with LLVM support, which generates [JIT inline extensions].
So I installed [LLVM from Homebrew] on my Mac and built a new Postgres
`--with-llvm` and a pointer to `llvm-config`, as [described in the docs]:

``` sh
brew install llvm
./configure \
    --prefix=$HOME/pgsql-devel \
    --with-llvm \
    LLVM_CONFIG=/opt/homebrew/opt/llvm/bin/llvm-config
make -j8
make install
```

No problems, excellent. Now let's run the tests:

``` console
$ make check
# output elided
1..222
# 37 of 222 tests failed.
# The differences that caused some tests to fail can be viewed in the file "src/test/regress/regression.diffs".
# A copy of the test summary that you see above is saved in the file "src/test/regress/regression.out".
make[1]: *** [check] Error 1
make: *** [check] Error 2
```

This was a surprise! A quick look at that `regression.diffs` file shows:

```
+FATAL:  fatal llvm error: Unsupported stack probing method
+server closed the connection unexpectedly
+	This probably means the server terminated abnormally
+	before or while processing the request.
+connection to server was lost
```

Yikes, the server is crashing! What's in the log file,
`src/test/regress/log/postmaster.log`? (Took a while to find it, thanks
depesz!):

```
2024-06-18 14:13:52.369 EDT client backend[49721] pg_regress/boolean FATAL:  fatal llvm error: Unsupported stack probing method
```

Same error. I tried with both the current master branch and the Postgres 16
release branch and got the same result. I pulled together what data I could
and opened [an LLVM issue].

The Solution
------------

After a few hours, one of the maintainers got back to me:

> The error message is LLVM reporting the backend can't handle the particular
> form of "probe-stack" attribute in the input LLVM IR. So this is likely a
> bug in the way postgres is generating LLVM IR: please file a bug against
> Postgres. (Feel free to reopen if you have some reason to believe the issue
> is on the LLVM side.)

Okay so maybe it's actually a Postgres bug? Seems odd, given the failures on
both master and Postgres 16, but I wrote to pgsql-hackers about it, where
Andres Freund quickly [figured it out]:

> I suspect the issue might be that the version of clang and LLVM are
> diverging too far. Does it work if you pass
> CLANG=/opt/homebrew/opt/llvm/bin/clang to configure?

I gave it a try:

``` sh
make clean
./configure \
    --prefix=$HOME/pgsql-devel \
    --with-llvm \
    LLVM_CONFIG=/opt/homebrew/opt/llvm/bin/llvm-config \
    CLANG=/opt/homebrew/opt/llvm/bin/clang

make -j8
make install
```

And then `make check`:

``` console
$ make check
# output elided
1..222
# All 222 tests passed.
```

Yay, that worked! So what happened? Well, take a look at this:

``` console
$ which clang                                                    
/usr/bin/clang
```

That's Clang as installed by the [Xcode CLI tools]. Apparently there can be
incompatibilities between Clang and LLVM. So one has to be sure to use the
Clang that's compatible with LLVM. Conveniently, the Homebrew LLVM formula
includes the proper Clang; all we have to do is tell the Postgres `configure`
script where to find it.

Pity the Xcode CLI package doesn't include LLVM; it would avoid the problem
altogether.

Upshot
------

Always point the `CLANG` variable to the correct Clang binary when compiling
Postgres `--with-llvm`. I've updated my [pgenv] configuration, which depends
on some other [Homebrew]-installed libraries and [plenv]-installed Perl, to do
the right thing on macOS:

``` sh
PGENV_CONFIGURE_OPTIONS=(
    --with-perl
    "PERL=$HOME/.plenv/shims/perl"
    --with-libxml
    --with-uuid=e2fs
    --with-zlib
    --with-llvm
    LLVM_CONFIG=/opt/homebrew/opt/llvm/bin/llvm-config
    CLANG=/opt/homebrew/opt/llvm/bin/clang
    --with-bonjour
    --with-openssl # Replaced with --with-ssl=openssl in v14
    --enable-tap-tests
    PKG_CONFIG_PATH=/opt/homebrew/opt/icu4c/lib/pkgconfig
    'CPPFLAGS=-I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/openssl/include -I/opt/homebrew/opt/libxml2/include -I/opt/homebrew/opt/icu4c/include'
    'CFLAGS=-I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/openssl/include -I/opt/homebrew/opt/libxml2/include -I/opt/homebrew/opt/icu4c/include'
    'LDFLAGS=-L/opt/homebrew/opt/readline/lib -L/opt/homebrew/opt/openssl/lib -L/opt/homebrew/opt/libxml2/lib -L/opt/homebrew/opt/icu4c/lib'
)
```

And now perhaps this post has helped you fix the same problem.

  [Clang]: https://clang.llvm.org "Clang: a C language family frontend for LLVM"
  [LLVM]: https://llvm.org "The LLVM Compiler Infrastructure"
  [JIT inline extensions]: https://www.postgresql.org/docs/current/jit-extensibility.html
    "Postgres Docs: JIT Extensibility"
  [LLVM from Homebrew]: https://formulae.brew.sh/formula/llvm
  [described in the docs]: https://www.postgresql.org/docs/current/install-make.html#CONFIGURE-OPTIONS-FEATURES
    "Postgres Docs: Building and Installation with Autoconf and Make — PostgreSQL Features"
  [an LLVM issue]: https://github.com/llvm/llvm-project/issues/95804
    "llvm/llvm-project#95804 fatal llvm error: Unsupported stack probing method on llvm 18.1.7"
  [figured it out]: https://www.postgresql.org/message-id/20240617203721.rl5dbk4katakbbk5%40awork3.anarazel.de
    "Re: FYI: LLVM Runtime Crash"
  [Xcode CLI tools]: https://www.macobserver.com/tips/how-to/install-xcode-command-line-tools/
  [pgenv]: https://github.com/theory/pgenv "pgenv — PostgreSQL binary manager"
  [plenv]: https://github.com/tokuhirom/plenv "plenv — perl binary manager"
