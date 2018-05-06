--- 
date: 2004-09-14T03:13:00Z
slug: utf8-trials
title: Lessons Learned with Perl and UTF-8
aliases: [/computers/programming/perl/utf8_trials.html]
tags: [Perl, Bricolage, Unicode, UTF-8]
---

<p>I learned quite a lot last week as I was making Bricolage much more
Unicode-aware. Bricolage has always managed Unicode content and stored it in a
PostgreSQL Unicode-encoded database. And by <q>Unicode</q> I of course
mean <q>UTF-8</q>. By far the biggest nightmare was figuring out 
<a href="/computers/programming/perl/mod_perl/escape_html_utf8.html" title="Apache::Util::escape_html() Doesn't Like Perl UTF-8 Strings">the bug
with <code>Apache::Util::escape_html()</code></a>, but ultimately it came down
to an interesting lesson.</p>

<p>Why was I making Bricolage Unicode-aware? Well, it all started with a
<a href="http://bugs.bricolage.cc/show_bug.cgi?id=648" title="substr() either crap utf8 string or mis-count the length in bytes.">bug report</a> from
Kang-min Liu <a href="http://gugod.org/blog/" title="Gugod's blog: The Mind Of Random">(a.k.a. <q>Gugod</q>)</a>. I had na&iuml;vely thought that if strings
were Unicode that Perl would know it and do the right thing. It turns out I
was wrong. Perl assumes that everything is binary unless you tell it
otherwise. This means that Perl operators such as <code>length</code>
and <code>substr</code> will count bytes instead of characters. And in the
case of Unicode, where characters can be multiple bytes, this can cause
serious problems. Not only were strings improperly concatenated mid-character
for Gugod, but PostgreSQL could <a
href="http://bugs.bricolage.cc/show_bug.cgi?id=709#c14"title="Two bugs in
one!">refuse to accept</a> such strings, since a chopped-up multibyte
character isn't valid Unicode!</p>

<p>So I had to make some decisions: Either stop using Perl operators that
count bytes, or let Perl know that all the strings that Bricolage deals with
are Unicode strings. The former wasn't really an option, of course, since
users can specify that certain content fields be a certain length of
characters. So with a lot of testing help from Gugod and his Bricolage install
full of multibyte characters, I set about doing so. The result is in the
recently released <a href="/bricolage/announce/1.8.2.html" title="Bricolage 1.8.2 Released">Bricolage 1.8.2</a> and I'm blogging what I learned for both
your reference and mine.</p>

<p>Perl considers its internal representation of strings to be UTF-8 strings,
and it knows what variables contain valid UTF-8 strings because they have a
special flag set on them, called, strangely enough, <code>utf8</code>. This
flag isn't set by default, but can be set in a number of ways. The ways I've
found so far are:</p>

<ul>
  <li><p>Using <code>Encode::decode()</code> to decode a string from binary to
    Perl's internal representation. The use of the word <q>decode</q> here had
    confused me for a while, because I thought it was a special encoding. But
    the truth is that it's not. Strings can have any number of encodings, such
    as <q>ISO-8859-1</q>, <q>GB3212</q>, <q>EUC-KR</q>, <q>UTF-8</q>, and the
    like. But when you <q>decode</q> a string, you're telling Perl that it's
    not any of those encodings, but Perl's own representation. I was confused
    because Perl's internal representation is UTF-8, which is an encoding. But
    really it's not UTF-8, It's <q>utf8</q>, which isn't an encoding, but
    Perl's own thing.</p></li>

  <li><p>Cheat: Use <code>Encode::_set_utf8_on()</code>. This private function
      is nevertheless documented by the <a
      href="http://search.cpan.org/dist/Encode/" title="Encode on CPAN">Encode
      module</a>, and therefore usable. What it does is simply turn on the
      <code>utf8</code> flag on a variable. You need be confident that the
      variable contains only valid UTF-8 characters, but if it does, then you
      should be pretty safe.</p></li>

  <li><p>Using the three-argument version of <code>open</code>, such as</p>

    <pre>open my $fh, &quot;&lt;utf8&quot;, &quot;/foo/bar&quot;
  or die &quot;Cannot open file: $!\n&quot;</pre>
    
    <p>Now when you read lines from this file, they will automatically be
      decoded to <code>utf8</code>.</p></li>

  <li><p>Using <code>binmode</code> to set the mode on a file handle:</p>

    <pre>binmode $fh, &quot;:utf8&quot;;</pre>

    <p>As with the three-argument version of <code>open</code> this forces
      Perl to decode the strings read from the file handle.</p></li>

  <li><p><code>use utf8;</code>. This Perl pragma indicates that everything
      within its scope is UTF-8, and therefore should be decoded
      to <code>utf8</code>.</p></li>
</ul>

