// Thin: FIELD chain walk leaf (wave441/445).
// wave445: Ubuntu pure-asm CG002 from `out[i]=` / `out[0]=` stores — use
// `*p =` / `*out =` (G.7 same semantics). PLATFORM: SHARED freestanding.
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_field_access_base_ref(arena: *u8, expr_ref: i32): i32;

/**
 * Walk FIELD chain from left_ref into out_fa[16]; write chain_n and root to outs.
 * @return i32 — chain_n (>=0); -1 fail
 * PLATFORM: SHARED freestanding.
 */
#[no_mangle]
export function glue_emit_assign_field_chain_walk_elf_c(arena: *u8, left_ref: i32, out_fa: *i32, out_root: *i32): i32 {
  unsafe {
    let chain_n: i32 = 0;
    let walk_cur: i32 = 0;
    let base_kind: i32 = 0;
    let slot: *i32 = 0 as *i32;
    walk_cur = left_ref;
    while (chain_n < 16) {
      base_kind = pipeline_expr_kind_ord_at(arena, walk_cur);
      if (base_kind != 44) {
        break;
      }
      slot = &out_fa[chain_n];
      *slot = walk_cur;
      chain_n = chain_n + 1;
      walk_cur = pipeline_expr_field_access_base_ref(arena, walk_cur);
      if (walk_cur <= 0) {
        break;
      }
    }
    *out_root = walk_cur;
    return chain_n;
  }
}
