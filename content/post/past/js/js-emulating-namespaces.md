--- 
date: 2005-05-04T18:27:48Z
slug: js-emulating-namespaces
title: Suggestion for Emulating Namespaces in JavaScript
aliases: [/computers/programming/javascript/emulating_namespaces.html]
tags: [JavaScript, namespaces]
type: post
---

I've been giving some thought on how to emulate namespaces in JavaScript (at
least until [they're implemented in the language]), and this is what I've come
up with: use objects for namespaces. This was inspired by a glance at the
[prototype], where I noticed that Sam Stephenson was using objects to group
related things into neat packages.

For example, say that you wanted to create a class for managing music on you
CDs. Normally in JavaScript, you'd create a class named `CDMusic`. This is all
well and fine, but if everyone creates classes with a single name, a [JSAN]
repository would end with an awfully crowded list of classes. It allows for no
effective hierarchical organization of code.

But if you use objects to represent namespaces, you can define a class something
like this, instead (1990s-era example borrowed from Damian Conway's [*Object
Oriented Perl*]):

``` js
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
```

So now, to use this class, you just:

``` js
var music = new CD.Music();
music.name = "Renegades";
music.artist = "Rage Against the Machine";
music.tracks.push("Microphone Fiend");
music.location("basement", 3); // I use an iPod, so it's in storage!
```

Of course, the key part of this example is `var music = new CD.Music();`. Note
how the class is defined as an attribute of the `CD` object. This allows us to
have a namespace, `CD.Music`, that is subsumed under another namespace, namely
`CD`. The nice thing about this is that, in the hypothetical JSAN repository,
the class might be defined the file *Music.js* in the *CD* directory. A `use()`
function as described by [Michael Schwern][JSAN] might then be smart enough to
look for */use/CD/Music.js* when you write `use("CD.Music")`.

I also kind of like how the use of the namespace and prototype allows my class
definition to be indented by the creation of the prototype object. But to make
these types of namespaces work, you must have that first statement:
`if (CD == undefined) var CD = {};`. This allows you to assign to a CD object
whether you have to create it (because your class stand on its own), or because
some other JavaScript class has defined it. This is especially important to
ensure that you don't stomp on someone else's work. Say someone is using two
different JavaScript classes, your `CD.Music` and someone else's `CD.Jukebox`.
The two classes might be completely unrelated to each other, but because they
both define themselves under the `CD` top-level namespace using the
`if (CD == undefined)` statement, they won't stomp on each other.

The only downside to this proposal, in my estimation, is the requirement it
imposes for defining inherited classes. Say you wanted a subclass of `CD.Music`
for classical music. You'd have to do it like this:

``` js
// CD.Music must be loaded already. Create the constructor.
CD.Music.Classical = function () {}

// Inherit from CD.Music.
CD.Music.Classical.prototype = new CD.Music(); // Inheritance.

// Add to the class and/or override as necessary.
CD.Music.Classical.prototype.composer  = null;
CD.Music.Classical.prototype.orchestra = null;
CD.Music.Classical.prototype.conductor = null;
CD.Music.Classical.prototype.soloist   = null;
```

So we don't get the block syntax, but in truth, that's no different from how one
typically handles inheritance in JavaScript. The only difference is the use of
the dot notation. Nevertheless, suggestions for how to use a block syntax would
be warmly received.

So what do you think? Is this something that makes sense to you? Would you do it
to better organize your JavaScript classes and modules (and yes, I am thinking
that you could group functional libraries this way, too, and then implement an
`import()` function to export functions to another “namespace” or the global
object)? Leave your opinions in a comment. Thanks!

  [they're implemented in the language]: http://www.mozilla.org/js/language/js20/core/namespaces.html
    "JavaScript 2.0 Namespaces specification"
  [prototype]: http://prototype.conio.net/
    "prototype: An object-oriented Javascript library"
  [JSAN]: http://use.perl.org/~schwern/journal/24112 "JSAN: A HOWTO Guide"
  [*Object Oriented Perl*]: https://www.amazon.com/exec/obidos/ASIN/1884777791/justatheory-20
    "Buy Object Oriented Perl on Amazon. Go Get it!"
