#!/usr/bin/env perl
# pipeline.x -E-extern product: aliases pipeline_dep_ctx_*→ast_pipeline_*, std.fs
# short names, parser_parse_into_buf, etc. so pipeline_gen.c can link as a
# separate TU against typeck_x.o / codegen_x.o / runtime_pipeline_abi (no inlined
# typeck/codegen).
#
# wave967: pipeline_glue.c / ast_pool.c left wave309. Do NOT reinject
# #include "pipeline_glue.c" (deleted mega = fake authority / broken cc).
# Strip residual includes only. Live orch = pipeline.x pure-extern + abi.
# PLATFORM: SHARED — archaeology honesty; Stage2 / glue_types path.
use strict;
use warnings;

my $path = $ARGV[0] or die "usage: fix_pipeline_extern_gen_c.pl pipeline_gen.c\n";
open my $fh, '+<', $path or die "open $path: $!\n";
local $/;
my $src = <$fh>;
my $orig = $src;

# wave967: strip any residual #include "pipeline_glue.c" (file deleted wave309).
# Never reinject — that was the soft knife root (fake include of absent mega).
if (index($src, '#include "pipeline_glue.c"') >= 0) {
  print STDERR "fix_pipeline_extern_gen_c: stripping residual #include \"pipeline_glue.c\"\n"
    . "  (retired wave309; live = runtime_pipeline_abi / pipeline.x pure-extern)\n";
  $src =~ s/\n#include "pipeline_glue.c"\n?/\n/g;
}
# Thin pipeline: -E-extern body must contain load/sync or parse_entry.
my $is_thin_pipeline = (index($src, 'pipeline_load_and_sync_direct_import_deps') >= 0)
  || (index($src, 'run_x_pipeline_parse_entry_if_needed') >= 0)
  || (index($src, 'pipeline_run_x_pipeline_impl') >= 0);
# Persist residual-include strip even on non-thin; then leave.
if (!$is_thin_pipeline) {
  if ($src ne $orig) {
    seek $fh, 0, 0;
    print $fh $src;
    truncate $fh, tell($fh);
  }
  close $fh;
  exit 0;
}

# 去掉重复 slice struct（与 Makefile dedupe 双保险）。
my $slice_seen = 0;
$src =~ s/^(struct xlang_slice_uint8_t \{[^\n]*\};\n)/$slice_seen++ ? '' : $1/mge;

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

# pipeline_module_* / pipeline_arena_* : linked from runtime_pipeline_abi /
# pipeline_x (wave309 left glue/ast_pool mega). Generated TU already has same-name externs.

# parser_parse_into_buf：C parser.o 无此符号；extern 须在 struct 定义之后声明。
if (index($src, 'parser_parse_into_buf') >= 0 && index($src, 'pipeline extern parser_parse_into_buf') < 0) {
  my $pbuf_decl = "/* pipeline extern parser_parse_into_buf */\nextern struct parser_ParseIntoResult parser_parse_into_buf(struct ast_ASTArena *arena, struct ast_Module *module, uint8_t *data, int32_t len);\n";
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$pbuf_decl/s
    or warn "fix_pipeline_extern_gen_c: parser_parse_into_buf anchor not found\n";
  $src =~ s/^extern struct parser_ParseIntoResult parser_parse_into_buf[^\n]*\n\n(?=static inline void xlang_panic_)//m;
}

# parser_copy_module_import_path64：parser_x.o 提供，避免 void get_module_import_path 语句导致 parse skip。
if (index($src, 'parser_copy_module_import_path64') >= 0
    && index($src, 'pipeline extern parser_copy_module_import_path64') < 0) {
  my $pcopy_decl = "/* pipeline extern parser_copy_module_import_path64 */\nextern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);\n";
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$pcopy_decl/s
    or warn "fix_pipeline_extern_gen_c: parser_copy_module_import_path64 anchor not found\n";
}
# xlang-c -E 对 *u8 形参生成 uint8_t *out，与 out[64] 冲突（Alpine GCC -Warray-parameter / 类型不一致）。
$src =~ s/^extern int32_t parser_copy_module_import_path64\([^\n]*uint8_t \* out\);\n//mg;
$src =~ s/^extern int32_t parser_copy_module_import_path64\([^\n]*uint8_t \*out\);\n//mg;

if (@alias_lines && index($src, '/* pipeline extern TU aliases */') < 0) {
  my $block = "/* pipeline extern TU aliases */\n" . join('', sort @alias_lines) . "\n";
  $src =~ s/(struct ast_PipelineDepCtx \{.*?\};\n)/$1\n$block/s
    or $src =~ s/(static inline void xlang_panic_\([^\n]*\n)/$block$1/s
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

# wave967: do NOT reinject #include "pipeline_glue.c" / ast_pool same-TU.
# Pre-leave path appended the include after stripping so fat-gen detection
# would not misfire; post-leave that include is a deleted-file fake authority.
# Thin pipeline links runtime_pipeline_abi + pipeline_x instead.
if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, tell($fh);
}
close $fh;
