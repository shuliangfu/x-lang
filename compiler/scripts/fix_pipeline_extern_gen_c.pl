#!/usr/bin/env perl
# pipeline.x -E-extern 产物：补 pipeline_dep_ctx_*→ast_pipeline_*、std.fs 短名、parser_parse_into_buf 等，
# 使 pipeline_gen.c 可与 pipeline_glue.o / typeck_x.o / codegen_x.o 分 TU 链接（无内联 typeck/codegen）。
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
# 瘦 pipeline：-E-extern 编排体须含 load/sync 或 parse_entry；run_x_pipeline_impl 迁 C glue 后不再出现在 gen.c。
my $is_thin_pipeline = (index($src, 'pipeline_load_and_sync_direct_import_deps') >= 0)
  || (index($src, 'run_x_pipeline_parse_entry_if_needed') >= 0)
  || (index($src, 'pipeline_run_x_pipeline_impl') >= 0);
exit 0 unless $is_thin_pipeline;

# 去掉重复 slice struct（与 Makefile dedupe 双保险）。
my $slice_seen = 0;
$src =~ s/^(struct shux_slice_uint8_t \{[^\n]*\};\n)/$slice_seen++ ? '' : $1/mge;

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

# 瘦 pipeline 生成体直接调用 std_fs_fs_* 时须 extern（链 std_fs_shim.o）。
my $std_fs_extern = '';
if (index($src, 'std_fs_fs_open_read') >= 0 && index($src, 'extern int32_t std_fs_fs_open_read') < 0) {
  $std_fs_extern = "/* std_fs_shim.o */\nextern int32_t std_fs_fs_open_read(uint8_t *path);\nextern int32_t std_fs_fs_close(int32_t fd);\n";
}

# 瘦 pipeline 生成体调用短名；extern 为 typeck_typeck_* / codegen_codegen_* / asm_asm_* 等（由分 TU 提供）。
add_alias('typeck_x_ast', 'typeck_typeck_x_ast');
add_alias('typeck_x_ast_library', 'typeck_typeck_x_ast_library');
add_alias('typeck_merge_dep_struct_layouts_into_entry', 'typeck_typeck_merge_dep_struct_layouts_into_entry');
add_alias('typeck_wpo_unify_soa_layouts', 'typeck_typeck_wpo_unify_soa_layouts');
add_alias('codegen_x_ast', 'codegen_codegen_x_ast');
add_alias('asm_codegen_ast', 'asm_asm_codegen_ast');
add_alias('lexer_init', 'lexer_lexer_init');
add_alias('lexer_lexer_next_into', 'lexer_next_into');
add_alias('lexer_lexer_next_buf', 'lexer_next_buf');
add_alias('ast_arena_init', 'ast_ast_arena_init');
add_alias('preprocess_x_buf', 'preprocess_x_buf');

# pipeline_module_* / pipeline_arena_* 由 pipeline_glue.o（ast_pool）提供，generated 已用同名 extern。

# parser_parse_into_buf：C parser.o 无此符号；extern 须在 struct 定义之后声明。
if (index($src, 'parser_parse_into_buf') >= 0 && index($src, 'pipeline extern parser_parse_into_buf') < 0) {
  my $pbuf_decl = "/* pipeline extern parser_parse_into_buf */\nextern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data, int32_t len);\n";
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$pbuf_decl/s
    or warn "fix_pipeline_extern_gen_c: parser_parse_into_buf anchor not found\n";
  $src =~ s/^extern struct parser_ParseIntoResult parser_parse_into_buf[^\n]*\n\n(?=static inline void shux_panic_)//m;
}

# parser_copy_module_import_path64：parser_x.o 提供，避免 void get_module_import_path 语句导致 parse skip。
if (index($src, 'parser_copy_module_import_path64') >= 0
    && index($src, 'pipeline extern parser_copy_module_import_path64') < 0) {
  my $pcopy_decl = "/* pipeline extern parser_copy_module_import_path64 */\nextern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);\n";
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$pcopy_decl/s
    or warn "fix_pipeline_extern_gen_c: parser_copy_module_import_path64 anchor not found\n";
}
# shux-c -E 对 *u8 形参生成 uint8_t *out，与 out[64] 冲突（Alpine GCC -Warray-parameter / 类型不一致）。
$src =~ s/^extern int32_t parser_copy_module_import_path64\([^\n]*uint8_t \* out\);\n//mg;
$src =~ s/^extern int32_t parser_copy_module_import_path64\([^\n]*uint8_t \*out\);\n//mg;

if (@alias_lines && index($src, '/* pipeline extern TU aliases */') < 0) {
  my $block = "/* pipeline extern TU aliases */\n" . join('', sort @alias_lines) . "\n";
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$block/s
    or $src =~ s/(static inline void shux_panic_\([^\n]*\n)/$block$1/s
    or warn "fix_pipeline_extern_gen_c: anchor not found in $path\n";
}
if ($std_fs_extern ne '' && index($src, '/* std_fs_shim.o */') < 0) {
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$std_fs_extern/s
    or $src =~ s/(\/\* pipeline extern TU aliases \*\/\n)/$std_fs_extern$1/s
    or warn "fix_pipeline_extern_gen_c: std_fs extern anchor not found\n";
}

# lexer_init → lexer_lexer_init（lexer_x.o）；须 extern 声明，勿与 lexer_lexer_init→lexer_init 互指成环。
if (index($src, '#define lexer_init lexer_lexer_init') >= 0
    && index($src, 'extern struct lexer_Lexer lexer_lexer_init') < 0) {
  my $lexer_decl = "/* lexer_x.o */\nextern struct lexer_Lexer lexer_lexer_init(void);\n";
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

sub write_pipeline_gen {
  my ($p, $body) = @_;
  open my $wf, '>', $p or die "write $p: $!\n";
  print $wf $body;
  close $wf;
}

# 瘦 pipeline 仍须同 TU 链 ast_pool：在文件末恢复 #include（fix 开头已去掉，避免脚本误判为 fat gen）。
# 须在 #include 前 #undef 全部 pipeline_*→ast_pipeline_* 别名，否则 ast_pool.c 内 pipeline_dep_ctx_ndep 等
# 会被宏展开成 ast_pipeline_*，与 pipeline_glue.c 末尾 ast_* 转发函数重复定义。
if ($is_thin_pipeline) {
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
  # 编排 parse/typecheck/codegen 已迁 C glue；gen.c 若仍有 pipeline_run_x_pipeline_* 体则无需 trampoline。
  my $tramp_block = '';
  my $tail_changed = 0;
  if (index($src, '#include "pipeline_glue.c"') < 0) {
    $src .= "\n$tramp_block$undef_block#include \"pipeline_glue.c\"\n";
    $tail_changed = 1;
  } else {
    if ($undef_block ne '' && index($src, 'pipeline extern TU: drop aliases before glue') < 0) {
      $src =~ s/\n#include "pipeline_glue.c"\n?\s*\z/\n$tramp_block$undef_block#include "pipeline_glue.c"\n/s;
      $tail_changed = 1;
    } elsif ($tramp_block ne '' && index($src, "int32_t run_x_pipeline_codegen_deps(struct") < 0) {
      $src =~ s/\n(\/\* pipeline extern TU: drop aliases before glue[^\n]* \*\/\n)/\n$tramp_block\n$1/s
        or $src =~ s/\n#include "pipeline_glue.c"\n?\s*\z/\n$tramp_block\n#include "pipeline_glue.c"\n/s;
      $tail_changed = 1;
    }
  }
  write_pipeline_gen($path, $src) if $tail_changed;
}
