---
date: 2009-11-17T22:29:18Z
slug: tap-parser-sourcehandler
title: Test Everything with TAP Source Handlers
aliases: [/computers/programming/perl/tap-parser-sourcehandler.html]
tags: [Perl, TAP, Testing, pgTAP, SourceHandler]
type: post
---

I've just arrived in Japan with my family. We're going to be spending several
days in Tokyo, during which time I'll be at the [JPUG 10th Anniversary
PostgreSQL Conference] for a couple of days (giving [the usual talk]), but
mainly I'll be on vacation. We'll be visiting Kyoto, too. We're really excited
about this trip; it'll be a great experience for Anna. I'll be back in the
saddle in December, so for those of you anxiously awaiting the next installment
of my [Catalyst tutorial], I'm afraid you'll have to wait a bit longer.

In the meantime, I wanted to write about a little something that's been cooking
for a while. Over the last several months, [Steve Purkis] has been working on a
new feature for [TAP::Parser][]: source handlers. The idea is to make it easier
for developers to add support for TAP emitters other than Perl. The existing
implementation did a decent job of handling Perl test scripts, of course, and
executable files (useful for compiled tests in C using [libtap], for example),
but anything else was difficult.

As the author of [pgTAP], I was of course greatly interested in this work,
because I had to bend over backwards to get `pg_prove` to work nicely. It's
[even uglier] to get a Module::Build-based distribution to run pgTAP and Perl
tests all at once in during `./Build test`: You had to subclass Module::Build to
do it.

Steve wanted to solve this problem, and he did. Then he was kind enough to
listen to my bitching an moaning and rewrite his fix so that it was simpler for
third parties (read: me) to add new source handlers. What's a source handler,
you ask? Check out the latest [dev release] of Test::Harness and you'll see it:
[TAP::Parser::SourceHandler]. As soon as Steve committed it, I jumped in and
implemented a new [handler for pgTAP]. The cool thing is that it took me only
three hours to do, including tests. And here's how you use it in a `Build.PL`,
so that you can have pgTAP tests named `*.pg` run at the same time as your `*.t`
Perl tests:

``` perl
Module::Build->new(
    module_name        => 'MyApp',
    test_file_exts     => [qw(.t .pg)],
    use_tap_harness    => 1,
    tap_harness_args   => {
        sources => {
            Perl  => undef,
            pgTAP => {
                dbname   => 'try',
                username => 'postgres',
                suffix   => '.pg',
            },
        }
    },
    build_requires     => {
        'Module::Build'                      => '0.30',
        'TAP::Parser::SourceHandler::pgTAP' => '3.19',
    },
)->create_build_script;
```

To summarize, you just have to:

-   Tell Module::Build the extensions of your test scripts (that's `qw(.t .pg)`
    here)
