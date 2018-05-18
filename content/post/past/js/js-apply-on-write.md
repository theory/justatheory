--- 
date: 2005-04-28T17:38:02Z
slug: js-apply-on-write
title: How do I Add apply() to IE JavaScript Functions
aliases: [/computers/programming/javascript/apply_on_write.html]
tags: [JavaScript, Internet Explorer, Firefox]
type: post
---

<p>This is really bugging me. I've added a feature to my TestSimple JavaScript library where one can specify a function to which to send test output. It executes the function, along with an object, if necessary, by calling its <code>apply()</code> method. If you don't specify a function for output, it uses <code>document.write</code> by default:</p>

<pre>
if (!fn) {
    fn = document.write;
    obj = document;
}
var output = function () { fn.apply(obj, arguments) };
</pre>

<p>This works great in Firefox, as I can then just call <code>fn.apply(this, arguments)</code> and the arguments are properly passed on through to the function.</p>

<p>However, Internet Explorer doesn't seem to have an <code>apply()</code> method on its <code>write()</code> function. If I execute <code>document.write.apply(document [&#x0027;foo&#x0027;])</code> in Firefox, it outputs <q>foo</q> to the browser. In Internet Explorer for Windows, however, it yields an error: <q>Object doesn't support this property or method.</q> Wha??</p>

<p>I thought I could get around it by just adding the <code>apply()</code> method to <code>document.write</code>, but that doesn't work, either. This code:</p>

<pre>
document.write.apply = Function.prototype.apply;
document.write.apply(document, [&#x0027;foo&#x0027;]);
</pre>

<p>Yields the same error. Curiously, so does this code:</p>

<pre>
document.write.apply2 = Function.prototype.apply;
document.write.apply2(document, [&#x0027;foo&#x0027;]);
</pre>

<p>So it seems that assigning a function to <code>document.write</code> is a no-op in IE. WTF?</p>

<p>So does anyone know a workaround for this bug? I found <a href="http://www.crockford.com/javascript/remedial.html" title="Remedial JavaScript">a page</a> that says, <q>Beware that some native functions in IE were made to look like objects instead of functions.</q> This might explain why <code>apply()</code> doesn't exist for the <code>document.write</code> object, but not why I can't add it.</p>

<p>Help!</p>
