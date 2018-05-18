--- 
date: 2010-04-28T00:14:07Z
slug: execute-on-select
title: Execute SQL Code on Connect
aliases: [/computers/databases/postgresql/execute-on-select.html]
tags: [Postgres, Perl, Ruby, Ruby on Rails, Catalyst, DBI, PL/Perl]
type: post
---

<p>I&#8217;ve been writing a fair bit of <a href="http://www.postgresql.org/docs/current/static/plperl.html">PL/Perl</a> for a client, and one of the things I&#8217;ve been doing is eliminating a ton of duplicate code by <a href="http://www.depesz.com/index.php/2008/08/01/writing-sprintf-and-overcoming-limitations-in-plperl/">creating utility functions</a> in the <code>%_SHARED</code> hash. This is great, as long as the code that creates those functions gets executed at the beginning of every database connection. So I put the utility generation code into a single function, called <code>prepare_perl_utils()</code>. It looks something like this:</p>

<pre>CREATE OR REPLACE FUNCTION prepare_perl_utils(
) RETURNS bool LANGUAGE plperl IMMUTABLE AS $$
    # Don&#x0027;t bother if we&#x0027;ve already loaded.
    return 1 if $_SHARED{escape_literal};

    $_SHARED{escape_literal} = sub {
        $_[0] =~ s/&#x0027;/&#x0027;&#x0027;/g; $_[0] =~ s/\\/\\\\/g; $_[0];
    };

    # Create other code refs in %_SHARED…
$$;
</pre>

<p>So now all I have to do is make sure that all the client&#8217;s apps execute this function as soon as they connect, so that the utilities will all be loaded up and ready to go. Here&#8217;s how I did it.</p>

<p>First, for the Perl app, I just took advantage of the <a href="http://dbi.perl.org/">DBI</a>&#8217;s <a href="http://search.cpan.org/dist/DBI/DBI.pm#Callbacks_(hash_ref)">callbacks</a> to execute the SQL I need when the DBI connects to the database. That link might not work just yet, as the DBI&#8217;s callbacks have only just been documented and that documentation appears only in dev releases so far. Once 1.611 drops, the link should work. At any rate, the use of callbacks I&#8217;m exploiting here has been in the DBI since 1.49, which was released in November 2005.</p>

<p>The approach is the same as I&#8217;ve <a href="/computers/programming/perl/dbi-connect-cached-hack.html">described before</a>: Just specify the <code>Callbacks</code> parameter to <code>DBI-&gt;connect</code>, like so:</p>

<pre>my $dbh = DBI-&gt;connect_cached($dsn, $user, $pass, {
    PrintError     =&gt; 0,
    RaiseError     =&gt; 1,
    AutoCommit     =&gt; 1,
    Callbacks      =&gt; {
        connected =&gt; sub { shift-&gt;do(&#x0027;SELECT prepare_perl_utils()&#x0027; },
    },
});
</pre>

<p>That&#8217;s it. The <code>connected</code> method is a no-op in the DBI that gets called to alert subclasses that they can do any post-connection initialization. Even without a subclass, we can take advantage of it to do our own initialization.</p>

<p>It was a bit trickier to make the same thing happen for the client&#8217;s <a href="http://rubyonrails.org/">Rails</a> app. Rails, alas, provides no on-connection callbacks. So we instead have to monkey-patch Rails to do what we want. With some help from &#8220;dfr|mac&#8221; on #rubyonrails (I haven&#8217;t touched Rails in 3 years!), I got it worked down to this:</p>

<pre>class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  def initialize_with_perl_utils(*args)
    returning(initialize_without_perl_utils(*args)) do
      execute(&#x0027;SELECT prepare_perl_utils()&#x0027;)
    end
  end
  alias_method_chain :initialize, :perl_utils
end
</pre>

<p>Basically, we overpower the PostgreSQL adapter&#8217;s <code>initialize</code> method and have it call <code>initialize_with_perl_utils</code> before it returns. It&#8217;s a neat trick; if you&#8217;re going to practice <a href="/computers/programming/methodology/fuck-typing.html">fuck typing</a>, <code>alias_method_chain</code> makes it about as clean as can be, albeit a little too magical for my tastes.</p>

<p>Anyway, recorded here for posterity (my blog is my other brain!).</p>
