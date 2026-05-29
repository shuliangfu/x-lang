#!/usr/bin/env perl
# parser.su -E/-E-extern 产物：slim ASTArena 无 exprs/types/blocks/funcs 数组，
# 将 memcpy(&v, &arena->pool[idx-1], ...) 改写为 ast_arena_*_get(arena, idx) API 调用。
use strict;
use warnings;

my $path = $ARGV[0] or die "usage: fix_parser_pool_access_gen_c.pl parser_gen.c\n";
my $is_parser_gen2 = ($path =~ /parser_gen2\.c$/);
open my $fh, '+<', $path or die "open $path: $!\n";
local $/;
my $src = <$fh>;
my $orig = $src;

# expr / type / block / func 池：generated 用 memcpy 读槽位，slim struct 无内联数组（arena 或 a 等指针名）。
sub fix_pool_get {
  my ($pool, $getter) = @_;
  $src =~ s/memcpy\(&(\w+), &(arena|a)->$pool\[(\w+) - 1\], sizeof\(\1\)\);/$1 = $getter($2, $3);/g;
  $src =~ s/memcpy\(&(\w+), &(\w+)->$pool\[(\w+) - 1\], sizeof\(\1\)\);/$1 = $getter($2, $3);/g;
}
fix_pool_get('exprs',  'ast_arena_expr_get');
fix_pool_get('types',  'ast_arena_type_get');
fix_pool_get('blocks', 'ast_arena_block_get');
fix_pool_get('funcs',  'ast_arena_func_get');

# -E-extern 未导出 ast.su 内联 helper 原型时补声明（parser 生成体直接调用）。
# 若 ast gen2 段已有 extern void ast_expr_init_match_enum，勿再插 early decl（避免 conflicting types）。
if (index($src, 'ast_expr_init_match_enum') >= 0
    && index($src, 'extern void ast_expr_init_match_enum') < 0
    && index($src, '/* parser extern ast helpers */') < 0) {
  my $decl = "/* parser extern ast helpers */\nvoid ast_expr_init_match_enum(struct ast_Expr *e);\n";
  $src =~ s/(static inline void shulang_panic_\([^\n]*\n)/$decl$1/s
    or warn "fix_parser_pool_access_gen_c: ast_expr_init_match_enum anchor not found\n";
}
# 历史产物可能同时含 early void 与 ast gen2 extern：去掉 redundant early 块。
if (index($src, 'extern void ast_expr_init_match_enum') >= 0) {
  $src =~ s/\n\/\* parser extern ast helpers \*\/\nvoid ast_expr_init_match_enum\([^\n]*\n//s;
}
# parser_gen.c：去掉 early/weak 重复声明，保留单一 extern（定义在 su_seed_bridge.o）。
if ($path =~ /parser_gen\.c$/) {
  $src =~ s/^void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n//m;
  $src =~ s/^\/\* parser extern ast helpers \*\/\nvoid ast_expr_init_match_enum\([^\n]*\n//m;
  $src =~ s/^extern __attribute__\(\(weak\)\) void ast_expr_init_match_enum\([^\n]*\n//mg;
  $src =~ s/\n\/\* ast gen2 single-prefix externs \*\/\n(?:extern[^\n]*\n)*//s;
  if (index($src, 'ast_expr_init_match_enum') >= 0
      && index($src, 'extern void ast_expr_init_match_enum') < 0) {
    $src =~ s/(static inline void shulang_panic_\([^\n]*\n)/extern void ast_expr_init_match_enum(struct ast_Expr *e);\n\n$1/s
      or warn "fix_parser_pool_access_gen_c: parser_gen ast_expr_init_match_enum anchor not found\n";
  }
}
# parser_gen2.c 与 -include ast.h 同编：ast.h 已声明 ast_expr_init_match_enum(ASTExpr*)，勿再插 struct ast_Expr 版 extern。
if ($is_parser_gen2) {
  $src =~ s/^extern void ast_expr_init_match_enum\([^\n]*\n//mg;
  $src =~ s/^extern __attribute__\(\(weak\)\) void ast_expr_init_match_enum\([^\n]*\n//mg;
  $src =~ s/^void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n//m;
}
if (index($src, 'ast_arena_func_get(') >= 0 && index($src, 'struct ast_Func ast_arena_func_get') < 0) {
  my $decl = "struct ast_ASTArena;\nstruct ast_Func ast_arena_func_get(struct ast_ASTArena *arena, int32_t ref);\n";
  $src =~ s/(void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n)/$1$decl/s
    or warn "fix_parser_pool_access_gen_c: ast_arena_func_get decl anchor not found\n";
}

# parser.su 新增 onefunc const 池 API：补 #define 使 parser_gen.c 链到 ast_pipeline_* glue。
my @pipeline_const_aliases = (
  [ 'pipeline_onefunc_append_const',    'ast_pipeline_onefunc_append_const' ],
  [ 'pipeline_onefunc_const_init_ref',  'ast_pipeline_onefunc_const_init_ref' ],
  [ 'pipeline_onefunc_const_type_ref',  'ast_pipeline_onefunc_const_type_ref' ],
);
for my $pair (@pipeline_const_aliases) {
  my ($from, $to) = @$pair;
  next if index($src, "#define $from ") >= 0;
  if ($src =~ s/(#define pipeline_onefunc_append_let ast_pipeline_onefunc_append_let\n)/$1#define $from $to\n/) {
    $orig = '' if $src ne $orig;    # force write below
  } else {
    warn "fix_parser_pool_access_gen_c: anchor for $from alias not found\n";
  }
}

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;
