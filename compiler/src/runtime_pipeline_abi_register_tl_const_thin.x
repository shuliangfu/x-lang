// 记211: tip pure overlay — non-hoist frames must not register module consts.
// Dead stack slots for NEG-over-LIT / BINOP consts caused Linux branched
// `return NAMED_CONST` to load garbage. Skip every is_const; imm fold owns it.
// PRODUCT: both ends _g05_pure_overlay first-wins Cap from_x MODLET_IN_REST.
// wave740 Class A: export-extern calls sit in unsafe (T001).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS co-path.

export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_asm_ctx_layout(ctx: *u8): *u8;
export extern function pipeline_asm_hoist_target_func_index(m: *u8): i32;
export extern function pipeline_module_top_level_let_name_len(m: *u8, tl: i32): i32;
export extern function pipeline_module_top_level_let_name_byte_at(m: *u8, tl: i32, k: i32): i32;
export extern function pipeline_module_top_level_let_type_ref(m: *u8, tl: i32): i32;
export extern function pipeline_module_top_level_let_init_ref(m: *u8, tl: i32): i32;
export extern function pipeline_module_top_level_let_is_const(m: *u8, tl: i32): i32;
export extern function pipeline_asm_modlet_name_is_shared(name: *u8, name_len: i32): i32;
export extern function pipeline_type_kind_ord_at(a: *u8, type_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(a: *u8, expr_ref: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern function asm_ctx_local_append(ctx: *u8, name: *u8, name_len: i32, offset: i32): i32;
export extern function asm_ctx_local_count(ctx: *u8): i32;
export extern function asm_local_slot_reg_offset(a: *u8, type_ref: i32, off: i32, out_next: *i32): i32;
export extern function pipeline_asm_let_init_stack_reserve_bytes(a: *u8, type_ref: i32, init_ref: i32): i32;

/**
 * Register module top-level lets into a non-hoist function frame.
 * 记211: skip ALL consts (not only INT_LIT/BOOL).
 * PLATFORM: SHARED freestanding · tip pure overlay.
 */
#[no_mangle]
export function pipeline_asm_register_module_top_level_lets_c(ctx: *u8, m: *u8, a: *u8, func_index: i32): void {
  unsafe {
    if (ctx == 0 as *u8 || m == 0 as *u8 || a == 0 as *u8) {
      return;
    }
    let nlets: i32 = pipe_load_i32_le(m, 12);
    if (nlets <= 0) {
      return;
    }
    let ly: *u8 = pipeline_asm_ctx_layout(ctx);
    if (ly == 0 as *u8) {
      return;
    }
    let hoist: i32 = pipeline_asm_hoist_target_func_index(m);
    if (func_index == hoist) {
      return;
    }
    let off: i32 = pipe_load_i32_le(ly, 4);
    let nexprs: i32 = pipe_load_i32_le(a, 4);
    let tl: i32 = 0;
    while (tl < nlets) {
      let name_len: i32 = pipeline_module_top_level_let_name_len(m, tl);
      if (name_len <= 0 || name_len > 255) {
        tl = tl + 1;
        continue;
      }
      let name_buf: u8[256] = [];
      let k: i32 = 0;
      while (k < name_len) {
        let b: i32 = pipeline_module_top_level_let_name_byte_at(m, tl, k);
        name_buf[k] = b as u8;
        k = k + 1;
      }
      let found: i32 = asm_ctx_local_find_offset(ctx, &name_buf[0], name_len);
      if (found >= 0) {
        tl = tl + 1;
        continue;
      }
      if (pipeline_asm_modlet_name_is_shared(&name_buf[0], name_len) != 0) {
        tl = tl + 1;
        continue;
      }
      let type_ref: i32 = pipeline_module_top_level_let_type_ref(m, tl);
      let init_ref: i32 = pipeline_module_top_level_let_init_ref(m, tl);
      let is_const: i32 = pipeline_module_top_level_let_is_const(m, tl);
      if (type_ref > 0) {
        let tk_arr: i32 = pipeline_type_kind_ord_at(a, type_ref);
        let ik_arr: i32 = 0;
        if (init_ref > 0 && init_ref <= nexprs) {
          ik_arr = pipeline_expr_kind_ord_at(a, init_ref);
        }
        if (tk_arr == 10 || ik_arr == 46) {
          tl = tl + 1;
          continue;
        }
      }
      /* 记211: skip every module const on non-hoist. */
      if (is_const != 0) {
        tl = tl + 1;
        continue;
      }
      let off_slot: i32[1] = [];
      off_slot[0] = off;
      let slot_off: i32 = asm_local_slot_reg_offset(a, type_ref, off, &off_slot[0]);
      off = off_slot[0];
      let ap: i32 = asm_ctx_local_append(ctx, &name_buf[0], name_len, slot_off);
      if (ap < 0) {
        return;
      }
      let reserve: i32 = pipeline_asm_let_init_stack_reserve_bytes(a, type_ref, init_ref);
      off = off + reserve;
      tl = tl + 1;
    }
    pipe_store_i32_le(ly, 4, off);
    let nloc: i32 = asm_ctx_local_count(ctx);
    pipe_store_i32_le(ly, 8, nloc);
  }
}
