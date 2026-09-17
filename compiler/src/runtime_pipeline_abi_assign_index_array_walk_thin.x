// Thin pure: INDEX chain walk for TYPE_ARRAY resolve (wave441).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;

/**
 * Walk INDEX chain from left_ref; write root and chain_n.
 * @return i32 — chain_n (>=0)
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_emit_assign_index_array_walk_elf_c(arena: *u8, left_ref: i32, out_root: *i32): i32 {
  unsafe {
    let walk_cur: i32 = 0;
    let chain_n: i32 = 0;
    let base_tk: i32 = 0;
    walk_cur = left_ref;
    chain_n = 0;
    while (chain_n < 8) {
      if (walk_cur <= 0) {
        break;
      }
      base_tk = pipeline_expr_kind_ord_at(arena, walk_cur);
      if (base_tk != 47) {
        break;
      }
      chain_n = chain_n + 1;
      walk_cur = pipeline_expr_index_base_ref(arena, walk_cur);
    }
    out_root[0] = walk_cur;
    return chain_n;
  }
}
