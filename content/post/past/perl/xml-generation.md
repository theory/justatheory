--- 
date: 2009-06-09T23:33:57Z
slug: xml-generation
title: Generating XML in Perl
aliases: [/computers/programming/perl/xml-generation.html]
tags: [Perl, XML]
type: post
---

<p>I've been working on a big <a href="http://www.bricolagecms.org/" title="Bricolage content management and publishing system">Bricolage</a>
project recently, and one of the requirements is to parse an incoming NewsML
feed, turn individual stories into Bricolage SOAP XML, and import them into
Bricolage. I'm using the amazing--if hideously
documented--<a href="http://search.cpan.org/perldoc?XML::LibXML" title="XML::LibXML on CPAN">XML::LibXML</a> to do the parsing of the incoming
NewsML, taking advantage of the power of XPath to pull out the bits I need.
But then came the <a href="https://twitter.com/Theory/status/2085796847" title="My Twery">question</a>: what should I use to generate the XML for
Bricolage?</p>

<p>Based on feedback from various Tweeps, I tried a few different approaches:
<a href="http://search.cpan.org/perldoc?XML::LibXML" title="XML::LibXML on CPAN">XML::LibXML</a>,
<a href="http://search.cpan.org/perldoc?XML::Genx" title="XML::Genx on CPAN">XML::Genx</a>, and of course the
venerable <a href="http://search.cpan.org/perldoc?XML::Writer" title="XML::Writer on CPAN">XML::Writer</a>. In truth, they all suck for one
reason: interface. As a test, I wanted to generate this dead simple
XML:</p>

<pre>
&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot;?&gt;
&lt;assets xmlns=&quot;http://bricolage.sourceforge.net/assets.xsd&quot;&gt;
  &lt;story id=&quot;1234&quot; type=&quot;story&quot;&gt;
    &lt;name&gt;Catch as Catch Can&lt;/name&gt;
  &lt;/story&gt;
&lt;/assets&gt;
</pre>

<p>Just get a load of how you create this XML in XML::LibXML:</p>

<pre>
use XML::LibXML;

