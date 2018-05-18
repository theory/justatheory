--- 
date: 2005-12-22T20:38:32Z
slug: perltidy-in-emacs
title: Use Perltidy in Emacs
aliases: [/computers/programming/perl/perltidy_in_emacs.html]
tags: [Perl, Emacs, Perltidy, elisp]
type: post
---

<p>Here's how I integrated <a href="http://search.cpan.org/dist/Perl-Tidy" title="Perltidy on CPAN">Perltidy</a> into Emacs. Based on some <a href="http://www.emacswiki.org/cgi-bin/wiki/CPerlMode" title="CPerlMode on Emacs Wiki, including Perltidy examples">examples</a> from the Emacs Wiki, as well as a bit of help on <code>#emacs</code>, I came up with this function:</p>

<pre>
(defun perltidy ()
  &quot;Run perltidy on the current region or buffer.&quot;
  (interactive)
  (save-excursion
    (unless mark-active (mark-defun))
    (shell-command-on-region (point) (mark) &quot;perltidy -q&quot; nil t)))

(global-set-key &quot;\C-ct&quot; &#x0027;perltidy)
</pre>

<p>With Perltidy installed and this function thrown into your <em>~/.emacs</em> file, you can run <code>perltidy</code> on a region by just hitting <code>C-C t</code>. If no region is selected, it'll run <code>perltidy</code> on the whole buffer.</p>
