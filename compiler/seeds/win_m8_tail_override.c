/* PLATFORM: WINDOWS leftover-PE — real *_m8_tail_thin_delegate_c_name (backend/pipeline/driver/typeck).
 * Twin of FROM_X. Class AA. Wrong stubs were const char*(void){return "";} — callers expect int32_t fill-out.
 * Link FIRST (PE first-wins).
 */
#include <stdint.h>
#include <string.h>

extern int32_t pipeline_module_func_name_equal_at(void *m, int32_t func_index, const uint8_t *name, int32_t nlen);
extern int32_t asm_module_is_pipeline_selfhost(void *m);
extern int32_t asm_module_is_driver_compile_selfhost(void *m);
extern int32_t asm_module_is_typeck_selfhost(void *m);
extern int32_t asm_env_entry_emit_heavy(void);
extern int32_t pipeline_asm_module_func_is_extern_at(void *m, int32_t func_index);
extern int32_t pipeline_module_func_name_len_at(void *m, int32_t func_index);
extern void pipeline_asm_module_func_name_copy64(void *m, int32_t func_index, uint8_t *out);

typedef struct {
  const char *x_name;
  int32_t x_len;
  const char *c_name;
  int32_t c_len;
} AsmBackendThinDelegateRow;

static const AsmBackendThinDelegateRow k_asm_backend_thin_delegate[] = {
    {"fill_param_slots", 16, "pipeline_asm_fill_param_slots", 29},
    {"fill_local_slots", 16, "pipeline_asm_fill_local_slots", 29},
    {"compute_frame_size", 18, "pipeline_asm_compute_frame_size_c", 33},
    {"emit_block_body_elf", 19, "backend_emit_block_body_sync_elf", 32},
    {"emit_block_inits_elf", 20, "pipeline_asm_emit_block_inits_elf_c", 35},
    {"emit_if_then_block_body_elf", 27, "pipeline_asm_emit_if_then_block_body_elf_c", 42},
    {"emit_while_loop_elf", 18, "pipeline_asm_emit_while_loop_elf_c", 34},
    {"emit_for_loop_elf", 16, "pipeline_asm_emit_for_loop_elf_c", 32},
    {"emit_loop_body_content", 22, "pipeline_asm_emit_loop_body_content_c", 35},
    {"emit_loop_body_content_elf", 26, "pipeline_asm_emit_loop_body_content_elf_c", 39},
    {"emit_next_label", 15, "pipeline_asm_emit_next_label_c", 30},
    {"format_label_id", 15, "pipeline_asm_format_label_id_c", 30},
    {"emit_expr_elf_call", 18, "pipeline_asm_emit_call_elf_c", 28},
    {"emit_expr_elf_method_call", 25, "pipeline_asm_emit_method_call_elf_c", 35},
    {"asm_emit_call_args_elf", 22, "pipeline_asm_emit_call_args_elf_c", 33},
    {"emit_block_inits", 16, "pipeline_asm_emit_block_inits_c", 31},
    {"emit_block_body", 15, "pipeline_asm_emit_block_body_c", 30},
    {"emit_while_loop", 15, "pipeline_asm_emit_while_loop_c", 30},
    {"emit_for_loop", 13, "pipeline_asm_emit_for_loop_c", 28},
    {"emit_if_then_block_body_text", 28, "pipeline_asm_emit_if_then_block_body_text_c", 43},
    {"emit_expr", 9, "pipeline_asm_emit_expr_c", 24},
    {"emit_expr_call", 14, "pipeline_asm_emit_expr_call_c", 29},
    {"emit_expr_method_call", 21, "pipeline_asm_emit_expr_method_call_c", 36},
    {"emit_expr_elf", 13, "pipeline_asm_emit_expr_elf_c", 28},
    {"emit_index_eff_addr_text", 24, "pipeline_asm_emit_index_eff_addr_text_c", 39},
    {"emit_index_eff_addr_elf", 23, "pipeline_asm_emit_index_eff_addr_elf_c", 38},
    {"emit_lvalue_eff_addr_text", 25, "pipeline_asm_emit_lvalue_eff_addr_text_c", 40},
    {"emit_lvalue_eff_addr_elf", 24, "pipeline_asm_emit_lvalue_eff_addr_elf_c", 39},
    {"asm_emit_call_args_text", 23, "pipeline_asm_emit_call_args_text_c", 33},
    {"local_offset", 12, "pipeline_asm_local_offset_c", 27},
    {"asm_resolve_whole_import_qualified_symbol", 41, "pipeline_asm_resolve_whole_import_qualified_symbol_c", 52},
    {"emit_skip_heavy_stub_elf", 24, "pipeline_asm_emit_skip_heavy_stub_elf_c", 39},
    {"simd_try_inline_shuffle_call_elf", 32, "pipeline_asm_simd_try_inline_shuffle_call_elf_c", 47},
    {"simd_try_inline_select_call_elf", 31, "pipeline_asm_simd_try_inline_select_call_elf_c", 46},
    {"simd_try_inline_binop2_call_elf", 31, "pipeline_asm_simd_try_inline_binop2_call_elf_c", 46},
    {"simd_try_inline_fma3_call_elf", 29, "pipeline_asm_simd_try_inline_fma3_call_elf_c", 46},
    {"asm_codegen_ast", 15, "pipeline_backend_asm_codegen_ast_c", 34},
    {"asm_codegen_ast_to_elf", 22, "pipeline_backend_asm_codegen_ast_to_elf_c", 41},
};

