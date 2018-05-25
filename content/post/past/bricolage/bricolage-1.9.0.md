--- 
date: 2005-08-20T01:33:49Z
slug: bricolage-1.9.0
title: Bricolage Now has PHP 5 Templating
aliases: [/bricolage/1.9.0.html]
tags: [Bricolage, PHP, Templating, Perl, Apache, mod_perl, Postgres]
type: post
---

Well, I've finally gone and done it. I've released [Bricolage 1.9.0], the first
development release towards 1.10.0, which I plan to get out sometime next month.
Among the new features in this release that I'm most excited about are a
revamped UI, LDAP authentication, and PHP 5 templating support.

The new UI is really nice. [Marshall Roch] ported it all to XHTML 1.0 strict
plus CSS. All the layout is done with CSS now, instead of the old 1999-era table
layouts we had before. The result is much smaller page loads, sometimes up to
70% smaller, Marshall tells me, and therefore much faster loads. Playing around
with the new version (now powering the [Kineticode] and [Bricolage] Web sites, I
do indeed find it to be a lot zippier. Couple the new UI with the new
[mod\_gzip] support and static Mason components, and things just perk right
along! Oh, and the expandable interfaces for both lists of objects and for
editing interfaces is very nice, indeed. Thank you Marshall for the great work!

Kineticode added the LDAP authentication support. We've been using a patch for
it against 1.8.x for our internal version of Bricolage and it works great. Now
we authenticate off of an OpenLDAP server, using the same usernames and
passwords we use for our email, Subversion, and [RT] servers. The configuration
is simple, via *bricolage.conf* directives, and you can even limit users who
authenticate to members of a particular LDAP group. Users must exist in
Bricolage, and if LDAP authentication fails, you can fall back on Bricolage's
internal authentication. I'm hoping that the LDAP support goes a long way
towards attracting more enterprise customers with single sign-on requirements.

And finally—yes, you heard right—Bricolage now supports PHP 5 templating in
addition to the existing Perl-based templating architectures ([Mason], [Template
Toolkit], and [HTML::Template]). So how did we add PHP 5 templating to a
[mod\_perl] application? Easy: we hired George Schlossnagle of [Omni TI] to
write [PHP::Interpreter], an embedded PHP 5 interpreter. Now anyone can natively
execute PHP 5 code from a Perl application. Not only that, but the PHP 5 code
can reach back into the Perl interpreter to use Perl modules and objects! Here's
an example that I like to show off to the PHP crowd:

``` php
<?php
    $perl = Perl::getInstance();
    $perl->eval("use DBI");
    $perl->eval("use DateTime");
    $dbh = $perl->call("DBI::connect", "DBI", "dbi:SQLite:dbname=dbfile");
    $dbh->do("CREATE TABLE foo (bar TEXT, time DATETIME)");
    $now = $perl->call("DateTime::now", "DateTime");
    $ins = $dbh->prepare("INSERT INTO foo VALUES (?, ?)");
    $ins->execute("This is a test", $now);
    $sel = $dbh->prepare("SELECT bar, time FROM foo");
    $sel->execute();
    $a = array("foo", "bar");
    foreach ($sel->fetch() as $val) {
        echo "$val\n";
    }
    $sel->finish();
    $dbh->do("DROP TABLE foo");
    $dbh->disconnect();
?>
```

Note that George plans to add convenience methods to load Perl modules and call
Perl class methods. Now, to execute this code from Perl, all you have to do is
write a little script, call it *pphp*, like so:

``` perl
use strict;
use PHP::Interpreter;
my $php = PHP::Interpreter->new;
$php->include(shift);
```

Then just execute your PHP code with the script: `pphp try.php`. Yes, this
*does* work! For years, when I've run across a PHP coder who wanted to try to
tell me that PHP was better than Perl, I always had a one-word reply that left
him cursing and conceding defeat: “**CPAN**.” Well no more. Now PHP hackers can
use any module on CPAN, too!

And as for Bricolage, the integration of PHP 5 templating is completely
transparent. Users just write PHP 5 templates instead of Mason templates and
that's it! For example, this is a fairly common style Bricolage Mason template:

``` perl
<%perl>;
for my $e ($element->get_elements(qw(header para _pull_quote_))) {
    my $kn = $e->get_key_name;
    if ($kn eq "para") {
        $m->print("<p>", $e->get_data, "</p>\n");
    } elsif ($kn eq "header") {
        # Test sdisplay_element() on a field.
        $m->print("<h3>", $burner->sdisplay_element($e), "</h3>\n");
    } elsif ($kn eq "_pull_quote_" && $e->get_object_order > 1) {
        # Test sdisplay_element() on a container.
        $m->print($burner->sdisplay_element($e));
    } else {
        # Test display_element().
        $burner->display_element($e);
    }
}
$burner->display_pages("_page_");
</%perl>
```

The same template in PHP 5 looks like this:

``` php
<?php
    # Convenience variables.
    $story   = $BRIC["story"];
    $element = $BRIC["element"];
    $burner  = $BRIC["burner"];
    foreach ($element->get_elements("header", "para", "_pull_quote_") as $e) {
        $kn = $e->get_key_name();
        if ($kn == "para") {
            echo "<p>", $e->get_data(), "</p>\n";
        } else if ($kn == "header") {
            # Test sdisplay_element() on a field.
            echo "<h3>", $burner->sdisplay_element($e), "</h3>\n";
        } else if ($kn == "_pull_quote_" && $e->get_object_order() > 1) {
            # Test sdisplay_element() on a container.
            echo $burner->sdisplay_element($e);
        } else {
            # Test display_element().
            $burner->display_element($e);
        }
    }
    $burner->display_pages("_page_");
?>
```

Yes, you are seeing virtually the same thing. But this is just a simple template
from Bricolage's test suite. The advantage is that PHP 5 coders who are familiar
with all the ins and outs of PHP 5 can just jump in an get started writing
Bricolage templates without having to learn any Perl! The Bricolage objects have
exactly the same API as they do in Perl, because they are *exactly the same
objects!* So everyone uses the same [API documentation] for the same tasks. The
only issue I've noticed so far is that PHP 5 does not yet have proper Unicode
support. Since all content in Bricolage is stored as UTF-8, this means that the
PHP 5 templates must treat it as binary data. But this is okay as long as
templaters use the `mb_*` PHP 5 functions to parse text.

Overall I'm very excited about this, and hope that it helps Bricolage to reach a
whole new community of users. I'd like to thank Portugal Telecom—SAPO.pt for
sponsoring the development of PHP::Interpreter and its integration into
Bricolage. I believe that they've really done the Bricolage community a great
service, and I hope that the Perl and PHP communities likewise benefit from the
integration possible with PHP::Interpreter.

And just so that the other templating architectures don't feel left out, here is
how the above template looks in Template Toolkit:

    [% FOREACH e = element.get_elements("header", "para", "_pull_quote_") %]
        [% kn = e.get_key_name %]
        [% IF kn == "para" %]
    <p>[% e.get_data %]</p>
        [% ELSIF kn == "header" %]
            [% # display_element() should just return a value. %]
    <h3>[% burner.display_element(e) %]</h3>
        [% ELSIF kn == "_pull_quote_" && e.get_object_order > 1 %]
            [% PERL %]
              # There is no sdisplay_element() in the TT burner, but we"ll just
              # Play with it, anyway.
              print $stash->get("burner")->display_element($stash->get("e"));
            [% END %]
        [% ELSE %]
            [% # Test display_element(). %]
            [% burner.display_element(e) %]
        [% END %]
    [% END %]
    [% burner.display_pages("_page_") %]

And here it is in HTML::Template:

    <tmpl_if _page__loop>
    <tmpl_loop _page__loop>
    <tmpl_include name="testing/sub/util.tmpl">
    <tmpl_var _page_>
    <tmpl_var page_break>
    </tmpl_loop>
    <tmpl_else>
    <tmpl_include name="testing/sub/util.tmpl">
    </tmpl_if>

I had to use the utility template with HTML::Template to get it to work right,
don't ask why. It looks like this:

    <tmpl_loop element_loop>
    <tmpl_if is_para>
    <p><tmpl_var para></p>
    </tmpl_if>
    <tmpl_if is_header>
    <h3><tmpl_var header></h3>
    </tmpl_if>
    <tmpl_if is__pull_quote_>
    <tmpl_var _pull_quote_>
    </tmpl_if>
    </tmpl_loop>

These templates come from the Bricolage test suite, where until this release,
there were never any template tests before. So you can see that the PHP 5
templating initiative has had major benefits for the stability of Bricolage,
too. Now that I've really worked with all four templating architectures in
Bricolage, I can now say that my preference for which to do goes in this order:

1.  Mason, because of its killer `autohandler` and inheritance architecture
2.  PHP 5 or Template Toolkit are tied for second place
3.  HTML::Template

In truth, all four are capable and have access to the entire Bricolage API so
that they can output anything. So what are you waiting for? [Download Bricolage]
and give it a try!

  [Bricolage 1.9.0]: http://www.bricolage.cc/news/announce/2005/08/19/bricolage-1.9.0/
    "Bricolage 1.9.0 “Punkin” Released"
  [Marshall Roch]: http://www.spastically.com/ "Marshall Roch's Blog"
  [Kineticode]: http://www.kineticode.com/ "Kineticode"
  [Bricolage]: http://www.bricolage.cc "Bricolage"
  [mod\_gzip]: http://www.schroepl.net/projekte/mod_gzip/ "mod_gzip home page"
  [RT]: http://www.bestpractical.com/ "Best Practical makes RT"
  [Mason]: http://www.masonhq.com/ "Mason HQ"
  [Template Toolkit]: http://www.template-toolkit.org/ "TT HQ"
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
    "HTML::Template on CPAN"
  [mod\_perl]: http://perl.apache.org/ "mod_perl HQ"
  [Omni TI]: http://www.omniti.com/ "Omni TI Consulting"
  [PHP::Interpreter]: http://search.cpan.org/dist/PHP-Interpreter/
    "PHP::Interpreter on CPAN"
  [API documentation]: http://www.bricolage.cc/docs/devel/api/
    "Bricolage development API, subject to change"
  [Download Bricolage]: http://www.bricolage.cc/downloads/bricolage-1.9.0.tar.gz
    "Download Bricolage 1.9.0"
