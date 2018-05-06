--- 
date: 2008-02-11T00:19:55Z
slug: cd-rom-filesystems
title: Mac OS X CD-ROM File Systems WTF?
aliases: [/computers/os/macosx/cd_rom_filesystems.html]
tags: [macOS, CD-ROM, Joliet, ISO9660, HFS+, WTF]
---

<p>Didn't it used to be the case that when you used the Mac OS X Finder to
burn a CD-ROM that you could then mount that CD-ROM on a Windows box? In the
last few months, I'm suddenly finding that this is no longer the case. So now
I have to use <code>hdiutil</code> to convert a <em>.dmg</em> file to the
Joliet and ISO9660 file systems:</p>

<pre>
hdiutil makehybrid -o image.iso -joliet -iso image.dmg
</pre>

<p>And <em>then</em> I could burn a CD readable on Windows. What the fuck? I
burned three CDs that were then useless to me before I finally dug
up <a href="http://www.macosxhints.com/article.php?query=dmg&amp;story=20050819185219196"
title="Mac OS X Hints: “DVD image manipulation via hdiutil”">this hint</a>.
And I had this problem with CDs burned by Tiger, too, last summer, so it's not
just Leopard. It seems to me that Mac OS X should always default to building a
hybrid CD that's then readable by Windows, Linux, and everything else. Why
doesn't it?</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/os/macosx/cd_rom_filesystems.html">old layout</a>.</small></p>


