#!/usr/bin/env perl
# M8-tail：将 backend.sx 大 emit 函数体替换为单行 C/partial 薄包装（恢复自举 second pass）。
use strict;
use warnings;
use utf8;

my $path = shift @ARGV // 'src/asm/backend.sx';
open my $fh, '<', $path or die "open $path: $!";
my $src = do { local $/; <$fh> };
close $fh;

my $extern_block = <<'SX';
/** M8-tail C/partial 薄包装 extern（pipeline_glue / compat_stubs / call_dispatch）。 */
extern function pipeline_asm_compute_frame_size_c(num_params: i32, arena: *ASTArena, block_ref: i32): i32;
extern function pipeline_asm_fill_param_slots(ctx: *AsmFuncCtx, mod: *Module, func_index: i32): void;
extern function pipeline_asm_fill_local_slots(ctx: *AsmFuncCtx, arena: *ASTArena, block_ref: i32): void;
extern function pipeline_asm_emit_block_inits_elf_c(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, block_ref: i32, ctx: *AsmFuncCtx, ta: i32, slot_base: i32): i32;
extern function pipeline_asm_emit_block_inits_c(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, ctx: *AsmFuncCtx, target_arch: i32, slot_base: i32): i32;
extern function pipeline_asm_emit_block_body_c(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, ctx: *AsmFuncCtx, target_arch: i32): i32;
extern function pipeline_asm_emit_while_loop_c(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, loop_idx: i32, ctx: *AsmFuncCtx, target_arch: i32): i32;
extern function pipeline_asm_emit_for_loop_c(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, for_idx: i32, ctx: *AsmFuncCtx, target_arch: i32): i32;
extern function pipeline_asm_emit_if_then_block_body_text_c(arena: *ASTArena, out: *CodegenOutBuf, then_block_ref: i32, ctx: *AsmFuncCtx, target_arch: i32): i32;
extern function pipeline_asm_emit_expr_c(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *AsmFuncCtx, target_arch: i32): i32;
extern function pipeline_asm_emit_expr_call_c(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *AsmFuncCtx, target_arch: i32): i32;
extern function pipeline_asm_emit_expr_method_call_c(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *AsmFuncCtx, target_arch: i32): i32;
extern function pipeline_asm_emit_next_label_c(ctx: *AsmFuncCtx, buf: *u8, buf_size: i32): i32;
extern function pipeline_asm_format_label_id_c(buf: *u8, buf_size: i32, id: i32): i32;
extern function pipeline_asm_emit_if_then_block_body_elf_c(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, then_block_ref: i32, ctx: *AsmFuncCtx, ta: i32): i32;
extern function pipeline_asm_emit_while_loop_elf_c(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, block_ref: i32, loop_idx: i32, ctx: *AsmFuncCtx, ta: i32): i32;
extern function pipeline_asm_emit_for_loop_elf_c(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, block_ref: i32, for_idx: i32, ctx: *AsmFuncCtx, ta: i32): i32;
extern function pipeline_asm_emit_expr_elf_c(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, expr_ref: i32, ctx: *AsmFuncCtx, ta: i32): i32;
extern function pipeline_asm_emit_call_elf_c(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, expr_ref: i32, ctx: *AsmFuncCtx, ta: i32): i32;
extern function pipeline_asm_emit_method_call_elf_c(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, expr_ref: i32, ctx: *AsmFuncCtx, ta: i32): i32;
extern function pipeline_asm_emit_call_args_elf_c(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, expr_ref: i32, ctx: *AsmFuncCtx, ta: i32, nargs: i32): i32;

SX

unless ($src =~ /pipeline_asm_compute_frame_size_c/) {
  $src =~ s/(extern function backend_emit_block_body_sync_elf[^\n]+\n)/$1$extern_block/;
}

sub replace_func {
  my ($name, $body) = @_;
  my $start = index($src, "function $name(");
  if ($start < 0) {
    warn "skip missing: $name\n";
    return;
  }
  my $brace = index($src, '{', $start);
  die "no brace: $name\n" if $brace < 0;
  my $depth = 0;
  my $i = $brace;
  my $len = length($src);
  for (; $i < $len; $i++) {
    my $c = substr($src, $i, 1);
    $depth++ if $c eq '{';
    $depth-- if $c eq '}';
    last if $depth == 0;
  }
  die "unbalanced: $name\n" if $depth != 0;
  $i++;
  substr($src, $start, $i - $start, $body);
}

