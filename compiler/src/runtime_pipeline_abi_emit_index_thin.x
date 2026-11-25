// Thin pure: wave351/378/387/516 Cap A — mega emit_index twin with gate removed.
// No modlet shortcut (w350 over-eager VAR+lit modlet broke Ubuntu option).
// G.7 ≡ mega pipeline_asm_emit_index_elf_c post-w350.
// wave378: BAN Ubuntu PREFER (option=240); Darwin PREFER stays.
// wave387: HARD BAN reinject both ends; stay prior Darwin PREFER / Ubuntu -E.
// wave516: tipU heal — mid `x=call()` pipe-cell; peer-flat load-arms so
//   Ubuntu tip keeps late-BB U (zext8/deref/type_kind); stamp → w516;
//   tip PRODUCT reinject still HARD BAN (keep prior overlay).
// 10.22: after lane load, add sp,#16 when CALL/METHOD spilled SIMD16
//   (nested arr[add4(...)[0]] must not pop vector as array base).
// PLATFORM: SHARED.

export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_32_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_append_u8_c(elf_ctx: *u8, b: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, w: u32): i32;
export extern function glue_emit_index_eff_addr_scaled_elf_c(arena: *u8, elf_ctx: *u8, ix_ref: i32, base_ref: i32, idx_ref: i32, ctx: *u8, ta: i32, esz: i32): i32;
export extern function glue_index_assign_addr_cache_clear(): void;
export extern function glue_index_assign_addr_cache_hit(arena: *u8, ctx: *u8, base_ref: i32, idx_ref: i32, esz: i32): i32;
export extern function glue_index_load_from_cached_assign_addr_elf_c(elf_ctx: *u8, esz: i32, ta: i32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_asm_index_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_base_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_index_index_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
/** wave516: pipe-cell helpers (keep tip U across mid-call assign). */
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_type_ref_with_decl_fallback_c(arena: *u8, base_ref: i32): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function backend_enc_arm64_add_sp_imm12_c(elf_ctx: *u8, imm: i32): i32;

/**
 * Emit signed byte load from [rax/x0] into eax/w0 (movsbl / LDRSB).
 * @param elf_ctx *u8 — emit context
 * @param ta i32 — 0 x86_64, 1 arm64, 2 riscv (zext fallback)
 * @return i32 — 0 ok; encoder rc
 * PLATFORM: SHARED — w1012 true-pack i8.
 */
function emit_index_enc_sext8_from_rax(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 969932800 as u32);
    }
  }
  if (ta == 2) {
    unsafe {
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    }
  }
  unsafe {
    if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c(elf_ctx, 190) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c(elf_ctx, 0);
  }
}

/**
 * Emit zero-extend halfword load (movzwl / LDRH).
 * @param elf_ctx *u8 — emit context
 * @param ta i32
 * @return i32 — 0 ok
 * PLATFORM: SHARED — w1015 esz=2 default.
 */
function emit_index_enc_zext16_from_rax(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 2034237440 as u32); /* 0x79400000 LDRH */
    }
  }
  if (ta == 2) {
    unsafe {
      return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    }
  }
  unsafe {
    if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c(elf_ctx, 183) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c(elf_ctx, 0);
  }
}

/**
 * Emit signed halfword load from [rax/x0] into eax/w0 (movswl / LDRSH).
 * @param elf_ctx *u8 — emit context
 * @param ta i32 — 0 x86_64, 1 arm64, 2 riscv (zext16 fallback)
 * @return i32 — 0 ok; encoder rc
 * PLATFORM: SHARED — w1015 true-pack i16.
 */
function emit_index_enc_sext16_from_rax(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 2044723200 as u32); /* 0x79C00000 LDRSH */
    }
  }
  if (ta == 2) {
    unsafe {
      return emit_index_enc_zext16_from_rax(elf_ctx, ta);
    }
  }
  unsafe {
    if (backend_enc_append_u8_c(elf_ctx, 15) != 0) {
      return 0 - 1;
    }
    if (backend_enc_append_u8_c(elf_ctx, 191) != 0) {
      return 0 - 1;
    }
    return backend_enc_append_u8_c(elf_ctx, 0);
  }
}

/**
 * Peer-flat: post-eff-addr INDEX load arms (wave516 Ubuntu tip BB budget).
 * Owns type_kind / deref_struct16 / zext8 / sext8(i8) / sext16(i16) / i32 / i64.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param expr_ref i32
 * @param ta i32
 * @param esz i32 — element byte size
 * @return i32 - 0 ok; encoder rc
 * PLATFORM: SHARED Cap A wave516 / w1012 true-pack i8 / w1015 i16.
 */

