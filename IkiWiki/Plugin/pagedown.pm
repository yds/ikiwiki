#!/usr/bin/perl
package IkiWiki::Plugin::pagedown;

use warnings;
use strict;
use IkiWiki 3.00;

sub import {
	add_underlay("pagedown");
	hook(type => "getsetup", id => "pagedown", call => \&getsetup);
	hook(type => "formbuilder_setup", id => "pagedown", call => \&formbuilder_setup);
}

sub getsetup () {
	return
		plugin => {
			safe => 1,
			rebuild => 0,
			section => "web",
		},
}

sub formbuilder_setup (@) {
	my %params=@_;
	my $form=$params{form};

	return if ! defined $form->field("do");
	
	return unless	$form->field("do") eq "edit" ||
			$form->field("do") eq "create" ||
			$form->field("do") eq "comment";

	my $helplink=urlto("ikiwiki/formatting", $params{page});
	my $wmd_preview=<<"END";
<div id="wmd-preview" class="wmd-preview"></div>
END
	my $wmd_button_bar=<<"END";
<div id="wmd-button-bar"></div>
END
	my $wmd_editor=<<"END";
<script type="text/javascript" charset="utf-8">
(function () {
	var converter = Markdown.getSanitizingConverter();
	converter.hooks.chain("preConversion", function (text) {
		text = text.replace(/\\[\\[!meta\\s+\\w+="([^"]*)"]]/gi, "");
		text = text.replace(/\\[\\[!tag\\s+([^\\]]+)]]/gi, "");
		return text;
	});
	var help = function () { window.open("$helplink", "Markdown Syntax Documentation"); }
	var editor = new Markdown.Editor(converter, '', { handler: help });
	editor.run();
})();
</script>
END
	$form->tmpl_param("javascript", include_javascript($params{page}));
	$form->tmpl_param("wmd_preview", $wmd_preview);
	$form->tmpl_param("wmd_button_bar", $wmd_button_bar);
	$form->tmpl_param("wmd_editor", $wmd_editor);
}

sub include_javascript ($) {
	my $from=shift;

	my $converter=urlto("pagedown/Markdown.Converter.js", $from);
	my $sanitizer=urlto("pagedown/Markdown.Sanitizer.js", $from);
	my $editor=urlto("pagedown/Markdown.Editor.js", $from);
	return <<"END"
<script type="text/javascript" charset="utf-8" src="$converter"></script>
<script type="text/javascript" charset="utf-8" src="$sanitizer"></script>
<script type="text/javascript" charset="utf-8" src="$editor"></script>
END
}

1
