Just a Theory
=============

This repository contains the source code for [Just a Theory], a periodically
irregular technology and culture blog by David E. Wheeler.

*Just a Theory* is written in [Markdown], built and published with [Hugo], and
hosted on [AWS]. Its set in [Source Sans Pro], with fixed-width type set in
[Source Code Pro]. The icons are by [Font Awesome].

The site eschews JavaScript, and uses no tracking or analytics services.

---

Reference
---------

Some notes for myself to refer to on how to use some of the shortcodes in this
project.

### Figure

The Figure shortcode and partial use the same syntax, to create an image figure
and caption in HTML and plain text. Can also be used as an object for the
`image` key in the front matter of a post, in which case it will be included in
the HTML metadata fore configuring articles previews on social media, as well as
above the body copy of the post. The parameters are:

`link`
:

`src`
:

`class`
:

`title`
:

`alt`
:

`target`
:

`rel`
:

`width`
:

`height`
:

`heading`
:

`caption`
:

`attr`
:

`attrlink`
:

`copyright`
:

`metaonly` : Used only for the `image:` front matter. When set to `true`,
prevents the figure from being rendered above the body of the post. Useful if
the image is used elsewhere in the post, but you still want it to appear in
metadata for previews on social media.

[Just a Theory]: https://justatheory.com/
[Markdown]: http://daringfireball.net/projects/markdown/
[Hugo]: https://gohugo.io
[AWS]: https://aws.amazon.com/
[Source Sans Pro]: https://github.com/adobe-fonts/source-sans-pro
[Source Code Pro]: https://github.com/adobe-fonts/source-code-pro
[Twitter]: https://twitter.com/theory
[Font Awesome]: https://fontawesome.com
