// 记211: tip pure overlay — non-hoist frames must not register module consts.
// tipU: mid `x=call()` drops on Ubuntu — all i32 results go through pipe cells.
// PRODUCT: both ends _g05_pure_overlay first-wins Cap from_x MODLET_IN_REST.
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
 * 记211: skip ALL consts. tipU pipe cells keep call results.
 * PLATFORM: SHARED freestanding · tip pure overlay.
 */
#[no_mangle]
export function pipeline_asm_register_module_top_level_lets_c(ctx: *u8, m: *u8, a: *u8, func_index: i32): void {
  unsafe {
    let cell: u8[64];
    let name_buf: u8[256];
    let off_slot: i32[1];
    let ly: *u8;
    let tl: i32;
    let nlets: i32;
    let off: i32;
    let nexprs: i32;
    let hoist: i32;
    if (ctx == 0 as *u8 || m == 0 as *u8 || a == 0 as *u8) {
      return;
    }
    pipe_store_i32_le(&cell[0], 0, pipe_load_i32_le(m, 12));
    nlets = pipe_load_i32_le(&cell[0], 0);
    if (nlets <= 0) {
      return;
    }
    ly = pipeline_asm_ctx_layout(ctx);
    if (ly == 0 as *u8) {
      return;
    }
    pipe_store_i32_le(&cell[0], 4, pipeline_asm_hoist_target_func_index(m));
    hoist = pipe_load_i32_le(&cell[0], 4);
    if (func_index == hoist) {
      return;
    }
    off = pipe_load_i32_le(ly, 4);
    nexprs = pipe_load_i32_le(a, 4);
    tl = 0;
    while (tl < nlets) {
      pipe_store_i32_le(&cell[0], 8, pipeline_module_top_level_let_name_len(m, tl));
      if (pipe_load_i32_le(&cell[0], 8) <= 0 || pipe_load_i32_le(&cell[0], 8) > 255) {
        tl = tl + 1;
        continue;
      }
      pipe_store_i32_le(&cell[0], 12, 0);
      while (pipe_load_i32_le(&cell[0], 12) < pipe_load_i32_le(&cell[0], 8)) {
        pipe_store_i32_le(&cell[0], 16, pipeline_module_top_level_let_name_byte_at(m, tl, pipe_load_i32_le(&cell[0], 12)));
        name_buf[pipe_load_i32_le(&cell[0], 12)] = pipe_load_i32_le(&cell[0], 16) as u8;
        pipe_store_i32_le(&cell[0], 12, pipe_load_i32_le(&cell[0], 12) + 1);
      }
      pipe_store_i32_le(&cell[0], 20, asm_ctx_local_find_offset(ctx, &name_buf[0], pipe_load_i32_le(&cell[0], 8)));
      if (pipe_load_i32_le(&cell[0], 20) >= 0) {
        tl = tl + 1;
        continue;
      }
      pipe_store_i32_le(&cell[0], 24, pipeline_asm_modlet_name_is_shared(&name_buf[0], pipe_load_i32_le(&cell[0], 8)));
      if (pipe_load_i32_le(&cell[0], 24) != 0) {
        tl = tl + 1;
        continue;
      }
      pipe_store_i32_le(&cell[0], 28, pipeline_module_top_level_let_type_ref(m, tl));
      pipe_store_i32_le(&cell[0], 32, pipeline_module_top_level_let_init_ref(m, tl));
      pipe_store_i32_le(&cell[0], 36, pipeline_module_top_level_let_is_const(m, tl));
      /* 记211: skip every module const on non-hoist (pipe cell keeps tipU). */
      if (pipe_load_i32_le(&cell[0], 36) != 0) {
        tl = tl + 1;
        continue;
      }
      if (pipe_load_i32_le(&cell[0], 28) > 0) {
        pipe_store_i32_le(&cell[0], 40, pipeline_type_kind_ord_at(a, pipe_load_i32_le(&cell[0], 28)));
        pipe_store_i32_le(&cell[0], 44, 0);
        if (pipe_load_i32_le(&cell[0], 32) > 0 && pipe_load_i32_le(&cell[0], 32) <= nexprs) {
          pipe_store_i32_le(&cell[0], 44, pipeline_expr_kind_ord_at(a, pipe_load_i32_le(&cell[0], 32)));
        }
        if (pipe_load_i32_le(&cell[0], 40) == 10 || pipe_load_i32_le(&cell[0], 44) == 46) {
          tl = tl + 1;
          continue;
        }
      }
      off_slot[0] = off;
      pipe_store_i32_le(&cell[0], 48, asm_local_slot_reg_offset(a, pipe_load_i32_le(&cell[0], 28), off, &off_slot[0]));
      off = off_slot[0];
      pipe_store_i32_le(&cell[0], 52, asm_ctx_local_append(ctx, &name_buf[0], pipe_load_i32_le(&cell[0], 8), pipe_load_i32_le(&cell[0], 48)));
      if (pipe_load_i32_le(&cell[0], 52) < 0) {
        return;
      }
      pipe_store_i32_le(&cell[0], 56, pipeline_asm_let_init_stack_reserve_bytes(a, pipe_load_i32_le(&cell[0], 28), pipe_load_i32_le(&cell[0], 32)));
      off = off + pipe_load_i32_le(&cell[0], 56);
      tl = tl + 1;
    }
    pipe_store_i32_le(ly, 4, off);
    pipe_store_i32_le(&cell[0], 60, asm_ctx_local_count(ctx));
    pipe_store_i32_le(ly, 8, pipe_load_i32_le(&cell[0], 60));
  }
}
