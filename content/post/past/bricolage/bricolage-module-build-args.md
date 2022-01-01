--- 
date: 2004-06-18T05:11:18Z
slug: bricolage-module-build-args
title: Fun with Module::Build Argument Processing
aliases: [/bricolage/dev/module_build_args.html]
tags: [Bricolage, Module::Build]
type: post
---

I've spend the better part of the last two days working on a custom subclass of
`Module::Build` to build Bricolage 2.0. It's going to be a lot nicer than the
nasty custom *Makefile* that Bricolage 1.x uses. The reason I'm creating a
custom subclass of `Module::Build` is to be able to do a lot of the extra stuff
that building Bricolage requires. Such as:

-   Copying configuration files from *conf/* into *blib*
-   Copying configuration files from *conf/* into *t* for testing
-   Copying configuration files from *comp/* into *blib*
-   Modifying Bricolage::Util::Config to contain a hard-coded reference to the
    location of *bricolage.conf* once Bricolage has been installed
-   Modifying the contents of *bricolage.conf* to reflect build options
    (forthcoming)
-   Modifying the contents of *httpd.conf* to reflect build options
    (forthcoming)

I'm sure there will be more as Bricolage develops (such as building the
database!), but this is enough for now. I've also been hacking on
`Module::Build` itself to add features I want. For example, I want users to be
able to pass options to *Build.PL* when they call it, so that it can do silent
installs. As it is, you can pass options now, but `Module::Build`'s option
processing lacks flexibility. For example, you can pass options like this:

    perl Build.PL opt1=val1 opt2=val2

And `Module::Build` will store the options in a hash like this:

``` perl
{ "opt1" => "val1",
  "opt2" => "val2" }
```

It understands options that use `--`, too; This invocation

    perl Build.PL --opt1 val1 --opt2 val2

produces the same hash. But be careful how you specify arguments! For example,
Modul::Build doesn't understand unary options or options that use both `--` and
`=>`! To whit, this invocation

    perl Build.PL --loud --opt1=val1 --opt2=val2 --foobar

Yields a hash like this:

``` perl
{ "loud" => "--opt1=val1",
  "opt2=val2" => "--foobar" }
```

Certainly not what I would expect! So to get great flexibility, I [sent a patch]
to the `Module::Build` mail list adding a new parameter to `new()`:
`get_options`. This is an array reference of options that will be passed to
`Getopt::Long::GetOptions()` before `Module::Build` parses arguments. It stores
the results in the same hash as Module::Build normally does, and options not
specified in `get_options` will be processed by `Module::Build` just as before.
But it gives a whole lot more control over what gets grabbed. For example, if I
were to try to get that last example to do what I want, all I'd need to do is
pass in the appropriate `Getopt::Long` specs:

``` perl
my $build = Module::Build->new(
    module_name => "Spangly",
    get_options => [ "loud+", "opt1=s", "opt2=s", "foobar" ],
);
```

Now, the hash yielded is:

``` perl
{ "loud"   => "1",
  "opt1"   => "val1",
  "opt2"   => "val2",
  "foobar" => "1" }
```

Isn't that nicer? And because the full suite of `Getopt::Long` specification is
supported, you can get even fancier:

``` perl
my $loud = 0;
my $build = Module::Build->new(
    module_name => "Spangly",
    get_options => [ "loud+" => \$loud, "foobar!" ],
);
```

Now this invocation:

    perl Build.PL --loud --loud --nofoobar

...sets the `$loud`scalar to `2`, while the args hash is simply
`{ "foobar" => "0" }`. Cool, eh?

Now I've just been discussing the patch with Dave Rolsky on the mail list, and
he argues that, while this is a good idea in principal, he'd rather see a
data-structure based argument list rather than `Getopt::Long`'s magical strings.
Perhaps `Module::Build` will end up “Borging” some of the ideas from
`Getopt::Simple`. But either way, I think that better argument processing is on
the way for `Module::Build`.

  [sent a patch]: https://sourceforge.net/p/module-build/mailman/message/7022986/
