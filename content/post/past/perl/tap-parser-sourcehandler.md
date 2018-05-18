--- 
date: 2009-11-17T22:29:18Z
slug: tap-parser-sourcehandler
title: Test Everything with TAP Source Handlers
aliases: [/computers/programming/perl/tap-parser-sourcehandler.html]
tags: [Perl, TAP, testing, pgTAP, SourceHandler]
type: post
---

<p>I've just arrived in Japan with my family. We're going to be spending several days in Tokyo, during which time I'll be at the <a href="http://www.postgresql.jp/events/pgcon09j/e/">JPUG 10th Anniversary PostgreSQL Conference</a> for a couple of days (giving <a href="http://www.postgresql.jp/events/pgcon09j/e/program_2#7" title="Unit Test your Database!">the usual talk</a>), but mainly I'll be on vacation. We'll be visiting Kyoto, too. We're really excited about this trip; it'll be a great experience for Anna. I'll be back in the saddle in December, so for those of you anxiously awaiting the next installment of my <a href="/computers/programming/perl/catalyst">Catalyst tutorial</a>, I'm afraid you'll have to wait a bit longer.</p>

<p>In the meantime, I wanted to write about a little something that's been cooking for a while. Over the last several months, <a href="http://www.spurkis.org/">Steve Purkis</a> has been working on a new feature for <a href="http://search.cpan.org/dist/Test&#x002d;Harness/" title="Test::Harness (with TAP:Parser) on CPAN">TAP::Parser</a>: source handlers. The idea is to make it easier for developers to add support for TAP emitters other than Perl. The existing implementation did a decent job of handling Perl test scripts, of course, and executable files (useful for compiled tests in C using <a href="http://code.google.com/p/libperl/wiki/Libtap">libtap</a>, for example), but anything else was difficult.</p>

<p>As the author of <a href="http://pgtap.projects.postgresql.org/">pgTAP</a>, I was of course greatly interested in this work, because I had to bend over backwards to get <code>pg_prove</code> to work nicely. It's <a href="http://pgtap.projects.postgresql.org/integration.html#perl">even uglier</a> to get a Module::Build&#x002d;based distribution to run pgTAP and Perl tests all at once in during <code>./Build test</code>: You had to subclass Module::Build to do it.</p>

<p>Steve wanted to solve this problem, and he did. Then he was kind enough to listen to my bitching an moaning and rewrite his fix so that it was simpler for third parties (read: me) to add new source handlers. What's a source handler, you ask? Check out the latest <a href="http://search.cpan.org/dist/Test&#x002d;Harness/" title="Test::Harness on CPAN">dev release</a> of Test::Harness and you'll see it: <a href="http://search.cpan.org/perldoc?TAP::Parser::SourceHandler">TAP::Parser::SourceHandler</a>. As soon as Steve committed it, I jumped in and implemented a new <a href="http://search.cpan.org/perldoc?TAP::Parser::SourceHandler::pgTAP">handler for pgTAP</a>. The cool thing is that it took me only three hours to do, including tests. And here's how you use it in a <code>Build.PL</code>, so that you can have pgTAP tests named <code>*.pg</code> run at the same time as your <code>*.t</code> Perl tests:</p>

<pre>
Module::Build&#x002d;&gt;new(
    module_name        =&gt; &#x27;MyApp&#x27;,
    test_file_exts     =&gt; [qw(.t .pg)],
    use_tap_harness    =&gt; 1,
    tap_harness_args   =&gt; {
        sources =&gt; {
            Perl  =&gt; undef,
            pgTAP =&gt; {
                dbname   =&gt; &#x27;try&#x27;,
                username =&gt; &#x27;postgres&#x27;,
                suffix   =&gt; &#x27;.pg&#x27;,
            },
        }
    },
    build_requires     =&gt; {
        &#x27;Module::Build&#x27;                      =&gt; &#x27;0.30&#x27;,
        &#x27;TAP::Parser::SourceHandler::pgTAP&#x27; =&gt; &#x27;3.19&#x27;,
    },
)&#x002d;&gt;create_build_script;
</pre>

<p>To summarize, you just have to:</p>

