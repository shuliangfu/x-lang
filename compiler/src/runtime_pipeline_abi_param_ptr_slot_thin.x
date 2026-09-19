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
// wave402: MACOS PREFER / LINUX hard-skip BAN tip reinject (CG002 / -E empty if).
// wave432: BOTH PREFER — extract w189_param_at_is_type_ptr so Ubuntu -E no
//   longer emits empty `if ()` / CFG-reorders the walker; -c ~4955B green.
// wave494: no-local mid `x=call()` (tip U starved 3/15); LINUX -E (tip PREFER
//   opt=77 — leftover smash in the compiler assign/deref family).
// wave610 M2: product path is PREFER_ASM both ends (no host-cc for this TU).
//   Standalone -backend asm -c is U-complete (T=3 UND=19). Do not fall back
//   to -E.
// PLATFORM: SHARED freestanding param slot · LINUX gold · MACOS.

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
/** Pipe cell store/load — tip-stable mid call results (wave494). */
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, p: *u8): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;

/**
 * TYPE_PTR formal check at one home (wave432: isolate from while/if CFG —
 * Ubuntu -E otherwise emits empty `if ()` inside the walker).
 * wave494: no-local — pipe cell for mid i32 calls.
 * @param arena *u8 — ASTArena*
 * @param mod *u8 — Module*
 * @param func_index i32 — emit function index
 * @param pi i32 — param index
 * @return i32 — 1 if param type kind is TYPE_PTR (9); else 0
 */
function w189_param_at_is_type_ptr(arena: *u8, mod: *u8, func_index: i32, pi: i32): i32 {
  let cell: u8[8];
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `pty=call()` / `tk=call()`; pipe cell. */
    pipe_store_i32_le(&cell[0], 0, pipeline_module_func_param_type_ref_at(mod, func_index, pi));
    if (pipe_load_i32_le(&cell[0], 0) <= 0) {
      return 0;
    }
    pipe_store_i32_le(&cell[0], 4, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(&cell[0], 0)));
    if (pipe_load_i32_le(&cell[0], 4) != 9) {
      return 0;
    }
  }
  return 1;
}

/**
 * Whether stack_off maps to a *T formal param home.
 * Homes match pipeline_asm_fill_param_slots: param 0 starts at 16, then
 * +8 (or +width when width>8; x86 high-end for wide homes).
 * wave494: no-local — pipe cell; loops in unsafe (T001).
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
  let off: i32 = 16;
  let slot_off: i32 = 0;
  let hit: i32 = 0;
  /* cell: [0]=nf|[4]=is_arm; cell_w: [0]=np|[4]=width */
  let cell: u8[8];
  let cell_w: u8[8];
  if (arena == (0 as *u8) || mod == (0 as *u8) || func_index < 0 || stack_off < 8) {
    return 0;
  }
  if ((stack_off & 7) != 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_module_num_funcs(mod));
    if (func_index >= pipe_load_i32_le(&cell[0], 0)) {
      return 0;
    }
    pipe_store_i32_le(&cell[0], 4, pipeline_asm_host_is_arm64_c());
    pipe_store_i32_le(&cell_w[0], 0, pipeline_module_func_num_params_at(mod, func_index));
    pi = 0;
    while (pi < pipe_load_i32_le(&cell_w[0], 0)) {
      pipe_store_i32_le(&cell_w[0], 4, glue_func_param_home_width_c(arena, mod, func_index, pi));
      if (pipe_load_i32_le(&cell_w[0], 4) <= 0) {
        pipe_store_i32_le(&cell_w[0], 4, 8);
      }
      if (pipe_load_i32_le(&cell[0], 4) != 0) {
        slot_off = off;
        if (pipe_load_i32_le(&cell_w[0], 4) > 8) {
          off = off + pipe_load_i32_le(&cell_w[0], 4);
        } else {
          off = off + 8;
        }
      } else {
        if (pipe_load_i32_le(&cell_w[0], 4) > 8) {
          slot_off = off + pipe_load_i32_le(&cell_w[0], 4);
          off = slot_off + 8;
        } else {
          slot_off = off;
          off = off + 8;
        }
      }
      if (slot_off == stack_off) {
        /* wave432: isolate TYPE_PTR check (Ubuntu -E CFG scramble). */
        hit = w189_param_at_is_type_ptr(arena, mod, func_index, pi);
        return hit;
      }
      pi = pi + 1;
    }
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
 * wave494: no-local — pipe cell for mid calls; loops in unsafe (T001).
 * PLATFORM: SHARED freestanding INDEX/field/lvalue · LINUX gold · MACOS.
 * Product inject is PREFER_ASM (wave610).
 */
