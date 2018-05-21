--- 
date: 2005-08-17T18:24:37Z
slug: test-simple-0.20
title: Test.Simple 0.20 Released
aliases: [/computers/programming/javascript/test_simple-0.20.html]
tags: [JavaScript, testing, TAP, Test Anything Protocol, Internet Explorer, Safari, Firefox, Opera]
type: post
---

It gives me great pleasure, not to mention a significant amount of pride, to
announce the release of [Test.Simple 0.20]. There are quite a few changes in
this release, including a few that break backwards compatibility—but only you're
writing your own Test.Builder-based test libraries (and I don't think anyone has
done so yet) or if you're subclassing Test.Harness (and there's only one of
those, that I know of).

The biggest change is that Test.Harness.Browser now supports pure *.js* script
files in addition to the original *.html* files. This works best in Firefox, of
course, but with a lot of help from Pawel Chmielowski (“prefiks” on \#jsan), it
also works in Safari, Opera, and IE 6 (though not in XP Service Pack 2; I'll
work on that after I get my new PC in the next few days). The trick with Firefox
(and hopefully other browsers in the future, since it feels lest hackish to me),
is that it uses the DOM to create a new HTML document in a hidden `iframe`, and
that document loads the *.js*. Essentially, it just uses the DOM to mimic the
structure of a typical *.html* test file. For the other browsers, the hidden
`iframe` uses `XMLHttpRequest` to load and `eval` the *.js* test file. [Check it
out] ([verbosely])!

I think that this will greatly enhance the benefits of Test.Simple, as it makes
writing tests *really* simple. All you have to do is create a single *.html*
file that looks something like this:

``` html
<html>
<head>
    <script type="text/javascript" src="./lib/JSAN.js"></script>
</head>
<body>
<script type="text/javascript">
    new JSAN("../lib").use("Test.Harness.Browser");
    new Test.Harness.Browser('./lib/JSAN.js').encoding('utf-8').runTests(
        'foo.js',
        'bar.js'
    );
</script>
</body>
</html>
```

In fact, that's pretty much exactly what Test.Simple's new harness looks like,
now that I've moved all of the old tests into *.js* files (although there is
still a *simpl.html* test file to ensure that *.html* test files still work!).
Here I'm using [JSAN] to dynamically load the libraries I need. I use it to load
Test.Harness.Browser (which then uses it to load Test.Harness), and then I tell
the Test.Harness.Browser object where it is so that it can load it for each
*.js* script. The test script itself can then look something like this:

``` js
new JSAN('../lib').use('Test.Simple');
plan({tests: 3});
ok(1, 'compile');
ok(1);
ok(1, 'foo');
```

And that's it! Just use JSAN to load the appropriate test library or libraries
and go! I know that JSAN is already loaded because Test.Harness.Browser loads it
for me before it loads and runs my *.js* test script. Nice, eh?

Of course, you don't have to use JSAN to run pure *.js* tests, although it can
be convenient. Instead, you can just pass a list of files to the harness to have
it load them for each test:

``` html
<html>
<head>
    <script type="text/javascript" src="./lib/Test/Harness.js"></script>
    <script type="text/javascript" src="./lib/Test/Harness/Browser.js"></script>
</head>
<body>
<script type="text/javascript">
    new Test.Harness.Browser(
        'lib/Test/Builder.js',
        'lib/Test/More.js',
        '../lib/MY/Library.js'
    ).runTests(
        'foo.js',
        'bar.js'
    );
</script>
</body>
</html>
```

This example tells Test.Harness.Browser to load Test.Builder and Test.More, and
then to run the tests in *foo.js* and *bar.js*. No need for JSAN if you don't
want it. The test script is exactly the same as the above, only without the line
with JSAN loading your test library.

Now, as I've said, this is imperfect. It's [surprisingly difficult] to get
browsers to do this properly, and it's likely that it won't work at all in many
browsers. I'm sure that I broke the Directory harness, too. Nevertheless, I'm
pleased that I got as many to work as I did (again, with great thanks to Pawel
Chmielowski for all the great hacks), but at this point, I'll probably only
focus on adding support for Windows XP Service Pack 2. But as you might imagine,
I'd welcome patches from anyone who wants to add support for other browsers.

There are a lot of other changes in this release. Here's the complete list:

-   Fixed verbose test output to be complete in the harness in Safari and IE.
-   Fixed `plan()` so that it doesn't die if the object is passed with an
    unknown attribute. This can happen when JS code has altered
    `Object.prototype` (shame on it!). Reported by Rob Kinyon.
-   Fixed some errors in the POD documentation.
-   Updated JSAN to 0.10.
-   Added documentation for Test.Harness.Director, complements of Gordon
    McCreight.
-   Fixed line endings in Konqueror and Opera and any other browser other than
    MSIE that supports `document.all`. Reported by Rob Kinyon.
-   Added support to Test.Harness.Browser for *.js* test files in addition to
    *.html* test files. Thanks to Pawel Chmielowski for helping me to overcome
    the final obstacles to actually getting this feature to work.
-   Added missing variable declarations. Patch from Pawel Chmielowski.
-   More portable fetching of the `body` element in Test.Builder. Based on patch
    from Pawel Chmielowski.
-   Added an `encoding` attribute to Test.Harness. This is largely to support
    pure JS tests, so that the browser harness can set up the proper encoding
    for the `script` elements it creates.
-   Added support for Opera, with thanks to Pawel Chmielowski.
-   Fixed the output from skipAll in the test harness.
-   Fixed display of summary of failed tests after all tests have been run by
    the browser harness. They are now displayed in a nicely formatted table
    without a `NaN` stuck where it doesn't belong.
-   COMPATIBILITY CHANGE: The browser harness now outputs failure information
    bold-faced and red. This required changing the output argument to the
    `outputResults()` method to an object with two methods, `pass()` and
    `fail()`. Anyone using `Test.Harness.outputResults()` will want to make any
    changes accordingly.
-   COMPATIBILITY CHANGE: new Test.Builder() now always returns a new
    Test.Builder object instead of a singleton. If you want the singleton, call
    `Test.Builder.instance()`. `Test.Builder.create()` has been deprecated and
    will be removed in a future release. This is different from how Perl's
    Test::Builder works, but is more JavaScript-like and sensible, so we felt it
    was best to break things early on rather than later. Suggested by Bob
    Ippolito.
-   Added `beginAsync()` and `endAsync()` functions to Test.More. Suggested by
    Bob Ippolito.

As always, feedback/comments/suggestions/winges welcome. Enjoy!

  [Test.Simple 0.20]: http://www.openjsan.org/doc/t/th/theory/Test/Simple/0.20/index.html
    "Download Test.Simple 0.20 from JSAN"
  [Check it out]: http://www.openjsan.org/src/t/th/theory/Test.Simple-0.20/tests/index.html
    "Run the Test.Simple test harness now!"
  [verbosely]: http://www.openjsan.org/src/t/th/theory/Test.Simple-0.20/tests/index.html?verbose=1
    "Run the Test.Simple test harness verbosely!"
  [JSAN]: http://www.openjsan.org/doc/c/cw/cwest/JSAN/
    "Download JSAN and start using JavaScript Libraries!"
  [surprisingly difficult]: /programming/javascript/need_js_genius.html
    "Plea for Help from JavaScript Geniuses"
