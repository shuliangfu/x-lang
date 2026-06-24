#!/usr/bin/env perl
# strip_invalid_u_suffix.pl — 移除非法整型字面量 u 后缀（4096u → 4096）。
use strict;
use warnings;
use File::Find;

my @roots = @ARGV ? @ARGV : ('std');

sub fix_text {
    my ($s) = @_;
    my $orig = $s;
    $s =~ s/\b(0x[0-9a-fA-F]+)u\b/$1/g;
    $s =~ s/\b(\d+)u\b/$1/g;
    return ($s, $s ne $orig);
}

sub process_file {
    my ($path) = @_;
    return unless $path =~ /\.sx\z/;
    open my $fh, '<', $path or return;
    local $/; my $t = <$fh>; close $fh;
    my ($new, $c) = fix_text($t);
    return unless $c;
    open my $out, '>', $path or die $!;
    print $out $new;
    close $out;
    print "fixed u-suffix: $path\n";
}

find({ wanted => sub {
    return if -d $_;
    process_file($File::Find::name) unless $_ =~ m/^\./;
}, no_chdir => 1 }, @roots);
