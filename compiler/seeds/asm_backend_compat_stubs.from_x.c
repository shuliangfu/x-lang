/* seeds/asm_backend_compat_stubs.from_x.c — G-02f-15 product TU
 * Product object from this seed; logic still C until full .x port.
 */
/**
 * asm_backend_compat_stubs.c — pipeline_glue 与 asm_backend_partial.o 的符号桥
 *
 * pipeline_glue.c（编入 pipeline_x.o）仍引用若干 backend_* 名，全量 asm.x -E 后部分已改名或未导出；
 * 本 TU 提供薄转发，使 bootstrap-driver-seed / shu_stage2 在 macOS arm64 上可链通。
 */
#include <stdint.h>
#include <string.h>

struct platform_elf_ElfCodegenCtx;
struct ast_ASTArena;
struct codegen_CodegenOutBuf;

/** 与 codegen.x CodegenOutBuf 一致（8MiB + len）。 */
#define SHUX_CODEGEN_OUTBUF_CAP 9437184
typedef struct {
  uint8_t data[SHUX_CODEGEN_OUTBUF_CAP];
  int32_t len;
} ShuCodegenOutBuf;

/**
 * 向 CodegenOutBuf 追加一行汇编（bytes + '\n'）。
 * build_asm/types.o 自举 asm 仅 emit format_u32_to_buf，arch 模块仍引用本符号。
 * weak：strict 链已链 build_asm/types.o 时由真符号覆盖，避免 duplicate symbol。
 */
__attribute__((weak)) int32_t append_asm_line(struct codegen_CodegenOutBuf *out, uint8_t *ptr, int32_t len) {
  ShuCodegenOutBuf *buf = (ShuCodegenOutBuf *)out;
  int32_t i;
  if (!buf || !ptr || len < 0)
    return -1;
  for (i = 0; i < len; i++) {
    if (buf->len >= SHUX_CODEGEN_OUTBUF_CAP)
      return -1;
    buf->data[buf->len++] = ptr[i];
  }
  if (buf->len >= SHUX_CODEGEN_OUTBUF_CAP)
    return -1;
  buf->data[buf->len++] = (uint8_t)'\n';
  return 0;
}

/** 内部 u32 格式化，避免依赖 build_asm/types.o 的 format_u32_to_buf。 */
static int32_t shu_format_u32_to_buf(uint8_t *buf, int32_t off, int32_t max, uint32_t u) {
  static const uint8_t digit_chars[10] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
  uint8_t tmp[10];
  int32_t num_digits = 0;
  uint32_t v = u;
  int32_t idx;
  if (!buf || max < 1)
    return -1;
  while (v > 0 && num_digits < 10) {
    tmp[num_digits++] = digit_chars[v % 10u];
    v /= 10u;
  }
  if (num_digits == 0) {
    buf[off] = digit_chars[0];
    return 1;
  }
  if (num_digits > max)
    return -1;
  idx = 0;
  while (idx < num_digits) {
    buf[off + idx] = tmp[num_digits - 1 - idx];
    idx++;
  }
  return num_digits;
}

/**
 * 将 i32 十进制写入 buf[off..]；与 types.x format_i32_to_buf 语义一致。
 * weak：strict 链 build_asm/types.o 已提供时勿 duplicate。
 */
__attribute__((weak)) int32_t format_i32_to_buf(uint8_t *buf, int32_t off, int32_t max, int32_t val) {
  static const uint8_t min_i32[11] = {'-', '2', '1', '4', '7', '4', '8', '3', '6', '4', '8'};
  uint32_t u;
  int32_t k;
  if (!buf || max < 1)
    return -1;
  if (val < 0) {
    u = (uint32_t)(0 - val);
    if ((int32_t)u < 0) {
      if (max < 11)
        return -1;
      for (k = 0; k < 11; k++)
        buf[off + k] = min_i32[k];
      return 11;
    }
    if (max < 1)
      return -1;
    buf[off] = (uint8_t)'-';
    {
      int32_t n = shu_format_u32_to_buf(buf, off + 1, max - 1, u);
      if (n < 0)
        return -1;
      return n + 1;
    }
  }
  return shu_format_u32_to_buf(buf, off, max, (uint32_t)val);
}

/**
 * Linux ELF：arch/*.x 经 import types 解析为 asm_types_* 链名；build_asm/types.o 导出 append_asm_line。
 * weak 转发，strict 链 types.o 真符号存在时仍可由 append_asm_line 覆盖本 TU 弱定义。
 */
