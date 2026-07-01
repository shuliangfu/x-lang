#!/usr/bin/env perl
# shux-c -E 对 slim ASTArena 仍可能生成 arena->exprs[] / blocks[] 直访；替换为 grow pool get_copy 调用，
# 并注入 pipeline_arena_* / ast_arena_* 原型与符号别名供 _gen2.c / pipeline_gen.c 单文件编译。
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
my $path = $ARGV[0] or die "usage: fix_slim_arena_gen_c.pl <file.c>\n";
open my $fh, '+<', $path or die "open $path: $!\n";
local $/;
my $src = <$fh>;
my $orig = $src;
$src =~ s/memcpy\(&(\w+), \&(\w+)->exprs\[(.+?) - 1\], sizeof\(\1\)\)/$1 = pipeline_arena_expr_get_copy($2, $3)/g;
$src =~ s/memcpy\(&(\w+), \&(\w+)->blocks\[(.+?) - 1\], sizeof\(\1\)\)/$1 = pipeline_arena_block_get_copy($2, $3)/g;
$src =~ s/memcpy\(&(\w+), \&(\w+)->types\[(.+?) - 1\], sizeof\(\1\)\)/$1 = pipeline_arena_type_get_copy($2, $3)/g;
$src =~ s/memcpy\(&(\w+), \&(\w+)->funcs\[(.+?) - 1\], sizeof\(\1\)\)/$1 = pipeline_arena_func_get_copy($2, $3)/g;

my $protos = <<'PROTO';
/* slim arena grow pool glue (linked from pipeline/runtime) */
extern struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
extern struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
extern void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
extern void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
extern void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
extern void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);

PROTO

if ($src =~ /pipeline_arena_(?:expr|block|type|func)_get_copy|ast_arena_(?:expr|block|type|func)_set/) {
  if (index($src, 'slim arena grow pool glue') < 0) {
    $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$protos/s
      or warn "fix_slim_arena_gen_c: ast_ASTArena anchor not found in $path\n";
  }
}

my %seen;
my @fwd_lines;
my @pipe_extern_lines;

# 返回值含 struct T * 时 shux-c -E 形如 extern struct ast_Module * ast_pipeline_*；
my $extern_ret = qr/(?:int32_t|void|int|uint8_t|size_t|intptr_t|struct\s+[A-Za-z0-9_]+\s*\*?)\s+/;

my $is_pipeline_gen2 = ($path =~ /pipeline_gen2\.c$/);
# parser_gen.c / lexer_gen.c / typeck_gen.c / codegen_gen.c 与 *_gen2.c 均需 TU 别名与 cross-module extern。
my $is_module_gen2   = ($path =~ /(?:parser|typeck|codegen|driver|lexer|lsp_diag|lsp_io|lsp)_gen(?:2)?\.c$/);

