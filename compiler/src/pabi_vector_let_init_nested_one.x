// One strong pipeline_asm_emit_vector_let_init_elf_c for the Windows
// true-pack link. Body is seeds/vector_let_init_nested_override.c.
// The mangled Cap residual name and the Darwin stubdead name are the
// same body, but each is its own object: same-.o dual T smashes i32.
// runtime_pipeline_abi.x only export-externs this short name. Do not
// fold this TU into the egg. Do not gcc the seed on the Windows path.
// Linux and Darwin still compile the C. PLATFORM: SHARED body.
// Windows relink consumes this object.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, ai: i32): i32;
export extern function pipeline_asm_array_lit_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_array_lit_leaf_elem_byte_sz_c(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_asm_emit_array_lit_flat_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32,
  leaf_esz: i32, flat_i: *i32
): i32;
export extern function glue_array_lit_emit_scalar_elem_to_rax_elf_c(
  arena: *u8, elf_ctx: *u8, lit: i32, elem: i32, ctx: *u8, ta: i32, esz: i32
): i32;
export extern function glue_expr_emit_may_clobber_rbx_elf_c(arena: *u8, expr_ref: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rax_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(
  elf_ctx: *u8, off: i32, sz: i32, ta: i32
): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function pipeline_asm_array_lit_elem_type_ref(arena: *u8, array_lit_expr_ref: i32): i32;
export extern function glue_emit_struct_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, let_ty_ref: i32, stack_slot_off: i32
): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32;
export extern function pipeline_asm_emit_struct_lit_fields_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(
  elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32
): i32;

/**
 * Store one element whose size is not 1, 2, 4, or 8 bytes.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param elf_ctx *u8 — object writer; caller already rejected null
 * @param elem_ref i32 — element expr ref; caller already skipped 0
 * @param ctx *u8 — AsmFuncCtx; caller already rejected null
 * @param ta i32 — 0 x86, 1 arm64; any other value returns 1 with no calls
 * @param stack_slot_off i32 — array base slot; lea uses this, not home
 * @param esz i32 — element stride in bytes
 * @param ai i32 — element index; arm64 home is base+ai*esz, x86 home is base-ai*esz
 * @param elem_ty i32 — element type ref; 0 when the caller did not load one
 * @return i32 — 0 stored, 1 not handled here, -1 error
 * STRUCT_LIT (kind 45) writes fields at home. Other kinds try struct
 * let-init at home. VAR, FIELD, and INDEX (kinds 3, 44, 47) that the
 * let-init declines then copy esz bytes from the element's address.
 * The copy lea uses stack_slot_off, then adds ai*esz only when ai > 0.
 * PLATFORM: SHARED.
 */
