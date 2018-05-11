--- 
date: 2014-09-21T14:45:00Z
title: Build Modern Perl RPMs with rpmcpan
aliases: [/rpm/2014/09/21/build-modern-perl-rpms-with-rpmcpan/]
tags: [Perl, RPM, CPAN, rpmcpan]
---

{{% figure src="/2014/09/build-modern-perl-rpms-with-rpmcpan/ioperllove.png" alt="iovation + Perl = Love" %}}

We've been using the CentOS Perl RPMs at [iovation] to run all of our Perl
applications. This has been somewhat painful, because the version of Perl,
5.10.1, is quite old --- it shipped in August 2009. In fact, it consists
mostly of bug fixes against Perl 5.10.0, which shipped in December 2007! Many
of the modules provided by CentOS core and [EPEL] are quite old, as well, and
we had built up quite the collection of customized module RPMs managed by a
massive spaghetti-coded Jenkins job. When we recently ran into a Unicode
issue that would best have been addressed by running a more modern Perl ---
rather than a [hinky workaround] --- I finally sat down and knocked out a way
to get a solid set of Modern Perl and related CPAN RPMs.

I gave it the rather boring name `rpmcpan`, and now [you can use it, too].
Turns out, [DevOps] doesn't myopically insist on using core RPMs in the name
of some abstract idea about stability. Rather, we just need a way to easily
deploy our stuff as RPMs. If the same applies to your organization, you can
get Modern Perl RPMs, too.

Here's how we do it. We have a new Jenkins job that runs both nightly and
whenever the [`rpmcpan` Git repository] updates. It uses the [MetaCPAN] API
to build the latest versions of everything we need. Here's how to get it to
build the latest version of Perl, 5.20.1:

``` sh
./bin/rpmcpan --version 5.20.1
```

That will get you a nice, modern Perl RPM, named `perl520`, completely encapsulated in `/usr/local/perl520`. Want 5.18 instead: Just change the version:

``` sh
./bin/rpmcpan --version 5.18.2
```

That will give you `perl518`. But that's not all. You want to build CPAN
distributions against that version. Easy. Just edit the [`dists.json` file].
Its contents are a JSON object where the keys name CPAN distributions (not
modules), and the values are objects that customize our RPMs get built. Most
of the time, the objects can be empty:

``` json
{
    "Try-Tiny": {}
}
```

This results in an RPM named `perl520-Try-Tiny` (or `perl518-Try-Tiny`,
etc.). Sometimes you might need additional information to customize the CPAN
spec file generated to build the distribution. For example, since this is
Linux, we need to exclude a Win32 dependency in the [Encode-Locale]
distribution:

``` json
{
    "Encode-Locale": { "exclude_requires": ["Win32::Console"] }
}
```

Other distributions might require additional RPMs or environment variables,
like [DBD-Pg], which requires the [PostgreSQL RPMs]:

``` json
{
    "DBD-Pg": {
        "build_requires": ["postgresql93-devel", "postgresql93"],
        "environment": { "POSTGRES_HOME": "/usr/pgsql-9.3" }
    }
}
```

See the [README] for a complete list of customization options. Or just get
started with our [`dists.json` file], which so far builds the bare minimum we
need for one of our Perl apps. Add new distributions? Send a [pull request]!
We'll be doing so as we integrate more of our Perl apps with a Modern Perl
and leave the sad RPM past behind.

[iovation]: http://iovation.com/
[EPEL]: https://fedoraproject.org/wiki/EPEL "Extra Packages for Enterprise Linux"
[hinky workaround]: http://grokbase.com/t/perl/perl5-porters/147gfvrd2n/encode-vs-json#20140723oncbjv4rddo66735xess5wo77a "“Encode vs. JSON” on Perl 5 Porters"
[you can use it, too]: https://github.com/iovation/rpmcpan "rpmcpan on GitHub"
[DevOps]: http://twitter.com/aaronblew "Aaron Blew: SRE Manager (dun dun duuuuun!)"
[`rpmcpan` Git repository]: https://github.com/iovation/rpmcpan "rpmcpan on GitHub"
[`dists.json` file]: https://github.com/iovation/rpmcpan/blob/master/etc/dists.json
[Encode-Locale]: http://search.cpan.org/dist/Encode-Locale "Encode-Locale on CPAN"
[PostgreSQL RPMs]: http://yum.postgresql.org "PostgreSQL Yum Repository"
[README]: https://github.com/iovation/rpmcpan/blob/master/README.md "`rpmcpan README`"
[pull request]: https://github.com/iovation/rpmcpan/pulls
[MetaCPAN]: https://metacpan.org/
[DBD-Pg]: http://search.cpan/org/dist/DBD-Pg/ "DBD-Pg on CPAN"
