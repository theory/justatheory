--- 
date: 2009-10-13T19:25:19Z
slug: dbix-connector-methods
title: Suggest Method Names for DBIx::Connector
aliases: [/computers/programming/perl/modules/dbix-connector-methods.html]
tags: [Perl, DBI, database, SQL, DBIx::Connector, bike shedding]
type: post
---

<p>Thanks to feedback from Tim Bunce and Peter Rabbitson in a DBIx::Class <a href="https://rt.cpan.org/Ticket/Display.html?id=47005" title="RT #47005: txn_do should provide a way to disable retry">bug report</a>, I've been reworking <a href="http://search.cpan.org/perldoc?DBIx::Connector" title="DBIx::Connector on CPAN">DBIx::Connector</a>'s block-handling methods. Tim's objection is that the the feature of <code>do()</code> and <code>txn_do()</code> that executes the code reference a second time in the event of a connection failure can be dangerous. That is, it can lead to action-at-a-distance bugs that are hard to find and fix. Tim suggested renaming the methods <code>do_with_retry()</code> and <code>txn_do_with_retry()</code> in order to make explicit what's going on, and to have non-retry versions of the methods.</p>

<p>I've made this change in the <a href="http://github.com/theory/dbix-connector/" title="DBIx::Connector on GitHub">repository</a>. But I wasn't happy with the method names; even though they're unambiguous, they are also overly long and not very friendly. I want people to <em>use</em> the retrying methods, but felt that the long names make the non-retrying preferable to users. While I was at it, I also wanted to get rid of <code>do()</code>, since it quickly became clear that it could <a href="http://github.com/theory/dbix-connector/issues#issue/3" title="Issue #3: API is somewhat confusing">cause some confusion</a> with the DBI's <code>do()</code> method.</p>

<p>I've been thesaurus spelunking for the last few days, and have come up with a few options, but would love to hear other suggestions. I like using <code>run</code> instead of <code>do</code> to avoid confusion with the DBI, but otherwise I'm not really happy with what I've come up with. There are basically five different methods (using Tim's suggestions for the moment):</p>

<dl>
  <dt><code>run( sub {} )</code></dt>
  <dd>Just run a block of code.</dd>
  <dt><code>txn_run( sub {} )</code></dt>
  <dd>Run a block of code inside a transaction.</dd>
  <dt><code>run_with_retry( sub {} )</code></dt>
  <dd>Run a block of code without pinging the database, and re-run the code if it throws an exception and the database turned out to be disconnected.</dd>
  <dt><code>txn_run_with_rerun( sub {} )</code></dt>
  <dd>Like <code>run_with_retry()</code>, but run the block inside a transaction.</dd>
  <dt><code>svp_run( sub {} )</code></dt>
  <dd>Run a block of code inside a savepoint (no retry for savepoints).</dd>
</dl>

<p>Here are some of the names I've come up with so far:</p>

<style type="text/css">
#dbixc {
border-collapse: collapse;
border-right: 1px solid #CCC;
margin: 0 0 1em;
}

#dbixc th {
padding: 0 0.5em;
text-align: left;
border-left: 1px solid #CCC;
border-top: 1px solid #FB7A31;
border-bottom: 1px solid #FB7A31;
background: #FFC;
}

#dbixc td {
border-bottom: 1px solid #CCC;
padding: 0.5em;
border-left: 1px solid #CCC;
}
</style>
<table id="dbixc">
  <tr>
    <th>Run block</th>
    <th>Run in txn</th>
    <th>Run in savepoint</th>
    <th>Run with retry</th>
    <th>Run in txn with retry</th>
    <th>Retry Mnemonic</th>
  </tr>
  <tr>
    <td><code>run</code></td>
    <td><code>txn_run</code></td>
    <td><code>svp_run</code></td>
    <td><code>runup</code></td>
    <td><code>txn_runup</code></td>
    <td>Run assuming the db is up, retry if not.</td>
  </tr>
  <tr>
    <td><code>run</code></td>
    <td><code>txn_run</code></td>
    <td><code>svp_run</code></td>
    <td><code>run_up</code></td>
    <td><code>txn_run_up</code></td>
    <td>Same as above.</td>
  </tr>
  <tr>
    <td><code>run</code></td>
    <td><code>txn_run</code></td>
    <td><code>svp_run</code></td>
    <td><code>rerun</code></td>
    <td><code>txn_rerun</code></td>
    <td>Run assuming the db is up, rerun if not.</td>
  </tr>
  <tr>
    <td><code>run</code></td>
    <td><code>txn_run</code></td>
    <td><code>svp_run</code></td>
    <td><code>run::retry</code></td>
    <td><code>txn_run::retry</code></td>
    <td><code>::</code> means “with”</td>
  </tr>
</table>

<p>That last one is a cute hack suggested
by <a href="http://search.cpan.org/~rkinyon/" title="Rob Kinyon's CPAN
distributions">Rob Kinyon</a> on IRC. As you can see, I'm pretty consistent
with the non-retrying method names; it's the methods that retry that I'm not
satisfied with. A approach I've avoided is to use an adverb for the non-retry
methods, mainly because there is no retry possible for the savepoint methods,
so it seemed silly to have <code>svp_run_safely()</code> to
complement <code>do_safely()</code> and <code>txn_do_safely()</code>.</p>

<p>Brilliant suggestions warmly appreciated.</p>
