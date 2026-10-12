// Link body of glue_field_call_arg_try_load_agg_from_rax_elf_c.
// The tip function in runtime_pipeline_abi.x sizes a named field even when
// no call argument is active. A 9 to 16 byte field is dereferenced into the
// return pair. A field wider than 16 bytes returns 0 so the caller can
// memcpy from the address. A field of at most 8 bytes returns 0 outside a
// call, so the scalar load keeps the real width, and loads one qword only
// while a call argument is active.
// The Linux egg is one weak body that returns 0 as soon as
// pipeline_asm_emit_call_arg_active_c is 0. A let or assign of the field
// never reaches those size gates. Three R_X86_64_PLT32 sites in that object
// name this symbol. The Windows egg is one strong T with the same early
// return, and three same-TU calls enter that entry. Darwin's pabi_weak
// already follows the tip gates, so this file is not a Darwin input.
// Every extern result goes through a pipe cell. The product drops a direct
// "name = extern(...)" store. The module pointer uses the pointer cell.
// This file does not divide or take a remainder. Do not set
// XLANG_PREFER_ASM_O. The mega function stays the authority. Do not change
// this control flow apart from the pipe cells.
// PLATFORM: LINUX and WINDOWS link of the SHARED tip body. Not Darwin.

export extern function pipeline_asm_emit_call_arg_active_c(): i32;
export extern function pipeline_asm_emit_ctx_call_param_ty_get(): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function glue_field_access_field_type_ref_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_field_access_layout_field_type_ref_by_name_c(arena: *u8, mod: *u8, fa_ref: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function pipe_load_ptr_slot(base: *u8, i: i32): *u8;
export extern function pipe_store_ptr_slot(base: *u8, i: i32, val: *u8): void;

/**
 * Load one i32 that pipe_store_i32_le just wrote at offset 0.
 * The name is unique to this object. The store-pair thin already emits
 * w2060_store_pair_cell_i32, so this object must not reuse that name.
 * @param base *u8 — 8-byte cell; the i32 is at offset 0. Null is not used.
 * @return i32 — the stored value
 * PLATFORM: LINUX and WINDOWS. Not an egg symbol. Linux refresh weakens
 * this global. Windows leaves the filename-prefixed name strong, because
 * the egg does not define it. It is not a patch-list symbol.
 */
function w2060_field_agg_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Load one pointer that pipe_store_ptr_slot just wrote at slot 0.
 * @param base *u8 — 8-byte cell; slot 0 is the pointer. Null is not used.
 * @return *u8 — the stored pointer, which may itself be null
 * PLATFORM: LINUX and WINDOWS. Not an egg symbol. Linux refresh weakens
 * this global. Windows leaves the filename-prefixed name strong, because
 * the egg does not define it. It is not a patch-list symbol.
 */
function w2060_field_agg_cell_ptr(base: *u8): *u8 {
  unsafe {
    return pipe_load_ptr_slot(base, 0);
  }
}

/**
 * After the field address is in rax, load a named aggregate into the
 * return pair, or leave it for the scalar load.
 * A live call argument uses the formal type when that formal is a named
 * struct. A let or assign has no live formal, so the field's own type is
 * the gate. Wider than 16 bytes returns 0. 9 to 16 bytes dereferences into
 * the pair and returns 1. At most 8 bytes returns 0 outside a call, and
 * loads one qword during a call.
 * @param arena *u8 — AST arena. Null returns 0.
 * @param elf_ctx *u8 — emit context. Null returns 0.
 * @param fa_ref i32 — FIELD_ACCESS expr ref
 * @param ta i32 — target arch. 0 is x86_64. 1 is arm64.
 * @return i32 — 1 when the pair or the qword load is done. 0 when the
 *   caller should scalar-load or memcpy. -1 when an encoder returns nonzero.
 * PLATFORM: LINUX and WINDOWS link of the SHARED tip. Darwin is not a
 * consumer. Keep the gates identical to
 * glue_field_call_arg_try_load_agg_from_rax_elf_c in runtime_pipeline_abi.x.
 */
#[no_mangle]
export function glue_field_call_arg_try_load_agg_from_rax_elf_c(arena: *u8, elf_ctx: *u8, fa_ref: i32, ta: i32): i32 {
  let fty: i32 = 0;
  let sz: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let pty: i32 = 0;
  let kord: i32 = 0;
  let active: i32 = 0;
  let rc: i32 = 0;
  let cell: u8[8];
  let pcell: u8[8];
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8)) {
    return 0;
  }
  // Formal type only while a call arg is active. Outside a call the saved
  // param type is stale and must not size a let or assign.
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_call_arg_active_c());
  }
  active = w2060_field_agg_cell_i32(&cell[0]);
  if (active != 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_ctx_call_param_ty_get());
    }
    pty = w2060_field_agg_cell_i32(&cell[0]);
    if (pty > 0) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipeline_type_kind_ord_at(arena, pty));
      }
      kord = w2060_field_agg_cell_i32(&cell[0]);
      // Named struct is kind 8.
      if (kord == 8) {
        fty = pty;
      }
    }
  }
  unsafe {
    pipe_store_ptr_slot(&pcell[0], 0, pipeline_asm_emit_module_ref_c());
  }
  mod = w2060_field_agg_cell_ptr(&pcell[0]);
  if (fty <= 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, glue_field_access_field_type_ref_c(arena, mod, fa_ref));
    }
    fty = w2060_field_agg_cell_i32(&cell[0]);
  }
  if (fty <= 0 && mod != (0 as *u8)) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, glue_field_access_layout_field_type_ref_by_name_c(arena, mod, fa_ref));
    }
    fty = w2060_field_agg_cell_i32(&cell[0]);
  }
  if (fty <= 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_type_kind_ord_at(arena, fty));
  }
  kord = w2060_field_agg_cell_i32(&cell[0]);
  if (kord != 8) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_type_named_layout_size_any_module_elf_c(arena, fty));
  }
  sz = w2060_field_agg_cell_i32(&cell[0]);
  if (sz <= 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, glue_type_size_simple(mod, arena, fty, 0));
    }
    sz = w2060_field_agg_cell_i32(&cell[0]);
  }
  if (sz <= 0) {
    return 0;
  }
  // Wider than 16 bytes: leave the address in rax for the caller memcpy.
  if (sz > 16) {
    return 0;
  }
  // 9 to 16 bytes: both halves, including a let or assign with no formal.
  if (sz > 8) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta));
    }
    rc = w2060_field_agg_cell_i32(&cell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
    return 1;
  }
  // At most 8 bytes. Outside a call the scalar emitter owns the width.
  unsafe {
    pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_call_arg_active_c());
  }
  active = w2060_field_agg_cell_i32(&cell[0]);
  if (active == 0) {
    return 0;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_load_64_from_rax_arch(elf_ctx, ta));
  }
  rc = w2060_field_agg_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  return 1;
}