__attribute__((weak)) int32_t asm_types_append_asm_line(struct codegen_CodegenOutBuf *out, uint8_t *ptr, int32_t len) {
  return append_asm_line(out, ptr, len);
}

/** 与 asm_types_append_asm_line 同理：types.format_i32_to_buf → asm_types_format_i32_to_buf。 */
__attribute__((weak)) int32_t asm_types_format_i32_to_buf(uint8_t *buf, int32_t off, int32_t max, int32_t val) {
  return format_i32_to_buf(buf, off, max, val);
}

/** types.format_u32_to_buf → asm_types_format_u32_to_buf（partial seed -E 路径）。 */
__attribute__((weak)) int32_t asm_types_format_u32_to_buf(uint8_t *buf, int32_t off, int32_t max, int32_t u) {
  return shu_format_u32_to_buf(buf, off, max, (uint32_t)u);
}

/** types.format_u32_hex8_to_buf：8 位十六进制，与 types.x 一致。 */
__attribute__((weak)) int32_t asm_types_format_u32_hex8_to_buf(uint8_t *buf, int32_t off, int32_t val) {
  static const uint8_t hex[16] = {'0', '1', '2', '3', '4', '5', '6', '7',
                                  '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
  uint32_t v = (uint32_t)val;
  int32_t i;
  if (!buf)
    return -1;
  for (i = 0; i < 8; i++) {
    buf[off + 7 - i] = hex[v & 15u];
    v >>= 4;
  }
  return 8;
}

/**
 * peephole/elf 路径：从 ElfCodegenCtx.code_data 读 u32 LE；与 elf.x elf_read_u32_le 一致。
 */
extern uint8_t *pipeline_elf_ctx_code_data_ptr(uint8_t *ctx_bytes);

__attribute__((weak)) int32_t asm_types_elf_read_u32_le(void *ctx, int32_t pos) {
  uint8_t *base;
  uint8_t *p;
  if (!ctx || pos < 0)
    return 0;
  base = pipeline_elf_ctx_code_data_ptr((uint8_t *)ctx);
  if (!base)
    return 0;
  p = base + pos;
  return (int32_t)((uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24));
}

/**
 * ast.x ref_is_null 调用的 Expr 布局 prime；自举 ast.o 未 emit 时为空操作。
 * weak：build_asm/ast.o 真 emit 时由其覆盖。
 */
__attribute__((weak)) void expr_layout_prime_call_resolved(void) {
}

/**
 * arm64 call 实参恢复：ldr x{reg}, [sp] 或 [sp, #slot*16]；与 arm64.x 一致。
 * weak：build_asm/arm64.o 已 emit 时由其覆盖。
 */
__attribute__((weak)) int32_t emit_ldr_sp_slot_to_xreg(struct codegen_CodegenOutBuf *out, int32_t slot, int32_t reg) {
  static const uint8_t digit[8] = {'0', '1', '2', '3', '4', '5', '6', '7'};
  uint8_t buf[48];
  int32_t s;
  int32_t rd;
  int32_t offx;
  int32_t n;
  if (!out)
    return -1;
  s = slot;
  if (s < 0)
    s = 0;
  if (s > 7)
    s = 7;
  rd = reg;
  if (rd < 0)
    rd = 0;
  if (rd > 7)
    rd = 7;
  memcpy(buf, "ldr x0, [sp", 11);
  buf[5] = digit[rd];
  if (s == 0) {
    buf[11] = ']';
    return append_asm_line(out, buf, 12);
  }
  buf[11] = ',';
  buf[12] = ' ';
  buf[13] = '#';
  offx = s * 16;
  n = format_i32_to_buf(buf, 14, 12, offx);
  if (n < 0)
    return -1;
  buf[14 + n] = ']';
  return append_asm_line(out, buf, 15 + n);
}

/** ast_pool.c：与 elf.x / PipelineElfCtxAccess 布局一致的 code_data 追加路由。 */
extern int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n);

/**
 * 向 ctx.code_data 追加 4 字节小端指令；须经 pipeline_elf_ctx_append_bytes，
 * 勿手算 code_data 偏移（前缀含 labels/patches 等大表，sizeof 小 header 会写错区导致 udf/SIGILL）。
 */
