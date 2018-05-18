--- 
date: 2002-11-30T20:23:00Z
slug: my-adventures
title: My Adventures with Mac OS X
aliases: [/computers/os/macosx/my_adventures.html]
tags: [macOS, David Wheeler, Perl, mod_perl, Apache, mod_ssl, GDBM, Emacs, Mac OS X Developer Tools, XML, apreq, iconv, Open SSL, Postgres, MySQL, XML::Parser, LWP, DBI, DBD::Pg, Bricolage]
type: post
---

<p>I recently decided to make the leap from
<a href="http://www.yellowdoglinux.com/">Yellow Dog Linux</a> to
<a href="http://www.apple.com/macosx/">Mac OS X</a> on my Titanium
<a href="http://www.apple.com/powerbook/">PowerBook</a>. Getting everything to
work the way I wanted proved to be a challenge, but well worth it. This
document outlines all that I learned, so that neither you nor I will have to
experience such pain again. The overall goal was to get
<a href="http://bricolage.cc/">Bricolage</a> up and running,
figuring that if it worked, then just about any mod_perl based solution
would run. I'm happy to say that I was ultimately successful. You can be,
too.</p>

<p>In the descriptions below, I provide links to download the software
you'll need, as well as the shell commands I used to compile and install
each package. In all cases (except for the installation of the Developer
Tools), I saved each package's sources to <em>/usr/local/src</em> and
gunzipped and untarred them there. I also carried out each step as root, by
running
<code>sudo -s</code>. If you're not comfortable using a Unix shell, you
might want to
<a href="http://www.oreillynet.com/pub/a/mac/2001/12/14/terminal_one.html">read up on it</a>, first. All of my examples also assume a sh-compatible shell,
such as bash or zsh. Fortunately, zsh comes with OS X, so you can just
enable it for yourself in NetInfo Manager by setting users -&gt;
&lt;username&gt; -&gt; shell to &quot;/bin/zsh&quot;, where &lt;username&gt;
is your user name.</p>

<h3>Developer Tools</h3>
<p>All of the software that I describe installing below must be compiled. To
compile software on Mac OS X, you need to install the Mac OS X Developer
Tools. These provide the cc compiler and many required libraries.
Conveniently, these come on a CD-ROM with the Mac OS X Version 10.1 upgrade
kit. I just popped in the CD and installed them like you'd install any other OS X
software. I needed administrative access to OS X to install the
Developer Tools (or, indeed, to install any of the other software I describe
below), but otherwise it posed no problems.</p>

<p>The best time to install the Developer Tools is immediately after
upgrading to OS X version 10.1. Then run the Software Update applet in the
System preferences to get your system completely up-to-date. By the time I
was done, I had the system updated to version 10.1.3.</p>

<h3>Emacs</h3>
<p>The first step I took in the process of moving to OS X was to get
working the tools I needed most. Essentially, what this meant was
<a href="http://www.gnu.org/software/emacs/emacs.html">GNU Emacs</a>. Now I
happen to be a fan of the X version of Emacs -- not XEmacs, but GNU Emacs
with X support built in. I wasn't relishing the idea of having to install X
on OS X (although there are <a href="http://www.xdarwin.org/">XFree86 ports</a>
that do this), so I was really pleased to discover the
<a href="http://mac-emacs.sourceforge.net/">Mac-Emacs project</a>. All I had to
do was patch the GNU Emacs 21.1 sources and compile them, and I was ready to
go! GNU Emacs works beautifully with the OS X Aqua interface.</p>

<p>There were a few configuration issues for me to work out, however. I have
become addicted to the green background that an old RedHat .XConfig file had
set, and I wanted this feature in OS X, too. Plus, the default font was
really ugly (well, too big, really -- anyone know how to make it smaller in
Emacs?) and the Mac command key was working as the Emacs META key, rather
than the option key. So I poked around the net until I found the settings I
needed and put them into my .emacs file:</p>

<pre>(custom-set-faces
'(default ((t (:stipple nil
  :background &quot;DarkSlateGrey&quot;
  :foreground &quot;Wheat&quot;
  :inverse-video nil
  :box nil
  :strike-through nil
  :overline nil
  :underline nil
  :slant normal
  :weight normal
  :height 116
  :width normal
  :family &quot;apple-andale mono&quot;))))
'(cursor ((t (:background &quot;Wheat&quot;))))
; Use option for the meta key.
(setq mac-command-key-is-meta nil)</pre>

