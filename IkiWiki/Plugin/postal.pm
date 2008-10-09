# A plugin for ikiwiki to implement adding a footer with a comment URL
# based on a template file and a key representing the current page

# Copyright © 2007 Thomas Schwinge <tschwinge@gnu.org>
# Copyright © 2008 David Bremner <bremner@unb.ca>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

package IkiWiki::Plugin::postal;

use warnings;
use strict;
use IkiWiki 2.00;
use Convert::YText 'encode_ytext';


sub import
{
    hook (type => "pagetemplate", id => "postal", call => \&pagetemplate);
}

sub pagetemplate (@)
{
    my %params = @_;
    my $page = $params{page};
    my $destpage = $params{destpage};
    my $template = $params{template};

    my $key = encode_ytext($page);

    my $pagespec=$config{postal_pagespec} || "!*/comments";

    if (!pagespec_match($page,$pagespec)){
	return;
    }

    my $subpage_name=$config{postal_pagename} || "comments";

    my $comment_page=$page . "/" . $subpage_name;
    add_depends($params{page},$comment_page);


    my $about_link=undef;
    my $about_page=bestlink($page,"about_comments");

    if ($about_page){
	$about_link=htmllink($page,$destpage,$about_page,
			       linktext=>gettext("About Comments"));
    }	
    
    my $comment_link=undef;
#    debug("pagesources{$comment_page}=$pagesources{$comment_page}\n");
    if (exists $pagesources{$comment_page}){
#	debug("looking for htmlink $page $destpage $comment_page\n");
	$comment_link=htmllink($page,$destpage,$comment_page,
			       linktext=>gettext("Read Comments"));
    }

    $template->param(POSTAL_DIV=>1,
		     POSTAL_PREFIX=>$config{postal_prefix},
		     POSTAL_KEY=>$key,
		     POSTAL_HOST=>$config{postal_host},
		     defined($about_link) ? (POSTAL_ABOUT_LINK=>$about_link):(),
		     defined($comment_link) ? (POSTAL_COMMENT_LINK=>$comment_link) :());
}


1;
