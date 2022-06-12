--- 
date: 2002-11-30T20:23:00Z
lastMod: 2022-06-12T22:42:22Z
slug: my-osx-adventures
title: My Adventures with Mac OS X
aliases: [/computers/os/macosx/my_adventures.html]
tags: [macOS, David Wheeler, Perl, mod_perl, Apache, mod_ssl, GDBM, Emacs, Mac OS X Developer Tools, XML, apreq, iconv, Open SSL, Postgres, MySQL, XML::Parser, LWP, DBI, DBD::Pg, Bricolage]
type: post
---

I recently decided to make the leap from [Yellow Dog Linux] to [Mac OS X] on my
Titanium [PowerBook]. Getting everything to work the way I wanted proved to be a
challenge, but well worth it. This document outlines all that I learned, so that
neither you nor I will have to experience such pain again. The overall goal was
to get [Bricolage] up and running, figuring that if it worked, then just about
any mod\_perl based solution would run. I'm happy to say that I was ultimately
successful. You can be, too.

In the descriptions below, I provide links to download the software you'll need,
as well as the shell commands I used to compile and install each package. In all
cases (except for the installation of the Developer Tools), I saved each
package's sources to */usr/local/src* and gunzipped and untarred them there. I
also carried out each step as root, by running `sudo -s`. If you're not
comfortable using a Unix shell, you might want to [read up on it], first. All of
my examples also assume a sh-compatible shell, such as bash or zsh. Fortunately,
zsh comes with OS X, so you can just enable it for yourself in NetInfo Manager
by setting users -\> \<username\> -\> shell to "/bin/zsh", where \<username\> is
your user name.

### Developer Tools

All of the software that I describe installing below must be compiled. To
compile software on Mac OS X, you need to install the Mac OS X Developer Tools.
These provide the cc compiler and many required libraries. Conveniently, these
come on a CD-ROM with the Mac OS X Version 10.1 upgrade kit. I just popped in
the CD and installed them like you'd install any other OS X software. I needed
administrative access to OS X to install the Developer Tools (or, indeed, to
install any of the other software I describe below), but otherwise it posed no
problems.

The best time to install the Developer Tools is immediately after upgrading to
OS X version 10.1. Then run the Software Update applet in the System preferences
to get your system completely up-to-date. By the time I was done, I had the
system updated to version 10.1.3.

### Emacs

The first step I took in the process of moving to OS X was to get working the
tools I needed most. Essentially, what this meant was [GNU Emacs]. Now I happen
to be a fan of the X version of Emacs -- not XEmacs, but GNU Emacs with X
support built in. I wasn't relishing the idea of having to install X on OS X
(although there are [XFree86 ports] that do this), so I was really pleased to
discover the [Mac-Emacs project]. All I had to do was patch the GNU Emacs 21.1
sources and compile them, and I was ready to go! GNU Emacs works beautifully
with the OS X Aqua interface.

There were a few configuration issues for me to work out, however. I have become
addicted to the green background that an old RedHat .XConfig file had set, and I
wanted this feature in OS X, too. Plus, the default font was really ugly (well,
too big, really -- anyone know how to make it smaller in Emacs?) and the Mac
command key was working as the Emacs META key, rather than the option key. So I
poked around the net until I found the settings I needed and put them into my
.emacs file:

``` elisp
(custom-set-faces
'(default ((t (:stipple nil
  :background "DarkSlateGrey"
  :foreground "Wheat"
  :inverse-video nil
  :box nil
  :strike-through nil
  :overline nil
  :underline nil
  :slant normal
  :weight normal
  :height 116
  :width normal
  :family "apple-andale mono"))))
'(cursor ((t (:background "Wheat"))))
; Use option for the meta key.
(setq mac-command-key-is-meta nil)
```

Installing Emacs is not required for installing any of the other packages
described below -- it just happens to be my favorite text editor and IDE. So I
don't provide the instructions here; the [Mac-Emacs project] does a plenty good
job. If you're not comfortable with Unix editors, you can use whatever editor
you like. [BBEdit] is a good choice.

### GDBM

