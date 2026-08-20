// Thin pure override: *T formal home vs by-value NAMED self.
// G.7: bodies MUST match w189_stack_off_is_emit_param_ptr_slot and
// glue_local_var_slot_needs_ptr_load_elf_c in runtime_pipeline_abi.x
// (same exported symbol). The old `(stack_off-8)/8` mapped the by-value
// NAMED self at home 16 onto param index 1; when that extra is TYPE_PTR,
// FIELD_ACCESS of `self.v` pointer-loaded the stored value (dyn extra
// `*i32` / PTR-outer `*[N][]T` sit-red 139). Homes match
// pipeline_asm_fill_param_slots (param 0 starts at 16).
// ensure injects via first-wins ld -r so product need not full mega -E
// (Darwin mega -E peaks 22-40GB RSS).
// PLATFORM: SHARED freestanding param slot · LINUX gold · MACOS co-path.

export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function asm_local_var_slot_holds_indirect_ptr(arena: *u8, var_expr_ref: i32, mod: *u8, ctx: *u8): i32;
export extern function pipeline_asm_emit_func_index_c(): i32;
export extern function pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena: *u8, mod: *u8, var_expr_ref: i32): i32;
export extern function glue_emit_func_param_is_indirect_array_slot_c(arena: *u8, mod: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_module_func_param_type_ref_for_name(mod: *u8, func_index: i32, name: *u8, name_len: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_module_num_funcs(mod: *u8): i32;
export extern function pipeline_asm_host_is_arm64_c(): i32;
export extern function pipeline_module_func_num_params_at(mod: *u8, func_index: i32): i32;
export extern function glue_func_param_home_width_c(arena: *u8, mod: *u8, func_index: i32, param_index: i32): i32;
export extern function pipeline_module_func_param_type_ref_at(mod: *u8, func_index: i32, param_index: i32): i32;

/**
 * Whether stack_off maps to a *T formal param home.
 * Homes match pipeline_asm_fill_param_slots: param 0 starts at 16, then
 * +8 (or +width when width>8; x86 high-end for wide homes). The old
 * `(stack_off-8)/8` mapped the by-value NAMED self at 16 onto param
 * index 1 — when that extra is TYPE_PTR, `self.v` pointer-loaded the
 * value (dyn extra `*i32` / PTR-outer `*[N][]T` sit-red 139). SLICE
 * extras stay kind 11 so they never hit this helper (dest-SLICE +
 * `self.v` already 7).
 * @param arena *u8 — ASTArena*
 * @param mod *u8 — Module*
 * @param func_index i32 — emit function index
 * @param stack_off i32 — frame magnitude (>=8, 8-aligned)
 * @return i32 — 1 if this home is a TYPE_PTR (kind 9) formal; else 0
 * PLATFORM: SHARED freestanding param slot · LINUX gold · MACOS co-path.
 * G.7: complete this walk (same homes as fill_param_slots; no second mapper).
 */
function w189_stack_off_is_emit_param_ptr_slot(arena: *u8, mod: *u8, func_index: i32, stack_off: i32): i32 {
  let pi: i32 = 0;
  let np: i32 = 0;
  let pty: i32 = 0;
  let nf: i32 = 0;
  let tk: i32 = 0;
  let off: i32 = 16;
  let is_arm: i32 = 0;
  let width: i32 = 0;
  let slot_off: i32 = 0;
  if (arena == (0 as *u8) || mod == (0 as *u8) || func_index < 0 || stack_off < 8) {
    return 0;
  }
  unsafe {
    nf = pipeline_module_num_funcs(mod);
  }
  if (func_index >= nf) {
    return 0;
  }
  if ((stack_off & 7) != 0) {
    return 0;
  }
  unsafe {
    is_arm = pipeline_asm_host_is_arm64_c();
    np = pipeline_module_func_num_params_at(mod, func_index);
  }
  pi = 0;
  while (pi < np) {
    unsafe {
      width = glue_func_param_home_width_c(arena, mod, func_index, pi);
    }
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
      unsafe {
        pty = pipeline_module_func_param_type_ref_at(mod, func_index, pi);
      }
      if (pty <= 0) {
        return 0;
      }
      unsafe {
        tk = pipeline_type_kind_ord_at(arena, pty);
      }
      /* TYPE_PTR == 9 */
      if (tk == 9) {
        return 1;
      }
      return 0;
    }
    pi = pi + 1;
  }
  return 0;
}

/**
 * Whether a local VAR slot must load the pointer home (*T / T[N] / T[] formal)
 * rather than lea the by-value slot (local let *T vs param).
 * @param arena *u8 — ASTArena*; null → 0
 * @param var_expr_ref i32 — EXPR_VAR ref
 * @param stack_off i32 — frame offset magnitude (fallback param table)
 * @param ctx *u8 — AsmFuncCtx*
 * @return i32 — 1 load pointer; 0 lea by-value / unknown
 *
 * Decision order (G.7 complete *T / T[N] / T[] set):
 *  1. asm_local_var_slot_holds_indirect_ptr Cap residual (resolved let *T etc.)
 *  2. indirect named-struct formal (always 0 SysV product)
 *  3. fixed T[N] formal (lea at CALL → 8B pointer home)
 *  4. stack_off maps to *T formal param slot
 *  5. TYPE_SLICE formal (codegen lowers as pointer; local let stays dual-GP)
 *
 * wave189 pure: G.7 authority (was Cap residual index_helpers).
 * PLATFORM: SHARED freestanding INDEX/field/lvalue · LINUX gold · MACOS co-path.
 */
#[no_mangle]
export function glue_local_var_slot_needs_ptr_load_elf_c(arena: *u8, var_expr_ref: i32, stack_off: i32, ctx: *u8): i32 {
  let mod: *u8 = 0 as *u8;
  let holds: i32 = 0;
  let fi: i32 = 0;
  let ko: i32 = 0;
  let vname: u8[128] = [];
  let vlen: i32 = 0;
  let pty: i32 = 0;
  let tk: i32 = 0;
  mod = glue_emit_module_from_ctx(ctx);
  unsafe {
    holds = asm_local_var_slot_holds_indirect_ptr(arena, var_expr_ref, mod, ctx);
  }
  if (holds != 0) {
    return 1;
  }
  fi = pipeline_asm_emit_func_index_c();
  if (mod != (0 as *u8) && fi >= 0) {
    if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, mod, var_expr_ref) != 0) {
      return 1;
    }
    if (glue_emit_func_param_is_indirect_array_slot_c(arena, mod, var_expr_ref) != 0) {
      return 1;
    }
    if (w189_stack_off_is_emit_param_ptr_slot(arena, mod, fi, stack_off) != 0) {
      return 1;
    }
    // PLATFORM: SHARED — TYPE_SLICE params lower as pointers (1 GP home).
    // Local TYPE_SLICE lets stay by-value dual-GP (needs_ptr_load=0).
    if (arena != (0 as *u8) && var_expr_ref > 0) {
      unsafe {
        ko = pipeline_expr_kind_ord_at(arena, var_expr_ref);
      }
      // EXPR_VAR == 3
      if (ko == 3) {
        unsafe {
          vlen = pipeline_expr_var_name_len(arena, var_expr_ref);
        }
        if (vlen > 0 && vlen <= 63) {
          unsafe {
            pipeline_expr_var_name_into(arena, var_expr_ref, &vname[0]);
            pty = pipeline_module_func_param_type_ref_for_name(mod, fi, &vname[0], vlen);
          }
          if (pty > 0) {
            unsafe {
              tk = pipeline_type_kind_ord_at(arena, pty);
            }
            // TYPE_SLICE == 11
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
