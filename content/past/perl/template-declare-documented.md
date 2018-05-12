--- 
date: 2009-10-30T05:09:18Z
slug: template-declare-documented
title: Template::Declare Explained
aliases: [/computers/programming/perl/modules/template-declare-documented.html]
tags: [Perl, templating, Template::Declare, mixins]
type: post
---

<p>Today, <a href="http://blog.sartak.org/">Sartak</a> uploaded a new version of
<a href="http://search.cpan.org/perldoc?Template::Declare" title="Template::Declare on CPAN">Template::Declare</a>.
Why should you care? Well, in addition to the
<a href="/computers/programming/perl/xml-generation.html" title="Just a Theory: “Generating XML in Perl”">nice templating syntax</a>,
the new version features <em>complete documentation</em>. For everything.</p>

<p>This came about because I was trying to understand Template::Declare, with its
occasional mentioning of “mixins” and “paths” and “roots,” and I just wasn’t
getting it out of the
<a href="http://search.cpan.org/~sartak/Template-Declare-0.40/lib/Template/Declare.pm" title="Template::Declare 0.40">existing documentation</a>.
Much of my confusion stemmed from how
<a href="http://search.cpan.org/perldoc?Catalyst::View::Template::Declare" title="Catalyst::View::Template::Declare on CPAN">Catalyst::View::Template::Declare</a>
used Template::Declare. So I started peppering
<a href="http://blog.fsck.com" title="Massively Parallel Procrastination">Jesse</a> with
questions and offering to fill in some gaps in the docs, and he was foolish
enough to give me a commit bit.</p>

<p>I was particularly interested in the <code>import_templates</code> and <code>alias</code> methods.
There was no documentation, and though there were tests, the two methods were
so similar that I could barely tell the difference. I also wasn’t sure what
the point was, though I had ideas. So I asked a bunch of
<a href="http://lists.jifty.org/pipermail/jifty-devel/2009-September/002161.html">questions</a>
and, through the discussion, I started to put the pieces together. I wrote
more tests, and started refactoring things. I'd write some code, rename
things, move them around, combine things, and then see who screamed. Jesse and
Sartak were happy to run the Jifty test suite and even, I think, some
<a href="http://www.bestpractical.com/">Best Practical</a> internal stuff to see what I
broke. And then I'd think I got things just right and they would punch holes
in it again.</p>

<p>But it finally came together, I understood what the methods were trying to do,
and I documented the shit out of it. Then Sartak would copy-edit my docs,
verifying my interpretations, and help me to understand where I got things
wrong.</p>

<p>The new version features a glossary (useful for users of other templating
packages) and extended examples that demonstrate XUL output, postprocessing,
inheritance, and wrappers. And, most importantly, an explanation of aliasing
(think delegation) and mixins (using the new name for <code>import_templates</code>:
<code>mix</code>). I greatly appreciate the time the BPS team took to answer my noobish
questions. And their patience as I ripped things apart and built them up
again. The result is that, in addition to being better documented, the new
version’s <code>alias</code> method creates build much better-performing and less
memory-intensive aliases.</p>

<p>So why was I doing all this? Well,
<a href="http://search.cpan.org/perldoc?Catalyst::View::Template::Declare" title="Catalyst::View::Template::Declare on CPAN">Catalyst::View::Template::Declare</a>
never seemed quite right to me. And in my discussions with the Jifty guys, it
seemed clear that its use of Template::Declare was <a href="http://lists.jifty.org/pipermail/jifty-devel/2009-September/002162.html">trying to alias</a>
kinda sorta, but not really. So as I tried to understand aliasing, I realized
that a new view class was needed for catalyst. So I endeavored to really
understand the features of Template::Declare so that I could do it right.</p>

<p>More news on that soon.</p>

<p>The upshot is that you have pretty nice control over mixing and aliasing
Template::Declare templates into paths. For example, if you have this template
class:</p>

<pre>
package MyApp::Templates::Util;
use base &#x0027;Template::Declare&#x0027;;
use Template::Declare::Tags;

template header =&gt; sub {
    my ($self, $args) = @_;
    head { title {  $args-&gt;{title} } };
};

template footer =&gt; sub {
    div {
        id is &#x0027;fineprint&#x0027;;
        p { &#x0027;Site contents licensed under a Creative Commons License.&#x0027; }
    };
};
</pre>

<p>You can mix those templates into your primary template class like so:</p>

<pre>package MyApp::Templates::Main;
use base &#x0027;Template::Declare&#x0027;;
use Template::Declare::Tags;
use MyApp::Template::Util;
mix MyApp::Template::Util under &#x0027;/util&#x0027;;

template content =&gt; sub {
    show &#x0027;/util/header&#x0027;;
    body {
        h1 { &#x0027;Hello world&#x0027; };
        show &#x0027;/util/footer&#x0027;;
    };
};
</pre>

<p>See how I've used the mixed in <code>header</code> and <code>footer</code> templates by referring to
them under the <code>/util</code> path? This gives the invocation of the other templates
the feel of calling
<a href="http://search.cpan.org/perldoc?HTML::Mason" title=" on CPAN">Mason</a> components or
invoking
<a href="http://search.cpan.org/perldoc?Template" title="Template Toolkit on CPAN">Template Toolkit</a>
templates. You can use these templates like so:</p>

<pre>
Template::Declare-&gt;init( dispatch_to =&gt; [&#x0027;MyApp::Templates::Main&#x0027;] );
print Template::Declare-&gt;show(&#x0027;/content&#x0027;);
</pre>

<p>So <code>MyApp::Templates::Main</code>’s templates are in the “/” directory, so to speak,
while the <code>MyApp::Templates::Util</code>’s templates are in the “/utils”
subdirectory. Pretty cool, eh?</p>

<p>So with this understanding in place, I had a much better feel for
Template::Declare, and could better think of it in normal templating terms.
Now I'm <em>this</em> much closer to my ideal Catalyst development environment. More
soon.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/modules/template-declare-documented.html">old layout</a>.</small></p>


