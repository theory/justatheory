--- 
date: 2005-05-04T18:27:48Z
slug: js-emulating-namespaces
title: Suggestion for Emulating Namespaces in JavaScript
aliases: [/computers/programming/javascript/emulating_namespaces.html]
tags: [JavaScript, namespaces]
---

<p>I've been giving some thought on how to emulate namespaces in JavaScript (at least until <a href="http://www.mozilla.org/js/language/js20/core/namespaces.html" title="JavaScript 2.0 Namespaces specification">they're implemented in the language</a>), and this is what I've come up with: use objects for namespaces. This was inspired by a glance at the <a href="http://prototype.conio.net/" title="prototype: An object-oriented Javascript library">prototype</a>, where I noticed that Sam Stephenson was using objects to group related things into neat packages.</p>

<p>For example, say that you wanted to create a class for managing music on you CDs. Normally in JavaScript, you'd create a class named <code>CDMusic</code>. This is all well and fine, but if everyone creates classes with a single name, a <a href="http://use.perl.org/~schwern/journal/24112" title="JSAN: A HOWTO Guide">JSAN</a> repository would end with an awfully crowded list of classes. It allows for no effective hierarchical organization of code.</p>

<p>But if you use objects to represent namespaces, you can define a class something like this, instead (1990s-era example borrowed from Damian Conway's <a href="http://www.amazon.com/exec/obidos/ASIN/1884777791/justatheory-20" title="Buy Object Oriented Perl on Amazon. Go Get it!"><cite>Object Oriented Perl</cite></a>):</p>

<pre>
if (CD == undefined) var CD = {}; // Make sure the base namespace exists.
CD.Music = function () {};        // Constructor definition.

// Class definition.
CD.Music.prototype = {
    name:      null,
    artist:    null,
    publisher: null,
    isbn:      null,
    tracks:    [],

    location: function (shelf, room) {
        if (room != null) this._room = room;
        if (shelf != null) this._shelf = shelf;
        return [this._room, this._shelf];
    },

    rating: function (rate) {
        if (rate != null) this._rating = rate;
        return this._rating;
    }
};
</pre>

<p>So now, to use this class, you just:</p>

<pre>
var music = new CD.Music();
music.name = &quot;Renegades&quot;;
music.artist = &quot;Rage Against the Machine&quot;;
music.tracks.push(&quot;Microphone Fiend&quot;);
music.location(&quot;basement&quot;, 3); // I use an iPod, so it's in storage!
</pre>

<p>Of course, the key part of this example is <code>var music = new CD.Music();</code>. Note how the class is defined as an attribute of the <code>CD</code> object. This allows us to have a namespace, <code>CD.Music</code>, that is subsumed under another namespace, namely <code>CD</code>. The nice thing about this is that, in the hypothetical JSAN repository, the class might be defined the file <em>Music.js</em> in the <em>CD</em> directory. A <code>use()</code> function as described by <a href="http://use.perl.org/~schwern/journal/24112" title="JSAN: A HOWTO Guide">Michael Schwern</a> might then be smart enough to look for <em>/use/CD/Music.js</em> when you write <code>use(&quot;CD.Music&quot;)</code>.</p>

<p>I also kind of like how the use of the namespace and prototype allows my class definition to be indented by the creation of the prototype object. But to make these types of namespaces work, you must have that first statement: <code>if (CD == undefined) var CD = {};</code>. This allows you to assign to a CD object whether you have to create it (because your class stand on its own), or because some other JavaScript class has defined it. This is especially important to ensure that you don't stomp on someone else's work. Say someone is using two different JavaScript classes, your <code>CD.Music</code> and someone else's <code>CD.Jukebox</code>. The two classes might be completely unrelated to each other, but because they both define themselves under the <code>CD</code> top-level namespace using the <code>if (CD == undefined)</code> statement, they won't stomp on each other.</p>

<p>The only downside to this proposal, in my estimation, is the requirement it imposes for defining inherited classes. Say you wanted a subclass of <code>CD.Music</code> for classical music. You'd have to do it like this:</p>

<pre>
// CD.Music must be loaded already. Create the constructor.
CD.Music.Classical = function () {}

// Inherit from CD.Music.
CD.Music.Classical.prototype = new CD.Music(); // Inheritance.

// Add to the class and/or override as necessary.
CD.Music.Classical.prototype.composer  = null;
CD.Music.Classical.prototype.orchestra = null;
CD.Music.Classical.prototype.conductor = null;
CD.Music.Classical.prototype.soloist   = null;
</pre>

<p>So we don't get the block syntax, but in truth, that's no different from how one typically handles inheritance in JavaScript. The only difference is the use of the dot notation. Nevertheless, suggestions for how to use a block syntax would be warmly received.</p>

<p>So what do you think? Is this something that makes sense to you? Would you do it to better organize your JavaScript classes and modules (and yes, I am thinking that you could group functional libraries this way, too, and then implement an <code>import()</code> function to export functions to another <q>namespace</q> or the global object)? Leave your opinions in a comment. Thanks!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/javascript/emulating_namespaces.html">old layout</a>.</small></p>