<ul>
<li>Tell Module::Build the extensions of your test scripts (that's <code>qw(.t .pg)</code> here)</li>
<li>Specify the Perl source with its defaults (that's what the <code>undef</code> does)</li>
<li>Specify the pgTAP options (database name, username, suffix, and lots of other potential settings)</li>
</ul>

<p>And that's it. You're done! Run your tests with the usual incantation:</p>

<pre>
perl Build.PL
./Build test
</pre>

<p>You can use pgTAP and its options with <code>prove</code>, too, via the <code>&#x002d;&#x002d;source</code> and  <code>&#x002d;&#x002d;pgtap&#x002d;option</code> options:</p>

<pre>
prove &#x002d;&#x002d;source pgTAP &#x002d;&#x002d;pgtap&#x002d;option dbname=try \
                     &#x002d;&#x002d;pgtap&#x002d;option username=postgres \
                     &#x002d;&#x002d;pgtap&#x002d;option suffix=.pg \
                     t/sometest.pg
</pre>

<p>It's great that it's now so much easier to support pgTAP tests, but what if you want to have Ruby tests? Or PHP? Well, it's a simple process to write your own source handler. Here's how:</p>

<ul>
<li><p>Subclass <a href="http://search.cpan.org/perldoc?TAP::Parser::SourceHandler">TAP::Parser::SourceHandler</a>. The final part of the package name is the name of the source. Thus if you wrote <code>TAP::Parser::SourceHandler::Ruby</code>, the name of your source would be "Ruby".</p></li>
<li><p>Load the necessary modules and register your source handler. For a Ruby source handler, it might look like this:</p>

<pre>
package TAP::Parser::SourceHandler::Ruby;
use strict;
use warnings;

use TAP::Parser::IteratorFactory   ();
use TAP::Parser::Iterator::Process ();
TAP::Parser::IteratorFactory&#x002d;>register_handler(__PACKAGE__);
</pre></li>
<li><p>Implement the <code>can_handle()</code> method. The task of this method is to return a score between 0 and 1 for how likely it is that your source handler can handle a given source. A bunch of information is passed in a hash to the method, so you can check it all out. For example, if you wanted to run Ruby tests ending in <code>.rb</code>, you might write something like this:</p>

<pre>
sub can_handle {
  my ( $class, $source ) = @_;
  my $meta = $source&#x002d;&gt;meta;

  # If it&#x27;s not a file (test script), we&#x27;re not interested.
  return 0 unless $meta&#x002d;&gt;{is_file};

  # Get the file suffix, if any.
  my $suf = $meta&#x002d;&gt;{file}{lc_ext};

  # If the config specifies a suffix, it&#x27;s required.
  if ( my $config = $source&#x002d;&gt;config_for(&#x27;Ruby&#x27;) ) {
      if ( defined $config&#x002d;&gt;{suffix} ) {
          # Return 1 for a perfect score.
          return $suf eq $config&#x002d;&gt;{suffix} ? 1 : 0;
      }
  }

  # Otherwise, return a score for our supported suffix.
  return $suf eq &#x27;.rb&#x27; ? 0.8 : 0;
}
</pre>

<p>The last line is the most important: it returns 0.8 if the suffix is <code>.rb</code>, saying that it's likely that this handler can handle the test. But the middle bit is interesting, too. The <code>$source&#x002d;&gt;config_for(&#x0027;Ruby&#x0027;)</code> call is seeing if the user specified a suffix, either via the command&#x002d;line or in the options. So in a <code>Build.PL</code>, that might be:</p>

<pre>
  tap_harness_args =&gt; {
      sources =&gt; {
          Perl =&gt; undef,
          Ruby =&gt; { suffix =&gt; &#x27;.rub&#x27; },
      }
  },
</pre>

<p>Meaning that the user wanted to run tests ending in <code>.rub</code> as Ruby tests. It can also be done on the command&#x002d;line with <code>prove</code>:</p>

<pre>
prove &#x002d;&#x002d;source Ruby &#x002d;&#x002d;ruby&#x002d;option suffix=.rub
</pre>

<p>Cool, eh? We have a reasonable default for Ruby tests, <code>.rb</code>, but the user can override however she likes.</p></li>
<li><p>And finally, implement the <code>make_iterator()</code> method. The job of this method is simply to create a <a href="http://search.cpan.org/perldoc?TAP::Parser::Iterator">TAP::Parser::Iterator</a> object to actually run the test. It might look something like this:</p>

<pre>
sub make_iterator {
  my ( $class, $source ) = @_;
  my $config = $source&#x002d;&gt;config_for(&#x27;Ruby&#x27;);

  my $fn = ref $source&#x002d;&gt;raw ? ${ $source&#x002d;&gt;raw } : $source&#x002d;&gt;raw;
  $class&#x002d;&gt;_croak(
      &#x27;No such file or directory: &#x27; . defined $fn ? $fn : &#x27;&#x27;
  ) unless $fn &amp;&amp; &#x002d;e $fn;

  return TAP::Parser::Iterator::Process&#x002d;&gt;new({
      command =&gt; [$config&#x002d;&gt;{ruby} || &#x27;ruby&#x27;, $fn ],
      merge   =&gt; $source&#x002d;&gt;merge
  });
}
</pre>

<p>Simple, right? Just make sure we have a valid file to execute, then instantiate and return a <a href="http://search.cpan.org/perldoc?TAP::Parser::Iterator::Process" title="TAP::Parser::Iterator::Process on CPAN">TAP::Parser::Iterator::Process</a> object to actually run the test.</p></li>
</ul>

<p>That's it. Just two methods and you're ready to go. I've even added support for a <code>suffix</code> option and a <code>ruby</code> option (so that you can point to the <code>ruby</code> executable in case it's not in your path). Using it is easy. I wrote a quick TAP&#x002d;emitting Ruby script like so:</p>

<pre>
puts &#x0027;ok 1 &#x002d; This is a test&#x0027;
puts &#x0027;ok 2 &#x002d; This is another test&#x0027;
puts &#x0027;not ok 3 &#x002d; This is a failed test&#x0027;
</pre>

<p>And to run this test (assuming that TAP::Parser::SourceHandler::Ruby has been installed somewhere where Perl can find it), it&#x0027;s just:</p>

<pre>
% prove &#x002d;&#x002d;source Ruby ~/try.rb &#x002d;&#x002d;verbose
/Users/david/try.rb .. 
ok 1 &#x002d; This is a test
ok 2 &#x002d; This is another test
not ok 3 &#x002d; This is a failed test
Failed 1/3 subtests 

Test Summary Report
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
/Users/david/try.rb (Wstat: 0 Tests: 3 Failed: 1)
  Failed test:  3
  Parse errors: No plan found in TAP output
Files=1, Tests=3,  0 wallclock secs ( 0.02 usr +  0.01 sys =  0.03 CPU)
Result: FAIL
</pre>

<p>It&#x0027;s so easy to create new source handlers now, especially if all you have to do is support a new dynamic language. I've put the simple Ruby example <a href="/code/TAP-Parser-SourceHandler-Ruby.pm">over here</a>; feel free to take it and run with it!</p>