Mac OS X doesn't come with a DBM! But since mod\_ssl needs it, we have to
install it. Fortunately, I found [this PDF] detailing someone else's adventures
with mod\_ssl on OS X, and it provided decent instructions for installing GDBM.
First, I created a new user for GDBM. In NetInfoManager, I created a duplicate
of the "unknown" user and named it "bin". Then, I downloaded [GDBM] from the
FSF, and installed it like this:

``` sh
cd /usr/local/src/gdbm-1.8.0
cp /usr/libexec/config* .
./configure
make
make install
ln -s /usr/local/lib/libgdbm.a /usr/local/lib/libdbm.a
```

That did the trick. Nothing else was involved, fortunately.

### Expat

Who doesn't do something with XML these days? If your answer is, "not me!", then
you'll need to install the Expat library in order to work with XML::Parser in
Perl. Fortunately it's relatively easy to install, although support for the
-static flag appears to be broken in cc on OS X, so it needs to be stripped out.
I downloaded it from its [project bpage], and then did this:

``` sh
cd /usr/local/src/expat-1.95.2
./configure
perl -i.bak -p -e \
  's/LDFLAGS\s*=\s*-static/LDFLAGS=/' \
  examples/Makefile
perl -i.bak -p -e \
    's/LDFLAGS\s*=\s*-static/LDFLAGS=/' \
    xmlwf/Makefile
make
make install
```

### Perl

Although Mac OS X ships with [Perl][] (Yay!), it's the older 5.6.0 version.
There have been many bug fixes included in 5.6.1, so I wanted to make sure I got
the latest stable version before I built anything else around it (mod\_perl,
modules, etc.).

Being a Unix program, Perl doesn't expect to run into the problems associated
with a case-insensitive file system like that Mac OS X's HFS Plus. So there are
a couple of tweaks to the install process that make it slightly more complicated
than you would typically expect. Fortunately, many have preceded us in doing
this, and the work-arounds are [well-known]. Basically, it comes down to this:

``` sh
cd /usr/local/src/perl-5.6.1/
export LC_ALL=C
export LANG=en_US
perl -i.bak -p -e 's|Local/Library|Library|g' hints/darwin.sh
sh Configure -des -Dfirstmakefile=GNUmakefile -Dldflags="-flat_namespace"
make
make test
make install
```

There were a few errors during `make test`, but none of them seems to be
significant. Hopefully, in the next version of Perl, the build will work just as
it does on other platforms.

### Downloads

Before installing Open SSL, mod\_ssl, mod\_perl, and Apache, I needed to get all
the right pieces in place. The mod\_ssl and mod\_perl configure processes patch
the Apache sources, so the Apache sources have to be downloaded and gunzipped
and untarred into an adjacent directory. Furthermore, the mod\_ssl version
number corresponds to the Apache version number, so you have to be sure that
they match up. Normally, I would just download the latest versions of all of
these pieces and run with it.

However, Bricolage requires the [libapreq] library and its supporting [Perl
modules] to run, and these libraries have not yet been successfully ported to
Mac OS X. But worry not; fearless mod\_perl hackers are working on the problem
even as we speak, and there is an interim solution to get everything working.

As of this writing, the latest version of Apache is 1.3.24. But because I needed
libapreq, I had to use an [experimental] version of Apache modified to
statically compile in libapreq. Currently, only version 1.3.23 has been patched
for libapreq, so that's what I had to use. I discovered this experimental path
thanks to a [discussion] on the [Mac OS X Perl] mail list.

So essentially what I did was download the experimental [apache.tar.gz] and the
experimental lightweight [apreq.tar.gz] packages and gunzip and untar them into
/usr/local/src. Then I was ready to move on to Open SSL, mod\_ssl, and
mod\_perl.

### Open SSL

Compiling Open SSL was pretty painless. One of the tests fails, but it all seems
to work out, anyway. I download the sources from the [Open SSL site], and did
this:

``` sh
cd /usr/local/src/openssl-0.9.6c
./config
make
make test
```

### mod\_ssl

The mod\_ssl Apache module poses no problems whatsoever. I simply downloaded
mod\_ssl-2.8.7-1.3.23 from the [mod\_ssl site][] (note that the "1.3.23" at the
end matches the version of Apache I downloaded) and gunzipped and untarred it
into /usr/local/src/. Then I simply excuted:

    ./configure --with-apache=/usr/local/src/apache_1.3.23

