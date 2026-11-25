/*
 * Host-gcc twin of runtime_pipeline_abi_const_var_off_thin.x.
 *
 * DIG s205/s208: tipU pipe cell overlay hung context.x asm emit. This twin
 * keeps the module-const → stack_off=-1 contract with direct i32 locals.
 * docs-only / DIG first-wins; tip authority is the .x (same body).
 * PLATFORM: WINDOWS DIG host-cc first-wins; SHARED overlay semantics.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(uint8_t *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(uint8_t *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(uint8_t *arena, int32_t expr_ref, uint8_t *out);
extern int32_t glue_asm_local_var_stack_off_scoped(uint8_t *arena, uint8_t *ctx, int32_t var_expr_ref);
extern uint8_t *pipeline_asm_emit_module_ref_c(void);
extern int32_t pipeline_module_top_level_let_name_len(uint8_t *m, int32_t tl);
extern int32_t pipeline_module_top_level_let_name_byte_at(uint8_t *m, int32_t tl, int32_t k);
extern int32_t pipeline_module_top_level_let_is_const(uint8_t *m, int32_t tl);
extern int32_t pipe_load_i32_le(uint8_t *base, int32_t off);

/**
 * EXPR_VAR stack offset; -1 when unset OR module const name.
 * PLATFORM: SHARED · WINDOWS DIG first-wins twin of the .x thin.
 */
int32_t glue_var_expr_stack_off_elf_c(uint8_t *arena, uint8_t *ctx, int32_t var_expr_ref) {
  uint8_t name[256];
  uint8_t *mod;
  int32_t off;
  int32_t vlen;
  int32_t tl;
  int32_t ntl;
  int32_t tlen;
  int32_t k;
  int32_t matched;

  if (arena == 0 || ctx == 0 || var_expr_ref <= 0) {
    return -1;
  }
  if (pipeline_expr_kind_ord_at(arena, var_expr_ref) != 3) {
    return -1;
  }
  off = glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref);
  if (off < 0) {
    return off;
  }
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen <= 0 || vlen > 255) {
    return off;
  }
  pipeline_expr_var_name_into(arena, var_expr_ref, &name[0]);
  mod = pipeline_asm_emit_module_ref_c();
  if (mod == 0) {
    return off;
  }
  ntl = pipe_load_i32_le(mod, 12);
  for (tl = 0; tl < ntl; tl++) {
    tlen = pipeline_module_top_level_let_name_len(mod, tl);
    if (tlen != vlen) {
      continue;
    }
    matched = 1;
    for (k = 0; k < vlen; k++) {
      if (pipeline_module_top_level_let_name_byte_at(mod, tl, k) != (int32_t)name[k]) {
        matched = 0;
        break;
      }
    }
    if (matched != 0) {
      if (pipeline_module_top_level_let_is_const(mod, tl) != 0) {
        return -1;
      }
      return off;
    }
  }
  return off;
}
