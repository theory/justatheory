--- 
date: 2005-08-20T01:33:49Z
slug: bricolage-1.9.0
title: Bricolage Now has PHP 5 Templating
aliases: [/bricolage/1.9.0.html]
tags: [Bricolage, PHP, templating, Perl, Apache, mod_perl, Postgres]
type: post
---

<p>Well, I've finally gone and done it. I've released <a href="http://www.bricolage.cc/news/announce/2005/08/19/bricolage-1.9.0/" title="Bricolage 1.9.0 &#x201c;Punkin&#x201d; Released">Bricolage 1.9.0</a>, the first development release towards 1.10.0, which I plan to get out sometime next month. Among the new features in this release that I'm most excited about are a revamped UI, LDAP authentication, and PHP 5 templating support.</p>

<p>The new UI is really nice. <a href="http://www.spastically.com/" title="Marshall Roch's Blog">Marshall Roch</a> ported it all to XHTML 1.0 strict plus CSS. All the layout is done with CSS now, instead of the old 1999-era table layouts we had before. The result is much smaller page loads, sometimes up to 70% smaller, Marshall tells me, and therefore much faster loads. Playing around with the new version (now powering the <a href="http://www.kineticode.com/" title="Kineticode">Kineticode</a> and <a href="http://www.bricolage.cc" title="Bricolage">Bricolage</a> Web sites, I do indeed find it to be a lot zippier. Couple the new UI with the new <a href="http://www.schroepl.net/projekte/mod_gzip/" title="mod_gzip home page">mod_gzip</a> support and static Mason components, and things just perk right along! Oh, and the expandable interfaces for both lists of objects and for editing interfaces is very nice, indeed. Thank you Marshall for the great work!</p>

<p>Kineticode added the LDAP authentication support. We've been using a patch for it against 1.8.x for our internal version of Bricolage and it works great. Now we authenticate off of an OpenLDAP server, using the same usernames and passwords we use for our email, Subversion, and <a href="http://www.bestpractical.com/" title="Best Practical makes RT">RT</a> servers. The configuration is simple, via <em>bricolage.conf</em> directives, and you can even limit users who authenticate to members of a particular LDAP group. Users must exist in Bricolage, and if LDAP authentication fails, you can fall back on Bricolage's internal authentication. I'm hoping that the LDAP support goes a long way towards attracting more enterprise customers with single sign-on requirements.</p>

<p>And finally&#x2014;yes, you heard right&#x2014;Bricolage now supports PHP 5 templating in addition to the existing Perl-based templating architectures (<a href="http://www.masonhq.com/" title="Mason HQ">Mason</a>, <a href="http://www.template-toolkit.org/" title="TT HQ">Template Toolkit</a>, and <a href="http://search.cpan.org/dist/HTML-Template/" title="HTML::Template on CPAN">HTML::Template</a>). So how did we add PHP 5 templating to a <a href="http://perl.apache.org/" title="mod_perl HQ">mod_perl</a> application? Easy: we hired George Schlossnagle of <a href="http://www.omniti.com/" title="Omni TI Consulting">Omni TI</a> to write <a href="http://search.cpan.org/dist/PHP-Interpreter/" title="PHP::Interpreter on CPAN">PHP::Interpreter</a>, an embedded PHP 5 interpreter. Now anyone can natively execute PHP 5 code from a Perl application. Not only that, but the PHP 5 code can reach back into the Perl interpreter to use Perl modules and objects! Here's an example that I like to show off to the PHP crowd:</p>

<pre>
&lt;?php
  $perl = Perl::getInstance();
  $perl-&gt;eval(&quot;use DBI&quot;);
  $perl-&gt;eval(&quot;use DateTime&quot;);
  $dbh = $perl-&gt;call(&quot;DBI::connect&quot;, &quot;DBI&quot;, &quot;dbi:SQLite:dbname=dbfile&quot;);
  $dbh-&gt;do(&quot;CREATE TABLE foo (bar TEXT, time DATETIME)&quot;);
  $now = $perl-&gt;call(&quot;DateTime::now&quot;, &quot;DateTime&quot;);
  $ins = $dbh-&gt;prepare(&quot;INSERT INTO foo VALUES (?, ?)&quot;);
  $ins-&gt;execute(&quot;This is a test&quot;, $now);
  $sel = $dbh-&gt;prepare(&quot;SELECT bar, time FROM foo&quot;);
  $sel-&gt;execute();
  $a = array(&quot;foo&quot;, &quot;bar&quot;);
  foreach ($sel-&gt;fetch() as $val) {
      echo &quot;$val\n&quot;;
  }
  $sel-&gt;finish();
  $dbh-&gt;do(&quot;DROP TABLE foo&quot;);
  $dbh-&gt;disconnect();
?&gt;
</pre>

<p>Note that George plans to add convenience methods to load Perl modules and call Perl class methods. Now, to execute this code from Perl, all you have to do is write a little script, call it <em>pphp</em>, like so:</p>

<pre>
use strict;
use PHP::Interpreter;
my $php = PHP::Interpreter-&gt;new;
$php-&gt;include(shift);
</pre>

<p>Then just execute your PHP code with the script: <code>pphp try.php</code>. Yes, this <em>does</em> work! For years, when I've run across a PHP coder who wanted to try to tell me that PHP was better than Perl, I always had a one-word reply that left him cursing and conceding defeat: <q><strong>CPAN</strong>.</q> Well no more. Now PHP hackers can use any module on CPAN, too!</p>

<p>And as for Bricolage, the integration of PHP 5 templating is completely transparent. Users just write PHP 5 templates instead of Mason templates and that's it! For example, this is a fairly common style Bricolage Mason template:</p>

<pre>
&lt;%perl&gt;;
for my $e ($element-&gt;get_elements(qw(header para _pull_quote_))) {
    my $kn = $e-&gt;get_key_name;
    if ($kn eq &quot;para&quot;) {
        $m-&gt;print(&quot;&lt;p&gt;&quot;, $e-&gt;get_data, &quot;&lt;/p&gt;\n&quot;);
    } elsif ($kn eq &quot;header&quot;) {
        # Test sdisplay_element() on a field.
        $m-&gt;print(&quot;&lt;h3&gt;&quot;, $burner-&gt;sdisplay_element($e), &quot;&lt;/h3&gt;\n&quot;);
    } elsif ($kn eq &quot;_pull_quote_&quot; &amp;&amp; $e-&gt;get_object_order &gt; 1) {
        # Test sdisplay_element() on a container.
        $m-&gt;print($burner-&gt;sdisplay_element($e));
    } else {
        # Test display_element().
        $burner-&gt;display_element($e);
    }
}
$burner-&gt;display_pages(&quot;_page_&quot;);
&lt;/%perl&gt;
</pre>

<p>The same template in PHP 5 looks like this:</p>

<pre>
&lt;?php
# Convenience variables.
$story   = $BRIC[&quot;story&quot;];
$element = $BRIC[&quot;element&quot;];
$burner  = $BRIC[&quot;burner&quot;];
foreach ($element-&gt;get_elements(&quot;header&quot;, &quot;para&quot;, &quot;_pull_quote_&quot;) as $e) {
    $kn = $e-&gt;get_key_name();
    if ($kn == &quot;para&quot;) {
        echo &quot;&lt;p&gt;&quot;, $e-&gt;get_data(), &quot;&lt;/p&gt;\n&quot;;
    } else if ($kn == &quot;header&quot;) {
        # Test sdisplay_element() on a field.
        echo &quot;&lt;h3&gt;&quot;, $burner-&gt;sdisplay_element($e), &quot;&lt;/h3&gt;\n&quot;;
    } else if ($kn == &quot;_pull_quote_&quot; &amp;&amp; $e-&gt;get_object_order() &gt; 1) {
        # Test sdisplay_element() on a container.
        echo $burner-&gt;sdisplay_element($e);
    } else {
        # Test display_element().
        $burner-&gt;display_element($e);
    }
}
$burner-&gt;display_pages(&quot;_page_&quot;);
?&gt;
</pre>

<p>Yes, you are seeing virtually the same thing. But this is just a simple template from Bricolage's test suite. The advantage is that PHP 5 coders who are familiar with all the ins and outs of PHP 5 can just jump in an get started writing Bricolage templates without having to learn any Perl! The Bricolage objects have exactly the same API as they do in Perl, because they are <em>exactly the same objects!</em> So everyone uses the same <a href="http://www.bricolage.cc/docs/devel/api/" title="Bricolage development API, subject to change">API documentation</a> for the same tasks. The only issue I've noticed so far is that PHP 5 does not yet have proper Unicode support. Since all content in Bricolage is stored as UTF-8, this means that the PHP 5 templates must treat it as binary data. But this is okay as long as templaters use the <code>mb_*</code> PHP 5 functions to parse text.</p>

<p>Overall I'm very excited about this, and hope that it helps Bricolage to reach a whole new community of users. I'd like to thank Portugal Telecom&#x2014;SAPO.pt for sponsoring the development of PHP::Interpreter and its integration into Bricolage. I believe that they've really done the Bricolage community a great service, and I hope that the Perl and PHP communities likewise benefit from the integration possible with PHP::Interpreter.</p>

<p>And just so that the other templating architectures don't feel left out, here is how the above template looks in Template Toolkit:</p>

<pre>
[% FOREACH e = element.get_elements(&quot;header&quot;, &quot;para&quot;, &quot;_pull_quote_&quot;) %]
    [% kn = e.get_key_name %]
    [% IF kn == &quot;para&quot; %]
&lt;p&gt;[% e.get_data %]&lt;/p&gt;
    [% ELSIF kn == &quot;header&quot; %]
        [% # display_element() should just return a value. %]
&lt;h3&gt;[% burner.display_element(e) %]&lt;/h3&gt;
    [% ELSIF kn == &quot;_pull_quote_&quot; &amp;&amp; e.get_object_order &gt; 1 %]
        [% PERL %]
          # There is no sdisplay_element() in the TT burner, but we&quot;ll just
          # Play with it, anyway.
          print $stash-&gt;get(&quot;burner&quot;)-&gt;display_element($stash-&gt;get(&quot;e&quot;));
        [% END %]
    [% ELSE %]
        [% # Test display_element(). %]
        [% burner.display_element(e) %]
    [% END %]
[% END %]
[% burner.display_pages(&quot;_page_&quot;) %]
</pre>

<p>And here it is in HTML::Template:</p>

<pre>
&lt;tmpl_if _page__loop&gt;
&lt;tmpl_loop _page__loop&gt;
&lt;tmpl_include name=&quot;testing/sub/util.tmpl&quot;&gt;
&lt;tmpl_var _page_&gt;
&lt;tmpl_var page_break&gt;
&lt;/tmpl_loop&gt;
&lt;tmpl_else&gt;
&lt;tmpl_include name=&quot;testing/sub/util.tmpl&quot;&gt;
&lt;/tmpl_if&gt;
</pre>

<p>I had to use the utility template with HTML::Template to get it to work right, don't ask why. It looks like this:</p>

<pre>
&lt;tmpl_loop element_loop&gt;
&lt;tmpl_if is_para&gt;
&lt;p&gt;&lt;tmpl_var para&gt;&lt;/p&gt;
&lt;/tmpl_if&gt;
&lt;tmpl_if is_header&gt;
&lt;h3&gt;&lt;tmpl_var header&gt;&lt;/h3&gt;
&lt;/tmpl_if&gt;
&lt;tmpl_if is__pull_quote_&gt;
&lt;tmpl_var _pull_quote_&gt;
&lt;/tmpl_if&gt;
&lt;/tmpl_loop&gt;
</pre>

<p>These templates come from the Bricolage test suite, where until this release, there were never any template tests before. So you can see that the PHP 5 templating initiative has had major benefits for the stability of Bricolage, too. Now that I've really worked with all four templating architectures in Bricolage, I can now say that my preference for which to do goes in this order:</p>

<ol>
  <li>Mason, because of its killer <code>autohandler</code> and inheritance architecture</li>
  <li>PHP 5 or Template Toolkit are tied for second place</li>
  <li>HTML::Template</li>
</ol>

<p>In truth, all four are capable and have access to the entire Bricolage API so that they can output anything. So what are you waiting for? <a href="http://www.bricolage.cc/downloads/bricolage-1.9.0.tar.gz" title="Download Bricolage 1.9.0">Download Bricolage</a> and give it a try!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/bricolage/1.9.0.html">old layout</a>.</small></p>