<p>Installing Emacs is not required for installing any of the other packages
described below -- it just happens to be my favorite text editor and IDE. So
I don't provide the instructions here; the
<a href="http://mac-emacs.sourceforge.net/">Mac-Emacs project</a> does a plenty
good job. If you're not comfortable with Unix editors, you can use whatever
editor you like. <a href="http://www.bbedit.com/products/bbedit.html">BBEdit</a>
is a good choice.</p>

<h3>GDBM</h3>
<p>Mac OS X doesn't come with a DBM! But since mod_ssl needs it, we have to
install it. Fortunately, I found
<a href="http://homepage.mac.com/rgriff/files/mod_ssl.pdf">this PDF</a>
detailing someone else's adventures with mod_ssl on OS X, and it provided
decent instructions for installing GDBM. First, I created a new user for
GDBM. In NetInfoManager, I created a duplicate of the &quot;unknown&quot;
user and named it &quot;bin&quot;. Then, I downloaded
<a href="http://www.gnu.org/software/gdbm/gdbm.html">GDBM</a> from the FSF,
and installed it like this:</p>

<pre>cd /usr/local/src/gdbm-1.8.0
cp /usr/libexec/config* .
./configure
make
make install
ln -s /usr/local/lib/libgdbm.a /usr/local/lib/libdbm.a</pre>

<p>That did the trick. Nothing else was involved, fortunately.</p>

<h3>Expat</h3>
<p>Who doesn't do something with XML these days? If your answer is, &quot;not
me!&quot;, then you'll need to install the Expat library in order to work
with XML::Parser in Perl. Fortunately it's relatively easy to install,
although support for the -static flag appears to be broken in cc on OS X, so
it needs to be stripped out. I downloaded it from its
<a href="http://sourceforge.net/projects/expat/">project bpage</a>, and then
did this:</p>

<pre>cd /usr/local/src/expat-1.95.2
./configure
perl -i.bak -p -e \
  's/LDFLAGS\s*=\s*-static/LDFLAGS=/' \
  examples/Makefile
perl -i.bak -p -e \
  's/LDFLAGS\s*=\s*-static/LDFLAGS=/' \
  xmlwf/Makefile
make
make install</pre>

<h3>Perl</h3>
<p>Although Mac OS X ships with <a href="http://www.perl.com/">Perl</a> (Yay!),
it's the older 5.6.0 version. There have been many bug fixes included in
5.6.1, so I wanted to make sure I got the latest stable version before I
built anything else around it (mod_perl, modules, etc.).</p>

<p>Being a Unix program, Perl doesn't expect to run into the problems
associated with a case-insensitive file system like that Mac OS X's HFS
Plus. So there are a couple of tweaks to the install process that make it
slightly more complicated than you would typically expect. Fortunately, many
have preceded us in doing this, and the work-arounds are
<a href="http://archive.develooper.com/macosx@perl.org/msg00895.html">well-known</a>.
Basically, it comes down to this:</p>

<pre>cd /usr/local/src/perl-5.6.1/
export LC_ALL=C
export LANG=en_US
perl -i.bak -p -e 's|Local/Library|Library|g' hints/darwin.sh
sh Configure -des -Dfirstmakefile=GNUmakefile -Dldflags=&quot;-flat_namespace&quot;
make
make test
make install</pre>

  <p>There were a few errors during <code>make test</code>, but none of them
  seems to be significant. Hopefully, in the next version of Perl, the build
  will work just as it does on other platforms.</p>

  <h3>Downloads</h3>
  <p>Before installing Open SSL, mod_ssl, mod_perl, and Apache, I needed to get
  all the right pieces in place. The mod_ssl and mod_perl configure processes
  patch the Apache sources, so the Apache sources have to be downloaded and
  gunzipped and untarred into an adjacent directory. Furthermore, the mod_ssl
  version number corresponds to the Apache version number, so you have to be
  sure that they match up. Normally, I would just download the latest versions
  of all of these pieces and run with it.</p>

  <p>However, Bricolage requires the
  <a href="http://httpd.apache.org/apreq/">libapreq</a> library and its supporting
  <a href="http://search.cpan.org/search?dist=libapreq">Perl modules</a>
  to run, and these libraries have not yet been successfully
  ported to Mac OS X. But worry not; fearless mod_perl hackers are working on
  the problem even as we speak, and there is an interim solution to get
  everything working.</p>

  <p>As of this writing, the latest version of Apache is 1.3.24. But because I
  needed libapreq, I had to use an
  <a href="http://www.apache.org/~joes/">experimental</a> version of Apache
  modified to statically compile in libapreq. Currently, only version 1.3.23
  has been patched for libapreq, so that's what I had to use. I discovered
  this experimental path thanks to a
  <a href="http://archive.develooper.com/macosx@perl.org/index.html#01539">discussion</a>
  on the <a href="http://lists.perl.org/showlist.cgi?name=macosx">Mac OS X Perl</a>
  mail list.</p>

  <p>So essentially what I did was download the experimental
  <a href="http://www.apache.org/~joes/apache.tar.gz">apache.tar.gz</a> and the
  experimental lightweight <a href="http://www.apache.org/~joes/apreq.tar.gz">apreq.tar.gz</a>
  packages and gunzip and untar them into /usr/local/src. Then I was ready to move on
  to Open SSL, mod_ssl, and mod_perl.</p>
  
  <h3>Open SSL</h3>
  <p>Compiling Open SSL was pretty painless. One of the tests fails, but it all
  seems to work out, anyway. I download the sources from the
  <a href="http://www.openssl.org/">Open SSL site</a>, and did this:</p>

