#!/usr/bin/perl

use Email::Folder;
use Email::LocalDelivery;

use Convert::YText qw(decode_ytext encode_ytext);

# we need at least version 2.54 of IkiWiki for the new config api
BEGIN { require IkiWiki; die unless ($IkiWiki::version >= 2.54) }

use IkiWiki::Setup;
use Getopt::Long;
use Carp;

my $config_file=undef;

GetOptions('config=s'=>\$config_file);

die "configuration file is mandatory" unless ($config_file);

my %config=IkiWiki::Setup::load($config_file);

my $queue=$config{queue} || croak("missing queue location");

my $folder=Email::Folder->new($path,reader=>'Email::Folder::maildir') 
    || croak("mailbox could not be opened");

for my $messages  ($folder->messages){

    my $to=$message->to;
    if ($to =~ m/$prefix($Convert::YText::valid_rex)/){
	my $page=decode_ytext($1);
	
	# sanity check the page path
	
	# check if comments folder exists, create if needed

	# write the message to the folder

	$msg_file= $comment_folder->write($message);

	# update vcs, copied from Ikiwiki::Plugins::attachment
    
	if ($config{rcs}) {
	    IkiWiki::rcs_add($filename);
	    IkiWiki::disable_commit_hook();
	    IkiWiki::rcs_commit($filename, gettext("attachment upload"),
				IkiWiki::rcs_prepedit($filename),
				$session->param("name"), $ENV{REMOTE_ADDR});
	    IkiWiki::enable_commit_hook();
	    IkiWiki::rcs_update();
	}

	# tag for deletion
	
	push (@must_die, $message->message-id);
	
	$folder->delete($message);

    }

    
    # refresh wiki
    IkiWiki::refresh();
    IkiWiki::saveindex();
 
    # make regex for message-id

    # called delete_message from Email::Delete
}

