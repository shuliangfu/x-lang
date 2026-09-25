// Thin pure: wave351/378/387/516 Cap A — mega emit_index twin with gate removed.
// No modlet shortcut (w350 over-eager VAR+lit modlet broke Ubuntu option).
// G.7 ≡ mega pipeline_asm_emit_index_elf_c post-w350.
// wave378: BAN Ubuntu PREFER (option=240); Darwin PREFER stays.
// wave387: HARD BAN reinject both ends; stay prior Darwin PREFER / Ubuntu -E.
// wave516: tipU heal — mid `x=call()` pipe-cell; peer-flat load-arms so
//   Ubuntu tip keeps late-BB U (zext8/deref/type_kind); stamp → w516;
//   tip PRODUCT reinject still HARD BAN (keep prior overlay).
// PLATFORM: SHARED.

export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
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
 * Peer-flat: post-eff-addr INDEX load arms (wave516 Ubuntu tip BB budget).
 * Owns type_kind / deref_struct16 / zext8 / sext8(i8) / i32 / i64 load U.
 * @param arena *u8
 * @param elf_ctx *u8
 * @param expr_ref i32
 * @param ta i32
 * @param esz i32 — element byte size
 * @return i32 - 0 ok; encoder rc
 * PLATFORM: SHARED Cap A wave516 / w1012 true-pack i8.
 */
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
    if (pipe_load_i32_le(&ecell[0], 0) == 4) {
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
    return glue_emit_index_load_arms_elf_c(
      arena, elf_ctx, expr_ref, ta, pipe_load_i32_le(&ecell[0], 0)
    );
  }
}
