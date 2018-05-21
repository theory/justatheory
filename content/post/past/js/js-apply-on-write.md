--- 
date: 2005-04-28T17:38:02Z
slug: js-apply-on-write
title: How do I Add apply() to IE JavaScript Functions
aliases: [/computers/programming/javascript/apply_on_write.html]
tags: [JavaScript, Internet Explorer, Firefox]
type: post
---

This is really bugging me. I've added a feature to my TestSimple JavaScript
library where one can specify a function to which to send test output. It
executes the function, along with an object, if necessary, by calling its
`apply()` method. If you don't specify a function for output, it uses
`document.write` by default:

``` js
if (!fn) {
    fn = document.write;
    obj = document;
}
var output = function () { fn.apply(obj, arguments) };
```

This works great in Firefox, as I can then just call `fn.apply(this, arguments)`
and the arguments are properly passed on through to the function.

However, Internet Explorer doesn't seem to have an `apply()` method on its
`write()` function. If I execute `document.write.apply(document ['foo'])` in
Firefox, it outputs “foo” to the browser. In Internet Explorer for Windows,
however, it yields an error: “Object doesn't support this property or method.”
Wha??

I thought I could get around it by just adding the `apply()` method to
`document.write`, but that doesn't work, either. This code:

``` js
document.write.apply = Function.prototype.apply;
document.write.apply(document, ['foo']);
```

Yields the same error. Curiously, so does this code:

``` js
document.write.apply2 = Function.prototype.apply;
document.write.apply2(document, ['foo']);
```

So it seems that assigning a function to `document.write` is a no-op in IE. WTF?

So does anyone know a workaround for this bug? I found [a page] that says,
“Beware that some native functions in IE were made to look like objects instead
of functions.” This might explain why `apply()` doesn't exist for the
`document.write` object, but not why I can't add it.

Help!

  [a page]: http://www.crockford.com/javascript/remedial.html "Remedial JavaScript"
