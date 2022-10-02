---
date: 2003-09-08T21:50:38Z
description: Modularization is good.
lastMod: 2022-10-02T22:39:29Z
slug: params-callbackrequest-1.10
tags:
  - use Perl
  - Perl
  - Params::CallbackRequest
title: Params::CallbackRequest 1.10
---

I have abstracted out all of the callback processing and execution code from my
MasonX::ApacheHandler::WithCallbacks module to a new module,
Params::CallbackRequest. This enables me to keep the callback code independent
of the Mason architecture, and thus work it in to other templating systems. Look
for the addition of callbacks to Template Toolkit next! This change necessitated
some breakage of backwards compatibility, but nothing that can't be changed with
some simple regex work.

In tandem with the above change, I have also completed my conversion of my Mason
callback subclass from ApacheHandler to Interp. This means that the callbacks
can be used in any Mason context, not just with mod_perl.
MasonX::ApacheHandler::WithCallbacks is hereby deprecated, and will soon be
deleted from CPAN (though you'll still be able to get it from BackPAN). Many
thanks to the Mason development team for accepting my multitude of patches to
make HTML::Mason::Interp more subclassable. A result of this change, however, is
that MasonX::Interp::WithCallbacks requires Mason 1.23 or later.

These modules are making their way to CPAN now, but you can get them here if
you're impatient:

*   [Params-CallbackRequest-1.10.tar.gz]
*   [MasonX-Interp-WithCallbacks-1.10.tar.gz]

Here's a complete list of the changes to get you started: 
  

*   Code moved over from MasonX::ApacheHandler::WithCallbacks, which is
    deprecated. Differences from that class are as follows. 
*   Callback handling code from MasonX::ApacheHandler::WithCallbacks has been
    migrated to Params::CallbackRequest. 
*   Code from MasonX::CallbackHandler has been migrated to Params::Callback. 
*   MasonX::CallbackTester has been removed, since it isn't necessary in a
    non-mod_perl environment. 
*   Params::CallbackRequest::Exceptions supplies the exceptions thrown by
    Params::CallbackRequest, since that module is not strictly connected to
    Mason. 
*   Changed the `request_args()` accessor from MasonX::CallbackHandler to
    `params()` in Params::Callback, to reflect the idea that this is a generic
    parameter-triggered callback architecture. 
*   Replaced the `ah()` accessor, since the callback controller isn't 
    a Mason ApacheHandler anymore, with `cb_request()` in Params::Callback. 
*   Added cb_request() accessor to MasonX::Interp::WithCallbacks. 
*   Replaced the `exec_null_cb_values` parameter from
    MasonX::ApacheHandler::WithCallbacks, which had defaulted to true, with
    "ignore_nulls" in Params::CallbackRequest, which defaults to false. 
*   Added Params::CallbackRequest `notes()` interface, which copies all notes to
    the Mason request `notes()` interface before the request executes. 
  
Enjoy! 

--- David

*Originally published [on use Perl;]*

  [ > http://david.wheeler.net/code/Params-CallbackRequest-1.10.tar.gz  >  ]: http://david.wheeler.net/code/Params-CallbackRequest-1.10.tar.gz
  [ > http://david.wheeler.net/code/MasonX-Interp-WithCallbacks-1.10.tar.gz  >  ]: http://david.wheeler.net/code/MasonX-Interp-WithCallbacks-1.10.tar.gz
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/14588/
    "use.perl.org journal of Theory: “Params::CallbackRequest 1.10”"
