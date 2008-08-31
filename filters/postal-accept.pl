#!/usr/bin/perl

# Take message on stdin, write to appropiate comment folder, 
# update wiki

use Email::LocalDelivery;
use Email::Filter;

use Convert::YText qw(decode_ytext encode_ytext);

# we need at least version 2.54 of IkiWiki for the new config api
BEGIN { require IkiWiki; die unless ($IkiWiki::version >= 2.54) }

use IkiWiki;
use IkiWiki::Setup;
use Getopt::Long;
use Carp;

my $folder_ext=".mbox";

my $config_file=undef;

GetOptions('config=s'=>\$config_file);

die "configuration file is mandatory" unless ($config_file);

%config=IkiWiki::defaultconfig();

IkiWiki::Setup::load($config_file);

$message=Email::Filter->new();

my $to=$message->to;
if ($to =~ m/$prefix($Convert::YText::valid_rex)/){
    my $page=decode_ytext($1);
    
    die("page ".$page." does not exist") if !($pagesources{$page});
    
    my $comments_folder=$page."/comments".$folder_ext;

    # write the message to the comment

    my ($delivered) = Email::LocalDeliver($config{srcdir}."/".$comments_folder);
    
    die ("delivery failed") if (!defined ($delivered));
    
    # update vcs, copied from Ikiwiki::Plugins::attachment
    
    if ($config{rcs}) {
	IkiWiki::rcs_add($delivered);
	IkiWiki::disable_commit_hook();
	IkiWiki::rcs_commit($delivered, gettext("postal delivery"),
			    IkiWiki::rcs_prepedit($delivered));
	IkiWiki::enable_commit_hook();
	IkiWiki::rcs_update();
    }

    
    # refresh wiki
    IkiWiki::refresh();
    IkiWiki::saveindex();
} 

