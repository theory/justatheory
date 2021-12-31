--- 
date: 2005-04-29T19:38:19Z
slug: js-ie-gotchas
title: Quirks of IE's JavaScript Implementation
aliases: [/computers/programming/javascript/ie_gotchas.html]
tags: [JavaScript, Internet Explorer, Gotchas, JScript, Firefox, Line Endings, Oxford Comma]
type: post
---

Just a few notes about the quirks of IE's JavaScript implementation that I had
to figure out and work around to get [TestSimple] working in IE.:

-   IE doesn't like serial commas. In other words, If I create an object like
    this:

        var obj = {
            foo: "yow",
            bar: "bat",
        };

    IE will complain. It seems it doesn't like that last comma, but it doesn't
    give you a decent diagnostic message to help you figure out that that's what
    it doesn't like. Fortunately, I didn't have to figure this one out;
    [Marshall] did And now I know to expect that IE thinks that its JavaScript
    should parse like SQL. Whatever!

-   You can't truncate an array using a single argument to `splice()`. In
    Firefox, `ary.splice(0)` will truncate the array, but in IE, you must
    provide the second argument, like this: `ary.splice(0, ary.length)`—or else
    it won't actually truncate the array.

-   Many IE JavaScript functions don't seem to actually inherit from the
    Function class! I discovered this when I tried to call
    [`document.write.apply()`] and it failed. Not only does the `apply()` method
    not exist, but I can't even add it! I came up with a decent workaround for
    this problem in TestBuilder, but I still don't have a general solution to
    the problem. I did find [a page] that might have a general solution, but it
    sure is ugly.

-   IE automatically converts line endings in to the platform specific
    alternatives whenever you assign a JavaScript string to a text element. When
    Marshall showed me output that wasn't properly adding “\#” after all line
    endings, this was my immediate suspicion, and a quick Googling [confirmed
    the issue]. So I had to add regular expressions to look for all variations
    on the line endings.

I'm sure I'll notice other issues as I work more with JavaScript, but feel free
to chime in here with any gotchas you've noticed, and then I won't have to work
so hard to figure them out on my own in the future (and neither will you)!

  [TestSimple]: {{% ref "/post/past/js/test-simple-0.03.md" %}}
    "TestSimple 0.03 Released"
  [Marshall]: http://www.spastically.com/ "Spastically"
  [`document.write.apply()`]: {{% ref "/post/past/js/js-apply-on-write" %}}
    "How do I Add apply() to IE JavaScript Functions?"
  [a page]: http://www.technicalpursuit.com/documents_codingstds.html
    "TIBET™ Coding Standards & Sample Code"
  [confirmed the issue]: http://simon.incutio.com/archive/2004/02/17/lineEndings
    "Automatic line ending conversions in IE"
