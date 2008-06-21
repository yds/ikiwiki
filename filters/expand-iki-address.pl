#!/usr/bin/perl

use Mail::Internet;
use Compress::LZF ;
use MIME::Base64::URLSafe; 

my $prefix="-comment-";
my $mail = Mail::Internet->new([<>]);

my $to = $mail->get('To:');

if ($to =~ m/$prefix([A-Za-z0-9\-_]+)\@/){
    my $key=$1;
    my $page=decompress(urlsafe_b64decode($key));
    $mail->replace('X-IkiWiki-Page:',$page);
}

$mail->print(\*STDOUT);


