// Thin pure: EXPR_DEREF load width (w1590, checklist 10.48).
// The egg body sizes the load from the deref expr's resolved type.
// A return or a widened let types that expr as i32, so *u8 / *i8 / *i16
// become a 4-byte mov / ldrsw. This sidecar uses the pointer pointee.
// Linux, Darwin, and Windows link it ahead of the egg copy.
// Do not rebuild the pabi egg.
// PLATFORM: SHARED — x86_64 and arm64 encoders. Linux, Darwin, and
// Windows rebuild this file into runtime_pipeline_abi_deref_narrow_thin.o.

export extern function pipeline_expr_unary_operand_ref_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, op: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, type_ref: i32): i32;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_type_size_simple(mod: *u8, arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function glue_vector_type_lanes_esz_c(arena: *u8, type_ref: i32, out_lanes: *i32, out_esz: *i32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_64_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_i32_indirect_to_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_zext8_from_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_append_u8_c(elf_ctx: *u8, b: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, w: u32): i32;

/**
 * Classify a named narrow integer. Other types, including u8, return 0.
 * @param arena *u8 — AST arena; null yields 0
 * @param ty i32 — pointee type ref
 * @return i32 — 1 named i8, 2 named i16, 3 named u16, 0 otherwise
 * PLATFORM: SHARED — same spelling as the index true-pack arms.
 */
function deref_narrow_tag(arena: *u8, ty: i32): i32 {
  let sn: u8[64] = [];
  let sl: i32 = 0;
  let kind: i32 = 0;
  unsafe {
    if (ty <= 0) {
      return 0;
    }
    kind = pipeline_type_kind_ord_at(arena, ty);
    if (kind != 8) {
      return 0;
    }
    sl = pipeline_type_named_name_into(arena, ty, &sn[0]);
    // 'i' '8'
    if (sl == 2 && sn[0] == 105 && sn[1] == 56) {
      return 1;
    }
    // 'i' '1' '6'
    if (sl == 3 && sn[0] == 105 && sn[1] == 49 && sn[2] == 54) {
      return 2;
    }
    // 'u' '1' '6'
    if (sl == 3 && sn[0] == 117 && sn[1] == 49 && sn[2] == 54) {
      return 3;
    }
    return 0;
  }
}

/**
 * Sign-extending byte load from [rax] / [x0] (movsbl / LDRSB).
 * @param elf_ctx *u8 — code byte sink
 * @param ta i32 — 0 x86_64, 1 arm64, 2 falls back to zero-extend
 * @return i32 — 0 on success, -1 on an encode failure
 * PLATFORM: SHARED — bytes match the index i8 arm.
 */
function deref_enc_sext8(elf_ctx: *u8, ta: i32): i32 {
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
 * Zero-extending halfword load from [rax] / [x0] (movzwl / LDRH).
 * @param elf_ctx *u8 — code byte sink
 * @param ta i32 — 0 x86_64, 1 arm64, 2 falls back to a 64-bit load
 * @return i32 — 0 on success, -1 on an encode failure
 * PLATFORM: SHARED — bytes match the index u16 arm.
 */
function deref_enc_zext16(elf_ctx: *u8, ta: i32): i32 {
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
 * Sign-extending halfword load from [rax] / [x0] (movswl / LDRSH).
 * @param elf_ctx *u8 — code byte sink
 * @param ta i32 — 0 x86_64, 1 arm64, 2 falls back to zero-extend
 * @return i32 — 0 on success, -1 on an encode failure
 * PLATFORM: SHARED — bytes match the index i16 arm.
 */
function deref_enc_sext16(elf_ctx: *u8, ta: i32): i32 {
  if (ta == 1) {
    unsafe {
      return backend_enc_append_u32_le_c(elf_ctx, 2044723200 as u32);
    }
  }
  if (ta == 2) {
    unsafe {
      return deref_enc_zext16(elf_ctx, ta);
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
 * Emit EXPR_DEREF. The address is the operand. The load width is the
 * pointer pointee, not the widened use type of the deref expr.
 * Named i8 sign-extends, named i16 sign-extends, u8 and u16 zero-extend.
 * An i32 or i64 pointee keeps the 4-byte or 8-byte load.
 * A 2-byte aggregate that is not i16 or u16 still uses the 8-byte load.
 * @param arena *u8 — AST arena; null is rejected by the callees
 * @param elf_ctx *u8 — code byte sink
 * @param expr_ref i32 — DEREF expression
 * @param ctx *u8 — asm function context
 * @param ta i32 — 0 is x86_64, 1 is arm64
 * @return i32 — 0 on success, -1 on an encode failure
 * PLATFORM: SHARED — one strong T. Linux and Darwin link this ahead of
 * the weak copy. Windows links this ahead of the egg's external copy.
 * PE first-wins. Do not rebuild the pabi egg.
 */
#[no_mangle]
export function pipeline_asm_emit_deref_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  let op: i32 = 0;
  let rc: i32 = 0;
  let load_ty: i32 = 0;
  let op_ty: i32 = 0;
  let pe: i32 = 0;
  let kind: i32 = 0;
  let esz: i32 = 0;
  let tag: i32 = 0;
  let named_sz: i32 = 0;
  let lanes: i32 = 0;
  let lane_esz: i32 = 0;
  let modp: *u8 = 0 as *u8;
  unsafe {
    op = pipeline_expr_unary_operand_ref_at(arena, expr_ref);
    if (op <= 0) {
      return 0 - 1;
    }
    rc = pipeline_asm_emit_expr_elf_c(arena, elf_ctx, op, ctx, ta);
    if (rc != 0) {
      return 0 - 1;
    }
    // Use-site typing may have widened the deref expr to i32. The operand
    // pointer still names the real pointee (*u8, *i8, *i16).
    load_ty = pipeline_expr_resolved_type_ref(arena, expr_ref);
    op_ty = pipeline_expr_resolved_type_ref(arena, op);
    if (op_ty > 0) {
      if (pipeline_type_kind_ord_at(arena, op_ty) == 9) {
        pe = pipeline_type_elem_ref_at(arena, op_ty);
        if (pe > 0) {
          load_ty = pe;
        }
      }
    }
    if (load_ty > 0) {
      kind = pipeline_type_kind_ord_at(arena, load_ty);
    }
    // Array: leave the pointer for the let-init copy. Slice is a 16-byte fat
    // load. A pointer pointee is one machine word.
    if (kind == 10) {
      return 0;
    }
    if (kind == 11) {
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    }
    if (kind == 9) {
      return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
    }
    tag = deref_narrow_tag(arena, load_ty);
    esz = glue_array_lit_force_esz_from_elem_type_c(arena, load_ty);
    if (esz <= 0) {
      esz = glue_index_elem_byte_sz_from_type_ref_c(arena, load_ty);
    }
    // Named structs still take the larger layout. Do not let that 4-byte
    // fallback overwrite a true-pack i8 or i16.
    if (tag == 0 && kind == 8) {
      named_sz = glue_type_named_layout_size_any_module_elf_c(arena, load_ty);
      if (named_sz > esz) {
        esz = named_sz;
      }
      modp = glue_emit_module_from_ctx(ctx);
      named_sz = glue_type_size_simple(modp, arena, load_ty, 0);
      if (named_sz > esz) {
        esz = named_sz;
      }
    }
    if (tag == 0 && esz <= 8) {
      rc = glue_vector_type_lanes_esz_c(arena, load_ty, &lanes, &lane_esz);
      if (rc == 0 && lanes > 0 && lane_esz > 0) {
        esz = lanes * lane_esz;
      }
    }
    if (esz <= 0) {
      esz = 4;
    }
    if (esz > 16) {
      return 0;
    }
    if (esz > 8) {
      return pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta);
    }
    if (esz == 1) {
      if (tag == 1) {
        return deref_enc_sext8(elf_ctx, ta);
      }
      return backend_enc_load_zext8_from_rax_arch(elf_ctx, ta);
    }
    if (esz == 2 && tag == 2) {
      return deref_enc_sext16(elf_ctx, ta);
    }
    if (esz == 2 && tag == 3) {
      return deref_enc_zext16(elf_ctx, ta);
    }
    if (esz == 4) {
      return backend_enc_load_i32_indirect_to_rax_arch(elf_ctx, ta);
    }
    return backend_enc_load_64_from_rax_arch(elf_ctx, ta);
  }
}
