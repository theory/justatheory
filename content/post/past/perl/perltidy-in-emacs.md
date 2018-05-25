--- 
date: 2005-12-22T20:38:32Z
slug: perltidy-in-emacs
title: Use Perltidy in Emacs
aliases: [/computers/programming/perl/perltidy_in_emacs.html]
tags: [Perl, Emacs, Perltidy, Elisp]
type: post
---

Here's how I integrated [Perltidy] into Emacs. Based on some [examples] from the
Emacs Wiki, as well as a bit of help on `#emacs`, I came up with this function:

``` EmacsLisp
    (defun perltidy ()
      "Run perltidy on the current region or buffer."
      (interactive)
      (save-excursion
        (unless mark-active (mark-defun))
        (shell-command-on-region (point) (mark) "perltidy -q" nil t)))

    (global-set-key "\C-ct" 'perltidy)
```

With Perltidy installed and this function thrown into your `*\~/.emacs*` file, you
can run `perltidy` on a region by just hitting `C-C t`. If no region is
selected, it'll run `perltidy` on the whole buffer.

  [Perltidy]: http://search.cpan.org/dist/Perl-Tidy "Perltidy on CPAN"
  [examples]: http://www.emacswiki.org/cgi-bin/wiki/CPerlMode
    "CPerlMode on Emacs Wiki, including Perltidy examples"