my $dom = XML::LibXML::Document-&gt;new( &#x0027;1.0&#x0027;, &#x0027;utf-8&#x0027; );
my $assets = $dom-&gt;createElementNS(&#x0027;http://bricolage.sourceforge.net/assets.xsd&#x0027;, &#x0027;assets&#x0027;);
$dom-&gt;addChild($assets);

my $story = $dom-&gt;createElement(&#x0027;story&#x0027;);
$assets-&gt;addChild($story);
$story-&gt;addChild( $dom-&gt;createAttribute( id =&gt; 1234));
$story-&gt;addChild( $dom-&gt;createAttribute( type =&gt; &#x0027;story&#x0027;));
my $name = $dom-&gt;createElement(&#x0027;name&#x0027;);
$story-&gt;addChild($name);
$name-&gt;addChild($dom-&gt;createTextNode(&#x0027;Catch as Catch Can&#x0027;));

say $dom-&gt;toString;
</pre>

<p>Does anyone actually think that this is intuitive? Okay, if you're used to
dealing with the XHTML DOM in JavaScript it's at least familiar, but
that's <em>hardly</em> an endorsement. XML::Genx isn't much better:</p>

<pre>
use XML::Genx::Simple;

my $w = XML::Genx::Simple-&gt;new;
$w-&gt;StartDocString;

$w-&gt;StartElementLiteral( $w-&gt;DeclareNamespace( &#x0027;http://bricolage.sourceforge.net/assets.xsd&#x0027;, &#x0027;&#x0027;), &#x0027;assets&#x0027; );
$w-&gt;StartElementLiteral( &#x0027;story&#x0027; );
$w-&gt;AddAttributeLiteral( id =&gt; 1234);
$w-&gt;AddAttributeLiteral( type =&gt; &#x0027;story&#x0027;);
$w-&gt;Element( &#x0027;name&#x0027; =&gt; &#x0027;Catch as Catch Can&#x0027; );
$w-&gt;EndElement;
$w-&gt;EndElement;
$w-&gt;EndDocument;

say $w-&gt;GetDocString;
</pre>

<p>It's not like messing with the DOM, but it's essentially the same: Use a
bunch of camelCase methods to declare each thing one-at-a-time. And you have
to count the number of open elements you have yourself, to know how many times
to call <code>EndElement()</code> to close elements. Can't we get the computer
to do this for us?</p>

<p>Feeling a bit frustrated, I went back to XML::Writer, which is what
Bricolage uses internally to generate the XML exported by its SOAP interface.
It looks like this:</p>

<pre>
use XML::Writer;

my $output = &#x0027;&#x0027;;
my $writer = XML::Writer-&gt;new(
    OUTPUT=&gt; \$output,
    ENCODING =&gt; &#x0027;utf8&#x0027;,
);

$writer-&gt;xmlDecl(&#x0027;UTF-8&#x0027;);
#$writer-&gt;startTag([&#x0027;http://bricolage.sourceforge.net/assets.xsd&#x0027;, &#x0027;stories&#x0027;]);
$writer-&gt;startTag(&#x0027;assets&#x0027;, xmlns =&gt; &#x0027;http://bricolage.sourceforge.net/assets.xsd&#x0027;);
$writer-&gt;startTag(&#x0027;story&#x0027;, id =&gt; 1234, type =&gt; &#x0027;story&#x0027;);
$writer-&gt;dataElement(name =&gt; &#x0027;Catch as Catch Can&#x0027;);
$writer-&gt;endTag(&#x0027;story&#x0027;);

$writer-&gt;endTag(&#x0027;assets&#x0027;);

say $output;
</pre>

<p>That's a bit better, in that you can specify the attributes and value of an
element all in one method call. I still have to count opened elements and
figure out where to close them, though. The thing that's missing, as with the
other approaches, is an API that reflects the hierarchical nature of XML
itself. I'm outputting a tree-like document; why should the API be so
hideously object-oriented and flat?</p>

<p>With this insight, I remembered Jesse
Vincent's <a href="http://search.cpan.org/perldoc?Template::Declare" title="Template::Declare on CPAN">Template::Declare</a>. It bills itself as a
templating library, but really it provides an interface for declaratively and
hierarchically generating XML. After a bit of hacking I came up with this:</p>

<pre>
package Template::Declare::TagSet::Bricolage;
BEGIN { $INC{&#x0027;Template/Declare/TagSet/Bricolage.pm&#x0027;} = __FILE__; }
use base &#x0027;Template::Declare::TagSet&#x0027;;

sub get_tag_list {
    return [qw( assets story name )];
}

package My::Template;
use Template::Declare::Tags &#x0027;Bricolage&#x0027;;
use base &#x0027;Template::Declare&#x0027;;

template bricolage =&gt; sub {
    xml_decl { &#x0027;xml&#x0027;, version =&gt; &#x0027;1.0&#x0027;, encoding =&gt; &#x0027;utf-8&#x0027; };
    assets {
        xmlns is &#x0027;http://bricolage.sourceforge.net/assets.xsd&#x0027;;
        story {
            attr { id =&gt; 1234, type =&gt; &#x0027;story&#x0027; };
            name { &#x0027;Catch as Catch Can&#x0027; }
        };
    };
};

package main;
use Template::Declare;
Template::Declare-&gt;init( roots =&gt; [&#x0027;My::Template&#x0027;]);
say Template::Declare-&gt;show(&#x0027;bricolage&#x0027;);
</pre>

<p>Okay, to be fair I had to do a lot more work to set things up. But once I
did, the core of the XML generation, there in the <code>bricolage</code>
template, is quite simple and straight-forward. Furthermore, thanks to the
hierarchical nature of Template::Declare, the tree structure of the resulting
XML is apparent in the code. And it's so concise!</p>

<p>Armed with this information, I whipped up a new module for CPAN:
<a href="http://search.cpan.org/perldoc?Template::Declare::Bricolage" title="Template::Declare::Bricolage on CPAN">Template::Declare::Bricolage</a>.
This module subclasses Template::Declare to provide a dead-simple interface
for generating XML for the Bricolage SOAP interface. Using this module to
generate the same XML is quite simple:</p>

<pre>
use Template::Declare::Bricolage;

say bricolage {
    story {
        attr { id =&gt; 1234, type =&gt; &#x0027;story&#x0027; };
        name { &#x0027;Catch as Catch Can&#x0027; }
    };
};
</pre>

<p>Yeah. Really. <em>That's it.</em> Because the Bricolage SOAP interface
requires that all XML documents have the top-level <code>&lt;assets&gt;</code>
tag, I just had the <code>bricolage</code> function handle that, as well as
actually executing the template and returning the XML. More complex XML is
just a simple, assuming that you use nice indentation to format your code.
Here's the code to generate XML for a Bricolage workflow object:</p>

<pre>
use Template::Declare::Bricolage;

say bricolage {
    workflow {
        attr        { id =&gt; 1027     };
        name        { &#x0027;Blogs&#x0027;        }
        description { &#x0027;Blog Entries&#x0027; }
        site        { &#x0027;Main Site&#x0027;    }
        type        { &#x0027;Story&#x0027;        }
        active      { 1              }
        desks  {
            desk { attr { start   =&gt; 1 }; &#x0027;Blog Edit&#x0027;    }
            desk { attr { publish =&gt; 1 }; &#x0027;Blog Publish&#x0027; }
        }
    }
};
</pre>

<p>Simple, huh? So the next time you need to generate XML, have a look at
<a href="http://search.cpan.org/perldoc?Template::Declare" title="Template::Declare on CPAN">Template::Declare</a>. It may not be the
fastest XML generator around, but if you have a well-defined list of
elements you need, it's certainly the nicest to use.</p>

<p>Oh, and Bricolage users? Just make use of
use <a href="http://search.cpan.org/perldoc?Template::Declare::Bricolage" title="Template::Declare::Bricolage on CPAN">Template::Declare::Bricolage</a>
to deaden the pain.</p>
