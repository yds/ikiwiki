#!/usr/bin/perl
# based on Ikiwiki skeleton plugin.

# Copyright (c) 2008 David Bremner <bremner@unb.ca>
# This file is distributed under the Artistic License/GPL2+

package IkiWiki::Plugin::mailbox;

use warnings;
use strict;
use IkiWiki 2.00;
use Email::Folder;

sub import { #{{{
	hook(type => "preprocess", id => "mailbox", call => \&preprocess);
} # }}}

sub preprocess (@) { #{{{
	my %params=@_;
	
	my $page=$params{page};
	my $type=$params{type} || 'maildir';

	my $path=$params{path} ||  error gettext("missing parameter") . " path";

	# note, mbox is not a directory, needs to be special cased
	my $dir=bestdir($page,$params{path}) || 
	    error("could not find ".$params{path});

	$params{path} = $config{srcdir} ."/" . $dir;

	return  format_mailbox(path=>$dir,%params);

} # }}}


### The guts of the plugin
### parameters 
sub format_mailbox(@){
    my %params=@_;
    my $path=$params{path} || error("path parameter mandatory");
    my $header_list=$params{headers} || "subject,from";

    my $folder=Email::Folder->new($path) || error("mailbox could not be opened");
    return join "\n", map { format_message(message=>$_) } $folder->messages;

}

sub make_pair($$){
    my $message=shift;
    my $name=shift;
    my $val=$message->header($_);
    my $hash={'HEADERNAME'=>$name,'VAL'=>$val};
    return $hash;
}
sub format_message(@){
    my  %params=@_;

    my $message=$params{message} || 
	error gettext("missing parameter"). "message";

    my $template= 
	template("email.tmpl") || error gettext("missing template");
    
    my @headers=map { make_pair($message,$_) } 
	$message->header_names;

    $template->param(HEADERS=>[@headers]);

    $template->param(body=>$message->body);

    my $output=$template->output();
    return $output;
}

### Utilities

# From Arpit Jain
# http://ikiwiki.info/todo/Bestdir_along_with_bestlink_in_IkiWiki.pm/
# need to clarify license
sub bestdir ($$) { #{{{
    my $page=shift;
       my $link=shift;
       my $cwd=$page;

       if ($link=~s/^\/+//) {
               $cwd="";
       }

       do {
               my $l=$cwd;
               $l.="/" if length $l;
               $l.=$link;
               if (-d "$config{srcdir}/$l") {
                       return $l;
               }
       } while $cwd=~s!/?[^/]+$!!;

       if (length $config{userdir}) {
               my $l = "$config{userdir}/".lc($link);

               if (-d $l) {
                       return $l;
               }
       }

       return "";
} #}}}



sub fill_template(@){
    my  %params=@_;
    my $template = $params{template} || error gettext("missing parameter");

    $params{basename}=IkiWiki::basename($params{page});

    foreach my $param (keys %params) {
	if ($template->query(name => $param)) {
	    $template->param($param =>
			     IkiWiki::htmlize($params{page}, $params{destpage},
					      pagetype($pagesources{$params{page}}),
					      $params{$param}));
	}
	if ($template->query(name => "raw_$param")) {
	    $template->param("raw_$param" => $params{$param});
	}
    }
}

1
