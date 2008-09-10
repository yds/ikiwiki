#!/usr/bin/perl

# Take message on stdin, write to appropiate comment folder, 
# update wiki
use strict;
use Email::LocalDelivery;
use Email::Filter;
use Data::Dumper;

use Convert::YText qw(decode_ytext);

# we need at least version 2.54 of IkiWiki for the new config api
BEGIN { require IkiWiki; die unless ($IkiWiki::version >= 2.63) }
use IkiWiki;
use IkiWiki::Setup;
use Getopt::Long;
use Carp;

my $folder_ext=".mbox";

my $config_file=undef;

GetOptions('config=s'=>\$config_file);

die "configuration file is mandatory" unless ($config_file);

%IkiWiki::config=IkiWiki::defaultconfig();
IkiWiki::Setup::load($config_file);

IkiWiki::loadplugins();
IkiWiki::checkconfig();


my $prefix=$config{postal_prefix} || die "prefix not set";

my $message=Email::Filter->new();

$message->exit(0); # do not exit after delivery

my $to=$message->to;
if ($to =~ m/$prefix($Convert::YText::valid_rex)/){
    my $page=decode_ytext($1);

    IkiWiki::loadindex();

# hmm, not sure why pagesource is indexed by page.ext, but it is awkward here    
#    die("page ".$page." does not exist") if (!exists $IkiWiki::pagesources{$page});

    chdir $config{srcdir} || die ("chdir $config{srcdir}: $!");

    my $comments_folder=$page."/comments".$folder_ext;

    # write the message to the comment
    
    $message->accept($comments_folder) || die("delivery failed");
    
    debug("delivered to $comments_folder\n");
    # update vcs, copied from Ikiwiki::Plugins::attachment
    
    if ($config{rcs}) {
	IkiWiki::rcs_add($comments_folder);
	IkiWiki::disable_commit_hook();
	IkiWiki::rcs_commit($comments_folder, gettext("postal delivery"),
			    IkiWiki::rcs_prepedit($comments_folder));
	IkiWiki::enable_commit_hook();
	IkiWiki::rcs_update();
    }

    
    # refresh wiki
    IkiWiki::refresh();
    IkiWiki::saveindex();
} 

