// One strong pipeline_asm_emit_index_elf_c. Windows and Linux each
// build this file into its own object. The same body lives in
// runtime_pipeline_abi_emit_index_thin.x. Do not PREFER that thin.
// Do not compile this file together with
// glue_emit_index_load_arms_elf_c: same-.o dual T smashes i32.
// That export stays in pabi_emit_index_arms_one.x.
// Do not gcc seeds/emit_index_true_i8_override.c into one object with
// the arms symbol. Darwin rebuilds this file into
// emit_index_elf_true_i8.o. Do not cc or gcc the seed on Windows,
// Linux, or Darwin.
// PLATFORM: SHARED body. Linux, Darwin, and Windows relinks consume this file.

export extern function glue_emit_index_eff_addr_scaled_elf_c(
  arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32,
  ctx: *u8, ta: i32, esz: i32
): i32;
export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_index_assign_addr_cache_hit(
  arena: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32
): i32;
export extern function glue_index_load_from_cached_assign_addr_elf_c(
  elf_ctx: *u8, esz: i32, ta: i32
): i32;
export extern function glue_emit_index_load_arms_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, esz: i32
): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Emit an INDEX rvalue: address, then the load arm for that stride.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param expr_ref i32 — INDEX expression
 * @param ctx *u8 — assign-address cache context
 * @param ta i32 — target arch code
 * @return i32 — -1 when base or index is missing, or the address emit fails;
 *   otherwise the cached-load rc or the load-arm rc
 * A cache hit skips the address emit and the load arms.
 * PLATFORM: SHARED — one strong T. Linux, Darwin, and Windows link this ahead of the egg.
 */
#[no_mangle]
export function pipeline_asm_emit_index_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32 {
  let bcell: u8[4] = [];
  let icell: u8[4] = [];
  let ecell: u8[4] = [];
  let hcell: u8[4] = [];
  let rccell: u8[4] = [];
  unsafe {
    pipe_store_i32_le(&bcell[0], 0, pipeline_expr_index_base_ref(arena, expr_ref));
    pipe_store_i32_le(&icell[0], 0, pipeline_expr_index_index_ref(arena, expr_ref));
    if (pipe_load_i32_le(&bcell[0], 0) <= 0 || pipe_load_i32_le(&icell[0], 0) <= 0) {
      return 0 - 1;
    }
    pipe_store_i32_le(&ecell[0], 0, pipeline_asm_index_elem_byte_sz_c(arena, expr_ref));
    pipe_store_i32_le(&hcell[0], 0, glue_index_assign_addr_cache_hit(
      arena, ctx,
      pipe_load_i32_le(&bcell[0], 0),
      pipe_load_i32_le(&icell[0], 0),
      pipe_load_i32_le(&ecell[0], 0)
    ));
    if (pipe_load_i32_le(&hcell[0], 0) != 0) {
      return glue_index_load_from_cached_assign_addr_elf_c(
        elf_ctx, pipe_load_i32_le(&ecell[0], 0), ta
      );
    }
    glue_index_assign_addr_cache_clear();
    pipe_store_i32_le(&rccell[0], 0, glue_emit_index_eff_addr_scaled_elf_c(
      arena, elf_ctx, expr_ref,
      pipe_load_i32_le(&bcell[0], 0),
      pipe_load_i32_le(&icell[0], 0),
      ctx, ta,
      pipe_load_i32_le(&ecell[0], 0)
    ));
    if (pipe_load_i32_le(&rccell[0], 0) != 0) {
      return 0 - 1;
    }
    return glue_emit_index_load_arms_elf_c(
      arena, elf_ctx, expr_ref, ta, pipe_load_i32_le(&ecell[0], 0)
    );
  }
}
