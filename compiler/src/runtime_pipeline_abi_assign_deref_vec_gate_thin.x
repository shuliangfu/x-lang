// Thin pure: DEREF vector gate — lanes/esz then var/call peers (wave472).
// G.7: part of glue_emit_assign_deref_after_addr_elf_c (peer-flat).
// wave472: no-local nbytes via re-call product; Tip U=4/4.
//   PRODUCT inject: LINUX PREFER (stamp w472); MACOS skip.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function glue_emit_assign_deref_vec_var_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, rko_pre: i32, nbytes: i32): i32;
export extern function glue_emit_assign_deref_vec_call_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, rko_pre: i32, nbytes: i32, ltr: i32): i32;

/**
 * DEREF vec_gate — if ltr is vector, try vec_var then vec_call (0/-1 cascade).
 * wave472: slot locals for lanes/esz only; nbytes = lanes*esz via re-call args.
 * @return i32 — 0 ok; -1 fail; -3 not a vector / not handled
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_deref_vec_gate_elf_c(arena: *u8, elf_ctx: *u8, right_ref: i32, ctx: *u8, ta: i32, ltr: i32): i32 {
  unsafe {
    let n_arr: i32[1] = [];
    let esz_s: i32[1] = [];
    if (glue_vector_type_lanes_esz_c(arena, ltr, &n_arr[0], &esz_s[0]) != 0) {
      return 0 - 3;
    }
    if (n_arr[0] <= 0) {
      return 0 - 3;
    }
    if (esz_s[0] <= 0) {
      return 0 - 3;
    }
    if (glue_emit_assign_deref_vec_var_elf_c(arena, elf_ctx, right_ref, ctx, ta, pipeline_expr_kind_ord_at(arena, right_ref), n_arr[0] * esz_s[0]) == 0) {
      return 0;
    }
    if (glue_emit_assign_deref_vec_var_elf_c(arena, elf_ctx, right_ref, ctx, ta, pipeline_expr_kind_ord_at(arena, right_ref), n_arr[0] * esz_s[0]) == (0 - 1)) {
      return 0 - 1;
    }
    if (glue_emit_assign_deref_vec_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, pipeline_expr_kind_ord_at(arena, right_ref), n_arr[0] * esz_s[0], ltr) == 0) {
      return 0;
    }
    if (glue_emit_assign_deref_vec_call_elf_c(arena, elf_ctx, right_ref, ctx, ta, pipeline_expr_kind_ord_at(arena, right_ref), n_arr[0] * esz_s[0], ltr) == (0 - 1)) {
      return 0 - 1;
    }
    return 0 - 3;
  }
}
