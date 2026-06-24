#!/usr/bin/env perl
# sync_lexer_gen_token_enum.pl — 将 lexer_gen.c 内 token_TokenKind 枚举与 include/token.h 对齐。
#
# 背景：lexer.sx -E 若用旧 seed 生成，枚举常缺 TOKEN_TRY/TOKEN_CATCH 等，导致
# parser_asm glue 用 token.h 的 TOKEN_* 比较时判错，用户程序 parse 0 funcs。
#
# 用法（compiler 目录）：perl scripts/sync_lexer_gen_token_enum.pl [lexer_gen.c]

use strict;
use warnings;

my $path = shift @ARGV // 'lexer_gen.c';
my $token_h = 'include/token.h';

open my $th, '<', $token_h or die "open $token_h: $!\n";
my @kinds;
while (<$th>) {
    push @kinds, $1 if /^\s+(TOKEN_[A-Z0-9_]+)\b/;
}
close $th;
die "no TOKEN_* in $token_h\n" unless @kinds;

my $enum = 'enum token_TokenKind { ' . join(', ', map { "token_TokenKind_$_" } @kinds) . ' };';

open my $in, '<', $path or die "open $path: $!\n";
my @lines = <$in>;
close $in;

my $pat = qr/^enum token_TokenKind \{.*\};$/;
my $found = 0;
for my $i (0 .. $#lines) {
    if ($lines[$i] =~ $pat) {
        $lines[$i] = $enum . "\n";
        $found = 1;
        last;
    }
}
die "token_TokenKind enum line not found in $path\n" unless $found;

open my $out, '>', $path or die "write $path: $!\n";
print {$out} @lines;
close $out;

print "sync_lexer_gen_token_enum: OK $path (" . scalar(@kinds) . " kinds)\n";
