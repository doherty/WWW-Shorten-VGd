use strict;
use warnings;
use 5.006;

package WWW::Shorten::VGd;
# ABSTRACT: shorten (or lengthen) URLs with http://v.gd

=head1 SYNOPSIS

    use WWW::Shorten::VGd;
    use WWW::Shorten 'VGd';

    my $url = q{http://averylong.link/wow?thats=really&really=long};
    my $short_url = makeashorterlink($url);
    my $long_url  = makealongerlink($short_url); # eq $url

=head1 DESCRIPTION

A Perl interface to the web site L<http://v.gd>. v.gd simply maintains
a database of long URLs, each of which has a unique identifier. By default,
this URL shortening service will show you a preview page before redirecting
you. This can be turned off by setting a cookie at L<http://v.gd/previews.php>.

=cut

use base qw( WWW::Shorten::generic Exporter );
our @EXPORT = qw( makeashorterlink makealongerlink );
use Carp;
use HTML::Entities;

=head1 Functions

=head2 makeashorterlink

The function C<makeashorterlink> will call the v.gd web site passing
it your long URL and will return the shortened link.

=cut

sub makeashorterlink {
    my $url = shift or croak 'No URL passed to makeashorterlink';
    my $ua = __PACKAGE__->ua();
    my $response = $ua->post('http://v.gd/create.php', [
        url => $url,
        source => 'PerlAPI-' . (defined __PACKAGE__->VERSION ? __PACKAGE__->VERSION : 'dev'),
        format => 'simple',
    ]);
    return unless $response->is_success;
    my $shorturl = $response->{_content};
    return if $shorturl =~ m/Error/;
    if ($response->content =~ m{(\Qhttp://v.gd/\E[\w_]+)}) {
        return $1;
    }
    return;
}

=head2 makealongerlink

The function C<makealongerlink> does the reverse. C<makealongerlink>
will accept as an argument either the full TinyURL URL or just the
TinyURL identifier.

If anything goes wrong, then either function will return C<undef>.

=cut

sub makealongerlink {
    my $url = shift or croak 'No v.gd key/URL passed to makealongerlink';
    my $ua = __PACKAGE__->ua();
    
    $url =~ s{\Qhttp://v.gd/\E}{}i;
    my $response = $ua->post('http://v.gd/forward.php', [
        shorturl => $url,
        source => 'PerlAPI-' . (defined __PACKAGE__->VERSION ? __PACKAGE__->VERSION : 'dev'),
        format   => 'simple',
    ]);
    # use Data::Dumper;
    # print STDERR Dumper $response;
    return unless $response->is_success;

    my $longurl = $response->{_content};
    return decode_entities($longurl);
}

1;

__END__