/**
 * 1 when index-base emitter spilled 16 bytes for CALL/METHOD (SIMD16 or
 * 1..8 byte array). Lane load reads the slot; emit_index adds sp back so
 * nested arr[add4(...)[0]] does not pop the vector as the array base.
 * PLATFORM: MACOS|ARM64.
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
  if (ta != 1) {
    return 0;
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

#[no_mangle]
export function glue_emit_index_load_arms_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ta: i32, esz: i32
): i32 {
  let rtycell: u8[4] = [];
  let rtkcell: u8[4] = [];
  let ecell: u8[4] = [];
  let sn: u8[64] = [];
  let sl: i32 = 0;
  unsafe {
    pipe_store_i32_le(&ecell[0], 0, esz);
    pipe_store_i32_le(&rtycell[0], 0, pipeline_expr_resolved_type_ref(arena, expr_ref));
    if (pipe_load_i32_le(&rtycell[0], 0) > 0) {
      pipe_store_i32_le(&rtkcell[0], 0, pipeline_type_kind_ord_at(
        arena, pipe_load_i32_le(&rtycell[0], 0)
      ));
      if (pipe_load_i32_le(&rtkcell[0], 0) == 10) {
        return 0;
      }
      if (pipe_load_i32_le(&rtkcell[0], 0) == 11) {
        return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
      }
    }
    if (pipe_load_i32_le(&ecell[0], 0) > 8 && pipe_load_i32_le(&ecell[0], 0) <= 16) {
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    }
    if (pipe_load_i32_le(&ecell[0], 0) != 1
      && pipe_load_i32_le(&ecell[0], 0) != 2
      && pipe_load_i32_le(&ecell[0], 0) != 4
      && pipe_load_i32_le(&ecell[0], 0) != 8) {
      return 0;
    }
    if (pipe_load_i32_le(&ecell[0], 0) == 1) {
      // True-pack named i8: sext8. u8/bool keep zext8.
      if (pipe_load_i32_le(&rtycell[0], 0) > 0
        && pipe_load_i32_le(&rtkcell[0], 0) == 8) {
        sl = pipeline_type_named_name_into(arena, pipe_load_i32_le(&rtycell[0], 0), &sn[0]);
        if (sl == 2 && sn[0] == 105 && sn[1] == 56) {
          return emit_index_enc_sext8_from_rax(elf_ctx, ta);
        }
      }
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    }
    if (pipe_load_i32_le(&ecell[0], 0) == 2) {
      // True-pack named i16: sext16. Other esz=2 keep zext16.
      if (pipe_load_i32_le(&rtycell[0], 0) > 0
        && pipe_load_i32_le(&rtkcell[0], 0) == 8) {
        sl = pipeline_type_named_name_into(arena, pipe_load_i32_le(&rtycell[0], 0), &sn[0]);
        if (sl == 3 && sn[0] == 105 && sn[1] == 49 && sn[2] == 54) {
          return emit_index_enc_sext16_from_rax(elf_ctx, ta);
        }
      }
      return emit_index_enc_zext16_from_rax(elf_ctx, ta);
    }
    if (pipe_load_i32_le(&ecell[0], 0) == 4) {
      /* 记212: TYPE_U32 → zext (ldr w / movl+zxt). i32 keeps LDRSW. */
      if (pipe_load_i32_le(&rtycell[0], 0) > 0
        && pipe_load_i32_le(&rtkcell[0], 0) == 3) {
        if (ta == 1) {
          return backend_enc_load_32_from_rax_arch(elf_ctx, ta);
        }
        if (backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta) != 0) {
          return 0 - 1;
        }
        return glue_enc_zxt_u32_result_to_rax_elf_c(elf_ctx, ta);
      }
      return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
    }
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  }
}

/**
 * Emit EXPR_INDEX rvalue — mega twin, no VAR/modlet early gate.
 * wave516: ban mid `x=call()`; pipe-cell + peer load-arms.
 * @return i32 - 0 ok; -1 fail
 * PLATFORM: SHARED Cap A wave351/516.
 */
#[no_mangle]
export function pipeline_asm_emit_index_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
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
    /* Lane in x0. Drop CALL/METHOD spill so outer index pop restores
     * the array base, not the vector. PLATFORM: MACOS|ARM64. */
    if (ta == 1) {
      pipe_store_i32_le(&hcell[0], 0, emit_index_arm64_call_spill(
        arena, pipe_load_i32_le(&bcell[0], 0), ta
      ));
      if (pipe_load_i32_le(&hcell[0], 0) != 0) {
        pipe_store_i32_le(&icell[0], 0, backend_enc_arm64_add_sp_imm12_c(elf_ctx, 16));
        if (pipe_load_i32_le(&icell[0], 0) != 0) {
          return 0 - 1;
        }
      }
    }
    return pipe_load_i32_le(&rccell[0], 0);
  }
}