replace_func('compute_frame_size', <<'SX');
/** 栈帧大小；M8-tail 委托 C glue（形参 + const/let + temp）。 */
function compute_frame_size(num_params: i32, arena: *ASTArena, block_ref: i32): i32 {
  return pipeline_asm_compute_frame_size_c(num_params, arena, block_ref);
}
SX

replace_func('fill_param_slots', <<'SX');
/** 形参槽；M8-tail 委托 C glue pipeline_asm_fill_param_slots。 */
function fill_param_slots(ctx: *AsmFuncCtx, mod: *Module, func_index: i32): void {
  pipeline_asm_fill_param_slots(ctx, mod, func_index);
}
SX

replace_func('fill_local_slots', <<'SX');
/** 块内 const/let 槽；M8-tail 委托 C glue pipeline_asm_fill_local_slots。 */
function fill_local_slots(ctx: *AsmFuncCtx, arena: *ASTArena, block_ref: i32): void {
  pipeline_asm_fill_local_slots(ctx, arena, block_ref);
}
SX

replace_func('asm_emit_call_args_elf', <<'SX');
/** ELF call 实参；M8-tail 委托 C glue pipeline_asm_emit_call_args_elf_c。 */
function asm_emit_call_args_elf(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, e: Expr, expr_ref: i32, ctx: *AsmFuncCtx, ta: i32, nargs: i32): i32 {
  return pipeline_asm_emit_call_args_elf_c(arena, elf_ctx, expr_ref, ctx, ta, nargs);
}
SX

replace_func('emit_if_then_block_body_text', <<'SX');
/** if then 块 text 路径；M8-tail 委托 partial（C glue）。 */
function emit_if_then_block_body_text(arena: *ASTArena, out: *CodegenOutBuf, then_block_ref: i32, ctx: *AsmFuncCtx, target_arch: i32): i32 {
  return pipeline_asm_emit_if_then_block_body_text_c(arena, out, then_block_ref, ctx, target_arch);
}
SX

replace_func('emit_if_then_block_body_elf', <<'SX');
/** if then 块 ELF 路径；M8-tail 委托 C glue pipeline_asm_emit_if_then_block_body_elf_c。 */
function emit_if_then_block_body_elf(
  arena: *ASTArena,
  elf_ctx: *platform.elf.ElfCodegenCtx,
  then_block_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32
): i32 {
  return pipeline_asm_emit_if_then_block_body_elf_c(arena, elf_ctx, then_block_ref, ctx, ta);
}
SX

replace_func('emit_expr_call', <<'SX');
/** text call 表达式；M8-tail 委托 partial backend_emit_expr_call（C glue）。 */
function emit_expr_call(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, e: Expr, ctx: *AsmFuncCtx, target_arch: i32): i32 {
  return pipeline_asm_emit_expr_call_c(arena, out, expr_ref, ctx, target_arch);
}
SX

replace_func('emit_expr_method_call', <<'SX');
/** text method_call；M8-tail 委托 partial（C glue）。 */
function emit_expr_method_call(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, e: Expr, ctx: *AsmFuncCtx, target_arch: i32): i32 {
  return pipeline_asm_emit_expr_method_call_c(arena, out, expr_ref, ctx, target_arch);
}
SX

replace_func('emit_expr_elf_method_call', <<'SX');
/** ELF method_call；M8-tail 委托 C glue pipeline_asm_emit_method_call_elf_c。 */
function emit_expr_elf_method_call(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, expr_ref: i32, e: Expr, ctx: *AsmFuncCtx, ta: i32): i32 {
  return pipeline_asm_emit_method_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
}
SX

replace_func('emit_expr_elf_call', <<'SX');
/** ELF call 表达式；M8-tail 委托 C glue pipeline_asm_emit_call_elf_c。 */
function emit_expr_elf_call(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, expr_ref: i32, e: Expr, ctx: *AsmFuncCtx, ta: i32): i32 {
  return pipeline_asm_emit_call_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
}
SX

replace_func('emit_expr', <<'SX');
/** text 表达式发射；M8-tail 委托 partial backend_emit_expr（C glue）。 */
function emit_expr(arena: *ASTArena, out: *CodegenOutBuf, expr_ref: i32, ctx: *AsmFuncCtx, target_arch: i32): i32 {
  return pipeline_asm_emit_expr_c(arena, out, expr_ref, ctx, target_arch);
}
SX

