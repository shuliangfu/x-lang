/*
 * Host-gcc first-wins twin of glue_call_arg_resolve_var_stack_off_elf_c.
 *
 * DIG s261 Soft Cap (PLATFORM: WINDOWS host-cc):
 * Cap soft call_arg_const_off.o first-wins T but tip body uses a 0x9a8
 * frame; emit_expr_elf_fast same-TU calls tip local `t` (sub $0x270)
 * which SEGVs (RIP=0) on `return x` after Soft Cap emit_expr_elf_rec
 * (s260). Mirror call_arg_const_off_thin.x EXIT as a small host-cc
 * frame; tip-land LINK_WINNERS + win_patch fold tipU t/T → Soft Cap.
 *
 * G.7: complete existing 记211 call_arg_const_off authority; do not
 * open a second resolve path.
 */
#include <stdint.h>

extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t glue_asm_local_var_stack_off_scoped(void *arena, void *ctx, int32_t var_expr_ref);
extern void *pipeline_asm_emit_module_ref_c(void);
extern int32_t asm_module_top_level_const_lit_i32(void *m, void *a, uint8_t *name, int32_t nlen, int32_t *out);

/**
 * Resolve EXPR_VAR stack offset for call-arg / fast emit (const fold first).
 *
 * @param arena ASTArena*
 * @param ctx AsmFuncCtx*
 * @param var_expr_ref EXPR_VAR ref; <=0 → -1
 * @return stack offset; -1 when not a local/const VAR
 * PLATFORM: WINDOWS host-cc Soft Cap; SHARED contract vs call_arg_const_off_thin.x.
 */
int32_t glue_call_arg_resolve_var_stack_off_elf_c(void *arena, void *ctx, int32_t var_expr_ref) {
  int32_t ko;
  int32_t vlen;
  int32_t lit_rc;
  int32_t imm;
  uint8_t name[256];
  void *mod;
  int32_t i;

  if (!arena || !ctx || var_expr_ref <= 0) {
    return -1;
  }
  /* EXPR_VAR = 3 */
  ko = pipeline_expr_kind_ord_at(arena, var_expr_ref);
  if (ko != 3) {
    return -1;
  }
  vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
  if (vlen > 0 && vlen <= 255) {
    i = 0;
    while (i < 256) {
      name[i] = 0;
      i = i + 1;
    }
    pipeline_expr_var_name_into(arena, var_expr_ref, &name[0]);
    mod = pipeline_asm_emit_module_ref_c();
    if (mod) {
      imm = 0;
      lit_rc = asm_module_top_level_const_lit_i32(mod, arena, &name[0], vlen, &imm);
      if (lit_rc != 0) {
        return -1;
      }
    }
  }
  return glue_asm_local_var_stack_off_scoped(arena, ctx, var_expr_ref);
}
