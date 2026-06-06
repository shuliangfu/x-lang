#!/usr/bin/env perl
# wpo_const_spec.pl — WPO-S2：读取 call graph JSON v2，统计全常量实参 call site
# 用法：wpo_const_spec.pl graph.json [--expect-site FROM TO ARG ...]
# 退出：0 = OK；1 = 解析/断言失败
use strict;
use warnings;

my $path = shift @ARGV or die "usage: wpo_const_spec.pl graph.json [--expect-site FROM TO ARG ...]\n";
my @expect_sites;
while (@ARGV) {
    if ($ARGV[0] eq '--expect-site') {
        shift @ARGV;
        defined(my $from = shift @ARGV) or die "missing FROM after --expect-site\n";
        defined(my $to = shift @ARGV) or die "missing TO after --expect-site\n";
        my @args;
        while (@ARGV && $ARGV[0] !~ /^--/) {
            push @args, shift @ARGV;
        }
        push @expect_sites, { from => 0+$from, to => 0+$to, args => \@args };
        next;
    }
    die "unknown arg: $ARGV[0]\n";
}

open my $fh, '<', $path or die "open $path: $!\n";
local $/;
my $json = <$fh>;
close $fh;

my @sites;
while ($json =~ /\{\s*"from"\s*:\s*(\d+)\s*,\s*"to"\s*:\s*(\d+)\s*,\s*"all_const"\s*:\s*(true|false)\s*,\s*"args"\s*:\s*\[([^\]]*)\]\s*\}/g) {
    my ($from, $to, $all_const, $args_raw) = ($1, $2, $3, $4);
    my @args;
    for my $tok (split /\s*,\s*/, $args_raw) {
        next if $tok eq '';
        if ($tok eq 'null') {
            push @args, undef;
        } else {
            push @args, 0 + $tok;
        }
    }
    push @sites, {
        from => 0+$from,
        to => 0+$to,
        all_const => ($all_const eq 'true'),
        args => \@args,
    };
}

die "wpo_const_spec: no call_sites parsed from $path\n" unless @sites;

my $total = scalar @sites;
my $all_const_n = grep { $_->{all_const} } @sites;
printf "wpo_const_spec: call_sites=%d all_const=%d\n", $total, $all_const_n;

for my $exp (@expect_sites) {
    my $found = 0;
    for my $s (@sites) {
        next unless $s->{from} == $exp->{from} && $s->{to} == $exp->{to};
        next unless $s->{all_const};
        my @got = grep { defined $_ } @{ $s->{args} };
        my @want = @{ $exp->{args} };
        next unless @got == @want;
        my $ok = 1;
        for my $i (0 .. $#want) {
            if ($got[$i] != $want[$i]) { $ok = 0; last; }
        }
        if ($ok) { $found = 1; last; }
    }
    die sprintf("wpo_const_spec FAIL: no all_const site from=%d to=%d args=[%s]\n",
        $exp->{from}, $exp->{to}, join(',', @{ $exp->{args} })) unless $found;
}

print "wpo_const_spec OK\n";
exit 0;
