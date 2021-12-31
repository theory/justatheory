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
and caption in HTML and plain text. For photos type posts, the HTML output image
will also be zoomable to the full width of the browser window by tapping the
image --- unless `link` is set.

Can also be used as an object for the `image` key in the front matter of a post,
in which case it will be included in the HTML metadata fore configuring articles
previews on social media, as well as above the body copy of the post. The
parameters are:

#### `src`

The image source URL. May be a local URL, which will be resolved by the
`link.html` partial. Required.

#### `link`
: A URL to link the image to. Optional.

#### `class`

A string with the CSS class or classes to use for the figure. Optional. Values
are:

*   frame - Wrap the figure in a dark background frame
*   left - Float the figure to the left of text
*   right - Float the figure to the right of text
*   center - Center the figure

#### `title`

Image title. Not used in plain text output unless `alt` is not set. Optional.

#### `alt`

Alt text for the title, generally text describing the image for those who cannot
see it. Optional.

#### `target`

Set the `target` attribute of the link. Only used if `link` is set. Optional.

#### `rel`
Set the `rel` attribute of the link. Only used if `link` is set. Optional.

#### `width`

Set the `width` attribute of the image. Optional.

#### `height`
Set the `height` attribute of the image. Optional.

#### `heading`

Sets the value for a heading (rendered as `<h4>`) in the caption. Optional.

#### `caption`

Text for the caption. Optional.

#### `attr`

Text to use for attribution, for when the photo comes from elsewhere.
Optional.

#### `attrLink`

Link to use for the attribution specified by `attr`. Used only if `attr` is
also set. Optional.

#### `copyright`

Text to use for a copyright notice. Will be preceded by the copyright symbol.

#### `metaOnly`

Used only for the `image:` front matter. When set to `true`, prevents the figure
from being rendered above the body of the post. Useful if the image is used
elsewhere in the post, but you still want it to appear in metadata for previews
on social media.

[Just a Theory]: https://justatheory.com/
[Markdown]: https://daringfireball.net/projects/markdown/
[Hugo]: https://gohugo.io
[AWS]: https://aws.amazon.com/
[Source Sans Pro]: https://github.com/adobe-fonts/source-sans-pro
[Source Code Pro]: https://github.com/adobe-fonts/source-code-pro
[Twitter]: https://twitter.com/theory
[Font Awesome]: https://fontawesome.com
