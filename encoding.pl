use encoding "utf-8";

our @digits=split "","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-";

sub encode_num($){
    my $num=shift;
    my $str="";

    while ($num>0){
	$remainder=$num % 64;
	$num=$num >> 6;
	
	$str = $digits[$remainder].$str;
    }
    
    return $str;
}
sub strict_rfc2822_escape($){
# according to rfc 2822, the following non-alphanumerics are OK for
# the local part of an address: "!#$%&'*+-/=?^_`{|}~". On the other
# hand, a fairly common exim configuration, for example, blocks
# addresses having "@%!/|`#&?" in the local part.  '+' and '-' are
# pretty widely used to attach suffixes (although usually only one
# works on a given mail host). It seems ok to use '+-', since the first 
# marks the beginning of a suffix, and then is a regular character.
#  '.' also seems mostly permissable
    my $str=shift;

    # "=" we use as an escape, and '_' for space
    $str=~ s/([^a-zA-Z0-9+\-~. ])/"=".encode_num(ord($1))."="/ge;
    $str=~ s/ /_/g;

    return $str;
};

while(<>){
    chomp();
    print strict_rfc2822_escape($_);
}