### mod\_perl

Configuring and installing mod\_ssl was, fortunately, a relatively
straight-forward process. Getting Apache compiled with mod\_perl and mod\_ssl,
however, was quite tricky, as you'll see below. A number of braver folks than I
have preceded me in installing mod\_perl, so I was able to rely on their
hard-earned knowledge to get the job done. For example, Randal Schwartz [posted]
instructions to the [mod\_perl mail list], and his instructions worked well for
me. So I downloaded the sources from the [mod\_perl] site, and did this:

``` sh
cd /usr/local/src/mod_perl-1.26
perl Makefile.PL \
  APACHE_SRC=/usr/local/src/apache_1.3.23/src \
  NO_HTTPD=1 \
  USE_APACI=1 \
  PREP_HTTPD=1 \
  EVERYTHING=1
make
make install
```

### Apache

Getting Apache compiled just right was the most time-consuming part of this
process for me. Although many had gone before me in this task, everybody seems
to do it differently. I had become accustomed to just allowing Apache to use
most of its defaults when I compiled under Linux, but now I was getting all
kinds of errors while following different instructions from different
authorities from around the web. Sometimes Apache wouldn't compile at all, and
I'd get strange errors. Other times it would compile, pass all of its tests, and
install, only to offer up errors such as

    dyld: /usr/local/apache/bin/httpd Undefined symbols: _log_config_module

when I tried to start it. It turns out that the problem there was that I had a
number of modules compiled as DSOs -- that is, libraries that can be loaded into
Apache dynamically -- but wasn't loading them properly in my httpd.conf. This
was mainly because I've grown accustomed to Apache having all the libraries I
needed compiled in statically, so I simply didn't have to worry about them.

But I finally hit on the right incantation to get Apache to compile with
everything I need added statically, but still with support for DSOs by compiling
in mod\_so. I present it here for your viewing pleasure:

``` sh
SSL_BASE=/usr/local/src/openssl-0.9.6c/ \
  ./configure \
  --with-layout=Apache \
  --enable-module=ssl \
  --enable-module=rewrite \
  --enable-module=so \
  --activate-module=src/modules/perl/libperl.a \
  --disable-shared=perl \
  --without-execstrip
make
make certificate TYPE=custom 
make install
```

This series of commands successfully compiled Apache with mod\_perl and mod\_ssl
support statically compiled in, along with most of the other default modules
that come with Apache. In short, everything is there that you need to run a
major application with security such as [Bricolage].

Note that `make certificate` will lead you through the process of creating an
SSL certificate. I like to use the "custom" type so that it reflects the name of
my organization. But you can use whatever approach you're most comfortable with.
Consult the mod\_ssl [INSTALL] file for more information.

### libapreq

Once Apache is installed with mod\_perl and mod\_ssl, the rest is gravy! The
experimental libapreq library I downloaded installed without a hitch:

``` sh
cd /usr/local/src/httpd-apreq
perl Makefile.PL
make
make install
```

### PostgreSQL

[PostgreSQL] is a sophisticated open-source Object-Relational DBMS. I use it a
lot in my application development, and it, too, is required by Bricolage. I was
a bit concerned about how well it would compile and work on Mac OS X, but I
needn't have worried. First of all, [Apple] has provided some pretty decent
[instructions]. Although they mainly document how to install [MySQL], a
competing open-source RDBMS, many of the same concepts apply to PostgreSQL.

The first thing I had to do was to create the "postgres" user. This is the
system user that PostgreSQL typically runs as. I followed Apple's instructions,
using NetInfo Manager to duplicate the default "www" group and "www" user and
give the copies the name "postgres" and a new gid and uid, respectively.

Next I downloaded the PostgreSQL version 7.2.1 sources. Version 7.2 is the first
to specifically support Mac OS X, so going about the install was as simple as it
is on any Unix system:

``` sh
./configure --enable-multibyte=UNICODE
make
make install
```

That was it! PostgreSQL was now installed. Next I had to initialize the
PostgreSQL database directory. Again, this works much the same as it does on any
Unix system:

``` sh
sudo -u postgres /usr/local/pgsql/bin/initdb \
  -D /usr/local/pgsql/data
```

The final step was to start PostgreSQL and try to connect to it:

