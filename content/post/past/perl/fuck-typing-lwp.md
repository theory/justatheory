--- 
date: 2010-05-27T16:37:15Z
slug: fuck-typing-lwp
title: Fuck Typing LWP
aliases: [/computers/programming/perl/fuck-typing-lwp.html]
tags: [Perl, LWP, Fuck Typing, Composition, Programming]
type: post
---

I'm working on a project that fetches various files from the Internet via LWP. I
wanted to make sure that I was a polite user, such that my app would pay
attention to `Last-Modified/If-Modified-Since` and `ETag/If-None-Match` headers.
And in most contexts I also want to respect the `robots.txt` file on the hosts
to which I'm sending requests. So I was very interested to read [chromatic’s
hack] for this very issue. I happily implemented two classes for my app,
MyApp::UA, which inherits from [LWP::UserAgent::WithCache], and
MyApp::UA::Robot, which inherits from MyApp::UA but changes
LWP::UserAgent::WithCache to inherit from [LWP::UARobot][]:

    @LWP::UserAgent::WithCache::ISA = ('LWP::RobotUA');

So far so good, right? Well, no. What I didn’t think about, stupidly, is that by
changing LWP::UserAgent::WithCache’s base class, I was doing so globally. So now
both MyApp::UA and MyApp::UA::Robot were getting the LWP::RobotUA behavior. Urk.

So my work around is to use a little [fuck typing] to ensure that
MyApp::UA::Robot has the robot behavior but MyApp::UA does not. Here’s what it
looks like (**BEWARE:** black magic ahead!):

``` perl
package MYApp::UA::Robot;

use 5.12.0;
use utf8;
use parent 'MyApp::UA';
use LWP::RobotUA;

do {
    # Import the RobotUA interface. This way we get its behavior without
    # having to change LWP::UserAgent::WithCache's inheritance.
    no strict 'refs';
    while ( my ($k, $v) = each %{'LWP::RobotUA::'} ) {
        *{$k} = *{$v}{CODE} if *{$v}{CODE} && $k ne 'new';
    }
};

sub new {
    my ($class, $app) = (shift, shift);
    # Force RobotUA configuration.
    local @LWP::UserAgent::WithCache::ISA = ('LWP::RobotUA');
    return $class->SUPER::new(
        $app,
        delay => 1, # be very nice -- max one hit per minute.
    );
}
```

The `do` block is where I do the fuck typing. It iterates over all the symbols
in LWP::RobotUA, inserts a reference to all subroutines into the current
package. Except for `new`, which I implement myself. This is so that I can keep
my inheritance from MyApp::UA intact. But in order for it to properly configure
the LWP::RobotUA interface, `new` must temporarily fool Perl into thinking that
LWP::UserAgent::WithCache inherits from LWP::RobotUA.

Pure evil, right? Wait, it gets worse. I've also overridden LWP::RoboUA’s
`host_wait` method, because if it’s the second request to a given host, I don’t
want it to sleep (the first request is for the `robots.txt`, and I see no reason
to sleep after that). So I had to modify the `do` block to skip both `new` and
`host_wait`:

``` perl
    while ( my ($k, $v) = each %{'LWP::RobotUA::'} ) {
        *{$k} = *{$v}{CODE} if *{$v}{CODE} && $k !~ /^(?:new|host_wait)$/;
    }
```

If I “override” any other LWP::RobotUA methods, I'll need to remember to add
them to that regex. Of course, since I'm not actually inheriting from
LWP::RobotUA, in order to dispatch to its `host_wait` method, I can’t use
`SUPER`, but must dispatch directly:

``` perl
sub host_wait {
    my ($self, $netloc) = @_;
    # First visit is for robots.txt, so let it be free.
    return if !$netloc || $self->no_visits($netloc) < 2;
    $self->LWP::RobotUA::host_wait($netloc);
}
```

Ugly, right? Yes, I am an evil bastard. “Fuck typing” is right, yo! At least
it’s all encapsulated.

This just reinforces [chromatic’s message][chromatic’s hack] in my mind. I'd
sure love to see LWP reworked to use [roles]!

  [chromatic’s hack]: http://www.modernperlbooks.com/mt/2010/05/are-objects-black-blocks-or-toolkits.html
  [LWP::UserAgent::WithCache]: http://search.cpan.org/perldoc?LWP::UserAgent::WithCache
  [LWP::UARobot]: http://search.cpan.org/perldoc?LWP::RobotUA
  [fuck typing]: /computers/programming/methodology/fuck-typing.html
  [roles]: http://search.cpan.org/~rgarcia/perl-5.10.0/lib/UNIVERSAL.pm#$obj-%3EDOES(_ROLE_