-   Specify the Perl source with its defaults (that's what the `undef` does)
-   Specify the pgTAP options (database name, username, suffix, and lots of
    other potential settings)

And that's it. You're done! Run your tests with the usual incantation:

    perl Build.PL
    ./Build test

You can use pgTAP and its options with `prove`, too, via the `--source` and
`--pgtap-option` options:

    prove --source pgTAP --pgtap-option dbname=try \
                         --pgtap-option username=postgres \
                         --pgtap-option suffix=.pg \
                         t/sometest.pg

It's great that it's now so much easier to support pgTAP tests, but what if you
want to have Ruby tests? Or PHP? Well, it's a simple process to write your own
source handler. Here's how:

-   Subclass [TAP::Parser::SourceHandler]. The final part of the package name is
    the name of the source. Thus if you wrote
    `TAP::Parser::SourceHandler::Ruby`, the name of your source would be "Ruby".

-   Load the necessary modules and register your source handler. For a Ruby
    source handler, it might look like this:

    ``` perl
    package TAP::Parser::SourceHandler::Ruby;
    use strict;
    use warnings;

    use TAP::Parser::IteratorFactory   ();
    use TAP::Parser::Iterator::Process ();
    TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);
    ```

-   Implement the `can_handle()` method. The task of this method is to return a
    score between 0 and 1 for how likely it is that your source handler can
    handle a given source. A bunch of information is passed in a hash to the
    method, so you can check it all out. For example, if you wanted to run Ruby
    tests ending in `.rb`, you might write something like this:

    ``` perl
    sub can_handle {
        my ( $class, $source ) = @_;
        my $meta = $source->meta;

        # If it's not a file (test script), we're not interested.
        return 0 unless $meta->{is_file};

        # Get the file suffix, if any.
        my $suf = $meta->{file}{lc_ext};

        # If the config specifies a suffix, it's required.
        if ( my $config = $source->config_for('Ruby') ) {
            if ( defined $config->{suffix} ) {
                # Return 1 for a perfect score.
                return $suf eq $config->{suffix} ? 1 : 0;
            }
        }

        # Otherwise, return a score for our supported suffix.
        return $suf eq '.rb' ? 0.8 : 0;
    }
    ```

    The last line is the most important: it returns 0.8 if the suffix is `.rb`,
    saying that it's likely that this handler can handle the test. But the
    middle bit is interesting, too. The `$source->config_for('Ruby')` call is
    seeing if the user specified a suffix, either via the command-line or in the
    options. So in a `Build.PL`, that might be:

    ``` perl
        tap_harness_args => {
            sources => {
                Perl => undef,
                Ruby => { suffix => '.rub' },
            }
        },
    ```

    Meaning that the user wanted to run tests ending in `.rub` as Ruby tests. It
    can also be done on the command-line with `prove`:

        prove --source Ruby --ruby-option suffix=.rub

    Cool, eh? We have a reasonable default for Ruby tests, `.rb`, but the user
    can override however she likes.

-   And finally, implement the `make_iterator()` method. The job of this method
    is simply to create a [TAP::Parser::Iterator] object to actually run the
    test. It might look something like this:

    ``` perl
    sub make_iterator {
        my ( $class, $source ) = @_;
        my $config = $source->config_for('Ruby');

        my $fn = ref $source->raw ? ${ $source->raw } : $source->raw;
        $class->_croak(
            'No such file or directory: ' . defined $fn ? $fn : ''
        ) unless $fn && -e $fn;

        return TAP::Parser::Iterator::Process->new({
            command => [$config->{ruby} || 'ruby', $fn ],
            merge   => $source->merge
        });
    }
    ```

    Simple, right? Just make sure we have a valid file to execute, then
    instantiate and return a [TAP::Parser::Iterator::Process] object to actually
    run the test.

That's it. Just two methods and you're ready to go. I've even added support for
a `suffix` option and a `ruby` option (so that you can point to the `ruby`
executable in case it's not in your path). Using it is easy. I wrote a quick
TAP-emitting Ruby script like so:

``` ruby
puts 'ok 1 - This is a test'
puts 'ok 2 - This is another test'
puts 'not ok 3 - This is a failed test'
```

And to run this test (assuming that TAP::Parser::SourceHandler::Ruby has been
installed somewhere where Perl can find it), it's just:

    % prove --source Ruby ~/try.rb --verbose
    /Users/david/try.rb .. 
    ok 1 - This is a test
    ok 2 - This is another test
    not ok 3 - This is a failed test
    Failed 1/3 subtests 

    Test Summary Report
    -------------------
    /Users/david/try.rb (Wstat: 0 Tests: 3 Failed: 1)
      Failed test:  3
      Parse errors: No plan found in TAP output
    Files=1, Tests=3,  0 wallclock secs ( 0.02 usr +  0.01 sys =  0.03 CPU)
    Result: FAIL

It's so easy to create new source handlers now, especially if all you have to do
is support a new dynamic language. I've put the simple Ruby example [over here];
feel free to take it and run with it!

  [JPUG 10th Anniversary PostgreSQL Conference]: http://www.postgresql.jp/events/pgcon09j/e/
  [the usual talk]: http://www.postgresql.jp/events/pgcon09j/e/program_2#7
    "Unit Test your Database!"
  [Catalyst tutorial]: {{% ref "/tags/catalyst" %}}
  [Steve Purkis]: http://www.spurkis.org/
  [TAP::Parser]: https://metacpan.org/dist/Test-Harness/
    "Test::Harness (with TAP:Parser) on CPAN"
  [libtap]: http://code.google.com/p/libperl/wiki/Libtap
  [pgTAP]: http://pgtap.projects.postgresql.org/
  [even uglier]: http://pgtap.projects.postgresql.org/integration.html#perl
  [dev release]: https://metacpan.org/dist/Test-Harness/
    "Test::Harness on CPAN"
  [TAP::Parser::SourceHandler]: https://metacpan.org/pod/TAP::Parser::SourceHandler
  [handler for pgTAP]: https://metacpan.org/pod/TAP::Parser::SourceHandler::pgTAP
  [TAP::Parser::Iterator]: https://metacpan.org/pod/TAP::Parser::Iterator
  [TAP::Parser::Iterator::Process]: https://metacpan.org/pod/TAP::Parser::Iterator::Process
    "TAP::Parser::Iterator::Process on CPAN"
  [over here]: /code/TAP-Parser-SourceHandler-Ruby.pm
