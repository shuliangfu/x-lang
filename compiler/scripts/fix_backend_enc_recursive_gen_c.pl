#!/usr/bin/env perl
# fix_backend_enc_recursive_gen_c.pl — 删除 asm_full_gen.c 中自递归 backend_enc_* / backend_arch_emit_* 桩
#
# backend.x 委托 C 分派后，shux-c -E 会生成 `return backend_*self(...)`；真实现由 dispatch TU 提供。

use strict;
use warnings;

my $path = $ARGV[0] or die "usage: $0 asm_full_gen.c\n";
open my $fh, '<', $path or die "$path: $!";
my $c = do { local $/; <$fh> };
close $fh;

my $removed = 0;
while ($c =~ s/int32_t\s+(backend_enc_\w+_arch|backend_arch_emit_\w+)\s*\([^{]+\)\s*\{\s*return\s+\1\s*\([^;]*\);\s*\}//s) {
  $removed++;
}

open my $out, '>', $path or die "$path: $!";
print $out $c;
close $out;
print STDERR "fix_backend_enc_recursive_gen_c: removed $removed self-recursive backend dispatch stubs\n" if $removed;
