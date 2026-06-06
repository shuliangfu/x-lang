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

# parser_gen -E-extern：parser_parse 烟测调 parse_expr_into；符号在 build_asm/parser.o 为 parse_expr_into（无 parser_ 前缀）。
if ($path =~ /parser_gen\.c$/ && index($src, 'parser_parse_expr_into') >= 0) {
  $src =~ s/\n\/\* parser_gen thin TU: parse_expr_into.*?\n#define parser_parse_expr_into parse_expr_into\n\n//s;
  if (index($src, '#define parser_parse_expr_into') < 0) {
    my $pex = <<'PEX';

/* parser_gen thin TU: parse_expr_into 由 build_asm/parser.o 提供 */
extern void parse_expr_into(struct ast_ASTArena *arena, struct lexer_Lexer lex, struct shulang_slice_uint8_t *source, struct parser_ParseExprResult *out);
#define parser_parse_expr_into parse_expr_into
PEX
    $src =~ s/(struct parser_ParseExprResult \{[^\}]+\};)/$1$pex/s
      or warn "fix_parser_pool_access_gen_c: parse_expr_into alias anchor not found\n";
  }
}

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;
