#!/usr/bin/env perl
# shu-c -E 对 slim ASTArena 仍可能生成 arena->exprs[] / blocks[] 直访；替换为 grow pool get_copy 调用，
# 并注入 pipeline_arena_* / ast_arena_* 原型与符号别名供 _gen2.c / pipeline_gen.c 单文件编译。
use strict;
use warnings;
use File::Basename qw(dirname);
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

# 返回值含 struct T * 时 shu-c -E 形如 extern struct ast_Module * ast_pipeline_*；
my $extern_ret = qr/(?:int32_t|void|int|uint8_t|size_t|intptr_t|struct\s+[A-Za-z0-9_]+\s*\*?)\s+/;

my $is_pipeline_gen2 = ($path =~ /pipeline_gen2\.c$/);
my $is_module_gen2   = ($path =~ /(?:parser|typeck|codegen|driver)_gen2\.c$/);

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

  # 禁止 ast_/lexer_ 本地 extern → 错误 #define（会破坏 ast_ast_* / lexer_lexer_* 链接名）。
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
if ($is_module_gen2 && @fwd_lines) {
  $src =~ s/\n\/\* pipeline call aliases \(ast_pipeline_\* extern, pipeline_\* call\) \*\/\n(?:#define[^\n]*\n)*//s;
  my $fwd_block = "/* pipeline call aliases (ast_pipeline_* extern, pipeline_* call) */\n" . join("", @fwd_lines);
  $src =~ s/(struct ast_ASTArena \{.*?\};\n)/$1\n$fwd_block/s
    or warn "fix_slim_arena_gen_c: forward alias anchor not found in $path\n";
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
}

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;