``` sh
sudo -u postgres /usr/local/pgsql/bin/pg_ctl start \
  -D /usr/local/pgsql/data /usr/local/pgsql/bin/psql -U postgres template1
```

If you follow the above steps and find yourself at a psql prompt, you're in
business! Because I tend to use PostgreSQL over TCP, I also enabled TCP
connectivity by enabling the "tcpip\_socket" option in the postgresql.conf file
in the data directory created by initdb:

``` ini
tcpip_socket = true
```

If you're like me, you like to have servers such as PostgreSQL start when your
computer starts. I enabled this by creating a Mac OS X PostgreSQL startup
bundle. It may or may not be included in a future version of PostgreSQL, but in
the meantime, you can download it from [here]. Simply download it, gunzip and
untar it into /Library/StartupItems, restart OS X, and you'll see it start up
during the normal Mac OS X startup sequence. I built this startup bundle by
borrowing from the existing FreeBSD PostgreSQL startup script, the Apache
startup script that ships with OS X, and by reading the [Creating SystemStarter
Startup Item Bundles HOWTO].

### XML::Parser

At this point, I had most

of the major pieces in place, and it was time for me to install the Perl modules
I needed. First up was [XML::Parser]. For some reason, XML::Parser can't find
the expat libraries, even though the location in which I installed them is
pretty common. I got around this by installing XML::Parser like this:

``` sh
perl Makefile.PL EXPATLIBPATH=/usr/local/lib \
  EXPATINCPATH=/usr/local/include
make
make test
make install
```

### Text::Iconv

In Bricolage, [Text::Iconv] does all the work of converting text between
character sets. This is because all of the data is stored in the database in
Unicode, but we wanted to allow users to use the character set with which
they're accustomed in the UI. So I needed to install Text::Iconv. Naturally, Mac
OS X doesn't come with libiconv -- a library on which Text::Iconv depends -- so
I had to install it. Fortunately, it was a simple process to [download it] and
do a normal build:

``` sh
cd /usr/local/src/libiconv-1.7
./configure
make
make install
```

Now, Text::Iconv itself was a little more problematic. You have to tell it to
look for libiconv by adding the -liconv option to the LIBS key in Makefile.PL.
I've simplified doing this with the usual Perl magic:

``` sh
perl -i.bak -p -e \
  "s/'LIBS'\s*=>\s*\[''\]/'LIBS' => \['-liconv'\]/" \
  Makefile.PL
perl Makefile.PL
make
make test
make install
```

### DBD::Pg