function vlet_wide_elem(
  arena: *u8, elf_ctx: *u8, elem_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, esz: i32, ai: i32, elem_ty: i32
): i32 {
  let home: i32 = 0;
  let ek: i32 = 0;
  let st: i32 = 0;
  let rc: i32 = 0;
  if (ta != 0 && ta != 1) {
    return 1;
  }
  if (ta == 1) {
    home = stack_slot_off + ai * esz;
  } else {
    home = stack_slot_off - ai * esz;
  }
  if (home < 0) {
    return 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, elem_ref);
  }
  if (ek == 45) {
    unsafe {
      st = pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, elem_ref, ctx, ta, home);
    }
    if (st != 0) {
      return 0 - 1;
    }
    return 0;
  }
  unsafe {
    st = glue_emit_struct_type_let_init_elf_c(
      arena, elf_ctx, elem_ref, ctx, ta, elem_ty, home);
  }
  if (st == 0) {
    return 0;
  }
  if (st == (0 - 1)) {
    return 0 - 1;
  }
  if (ek != 3 && ek != 44 && ek != 47) {
    return 1;
  }
  unsafe {
    rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, elem_ref, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_push_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  // ai == 0 does not call add. The C && short-circuit is the same.
  if (ai > 0) {
    unsafe {
      rc = backend_enc_add_imm_to_rax_arch(elf_ctx, ai * esz, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_pop_rax_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, esz, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Return 1 when any element is itself an ARRAY_LIT.
 * @param arena *u8 — AST arena
 * @param init_ref i32 — outer ARRAY_LIT expr ref
 * @param n_arr i32 — element count; caller already checked 1..1024
 * @return i32 — 1 if some element kind is 46, else 0
 * Stops at the first nested row, matching the C break. An element ref
 * that is not positive does not call kind.
 * PLATFORM: SHARED.
 */
function vlet_has_nested(arena: *u8, init_ref: i32, n_arr: i32): i32 {
  let ai: i32 = 0;
  let elem_ref: i32 = 0;
  let ek: i32 = 0;
  while (ai < n_arr) {
    unsafe {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    }
    if (elem_ref > 0) {
      unsafe {
        ek = pipeline_expr_kind_ord_at(arena, elem_ref);
      }
      if (ek == 46) {
        return 1;
      }
    }
    ai = ai + 1;
  }
  return 0;
}

/**
 * Emit one scalar element into the slot after a declined wide store.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — object writer
 * @param init_ref i32 — outer ARRAY_LIT expr ref
 * @param elem_ref i32 — element expr ref; not zero
 * @param ctx *u8 — AsmFuncCtx
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — array base slot
 * @param esz i32 — element stride passed to the scalar emitter
 * @param ai i32 — element index; store offset is ai*esz
 * @param store_sz i32 — 1, 2, 4, or 8; may differ from esz
 * @return i32 — 0 stored, -1 when any encode or the scalar emit fails
 * may_clobber is sampled before the scalar emit and applied after it.
 * PLATFORM: SHARED.
 */
function vlet_scalar_one(
  arena: *u8, elf_ctx: *u8, init_ref: i32, elem_ref: i32, ctx: *u8,
  ta: i32, stack_slot_off: i32, esz: i32, ai: i32, store_sz: i32
): i32 {
  let may_clobber: i32 = 0;
  let rc: i32 = 0;
  unsafe {
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    may_clobber = glue_expr_emit_may_clobber_rbx_elf_c(arena, elem_ref);
  }
  unsafe {
    rc = glue_array_lit_emit_scalar_elem_to_rax_elf_c(
      arena, elf_ctx, init_ref, elem_ref, ctx, ta, esz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  if (may_clobber != 0) {
    unsafe {
      rc = backend_enc_push_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, stack_slot_off, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
    unsafe {
      rc = backend_enc_pop_rax_arch(elf_ctx, ta);
    }
    if (rc != 0) {
      return 0 - 1;
    }
  }
  unsafe {
    rc = backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, ai * esz, store_sz, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * ARRAY_LIT into a stack slot. Nested rows flatten. A flat row stores
 * one element at a time.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — object writer; null returns -1
 * @param init_ref i32 — expr ref; not positive, or not kind 46, returns -1
 * @param ctx *u8 — AsmFuncCtx; null returns -1
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — destination slot of element 0
 * @return i32 — 0 when every element is stored, -1 on a hard failure
 * Count must be in 1..1024. A nested element uses the leaf stride
 * (default 4) and array_lit_flat. Otherwise the element stride
 * (default 4) is clamped to a store width of 1, 2, 4, or 8. A wider
 * element tries vlet_wide_elem first. Element ref 0 is skipped.
 * PLATFORM: SHARED.
 */
function vlet_nested_body(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  let n_arr: i32 = 0;
  let esz: i32 = 0;
  let store_sz: i32 = 0;
  let ai: i32 = 0;
  let elem_ref: i32 = 0;
  let has_nested: i32 = 0;
  let flat_i: i32 = 0;
  let elem_ty: i32 = 0;
  let wide: i32 = 0;
  let rc: i32 = 0;
  let ek: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || init_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ek = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (ek != 46) {
    return 0 - 1;
  }
  unsafe {
    n_arr = pipeline_expr_array_lit_num_elems_at(arena, init_ref);
  }
  if (n_arr <= 0 || n_arr > 1024) {
    return 0 - 1;
  }
  has_nested = vlet_has_nested(arena, init_ref, n_arr);
  if (has_nested != 0) {
    unsafe {
      esz = pipeline_asm_array_lit_leaf_elem_byte_sz_c(arena, init_ref);
    }
    if (esz <= 0) {
      esz = 4;
    }
    flat_i = 0;
    unsafe {
      rc = pipeline_asm_emit_array_lit_flat_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, stack_slot_off, esz, &flat_i);
    }
    return rc;
  }
  unsafe {
    esz = pipeline_asm_array_lit_elem_byte_sz_c(arena, init_ref);
  }
  if (esz <= 0) {
    esz = 4;
  }
  store_sz = esz;
  if (store_sz != 1 && store_sz != 2 && store_sz != 4 && store_sz != 8) {
    store_sz = 4;
  }
  elem_ty = 0;
  if (store_sz != esz) {
    unsafe {
      elem_ty = pipeline_asm_array_lit_elem_type_ref(arena, init_ref);
    }
  }
  while (ai < n_arr) {
    unsafe {
      elem_ref = pipeline_expr_array_lit_elem_ref(arena, init_ref, ai);
    }
    if (elem_ref != 0) {
      if (store_sz != esz) {
        wide = vlet_wide_elem(
          arena, elf_ctx, elem_ref, ctx, ta, stack_slot_off, esz, ai, elem_ty);
        if (wide < 0) {
          return 0 - 1;
        }
        if (wide != 0) {
          rc = vlet_scalar_one(
            arena, elf_ctx, init_ref, elem_ref, ctx, ta, stack_slot_off, esz, ai, store_sz);
          if (rc != 0) {
            return 0 - 1;
          }
        }
      } else {
        rc = vlet_scalar_one(
          arena, elf_ctx, init_ref, elem_ref, ctx, ta, stack_slot_off, esz, ai, store_sz);
        if (rc != 0) {
          return 0 - 1;
        }
      }
    }
    ai = ai + 1;
  }
  return 0;
}

/**
 * Short name. Thin callers and the egg call this.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — object writer; null returns -1
 * @param init_ref i32 — ARRAY_LIT expr ref; not positive returns -1
 * @param ctx *u8 — AsmFuncCtx; null returns -1
 * @param ta i32 — 0 x86, 1 arm64
 * @param stack_slot_off i32 — destination slot of element 0
 * @return i32 — 0 stored, -1 hard failure or not an ARRAY_LIT
 * The mangled name and stubdead live in their own objects and call
 * this symbol. They are not defined here.
 * PLATFORM: SHARED — Windows true-pack links this object first.
 */
#[no_mangle]
export function pipeline_asm_emit_vector_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  return vlet_nested_body(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}
