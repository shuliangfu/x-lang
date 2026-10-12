// Thin pure: INDEX TYPE_ARRAY dest-type resolve (wave441/445).
// wave445: `*out_ltr =` heal Ubuntu pure-asm CG002.
// G.7: peel INDEX chain to element TYPE_ARRAY dest type.
// wave546 Soft Cap: Ubuntu tip SEGV on raw `*i32` store, and calls inside
//   `if (local)` are dropped. Walk root is a byte cell cast only at the
//   extern call. Kind/var/field/resolved run in w546_fill when go!=0
//   (parameter); the caller selects which value to keep. Peel writes
//   out_ltr itself. stamp w546 HARD BAN tip PRODUCT reinject.
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_decl_type_ref_elf_c(arena: *u8, ctx: *u8, var_ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_assign_index_array_walk_elf_c(arena: *u8, left_ref: i32, out_root: *i32): i32;
export extern function glue_emit_assign_index_array_peel_elf_c(arena: *u8, ltr_in: i32, chain_n: i32, out_ltr: *i32): i32;

/**
 * Fetch VAR / FIELD / resolved type candidates for one root expr.
 * go is a parameter. The four queries always run when go!=0 so Ubuntu
 * tip keeps the symbols; the caller still picks VAR(kind 3), else
 * FIELD(kind 44), else resolved.
 * @param arena *u8 — AST arena
 * @param ctx *u8 — emit context for var-decl type
 * @param walk_cur i32 — chain root expr; ignored when go==0
 * @param go i32 — 0 stores 0 and skips the queries
 * @param lcell *u8 — receives the selected type ref
 * @return i32 — 1 when queries ran, else 0
 * PLATFORM: SHARED freestanding.
 */
function w546_fill(arena: *u8, ctx: *u8, walk_cur: i32, go: i32, lcell: *u8): i32 {
  unsafe {
    if (go == 0) {
      pipe_store_i32_le(lcell, 0, 0);
      return 0;
    }
    let kcell: u8[8] = [];
    let vcell: u8[8] = [];
    let fcell: u8[8] = [];
    let rcell: u8[8] = [];
    pipe_store_i32_le(&kcell[0], 0, pipeline_expr_kind_ord_at(arena, walk_cur));
    pipe_store_i32_le(&vcell[0], 0, glue_var_decl_type_ref_elf_c(arena, ctx, walk_cur));
    pipe_store_i32_le(&fcell[0], 0, glue_field_access_field_type_ref_c(arena, pipeline_asm_emit_module_ref_c(), walk_cur));
    pipe_store_i32_le(&rcell[0], 0, pipeline_expr_resolved_type_ref(arena, walk_cur));
    pipe_store_i32_le(lcell, 0, 0);
    if (pipe_load_i32_le(&kcell[0], 0) == 3) {
      pipe_store_i32_le(lcell, 0, pipe_load_i32_le(&vcell[0], 0));
    }
    if (pipe_load_i32_le(lcell, 0) <= 0) {
      if (pipe_load_i32_le(&kcell[0], 0) == 44) {
        pipe_store_i32_le(lcell, 0, pipe_load_i32_le(&fcell[0], 0));
      }
    }
    if (pipe_load_i32_le(lcell, 0) <= 0) {
      pipe_store_i32_le(lcell, 0, pipe_load_i32_le(&rcell[0], 0));
    }
    return 1;
  }
}

/**
 * Resolve INDEX-chain element type into out_ltr.
 * @param arena *u8 — AST arena
 * @param left_ref i32 — INDEX expr
 * @param ctx *u8 — emit context
 * @param out_ltr *i32 — element type; written by peel, not by `*out=`
 * @return i32 — 0 ok; -3 not resolved
 * PLATFORM: SHARED freestanding · LINUX gold · MACOS|ARM64.
 */
#[no_mangle]
export function glue_emit_assign_index_array_resolve_elf_c(arena: *u8, left_ref: i32, ctx: *u8, out_ltr: *i32): i32 {
  unsafe {
    let root: u8[8] = [];
    let ncell: u8[8] = [];
    let lcell: u8[8] = [];
    let pcell: u8[8] = [];
    let go: i32 = 1;
    pipe_store_i32_le(&ncell[0], 0, glue_emit_assign_index_array_walk_elf_c(arena, left_ref, &root[0] as *i32));
    if (pipe_load_i32_le(&root[0], 0) <= 0) {
      go = 0;
    }
    w546_fill(arena, ctx, pipe_load_i32_le(&root[0], 0), go, &lcell[0]);
    if (pipe_load_i32_le(&lcell[0], 0) <= 0) {
      return 0 - 3;
    }
    pipe_store_i32_le(&pcell[0], 0, glue_emit_assign_index_array_peel_elf_c(arena, pipe_load_i32_le(&lcell[0], 0), pipe_load_i32_le(&ncell[0], 0), out_ltr));
    if (pipe_load_i32_le(&pcell[0], 0) != 0) {
      return 0 - 3;
    }
    return 0;
  }
}
