// One strong glue_emit_index_load_arms_elf_c. Windows and Linux each
// build this file into its own object. The same body lives in
// runtime_pipeline_abi_emit_index_thin.x. Do not PREFER that thin.
// Do not compile this file together with pipeline_asm_emit_index_elf_c:
// same-.o dual T smashes i32. That export stays in
// pabi_emit_index_elf_one.x. Do not gcc
// seeds/emit_index_true_i8_override.c into one object with the elf
// symbol. Darwin still prepends a leftover combined object.
// PLATFORM: SHARED body. Linux and Windows relinks consume this file.

export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_append_u8_c(elf_ctx: *u8, b: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, w: u32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Emit a signed byte load from [rax/x0] into eax/w0 (movsbl / LDRSB).
 * @param elf_ctx *u8 — encoder context; null is the encoder's problem
 * @param ta i32 — 0 x86_64, 1 arm64, 2 other (zext fallback)
 * @return i32 — 0 when the bytes were appended; encoder rc otherwise
 * PLATFORM: SHARED — file-local helper, not a link export.
 */
function emit_index_enc_sext8_from_rax(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe {
      // 0x39C00000 LDRSB W0,[X0]. The thin's 969932800 is 0x39D00000.
      return backend_enc_append_u32_le_c(elf_ctx, 968884224 as u32);
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
 * Emit a zero-extend halfword load (movzwl / LDRH).
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — 0 x86_64, 1 arm64, 2 other (64-bit load fallback)
 * @return i32 — 0 when the bytes were appended; encoder rc otherwise
 * PLATFORM: SHARED — file-local helper, not a link export.
 */
function emit_index_enc_zext16_from_rax(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 2034237440 as u32);
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
 * Emit a signed halfword load from [rax/x0] into eax/w0 (movswl / LDRSH).
 * @param elf_ctx *u8 — encoder context
 * @param ta i32 — 0 x86_64, 1 arm64, 2 other (zext16 fallback)
 * @return i32 — 0 when the bytes were appended; encoder rc otherwise
 * PLATFORM: SHARED — file-local helper, not a link export.
 */
function emit_index_enc_sext16_from_rax(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe {
      // 0x79C00000 LDRSH W0,[X0]. The thin's 2044723200 is 0x79E00000.
      return backend_enc_append_u32_le_c(elf_ctx, 2042626048 as u32);
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
 * Emit the INDEX load that follows a computed element address.
 * @param arena *u8 — AST arena; null fails closed inside the type queries
 * @param elf_ctx *u8 — encoder context
 * @param expr_ref i32 — INDEX expression
 * @param ta i32 — target arch code passed to the encoders
 * @param esz i32 — element stride in bytes
 * @return i32 — 0 when no bytes are required or the encoder accepted them;
 *   the deref helper's rc for a 16-byte slot; -1 when an append fails
 * Named i8 (esz 1) sign-extends. Other esz 1 zero-extends.
 * Named i16 (esz 2) sign-extends. Other esz 2 zero-extends.
 * Type kind 10 returns 0. Type kind 11 and strides 9..16 deref 16 bytes.
 * PLATFORM: SHARED — one strong T. Windows links this ahead of the egg.
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
      // Named i8 sign-extends. u8 and bool stay on the zero-extend load.
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
      // Named i16 sign-extends. Every other 2-byte element zero-extends.
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
      return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
    }
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  }
}