static int32_t shu_elf_ctx_append_u32_le(struct platform_elf_ElfCodegenCtx *elf_ctx, uint32_t word) {
  uint8_t bytes[4];
  if (!elf_ctx)
    return -1;
  bytes[0] = (uint8_t)(word & 255u);
  bytes[1] = (uint8_t)((word >> 8) & 255u);
  bytes[2] = (uint8_t)((word >> 16) & 255u);
  bytes[3] = (uint8_t)((word >> 24) & 255u);
  return pipeline_elf_ctx_append_bytes((uint8_t *)elf_ctx, bytes, 4);
}

/**
 * arm64 MOVZ/MOVK 将 imm32 装入 w0；绕过 partial.o，避免 type_kind_ordinal 首条 cmp 时 Abort。
 */
static int32_t shu_arm64_mov_imm32_to_w0_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32) {
  uint32_t lo;
  uint32_t hi;
  lo = (uint32_t)imm32 & 65535u;
  hi = ((uint32_t)imm32 >> 16) & 65535u;
  if (shu_elf_ctx_append_u32_le(elf_ctx, 0x52800000u | (lo << 5)) != 0)
    return -1;
  if (hi != 0 && shu_elf_ctx_append_u32_le(elf_ctx, 0x72800000u | (hi << 5)) != 0)
    return -1;
  return 0;
}

/** 与 backend.x AsmFuncCtx 前缀一致，供 block_slot_base_for 读 num_locals。 */
struct backend_AsmFuncCtx {
  int32_t frame_size;
  int32_t next_offset;
  int32_t num_locals;
};

extern int32_t backend_emit_expr_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                     int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
/** seed partial 全量 X 体；慢路径专用，勿与薄包装 backend_emit_expr_elf 互调。 */
extern int32_t backend_emit_expr_elf_full(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                          int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t backend_enc_mov_rax_to_arg_reg_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t k,
                                                  int32_t ta);
extern void asm_ctx_ensure_block_locals(uint8_t *ctx, struct ast_ASTArena *arena, int32_t block_ref,
                                        int32_t *inout_next_offset, int32_t *inout_num_locals);
extern int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref);
extern int32_t pipeline_expr_call_arg_ref(void *arena, int32_t expr_ref, int32_t idx);
/** pipeline_glue.c：expr emit C 快/慢路径（call 实参须走此而非仅 slow）。 */
extern int32_t pipeline_asm_emit_expr_elf_c(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                            int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta);
extern int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
extern int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
extern int32_t arch_arm64_enc_enc_mov_imm32_to_w0(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_x86_64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);
extern int32_t arch_riscv64_enc_enc_ret_imm32(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32);

/**
 * partial.o 导出 backend_emit_expr_elf；compat 慢路径期望 _full 符号，别名到同一实现。
 */
int32_t backend_emit_expr_elf_full(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                   int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return backend_emit_expr_elf(arena, elf_ctx, expr_ref, ctx, ta);
}

/**
 * 慢路径回调 seed partial 内全量 backend_emit_expr_elf（勿调薄包装互递归 SIGSEGV）。
 */
int32_t backend_emit_expr_elf_slow(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                   int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return backend_emit_expr_elf_full(arena, elf_ctx, expr_ref, ctx, ta);
}

/**
 * 将 imm32 装入“结果寄存器”（arm64 w0 / x86 eax / riscv a0）。
 */
int32_t backend_enc_mov_imm32_to_w0_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t imm32, int32_t ta) {
  if (ta == 1)
    return shu_arm64_mov_imm32_to_w0_c(elf_ctx, imm32);
  if (ta == 2)
    return arch_riscv64_enc_enc_ret_imm32(elf_ctx, imm32);
  return arch_x86_64_enc_enc_ret_imm32(elf_ctx, imm32);
}

/**
 * 登记块内 const/let 栈槽（ast_pool.c：按类型宽度步进，并记录 block→slot_base）。
 * 替代仅 +8 步进的 fill_local_slots，修复 if 分支 `{ let t: Token = …; … tok: t }` 中 `t` 未入 locals。
 */
void backend_ensure_block_local_slots(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t off;
  int32_t nl;
  if (!ctx || !arena || block_ref <= 0)
    return;
  off = ctx->next_offset;
  nl = ctx->num_locals;
  asm_ctx_ensure_block_locals((uint8_t *)ctx, arena, block_ref, &off, &nl);
  ctx->next_offset = off;
  ctx->num_locals = nl;
}

/**
 * 块内局部起始槽下标；优先读 asm_ctx_block_slot_get，与 ensure_block_locals 一致。
 */
