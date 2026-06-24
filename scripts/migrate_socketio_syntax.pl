#!/usr/bin/env perl
# socketio.sx 语法迁移：++/-- → x = x ± 1；for step i++；字符字面量 → 数字 as u8。
use strict;
use warnings;

my $path = shift // 'std/socketio/socketio.sx';
open my $fh, '<', $path or die $!;
my $src = do { local $/; <$fh> };
close $fh;

# for (...; ...; var++) → var = var + 1
$src =~ s/for\s*\(([^;]*);([^;]*);(\s*)([A-Za-z_][A-Za-z0-9_]*)\+\+\s*\)/for ($1;$2;$3$4 = $4 + 1)/g;

# arr[idx++] = expr → 两行
$src =~ s{
  ([A-Za-z_][A-Za-z0-9_]*(?:\[[^\]]+\])*)
  \[([A-Za-z_][A-Za-z0-9_]*)\+\+\]
  \s*=\s*([^;]+);
}{
  $1\[$2\] = $3;\n    $2 = $2 + 1;
}gx;

# arr[++idx] 读 → 先增再读（简化：仅 sio_pkt[++i] 等常见形）
$src =~ s/\b([A-Za-z_][A-Za-z0-9_]*)\[\+\+([A-Za-z_][A-Za-z0-9_]*)\]/
  do { my ($a,$i)=($1,$2); "$i = $i + 1; $a\[$i\]" }/ge;

# arr[idx++] 读（out_event[ei++] = c）
$src =~ s{
  ([A-Za-z_][A-Za-z0-9_]*(?:\[[^\]]+\])*)
  \[([A-Za-z_][A-Za-z0-9_]*)\+\+\]
  (?!\s*=)
}{
  do { my ($a,$i)=($1,$2); my $t="${i}_bump"; "($a\[$i\], ($i = $i + 1))" } 
}ge;
# 上面三元组不好用，改简单替换：out_event[ei++] = c → 两行
$src =~ s{
  ^(\s*)([A-Za-z_][A-Za-z0-9_]*(?:\[[^\]]+\])*)\[([A-Za-z_][A-Za-z0-9_]*)\+\+\]\s*=\s*([^;]+);$
}{
  my ($ind,$a,$i,$v)=($1,$2,$3,$4);
  "${ind}${a}\[$i\] = $v;\n${ind}$i = $i + 1;"
}gmx;

# var++ 语句
$src =~ s/^(\s*)([A-Za-z_][A-Za-z0-9_]*)\+\+\s*;?$/$1$2 = $2 + 1;/gm;

# members[count++] = v
$src =~ s{
  ([A-Za-z_][A-Za-z0-9_]*(?:\[[^\]]+\])*)
  \[([A-Za-z_][A-Za-z0-9_]*)\+\+\]
  \s*=\s*([^;]+);
}{
  my ($a,$i,$v)=($1,$2,$3);
  "$a\[$i\] = $v;\n    $i = $i + 1;"
}gx;

# 常见字符字面量
my %char = (
  q{'/'} => '47', q{"'"} => '39', q{'\\''} => '39',
  q{'0'} => '48', q{'c'} => '99', q{','} => '44',
  q{'['} => '91', q{']'} => '93',
  q{'\r'} => '13', q{'\n'} => '10',
);
for my $lit (sort { length($b) <=> length($a) } keys %char) {
  my $n = $char{$lit};
  $src =~ s/\(\s*$lit\s+as\s+u8\s*\)/($n as u8)/g;
  $src =~ s/\(\(\s*$lit\s+as\s+u8\s*\)/(($n as u8)/g;
}

open my $out, '>', $path or die $!;
print {$out} $src;
close $out;
print "migrated $path\n";
