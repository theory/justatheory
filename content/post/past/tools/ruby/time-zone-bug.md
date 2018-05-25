--- 
date: 2007-08-29T19:06:14Z
slug: ruby-time-zone-bug
title: Ruby Time Object Time Zone Bug
aliases: [/computers/programming/ruby/time_zone_bug.html]
tags: [Ruby, Time Zones]
type: post
---

[This is disappointing].

To summarize, Ruby's `Time` class has a bug in its `zone` method. The example is
simple:

``` ruby
tz = ENV['TZ']
ENV['TZ'] = 'Africa/Luanda'
t = Time.now
puts t.zone
ENV['TZ'] = 'Australia/Lord_Howe'
puts t.zone
```

This outputs:

    WAT
    WAT

So far so good. But look what happens when I add a single line to the program,
`foo = t.to_s`:

``` ruby
tz = ENV['TZ']
ENV['TZ'] = 'Africa/Luanda'
t = Time.now
puts t.zone
ENV['TZ'] = 'Australia/Lord_Howe'
foo = t.to_s
puts t.zone
```

The result changes:

    WAT
    LHST

This is clearly wrong. Changing the `$TZ` environment variable and stringifying
the object should not change the underlying value of any of the object's
attributes. The `Time` object should remember the value of the time zone when it
is initialized, and should never change.

Unfortunately, The Ruby core developers (or at least the owner of the bug
report) feel that, since `Time` relies on the system C API, and since time zones
are a PITA, it's not worth it to change this behavior. The downside, however, is
that you cannot rely on `Time` zones to ever be correct unless you're very, very
careful.

Personally, in my subclass of `Time`, I took care of stashing the time zone at
object instantiation as a workaround for this bug. It seemed reasonable to me,
and I was just surprised that the idea was rejected by the Ruby developers.

What do you think?

  [This is disappointing]: http://rubyforge.org/tracker/?func=detail&atid=1698&aid=6368&group_id=426
    "[ ruby-Bugs-6368 ] Time Changes Zones"