int32_t backend_block_slot_base_for(struct backend_AsmFuncCtx *ctx, struct ast_ASTArena *arena, int32_t block_ref) {
  int32_t nconst;
  int32_t nlet;
  int32_t slot_base;
  if (!ctx || !arena || block_ref <= 0)
    return 0;
  slot_base = asm_ctx_block_slot_get((uint8_t *)ctx, block_ref);
  if (slot_base >= 0)
    return slot_base;
  nconst = ast_ast_block_num_consts(arena, block_ref);
  nlet = ast_ast_block_num_lets(arena, block_ref);
  slot_base = ctx->num_locals - nconst - nlet;
  return slot_base < 0 ? 0 : slot_base;
}

/**
 * ARM64 单 call 实参：emit 表达式再 mov 到第 arg_idx 个参数寄存器。
 */
int32_t backend_asm_emit_one_call_arg_elf_arm64_push(void *arena, void *elf_ctx, int32_t expr_ref, int32_t arg_idx,
                                                     void *ctx, int32_t ta) {
  int32_t arg_ref = pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx);
  if (arg_ref == 0)
    return 0;
  if (pipeline_asm_emit_expr_elf_c((struct ast_ASTArena *)arena, (struct platform_elf_ElfCodegenCtx *)elf_ctx, arg_ref,
                                   (struct backend_AsmFuncCtx *)ctx, ta) != 0)
    return -1;
  return backend_enc_mov_rax_to_arg_reg_arch((struct platform_elf_ElfCodegenCtx *)elf_ctx, arg_idx, ta);
}

extern int32_t backend_emit_block_inits(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                        int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch,
                                        int32_t slot_base);
extern int32_t backend_emit_block_body(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                       int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t backend_emit_while_loop(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                       int32_t block_ref, int32_t loop_idx, struct backend_AsmFuncCtx *ctx,
                                       int32_t target_arch);
extern int32_t backend_emit_for_loop(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                     int32_t block_ref, int32_t for_idx, struct backend_AsmFuncCtx *ctx,
                                     int32_t target_arch);
extern int32_t backend_emit_loop_body_content(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                              int32_t body_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch);
extern int32_t backend_emit_if_then_block_body_text(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                    int32_t then_block_ref, struct backend_AsmFuncCtx *ctx,
                                                    int32_t target_arch);
extern int32_t backend_emit_expr(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                 struct backend_AsmFuncCtx *ctx, int32_t target_arch);

/**
 * text asm 路径：块 const/let 初始化；委托 seed partial 全量 backend_emit_block_inits（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_block_inits_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                        int32_t block_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch,
                                        int32_t slot_base) {
  return backend_emit_block_inits(arena, out, block_ref, ctx, target_arch, slot_base);
}

/**
 * text asm 块体 stmt_order 发射；委托 seed partial 全量 backend_emit_block_body（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_block_body_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t block_ref,
                                       struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  return backend_emit_block_body(arena, out, block_ref, ctx, target_arch);
}

/**
 * text asm while 循环发射；委托 seed partial backend_emit_while_loop（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_while_loop_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t block_ref,
                                       int32_t loop_idx, struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  return backend_emit_while_loop(arena, out, block_ref, loop_idx, ctx, target_arch);
}

/**
 * text asm for 循环发射；委托 seed partial backend_emit_for_loop（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_for_loop_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t block_ref,
                                     int32_t for_idx, struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  return backend_emit_for_loop(arena, out, block_ref, for_idx, ctx, target_arch);
}

/**
 * text asm 循环体 stmt_order 发射；委托 seed partial backend_emit_loop_body_content（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_loop_body_content_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                              int32_t body_ref, struct backend_AsmFuncCtx *ctx,
                                              int32_t target_arch) {
  return backend_emit_loop_body_content(arena, out, body_ref, ctx, target_arch);
}

/**
 * text asm if-then 块体；委托 seed partial backend_emit_if_then_block_body_text（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_if_then_block_body_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                    int32_t then_block_ref, struct backend_AsmFuncCtx *ctx,
                                                    int32_t target_arch) {
  return backend_emit_if_then_block_body_text(arena, out, then_block_ref, ctx, target_arch);
}

/**
 * text asm 表达式发射；委托 seed partial 全量 backend_emit_expr（M8-tail 薄包装）。
 */
int32_t pipeline_asm_emit_expr_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                 struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  return backend_emit_expr(arena, out, expr_ref, ctx, target_arch);
}

struct ast_Module;

extern void pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a);
extern int32_t backend_enc_epilogue_arch(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta);

