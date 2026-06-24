#!/usr/bin/env perl
# migrate_string_as_u8.pl — 将 "foo" as *u8 替换为 &PREFIX_LIT_*[0]
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
    return "${prefix}_LIT_$n";
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
while ($src =~ /"((?:\\.|[^"\\])*)"\s+as\s+\*u8/g) {
    my $raw = $1;
    $map{$raw} = lit_name(unescape($raw)) unless exists $map{$raw};
}

exit 0 unless %map;

my @decls;
for my $raw (sort keys %map) {
    my $s = unescape($raw);
    my @b = map { ord($_) } split //, $s;
    push @b, 0;
    my $name = $map{$raw};
    push @decls, "const $name: u8[" . scalar(@b) . "] = [" . join(", ", @b) . "];";
}

my $marker = "/** C 字符串常量（解析器不支持 \"...\" as *u8）。 */";
my $block = "$marker\n" . join("\n", @decls) . "\n\n";

unless ($src =~ /\Q$marker\E/) {
    if ($src =~ /^(const CFG_LIT_OFF:.*?;\n)/m) {
        $src =~ s/^(const CFG_LIT_OFF:.*?;\n)/$1$block/m;
    } elsif ($src =~ /^(const SCH_SCHEMA_MEM_SIZE:.*?;\n\n)/m) {
        $src =~ s/^(const SCH_SCHEMA_MEM_SIZE:.*?;\n\n)/$1$block/m;
    } elsif ($src =~ /^((?:const\s+\S+.*?;\n)+)(\n(?:allow\(padding\)\s+struct|struct|function|extern)\s)/m) {
        $src =~ s/^((?:const\s+\S+.*?;\n)+)(\n(?:allow\(padding\)\s+struct|struct|function|extern)\s)/$1\n$block$2/m;
    } elsif ($src =~ /^((?:const\s+\S+.*?;\n)+)(\n\/\*\*|\n\n)/m) {
        $src =~ s/^((?:const\s+\S+.*?;\n)+)(\n)/$1\n$block/m;
    } else {
        die "no insertion point in $path\n";
    }
} else {
    for my $line (@decls) {
        $line =~ /^const (\S+):/;
        my $cname = $1;
        next if $src =~ /\b$cname\b/;
        $src =~ s/(\Q$marker\E\n)/$1$line\n/;
    }
}

for my $raw (keys %map) {
    my $name = $map{$raw};
    my $pat = quotemeta("\"$raw\" as *u8");
    $src =~ s/$pat/&${name}[0]/g;
}

open my $out, '>', $path or die "write: $!\n";
print $out $src;
close $out;
print "migrated ", scalar(keys %map), " strings in $path\n";
