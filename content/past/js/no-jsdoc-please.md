--- 
date: 2005-03-30T06:35:34Z
slug: no-jsdoc-please
title: JSDoc Doesn't Quite do the Trick for Me
aliases: [/computers/programming/javascript/no_jsdoc_please.html]
tags: [JavaScript, JSDoc, JavaDoc, Pod]
type: post
---

<p>After my <a href="/computers/programming/javascript/documentation_standard.html" title="I ask, &#x201c;Is there a JavaScript Library Documentation Standard?&#x201d;">request for JavaScript documentation standards</a>, I investigated the one I found myself: <a href="http://jsdoc.sourceforge.net/" title="Learn about JSDoc (written in Perl!) on the project home page">JSDoc</a>. I went ahead and used its syntax to document a JavaScript class I'd written, and it seemed to work pretty well. Initially, my main complaint was that their was no easy way to include arbitrary documentation. Everything has to be associated with a constructor, attribute, or method. Bleh.</p>

<p>But then I started documenting two purely functional JavaScript files I'd written. These just create functions in the Global scope for general use. And here's where JSDoc started to really become a PITA. First, functions with the same names in the two files were declared to be pre-declared! They two files are part of the same project, but users will generally use one or the other, not both. But JSDoc has taken it upon itself to refuse to document functions that are in two different files in the same project. Surely that's the JavaScript interpreter's responsibility!</p>

<p>The next issue I ran into (after I commented out the code in <em>JSDoc.pm</em> that refused to document functions with the same names) was that it didn't recognize one of the files as having documentation, because there was no constructor. Well duh! A purely functional implementation doesn't <em>have</em> a constructor! It seems that Java's bias for OO-only implementations has unduly influenced JSDoc, even though JavaScript applications often define no classes at all!</p>

<p>The clincher in my decision to ditch JSDoc, however, came when I realized that, for most projects, I won't want the documentation in the same file as the code. While I generally prefer that they be in the same file, I will often have 4-10 times more documentation than actual code, and the bandwidth overhead seems unnecessary. JavaDoc and JSDoc of course require that any documentation be in the same files, since that's where they parse method signatures and such.</p>

<p>So I think I'll follow Chris Dolan's advice from my <a href="/computers/programming/javascript/documentation_standard.html" title="Is there a JavaScript Library Documentation Standard?">original post</a> and fall back on Good 'ole <a href="http://search.cpan.org/dist/perl/pod/perlpod.pod" title="Read the POD documentation on CPAN">POD</a>. POD allows me to write as much or as little documentation as I like, with methods and functions documented in an order that makes sense to me, with headings even! I can write long descriptions, synopses, and even documentation completely unrelated to specifics of the interface. And all in a separate file, even!</p>

<p>This will do until someone formalizes a standard for JavaScript. Maybe it'll be <a href="http://kwiki.org/?KwiD" title="KWID is a proposed replacement format for Perl's POD format; read more about it here.">KwiD</a>?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/javascript/no_jsdoc_please.html">old layout</a>.</small></p>


