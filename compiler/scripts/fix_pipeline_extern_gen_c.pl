#!/usr/bin/env perl
# pipeline.su -E-extern 产物：补 pipeline_dep_ctx_*→ast_pipeline_*、std.fs 短名、parser_parse_into_buf 等，
# 使 pipeline_gen.c 可与 pipeline_glue.o / typeck_su.o / codegen_su.o 分 TU 链接（无内联 typeck/codegen）。
use strict;
use warnings;

my $path = $ARGV[0] or die "usage: fix_pipeline_extern_gen_c.pl pipeline_gen.c\n";
open my $fh, '+<', $path or die "open $path: $!\n";
local $/;
my $src = <$fh>;
my $orig = $src;

# 仅处理瘦 pipeline：-E-extern 仍可能追加 #include "pipeline_glue.c" 行，但不含内联 glue 体。
if (index($src, '#include "pipeline_glue.c"') >= 0) {
  $src =~ s/\n#include "pipeline_glue.c"\n?\s*\z/\n/s;
}
exit 0 if index($src, 'pipeline_run_su_pipeline_impl') < 0;

# 去掉重复 slice struct（与 Makefile dedupe 双保险）。
my $slice_seen = 0;
$src =~ s/^(struct shulang_slice_uint8_t \{[^\n]*\};\n)/$slice_seen++ ? '' : $1/mge;

my @alias_lines;
my %alias_done;

sub add_alias {
  my ($from, $to) = @_;
  return if $alias_done{"$from=$to"}++;
  push @alias_lines, "#define $from $to\n";
}

# ast_pipeline_* glue 符号：generated 体调用 pipeline_dep_ctx_* / pipeline_ctx_* / pipeline_module_* 短名。
while ($src =~ /^extern\s+.+\s+ast_pipeline_(\w+)\s*\(/mg) {
  my $s = $1;
  add_alias("pipeline_$s", "ast_pipeline_$s") if $s =~ /^(?:dep_ctx_|ctx_|module_|arena_)/;
}

# hoisted 块内 ast_pipeline_* 也补一轮（dep_ctx / ctx_lib_root）。
while ($src =~ /^extern\s+.+\s+ast_pipeline_(dep_ctx_\w+|ctx_lib_root_\w+|ctx_lib_root_count)\s*\(/mg) {
  add_alias("pipeline_$1", "ast_pipeline_$1");
}

# std.fs 短名（-E-extern 导出 std_fs_fs_*）。
add_alias('fs_open_read',  'std_fs_fs_open_read');
add_alias('fs_close',      'std_fs_fs_close');
add_alias('fs_read',       'std_fs_fs_read');

# 瘦 pipeline 生成体调用短名；extern 为 typeck_typeck_* / codegen_codegen_* / asm_asm_* 等（由分 TU 提供）。
add_alias('typeck_su_ast', 'typeck_typeck_su_ast');
add_alias('typeck_su_ast_library', 'typeck_typeck_su_ast_library');
add_alias('typeck_merge_dep_struct_layouts_into_entry', 'typeck_typeck_merge_dep_struct_layouts_into_entry');
add_alias('codegen_su_ast', 'codegen_codegen_su_ast');
add_alias('asm_codegen_ast', 'asm_asm_codegen_ast');
add_alias('lexer_init', 'lexer_lexer_init');
add_alias('lexer_lexer_next_into', 'lexer_next_into');
add_alias('lexer_lexer_next_buf', 'lexer_next_buf');
add_alias('ast_arena_init', 'ast_ast_arena_init');
add_alias('preprocess_su_buf', 'preprocess_preprocess_su_buf');

# pipeline_module_* / pipeline_arena_* 由 pipeline_glue.o（ast_pool）提供，generated 已用同名 extern。

# parser_parse_into_buf：C parser.o 无此符号；extern 须在 struct 定义之后声明。
if (index($src, 'parser_parse_into_buf') >= 0 && index($src, 'pipeline extern parser_parse_into_buf') < 0) {
  my $pbuf_decl = "/* pipeline extern parser_parse_into_buf */\nextern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data, int32_t len);\n";
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$pbuf_decl/s
    or warn "fix_pipeline_extern_gen_c: parser_parse_into_buf anchor not found\n";
  $src =~ s/^extern struct parser_ParseIntoResult parser_parse_into_buf[^\n]*\n\n(?=static inline void shulang_panic_)//m;
}

if (@alias_lines && index($src, '/* pipeline extern TU aliases */') < 0) {
  my $block = "/* pipeline extern TU aliases */\n" . join('', sort @alias_lines) . "\n";
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$block/s
    or $src =~ s/(static inline void shulang_panic_\([^\n]*\n)/$block$1/s
    or warn "fix_pipeline_extern_gen_c: anchor not found in $path\n";
}

# lexer_init → lexer_lexer_init（lexer_su.o）；须 extern 声明，勿与 lexer_lexer_init→lexer_init 互指成环。
if (index($src, '#define lexer_init lexer_lexer_init') >= 0
    && index($src, 'extern struct lexer_Lexer lexer_lexer_init') < 0) {
  my $lexer_decl = "/* lexer_su.o */\nextern struct lexer_Lexer lexer_lexer_init(void);\n";
  if (index($src, '/* pipeline extern TU aliases */') >= 0) {
    $src =~ s/(#define lexer_init lexer_lexer_init\n)/$lexer_decl$1/s
      or warn "fix_pipeline_extern_gen_c: lexer_lexer_init anchor not found\n";
  }
}

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;

# 瘦 pipeline 仍须同 TU 链 ast_pool：在文件末恢复 #include（fix 开头已去掉，避免脚本误判为 fat gen）。
# 须在 #include 前 #undef 全部 pipeline_*→ast_pipeline_* 别名，否则 ast_pool.c 内 pipeline_dep_ctx_ndep 等
# 会被宏展开成 ast_pipeline_*，与 pipeline_glue.c 末尾 ast_* 转发函数重复定义。
if (index($src, 'pipeline_run_su_pipeline_impl') >= 0) {
  my $undef_block = '';
  if (@alias_lines) {
    my @undef = map {
      chomp;
      my ($from) = /^#define (\S+)/ ? $1 : ();
      $from ? "#undef $from\n" : '';
    } @alias_lines;
    $undef_block = "/* pipeline extern TU: drop aliases before glue (ast_pool uses pipeline_* names) */\n"
      . join('', grep { length } @undef) . "\n";
  }
  if (index($src, '#include "pipeline_glue.c"') < 0) {
    open my $af, '>>', $path or die "append $path: $!\n";
    print $af "\n$undef_block#include \"pipeline_glue.c\"\n";
    close $af;
  } elsif ($undef_block ne '' && index($src, 'pipeline extern TU: drop aliases before glue') < 0) {
    $src =~ s/\n#include "pipeline_glue.c"\n?\s*\z/\n$undef_block#include "pipeline_glue.c"\n/s;
    seek $fh, 0, 0;
    print $fh $src;
    truncate $fh, tell($fh);
  }
}
