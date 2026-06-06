#!/usr/bin/env perl
# wpo_dce.pl — WPO-S1：读取 codegen_dump_wpo_callgraph_json 输出，统计 dead exports
# 用法：wpo_dce.pl graph.json [--expect-dead NAME ...]
# 退出：0 = OK；1 = 解析/断言失败
use strict;
use warnings;

my $path = shift @ARGV or die "usage: wpo_dce.pl graph.json [--expect-dead NAME ...] [--min-dead-pct N]\n";
my @expect_dead;
my $min_dead_pct;
while (@ARGV) {
    if ($ARGV[0] eq '--expect-dead') {
        shift @ARGV;
        push @expect_dead, shift @ARGV or die "missing name after --expect-dead\n";
        next;
    }
    if ($ARGV[0] eq '--min-dead-pct') {
        shift @ARGV;
        defined($min_dead_pct = shift @ARGV) or die "missing value after --min-dead-pct\n";
        next;
    }
    die "unknown arg: $ARGV[0]\n";
}

open my $fh, '<', $path or die "open $path: $!\n";
local $/;
my $json = <$fh>;
close $fh;

# 轻量解析：不依赖 JSON 模块
my @funcs;
while ($json =~ /\{\s*"id"\s*:\s*(\d+)\s*,\s*"module"\s*:\s*(\d+)\s*,\s*"name"\s*:\s*"((?:\\.|[^"\\])*)"\s*,\s*"extern"\s*:\s*(true|false)\s*,\s*"reachable"\s*:\s*(true|false)\s*\}/g) {
    my ($id, $mod, $name, $ext, $reach) = ($1, $2, $3, $4, $5);
    push @funcs, { id => 0+$id, module => 0+$mod, name => $name, extern => ($ext eq 'true'), reachable => ($reach eq 'true') };
}

die "wpo_dce: no functions parsed from $path\n" unless @funcs;

my $total = scalar @funcs;
my $reachable = grep { $_->{reachable} } @funcs;
my $dead = $total - $reachable;
my $pct = $total > 0 ? (100.0 * $dead / $total) : 0.0;

printf "wpo_dce: total=%d reachable=%d dead=%d (%.1f%%)\n", $total, $reachable, $dead, $pct;

my @dead_names = map { $_->{name} } grep { !$_->{reachable} && !$_->{extern} } @funcs;
if (@dead_names) {
    print "dead: ", join(", ", @dead_names), "\n";
}

for my $name (@expect_dead) {
    my $found = grep { $_ eq $name } @dead_names;
    die "wpo_dce FAIL: expected dead '$name' not in dead list\n" unless $found;
}

if (defined $min_dead_pct && $pct + 0.0001 < $min_dead_pct) {
    die sprintf("wpo_dce FAIL: dead %.1f%% < min %.1f%%\n", $pct, $min_dead_pct);
}

print "wpo_dce OK\n";
exit 0;
