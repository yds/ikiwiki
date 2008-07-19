#!/usr/bin/perl

use Email::Filter;
use Convert::YText qw(decode_ytext encode_ytext);

# we need at least version 2.54 of IkiWiki for the new config api
BEGIN { require IkiWiki; die unless ($IkiWiki::version >= 2.54) }

use IkiWiki::Setup;
use Getopt::Long;

my $config_file=undef;

GetOptions('config=s'=>\$config_file);

die "configuration file is mandatory" unless ($config_file);

my %config=IkiWiki::Setup::load($config_file);

my $maildir=$config{postal_maildir} || die "maildir not set";

my $prefix=$config{postal_prefix} || die "prefix not set";

$mail=Email::Filter->new(emergency => $maildir);

my $to=$mail->to;
if ($to =~ m/$prefix($Convert::YText::valid_rex)/){
    my $key=decode_ytext($1);

    $mail->simple->header_set('X-IkiPostal-Key',$key);

    # need to somehow escape the names. Here we use the fact that YText 
    # cannot have @ signs.
    my @path=split(qr{/},$key);
    map { $_=encode_ytext($_); s/\./@/g } @path;
    
    my $mailbox=$maildir . "/.".join(".",@path)."/" ;
    
    $mail->accept($mailbox);


};


 