#[no_mangle]
export function glue_local_var_slot_needs_ptr_load_elf_c(arena: *u8, var_expr_ref: i32, stack_off: i32, ctx: *u8): i32 {
  /* Cap 4.2.8: var_name_into memset(out,0,256); align mega runtime_pipeline_abi.x. */
  let vname: u8[256] = [];
  let cell_m: u8[8];
  let cell: u8[8];
  let cell_t: u8[8];
  // M2 class A: export-extern calls must sit in unsafe (-backend asm T001).
  // PLATFORM: SHARED — asm typeck contract; mega thin small-file reproduce.
  unsafe {
    /* PLATFORM: SHARED — tip drops mid `mod=call()` / `holds=call()`; pipe cells. */
    pipe_store_ptr_slot(&cell_m[0], 0, glue_emit_module_from_ctx(ctx));
    pipe_store_i32_le(&cell[0], 0, asm_local_var_slot_holds_indirect_ptr(arena, var_expr_ref, pipe_load_ptr_slot(&cell_m[0], 0), ctx));
    if (pipe_load_i32_le(&cell[0], 0) != 0) {
      return 1;
    }
    /* cell[4]=fi stable for rest of walk. */
    pipe_store_i32_le(&cell[0], 4, pipeline_asm_emit_func_index_c());
    if (pipe_load_ptr_slot(&cell_m[0], 0) != (0 as *u8) && pipe_load_i32_le(&cell[0], 4) >= 0) {
      if (pipeline_asm_emit_func_param_is_indirect_struct_slot_c(arena, pipe_load_ptr_slot(&cell_m[0], 0), var_expr_ref) != 0) {
        return 1;
      }
      if (glue_emit_func_param_is_indirect_array_slot_c(arena, pipe_load_ptr_slot(&cell_m[0], 0), var_expr_ref) != 0) {
        return 1;
      }
      if (w189_stack_off_is_emit_param_ptr_slot(arena, pipe_load_ptr_slot(&cell_m[0], 0), pipe_load_i32_le(&cell[0], 4), stack_off) != 0) {
        return 1;
      }
      // PLATFORM: SHARED — TYPE_SLICE params lower as pointers (1 GP home).
      // Local TYPE_SLICE lets stay by-value dual-GP (needs_ptr_load=0).
      if (arena != (0 as *u8) && var_expr_ref > 0) {
        pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, var_expr_ref));
        // EXPR_VAR == 3
        if (pipe_load_i32_le(&cell[0], 0) == 3) {
          pipe_store_i32_le(&cell[0], 0, pipeline_expr_var_name_len(arena, var_expr_ref));
          if (pipe_load_i32_le(&cell[0], 0) > 0 && pipe_load_i32_le(&cell[0], 0) <= 255) {
            pipeline_expr_var_name_into(arena, var_expr_ref, &vname[0]);
            /* cell_t[0]=pty; cell_t[4]=tk. cell[0]=vlen; cell[4]=fi. */
            pipe_store_i32_le(&cell_t[0], 0, pipeline_module_func_param_type_ref_for_name(
                pipe_load_ptr_slot(&cell_m[0], 0),
                pipe_load_i32_le(&cell[0], 4),
                &vname[0],
                pipe_load_i32_le(&cell[0], 0)));
            if (pipe_load_i32_le(&cell_t[0], 0) > 0) {
              pipe_store_i32_le(&cell_t[0], 4, pipeline_type_kind_ord_at(arena, pipe_load_i32_le(&cell_t[0], 0)));
              // TYPE_SLICE == 11
              if (pipe_load_i32_le(&cell_t[0], 4) == 11) {
                return 1;
              }
            }
          }
        }
      }
    }
  }
  return 0;
}
