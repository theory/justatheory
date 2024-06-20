Just a Theory
=============

This repository contains the source code for [Just a Theory], a periodically
irregular technology and culture blog by David E. Wheeler.

*Just a Theory* is written in [Markdown], built and published with [Hugo], and
hosted on [AWS]. It's set in [Source Sans Pro], with fixed-width type set in
[Source Code Pro]. The icons are by [Font Awesome].

The site eschews JavaScript, and uses no tracking or analytics services.

---

Reference
---------

Some notes for myself to refer to on how to use some of the shortcodes in this
project.

### Link

The [Link shortcode] resolves a link to a static file, such as a tarball, PDF,
patch, or image. It takes a single argument: the file or URL to link to. It uses
the following heuristics to determine how to render the link:

*   If the link starts with `/`, it is assumed to be an absolute link on the
    site. It will be rendered with the site base URL prefixed to it.
*   If the link contains `://` or starts with `//`, it's assumed to be a full
    URL and is simply output as such. This option isn't generally used directly,
    but implicitly by the figure shortcode below.
*   Otherwise the link is assumed to be a file name in the same directory as the
    current page. It will be prefixed with the full URL of the current page.

Examples:

``` go
{{% link "/downloads/TestBuilder-0.01.tar.gz" %}}
{{% link "learning_plpgsql.pdf" %}}
```

Note that links to assets in other page bundles are not supported for [various
reasons]. In other words, this will not work and cannot (easily) be made to
work:

``` go
{{% link "/post/postgres/extension-ecosystem-summit/summit.jpeg" %}}
```

Instead move such shared images to the [`static` directory](./static/) with
and use an absolute path, or just use the absolute path to the other post:

``` go
{{% link "/2024/02/extension-ecosystem-summit/summit.jpeg" %}}
```

Or use a `ref` to the original package (in which case `link` isn't needed at all):

``` go
{{% ref "/post/postgres/extension-ecosystem-summit" %}}summit.jpeg
```

Although this option is not available in front matter.

### Ref

The [Ref shortcode] comes with Hugo, and links to a document in the current
project. Pass a single argument, the path to the document, as the sole argument.
Use the absolute path starting from a subdirectory of the `content/` directory,
and omit the `.md` or `/index.md` from the file name (unless the file name
contains other `.` characters, in which case the full file name should remain).

An optional second argument specifies an alternate output format.

Examples:

``` go
  [#extensions]: https://postgresteam.slack.com/archives/C056ZA93H1A
    "Postgres Slack/#extensions: Extensions and extension-related accessories"
  [Postgres Slack]: https://pgtreats.info/slack-invite
    "Join the Postgres Slack"
{{% ref "/post/books/project-hail-mary" "text" %}}
{{% ref "/post/past/js/test-simple-0.03.md" %}}
{{% ref "/photo/nyc/harlem-steps" %}}
{{% ref "/" "json" %}}
```

## Param

The [Param shortcode] comes with Hugo and emits data from site parameters ---
basically the stuff under `[params]` in [`config.toml`](config.toml). Examples:

``` md
[my GitHub]: https://github.com/{{% param "github" %}}
[on Mastodon]: {{% param "mastodon.url" %}} "{{% param "mastodon.user" %}}"
```

### Syntax Highlighting

[Syntax Highlighting] comes with Hugo. Use fenced blocks with the [named language],
e.g.,

   ``` go
   func main() {}
   ```

An optional second argument takes  a comma-delimited list of `key=value` option
pairs, e.g.,

    ``` go {linenos=table,hl_lines=[8,"15-17"],linenostart=199}
    // ... code
    ```

The supported options are:

*   `linenos`: configure line numbers. Valid values are `true`, `false`,
    `table`, or `inline`. `false` will turn off line numbers if it’s
    configured to be on in site config. New in v0.60.0: `table` will give
    copy-and-paste friendly code blocks.
*   `hl_lines`: lists a set of line numbers or line number ranges to be
    highlighted.
*   `linenostart=199`: starts the line number count from 199.
*   `anchorlinenos`: Configure anchors on line numbers. Valid values are `true`
    or `false`;
*   `lineanchors`: Configure a prefix for the anchors on line numbers. Will be
    suffixed with `-`, so linking to the line number 1 with the option
    `lineanchors=prefix` adds the anchor `prefix-1 to` the page.

### Figure

The [Figure shortcode] and partial use the same syntax, to create an image figure
and caption in HTML and plain text. For photos type posts, the HTML output image
will also be zoomable to the full width of the browser window by tapping the
image --- unless `link` is set.

Can also be used as an object for the `image` key in the front matter of a post,
in which case it will be included in the HTML metadata fore configuring articles
previews on social media, as well as above the body copy of the post. The
parameters are:

#### `src`

The image source URL. May be a local URL, which will be resolved by the
[Link](#link) shortcode. Required.

#### `link`

A URL to link the image to. May be a local URL, which will be resolved by the
[Link](#link) shortcode. Optional.

#### `class`

A string with the CSS class or classes to use for the figure. Optional. Values
are:

*   frame - Wrap the figure in a dark background frame
*   left - Float the figure to the left of text
*   right - Float the figure to the right of text
*   center - Center the figure
*   clear -  Make the background transparent instead of white

#### `title`

Image title. Not used in plain text output unless `alt` is not set. Markdown
within the value of `caption` will be rendered. Optional.

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

Sets the value for a heading (rendered as `<h4>`) in the caption. Markdown
within the value of `caption` will be rendered. Optional.

#### `caption`

Text for the caption. Markdown within the value of `caption` will be rendered.
Optional.

#### `attr`

Text to use for attribution, for when the photo comes from elsewhere. Markdown
within the value of `caption` will be rendered. Optional.

#### `copyright`

Text to use for a copyright notice. Will be preceded by the copyright symbol.
Markdown within the value of `caption` will be rendered. Optional.

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
  [Link shortcode]: themes/justatheory/layouts/partials/link.html
  [Ref shortcode]: https://gohugo.io/content-management/cross-references/
  [various reasons]: https://discourse.gohugo.io/t/48656/9
  [Figure shortcode]: themes/justatheory/layouts/partials/figure.html
  [Param shortcode]: https://gohugo.io/content-management/shortcodes/#param
  [Syntax Highlighting]: https://gohugo.io/content-management/syntax-highlighting/
  [named language]: https://gohugo.io/content-management/syntax-highlighting/#list-of-chroma-highlighting-languages
  [options]: https://gohugo.io/content-management/syntax-highlighting/#highlight-shortcode
