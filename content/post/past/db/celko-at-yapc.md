--- 
date: 2009-05-13T22:45:57Z
slug: celko-at-yapc
title: Learn Mad Database Skillz at YAPC::NA 2009
aliases: [/computers/databases/celko-at-yapc.html]
tags: [databases, Perl, SQL, Joe Celko, database, RDBMS]
type: post
---

<p>A few weeks ago, I
<a href="https://twitter.com/Theory/status/1576878753">twittered</a> that, in
my opinion, application developers should really learn how to use databases.
And by that I mean SQL, really. I know that a lot of app developers like to
use <a href="https://en.wikipedia.org/wiki/Object-relational_mapping" title="Wikipedia: “Object-relational mapping”">ORMs</a> to access the
database, so that you don't have to really think about it, but most ORMs are
written by people who <a href="http://david.loudthinking.com/arc/2005_09.html" title="Choose a single layer of cleverness">don't like databases</a>, don't
like SQL, haven't taken the time to learn it in any depth, and thus don't
write very good SQL. And even if they <a href="http://www.sqlalchemy.org/" title="SQLAlchemy: The Python SQL Toolkit and Object Relational Mapper">do like SQL</a>, that usually means they provide a way for you to execute SQL
queries directly. The reason? Because the ORM does not really understand how
building more and more complex queries can have negative performance issues,
and that
<a href="https://en.wikipedia.org/wiki/There_is_more_than_one_way_to_do_it">there is more than one way to do it</a>. It's pretty common to have to go back to
custom SQL to solve performance issues. So to solve those problems, you gotta
understand SQL.</p>

<p>Another sin of application developers is to try to use very standard SQL 
syntax and features when writing SQL queries, so that they can easily be
ported to other databases. Well, if you're going to do that, you might as well
use an ORM, but never mind. Think about it this way: If you were writing an
application in <a href="http://www.ruby-lang.org/">Ruby</a>, would you avoid the
use of <a href="http://allaboutruby.wordpress.com/2006/01/20/ruby-blocks-101/" title="All About Ruby: “Ruby Blocks 101”">blocks</a> because you might someday
want to port it to Perl? And how often have you decided to port an application
to another database, anyway? Sure, some OSS projects add support for new
databases, but they seldom drop support for one RDBMS in favor of another.</p>

<p>If you're writing an application in
<a href="http://www.perl.org/">Perl</a>, it pays to learn
<a href="http://dave.org.uk/talks/idiomatic/">idiomatic Perl</a>. If you're
writing it in Ruby, it pays to use
<a href="http://cbcg.net/talks/rubyidioms/index.html">idiomatic Ruby</a>. So
why would you settle for anything less when using an RDBMS? SQL is, after all,
just another programming language, and the various dialects have their
advantages and disadvantages. Learning how SQL really works and how to
leverage the features of your RDBMS will only improve the performance,
reliability, and scalability of your app. If your Perl or Ruby or Python code
doesn't look like C, why would you write least-common denominator ANSI-92
compliant SQL? You have a powerful programming language and application server
with an amazing array of features and capabilities. <em>Use them!</em></p>

<p>All of which is a very long-winded way to say that it really, truly
pays to learn the ins and outs of SQL, just like any other language. And if
you're a Perl hacker, you have a great opportunity to do just that at
<a href="http://yapc10.org/" title="YAPC|10 - Pittsburgh - June 22-24, 2009">YAPC::NA 10</a> this summer.
In response to my tweet, YAPC organizer Robert Blackwell
<a href="https://twitter.com/rblackwe/status/1577360108">replied</a> in
agreement, and pointed out that famed SQL expert
<a href="http://www.celko.com/">Joe Celko</a>, author of
<a href="https://www.amazon.com/exec/obidos/search-handle-form/104-8596028-9604762" title="Joe Celko's Books on Amazon.com">numerous volumes</a> on SQL syntax and
techniques, will be offering two classes on SQL at YAPC:</p>

<ul>
  <li><a href="http://yapc10.org/yn2009/talk/2050">Introduction to RDBMS and SQL for the Totally Ignorant</a>. Well, okay, the name of the course is a
  bit unfortunate, but the material covered is not. If you know little or
  nothing about SQL, this course should be a terrific introduction.</li>
  <li><a href="http://yapc10.org/yn2009/talk/2051">The New Stuff in SQL You Don't Know About</a>. So much great stuff has been added to SQL over the
  years, and ORMs know virtually none of it. Learn how to put that stuff to
  work in your apps!</li>
</ul>

<p>This is a great opportunity to expand your knowledge of SQL, how it works,
and why it's so powerful. (Even if you're not fond of the idea of relational
databases, think of it as an opportunity to follow
<a href="http://markmail.org/message/tpatt4rgdwmcjsvg" title="Re: Thoughts on maintaining perl">Tom Christiansen's injunction</a> and
learn a bit about logical programming.) Celko knows SQL like nobody's
business, and will be sharing that knowledge in two remarkably cheap courses.
Even if you're not a Perl hacker, if you want to really learn the ins and outs
of SQL-- how to write idiomatic SQL to match the mad skillz you already apply
to your application code, you could hardly do better than to get in on these
deals and drink from the Celko firehose. I only wish I was going to be there
(alas, prior plans interfered). But do please tell me all about it!</p>
