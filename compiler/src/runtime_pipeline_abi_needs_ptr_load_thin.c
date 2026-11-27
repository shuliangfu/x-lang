/*
 * Host-gcc first-wins twin of glue_local_var_slot_needs_ptr_load_elf_c
 * (+ w189 param-ptr slot helpers).
 *
 * DIG s263 Soft Cap (PLATFORM: WINDOWS host-cc):
 * s262 Soft Cap load_var_dual_gp entered, but first callee
 * glue_local_var_slot_needs_ptr_load_elf_c is tip-compiled
 * param_ptr_slot_win.o with mov $0x1168 stack probe → SEGV RIP=0 on
 * typed `let` / `return x`. Mirror param_ptr_slot_thin.x EXIT as a
 * small host-cc frame; tip-land LINK_WINNERS + win_patch fold tipU /
 * typool T → Soft Cap.
 *
 * G.7: complete existing wave189 / param_ptr_slot authority; do not
 * open a second needs_ptr decision path.
 */
#include <stdint.h>

extern void *glue_emit_module_from_ctx(void *ctx);
extern int32_t asm_local_var_slot_holds_indirect_ptr(void *arena, int32_t var_expr_ref, void *mod,
                                                    void *ctx);
extern int32_t pipeline_asm_emit_func_index_c(void);
extern int32_t pipeline_asm_emit_func_param_is_indirect_struct_slot_c(void *arena, void *mod,
                                                                    int32_t var_expr_ref);
extern int32_t glue_emit_func_param_is_indirect_array_slot_c(void *arena, void *mod,
                                                            int32_t var_expr_ref);
extern int32_t pipeline_expr_kind_ord_at(void *arena, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(void *arena, int32_t expr_ref);
extern void pipeline_expr_var_name_into(void *arena, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_module_func_param_type_ref_for_name(void *mod, int32_t func_index,
                                                           uint8_t *name, int32_t name_len);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t ref);
extern int32_t pipeline_module_num_funcs(void *mod);
extern int32_t pipeline_asm_host_is_arm64_c(void);
extern int32_t pipeline_module_func_num_params_at(void *mod, int32_t func_index);
extern int32_t glue_func_param_home_width_c(void *arena, void *mod, int32_t func_index,
                                           int32_t param_index);
extern int32_t pipeline_module_func_param_type_ref_at(void *mod, int32_t func_index,
                                                     int32_t param_index);

/**
 * TYPE_PTR formal check at one param home.
 *
 * @param arena ASTArena*
 * @param mod Module*
 * @param func_index emit function index
 * @param pi param index
 * @return 1 if param type kind is TYPE_PTR (9); else 0
 * PLATFORM: WINDOWS host-cc Soft Cap; SHARED contract vs param_ptr_slot_thin.x.
 */
int32_t w189_param_at_is_type_ptr(void *arena, void *mod, int32_t func_index, int32_t pi) {
  int32_t pty;
  int32_t tk;
  if (arena == 0 || mod == 0 || func_index < 0 || pi < 0) {
    return 0;
  }
  pty = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
  if (pty <= 0) {
    return 0;
  }
  tk = pipeline_type_kind_ord_at(arena, pty);
  if (tk != 9) {
    return 0;
  }
  return 1;
}

/**
 * Whether stack_off maps to a *T formal param home.
 *
 * Homes match pipeline_asm_fill_param_slots: param 0 starts at 16.
 *
 * @param arena ASTArena*
 * @param mod Module*
 * @param func_index emit function index
 * @param stack_off frame magnitude (>=8, 8-aligned)
 * @return 1 if this home is a TYPE_PTR formal; else 0
 * PLATFORM: WINDOWS host-cc Soft Cap; SHARED contract vs param_ptr_slot_thin.x.
 */
int32_t w189_stack_off_is_emit_param_ptr_slot(void *arena, void *mod, int32_t func_index,
                                             int32_t stack_off) {
  int32_t pi;
  int32_t np;
  int32_t nf;
  int32_t is_arm;
  int32_t width;
  int32_t off;
  int32_t slot_off;
  if (arena == 0 || mod == 0 || func_index < 0 || stack_off < 8) {
    return 0;
  }
  if ((stack_off & 7) != 0) {
    return 0;
  }
  nf = pipeline_module_num_funcs(mod);
  if (func_index >= nf) {
    return 0;
  }
  is_arm = pipeline_asm_host_is_arm64_c();
  np = pipeline_module_func_num_params_at(mod, func_index);
  pi = 0;
  off = 16;
  while (pi < np) {
    width = glue_func_param_home_width_c(arena, mod, func_index, pi);
    if (width <= 0) {
      width = 8;
    }
    if (is_arm != 0) {
      slot_off = off;
      if (width > 8) {
        off = off + width;
      } else {
        off = off + 8;
      }
    } else {
      if (width > 8) {
        slot_off = off + width;
        off = slot_off + 8;
      } else {
        slot_off = off;
        off = off + 8;
      }
    }
    if (slot_off == stack_off) {
      return w189_param_at_is_type_ptr(arena, mod, func_index, pi);
    }
    pi = pi + 1;
  }
  return 0;
}

/**
 * Whether a local VAR slot must load the pointer home (*T / T[N] / T[] formal)
 * rather than lea the by-value slot.
 *
 * Decision order matches param_ptr_slot_thin.x (G.7 authority).
 *
 * @param arena ASTArena*; null → fall through
 * @param var_expr_ref EXPR_VAR ref
 * @param stack_off frame offset magnitude
 * @param ctx AsmFuncCtx*
 * @return 1 load pointer; 0 lea by-value / unknown
 * PLATFORM: WINDOWS host-cc Soft Cap; SHARED contract vs param_ptr_slot_thin.x.
 */
int32_t glue_local_var_slot_needs_ptr_load_elf_c(void *arena, int32_t var_expr_ref, int32_t stack_off,
                                                void *ctx) {
  void *mod;
  int32_t holds;
  int32_t fi;
  int32_t ko;
  int32_t vlen;
  int32_t pty;
  int32_t tk;
  uint8_t vname[256];

  mod = glue_emit_module_from_ctx(ctx);
  holds = asm_local_var_slot_holds_indirect_ptr(arena, var_expr_ref, mod, ctx);
  if (holds != 0) {
    return 1;
  }
  fi = pipeline_asm_emit_func_index_c();
  if (mod != 0 && fi >= 0) {
    if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, var_expr_ref) != 0) {
      return 1;
    }
    if (glue_emit_func_param_is_indirect_array_slot_c(arena, mod, var_expr_ref) != 0) {
      return 1;
    }
    if (w189_stack_off_is_emit_param_ptr_slot(arena, mod, fi, stack_off) != 0) {
      return 1;
    }
    if (arena != 0 && var_expr_ref > 0) {
      ko = pipeline_expr_kind_ord_at(arena, var_expr_ref);
      if (ko == 3) {
        vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
        if (vlen > 0 && vlen <= 255) {
          pipeline_expr_var_name_into(arena, var_expr_ref, vname);
          pty = pipeline_module_func_param_type_ref_for_name(mod, fi, vname, vlen);
          if (pty > 0) {
            tk = pipeline_type_kind_ord_at(arena, pty);
            if (tk == 11) {
              return 1;
            }
          }
        }
      }
    }
  }
  return 0;
}
