use strict;
use warnings;
use Test::More tests => 6;

BEGIN {
    use_ok('WWW::Shorten::VGd');
};

my $longurl  = q{http://maps.google.co.uk/maps?f=q&source=s_q&hl=en&geocode=&q=louth&sll=53.800651,-4.064941&sspn=33.219383,38.803711&ie=UTF8&hq=&hnear=Louth,+United+Kingdom&ll=53.370272,-0.004034&spn=0.064883,0.075788&z=14};
my $return = makeashorterlink($longurl);
my ($code) = $return =~ /([\w_]+)$/;
my $prefix = 'http://v.gd/';
is ( makeashorterlink($longurl), $prefix.$code, 'make it shorter');
is ( makealongerlink($prefix . $code), $longurl, 'make it longer');
is ( makealongerlink($code), $longurl, 'make it longer by Id',);

{
    eval { &makeashorterlink() };
    ok($@, 'makeashorterlink fails with no args');
}
{
    eval { &makealongerlink() };
    ok($@, 'makealongerlink fails with no args');
}
