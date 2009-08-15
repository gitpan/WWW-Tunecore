#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WWW::Tunecore' );
}

diag( "Testing WWW::Tunecore $WWW::Tunecore::VERSION, Perl $], $^X" );
