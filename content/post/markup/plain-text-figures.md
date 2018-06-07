---
title: "Plain Text Figures"
date: 2018-06-06T23:23:26Z
lastMod: 2018-06-06T23:23:26Z
description: How I went about formatting embedded figures in the plain text output for *Just a Theory.*
tags: [Markup, Just a Theory, Markdown, Plain Text, Image, Daring Fireball, Figure]
type: post
draft: true
---

A couple weeks ago, I implemented [JSON Feed] for *Just a Theory* (subscribe
[here]). A nice feature of the format is that, in addition to the expected
`content_html` field, one can also include plain text, in the `content_text`
field. It reminded me of the [Daring Fireball] plain text feature: Just append
`.text` to any post to see its [Markdown] representation, [like this]. I'm a
sucker for plain text, so decided to follow suit. So now you can read my recent
[wedding anniversary post] in HTML or plain text simply by [appending
`copy.text`] to the URL (or via the JSON Feed).

Markdowners will notice something off about the formatting: the embedded image
looks nothing like Markdown. Here it is:

<pre><code>
{{&#37; figure
  src     = "dance.jpg"
  title   = "dance.jpg"
  alt     = "First Dance"
  caption = "First dance, 28 May 1995."
%}}
</code></pre>

This format defines an HTML [figure] in the [Hugo] [figure shortcode] format.
It's serviceable for writing posts, but not beautiful. In Markdown, it would
look like this:

``` markdown
![First Dance](dance.jpg "First Dance")
```

Which, sadly, doesn't allow for a caption. Worse, it's not great to read: it's
too similar to the text [link format], and doesn't look much like an image, let
alone a figure. Even Markdown creator [John Gruber] doesn't seem to use the
syntax much, preferring to use the HTML [`<img>`] element, as in [this example].
But that's not super legible, either; it hardly differs from the shortcode
format. I'd prefer a nicer syntax for embedded images and figures, but alas,
Markdown hasn't one.

Fortunately, the `copy.text` output needn't be valid Markdown. It's a plain text
output intended for reading, not for parsing into HTML. This frees me to make
figures and images appear however I like.

Framed
------

Still, I appreciate the philosophy behind Markdown, which is best summarized by
this bit from the [docs][Markdown]:

> The overriding design goal for Markdown's formatting syntax is to make it as
> readable as possible. The idea is that a Markdown-formatted document should
> be publishable as-is, as plain text, without looking like it’s been marked up
> with tags or formatting instructions.

So how do you make an embedded image look like an image without any obvious
tags? How about we frame it?

```
        {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
        {                                                          }
        {                      [First Dance]                       }
        {  https://justatheory.com/2018/05/twenty-three/dance.jpg  }
        {                                                          }
        {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
        {  First dance, 28 May 1995.                               }
        {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
```

Think of the braces and tildes like a gilded frame. In the top section, we have
the bracketed alt text as a kind of card, followed by the image URL. Below the
image area, separated by another line of tildes, we have the caption. So it kind
of looks like an image in a frame, right? If you want to include a link, just
add it below the image URL. Here's an example adapted from [this old post]:

```
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
  {                                                                      }
  {                      [*Vogue* on the new iPad]                       }
  {   https://farm8.staticflickr.com/7198/7007813933_bd7e86947c_z.jpg    }
  {     (https://www.flickr.com/photos/theory/7007813933/sizes/l/)       }
  {                                                                      }
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
  {  Image content from *Vogue* on the new iPad. Not shown: the second   }
  {  that it's blurry while the image engine finishes loading and        }
  {  displaying the image.                                               }
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
```

The link appears in parentheses (just like in the text [link format]). And
Markdown formatting can be preserved in the alt text and caption, too. Want to
include multiple images in the figure? Just add them, as long as the caption, if
there is one, appears in the last "box" in the "frame":

```
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
  {                                                                      }
  {                [*The New Yorker* on the 1st gen iPad]                }
  {   https://farm8.staticflickr.com/7059/6861697774_a7ac0d9356_z.jpg    }
  {      (https://www.flickr.com/photos/theory/6861697774/sizes/o/)      }
  {                                                                      }
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
  {                                                                      }
  {      [*The New Yorker* on the 3rd gen iPad with retina display]      }
  {   https://farm8.staticflickr.com/7110/7007813821_6293e374eb_z.jpg    }
  {      (https://www.flickr.com/photos/theory/7007813821/sizes/o/)      }
  {                                                                      }
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
  {  Text content from *The New Yorker* on the first generation iPad     }
  {  (top) and the third generation iPad with retina display (bottom).   }
  {  Looks great because it's text.                                      }
  {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
```

