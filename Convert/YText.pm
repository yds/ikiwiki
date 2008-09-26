package Convert::YText;

use strict;
use warnings;
use vars qw/$VERSION @ISA @EXPORT_OK/;
@ISA = 'Exporter';
@EXPORT_OK = qw( encode_ytext decode_ytext );

use encoding "utf-8";


$VERSION=0.1;

=head1 NAME

Convert::YText - Quotes strings suitably for rfc2822 local part

=head1 VERSION

Version 0.1 B<BETA>

=head1 SYNOPSIS

use Convert::YText qw(encode_ytext decode_ytext);

$encoded=encode_ytext($string);
$decoded=decode_ytext($encoded);

($decoded eq $string) || die "this should never happen!";


=head1 DESCRIPTION

Convert::YText converts strings to and from "YText", a format inspired
by xtext defined in RFC1894, the MIME base64 and quoted-printable
types (RFC 1394).  The main goal is encode a UTF8 string into something safe
for use as the local part in an internet email address  (RFC2822).

According to RFC 2822, the following non-alphanumerics are OK for the
local part of an address: "!#$%&'*+-/=?^_`{|}~". On the other hand, it
seems common in practice to block addresses having "%!/|`#&?" in the
local part.  The idea is to restrict ourselves to basic ASCII
alphanumerics, plus a small set of printable ASCII, namely "=_+-~.".
Spaces are replaced with "+", "/" with "~", the characters
"A-Za-z0-9_.-" encode as themselves, and everything else is written
"=USTR=" where USTR is the base64 (using "A-Za-z0-9_." as digits)
encoding of the unicode character code.

The characters '+' and '-' are pretty widely used to attach suffixes
(although usually only one works on a given mail host). It seems ok to
use '+-', since the first marks the beginning of a suffix, and then is
a regular character. The character '.' also seems mostly permissable.


=head1 METHODS

=cut

our $digit_string="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.";

our $must_base64=qr{[^a-zA-Z0-9\.\-\/_ ]};
our $digit_rex=qr{[$digit_string]+};
our $valid_rex=qr{[A-Za-z0-9.\=\_\~\-]+};

our @digits=split "",$digit_string;

sub encode_num($){
    my $num=shift;
    my $str="";

    while ($num>0){
	my $remainder=$num % 64;
	$num=$num >> 6;
	
	$str = $digits[$remainder].$str;
    }
    
    return $str;
}
sub decode_str($){
    my $str=shift;
    my @chars=split "",$str;
    my $num=0;

    while (scalar(@chars)>0){
	my $remainder=index $digit_string,$chars[0];
	
	# convert this to carp or something
	die if ($remainder <0);

	$num=$num << 6;
	$num+=$remainder;
	shift @chars;
    }
    
    return chr($num);
}
sub encode_ytext($){
    my $str=shift;

    # "=" we use as an escape, and '+' for space
    $str=~ s/($must_base64)/"=".encode_num(ord($1))."="/ge;
    
    $str=~ s|/|~|g;    
    $str=~ s/ /+/g;
    
    return $str;
};

sub decode_ytext($){
    my $str = shift;
    
    $str=~ s/\+/ /g;
    $str=~ s|~|/|g;
    $str=~ s/=($digit_rex)+=/ decode_str($1)/eg;
    return $str;
}

=head1 TODO

Finish doc. Write tests.

=head1 AUTHOR

David Bremner, E<lt>bremner@unb.caE<gt>

=head1 COPYRIGHT

Copyright (C) 2008 David Bremner.  All Rights Reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 CAVEAT

This module is currently in B<BETA> condition.  It should not be used
in a production environment, and is released with no warranty of any
kind whatsoever.

Corrections, suggestions, bugreports and tests are welcome!

=head1 SEE ALSO

L<MIME::Base64>, L<MIME::Decoder::Base64>, L<MIME::Decoder::QuotedPrint>.

=cut

1;
