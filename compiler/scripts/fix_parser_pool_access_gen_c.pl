#!/usr/bin/env perl
# parser.sx -E/-E-extern 产物：slim ASTArena 无 exprs/types/blocks/funcs 数组，
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

# parser_gen.c：ast_expr_init_match_enum 须在 struct ast_Expr 完整定义之后声明（GCC Alpine -Wincompatible-pointer-types）。
if ($path =~ /parser_gen\.c$/) {
  $src =~ s/^\/\* parser extern ast helpers \*\/\n(?:extern )?void ast_expr_init_match_enum\([^\n]*\n//m;
  $src =~ s/^void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n//m;
  $src =~ s/^extern void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n//m;
  $src =~ s/^extern __attribute__\(\(weak\)\) void ast_expr_init_match_enum\([^\n]*\n//mg;
  $src =~ s/\n\/\* ast gen2 single-prefix externs \*\/\n(?:extern[^\n]*\n)*//s;
  if (index($src, 'ast_expr_init_match_enum') >= 0
      && $src !~ /struct ast_Expr \{[^}]+\};\nextern void ast_expr_init_match_enum/s) {
    $src =~ s/(struct ast_Expr \{[^}]+\};\n)/$1\nextern void ast_expr_init_match_enum(struct ast_Expr *e);\n/s
      or warn "fix_parser_pool_access_gen_c: post-struct ast_expr_init_match_enum anchor not found\n";
  }
}
# parser_gen2.c 与 -include ast.h 同编：ast.h 已声明 ast_expr_init_match_enum(ASTExpr*)，勿再插 struct ast_Expr 版 extern。
if ($is_parser_gen2) {
  $src =~ s/^extern void ast_expr_init_match_enum\([^\n]*\n//mg;
  $src =~ s/^extern __attribute__\(\(weak\)\) void ast_expr_init_match_enum\([^\n]*\n//mg;
  $src =~ s/^void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n//m;
}
if (index($src, 'ast_arena_func_get(') >= 0) {
  # fix_slim_arena 已注入 #define ast_arena_func_get ast_ast_arena_func_get 时，须声明 ast_ast_arena_func_get。
  my $use_ast_ast = index($src, '#define ast_arena_func_get ast_ast_arena_func_get') >= 0;
  my $getter_sym = $use_ast_ast ? 'ast_ast_arena_func_get' : 'ast_arena_func_get';
  if (index($src, "struct ast_Func $getter_sym") < 0) {
    my $decl = "struct ast_ASTArena;\nstruct ast_Func $getter_sym(struct ast_ASTArena *arena, int32_t ref);\n";
    $src =~ s/(void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n)/$1$decl/s
      or warn "fix_parser_pool_access_gen_c: ast_arena_func_get decl anchor not found\n";
  }
  if ($use_ast_ast) {
    $src =~ s/^struct ast_Func ast_arena_func_get\([^\n]*\n//m;
  }
}

# lsp_diag 等：直接调用 ast_arena_*_get 时补 ast_ast_arena_* extern 与 #define 别名。
if (index($src, 'ast_arena_expr_get(') >= 0 && index($src, '#define ast_arena_expr_get ast_ast_arena_expr_get') < 0) {
  $src =~ s/\n\/\* ast_ast_arena pool externs \(pipeline_glue\.c at link\) \*\/\n(?:extern[^\n]*\n|#define ast_arena_[^\n]*\n)*//s;
  if (index($src, 'extern struct ast_Expr ast_ast_arena_expr_get') < 0) {
    my $pool_ext = <<'POOL_EXT';

/* ast_ast_arena pool externs (pipeline_glue.c at link) */
extern struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena *a, int32_t ref);
#define ast_arena_expr_get ast_ast_arena_expr_get
#define ast_arena_type_get ast_ast_arena_type_get
POOL_EXT
    $src =~ s/(struct ast_ASTArena \{[^\}]+\};\n)/$1$pool_ext/s
      or warn "fix_parser_pool_access_gen_c: lsp ast_arena getter extern anchor not found\n";
  }
}

# parser 等：经 fix_slim_arena 映射 ast_arena_* → ast_ast_arena_* 时，单 TU 编译须补 pipeline_glue 侧 extern。
if (index($src, '#define ast_arena_block_get ast_ast_arena_block_get') >= 0) {
  $src =~ s/\n\/\* ast_ast_arena pool externs \(pipeline_glue\.c at link\) \*\/\n(?:extern[^\n]*\n|#define ast_arena_[^\n]*\n)*//s;
  if (index($src, 'extern struct ast_Block ast_ast_arena_block_get') < 0) {
    my $pool_ext = <<'POOL_EXT';

/* ast_ast_arena pool externs (pipeline_glue.c at link) */
extern void ast_ast_arena_init(struct ast_ASTArena *arena);
extern int32_t ast_ast_arena_type_alloc(struct ast_ASTArena *a);
extern int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena *a);
extern int32_t ast_ast_arena_block_alloc(struct ast_ASTArena *a);
extern int32_t ast_ast_arena_func_alloc(struct ast_ASTArena *a);
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena *a, int32_t ref);
extern void ast_ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);
POOL_EXT
    $src =~ s/(struct ast_ASTArena \{[^\}]+\};\n)/$1$pool_ext/s
      or warn "fix_parser_pool_access_gen_c: ast_ast_arena pool extern anchor not found\n";
  }
  # ast 辅助与 heap：parser -E 生成体直接调用，单 TU 须 extern（链 ast_gen2 weak / sx_seed_bridge）。
  if (index($src, 'ast_ref_is_null(') >= 0 && index($src, 'extern int ast_ref_is_null') < 0) {
    $src =~ s/(struct shux_slice_uint8_t \{[^\}]+\};\n)/$1extern int ast_ref_is_null(int32_t ref);\n/s
      or warn "fix_parser_pool_access_gen_c: ast_ref_is_null anchor not found\n";
  }
  if (index($src, 'std_heap_alloc_zeroed(') >= 0 && index($src, 'extern void *std_heap_alloc_zeroed') < 0) {
    $src =~ s/(struct shux_slice_uint8_t \{[^\}]+\};\n)/$1extern void *std_heap_alloc_zeroed(size_t size);\n/s
      or warn "fix_parser_pool_access_gen_c: std_heap_alloc_zeroed anchor not found\n";
  }
  if (index($src, 'std_heap_free(') >= 0 && index($src, 'extern void std_heap_free') < 0) {
    $src =~ s/(struct shux_slice_uint8_t \{[^\}]+\};\n)/$1extern void std_heap_free(void *ptr);\n/s
      or warn "fix_parser_pool_access_gen_c: std_heap_free anchor not found\n";
  }
}

# parser.sx 新增 onefunc const 池 API：补 #define 使 parser_gen.c 链到 ast_pipeline_* glue。
my @pipeline_const_aliases = (
  [ 'pipeline_onefunc_append_const',    'ast_pipeline_onefunc_append_const' ],
  [ 'pipeline_onefunc_const_init_ref',  'ast_pipeline_onefunc_const_init_ref' ],
  [ 'pipeline_onefunc_const_type_ref',  'ast_pipeline_onefunc_const_type_ref' ],
);
for my $pair (@pipeline_const_aliases) {
  my ($from, $to) = @$pair;
  next if $path !~ /parser_gen\.c$/;
  next if index($src, "#define $from ") >= 0;
  if ($src =~ s/(#define pipeline_onefunc_append_let ast_pipeline_onefunc_append_let\n)/$1#define $from $to\n/) {
    $orig = '' if $src ne $orig;    # force write below
  } else {
    warn "fix_parser_pool_access_gen_c: anchor for $from alias not found\n";
  }
}

# parse_expr_into：由 parser_asm_parse_expr_link.c 转发 parser_parse_expr_into；勿再注入 extern 裸名（bootstrap 链会 undefined）。

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;
