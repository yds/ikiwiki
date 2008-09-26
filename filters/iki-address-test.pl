#!/usr/bin/perl

use lib "..";
use strict;
use Email::Filter;
use Convert::YText qw(decode_ytext);

my $prefix="-comment-";
my $message=Email::Filter->new();

$message->exit(0); # do not exit after delivery

my $to=$message->to;
if ($to =~ m/$prefix($Convert::YText::valid_rex)/){
    my $page=decode_ytext($1);

    print STDERR "page=$page";
}


