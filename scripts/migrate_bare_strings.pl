#!/usr/bin/env perl
# 将 .sx 中裸 "..." 字面量（memcmp/实参/let 初值）迁为顶层 const u8[N] + &PREFIX_LIT_*[0]。
use strict;
use warnings;

my $prefix = shift @ARGV or die "usage: $0 PREFIX file.sx\n";
my $path = shift @ARGV or die "usage: $0 PREFIX file.sx\n";

sub lit_name {
    my ($s) = @_;
    my $n = $s;
    $n =~ s/[^a-zA-Z0-9]+/_/g;
    $n =~ s/^_+|_+$//g;
    $n = uc($n);
    $n = "N$n" if $n =~ /^[0-9]/;
    $n = "EMPTY" if $n eq "";
    my $h = 0;
    $h = ($h * 31 + ord($_)) % 10000 for split //, $s;
    return "${prefix}_LIT_${n}_$h";
}

sub unescape {
    my ($raw) = @_;
    my $s = $raw;
    $s =~ s/\\n/\n/g;
    $s =~ s/\\t/\t/g;
    $s =~ s/\\"/"/g;
    $s =~ s/\\\\/\\/g;
    return $s;
}

open my $fh, '<', $path or die "open: $!\n";
my $src = do { local $/; <$fh> };
close $fh;

my %map;
while ($src =~ /"((?:\\.|[^"\\])*)"/g) {
    my $raw = $1;
    next if $raw =~ /^\*\//;
    $map{$raw} = lit_name(unescape($raw)) unless exists $map{$raw};
}

exit 0 unless %map;

my $marker = "/** C 字符串常量（解析器不支持 \"...\" as *u8）。 */";
my @decls;
for my $raw (sort keys %map) {
    my $s = unescape($raw);
    my @b = map { ord($_) } split //, $s;
    push @b, 0;
    my $name = $map{$raw};
    push @decls, "const $name: u8[" . scalar(@b) . "] = [" . join(", ", @b) . "];";
}

unless ($src =~ /\Q$marker\E/) {
    die "marker missing in $path\n";
}
for my $line (@decls) {
    $line =~ /^const (\S+):/;
    my $cname = $1;
    next if $src =~ /\b$cname\b/;
    $src =~ s/(\Q$marker\E\n)/$1$line\n/;
}

for my $raw (keys %map) {
    my $name = $map{$raw};
    my $pat = quotemeta("\"$raw\"");
    $src =~ s/$pat/&${name}[0]/g;
}

open my $out, '>', $path or die "write: $!\n";
print $out $src;
close $out;
print "migrated ", scalar(keys %map), " bare strings in $path\n";
