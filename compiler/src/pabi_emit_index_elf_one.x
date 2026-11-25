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
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_type_ref_with_decl_fallback_c(arena: *u8, base_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function backend_enc_arm64_add_sp_imm12_c(elf_ctx: *u8, imm: i32): i32;
export extern function backend_enc_append_u8_c(elf_ctx: *u8, byte: i32): i32;

/**
 * 1 when the index-base emitter spilled 16 bytes for this CALL/METHOD.
 * @param arena *u8 — expression pool; null returns 0
 * @param base_ref i32 — INDEX base; not positive returns 0
 * @param ta i32 — 0 x86_64 or 1 arm64; other targets return 0
 * @return i32 — 1 when a 16-byte SIMD pair or a 1..8 byte array value
 *   was pushed and x0 was set to that slot; 0 otherwise
 * Same gate as glue_emit_index_eff_addr_base_elf_c. The lane load still
 * reads the slot. emit_index adds sp back afterwards so a surrounding
 * push/pop does not pop the vector. A slice header is not this spill.
 * PLATFORM: SHARED — same gate as index_base_field spill.
 */
function emit_index_arm64_call_spill(arena: *u8, base_ref: i32, ta: i32): i32 {
  let ko: i32 = 0;
  let tr: i32 = 0;
  let trk: i32 = 0;
  let simd: i32 = 0;
  let lanes_buf: i32[1] = [];
  let esz_buf: i32[1] = [];
  let lanes: i32 = 0;
  let esz: i32 = 0;
  let nbytes: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let rc: i32 = 0;
  if (ta != 0) {
    if (ta != 1) {
      return 0;
    }
  }
  if (arena == 0 as *u8) {
    return 0;
  }
  if (base_ref <= 0) {
    return 0;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  if (ko != 48) {
    if (ko != 49) {
      return 0;
    }
  }
  unsafe {
    tr = glue_var_expr_type_ref_with_decl_fallback_c(arena, base_ref);
  }
  if (tr <= 0) {
    unsafe {
      tr = pipeline_expr_resolved_type_ref(arena, base_ref);
    }
  }
  if (tr <= 0) {
    return 0;
  }
  unsafe {
    trk = pipeline_type_kind_ord_at(arena, tr);
  }
  if (trk == 11) {
    return 0;
  }
  unsafe {
    simd = asm_type_is_simd_vector_spelling(arena, tr);
  }
  if (simd != 0) {
    unsafe {
      rc = glue_vector_type_lanes_esz_c(arena, tr, &lanes_buf[0], &esz_buf[0]);
    }
    if (rc != 0) {
      return 0;
    }
    lanes = lanes_buf[0];
    esz = esz_buf[0];
    if (lanes > 0) {
      if (esz > 0) {
        if (lanes * esz == 16) {
          return 1;
        }
      }
    }
    return 0;
  }
  if (trk == 10) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
      nbytes = glue_type_size_simple(mod, arena, tr, 0);
    }
    if (nbytes > 0) {
      if (nbytes <= 8) {
        return 1;
      }
    }
  }
  return 0;
}

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
 * A CALL or METHOD base of a 16-byte SIMD (or a 1..8 byte array) spills
 * that value and leaves x0 on the slot. The lane load reads it. This
 * function then adds 16 back to sp. A surrounding index keeps its saved
 * base; the vector is not what that pop restores. The epilogue is not
 * the only restore. PLATFORM: MACOS|ARM64 for the add-back. The load
 * itself is SHARED.
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
    pipe_store_i32_le(&rccell[0], 0, glue_emit_index_load_arms_elf_c(
      arena, elf_ctx, expr_ref, ta, pipe_load_i32_le(&ecell[0], 0)
    ));
    /* The lane is in rax/x0. Drop the CALL/METHOD 16-byte spill so
     * the outer index pop restores the array base, not the vector.
     * PLATFORM: SHARED (arm64 add sp,#16; x86_64 add rsp,16). */
    if (ta == 0 || ta == 1) {
      pipe_store_i32_le(&hcell[0], 0, emit_index_arm64_call_spill(
        arena, pipe_load_i32_le(&bcell[0], 0), ta
      ));
      if (pipe_load_i32_le(&hcell[0], 0) != 0) {
        if (ta == 1) {
          pipe_store_i32_le(&icell[0], 0, backend_enc_arm64_add_sp_imm12_c(elf_ctx, 16));
          if (pipe_load_i32_le(&icell[0], 0) != 0) {
            return 0 - 1;
          }
        }
        if (ta == 0) {
          /* add rsp, 16 */
          if (backend_enc_append_u8_c(elf_ctx, 72) != 0) {
            return 0 - 1;
          }
          if (backend_enc_append_u8_c(elf_ctx, 131) != 0) {
            return 0 - 1;
          }
          if (backend_enc_append_u8_c(elf_ctx, 196) != 0) {
            return 0 - 1;
          }
          if (backend_enc_append_u8_c(elf_ctx, 16) != 0) {
            return 0 - 1;
          }
        }
      }
    }
    return pipe_load_i32_le(&rccell[0], 0);
  }
}
