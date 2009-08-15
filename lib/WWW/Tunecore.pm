package WWW::Tunecore;

use warnings;
use strict;

=head1 NAME

WWW::Tunecore - Control your Tunecore account in Perl

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

WWW::Tunecore provides methods that allow you to programatically
perform various functions in your Tunecore account, such as
withdraw funds and download your monthly sales reports.

    use WWW::Tunecore;

    my $foo = WWW::Tunecore->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=cut

use WWW::Sitebase::Navigator -Base;

field site_info => {
    home_page => 'http://www.tunecore.com', # URL of site's homepage
    account_field => 'person[email]', # Fieldname from the login form
    password_field => 'person[password]', # Password fieldname
    cache_dir => '.www-tunecore',
#    login_form_name => 'login', # The name of the login form.  OR
    login_form_no => 1, # The number of the login form (defaults to 1).
                        # 1 is the first form on the page.
    login_verify_re => 'my discography', # (optional)
        # Non-case-sensitive RE we should see once we're logged in
    not_logged_in_re => 'Login Unsuccessful',
        # If we log in and it fails (bad password, account suddenly
        # gets logged out), the page will have this RE on it.
        # Case insensitive.
    home_uri_re => 'discography',
        # _go_home uses this and the next two items to load
        # the home page.  You can provide these options or
        # just override the method.
        # First, this is matched against the current URL to see if we're
        # already on the home page.
    home_link_re => 'discography',
        # If we're not on the home page, this RE is 
        # used to find a link to the "Home" button on the current
        # page.
    home_url => 'http://www.tunecore.com/',
        # If the "Home" button link isn't found, this URL is
        # retreived.
    error_regexs => [
#        'An unexpected error has occurred',
#        'Site is temporarily down',
#       'We hired monkeys to program our site, please wait '.
#            'while they throw bananas at each other.'
    ],
        # error_regexs is optional.  If the site you're navigating
        # displays  error pages that do not return proper HTTP Status
        # codes (i.e. returns a 200 but displays an error), you can enter
        # REs here and any page that matches will be retried.
        # This is meant for IIS and ColdFusion-based sites that
        # periodically spew error messages that go away when tried again.
};

=head1 FUNCTIONS

=head2 withdraw_funds

Withdraw all funds to paypal using the email address you used to log in.

=cut

sub withdraw_funds {

    # Just because I'll probably want to make these options at some point...
    my $amount = '';
    my $paypal_email = $self->account_name;

    # Get to the withdraw page
    $self->get_page( 'https://www.tunecore.com/my_account/withdraw',
        re => 'Current Balance:' ) or return undef;
    
    # Get the current balance
    $self->current_page->content =~ /Current Balance: .*?\$([0-9]+\.[0-9]+) /smo;
    my $bal = $1;
    $self->debug( "Got balance page. Balance is $bal." );

    return $bal if ( $bal eq '0.00' );

    unless ( $bal ) {
        $self->error( 'Unable to read balance from withdrawal page' );
        return undef;
    }
    
    $amount = ( $amount || $bal );

    $self->debug( "Submitting withdrawl form 1" );
    # First page - enter the withdrawal amount and payment method
    $self->submit_form(
        form_no => 1,
        button => 'Withdraw Funds',
        fields_ref => {
            'withdrawal[payment_amount]' => "$amount",
            'withdrawal[payment_method]' => 'paypal'
        },
        re2 => 'Withdrawing: .*?'.">$bal"
    ) or return undef;

    $self->debug( "Submitting withdrawl form 2" );
    # Second page, confirm the amount and enter the email address
    $self->submit_form(
        form_no => 1,
        button => 'Withdraw Funds',
        fields_ref => {
            'withdrawal[paypal_address]' => $paypal_email
        }
    ) or return undef;

    # Make sure the withdrawl happened - it just returns us to the "my
    # account" page.
    
    $self->current_page->content =~ /Current Balance: .*?\$([0-9]+\.[0-9]+) /smo;
    unless ( $1 && ( $1 = "0.00" ) ) {
        $self->error( "Withdrawl failed while submitting final withdrawl form." );
        return undef;
    }
    
    # Return the amount withdrawn
    return ( $amount );
}

=head2 download_sales

Downloads the most recent sales report.
    
    use WWW::Tunecore
    
    my $tc = new WWW::Tunecore( $account, $password );
    
    my $sales = $tunecore->download_sales or die $tunecore->error;

    print $sales;

The sales are returned in CSV format, so you can save them to disk
or run them through a CSV parser. The first line is field headers.

The file returned is whatever TuneCore provides, unprocessed.
    
=cut

sub download_sales {

    $self->get_page( 'https://www.tunecore.com/my_account/exports',
        re => 'Download Accounting Files' ) or return undef;
    print "Got Download page\n";
    $self->follow_link( text_regex => qr/-sales-.*?\.csv/, re=>'TC Reporting Month' ) or return undef;
    
    return $self->current_page->content;
}

=head2 debug

Comment out the "return" to print debugging messages while working
on the module. If you're subclassing this module, you can print
debugging messages by calling $self->debug( "message"). Override
this method and comment out the return:

 sub debug {
     # return;  # Un-comment when done testing.
     my $message = shift;
     print $message."\n";
}

=cut

sub debug {

    return;
    my $message = shift;
    
    print $message."\n";

}
=head1 AUTHOR

Grant Grueninger, C<< <grantg at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-tunecore at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Tunecore>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Tunecore


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Tunecore>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Tunecore>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Tunecore>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Tunecore/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Grant Grueninger.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::Tunecore
