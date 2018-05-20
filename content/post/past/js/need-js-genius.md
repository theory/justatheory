--- 
date: 2005-08-09T04:31:40Z
slug: need-js-genius
title: Plea for Help from JavaScript Geniuses
aliases: [/computers/programming/javascript/need_js_genius.html]
tags: [JavaScript, DOM]
type: post
---

I've been working for some time to get pure *.js* test files working with
[`Test.Simple`]. In principal, it's simple: The Browser harness simply
constructs a hidden `iframe`, and if the test script ends in *.js*, it uses
`document.write()` for that `iframe` to write out a new HTML document that
includes the test script via a `script` tag. It can also load other scripts
specified by the user in the *index.html* file that runs the harness.

I got it working, and then converted all of `Test.Simple`'s own tests over to
*.js* files, at which point it got all weird. The tests were dying after the
third test file was loaded and run. After weeks of on and off debugging, I've
reduced the problem enough to find the following:

-   I'm using [JSAN] to load dependencies in the test scripts themselves. The
    browser harness loads it by writing a `script` tag into the `head` section
    of the `iframe`.
-   The tests always use `JSAN` to load `Test.Builder`, either directly or by
    loading a library that depends on it (like `Test.More`.
-   `Test.Builder` detects when it's being run in a browser and sets an `onload`
    event handler to end the execution of tests.
-   For the first two test files, `Test.Builder` loads and runs, and sets up the
    `onload` event handler, and it properly executes when the test finish.
-   But in the third test, the `onload` event handler seems to run *before*
    `Test.Builder` has finished execution or even loading! As such, it cannot
    get access to the `Test.Builder` class to finish the tests, and throws an
    exception: “Error: this.Test has no properties”, where `this` is the
    `iframe` window object.

The only thing I can guess is that it's retaining the `onload` event handler for
the previous test file, even if I put `delete buffer.onload` before writing out
the HTML to load the test file! (Note that “`buffer`” is the name of the
variable that is holding the `contentWindow` attribute of the `iframe` object.)
You can observe this behavior for yourself by [running the tests] now. They
don't work in Safari at all (I code to Firefox and then port to the other
browsers), but Firefox demonstrates the issue. I have `alert()`s that run just
before `Test.Builder` sets up the `onload` event handler, and then inside the
event handler, either when its run or when it catches an exception (but before
it rethrows it). The order of execution, you'll note, is as follows:

-   “async.js..........” output to browser
-   `alert("Setup: buffer")` during the execution of `Test.Builder` for
    *async.js*, where "buffer" is the name of the `iframe` element.
-   `alert("Onload: buffer")` for *async.js*, during the execution of the
    `onload` event
-   “bad\_plan.js.......” output to browser
-   `alert("Setup: buffer")` during the execution of `Test.Builder` for
    *bad\_plan.js*
-   `alert("Onload: buffer")` for *bad\_plan.js*, during the execution of the
    `onload` event
-   “buffer.js........” output to browser
-   `alert("Catch: buffer")` output from catching the exception in the `onload`
    handler for *buffer.js*, which, of course, `Test.builder` hasn't set up yet!

If I don't rethrow the exception, it then runs the code in `Test.Builder` that
sets up the `onload` handler. In other words, the `onload` handler runs *before*
it has been created. Huh?

The nearest to a workaround that I've found is to delete the `iframe` element
after each test and create a new one. The errors are still thrown, but all tests
seem to pass anyway. It doesn't seem to like the old-style *.html* test files,
though; it hangs on them without throwing any error at all. Grrrr.

So, are you a JavaScript genius? Do you know how the browser, DOM, and frames
work and interact better than you know your own family? If so, please, *please*
give me a hint as to what I can do to fix this problem so that I can get a new
version of `Test.Simple` out ASAP. Thanks!

**Update:** I forgot to mention that the in-progress source code for
`Test.Simple` with support for *.js* test files can be [downloaded here], so
that you can play with it on your own system. Thanks!

  [`Test.Simple`]: http://www.openjsan.org/doc/t/th/theory/Test/Simple/
    "Get Test.Simple on JSAN"
  [JSAN]: http://www.openjsan.org/doc/c/cw/cwest/JSAN/ "JSAN on JSAN"
  [running the tests]: /code/Test.Simple-0.11_1/tests/index.html
    "Run the broken test suite now!"
  [downloaded here]: /code/Test.Simple-0.11_1.tar.gz
    "Download Test.Simple 0.11_1"
