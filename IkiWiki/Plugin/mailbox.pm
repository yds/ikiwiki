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
	hook(type => "getopt", id => "mailbox",  call => \&getopt);
	hook(type => "checkconfig", id => "mailbox", call => \&checkconfig);
	hook(type => "needsbuild", id => "mailbox", call => \&needsbuild);
	hook(type => "preprocess", id => "mailbox", call => \&preprocess);
	hook(type => "filter", id => "mailbox", call => \&filter);
	hook(type => "linkify", id => "mailbox", call => \&linkify);
	hook(type => "scan", id => "mailbox", call => \&scan);
	hook(type => "htmlize", id => "mailbox", call => \&htmlize);
	hook(type => "sanitize", id => "mailbox", call => \&sanitize);
	hook(type => "postscan", id => "mailbox", call => \&postscan);
	hook(type => "format", id => "mailbox", call => \&format);
	hook(type => "pagetemplate", id => "mailbox", call => \&pagetemplate);
	hook(type => "templatefile", id => "mailbox", call => \&templatefile);
	hook(type => "delete", id => "mailbox", call => \&delete);
	hook(type => "change", id => "mailbox", call => \&change);
	hook(type => "cgi", id => "mailbox", call => \&cgi);
	hook(type => "auth", id => "mailbox", call => \&auth);
	hook(type => "sessioncgi", id => "mailbox", call => \&sessioncgi);
	hook(type => "canedit", id => "mailbox", call => \&canedit);
	hook(type => "editcontent", id => "mailbox", call => \&editcontent);
	hook(type => "formbuilder_setup", id => "mailbox", call => \&formbuilder_setup);
	hook(type => "formbuilder", id => "mailbox", call => \&formbuilder);
	hook(type => "savestate", id => "mailbox", call => \&savestate);
} # }}}

sub getopt () { #{{{
	debug("mailbox plugin getopt");
} #}}}

sub checkconfig () { #{{{
	debug("mailbox plugin checkconfig");
} #}}}

sub needsbuild () { #{{{
	debug("mailbox plugin needsbuild");
} #}}}

sub preprocess (@) { #{{{
	my %params=@_;
	
	my $page=$params{page};
	my $type=$params{type} || 'maildir';

	print STDERR join("\n",%params);

	error("path is mandatory") if (!defined($params{path}));

	# note, mbox is not a directory
	my $dir=bestdir($page,$params{path}) || 
	    error("could not find ".$params{path});

	$dir = $config{srcdir} ."/" . $dir;

	return  format_mailbox(path=>$dir);

} # }}}

sub filter (@) { #{{{
	my %params=@_;
	
	
#	debug("mailbox plugin: path=".$params{path});

	return $params{content};
} # }}}

sub linkify (@) { #{{{
	my %params=@_;
	
	debug("mailbox plugin running as linkify");

	return $params{content};
} # }}}

sub scan (@) { #{{{a
	my %params=@_;

	debug("mailbox plugin running as scan");
} # }}}

sub htmlize (@) { #{{{
	my %params=@_;

	debug("mailbox plugin running as htmlize");

	return $params{content};
} # }}}

sub sanitize (@) { #{{{
	my %params=@_;
	
	debug("mailbox plugin running as a sanitizer");

	return $params{content};
} # }}}

sub postscan (@) { #{{{
	my %params=@_;
	
	debug("mailbox plugin running as postscan");
} # }}}

sub format (@) { #{{{
	my %params=@_;
	
	debug("mailbox plugin running as a formatter");

	return $params{content};
} # }}}

sub pagetemplate (@) { #{{{
	my %params=@_;
	my $page=$params{page};
	my $template=$params{template};
	
	debug("mailbox plugin running as a pagetemplate hook");
} # }}}

sub templatefile (@) { #{{{
	my %params=@_;
	my $page=$params{page};
	
	debug("mailbox plugin running as a templatefile hook");
} # }}}

sub delete (@) { #{{{
	my @files=@_;

	debug("mailbox plugin told that files were deleted: @files");
} #}}}

sub change (@) { #{{{
	my @files=@_;

	debug("mailbox plugin told that changed files were rendered: @files");
} #}}}

sub cgi ($) { #{{{
	my $cgi=shift;

	debug("mailbox plugin running in cgi");
} #}}}

sub auth ($$) { #{{{
	my $cgi=shift;
	my $session=shift;

	debug("mailbox plugin running in auth");
} #}}}

sub sessionncgi ($$) { #{{{
	my $cgi=shift;
	my $session=shift;

	debug("mailbox plugin running in sessioncgi");
} #}}}

sub canedit ($$$) { #{{{
	my $page=shift;
	my $cgi=shift;
	my $session=shift;

	debug("mailbox plugin running in canedit");
} #}}}

sub editcontent ($$$) { #{{{
	my %params=@_;

	debug("mailbox plugin running in editcontent");

	return $params{content};
} #}}}

sub formbuilder_setup (@) { #{{{
	my %params=@_;
	
	debug("mailbox plugin running in formbuilder_setup");
} # }}}

sub formbuilder (@) { #{{{
	my %params=@_;
	
	debug("mailbox plugin running in formbuilder");
} # }}}

sub savestate () { #{{{
	debug("mailbox plugin running in savestate");
} #}}}

### The guts of the plugin
### parameters 
sub format_mailbox(@){
    my %params=@_;
    my $path=$params{path} || error("path parameter mandatory");
    my $header_list=$params{headers} || "subject,from";

    my $folder=Email::Folder->new($path) || error("mailbox could not be opened");
    return join "\n", map { format(message=>$_) } $folder->messages;

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



1
