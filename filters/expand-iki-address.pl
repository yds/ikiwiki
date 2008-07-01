#!/usr/bin/perl

use Mail::Internet;
use Convert::YText 'decode_ytext';

my $prefix="-comment-";
my $mail = Mail::Internet->new([<>]);

my $to = $mail->get('To:');

if ($to =~ m/$prefix([A-Za-z0-9\.\+\=\-_]+)\@/){
    my $key=$1;
    my $page=decode_ytext($key);
    $mail->replace('X-IkiWiki-Page:',$page);
}

$mail->print(\*STDOUT);


