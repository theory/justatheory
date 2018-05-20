--- 
date: 2005-08-22T21:55:26Z
slug: js-ie-dom-help
title: IE DOM Help
aliases: [/computers/programming/javascript/ie_dom_help.html]
tags: [JavaScript, Internet Explorer, DOM]
type: post
---

I got Test.Harness.Browser working with IE 6 SP 2 today, but decided to spend a
bit of time trying to get it working with the DOM script inclusion approach
instead of the XMLHttpRequest approach. The code that causes the problem is this
(`pre` is a pre element generated with the DOM API):

    el = doc.createElement("script");
    el.type = "text/javascript";
    // XXX IE chokes on this line.
    el.appendChild(doc.createTextNode("window.onload(null, Test)"));
    pre.appendChild(el);

This works great in Firefox, but IE 6 doesn't like the call to `appendChild()`.
It says, “Unexpected call to method or property access.” So I tried to replace
that line with:

    el.innerHTML = "window.onload(null, Test);";

Firefox is still happy, but now IE 6 says, “Unknown runtime error.” If I try to
just append a script tag to `pre.innerHTML`, I get no error, but the code
doesn't seem to execute, either. In fact, pre.innerHTML appears to be empty!

Anyone have any idea how I can dynamically write to a script element that I've
created via the DOM?
