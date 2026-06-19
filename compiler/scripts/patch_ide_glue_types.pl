#!/usr/bin/env perl
# patch_ide_glue_types.pl — 将 extract 快照与当前 ast.sx 布局对齐（M-3 region 等）。
# 用法：perl scripts/patch_ide_glue_types.pl ide/pipeline_glue_types.inc
use strict;
use warnings;

my $path = shift @ARGV or die "usage: $0 pipeline_glue_types.inc\n";
open my $fh, '+<', $path or die "open $path: $!\n";
local $/; my $s = <$fh>;

# M-3：Block 增加 region 侧车池字段（与 ast.sx Block 一致）。
$s =~ s/(num_if_stmts;\s*)int32_t defer_base/$1int32_t region_base; int32_t num_regions; int32_t defer_base/s
  unless $s =~ /region_base/;

# M-3/M-4：TypeKind 序与 ast.sx 一致（TYPE_LINEAR 在 TYPE_VECTOR 前）。
$s =~ s/(TYPE_SLICE,\s*)ast_TypeKind_TYPE_VECTOR/$1ast_TypeKind_TYPE_LINEAR, ast_TypeKind_TYPE_VECTOR/s
  unless $s =~ /TYPE_LINEAR/;

# ast.sx 别名：glue 池 init 符号名。
$s =~ s/\bast_arena_init\b/ast_ast_arena_init/g if $s =~ /void ast_arena_init\(/ && $s !~ /ast_ast_arena_init/;

seek $fh, 0, 0;
print $fh $s;
truncate $fh, tell($fh);
close $fh;