Although the [DBI] installed via the CPAN module without problem, [DBD::Pg]
wanted to play a little less nice. Of course I specified the proper environment
variables to install it (anyone know why DBD::Pg's Makefile.PL script can't try
to figure those out on its own?), but still I got this error during `make`:

    /usr/bin/ld: table of contents for archive:
    /usr/local/pgsql/lib/libpq.a is out of date;
    rerun  ranlib(1) (can't load from it)

But this was one of those unusual situations in which the error message was
helpful. So I took the error message's advice, and successfully compiled and
installed DBD::Pg like this:

``` sh
ranlib /usr/local/pgsql/lib/libpq.a
export POSTGRES_INCLUDE=/usr/local/pgsql/include
export POSTGRES_LIB=/usr/local/pgsql/lib
perl Makefile.PL
make
make test
make install
```

### LWP

The last piece I needed to worry about customizing when I installed it was
[LWP]. Before installing, back up /usr/bin/head. The reason for this is that LWP
will install /usr/bin/HEAD, and because HFS Plus is a case-insensitive file
system, it'll overwrite /usr/bin/head! This is a pretty significant issue, since
many configure scripts use /usr/bin/head. So after installing LWP, move
/usr/bin/HEAD, GET, & POST to /usr/local/bin. Also move /usr/bin/lwp\* to
/usr/local/bin. Then move your backed-up copy of head back to /usr/bin.

Naturally, I didn't realize that this was necessary until it was too late. I
installed LWP with the CPAN module, and it wiped out /usr/bin/head. Fortunately,
all was not lost (though it took me a while to figure out why my Apache compiles
were failing!): I was able to restore head by copying it from the Mac OS X
installer CD. I Just popped it in an executed the command:

``` sh
cp "/Volumes/Mac OS X Install CD/usr/bin/head" /usr/bin
```

And then everything was happy again.

### Bricolage

And finally, the pièce de résistance: [Bricolage!][Bricolage] All of the other
required Perl modules installed fine from Bundle::Bricolage:

``` sh
perl -MCPAN -e 'install Bundle::Bricolage'
```

Then I simply followed the directions in Bricolage's INSTALL file, and started
'er up! I would document those steps here, but the install process is currently
in flux and likely to change soon. The INSTALL file should always be current,
however -- check it out!

### To Be Continued

No doubt my adventures with Unix tools on Mac OS X are far from over. I've
reported to various authors on the issues I've described above, and most will
soon be releasing new versions to address those issues. As they do, I'll
endeavor to keep this page up-to-date. In the meantime, I am thoroughly enjoying
working with the first really solid OS that Apple has released in years, and
thrilled that I can finally have the best of both worlds: a good, reliable, and
elegant UI, and all the Unix power tools I can stand! I hope you do, too.

  [Yellow Dog Linux]: https://en.wikipedia.org/wiki/Yellow_Dog_Linux
  [Mac OS X]: https://www.apple.com/macosx/
  [PowerBook]: https://www.apple.com/powerbook/
  [Bricolage]: https://bricolagecms.org/
  [read up on it]: http://www.oreillynet.com/pub/a/mac/2001/12/14/terminal_one.html
  [GNU Emacs]: https://www.gnu.org/software/emacs/emacs.html
  [XFree86 ports]: https://en.wikipedia.org/wiki/XDarwin
  [Mac-Emacs project]: http://mac-emacs.sourceforge.net/
  [BBEdit]: https://www.barebones.com/products/bbedit/
  [this PDF]: https://web.archive.org/web/20030810222250/http://homepage.mac.com/rgriff/files/mod_ssl.pdf
  [GDBM]: https://www.gnu.org.ua/software/gdbm/
  [project bpage]: https://sourceforge.net/projects/expat/
  [Perl]: https://www.perl.com/
  [well-known]: https://www.nntp.perl.org/group/perl.macosx/2001/10/msg896.html
  [libapreq]: https://httpd.apache.org/apreq/
  [Perl modules]: https://metacpan.org/search?q=dist%3Alibapreq
  [experimental]: https://web.archive.org/web/20021128141259/http://www.apache.org/~joes/
  [discussion]: http://archive.develooper.com/macosx@perl.org/index.html#01539
  [Mac OS X Perl]: https://lists.perl.org/list/macosx.html
  [apache.tar.gz]: http://www.apache.org/~joes/apache.tar.gz
  [apreq.tar.gz]: http://www.apache.org/~joes/apreq.tar.gz
  [Open SSL site]: https://www.openssl.org
  [mod\_ssl site]: http://www.modssl.org
  [posted]: https://web.archive.org/web/20021112182402/http://mathforum.org/epigone/modperl/fermkhiwhand/m1wv11m544.fsf_-_@halfdome.holdit.com
  [mod\_perl mail list]: https://lists.perl.org/list/modperl-user.html
  [mod\_perl]: https://perl.apache.org
  [INSTALL]: http://www.modssl.org/source/exp/mod_ssl/pkg.mod_ssl/INSTALL
  [PostgreSQL]: https://www.postgresql.org/
  [Apple]: https://www.apple.com/
  [instructions]: https://web.archive.org/web/20021201185559/http://developer.apple.com/internet/macosx/osdb.html
  [MySQL]: https://dev.mysql.com/
  [here]: {{% link "/downloads/pgsql_osx_start.tar.gz" %}}
  [Creating SystemStarter Startup Item Bundles HOWTO]: https://web.archive.org/web/20021003151714/http://www.opensource.apple.com/projects/documentation/howto/html/SystemStarter_HOWTO.html
  [XML::Parser]: https://metacpan.org/dist/XML-Parser
  [Text::Iconv]: https://metacpan.org/dist/Text-Iconv
  [download it]: http://www.gnu.org/software/libiconv/
  [DBI]: https://metacpan.org/dist/DBI
  [DBD::Pg]: https://metacpan.org/dist/DBD-Pg
  [LWP]: https://metacpan.org/dist/libwww-perl
