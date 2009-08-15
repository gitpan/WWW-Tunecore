#!/usr/bin/perl

use Test::More tests => 1;

use WWW::Tunecore;

SKIP: {
    skip 'Need login to test sales download', 1;

    # See if we can get a username and password
    my $tunecore = new WWW::Tunecore( auto_login => 1);

    my $sales="";
    if ( $sales = $tunecore->download_sales ) {
        pass('Download Sales');
    } else {
        fail('Download Sales');
    }

}
