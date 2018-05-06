--- 
date: 2010-06-03T05:19:10Z
slug: handling-multiple-exceptions
title: Handling Multiple Exceptions
aliases: [/computers/programming/perl/handling-multiple-exceptions.html]
tags: [Perl, exception handling]
---

<p>I ran into an issue with <a href="http://search.cpan.org/perldoc?DBIx::Connector">DBIx::Connector</a> tonight: <a href="http://www.sqlite.org">SQLite</a> started throwing an exception from within a call to <code>rollback()</code>: “DBD::SQLite::db rollback failed: cannot rollback transaction – SQL statements in progress”. This is rather annoying, as it ate the underlying exception that led to the rollback.</p>

<p>So I've added a test to DBIx::Connector that looks like this:</p>

<pre><code>my $dmock = Test::MockModule-&gt;new($conn-&gt;driver);
$dmock-&gt;mock(rollback =&gt; sub { die 'Rollback WTF' });

eval { $conn-&gt;txn(sub {
    my $sth = shift-&gt;prepare("select * from t");
    die 'Transaction WTF';
}) };

ok my $err = $@, 'We should have died';
like $err, qr/Transaction WTF/, 'Should have the transaction error';
</code></pre>

<p>It fails as expected: the error is “Rollback WTF”. So far so good. Now the question is, how should I go about fixing it? Ideally I'd be able to access <em>both</em> exceptions in whatever exception handling I do. How to go about that?</p>

<p>I see three options. The first is that taken by <a href="http://www.bricolagecms.org/">Bricolage</a> and <a href="http://search.cpan.org/perldoc?DBIx::Class">DBIx::Class</a>: create a new exception that combines both the transaction exception and the rollback exception into one. DBIx::Class does it like this:</p>

<pre><code>$self-&gt;throw_exception(
  "Transaction aborted: ${exception}. "
  . "Rollback failed: ${rollback_exception}"
);
</code></pre>

<p>That’s okay as far as it goes. But what if <code>$exception</code> is an <a href="http://search.cpan.org/perldoc?Exception::Class::DBI">Exception::Class::DBI</a> object, or some other exception object? It would get stringified and the exception handler would lose the advantages of the object. But maybe that doesn’t matter so much, since the rollback exception is kind of important to address first?</p>

<p>The second option is to throw a new exception object with the original exceptions as attributes. Something like (pseudo-code):</p>

<pre><code>DBIx::Connector::RollbackException-&gt;new(
    txn_exception      =&gt; $exception,
    rollback_exception =&gt; $rollback_exception,
);
</code></pre>

<p>This has the advantage of keeping the original exception as an object, although the exception handler would have to expect this exception and go digging for it. So far in DBIx::Connector, I've left DBI exception construction up to the DBI and to the consumer, so I'm hesitant to add a one-off special-case exception object like this.</p>

<p>The third option is to use a special variable, <code>@@</code>, and put both exceptions into it. Something like:</p>

<pre><code>@@ = ($exception, $rollback_exception);
die $rollback_exception;
</code></pre>

<p>This approach doesn’t require a dependency like the previous approach, but the user would still have to know to dig into <code>@@</code> if they caught the rollback exception. But then I might as well have thrown a custom exception object that’s easier to interrogate than an exception string. Oh, and is it appropriate to use <code>@@</code>? I seem to recall seeing some discussion of this variable on the perl5-porters mail list, but it’s not documented or supported. Or something. Right?</p>

<p>What would you do?</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/handling-multiple-exceptions.html">old layout</a>.</small></p>


