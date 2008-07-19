#!/usr/bin/perl

use Email::Filter;
use Convert::YText 'decode_ytext';

# we need at least version 2.54 of IkiWiki for the new config api
BEGIN { require IkiWiki; die unless ($IkiWiki::version >= 2.54) }

use IkiWiki::Setup;
use Getopt::Long;

my $config_file=undef;

GetOptions('config=s'=>\$config_file);

die "configuration file is mandatory" unless ($config_file);

my %config=IkiWiki::Setup::load($config_file);

my $maildir=$config{postal_maildir};
my $prefix=$config{postal_prefix};

$mail=Email::Filter->new(emergency => $maildir);

my $to=$mail->to;
if ($to =~ m/$prefix($Convert::YText::valid_rex)/){
    my $key=decode_ytext($1);
    print $key;
};