replace_func('emit_expr_elf', <<'SX');
/** ELF 表达式发射；M8-tail 委托 C glue pipeline_asm_emit_expr_elf_c（fast + rec / partial 慢路径）。 */
function emit_expr_elf(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, expr_ref: i32, ctx: *AsmFuncCtx, ta: i32): i32 {
  return pipeline_asm_emit_expr_elf_c(arena, elf_ctx, expr_ref, ctx, ta);
}
SX

replace_func('emit_block_inits_elf', <<'SX');
/** ELF 块 const/let 初始化；M8-tail 委托 C glue pipeline_asm_emit_block_inits_elf_c。 */
function emit_block_inits_elf(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, block_ref: i32, ctx: *AsmFuncCtx, ta: i32, slot_base: i32): i32 {
  return pipeline_asm_emit_block_inits_elf_c(arena, elf_ctx, block_ref, ctx, ta, slot_base);
}
SX

replace_func('emit_while_loop_elf', <<'SX');
/** ELF while 循环；M8-tail 委托 partial backend_emit_while_loop_elf（C glue）。 */
function emit_while_loop_elf(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, block_ref: i32, loop_idx: i32, ctx: *AsmFuncCtx, ta: i32): i32 {
  return pipeline_asm_emit_while_loop_elf_c(arena, elf_ctx, block_ref, loop_idx, ctx, ta);
}
SX

replace_func('emit_for_loop_elf', <<'SX');
/** ELF for 循环；M8-tail 委托 partial backend_emit_for_loop_elf（C glue）。 */
function emit_for_loop_elf(arena: *ASTArena, elf_ctx: *platform.elf.ElfCodegenCtx, block_ref: i32, for_idx: i32, ctx: *AsmFuncCtx, ta: i32): i32 {
  return pipeline_asm_emit_for_loop_elf_c(arena, elf_ctx, block_ref, for_idx, ctx, ta);
}
SX

replace_func('emit_block_inits', <<'SX');
/** text 块 const/let 初始化；M8-tail 委托 partial backend_emit_block_inits（C glue）。 */
function emit_block_inits(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, ctx: *AsmFuncCtx, target_arch: i32, slot_base: i32): i32 {
  return pipeline_asm_emit_block_inits_c(arena, out, block_ref, ctx, target_arch, slot_base);
}
SX

replace_func('emit_next_label', <<'SX');
/** 生成唯一局部标签；M8-tail 委托 C glue pipeline_asm_emit_next_label_c。 */
function emit_next_label(ctx: *AsmFuncCtx, buf: *u8, buf_size: i32): i32 {
  return pipeline_asm_emit_next_label_c(ctx, buf, buf_size);
}
SX

replace_func('format_label_id', <<'SX');
/** 格式化 ".L_<id>"；M8-tail 委托 C glue pipeline_asm_format_label_id_c。 */
function format_label_id(buf: *u8, buf_size: i32, id: i32): i32 {
  return pipeline_asm_format_label_id_c(buf, buf_size, id);
}
SX

replace_func('emit_while_loop', <<'SX');
/** text while 循环；M8-tail 委托 partial backend_emit_while_loop（C glue）。 */
function emit_while_loop(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, loop_idx: i32, ctx: *AsmFuncCtx, target_arch: i32): i32 {
  return pipeline_asm_emit_while_loop_c(arena, out, block_ref, loop_idx, ctx, target_arch);
}
SX

replace_func('emit_for_loop', <<'SX');
/** text for 循环；M8-tail 委托 partial backend_emit_for_loop（C glue）。 */
function emit_for_loop(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, for_idx: i32, ctx: *AsmFuncCtx, target_arch: i32): i32 {
  return pipeline_asm_emit_for_loop_c(arena, out, block_ref, for_idx, ctx, target_arch);
}
SX

replace_func('emit_block_body', <<'SX');
/** text 块体 stmt_order；M8-tail 委托 partial backend_emit_block_body（C glue）。 */
function emit_block_body(arena: *ASTArena, out: *CodegenOutBuf, block_ref: i32, ctx: *AsmFuncCtx, target_arch: i32): i32 {
  return pipeline_asm_emit_block_body_c(arena, out, block_ref, ctx, target_arch);
}
SX

open my $out, '>', $path or die "write $path: $!";
print {$out} $src;
close $out;
print "m8_tail_thin_backend_sx.pl: OK $path\n";