<pre>cd /usr/local/src/openssl-0.9.6c
./config
make
make test</pre>

<h3>mod_ssl</h3>

<p>The mod_ssl Apache module poses no problems whatsoever. I simply downloaded
mod_ssl-2.8.7-1.3.23 from the <a href="http://www.modssl.org/">mod_ssl site</a>
(note that the "1.3.23" at the end matches the version of Apache I
downloaded) and gunzipped and untarred it into /usr/local/src/. Then I
simply excuted:</p>

<pre>./configure --with-apache=/usr/local/src/apache_1.3.23</pre>

<h3>mod_perl</h3>
<p>Configuring and installing mod_ssl was, fortunately, a relatively
straight-forward process. Getting Apache compiled with mod_perl and mod_ssl,
however, was quite tricky, as you'll see below. A number of braver folks
than I have preceded me in installing mod_perl, so I was able to rely on
their hard-earned knowledge to get the job done. For example, Randal
Schwartz
<a href="http://mathforum.org/epigone/modperl/fermkhiwhand/m1wv11m544.fsf_-_@halfdome.holdit.com">posted</a>
instructions to the <a href="http://lists.perl.org/showlist.cgi?name=modperl-user">mod_perl mail
list</a>, and his instructions worked well for me. So I downloaded the
sources from the <a href="http://perl.apache.org/">mod_perl</a> site, and
did this:</p>

<pre>cd /usr/local/src/mod_perl-1.26
perl Makefile.PL \
  APACHE_SRC=/usr/local/src/apache_1.3.23/src \
  NO_HTTPD=1 \
  USE_APACI=1 \
  PREP_HTTPD=1 \
  EVERYTHING=1
make
make install</pre>

  <h3>Apache</h3>
  <p>Getting Apache compiled just right was the most time-consuming part of this
  process for me. Although many had gone before me in this task, everybody
  seems to do it differently. I had become accustomed to just allowing Apache
  to use most of its defaults when I compiled under Linux, but now I was
  getting all kinds of errors while following different instructions from
  different authorities from around the web. Sometimes Apache wouldn't compile
  at all, and I'd get strange errors. Other times it would compile, pass all
  of its tests, and install, only to offer up errors such as</p>

  <pre>dyld: /usr/local/apache/bin/httpd Undefined symbols: _log_config_module</pre>

<p>when I tried to start it. It turns out that the problem there was that I
had a number of modules compiled as DSOs -- that is, libraries that can be
loaded into Apache dynamically -- but wasn't loading them properly in my
httpd.conf. This was mainly because I've grown accustomed to Apache having
all the libraries I needed compiled in statically, so I simply didn't have
to worry about them.</p>

<p>But I finally hit on the right incantation to get Apache to compile with
everything I need added statically, but still with support for DSOs by
compiling in mod_so. I present it here for your viewing pleasure:</p>

<pre>SSL_BASE=/usr/local/src/openssl-0.9.6c/ \
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
  make install</pre>

