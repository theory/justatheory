--- 
date: 2010-05-19T17:45:57Z
description: I'm not sure I want to get into the business of defending against programmer mistakes in DBIx::Connector module. What do you think?
slug: defend-against-mistakes
title: Defend Against Programmer Mistakes?
aliases: [/computers/programming/perl/defend-against-mistakes.html]
tags: [Perl, DBIx::Connector]
type: post
---

<p>I get email:</p>

<blockquote>
  <p>Hey David,</p>
  
  <p>I ran in to an issue earlier today in production that, while it is an error in my code, <a href="http://search.cpan.org/perldoc?DBIx::Connector">DBIx::Connector</a> could easily handle the issue better.  Here's the use case:</p>

<pre>
package Con;
use Moose;
sub txn {
    my ($self, $code) = @_;
    my @ret;
    warn &quot;BEGIN EVAL\n&quot;;
    eval{ @ret = $code-&gt;() };
    warn &quot;END EVAL\n&quot;;
    die &quot;DIE: $@&quot; if $@;
    return @ret;
}
package main;
my $c = Con-&gt;new();
foreach (1..2) {
    $c-&gt;txn(sub{ next; });
}
</pre>
  
  <p>The result of this is:</p>

<pre>
BEGIN EVAL
Exiting subroutine via next at test.pl line 16.
Exiting eval via next at test.pl line 16.
Exiting subroutine via next at test.pl line 16.
BEGIN EVAL
Exiting subroutine via next at test.pl line 16.
Exiting eval via next at test.pl line 16.
Exiting subroutine via next at test.pl line 16.
</pre>
  
  <p>This means that any code after the eval block is not executed.  And, in the case of DBIx::Connector, means the transaction is not committed or rolled back, and the next call to is <code>txn()</code> mysteriously combined with the previous <code>txn()</code> call.  A quick fix for this is to just add a curly brace in to the eval:</p>

<pre>
eval{ { @ret = $code-&gt;() } };
</pre>
  
  <p>Then the results are more what we'd expect:</p>

<pre>
BEGIN EVAL
Exiting subroutine via next at test.pl line 16.
END EVAL
BEGIN EVAL
Exiting subroutine via next at test.pl line 16.
END EVAL
</pre>
  
  <p>I've fixed my code to use <code>return;</code> instead of <code>next;</code>, but I think this would be a useful fix for DBIx::Connector so that it doesn't act in such an unexpected fashion when the developer accidentally calls next.</p>
</blockquote>

<p>The fix here is pretty simple, but I'm not sure I want to get into the business of defending against programmer mistakes like this in <a href="http://search.cpan.org/perldoc?DBIx::Connector">DBIx::Connector</a> or any module.</p>

<p>What do you think?</p>
