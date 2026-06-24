#!/usr/bin/env perl
# 为 socketio.sx 中「if (cond)\n    stmt;」补花括号，满足 .sx parser 要求。
use strict;
use warnings;

my $path = shift // 'std/socketio/socketio.sx';
open my $fh, '<', $path or die $!;
my @lines = <$fh>;
close $fh;

my @out;
my $i = 0;
while ($i < @lines) {
  my $line = $lines[$i];
  if ($line =~ /^(\s*)if\s*\(/ && $line !~ /\{\s*$/) {
    my $indent = $1;
    my $j = $i + 1;
    if ($j < @lines && $lines[$j] =~ /^(\s+)(\S.*)/ && length($1) > length($indent)) {
      my ($body_indent, $body) = ($1, $2);
      push @out, $line;
      push @out, "${body_indent}{\n";
      push @out, "${body_indent}  $body\n";
      push @out, "${body_indent}}\n";
      $i = $j + 1;
      next;
    }
  }
  push @out, $line;
  $i++;
}

open my $out_fh, '>', $path or die $!;
print {$out_fh} @out;
close $out_fh;
print "fixed $path\n";