/**
 * 查 backend 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_backend_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                  int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_backend_thin_delegate) / sizeof(k_asm_backend_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_backend_thin_delegate[i].x_name,
                                           k_asm_backend_thin_delegate[i].x_len)) {
      if (k_asm_backend_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_backend_thin_delegate[i].c_name, (size_t)k_asm_backend_thin_delegate[i].c_len);
      out[k_asm_backend_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_backend_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** M8-tail：parse/typecheck entry 薄 bl→C（do_parse 仍 X emit 调 set_main thin→C）。 */
static const AsmBackendThinDelegateRow k_asm_pipeline_thin_delegate[] = {
    {"pipeline_parse_set_main_from_buf", 32, "pipeline_parse_set_main_from_buf_c", 34},
    {"pipeline_should_skip_x_typeck", 30, "pipeline_should_skip_x_typeck_c", 32},
    {"run_x_pipeline_typecheck_entry", 31, "run_x_pipeline_typecheck_entry_emit_c", 36},
};

/**
 * 查 pipeline 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_pipeline_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                   int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_pipeline_thin_delegate) / sizeof(k_asm_pipeline_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_pipeline_thin_delegate[i].x_name,
                                           k_asm_pipeline_thin_delegate[i].x_len)) {
      if (k_asm_pipeline_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_pipeline_thin_delegate[i].c_name, (size_t)k_asm_pipeline_thin_delegate[i].c_len);
      out[k_asm_pipeline_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_pipeline_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}


/* ── driver / typeck M8-tail 薄委托表（补全五表域；历史自 ast_pool.c 抽出，live in runtime_pipeline_abi）── */
/* k_asm_driver_thin_delegate + k_asm_typeck_thin_delegate 及其 m8 查找符号。 */

/** M8-tail：driver compile 薄 bl 表已空；run_compiler_full_x* 堆 state + X post_parse 真 emit。 */
static const AsmBackendThinDelegateRow k_asm_driver_thin_delegate[] = {
};

/**
 * 查 driver/compile.x 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_driver_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_driver_thin_delegate) / sizeof(k_asm_driver_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_driver_thin_delegate[i].x_name,
                                           k_asm_driver_thin_delegate[i].x_len)) {
      if (k_asm_driver_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_driver_thin_delegate[i].c_name, (size_t)k_asm_driver_thin_delegate[i].c_len);
      out[k_asm_driver_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_driver_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** typeck EMIT_HEAVY 薄委托：仅剩须 C 维持的入口（typeck 主体已 X emit）。 */
static const AsmBackendThinDelegateRow k_asm_typeck_thin_delegate[] = {
};

/**
 * typeck EMIT_HEAVY 第二遍：SKIP 桩路径 bl→C 委托或 typeck_x.o 同名实现（首遍 SKIP 仍 ret0）。
 * 实参已在 ABI 寄存器；Mach-O 由 backend_enc_call_arch 加 leading `_`。
 */
int32_t asm_typeck_m8_tail_thin_delegate_c_name(void *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  int32_t nl;

  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  if (!asm_module_is_typeck_selfhost(m) || asm_env_entry_emit_heavy() == 0)
    return 0;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_typeck_thin_delegate) / sizeof(k_asm_typeck_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_typeck_thin_delegate[i].x_name,
                                           k_asm_typeck_thin_delegate[i].x_len)) {
      if (k_asm_typeck_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_typeck_thin_delegate[i].c_name, (size_t)k_asm_typeck_thin_delegate[i].c_len);
      out[k_asm_typeck_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_typeck_thin_delegate[i].c_len;
      return 1;
    }
  }
  nl = pipeline_module_func_name_len_at(m, func_index);
  if (nl <= 0 || nl >= out_cap)
    return 0;
  pipeline_asm_module_func_name_copy64(m, func_index, out);
  out[nl] = 0;
  *out_len = nl;
  return 1;
}
