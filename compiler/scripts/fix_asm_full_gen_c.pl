#!/usr/bin/env perl
# fix_asm_full_gen_c.pl — shux -E asm.sx 产出 C 的宿主 cc 兼容补丁（G-06 build_seed_asm_host）
# 修复：固定数组字段顺序、float_val、enum 字段、import 限定调用、asm.types 残缺 emit、指针字段访问等。
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
my $path = $ARGV[0] or die "usage: fix_asm_full_gen_c.pl <asm_full_gen.c>\n";
my $compiler_root = abs_path(dirname(dirname(__FILE__)));
open my $fh, '+<', $path or die "open $path: $!\n";
my $src = do { local $/; <$fh> };
my $orig = $src;

# 去掉陈旧 glue 块中与 backend_ASTArena extern 冲突的 ast_ASTArena 声明（bak 内嵌 glue 或重复注入）
$src =~ s/extern int32_t pipeline_expr_array_lit_num_elems_at\(struct ast_ASTArena \*[^;]+;\s*//g;
$src =~ s/extern int32_t pipeline_expr_kind_ord_at\(struct ast_ASTArena \*[^;]+;\s*//g;
# 粘连在同一行的残留（删 kind 行后 array_lit 贴到上一行末尾）
$src =~ s/;extern int32_t pipeline_expr_array_lit_num_elems_at\(struct ast_ASTArena \*[^;]+;//g;
$src =~ s/;extern int32_t pipeline_expr_kind_ord_at\(struct ast_ASTArena \*[^;]+;//g;

# uint8_t[N] name → uint8_t name[N]
$src =~ s/\b(uint8_t|int32_t|char|double)\[(\d+)\]\s+(\w+)/$1 $3\[$2\]/g;
# f64 字段误 emit 为 void
$src =~ s/\bvoid float_val;/double float_val;/g;
# 未 emit 完整 enum 定义时退化为 int32_t
$src =~ s/struct\s+[A-Za-z0-9_]+_ExprKind\s+kind;/int32_t kind;/g;
$src =~ s/struct\s+[A-Za-z0-9_]+_TypeKind\s+kind;/int32_t kind;/g;
$src =~ s/struct\s+[A-Za-z0-9_]+_ExprKind\s+(\w+);/int32_t $1;/g;

# ExprKind.EXPR_* → 序数（与 ast.h AST_EXPR_* 一致）
my %expr_kind_ord = (
  EXPR_LIT => 0, EXPR_FLOAT_LIT => 1, EXPR_BOOL_LIT => 2, EXPR_VAR => 3,
  EXPR_ADD => 4, EXPR_SUB => 5, EXPR_MUL => 6, EXPR_DIV => 7, EXPR_MOD => 8,
  EXPR_SHL => 9, EXPR_SHR => 10, EXPR_BITAND => 11, EXPR_BITOR => 12, EXPR_BITXOR => 13,
  EXPR_EQ => 14, EXPR_NE => 15, EXPR_LT => 16, EXPR_LE => 17, EXPR_GT => 18, EXPR_GE => 19,
  EXPR_LOGAND => 20, EXPR_LOGOR => 21, EXPR_NEG => 22, EXPR_BITNOT => 23, EXPR_LOGNOT => 24,
  EXPR_IF => 25, EXPR_BLOCK => 26, EXPR_TERNARY => 27, EXPR_ASSIGN => 28,
  EXPR_ADD_ASSIGN => 29, EXPR_SUB_ASSIGN => 30, EXPR_MUL_ASSIGN => 31, EXPR_DIV_ASSIGN => 32,
  EXPR_MOD_ASSIGN => 33, EXPR_BITAND_ASSIGN => 34, EXPR_BITOR_ASSIGN => 35, EXPR_BITXOR_ASSIGN => 36,
  EXPR_SHL_ASSIGN => 37, EXPR_SHR_ASSIGN => 38, EXPR_BREAK => 39, EXPR_CONTINUE => 40,
  EXPR_RETURN => 41, EXPR_PANIC => 42, EXPR_MATCH => 43, EXPR_FIELD_ACCESS => 44,
  EXPR_STRUCT_LIT => 45, EXPR_ARRAY_LIT => 46, EXPR_INDEX => 47, EXPR_CALL => 48,
  EXPR_METHOD_CALL => 49, EXPR_ENUM_VARIANT => 50, EXPR_ADDR_OF => 51, EXPR_DEREF => 52,
  EXPR_AS => 53, EXPR_AWAIT => 54, EXPR_RUN => 55, EXPR_SPAWN => 56, EXPR_TRY_PROPAGATE => 57,
  EXPR_STRING_LIT => 58,
);
for my $k (sort { length($b) <=> length($a) } keys %expr_kind_ord) {
  my $v = $expr_kind_ord{$k};
  $src =~ s/ExprKind\.$k\b/$v/g;
}

# import 限定调用：(arch.arm64_enc).enc_* → arch_arm64_enc_enc_*
$src =~ s/\(\(arch\.arm64_enc\)\.(\w+)\)/arch_arm64_enc_$1/g;
$src =~ s/\(\(arch\.riscv64_enc\)\.(\w+)\)/arch_riscv64_enc_$1/g;
$src =~ s/\(\(arch\.x86_64_enc\)\.(\w+)\)/arch_x86_64_enc_$1/g;
# import 限定调用：(arch.arm64).emit_* → arch_arm64_emit_*
$src =~ s/\(\(arch\.(arm64|riscv64|x86_64)\)\.(\w+)\)/arch_$1_$2/g;

# TypeKind.TYPE_* → ast.h ASTTypeKind 序数
my %type_kind_ord = (
  TYPE_I32 => 0, TYPE_BOOL => 1, TYPE_U8 => 2, TYPE_U32 => 3, TYPE_U64 => 4, TYPE_I64 => 5,
  TYPE_USIZE => 6, TYPE_ISIZE => 7, TYPE_NAMED => 8, TYPE_PTR => 9, TYPE_ARRAY => 10,
  TYPE_SLICE => 11, TYPE_LINEAR => 12, TYPE_OWNED => 13, TYPE_VECTOR => 14, TYPE_F32 => 15,
  TYPE_F64 => 16, TYPE_VOID => 17, TYPE_UNION => 18,
);
for my $k (sort { length($b) <=> length($a) } keys %type_kind_ord) {
  my $v = $type_kind_ord{$k};
  $src =~ s/TypeKind\.$k\b/$v/g;
}

# 指针形参误 emit 为 value 字段访问
$src =~ s/\bctx\.(\w+)/ctx->$1/g;
$src =~ s/\belf_ctx\.(\w+)/elf_ctx->$1/g;
# CodegenOutBuf * out：out.len / out.data → out->（peephole/platform 路径）
$src =~ s/\bout\.len\b/out->len/g;
$src =~ s/\bout\.data\b/out->data/g;
# *Module 字段：incomplete backend_Module → ast_pool glue
$src =~ s/\bmod\.num_funcs\b/pipeline_module_num_funcs((struct ast_Module *)mod)/g;
$src =~ s/\(mod->num_funcs\)/pipeline_module_num_funcs((struct ast_Module *)mod)/g;
$src =~ s/\bmodule\.num_struct_layouts\b/pipeline_module_num_struct_layouts_at((struct ast_Module *)module)/g;
$src =~ s/\(module->num_struct_layouts\)/pipeline_module_num_struct_layouts_at((struct ast_Module *)module)/g;

# void 函数误 emit return 0
$src =~ s/(void backend_\w+\([^)]*\)\s*\{.*?)\n  return 0;\n(\})/$1\n$2/sg;

# codegen 双前缀
$src =~ s/\bcodegen_codegen_(\w+)/codegen_$1/g;

# -E backend.sx import glue 误加 backend_ 前缀（链入 pipeline_glue / ast_pool 真符号）
# 保留 pipeline_glue 中少数 backend_pipeline_expr_struct_lit_* 与 user_asm_seed 的 backend_pipeline_module_num_funcs
$src =~ s/\bbackend_pipeline_backend_/pipeline_backend_/g;
$src =~ s/\bbackend_pipeline_asm_/pipeline_asm_/g;
$src =~ s/\bbackend_pipeline_module_(?!num_funcs\b)/pipeline_module_/g;
$src =~ s/\bbackend_pipeline_expr_(?!struct_lit)/pipeline_expr_/g;
$src =~ s/\bbackend_pipeline_elf_ctx_/pipeline_elf_ctx_/g;
$src =~ s/\bbackend_pipeline_block_/pipeline_block_/g;
$src =~ s/\bbackend_backend_/backend_/g;
$src =~ s/\bbackend_asm_ctx_local_/asm_ctx_local_/g;

# platform_elf import pipeline 符号：partial 链 pipeline_sx.o（ast_pool）而非 platform_elf_pipeline_* 子集
$src =~ s/\bplatform_elf_pipeline_elf_ctx_/pipeline_elf_ctx_/g;
$src =~ s/\bplatform_elf_pipeline_elf_pgo_hot_enabled\b/pipeline_elf_pgo_hot_enabled/g;
$src =~ s/\bplatform_elf_pipeline_elf_label_mod_scope_reset\b/pipeline_elf_label_mod_scope_reset/g;
$src =~ s/\bplatform_elf_pipeline_elf_log_unresolved_patch\b/pipeline_elf_log_unresolved_patch/g;
$src =~ s/\bplatform_elf_pipeline_elf_write_o_pgo_to_buf\b/pipeline_elf_write_o_pgo_to_buf/g;
$src =~ s/\bplatform_elf_pipeline_elf_write_o_standard_to_buf_c\b/pipeline_elf_write_o_standard_to_buf_c/g;

# struct Expr 在前文使用、文末才定义：统一为已定义的 backend_Expr
$src =~ s/\bstruct Expr\b/struct backend_Expr/g;

# module->num_imports：incomplete backend_Module → parser glue
$src =~ s/\bmodule->num_imports\b/parser_get_module_num_imports((struct ast_Module *)module)/g;
$src =~ s/\bcur_mod->num_imports\b/parser_get_module_num_imports((struct ast_Module *)cur_mod)/g;

# backend_Type 未定义 → ast_Type
$src =~ s/\bstruct backend_Type\b/struct ast_Type/g;

# 残缺 import 段解析（-E 漏 let 声明）→ pipeline glue
$src =~ s/int backend_asm_import_segment_at_local\(struct backend_Module \* module, int32_t imp_ix, int32_t want_seg, int32_t \* ostr, int32_t \* olen\) \{.*?\n\}/int backend_asm_import_segment_at_local(struct backend_Module * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen) {\n  return pipeline_typeck_import_segment_at_c((struct ast_Module *)module, imp_ix, want_seg, ostr, olen);\n}/s;

# struct_layout 名称探测（漏 let nlen/j/eq）→ parser_asm C glue
$src =~ s/int backend_asm_module_named_type_has_struct_layout\(struct backend_Module \* module, uint8_t \* name, int32_t name_len\) \{.*?\n\}/int backend_asm_module_named_type_has_struct_layout(struct backend_Module * module, uint8_t * name, int32_t name_len) {\n  return parser_asm_struct_layout_name_exists_arr_c((struct ast_Module *)module, name, name_len);\n}/s;

# 按名查本模块函数下标（漏 let flen/fb/same）→ pipeline asm glue
$src =~ s/int32_t backend_asm_module_func_index_by_name\(struct backend_Module \* mod, uint8_t \* name, int32_t name_len\) \{.*?\n\}/int32_t backend_asm_module_func_index_by_name(struct backend_Module * mod, uint8_t * name, int32_t name_len) {\n  if (!mod || name_len <= 0 || name_len > 63) { return -1; }\n  int32_t fi = 0;\n  while (fi < pipeline_module_num_funcs((struct ast_Module *)mod)) {\n    int32_t flen = pipeline_asm_module_func_name_len_at((struct ast_Module *)mod, fi);\n    if (flen == name_len) {\n      uint8_t fb[64] = {};\n      pipeline_asm_module_func_name_copy64((struct ast_Module *)mod, fi, fb);\n      int32_t same = 1;\n      int32_t k = 0;\n      while (k < name_len) {\n        if (fb[k] != name[k]) { same = 0; break; }\n        k++;\n      }\n      if (same) { return fi; }\n    }\n    fi++;\n  }\n  return -1;\n}/s;

# backend_enc 相互调用：补前向声明
unless ($src =~ /backend_enc_cmp_setcc_movzbl_arch\s*\(/) {
  # defined later
}
if ($src =~ /backend_enc_cset_w0_from_cc_arch/ && $src !~ /extern int32_t backend_enc_cmp_setcc_movzbl_arch/) {
  $src =~ s/(struct backend_ElfCodegenCtx;\n)/$1extern int32_t backend_enc_cmp_setcc_movzbl_arch(struct backend_ElfCodegenCtx * elf_ctx, int32_t cc, int32_t ta);\n/
    or $src =~ s/(#include <stdlib\.h>)/$1\nextern int32_t backend_enc_cmp_setcc_movzbl_arch(struct backend_ElfCodegenCtx * elf_ctx, int32_t cc, int32_t ta);\n/;
}

sub enc_decl_infer {
  my ($src_ref, $fn) = @_;
  if ($$src_ref =~ /\b\Q$fn\E\s*\(([^)]*)\)/) {
    my @args = split /\s*,\s*/, $1;
  my @tys = ('backend_ElfCodegenCtx * elf_ctx');
    for my $i (1 .. $#args) {
      my $a = $args[$i];
      if ($a =~ /^(use_ptr|name|label|nm)$/) { push @tys, "uint8_t * $a"; }
      else { push @tys, "int32_t arg$i"; }
    }
    return "extern int32_t $fn(" . join(', ', @tys) . ");\n";
  }
  return "extern int32_t $fn(backend_ElfCodegenCtx * elf_ctx);\n";
}

sub load_glue_externs {
  my ($src_ref, $glue_path) = @_;
  open my $gf, '<', $glue_path or return '';
  my $body = do { local $/; <$gf> };
  close $gf;
  my %want;
  while ($$src_ref =~ /\b(ast_pipeline_\w+|ast_ast_arena_\w+|pipeline_typeck_import_segment_at_c|pipeline_type_kind_ord_at|parser_get_module_num_imports|codegen_import_path_to_c_prefix_into|backend_asm_module_named_type_has_struct_layout|backend_pipeline_asm_emit_func_param_is_ptr_by_name_c)\s*\(/g) {
    $want{$1} = 1;
  }
  my $out = '';
  my %done;
  while ($body =~ /^((?:extern\s+)?(?:struct\s+\w+\s+|int32_t|int|uint8_t|void|struct\s+ast_\w+\s+)[A-Za-z0-9_]+\s+[A-Za-z0-9_]+\s*\([^;]*\);)/mg) {
    my $line = $1;
    $line = "extern $line" unless $line =~ /^extern/;
    for my $sym (keys %want) {
      next if $done{$sym};
      if ($line =~ /\b\Q$sym\E\s*\(/) {
        $out .= "$line\n";
        $done{$sym} = 1;
      }
    }
  }
  return $out;
}

# types 绑定误解析为 codegen_ 前缀 → asm_types_（compat stub / 跳过 dep emit 时由 C 提供）
$src =~ s/\bcodegen_format_i32_to_buf\b/asm_types_format_i32_to_buf/g;
$src =~ s/\bcodegen_format_u32_to_buf\b/asm_types_format_u32_to_buf/g;
$src =~ s/\bcodegen_format_u32_hex8_to_buf\b/asm_types_format_u32_hex8_to_buf/g;
$src =~ s/\bcodegen_append_asm_line\b/asm_types_append_asm_line/g;

# *Module 形参字段访问 module.x → module->x
$src =~ s/\bmodule\.num_/module->num_/g;
$src =~ s/\bcur_mod\.num_/cur_mod->num_/g;

# void 函数误 emit return 0；Module 字段访问改直接调 glue（避免 incomplete struct）
$src =~ s/void backend_asm_hoist_top_level_lets_for_codegen\(struct backend_Module \* module, struct backend_ASTArena \* arena\) \{.*?\n\}/void backend_asm_hoist_top_level_lets_for_codegen(struct backend_Module * module, struct backend_ASTArena * arena) {\n  pipeline_module_hoist_top_level_lets_into_main((struct ast_Module *)module, (struct ast_ASTArena *)arena);\n}/s;

# 函数形参 struct *_ExprKind → int32_t
$src =~ s/struct\s+[A-Za-z0-9_]+_ExprKind\s+(\w+)\)/int32_t $1)/g;

# 残余 ExprKind 变体
$src =~ s/ExprKind\.EXPR_BINOP/51/g;

# ast_ast_arena_expr_get 按值拷贝 → pipeline glue（backend.sx M8 路径）
$src =~ s/int32_t backend_asm_init_is_empty_array_lit\(struct backend_ASTArena \* arena, int32_t init_ref\) \{.*?\n\}/int32_t backend_asm_init_is_empty_array_lit(struct backend_ASTArena * arena, int32_t init_ref) {\n  if (init_ref == 0) { return 0; }\n  if (pipeline_expr_kind_ord_at((struct ast_ASTArena *)arena, init_ref) != 46) { return 0; }\n  return pipeline_expr_array_lit_num_elems_at((struct ast_ASTArena *)arena, init_ref) == 0;\n}/s;

# arch_*_enc_enc_* 调用：从 backend_enc_dispatch.c 复制正确 extern（勿 void 桩，否则 cc 报参数个数不匹配）
$src =~ s/\/\* arch\.\*_enc：dispatch\/seed 链提供，cc -c 前向声明 \*\/\n(?:extern int32_t arch_(?:arm64|riscv64|x86_64)_enc_enc_[a-zA-Z0-9_]+\([^)]*\);\n)+//g;
my %enc_syms;
while ($src =~ /\b(arch_(?:arm64|riscv64|x86_64)_enc_enc_[a-zA-Z0-9_]+)\s*\(/g) {
  $enc_syms{$1} = 1;
}
if (keys %enc_syms) {
  my $dispatch_c = "$compiler_root/src/asm/backend_enc_dispatch.c";
  open my $dcf, '<', $dispatch_c or die "open $dispatch_c: $!\n";
  my %dispatch_decls;
  while (my $line = <$dcf>) {
    next unless $line =~ /^extern int32_t (arch_(?:arm64|riscv64|x86_64)_enc_enc_[a-zA-Z0-9_]+)\s*\(/;
    my $fn = $1;
    $line =~ s/struct platform_elf_ElfCodegenCtx/backend_ElfCodegenCtx/g;
    $dispatch_decls{$fn} = $line;
  }
  close $dcf;
  my $enc_decls = "/* arch.*_enc：dispatch/seed 链提供，cc -c 前向声明（签名来自 backend_enc_dispatch.c） */\n";
  $enc_decls .= "struct platform_elf_ElfCodegenCtx;\ntypedef struct platform_elf_ElfCodegenCtx backend_ElfCodegenCtx;\n";
  for my $fn (sort keys %enc_syms) {
    if (my $decl = $dispatch_decls{$fn}) {
      $enc_decls .= $decl;
    } else {
      $enc_decls .= enc_decl_infer(\$src, $fn);
    }
  }
  if ($src =~ /extern int32_t asm_types_append_asm_line\([^\n]+\n/) {
    $src =~ s/(extern int32_t asm_types_append_asm_line\([^\n]+\n)/$1$enc_decls/;
  } else {
    $src =~ s/(#include <stdlib\.h>)/$1\n$enc_decls/;
  }
}

# asm.types 残缺 emit（stmt_order 漏 let）：删实现，改 extern（链入 asm_backend_compat_stubs.c weak 符号）
my $asm_types_stub = <<'STUB';
/* asm.types：-E 跳过 dep 或 emit 残缺时由 compat stub 提供 */
extern int32_t asm_types_format_u32_to_buf(uint8_t * buf, int32_t off, int32_t max, int32_t u);
extern int32_t asm_types_format_i32_to_buf(uint8_t * buf, int32_t off, int32_t max, int32_t val);
extern int32_t asm_types_format_u32_hex8_to_buf(uint8_t * buf, int32_t off, int32_t val);
extern int32_t asm_types_append_asm_line(void * out, uint8_t * ptr, int32_t len);
STUB
$src =~ s/int32_t asm_types_format_u32_to_buf\(uint8_t \* buf, int32_t off, int32_t max, int32_t u\) \{.*?\n\}//sg;
$src =~ s/int32_t asm_types_format_i32_to_buf\(uint8_t \* buf, int32_t off, int32_t max, int32_t val\) \{.*?\n\}//sg;
$src =~ s/int32_t asm_types_format_u32_hex8_to_buf\(uint8_t \* buf, int32_t off, int32_t val\) \{.*?\n\}//sg;
if ($src !~ /extern int32_t asm_types_format_u32_to_buf/) {
  $src =~ s/(#include <stdlib\.h>)/$1\n$asm_types_stub/;
}

unless ($src =~ /#include <stddef\.h>/) {
  $src =~ s/#include <stdint\.h>/#include <stdint.h>\n#include <stddef.h>\n#include <string.h>\n#include <stdio.h>\n#include <stdlib.h>\n#include <unistd.h>/;
}
# ssize_t：-E 产出用 POSIX 类型，宿主 cc 无 unistd 时退化为 int64_t
unless ($src =~ /#include <unistd\.h>/ || $src =~ /typedef.*ssize_t/) {
  $src =~ s/(#include <stdlib\.h>)/$1\n#ifndef _SSIZE_T_DEFINED\ntypedef int64_t ssize_t;\n#define _SSIZE_T_DEFINED\n#endif/;
}

# 结构体字段误 emit 为 struct T[N] name → struct T name[N]
$src =~ s/struct\s+([A-Za-z0-9_]+)\[(\d+)\]\s+(\w+);/struct $1 $3\[$2\];/g;

# -E 截断导致 ElfCodegenCtx 缺 syms/code_data 等：用 pipeline_gen 完整布局替换
my $elf_ctx_full = <<'ELFCTX';
struct platform_elf_ElfCodegenCtx {
  int32_t code_len;
  struct platform_elf_ElfLabelEntry labels[16384];
  int32_t num_labels;
  struct platform_elf_ElfPatchEntry patches[16384];
  int32_t num_patches;
  struct platform_elf_ElfRelocEntry relocs[16384];
  uint8_t reloc_sym_names[16384][64];
  int32_t num_relocs;
  struct platform_elf_ElfSymEntry syms[16384];
  int32_t num_syms;
  int32_t sym_name_len;
  int32_t e_machine;
  int32_t reloc_type_r_pc32;
  int32_t current_frame_size;
  int32_t macho_leading_underscore;
  int32_t code_hot_len;
  int32_t emit_hot;
  uint8_t code_data[8716288];
  uint8_t code_hot_data[1048576];
  uint8_t sym_name_data[131072];
};
ELFCTX
for my $pfx (qw(platform_elf platform_macho platform_coff)) {
  my $full = $elf_ctx_full;
  $full =~ s/platform_elf/$pfx/g;
  $src =~ s/struct ${pfx}_ElfCodegenCtx \{.*?\n\};/$full/s;
}

# backend.sx import elf.ElfCodegenCtx → backend_ElfCodegenCtx；与 platform_elf 同布局（-E 截断时二者并存导致 cc 不兼容）
if ($src =~ /struct platform_elf_ElfCodegenCtx \{/) {
  unless ($src =~ /typedef struct platform_elf_ElfCodegenCtx backend_ElfCodegenCtx/) {
    $src =~ s/(struct platform_elf_ElfCodegenCtx \{.*?\n\};)/$1\n\ntypedef struct platform_elf_ElfCodegenCtx backend_ElfCodegenCtx;\n/s;
  }
  $src =~ s/\bstruct backend_ElfCodegenCtx\b/backend_ElfCodegenCtx/g;
  $src =~ s/\bstruct platform_elf_ElfCodegenCtx \*/backend_ElfCodegenCtx */g;
}

# peephole 模块 import elf.ElfCodegenCtx → 与 platform_elf 同布局
$src =~ s/\bstruct peephole_ElfCodegenCtx\b/backend_ElfCodegenCtx/g;

# -E 截断：platform_elf 结构体定义落在 peephole_elf_* 之后 → 前移到首次使用之前
if ($src =~ /int32_t peephole_peephole_elf_u32_eq/s && $src =~ /struct platform_elf_ElfLabelEntry \{/s) {
  if (index($src, 'peephole_peephole_elf_u32_eq') < index($src, 'struct platform_elf_ElfLabelEntry {')) {
    if ($src =~ /(struct platform_elf_ElfLabelEntry \{.*?\n\};\n\nstruct platform_elf_ElfPatchEntry \{.*?\n\};\n\nstruct platform_elf_ElfRelocEntry \{.*?\n\};\n\nstruct platform_elf_ElfSymEntry \{.*?\n\};\n\nstruct platform_elf_ElfCodegenCtx \{.*?\n\};)/s) {
      my $elf_structs = $1;
      while ($src =~ s/\n#include <stdint\.h>\n\Q$elf_structs\E\n//s) { }
      while ($src =~ s/\n\Q$elf_structs\E\n+//s) { }
      $src =~ s/(int32_t peephole_peephole_elf_u32_eq)/$elf_structs\n\n$1/s;
    }
  }
}
# 文件中部重复 #include（-E 拼接 artifact）
$src =~ s/\n#include <stdint\.h>\n(?=#include|\nstruct platform_)/\n/g;

# -E 尾部重复 emit 的 asm_types/backend 结构体（保留 static err / init_globals）
if ($src =~ /\nstruct asm_types_CodegenOutBuf \{/ && $src =~ /static int32_t err;/) {
  $src =~ s/\n#include <stdint\.h>\nstruct asm_types_CodegenOutBuf \{.*?(?=static int32_t err;)/\n/s;
}

# backend_asm_module_named_type_has_struct_layout 在定义前被引用（void* 避免 incomplete struct backend_Module 冲突）
$src =~ s/extern int backend_asm_module_named_type_has_struct_layout\(struct backend_Module \* module, uint8_t \* name, int32_t name_len\);\n\n//;
$src =~ s/int backend_asm_module_named_type_has_struct_layout\(struct backend_Module \* module, uint8_t \* name, int32_t name_len\)/int backend_asm_module_named_type_has_struct_layout(void * module, uint8_t * name, int32_t name_len)/g;
unless ($src =~ /int backend_asm_module_named_type_has_struct_layout\(void \* module/) {
  $src =~ s/(int32_t backend_asm_names_equal\(uint8_t \* a, int32_t a_len, uint8_t \* b, int32_t b_len\))/int backend_asm_module_named_type_has_struct_layout(void * module, uint8_t * name, int32_t name_len);\n$1/s;
}

# peephole 文本优化：漏 let / 缺 return → 补局部或最小桩
$src =~ s/(int32_t peephole_peephole_remove_redundant_push_pop\(struct peephole_CodegenOutBuf \* out\) \{\n)/$1  int32_t line_end = 0;\n  int32_t line_len = 0;\n  int32_t next_start = 0;\n  int32_t j = 0;\n/g;
$src =~ s/(int32_t peephole_peephole_remove_noop_mov_rax_rax\(struct peephole_CodegenOutBuf \* out\) \{\n)(?!  int32_t line_end)/$1  int32_t line_end = 0;\n  int32_t j = 0;\n/g;
$src =~ s/(int32_t peephole_peephole_remove_noop_mov_x0_x0\(struct peephole_CodegenOutBuf \* out\) \{\n)(?!  int32_t line_end)/$1  int32_t line_end = 0;\n  int32_t j = 0;\n/g;
$src =~ s/(int32_t peephole_peephole_remove_redundant_push_pop\(struct peephole_CodegenOutBuf \* out\) \{.*?)\n\}\n(int32_t peephole_peephole_remove_noop_mov_rax_rax)/$1\n  return 0;\n}\n$2/s;
# peephole ELF 路径 stmt_order 漏 let：seed partial 用可编译桩（后续 shux-seed-phase1 重 -E 替换）
$src =~ s/int32_t peephole_peephole_elf_region_has_meta\(struct platform_elf_ElfCodegenCtx \* ctx, int32_t pos, int32_t len\) \{.*?\n\}/int32_t peephole_peephole_elf_region_has_meta(struct platform_elf_ElfCodegenCtx * ctx, int32_t pos, int32_t len) {\n  (void)ctx; (void)pos; (void)len;\n  return 0;\n}/s;
$src =~ s/void peephole_peephole_elf_shift_meta_after_remove\(struct platform_elf_ElfCodegenCtx \* ctx, int32_t pos, int32_t len\) \{.*?\n\}/void peephole_peephole_elf_shift_meta_after_remove(struct platform_elf_ElfCodegenCtx * ctx, int32_t pos, int32_t len) {\n  (void)ctx; (void)pos; (void)len;\n}/s;
$src =~ s/int32_t peephole_peephole_elf_remove_redundant_push_pop\(struct platform_elf_ElfCodegenCtx \* ctx, int32_t e_machine\) \{.*?\n\}/int32_t peephole_peephole_elf_remove_redundant_push_pop(struct platform_elf_ElfCodegenCtx * ctx, int32_t e_machine) {\n  (void)ctx; (void)e_machine;\n  return 0;\n}/s;
$src =~ s/int32_t peephole_peephole_elf_remove_redundant_spill_reg_mov_pair\(struct platform_elf_ElfCodegenCtx \* ctx\) \{.*?\n\}/int32_t peephole_peephole_elf_remove_redundant_spill_reg_mov_pair(struct platform_elf_ElfCodegenCtx * ctx) {\n  (void)ctx;\n  return 0;\n}/s;
$src =~ s/int32_t peephole_peephole_elf_remove_redundant_mov_x2_pair\(struct platform_elf_ElfCodegenCtx \* ctx\) \{.*?\n\}/int32_t peephole_peephole_elf_remove_redundant_mov_x2_pair(struct platform_elf_ElfCodegenCtx * ctx) {\n  (void)ctx;\n  return 0;\n}/s;

# -E 截断：backend_fold_expr_is_add_kind 缺 fallthrough return 0（cc -Wreturn-type 失败）
$src =~ s/int32_t backend_fold_expr_is_add_kind\(struct backend_ASTArena \* arena, int32_t expr_ref\) \{\n  int32_t k = codegen_pipeline_expr_kind_ord_at\(arena, expr_ref\);\n  if \(\(\(k ==4\) \|\| \(k ==51\)\)\) \{\n    return 1;\n  \}\n\}/int32_t backend_fold_expr_is_add_kind(struct backend_ASTArena * arena, int32_t expr_ref) {\n  int32_t k = codegen_pipeline_expr_kind_ord_at(arena, expr_ref);\n  if (((k ==4) || (k ==51))) {\n    return 1;\n  }\n  return 0;\n}/s;

# -E 截断：backend_asm_local_var_slot_holds_indirect_ptr 缺 fallthrough return 0
$src =~ s/\}\n  return 0;\n\nint32_t backend_enc_local_slot_ptr_or_addr_arch/  return 0;\n}\nint32_t backend_enc_local_slot_ptr_or_addr_arch/s;
$src =~ s/(  if \(\(\(\(\(vtyp\.kind\) ==\(8\)\) && \(mod !=\(\(struct ast_Module \*\)\(0\)\)\)\) && backend_asm_module_named_type_has_struct_layout\(mod, &\(\(\(vtyp\.name\)\)\[0\]\), \(vtyp\.name_len\)\)\)\) \{\n    return 1;\n  \}\n)\}(\nint32_t backend_enc_local_slot_ptr_or_addr_arch)/$1  return 0;\n}$2/s;

# peephole 函数漏 let line_end/j/line_len/next_start（非上述具名函数）
$src =~ s/((?:int32_t|void)\s+peephole_\w+\([^{]+\)\s*\{)(?![^}]*\bint32_t\s+line_end\b)([^}]*\bline_end\b)/$1\n  int32_t line_end = 0;\n  int32_t line_len = 0;\n  int32_t next_start = 0;\n  int32_t j = 0;\n$2/sg;

# stmt_order 漏 let 的 backend_fold / 部分 backend_asm：seed partial 可编译桩（phase1 重 -E 后替换）
sub stub_int32_fn_body {
  my ($src_ref, $fn) = @_;
  my $pos = 0;
  while (($pos = index($$src_ref, "int32_t $fn(", $pos)) >= 0) {
    my $brace = index($$src_ref, '{', $pos);
    last if $brace < 0;
    my $depth = 1;
    my $i = $brace + 1;
    while ($depth > 0 && $i < length($$src_ref)) {
      my $c = substr($$src_ref, $i, 1);
      $depth++ if $c eq '{';
      $depth-- if $c eq '}';
      $i++;
    }
    next if $depth != 0;
    my $sig = substr($$src_ref, $pos, $brace - $pos + 1);
    substr($$src_ref, $pos, $i - $pos, "${sig} return 0; }");
    $pos = $pos + length($sig) + 12;
  }
}
my @stub_fold_asm = qw(
  backend_fold_func_return_operand_ref
  backend_fold_func_x_plus_k_chain
  backend_fold_body_has_call_or_nested_loop
  backend_fold_affine_i_plus_k_expr
  backend_fold_is_assign_s_plus_affine_i
  backend_fold_parse_affine_sum_body
  backend_fold_block_let_struct_lit_i32_sum
  backend_fold_is_assign_s_plus_pair_field_sum_call
  backend_fold_parse_struct_pair_n2_body
  backend_fold_is_assign_s_plus_const_field_call
  backend_fold_parse_count_up_const_field_call_body
  backend_fold_parse_count_up_body
  backend_fold_block_let_init_lit
  backend_asm_import_path_slice_equal
  backend_asm_import_binding_name_equal
  backend_asm_fill_c_prefix_from_module_import
  backend_asm_resolve_whole_import_qualified_symbol
  backend_asm_index_elem_byte_sz
  backend_asm_array_lit_elem_byte_sz
  backend_asm_array_lit_reserve_stack_bytes
  backend_asm_struct_lit_reserve_stack_bytes
  backend_try_fold_count_up_while_elf
  backend_try_inline_x_plus_k_call_elf
  backend_try_inline_param0_field_sum_call_elf
  platform_elf_elf_add_patch
  platform_elf_elf_write_u32_le
  platform_macho_write_macho_o_to_buf
  platform_macho_macho_reloc_sym_name_buf
  platform_macho_macho_reloc_sym_defined
  platform_coff_write_coff_o_to_buf
  peephole_peephole_remove_empty_lines
  arch_riscv64_emit_prologue
  arch_riscv64_emit_epilogue
  arch_riscv64_emit_cmp_setcc
  arch_riscv64_emit_store_rax_to_rbx_indirect
  arch_riscv64_emit_store_rax_to_rbx_offset
  arch_arm64_emit_store_rax_to_rbx_offset
  arch_arm64_emit_store_rax_to_rbx_indirect
  arch_x86_64_emit_store_rax_to_rbx_indirect
  arch_x86_64_emit_label
);
for my $fn (@stub_fold_asm) {
  stub_int32_fn_body(\$src, $fn);
}
# bool 返回的 fold 探测函数
$src =~ s/int backend_asm_import_segment_at_local\(struct backend_Module \* module, int32_t imp_ix, int32_t want_seg, int32_t \* ostr, int32_t \* olen\) \{.*?\n\}/int backend_asm_import_segment_at_local(struct backend_Module * module, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen) {\n  return pipeline_typeck_import_segment_at_c((struct ast_Module *)module, imp_ix, want_seg, ostr, olen);\n}/s unless $src =~ /pipeline_typeck_import_segment_at_c\(\(struct ast_Module \*\)module, imp_ix/;

# 截断的 -E 尾部：init_globals 须在 module/arena/out/ctx/elf_ctx 静态变量之后
if ($src =~ /static void init_globals\(void\)/ && $src =~ /static struct backend_Module \* module;/s) {
  my $globals = "static struct backend_Module * module;\nstatic struct backend_ASTArena * arena;\nstatic struct backend_CodegenOutBuf * out;\nstatic struct backend_PipelineDepCtx * ctx;\nstatic backend_ElfCodegenCtx * elf_ctx;\n";
  $src =~ s/\nstatic struct backend_Module \* module;\nstatic struct backend_ASTArena \* arena;\nstatic struct backend_CodegenOutBuf \* out;\nstatic struct backend_PipelineDepCtx \* ctx;\nstatic backend_ElfCodegenCtx \* elf_ctx;\n//s;
  $src =~ s/(static int32_t err;)/$globals$1/s unless index($src, 'static struct backend_Module * module;') < index($src, 'static int32_t err;');
}
if ($src =~ /static void init_globals\(void\) \{/ && $src !~ /static struct backend_Module \* module;/s) {
  $src =~ s/(static int32_t err;)/static struct backend_Module * module;\nstatic struct backend_ASTArena * arena;\nstatic struct backend_CodegenOutBuf * out;\nstatic struct backend_PipelineDepCtx * ctx;\nstatic backend_ElfCodegenCtx * elf_ctx;\n$1/s;
}

my $glue_stub = <<'GLUE';
/* pipeline/ast glue：cc -c 前向声明（定义在 pipeline_glue.c / ast_pool.c） */
typedef struct backend_ASTArena ast_ASTArena;
struct ast_Module;
struct ast_Type {
  int32_t kind;
  int32_t elem_type_ref;
  int32_t array_size;
  uint8_t name[64];
  int32_t name_len;
};
struct ast_Expr;
typedef struct backend_Expr ast_Expr;
extern ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena * a, int32_t ref);
extern struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena * a, int32_t ref);
extern int32_t ast_pipeline_expr_call_num_args_at(struct ast_ASTArena * a, int32_t expr_ref);
extern int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena * a, int32_t expr_ref, int32_t idx);
extern int32_t ast_pipeline_module_import_binding_name_len(struct ast_Module * m, int32_t idx);
extern int32_t parser_get_module_num_imports(struct ast_Module * m);
extern int32_t pipeline_typeck_import_segment_at_c(struct ast_Module * m, int32_t imp_ix, int32_t want_seg, int32_t * ostr, int32_t * olen);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena * a, int32_t ref);
extern int32_t pipeline_module_num_funcs(struct ast_Module * m);
extern int32_t pipeline_module_num_struct_layouts_at(struct ast_Module * m);
extern int32_t parser_asm_struct_layout_name_exists_arr_c(void * module, uint8_t * nm, int32_t nlen);
extern int32_t asm_types_elf_read_u32_le(void * ctx, int32_t pos);
GLUE
if (index($src, 'pipeline/ast glue') < 0 && $src =~ /\bast_(?:pipeline|ast_arena)_\w+\s*\(/) {
  $src =~ s/(#include <stdlib\.h>)/$1\n$glue_stub/;
}
# glue 块与 -E extern 重复声明（backend_ASTArena vs ast_ASTArena）→ 删 ast 版
$src =~ s/\nextern int32_t pipeline_expr_kind_ord_at\(struct ast_ASTArena \*[^;]+;\n//g;
$src =~ s/\nextern int32_t pipeline_expr_array_lit_num_elems_at\(struct ast_ASTArena \*[^;]+;\n//g;

if ($src ne $orig) {
  seek $fh, 0, 0;
  print $fh $src;
  truncate $fh, length($src);
}
close $fh;