<p>This series of commands successfully compiled Apache with mod_perl and
mod_ssl support statically compiled in, along with most of the other default
modules that come with Apache. In short, everything is there that you need
to run a major application with security such as
<a href="http://bricolage.cc/">Bricolage</a>.</p>

<p>Note that <code>make certificate</code> will lead you through the process
of creating an SSL certificate. I like to use the &quot;custom&quot; type so
that it reflects the name of my organization. But you can use whatever
approach you're most comfortable with. Consult the mod_ssl
<a href="http://www.modssl.org/source/exp/mod_ssl/pkg.mod_ssl/INSTALL">INSTALL</a>
file for more information.</p>

<h3>libapreq</h3>
<p>Once Apache is installed with mod_perl and mod_ssl, the rest is gravy! The
experimental libapreq library I downloaded installed without a hitch:</p>

<pre>cd /usr/local/src/httpd-apreq
perl Makefile.PL
make
make install</pre>

<h3>PostgreSQL</h3>
<p><a href="http://www.postgresql.org/">PostgreSQL</a> is a sophisticated
open-source Object-Relational DBMS. I use it a lot in my application
development, and it, too, is required by Bricolage. I was a bit concerned
about how well it would compile and work on Mac OS X, but I needn't have
worried. First of all, <a href="http://www.apple.com/">Apple</a> has
provided some pretty decent
<a href="http://developer.apple.com/internet/macosx/osdb.html">instructions</a>.
Although they mainly document how to install <a href="http://www.mysql.org/">MySQL</a>,
a competing open-source RDBMS, many of the same concepts apply to PostgreSQL.</p>

<p>The first thing I had to do was to create the &quot;postgres&quot; user.
This is the system user that PostgreSQL typically runs as. I followed Apple's
instructions, using NetInfo Manager to duplicate the default &quot;www&quot;
group and &quot;www&quot; user and give the copies the name
&quot;postgres&quot; and a new gid and uid, respectively.</p>

<p>Next I downloaded the PostgreSQL version 7.2.1 sources. Version 7.2 is
the first to specifically support Mac OS X, so going about the install was
as simple as it is on any Unix system:</p>

<pre>./configure --enable-multibyte=UNICODE
make
make install</pre>

<p>That was it! PostgreSQL was now installed. Next I had to initialize
the PostgreSQL database directory. Again, this works much the same as it does
on any Unix system:</p>

<pre>sudo -u postgres /usr/local/pgsql/bin/initdb \
  -D /usr/local/pgsql/data</pre>

<p>The final step was to start PostgreSQL and try to connect to it:</p>

<pre>sudo -u postgres /usr/local/pgsql/bin/pg_ctl start \
  -D /usr/local/pgsql/data /usr/local/pgsql/bin/psql -U postgres template1</pre>

<p>If you follow the above steps and find yourself at a psql prompt, you're
in business! Because I tend to use PostgreSQL over TCP, I also enabled TCP
connectivity by enabling the &quot;tcpip_socket&quot; option in the
postgresql.conf file in the data directory created by initdb:</p>

<pre>tcpip_socket = true</pre>

<p>If you're like me, you like to have servers such as PostgreSQL start when
your computer starts. I enabled this by creating a Mac OS X PostgreSQL
startup bundle. It may or may not be included in a future version of
PostgreSQL, but in the meantime, you can download it from <a
href="/downloads/pgsql_osx_start.tar.gz">here</a>. Simply download it, gunzip and untar
it into /Library/StartupItems, restart OS X, and you'll see it start up
during the normal Mac OS X startup sequence. I built this startup bundle by
borrowing from the existing FreeBSD PostgreSQL startup script, the Apache
startup script that ships with OS X, and by reading the
<a href="http://www.opensource.apple.com/projects/documentation/howto/html/SystemStarter_HOWTO.html">Creating SystemStarter Startup Item Bundles HOWTO</a>.</p>

<h3>XML::Parser</h3> At this point, I had most
<p>of the major pieces in place, and it was time for me to install the Perl
modules I needed. First up was
<a href="http://search.cpan.org/search?dist=XML-Parser">XML::Parser</a>. For
some reason, XML::Parser can't find the expat libraries, even though the
location in which I installed them is pretty common. I got around this by
installing XML::Parser like this:</p>

<pre>perl Makefile.PL EXPATLIBPATH=/usr/local/lib \
  EXPATINCPATH=/usr/local/include
make
make test
make install</pre>