<p>So I started applying these approaches in various places. The first thing I
did was to set the <code>utf8</code> flag on data coming from the browser with
<code>Encode::_set_utf8_on()</code>. Shitty browsers can of course send shitty
data, but I'm deciding, for the moment at least, to trust browser to send only
UTF-8 when I tell them that's what I want. This solved Gugod's immediate
problem, and I happily closed the bug. But then he started to run into places
where strings appeared properly in some places but not in others. We spent an
entire day (night for Gugod--I really appreciated the help!) tracking down the
problem, and there turned out to be two of them. One was the the bug
with <code>Apache::Util::escape_html()</code> that I've <a
href="/computers/programming/perl/mod_perl/escape_html_utf8.html"
title="Apache::Util::escape_html() Doesn't Like Perl UTF-8 Strings">described
elsewhere</a>, but the other proved more interesting.</p>

<p>It seems that if you concatenate a UTF-8 string with the <code>utf8</code>
flagged turned on with a UTF-8 string without <code>utf8</code> turned on, the
text in the unflagged variable turns to crap! I have no idea why this is, but
Gugod noticed that strings pulled into the UI from the Bricolage zh_tw
localization library simply didn't display properly. I had him add <code>use
utf8;</code> to the zh_tw module, and the problem went away!</p>

<p>So the lesson learned here is: If you're going to make Perl strings
Unicode-aware, then <strong>all</strong> of your Perl strings need to be
Unicode-aware. It's an all or nothing kind of thing.</p>

<p>So while setting the <code>utf8</code> flag on browser submits and
adding <code>use utf8;</code> to the localization modules got us part of the
way toward a solution, it turned out to be trickier than I expected to get
the <code>utf8</code> flag set on everything. The places I needed to get it
working were in the UI Mason components, in templates, and in strings pulled
from the database.</p>

<p>It took a bit of research, but I think I successfully figured out how to
make the UI Mason components UTF-8 aware. I just added <code>preamble =&gt;
&quot;use utf8\n;&quot;</code> to the creation of the Mason interpretor. This
gets passed on to is compiler, and now that string is added to the beginning
of every template. This made things behave better in the UI. I applied the
same approach to the interpreter created for Mason templates with equal
success.</p>

<p>I'm less confident that I pulled it off for the HTML::Template and Template
Toolkit templating architectures. In a <a
href="http://www.template-toolkit.org/pipermail/templates/2004-September/006583.html"
title="Add utf8 to All Templates?">discussion</a> on the templates mailing
list, Andy Wardley <a
href="http://www.template-toolkit.org/pipermail/templates/2004-September/006584.html"
title="Andy Wardley Replies">suggested</a> that it wasn't currently possible.
But I wasn't so sure. It seemed to me that, since Bricolage reads in the
templates and asks TT to execute them within a certain scope, that I could
just set the mode to <code>utf8</code> on the file handle and then execute the
template within the scope of a <code>use utf8;</code> statement. So that's
what I did. Feedback on whether it works or not would be warmly welcomed.</p>

<p>I tried a similar approach with the HTML::Template burner. Again, the
burner reads the templates from files and passes them to HTML::Template for
execution (as near as I could tell, anyway; I'm not an HTML::Template template
user). Hopefully it'll just work.</p>

<p>So that just left the database. Since the database is Unicode-only, all I
needed to do was to turn on the <code>utf8</code> flag</code> for all content pulled
from the database. Amazingly, this hasn't come up as an issue for people very
much, because DBI doesn't do anything about Unicode. I <a
href="http://www.mail-archive.com/dbi-dev@perl.org/msg03451.html" title="UTF-8
flags (again)">picked up an older discussion</a> started by Matt Sergeant on
the dbi-dev mail list, but it looks like it might be a while before DBI has
fast, integrated support for turning <code>utf8</code> on and off for various
database handles and columns. I look forward to it, though, because it's
likely to be very efficient. I greatly look forward to seeing the results
of <a href="http://www.mail-archive.com/dbi-dev@perl.org/msg03452.html" title="Tim Bunce Responds">Tim's work</a> in the next release of DBI. I opened
another <a href="http://bugs.bricolage.cc/show_bug.cgi?id=802" title="Set SvUTF8_on on Data Fetched from Database">bug report</a> to remind myself to take
advantage of the new feature when it's ready.</p>

<p>So in the meantime, I needed to find another solution. Fortunately, my
fellow PostgreSQL users had run into it before, and added what I needed to <a
href="http://search.cpan.org/dist/DBD-Pg/" title="DBD::Pg on CPAN">DBD::Pg</a>
back in version 1.22. The <code>pg_enable_utf8</code> database handle
parameter forces the <code>utf8</code> flag to be turned on for all string
data returned from the database. I added this parameter to Bricolage, and now
all data pulled from the database is <code>utf8</code>. And so are the UI
components, templates, localization libraries, and data submitted from
browsers. I think that nailed everything, but I know that Unicode issues
are a slippery slope. I can't wait until I have to deal with them again!</p>

<p><strong>Not.</strong></p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/perl/utf8_trials.html">old layout</a>.</small></p>


