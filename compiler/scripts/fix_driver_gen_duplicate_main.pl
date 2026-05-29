#!/usr/bin/env perl
# shu-c -E-extern 生成 driver_gen.c 时可能重复 main_run_compiler_c（后者自递归）。
# 保留转调 impl 的版本，删掉多余的自调用副本。
use strict;
use warnings;

my $path = $ARGV[0] or die "usage: fix_driver_gen_duplicate_main.pl driver_gen.c\n";
open my $fh, '+<', $path or die "open $path: $!\n";
local $/;
my $src = <$fh>;
my $orig = $src;

$src =~ s/\nint32_t main_run_compiler_c\(int32_t argc, uint8_t \* argv\) \{\n  return main_run_compiler_c\(argc, argv\);\n\}//s;

# main.su 调用 preprocess_su_buf；-E-extern 导出 preprocess_preprocess_su_buf（由 preprocess_su.o 提供）。
if (index($src, 'preprocess_preprocess_su_buf') >= 0 && index($src, '#define preprocess_su_buf') < 0) {
  $src =~ s/(extern int32_t preprocess_preprocess_su_buf[^\n]*\n)/$1#define preprocess_su_buf preprocess_preprocess_su_buf\n/s
    or warn "fix_driver_gen: preprocess_su_buf alias anchor not found\n";
}

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;
