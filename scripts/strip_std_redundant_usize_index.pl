#!/usr/bin/env perl
# strip_std_redundant_usize_index.pl — 删除 std 中下标/实参语境冗余 `as usize`（保留指针算术 `ptr + i as usize`）。
use strict;
use warnings;

sub strip_file {
    my ($path) = @_;
    open my $fh, '<', $path or return;
    local $/; my $s = <$fh>; close $fh;
    my $orig = $s;
    # 下标：arr[i as usize] → arr[i]
    $s =~ s/\[([^\[\]]+?) as usize\]/[$1]/g;
    # 函数实参末位等：, len as usize) → , len)
    $s =~ s/, ([^,\(\)]+?) as usize\)/, $1)/g;
    # 函数实参中间：, len as usize, → , len,
    $s =~ s/, ([^,\(\)]+?) as usize,/, $1,/g;
    return if $s eq $orig;
    open my $out, '>', $path or die $!;
    print $out $s;
    close $out;
    print "stripped: $path\n";
}

for my $f (@ARGV) { strip_file($f); }
