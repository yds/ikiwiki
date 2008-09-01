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

# A footer with comment information will be added to every rendered page
# a file `comments.html' or 'comments.mdwn' is found (using the
# same rules as for the sidebar plugin).

# You'll need a full wiki-rebuild if your comment header file is changed.
#
# You can use wiki links in `comments.html'.

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
    my $page = IkiWiki::pagetitle($params{page});
    my $destpage = $params{destpage};

    my $template = $params{template};

    if ($template->query (name => "comments") &&
	! defined $template->param ('comments'))
    {
	debug("adding comments to ".$page);
	my $key = encode_ytext($page);
	debug("using key ".$key);


	my $content;
	my $comment_page = bestlink ($page, "_comments") || return;
	my $comment_file = $pagesources{$comment_page} || return;

	$content = readfile (srcfile ($comment_file));
	if (defined $content && length $content)
	{
	    $content =~ s/%%KEY%%/$key/g;
	    $content =~ s/%%PAGE%%/$page/g;

	    debug("comment blurb: ". $content);

    $template->param(POSTAL_COMMENTS=>1,
		     POSTAL_PREFIX=>$config{postal_prefix},
		     POSTAL_KEY=>$key,
		     POSTAL_HOST=>$config{postal_host},
		     POSTAL_COMMENT_LINK=>$comment_link	);
}


1;