/**
 * SKIP_TYPECK 桩：mov w0/x0/eax,#0 + epilogue；M8-tail 薄包装 bl 委托。
 */
int32_t pipeline_asm_emit_skip_heavy_stub_elf_c(struct platform_elf_ElfCodegenCtx *elf_ctx, int32_t ta) {
  if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0)
    return -1;
  return backend_enc_epilogue_arch(elf_ctx, ta);
}

/**
 * build_asm backend.o 薄包装误引用 pipeline_asm_emit_loop_body_content（无 _c 后缀）→ 转发 *_c 真实现。
 */
extern int32_t pipeline_asm_emit_loop_body_content_elf_c(struct ast_ASTArena *arena,
                                                          struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                          int32_t body_ref, struct backend_AsmFuncCtx *ctx,
                                                          int32_t ta);

int32_t pipeline_asm_emit_loop_body_content(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                            int32_t body_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch) {
  return pipeline_asm_emit_loop_body_content_c(arena, out, body_ref, ctx, target_arch);
}

/** ELF 版 loop body content 链名修正（无 _c 后缀 → pipeline_asm_emit_loop_body_content_elf_c）。 */
int32_t pipeline_asm_emit_loop_body_content_elf(struct ast_ASTArena *arena, struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                int32_t body_ref, struct backend_AsmFuncCtx *ctx, int32_t ta) {
  return pipeline_asm_emit_loop_body_content_elf_c(arena, elf_ctx, body_ref, ctx, ta);
}

extern int32_t pipeline_asm_emit_call_args_text_c(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                  int32_t expr_ref, struct backend_AsmFuncCtx *ctx, int32_t target_arch,
                                                  int32_t nargs);

/** build_asm backend.o 误链名 pipeline_asm_emit_call_args_text → pipeline_asm_emit_call_args_text_c。 */
int32_t pipeline_asm_emit_call_args_text(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out, int32_t expr_ref,
                                         struct backend_AsmFuncCtx *ctx, int32_t target_arch, int32_t nargs) {
  return pipeline_asm_emit_call_args_text_c(arena, out, expr_ref, ctx, target_arch, nargs);
}

/** partial 无 seed_mega 强符号时 pipeline_glue 仍须解析；转发到 backend_asm_codegen_ast*。 */
extern int32_t backend_asm_codegen_ast(void *module, void *arena, void *out_buf, void *ctx);
extern int32_t backend_asm_codegen_ast_to_elf(void *module, void *arena, void *elf_ctx, void *ctx);

__attribute__((weak)) int32_t backend_asm_codegen_ast_seed_mega(void *module, void *arena, void *out_buf, void *ctx) {
  return backend_asm_codegen_ast(module, arena, out_buf, ctx);
}

__attribute__((weak)) int32_t backend_asm_codegen_ast_to_elf_seed_mega(void *module, void *arena, void *elf_ctx,
                                                                         void *ctx) {
  return backend_asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx);
}

/** asm.x -E partial 导出 peephole_peephole_*；user_asm_seed_bridge 引用无前缀 peephole_*。 */
extern int32_t peephole_peephole_run(void *out_buf);
extern int32_t peephole_peephole_elf_run(void *elf_ctx);

/* experimental bootstrap 里 build_asm/peephole.o 可能退化成 CI text stub；此时用弱兜底保证可链接。 */
__attribute__((weak)) int32_t peephole_peephole_run(void *out_buf) {
  (void)out_buf;
  return 0;
}

__attribute__((weak)) int32_t peephole_peephole_elf_run(void *elf_ctx) {
  (void)elf_ctx;
  return 0;
}

int32_t peephole_run(void *out_buf) {
  return peephole_peephole_run(out_buf);
}

int32_t peephole_elf_run(void *elf_ctx) {
  return peephole_peephole_elf_run(elf_ctx);
}

/** lsp_diag_gen.c 尚未含 semanticTokens（pinned seed 旧版）；真 partial 不再携带 phase1 弱桩时须兜底。
 * lsp_diag.x 再生后由 lsp_diag_x.o 强符号覆盖。
 */
__attribute__((weak)) int32_t typeck_lsp_build_semantic_tokens_response(int32_t id_val, uint8_t *doc_buf, int32_t doc_len,
                                                                        uint8_t *out_buf, int32_t out_cap) {
  (void)id_val;
  (void)doc_buf;
  (void)doc_len;
  (void)out_buf;
  (void)out_cap;
  return -1;
}