You can tell I like to center the images, though not the caption. Maybe you
don't need a caption or much else. It could be quite minimal: just an image and
alt text:

        {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
        {                      [First Dance]                       }
        {  https://justatheory.com/2018/05/twenty-three/dance.jpg  }
        {~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

Here I've eschewed the blank lines; the dont' feel necessary without the
caption.

Of course, if we wanted, this format could also be parsed reasonably well. But
that's not really the goal. The point is legible figures that stand out from the
text. I think this design does the trick, but we can take it a step further.
Because everything is framed in braces, we might decide to put whatever we want
in there. Like, I dunno, replace the alt text with an ASCII art[^figure-ascii]
version of the image generated by an [conversion interface]? Here's my wedding
photo again:

```
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{                                                                                    }
{  NNNmmdsyyyyyyysssssdhyssooo+++++++++++++ooymNNNNyo+/::::-----------------------:  }
{  NNmNmdssyyyyyssssssdhyssooo++++///++++++ooymNmmmyo+/:::--------...-------------:  }
{  mmddddsyyyyyyssssssdhyssoo++++/////++++osydmmmmNyo+/::--------.....-------------  }
{  Nmddmmsyyyyyyssssssdhysooo+++///////++osso+oymNNyo+/::--------.......-----------  }
{  mmmmmmyyyyyyysssssshhysooo+++//////+ys+//:///sdmho+/::-------..........---------  }
{  mmmmmmyyyyyyssssosshhysooo+++////+ydmy/:/:/+ossydo+/::------...........---------  }
{  mmmmmmyyyyyysssoosshhysosshdy+/+odmNNmdyddmmNNmdmms+::------............--------  }
{  mmmmmmyyyyyyssooosshdhyso:/ymhhdmNNNNNmyhNNNNNNNNNmmo:------.............-------  }
{  mdddmmhyyyysssooossdmdmho.-hmmNNNNNNNmdyhmNNNNNNNNNmh+/+/--..............-------  }
{  mmmmddhyyyysssoooymmNmNmo--yNNmNmmmmmhhyhdhydNNNNmmmdysshy:..............-------  }
{  mmmddmhyyyssssoosdNNNNNmssydmNddhssossyyhs::+ssyhmmh+///ohh-..............------  }
{  Nmmmmmdyyyssssoohhdmddhs:-:hdhyhdso+++///--::/:::+o/://oosy:-.............------  }
{  NNNmmmdyyyssssosdhhyyh+//oohdmmmh///+/::::::---:++/://+hddmdho:...........------  }
{  NNNmmmdyyyssssosmmdmdy+.-/mmdmho+//////::::::/sddddhs/.:sdmmmmy-..........------  }
{  NNmmmmdhyyssssooydmmd+/+sydNmmh+/+yddyo/://oydmmmmmmdy:..:ymds:............-----  }
{  mmmmmmdhyysssoooo+oo+ohdmmmmmddhhsyddddysyddddmmmdddho-..`./h/.............-----  }
{  mmNNNNmhyysssoooo:-/.-ymmmmmmmmmmmNmdddmmmdmdddhhhhs-```````/h-............-----  }
{  NNNNNNmhyysssooymddmddmmmdddddmdmmNmyddmddddhhhhhy:`   ` ```.oo............-----  }
{  NNNNNNmhyyssssymmmNNmmmddhhddddmddddhddmdhddhhhhs-     ` ```.:y............-----  }
{  NNmdmNmhyysssydNmmNmmmddddddddddddhdddhddhhhhhho.      ``````.y............-----  }
{  mmmddmmdhyssssdmmhdmmmddddddhhdhhhhhddhhhdhhho-`       `` ```.s...........------  }
{  ddddhdddhyysssymNmmmmmddddddddhhdhhhhdddddy+.``        `` ```.s............-----  }
{  NNNmmddhyyssssosdddmmmmdddddddhhdddmmmmd+..```        `` ````-s............-----  }
{  NNNmmhysssssssooooymmmmdddmmmdhhdmdmdddd/``.`        ``  ```.-o...........------  }
{  mNNmddhhysssssssssydmmmmdmmmmmddmmddddhdd+``        `` `````.-/...........------  }
{  NNNmmddhhhhyyyyyyyyhmmmmmmmmmmddddddddhhy.``    ` ``` ``````./-...........------  }
{  NNNmmmysssssssssssssdmmmmmmmddddddddddh+.`     ` ```   `````.+...........-------  }
{  mmmNmmhyyyyyhhhhhhhhdmmmmmmddddddddddy:`````` `````   ``````-:...........-------  }
{  mmmmmmmmmmmmmmmmmmddhdmmmddddddddddy/.`````` ````       ```./...........-------:  }
{  mmmmmmmmmmmmmmmmmmhyssdmmmmdddddho:.``````````-```  ``````./:...........-------:  }
{  mmmmmNmmmmmmmmmddddhysydmmddho:-...`````````:oh/```` ````.-:............-------:  }
{  mmmmNNmmmmmmmmmmmmmddyoydo:.``.`````````.:+ydddh-```````-/--............-------:  }
{  NNNNNNNmmmmmmmmmmmmdyyyoo.````...`````:ohdmdddddh+oosyyhdmo--..........--------:  }
{  NNNNNNNNmmmmmmmNmmmmhys+//-```...`.-+yddddmmmddddmmmmmmmmmm+--.......----------:  }
{  NNNNNNNNNmmmmNNNNNmmsyysohdyosyhyyhddddddddmmmmmdmmmmmmmmmmh--.......---------::  }
{  NNNNNNNNNNNNNNNNNNNNyyhhdmmdddmmdddddmddddmmmmmmmmmmmmmmmmmd-----------------:::  }
{  NNNNNNNNNNNNNNNNNNNNmmmmmmmmdddddddmmmmmmmmmmmmmmmmmmmmmmmmy-----------------:::  }
{  NNNNNNNNNNNNNNNNNNNNmmmmmmmmddddddmmmmmmmmmmmmmmmmmmmmmmmmm+-----------------:::  }
{  NNNNNNNNNNNNNNNNmNNNmmmmmmmmmdmdmmmmmmmmmmmmmmmmmmmmmmmmmmh:----------------::::  }
{  NNNNNNNNNNNNNNNNNNNmmmmmmdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmo----------------:::::  }
{  NNNNNNNNNNNNNNNNNNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm/---------------::::::  }
{  NNNNNNNNNNNNNNNNNNNNNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNNmy::::::::--:-:::::::://  }
{  NNNNNNNNNNNNNNNNNNNNNNmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmNmmo///:::::::::::::::////  }
{  NNNNNNNNNNNNNNNNNNNNNNmdddmmmmmmmmmmmmmmmmmmmmmmmmmmmNmmy///////////////////////  }
{  NNNNNNNNNNNNNNNNNNNNNNmdddddddddddddmmmmmmmmmmmmmmmmmNmm/::::::::::::::::::::::/  }
{  NNNNNNNNNNNNNNNNNNNNNNmdddddddddhddddddmmmmmmmmmmmmmmmmy::::::::::--:::::::::///  }
{  NNNNNNNNNNNNNNNNNNNNNNmmdddddddddddddddmmmmmmmmmmmNNNmNyo++++/////////////++++oo  }
{  NNNNNNNNNNNNNNNNNNNNNNmmdddddddddddddddmmmmmmmmmmNNNmmNhyyyyyyssssssssssssssssss  }
{  NNNNNNNNNNNNNNNNNNNNNmmmdddddddddddddddmmmmmmmmmNmNNmmmysssssooooo+++++/////////  }
{  NNNNNNNNNNNNNNNNNNNNNmmmmddddddddddddddmmmmmmmNNNNNmmmd/::::::::::::::://///////  }
{  NNNNNNNNNNNNNNNNNNNNNmmmmdmddddddddddddmmmmmmNNNmNmmmmd::::::::::::::://////////  }
{  NNNNNNNNNNNNNNNNNNNNNmmmmdmmmdddddddddmmmmmmNmmmNmmmmmh::::::::://///////++os+++  }
{  NNNNNNNNNNNNNNNNNNNNNmmmmdmmmmddddddddmmNmNNmmmNmNNmmNh/::::///////////+oo+++++o  }
{  NNNNNNNNNNNNNNNNNNNNmmmmmmmddddddddddmmNmmmmmmmNNNNmmNy////////+oossyyhhhdddmmmN  }
{                                                                                    }
{               https://justatheory.com/2018/05/twenty-three/dance.jpg               }
{                                                                                    }
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
{  First dance, 28 May 1995.                                                         }
{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
```

Silly? Maybe. But I'm having fun with it. I expect to wrangle Hugo into emitting
something like this soon.

  [^figure-ascii]: Surely someone has come up with a way to improve on ASCII art by using [box elements] or something?

  [JSON Feed]: https://jsonfeed.org
  [here]: /feed.json
  [Daring Fireball]: https://daringfireball.net
  [Markdown]: https://daringfireball.net/projects/markdown/
  [like this]: https://daringfireball.net/linked/2018/06/05/goode-federighi-uikit.text
  [wedding anniversary post]: {{% ref "post/personal/twenty-three/index.md" %}}
  [appending `copy.text`]: {{% ref "post/personal/twenty-three/index.md" "text" %}}
  [figure]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/figure
  [Hugo]: https://gohugo.io/
  [figure shortcode]: https://gohugo.io/content-management/shortcodes/#figure
  [link format]: https://daringfireball.net/projects/markdown/syntax#link
  [John Gruber]: https://daringfireball.net/colophon/
  [`<img>`]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img
  [this example]: https://daringfireball.net/2017/05/halide.text
  [this old post]: {{% ref "post/past/apps/conde-nast-ipad.md" %}}
  [conversion interface]: https://www.text-image.com/
  [box elements]: https://en.wikipedia.org/wiki/Box-drawing_character
    "Wikipedia: “Box-drawing character”"