if ($is_pipeline_gen2) {
  # pipeline_gen2 同 TU 含 ast_pool.c（实现 pipeline_*）；仅补 extern 原型，禁止 #define 别名（会宏展开冲突）。
  while ($src =~ /^extern\s+(${extern_ret})ast_pipeline_(\w+)\s*\(([^;]*)\);/mg) {
    next if $seen{"pext_$2"}++;
    push @pipe_extern_lines, "extern $1 pipeline_$2($3);\n";
  }
  # ast_pool scratch（preprocess_if_stack / asm_qual_sym / asm_ctx_local / driver_emit）：gen2 若导出 ast_ 前缀则补 pipeline 回落原型。
  while ($src =~ /^extern\s+(${extern_ret})(preprocess_if_stack_\w+|asm_qual_sym_layer_\w+|asm_ctx_local_\w+|driver_emit_\w+)\s*\(([^;]*)\);/mg) {
    my ($ret, $sym, $args) = ($1, $2, $3);
    next if $seen{"pool_$sym"}++;
    push @pipe_extern_lines, "extern $ret $sym($args);\n";
  }
} elsif ($is_module_gen2) {
  while ($src =~ /^extern\s+${extern_ret}ast_pipeline_(\w+)\s*\(/mg) {
    next if $seen{"fwd_$1"}++;
    push @fwd_lines, "#define pipeline_$1 ast_pipeline_$1\n";
  }

  while ($src =~ /^extern\s+${extern_ret}ast_ast_arena_(\w+)\s*\(/mg) {
    next if $seen{"aa_$1"}++;
    push @fwd_lines, "#define ast_arena_$1 ast_ast_arena_$1\n";
  }

  # typeck_gen / codegen_gen：pipeline_gen 仍声明 typeck_typeck_* / codegen_codegen_*，实现名为 typeck_* / codegen_*。
  if ($path =~ /typeck_gen\.c$/) {
    while ($src =~ /^int(?:32_t)?\s+typeck_(\w+)\s*\(/mg) {
      my $suffix = $1;
      next if $seen{"tcmap_$suffix"}++;
      push @fwd_lines, "#define typeck_typeck_$suffix typeck_$suffix\n";
    }
  }
  if ($path =~ /codegen_gen\.c$/) {
    while ($src =~ /^int(?:32_t)?\s+codegen_(\w+)\s*\(/mg) {
      my $suffix = $1;
      next if $seen{"cgmap_$suffix"}++;
      push @fwd_lines, "#define codegen_codegen_$suffix codegen_$suffix\n";
    }
  }

  # -E-extern 导出 ast_ast_block_* / ast_ast_expr_*，生成体仍调用 ast_block_* / ast_expr_*。
  while ($src =~ /^extern\s+${extern_ret}ast_ast_(block_\w+|expr_\w+)\s*\(/mg) {
    my $suffix = $1;
    next if $seen{"abx_$suffix"}++;
    push @fwd_lines, "#define ast_$suffix ast_ast_$suffix\n";
  }
  # inject 的 extern ast_block_* / ast_arena_*（单 ast_ 前缀）→ pipeline_sx.o 中 ast_ast_*。
  while ($src =~ /^extern\s+${extern_ret}ast_(block_\w+|expr_\w+)\s*\(/mg) {
    my $suffix = $1;
    next if $seen{"abx1_$suffix"}++;
    # ast_gen2.c 实现为 ast_expr_init_* 等，勿映射到不存在的 ast_ast_expr_init_*。
    next if $suffix =~ /^expr_init_/;
    push @fwd_lines, "#define ast_$suffix ast_ast_$suffix\n";
  }
  while ($src =~ /^extern\s+${extern_ret}ast_arena_(\w+)\s*\(/mg) {
    my $suffix = $1;
    next if $seen{"aa1_$suffix"}++;
    push @fwd_lines, "#define ast_arena_$suffix ast_ast_arena_$suffix\n";
  }

  # 禁止 ast_/lexer_ 本地 extern → 错误 #define（会破坏 ast_ast_* / lexer_lexer_* 链接名）。
}

# lexer_gen.c / lexer_gen2.c：避免与 C lexer.o 的 lexer_next 重复导出（parser 仅用 lexer_next_into）。
if ($path =~ /lexer_gen(?:2)?\.c$/) {
  $src =~ s/\bstruct lexer_LexerResult lexer_next\(/struct lexer_LexerResult lexer_next_slice(/g;
  $src =~ s/\breturn lexer_next\(/return lexer_next_slice(/g;
}

# parser_gen.c 顶部「parser extern ast helpers」与 inject 块重复，去掉前者避免 conflicting types。
if ($path =~ /parser_gen(?:2)?\.c$/) {
  $src =~ s/\n\/\* parser extern ast helpers \*\/\n(?:extern )?void ast_expr_init_match_enum\([^\n]*\n//s;
  $src =~ s/^void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n//m;
  $src =~ s/^extern void ast_expr_init_match_enum\(struct ast_Expr \*e\);\n//m;
  # -E-extern 误导出 lexer_lexer_*，生成体调用 lexer_*；补与 lexer_sx.o 一致的声明。
  $src =~ s/^#define lexer_next_into lexer_lexer_next_into\n//mg;
  $src =~ s/^#define lexer_init lexer_lexer_init\n//mg;
  $src =~ s/^#define lexer_next_buf lexer_lexer_next_buf\n//mg;
  $src =~ s/\n\/\* parser lexer single-prefix externs \(lexer_sx\.o\) \*\/\nextern struct lexer_Lexer lexer_init\(void\);\nextern void lexer_next_into\([^\n]*\nextern struct lexer_LexerResult lexer_next_buf\([^\n]*\n\n//s;
}

# ast_gen2.c：与 pipeline_glue.c 同链时辅助符号须 weak，避免 duplicate symbol（verify-selfhost-stage2）。
if ($path =~ /ast_gen2\.c$/) {
  # ast.sx 自身 TU 的 arena helper 真链接名是 ast_ast_*；若生成后残留 ast_ast_ast_*，会在单文件编译时变成不存在的三级前缀。
  $src =~ s/\bast_ast_ast_/ast_ast_/g;
  $src =~ s{^extern\s+(.+?\s+)ast_arena_(\w+)\s*\(([^)]*)\);\n}{
    my ($ret, $suffix, $args) = ($1, $2, $3);
    my $decl = "extern ${ret}ast_arena_${suffix}($args);\n";
    if ($src !~ /^extern\s+.+?\s+ast_ast_arena_\Q$suffix\E\s*\(/m) {
      $decl .= "extern ${ret}ast_ast_arena_${suffix}($args);\n";
    }
    $decl;
  }mge;
  for my $sym (qw(ast_ref_is_null ast_expr_layout_prime_call_resolved ast_expr_init_match_enum ast_expr_init_call_resolve)) {
    next if $src =~ /weak.*\b$sym\b/;
    $src =~ s/^((?:int32_t|int|void)\s+$sym\s*\([^)]*\)\s*\{)/__attribute__((weak)) $1/mg;
  }
}

# parser_gen2.c：-E-extern 导出 lexer_lexer_*，生成体调 lexer_*；链 lexer_sx2.o（单前缀）时统一改声明名。
if ($path =~ /parser_gen2\.c$/) {
  $src =~ s/^#define lexer_next_into lexer_lexer_next_into\n//mg;
  $src =~ s/^#define lexer_init lexer_lexer_init\n//mg;
  $src =~ s/^#define lexer_next_buf lexer_lexer_next_buf\n//mg;
  $src =~ s/\blexer_lexer_next_into\b/lexer_next_into/g;
  $src =~ s/\blexer_lexer_init\b/lexer_init/g;
  $src =~ s/\blexer_lexer_next_buf\b/lexer_next_buf/g;
}

# 须在 reverse alias 之前：inject 会写入 ast_pipeline_* extern，避免 ast↔pipeline 双向 #define 环（typeck_gen body_expr_ref_at）。
if ($is_module_gen2 && $path !~ /pipeline_gen/) {
  $src = inject_pipeline_glue_from_usage($src);
}

my @rev_fwd_lines;
if ($is_module_gen2) {
  while ($src =~ /^extern\s+${extern_ret}pipeline_(\w+)\s*\(/mg) {
    next if $seen{"revf_$1"}++;
    next if $src =~ /^extern\s+${extern_ret}ast_pipeline_$1\s*\(/m;
    push @rev_fwd_lines, "#define ast_pipeline_$1 pipeline_$1\n";
  }
}

my $defines_ast_pipeline = ($src =~ /\bast_pipeline_\w+\s*\([^)]*\)\s*\{/);
if ($is_module_gen2 && @rev_fwd_lines && index($src, 'pipeline reverse aliases') < 0 && !$defines_ast_pipeline) {
  my $rev_block = "/* pipeline reverse aliases (call ast_pipeline_* → pipeline_* extern) */\n" . join("", @rev_fwd_lines);
  $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$rev_block/s
    or warn "fix_slim_arena_gen_c: reverse alias anchor not found in $path\n";
}
if ($is_module_gen2 && ($path =~ /pipeline_gen/ || @fwd_lines)) {
  if (index($src, 'C-04 -E-extern TU aliases') < 0) {
  $src =~ s/\n\/\* pipeline call aliases \(ast_pipeline_\* extern, pipeline_\* call\) \*\/\n(?:#define[^\n]*\n)*//s;
  my $fwd_block = "/* pipeline call aliases (ast_pipeline_* extern, pipeline_* call) */\n" . join("", @fwd_lines);
  $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$fwd_block/s
    or warn "fix_slim_arena_gen_c: forward alias anchor not found in $path\n";
  }
}
if ($is_pipeline_gen2 && @pipe_extern_lines) {
  $src =~ s/\n\/\* pipeline call aliases \(ast_pipeline_\* extern, pipeline_\* call\) \*\/\n(?:#define[^\n]*\n)*//s;
  $src =~ s/\n\/\* pipeline pool extern decls \(calls pipeline_\*, defs in ast_pool\.c\) \*\/\n(?:extern[^\n]*\n)*//s;
  my $pool_block = "/* pipeline pool extern decls (calls pipeline_*, defs in ast_pool.c) */\n" . join("", @pipe_extern_lines);
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$pool_block/s
    or warn "fix_slim_arena_gen_c: pipeline pool extern anchor not found in $path\n";
}

# 从 ast_gen2.c / lexer_gen2.c 补全 import 符号的 extern（-E-extern 未全量导出时单文件编译缺原型）。
sub load_extern_prototypes {
  my ($proto_path, $sym_prefix) = @_;
  my %map;
  return %map unless -f $proto_path;
  open my $pf, '<', $proto_path or return %map;
  my $body = do { local $/; <$pf> };
  close $pf;
  while ($body =~ /^(?:extern\s+)?(.+?\s+)(${sym_prefix}\w+)\s*\(([^)]*)\)\s*[;{]/mg) {
    my ($ret, $name, $args) = ($1, $2, $3);
    $ret =~ s/\s+$//;
    next if $ret =~ /\*/ && $ret !~ /struct\s/;
    $map{$name} = "extern $ret $name($args);\n";
  }
  return %map;
}

sub inject_cross_module_externs {
  my ($src, $dir, $prefix, $marker) = @_;
  my $proto_file = "$dir/${prefix}_gen2.c";
  my %protos = load_extern_prototypes($proto_file, $prefix eq 'ast' ? 'ast_ast_' : 'lexer_lexer_');
  return $src unless %protos;

  my %have;
  while ($src =~ /^extern\s+.+\b((?:ast_ast_|lexer_lexer_)\w+)\s*\(/mg) {
    $have{$1} = 1;
  }
  my %inj_seen;
  my @lines;
  while ($src =~ /\b((?:ast_ast_|lexer_lexer_)\w+)\s*\(/g) {
    my $sym = $1;
    next if $have{$sym} || $inj_seen{$sym}++;
    next unless $protos{$sym};
    push @lines, $protos{$sym};
    $have{$sym} = 1;
  }
  return $src unless @lines;

  $src =~ s/\n\/\* $marker \*\/\n(?:extern[^\n]*\n)*//s;
  my $block = "/* $marker */\n" . join("", @lines);
  $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$block/s
    or warn "fix_slim_arena_gen_c: cross-module extern anchor not found in $path\n";
  return $src;
}

if ($is_module_gen2) {
  my $dir = dirname($path);
  $src = inject_cross_module_externs($src, $dir, 'ast', 'ast cross-module externs');
  $src = inject_cross_module_externs($src, $dir, 'lexer', 'lexer cross-module externs');
  $src = inject_ast_gen2_single_prefix_externs($src, $dir);
  if ($path =~ /parser_gen(?:2)?\.c$/) {
    $src = inject_lexer_gen_single_prefix_externs($src, $dir);
  }
  $src = append_ast_gen2_link_aliases($src);
}

# inject_ast_gen2 在 pipeline call aliases 之后插入 extern，须再补 #define ast_* → ast_ast_*。
sub append_ast_gen2_link_aliases {
  my ($src) = @_;
  my @extra;
  my %done;
  while ($src =~ /^extern\s+${extern_ret}ast_(block_\w+|expr_\w+)\s*\(/mg) {
    my $suffix = $1;
    next if $suffix =~ /^expr_init_/;
    next if $done{"ablate_$suffix"}++;
    next if $src =~ /^#define ast_$suffix ast_ast_$suffix/m;
    push @extra, "#define ast_$suffix ast_ast_$suffix\n";
  }
  while ($src =~ /^extern\s+${extern_ret}ast_arena_(\w+)\s*\(/mg) {
    my $suffix = $1;
    next if $done{"aalate_$suffix"}++;
    next if $src =~ /^#define ast_arena_$suffix ast_ast_arena_$suffix/m;
    push @extra, "#define ast_arena_$suffix ast_ast_arena_$suffix\n";
  }
  return $src unless @extra;
  $src =~ s/\n\/\* ast gen2 late link aliases \*\/\n(?:#define[^\n]*\n)*//s;
  my $block = "/* ast gen2 late link aliases */\n" . join('', @extra);
  $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$block/s
    or warn "fix_slim_arena_gen_c: ast gen2 late alias anchor not found\n";
  return $src;
}

# parser 调用 lexer_init / lexer_next_into；lexer_gen.c 导出单前缀符号（lexer_sx.o）。
sub inject_lexer_gen_single_prefix_externs {
  my ($src, $dir) = @_;
  # Stage2 仅生成 lexer_gen2.c；bootstrap 用 lexer_gen.c。
  my $proto_file = -f "$dir/lexer_gen2.c" ? "$dir/lexer_gen2.c" : "$dir/lexer_gen.c";
  return $src unless -f $proto_file;
  open my $pf, '<', $proto_file or return $src;
  my $body = do { local $/; <$pf> };
  close $pf;
  my %proto;
  while ($body =~ /^(?:extern\s+)?(.+?\s+)(lexer_(?!lexer_)\w+)\s*\(([^)]*)\)\s*[;{]/mg) {
    my ($ret, $name, $args) = ($1, $2, $3);
    $ret =~ s/\s+$//;
    $proto{$name} = "extern $ret $name($args);\n";
  }
  return $src unless %proto;

  my %have;
  while ($src =~ /^extern\s+.+\b(lexer_(?!lexer_)\w+)\s*\(/mg) {
    $have{$1} = 1;
  }
  my %inj_seen;
  my @lines;
  while ($src =~ /\b(lexer_(?!lexer_)\w+)\s*\(/g) {
    my $sym = $1;
    next if $have{$sym} || $inj_seen{$sym}++;
    next unless $proto{$sym};
    push @lines, $proto{$sym};
    $have{$sym} = 1;
  }
  return $src unless @lines;

  $src =~ s/\n\/\* lexer gen single-prefix externs \*\/\n(?:extern[^\n]*\n)*//s;
  my $block = "/* lexer gen single-prefix externs */\n" . join("", @lines);
  $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$block/s
    or warn "fix_slim_arena_gen_c: lexer gen single-prefix anchor not found in $path\n";
  return $src;
}

# ast_gen2.c 中实现为 ast_block_* / ast_expr_*（单 ast_ 前缀）；-E-extern 的 typeck/codegen 生成体仍直接调用这些名字。
sub inject_ast_gen2_single_prefix_externs {
  my ($src, $dir) = @_;
  my $proto_file = "$dir/ast_gen2.c";
  return $src unless -f $proto_file;
  open my $pf, '<', $proto_file or return $src;
  my $body = do { local $/; <$pf> };
  close $pf;
  my %proto;
  while ($body =~ /^(?:extern\s+)?(.+?\s+)(ast_(?:block|expr|arena)_[a-zA-Z0-9_]+)\s*\(([^)]*)\)\s*[;{]/mg) {
    my ($ret, $name, $args) = ($1, $2, $3);
    $ret =~ s/\s+$//;
    $proto{$name} = "extern $ret $name($args);\n";
  }
  return $src unless %proto;

  my %have;
  while ($src =~ /^extern\s+.+\b(ast_(?:block|expr|arena)_[a-zA-Z0-9_]+)\s*\(/mg) {
    $have{$1} = 1;
  }
  my %inj_seen;
  my @lines;
  while ($src =~ /\b(ast_(?:block|expr|arena)_[a-zA-Z0-9_]+)\s*\(/g) {
    my $sym = $1;
    next if $sym =~ /^expr_init_/;
    next if $have{$sym} || $inj_seen{$sym}++;
    next unless $proto{$sym};
    push @lines, $proto{$sym};
    $have{$sym} = 1;
  }
  return $src unless @lines;

  $src =~ s/\n\/\* ast gen2 single-prefix externs \*\/\n(?:extern[^\n]*\n)*//s;
  my $block = "/* ast gen2 single-prefix externs */\n" . join("", @lines);
  $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$block/s
    or warn "fix_slim_arena_gen_c: ast gen2 single-prefix anchor not found in $path\n";
  return $src;
}

# 单文件 typeck/codegen/pipeline(-extern) 调 pipeline_* 时，从 pipeline_glue.c 补 ast_pipeline_* extern 与 #define。
sub inject_pipeline_glue_from_usage {
  my ($src) = @_;
  my $glue_path = abs_path(dirname($path) . '/pipeline_glue.c');
  return $src unless -f $glue_path;
  open my $gl, '<', $glue_path or return $src;
  my $glue = do { local $/; <$gl> };
  close $gl;

  my %proto;
  while ($glue =~ /^((?:void|int32_t|int|uint8_t|size_t|struct\s+ast_\w+\s*\*?)\s+(ast_pipeline_\w+)\s*\(([^)]*)\))\s*\{/mg) {
    my ($sig, $name, $args) = ($1, $2, $3);
    $proto{$name} = "extern $sig;\n";
  }

  my %need;
  while ($src =~ /\bpipeline_([a-zA-Z0-9_]+)\s*\(/g) {
    my $suffix = $1;
    next if $src =~ /#define\s+pipeline_\Q$suffix\E\b/;
    my $ast = "ast_pipeline_$suffix";
    next unless $proto{$ast};
    $need{$suffix} = $ast;
  }
  return $src unless %need;

  my @ext_lines;
  my @def_lines;
  for my $suffix (sort keys %need) {
    my $ast = $need{$suffix};
    push @ext_lines, $proto{$ast} unless $src =~ /^\s*extern\s+.*\b\Q$ast\E\s*\(/m;
    push @def_lines, "#define pipeline_$suffix $ast\n";
  }
  return $src unless @ext_lines || @def_lines;

  $src =~ s/\n\/\* pipeline glue usage aliases \*\/\n(?:extern[^\n]*\n|#define[^\n]*\n)*//s;
  my $block = "/* pipeline glue usage aliases */\n" . join("", @ext_lines) . join("", @def_lines);
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$block/s
    or $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$block/s
    or warn "fix_slim_arena_gen_c: pipeline glue alias anchor not found in $path\n";
  return $src;
}

# inject_pipeline_glue_from_usage 定义见上；module gen2 已在 reverse alias 前调用。

# parser_gen.c：所有 inject 完成后，将 shux_slice 提前到 ast_ASTArena 后（GCC 见完整类型再声明 lexer_* extern）。
sub hoist_shux_slice_struct {
  my ($s) = @_;
  my $def = "struct shux_slice_uint8_t { uint8_t *data; size_t length; };\n";
  return $s unless index($s, $def) >= 0;
  return $s if $s =~ /struct ast_ASTArena \{[^\}]+\};\n\Q$def\E/s;
  $s =~ s/\Q$def\E//g;
  $s =~ s/(struct ast_ASTArena \{[^\}]+\};\n)/$1$def/s
    or warn "fix_slim_arena_gen_c: hoist shux_slice anchor not found in $path\n";
  return $s;
}
if ($path =~ /parser_gen(?:2)?\.c$/) {
  $src = hoist_shux_slice_struct($src);
}

# ast_gen2 weak 辅助：typeck/codegen/parser -E 生成体直接调用，单 TU 须 extern 声明。
if ($is_module_gen2 && index($src, 'ast_ref_is_null(') >= 0 && $src !~ /extern\s+int\s+ast_ref_is_null\s*\(/) {
  $src =~ s/(struct ast_ASTArena \{[^\}]+\};\n)/$1extern int ast_ref_is_null(int32_t ref);\n/s
    or warn "fix_slim_arena_gen_c: ast_ref_is_null extern anchor not found in $path\n";
}

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;