<h3>Text::Iconv</h3>
<p>In Bricolage, <a href="http://search.cpan.org/search?dist=Text-Iconv">Text::Iconv</a> does
all the work of converting text between character sets. This is because all
of the data is stored in the database in Unicode, but we wanted to allow
users to use the character set with which they're accustomed in the UI. So I
needed to install Text::Iconv. Naturally, Mac OS X doesn't come with
libiconv -- a library on which Text::Iconv depends -- so I had to install
it. Fortunately, it was a simple process to
<a href="http://www.gnu.org/software/libiconv/">download it</a> and do a normal
build:</p>

<pre>cd /usr/local/src/libiconv-1.7
./configure
make
make install</pre>

<p>Now, Text::Iconv itself was a little more problematic. You have to tell
it to look for libiconv by adding the -liconv option to the LIBS key in
Makefile.PL. I've simplified doing this with the usual Perl magic:</p>

<pre>perl -i.bak -p -e \
  "s/'LIBS'\s*=>\s*\[''\]/'LIBS' => \['-liconv'\]/" \
  Makefile.PL
perl Makefile.PL
make
make test
make install
</pre>

<h3>DBD::Pg</h3>
<p>Although the <a href="http://search.cpan.org/search?dist=DBI">DBI</a>
installed via the CPAN module without problem,
<a href="http://search.cpan.org/search?dist=DBD-Pg">DBD::Pg</a> wanted to play
a little less nice. Of course I specified the proper environment variables to
install it (anyone know why DBD::Pg's Makefile.PL script can't try to figure
those out on its own?), but still I got this error during <code>make</code>:</p>

<pre>/usr/bin/ld: table of contents for archive:
/usr/local/pgsql/lib/libpq.a is out of date;
rerun  ranlib(1) (can't load from it)</pre>

<p>But this was one of those unusual situations in which the error message
was helpful. So I took the error message's advice, and successfully compiled
and installed DBD::Pg like this:</p>

<pre>ranlib /usr/local/pgsql/lib/libpq.a
export POSTGRES_INCLUDE=/usr/local/pgsql/include
export POSTGRES_LIB=/usr/local/pgsql/lib
perl Makefile.PL
make
make test
make install</pre>

<h3>LWP</h3>
<p>The last piece I needed to worry about customizing when I installed it was
<a href="http://search.cpan.org/search?dist=libwww-perl">LWP</a>. Before
installing, back up /usr/bin/head. The reason for this is that LWP will
install /usr/bin/HEAD, and because HFS Plus is a case-insensitive file system,
it'll overwrite /usr/bin/head! This is a pretty significant issue, since
many configure scripts use /usr/bin/head. So after installing LWP, move
/usr/bin/HEAD, GET, &amp; POST to /usr/local/bin. Also move /usr/bin/lwp* to
/usr/local/bin. Then move your backed-up copy of head back to /usr/bin.</p>

<p>Naturally, I didn't realize that this was necessary until it was too
late. I installed LWP with the CPAN module, and it wiped out /usr/bin/head.
Fortunately, all was not lost (though it took me a while to figure out why
my Apache compiles were failing!): I was able to restore head by copying it
from the Mac OS X installer CD. I Just popped it in an executed the
command:</p>

<pre>cp "/Volumes/Mac OS X Install CD/usr/bin/head" /usr/bin</pre>

<p>And then everything was happy again.</p>

<h3>Bricolage</h3>

<p>And finally, the pi&egrave;ce de r&eacute;sistance:
<a href="http://bricolage.cc/">Bricolage!</a> All of the other
required Perl modules installed fine from Bundle::Bricolage:</p>

<pre>perl -MCPAN -e 'install Bundle::Bricolage'</pre>

<p>Then I simply followed the directions in Bricolage's INSTALL file, and
started 'er up! I would document those steps here, but the install process
is currently in flux and likely to change soon. The INSTALL file should
always be current, however -- check it out!</p>

<h3>To Be Continued</h3>
<p>No doubt my adventures with Unix tools on Mac OS X are far from over. I've
reported to various authors on the issues I've described above, and most
will soon be releasing new versions to address those issues. As they do,
I'll endeavor to keep this page up-to-date. In the meantime, I am thoroughly
enjoying working with the first really solid OS that Apple has released in
years, and thrilled that I can finally have the best of both worlds: a good,
reliable, and elegant UI, and all the Unix power tools I can stand! I hope
you do, too.</p>
