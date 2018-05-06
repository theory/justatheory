package TAP::Parser::SourceHandler::Ruby;

use strict;

use TAP::Parser::IteratorFactory   ();
use TAP::Parser::Iterator::Process ();
TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);

sub can_handle {
    my ( $class, $source ) = @_;
    my $meta = $source->meta;

    # If it's not a file (test script), we're not interested.
    return 0 unless $meta->{is_file};

    # Get the file suffix, if any.
    my $suf = $meta->{file}{lc_ext};

    # If the config specifies a suffix, it's required.
    if ( my $config = $source->config_for('Ruby') ) {
        if ( defined $config->{suffix} ) {
            # Return 1 for a perfect score.
            return $suf eq $config->{suffix} ? 1 : 0;
        }
    }

    # Otherwise, return a score for our supported suffix.
    return $suf eq '.rb' ? 0.8 : 0;
}

sub make_iterator {
    my ( $class, $source ) = @_;
    my $config = $source->config_for('Ruby');

    my $fn = ref $source->raw ? ${ $source->raw } : $source->raw;
    $class->_croak(
        'No such file or directory: ' . defined $fn ? $fn : ''
    ) unless $fn && -e $fn;

    return TAP::Parser::Iterator::Process->new({
        command => [$config->{ruby} || 'ruby', $fn ],
        merge   => $source->merge
    });
}

1;
