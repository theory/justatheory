---
date: 2002-09-12T20:01:10Z
description: How to fix them in version 0.05.
lastMod: 2022-10-02T22:39:29Z
slug: chimera-fonts
tags:
  - use Perl
  - Perl
  - Chimera
title: Chimera Fonts
---

Chimera is finally working for me on Jaguar with the new 0.05 release. It's
really nice to use, compared to Mozilla or most other browsers. However, the
font sizes were all whacked out on my TiBook. Using Bricolage, a lot of the type
was so small that it was almost unreadable. This seemed strange to me, since
Bricolage detects Chimera as Mozilla (Gecko), and sets the font sizes
appropriately.

The solution turns out to be simple, and I pass it on here for the benefit of my
fellow Mac OS X junkies who want to use Chimera. You simply have to edit your
`prefs.js` file, which you'll find in `~/Library/Application
Support/Chimera/Profiles/default/foo.slt/`, where `foo.slt` is a salted
directory name. So just open up `prefs.js` and add this line:

``` js
user_pref("browser.display.screen_resolution", 96);
```

After quitting and restarting Chimera, the font sizes will once again render
just as they do in Mozilla.

*Originally published [on use Perl;]*

  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/7710/
    "use.perl.org journal of Theory: “Chimera Fonts”"
