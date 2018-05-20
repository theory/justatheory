--- 
date: 2008-02-11T00:19:55Z
slug: cd-rom-filesystems
title: Mac OS X CD-ROM File Systems WTF?
aliases: [/computers/os/macosx/cd_rom_filesystems.html]
tags: [macOS, CD-ROM, Joliet, ISO9660, HFS+, WTF]
type: post
---

Didn't it used to be the case that when you used the Mac OS X Finder to burn a
CD-ROM that you could then mount that CD-ROM on a Windows box? In the last few
months, I'm suddenly finding that this is no longer the case. So now I have to
use `hdiutil` to convert a *.dmg* file to the Joliet and ISO9660 file systems:

    hdiutil makehybrid -o image.iso -joliet -iso image.dmg

And *then* I could burn a CD readable on Windows. What the fuck? I burned three
CDs that were then useless to me before I finally dug up [this hint]. And I had
this problem with CDs burned by Tiger, too, last summer, so it's not just
Leopard. It seems to me that Mac OS X should always default to building a hybrid
CD that's then readable by Windows, Linux, and everything else. Why doesn't it?

  [this hint]: http://www.macosxhints.com/article.php?query=dmg&story=20050819185219196
    "Mac OS X Hints: “DVD image manipulation via hdiutil”"
