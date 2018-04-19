Updating Fonts
==============

1.  Download the latest stable releases of the non-variable versions of
    [Source Sans Pro](https://github.com/adobe-fonts/source-sans-pro/releases) and
    [Source Code Pro](https://github.com/adobe-fonts/source-code-pro/releases).
2.  Unpack the downloads.
3.  From each package, upload the contents of the `OTF` directories, 12 at a
    time, to the
    [FontSquirrel Webfont Generator](https://www.fontsquirrel.com/tools/webfont-generator).
4.  Check the box to confirm that the fonts can be used for web embedding, then
    download the fonts.
5.  Repeat steps 3-4 until all the fonts have been downloaded.
6.  Copy all the files matching `*.woff*` to a single fonts directory.
7.  Run this Perl script over the files:

        use v5.20;
        use warnings;
        use utf8;
        use File::Copy qw(mv);

        my %config = (
            black => { qual => 'blk', style => 'normal', weight => '900' },
            blackit => { qual => 'blkit', style => 'italic', weight => '900' },
            bold => { qual => 'bld', style => 'normal', weight => 'bold' },
            boldit => { qual => 'bldit', style => 'italic', weight => 'bold' },
            extralight => { qual => 'xlt', style => 'normal', weight => '100' },
            extralightit => { qual => 'xltit', style => 'italic', weight => '100' },
            it  => { qual => 'it', style => 'italic', weight => 'normal' },
            light => { qual => 'lt', style => 'normal', weight => '200' },
            lightit => { qual => 'ltit', style => 'italic', weight => '200' },
            medium => { qual => 'med', style => 'normal', weight => 'normal' },
            mediumit => { qual => 'medit', style => 'italic', weight => 'normal' },
            regular => { qual => 'reg', style => 'normal', weight => 'normal' },
            semibold => { qual => 'sbld', style => 'normal', weight => '600' },
            semiboldit => { qual => 'sbldit', style => 'italic', weight => '600' },
        );

        for my $fn (@ARGV) {
            my ($name, $type, $ext) = $fn =~ /^([^-]+)-([^-]+)-[^.]+.([^.]+)/;
            next unless $name;
            my ($sn, $ln) = $name eq 'sourcesanspro'
                ? ('srcsans', 'SourceSans')  : ('srccode', 'SourceCode');;
            my $c = $config{$type} or die "No config for $type\n";
            my $bn = "$sn-$c->{qual}";
            if ($ext eq 'woff') {
                say qq{\@font-face {
            font-family: '$ln';
            src: url('/fonts/$bn.woff2') format('woff2'),
                url('/fonts/$bn.woff') format('woff');
            font-weight: $c->{weight};
            font-style: $c->{style};
        }
        };
            }

            mv $fn => "$bn.$ext";
        }

8.  Copy the output of the script into the CSS file.


See the
[Mozilla Web fonts docs](https://developer.mozilla.org/en-US/docs/Learn/CSS/Styling_text/Web_fonts)
for additional information on web fonts, and
[this SO answer](https://stackoverflow.com/a/11002874/79202) for reasons to just
use WOFF2 and WOFF.
