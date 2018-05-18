--- 
date: 2005-03-28T23:16:25Z
slug: js-documentation-standard
title: Is there a JavaScript Library Documentation Standard?
aliases: [/computers/programming/javascript/documentation_standard.html]
tags: [JavaScript, documentation, Pod, Java, JavaDoc]
type: post
---

<p>Is there a JavaScript documentation standard? I've been working on a test framework for JavaScript and I'd like to integrate documentation so that others can use it.</p>

<p>If there isn't a documentation standard, I can see three possible options that I'd like to suggest:</p>

<dl>
  <dt>Use XHTML.</dt>
  <dd><p>Since JavaScript is mainly used for XHTML, it makes some sense to
  just use XHTML for its documentation. The downside to this is that there is
  currently no way to parse out the documentation, AFAIK. The format for
  putting the docs into comments would have to be standardized. I don't really
  see that happening.</p></dd>

  <dt>Use POD.</dt>
  <dd><p>JavaScript is a dynamic language; it'd make some sense to use the
  documentation format of an existing dynamic language. And POD is a proven
  format. The downside, of course, is that there is not a parser for pulling
  POD out of a <em>.js</em> file. Same problem as for XHTML,
  essentially.</p></dd>

  <dt>Use JavaDoc</dt>
  <dd>
    <p>Since the syntax of JavaScript is roughly based on JavaScript, and
    JavaScript supports the same comment syntax, one could simply use the
    JavaDoc format. The <em>javadoc</em> application probably couldn't parse it
    out too well, since it parses the Java code (or byte code?) to
    automatically document method names, signatures, etc.</p>

    <p>But a quick Googling yields <a href="http://jsdoc.sourceforge.net/"
    title="Learn about JSDoc (written in Perl!) on the project home
    page">JSDoc</a> as a possible solution. The only downside to the
    JavaDoc/JSDoc solution is that it tends to allow authors to be too lazy.
    Since the application automatically documents the existence of functions
    and their signatures, often little else is documented. But that's mainly a
    personal issue; I don't have to be so lazy in my own documentation! I
    think I'll give that a shot.</p>
  </dd>
</dl>

<p>Meanwhile, if anyone knows of something better/more widely used, let me know!</p>
