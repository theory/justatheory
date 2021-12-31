--- 
date: 2009-06-09T23:33:57Z
slug: perl-xml-generation
title: Generating XML in Perl
aliases: [/computers/programming/perl/xml-generation.html]
tags: [Perl, XML]
type: post
---

I've been working on a big [Bricolage] project recently, and one of the
requirements is to parse an incoming NewsML feed, turn individual stories into
Bricolage SOAP XML, and import them into Bricolage. I'm using the amazing--if
hideously documented--[XML::LibXML] to do the parsing of the incoming NewsML,
taking advantage of the power of XPath to pull out the bits I need. But then
came the [question][]: what should I use to generate the XML for Bricolage?

Based on feedback from various Tweeps, I tried a few different approaches:
[XML::LibXML], [XML::Genx], and of course the venerable [XML::Writer]. In truth,
they all suck for one reason: interface. As a test, I wanted to generate this
dead simple XML:

``` xml
<?xml version="1.0" encoding="utf-8"?>
<assets xmlns="http://bricolage.sourceforge.net/assets.xsd">
    <story id="1234" type="story">
    <name>Catch as Catch Can</name>
    </story>
</assets>
```

Just get a load of how you create this XML in XML::LibXML:

``` perl
use XML::LibXML;

my $dom = XML::LibXML::Document->new( '1.0', 'utf-8' );
my $assets = $dom->createElementNS('http://bricolage.sourceforge.net/assets.xsd', 'assets');
$dom->addChild($assets);

my $story = $dom->createElement('story');
$assets->addChild($story);
$story->addChild( $dom->createAttribute( id => 1234));
$story->addChild( $dom->createAttribute( type => 'story'));
my $name = $dom->createElement('name');
$story->addChild($name);
$name->addChild($dom->createTextNode('Catch as Catch Can'));

say $dom->toString;
```

Does anyone actually think that this is intuitive? Okay, if you're used to
dealing with the XHTML DOM in JavaScript it's at least familiar, but that's
*hardly* an endorsement. XML::Genx isn't much better:

``` perl
use XML::Genx::Simple;

my $w = XML::Genx::Simple->new;
$w->StartDocString;

$w->StartElementLiteral( $w->DeclareNamespace( 'http://bricolage.sourceforge.net/assets.xsd', ''), 'assets' );
$w->StartElementLiteral( 'story' );
$w->AddAttributeLiteral( id => 1234);
$w->AddAttributeLiteral( type => 'story');
$w->Element( 'name' => 'Catch as Catch Can' );
$w->EndElement;
$w->EndElement;
$w->EndDocument;

say $w->GetDocString;
```

It's not like messing with the DOM, but it's essentially the same: Use a bunch
of camelCase methods to declare each thing one-at-a-time. And you have to count
the number of open elements you have yourself, to know how many times to call
`EndElement()` to close elements. Can't we get the computer to do this for us?

Feeling a bit frustrated, I went back to XML::Writer, which is what Bricolage
uses internally to generate the XML exported by its SOAP interface. It looks
like this:

``` perl
use XML::Writer;

my $output = '';
my $writer = XML::Writer->new(
    OUTPUT=> \$output,
    ENCODING => 'utf8',
);

$writer->xmlDecl('UTF-8');
#$writer->startTag(['http://bricolage.sourceforge.net/assets.xsd', 'stories']);
$writer->startTag('assets', xmlns => 'http://bricolage.sourceforge.net/assets.xsd');
$writer->startTag('story', id => 1234, type => 'story');
$writer->dataElement(name => 'Catch as Catch Can');
$writer->endTag('story');

$writer->endTag('assets');

say $output;
```

That's a bit better, in that you can specify the attributes and value of an
element all in one method call. I still have to count opened elements and figure
out where to close them, though. The thing that's missing, as with the other
approaches, is an API that reflects the hierarchical nature of XML itself. I'm
outputting a tree-like document; why should the API be so hideously
object-oriented and flat?

With this insight, I remembered Jesse Vincent's [Template::Declare]. It bills
itself as a templating library, but really it provides an interface for
declaratively and hierarchically generating XML. After a bit of hacking I came
up with this:

``` perl
package Template::Declare::TagSet::Bricolage;
BEGIN { $INC{'Template/Declare/TagSet/Bricolage.pm'} = __FILE__; }
use base 'Template::Declare::TagSet';

sub get_tag_list {
    return [qw( assets story name )];
}

package My::Template;
use Template::Declare::Tags 'Bricolage';
use base 'Template::Declare';

template bricolage => sub {
    xml_decl { 'xml', version => '1.0', encoding => 'utf-8' };
    assets {
        xmlns is 'http://bricolage.sourceforge.net/assets.xsd';
        story {
            attr { id => 1234, type => 'story' };
            name { 'Catch as Catch Can' }
        };
    };
};

package main;
use Template::Declare;
Template::Declare->init( roots => ['My::Template']);
say Template::Declare->show('bricolage');
```

Okay, to be fair I had to do a lot more work to set things up. But once I did,
the core of the XML generation, there in the `bricolage` template, is quite
simple and straight-forward. Furthermore, thanks to the hierarchical nature of
Template::Declare, the tree structure of the resulting XML is apparent in the
code. And it's so concise!

Armed with this information, I whipped up a new module for CPAN:
[Template::Declare::Bricolage]. This module subclasses Template::Declare to
provide a dead-simple interface for generating XML for the Bricolage SOAP
interface. Using this module to generate the same XML is quite simple:

``` perl
use Template::Declare::Bricolage;

say bricolage {
    story {
        attr { id => 1234, type => 'story' };
        name { 'Catch as Catch Can' }
    };
};
```

Yeah. Really. *That's it.* Because the Bricolage SOAP interface requires that
all XML documents have the top-level `<assets>` tag, I just had the `bricolage`
function handle that, as well as actually executing the template and returning
the XML. More complex XML is just a simple, assuming that you use nice
indentation to format your code. Here's the code to generate XML for a Bricolage
workflow object:

``` perl
use Template::Declare::Bricolage;

say bricolage {
    workflow {
        attr        { id => 1027     };
        name        { 'Blogs'        }
        description { 'Blog Entries' }
        site        { 'Main Site'    }
        type        { 'Story'        }
        active      { 1              }
        desks  {
            desk { attr { start   => 1 }; 'Blog Edit'    }
            desk { attr { publish => 1 }; 'Blog Publish' }
        }
    }
};
```

Simple, huh? So the next time you need to generate XML, have a look at
[Template::Declare]. It may not be the fastest XML generator around, but if you
have a well-defined list of elements you need, it's certainly the nicest to use.

Oh, and Bricolage users? Just make use of use [Template::Declare::Bricolage] to
deaden the pain.

  [Bricolage]: http://www.bricolagecms.org/
    "Bricolage content management and publishing system"
  [XML::LibXML]: https://metacpan.org/pod/XML::LibXML
    "XML::LibXML on CPAN"
  [question]: https://twitter.com/Theory/status/2085796847 "My Twery"
  [XML::Genx]: https://metacpan.org/pod/XML::Genx "XML::Genx on CPAN"
  [XML::Writer]: https://metacpan.org/pod/XML::Writer
    "XML::Writer on CPAN"
  [Template::Declare]: https://metacpan.org/pod/Template::Declare
    "Template::Declare on CPAN"
  [Template::Declare::Bricolage]: https://metacpan.org/pod/Template::Declare::Bricolage
    "Template::Declare::Bricolage on CPAN"
