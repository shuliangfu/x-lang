// knife 254 / 9.2 struct_lit_*: Darwin tip authority for
//   win_emit_struct_lit_fields_into_parked_rbx
//   pipeline_asm_emit_struct_lit_fields_elf_c
//   pipeline_asm_emit_struct_lit_elf_c
// Darwin wide-copy gate is ahead of
// seeds/runtime_pipeline_abi.windows_link_stubs.c. That seed still
// stores an ARRAY_LIT wider than 16 as a pointer. Do not edit it here.
// (reserve home, park rbx, call win_emit, materialize ≤16B into GP).
// Do not take these T from archive_leaf (stale CG002). Rebuild every
// Darwin relink with _g05_pure_overlay (no PREFER). Pipe cells hold
// every extern result. No integer / or %.
// PLATFORM: MACOS|DARWIN tip cold.

export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_emit_module_from_ctx(ctx: *u8): *u8;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_expr_struct_lit_num_fields(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_init_ref(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_expr_struct_lit_field_offset_at(arena: *u8, mod: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_expr_struct_lit_field_type_ref_at(arena: *u8, mod: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_expr_struct_lit_value_bytes(a: *u8, m: *u8, expr_ref: i32): i32;
export extern function glue_struct_lit_field_store_sz(arena: *u8, expr_ref: i32, fi: i32): i32;
export extern function pipeline_asm_emit_expr_elf_rec(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_pop_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_push_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbx_offset_arch(elf_ctx: *u8, off: i32, load_sz: i32, ta: i32): i32;
export extern function backend_enc_append_u32_le_c(elf_ctx: *u8, w: u32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rax_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rbx_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_load_rbp_to_rdx_arch(elf_ctx: *u8, off: i32, ta: i32): i32;
export extern function glue_type_named_layout_size_any_module_elf_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_asm_type_ref_byte_size_c(arena: *u8, ty_ref: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32): i32;
export extern function pipe_asm_ctx_off_next_offset(): i32;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;
export extern function pipeline_type_elem_ref_at(arena: *u8, ty_ref: i32): i32;
export extern function glue_simd_alloc_vector_temp_slot_c(arena: *u8, ctx: *u8, type_ref: i32): i32;
export extern function glue_emit_vector_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  stack_slot_off: i32, type_ref: i32): i32;
export extern function asm_type_is_simd_vector_spelling(arena: *u8, type_ref: i32): i32;
export extern function glue_vector_elem_is_f32_c(arena: *u8, type_ref: i32): i32;
export extern function vector_let_init_array_lit_a64_vlet_f32_fill_lane(arena: *u8, type_ref: i32): i32;
export extern function glue_is_vector_lane_scalar_binop_ko(ko: i32): i32;
export extern function pipeline_lane_operand_emit_let_block_chain(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, budget: i32
): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function asm_ctx_local_find_offset_scoped(ctx: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function asm_ctx_local_find_offset(ctx: *u8, name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_match_name_is_subject_field_c(module: *u8, arena: *u8, name: *u8, name_len: i32): i32;
export extern function pipeline_codegen_match_matched_ref_c(): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function glue_field_layout_offset_for_var_base_field(arena: *u8, mod: *u8, base_var_ref: i32, field_name: *u8, flen: i32): i32;
export extern function backend_enc_add_imm_to_rax_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function pipeline_expr_resolved_type_ref(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_struct_lit_type_name_set(arena: *u8, expr_ref: i32, name: *u8, name_len: i32): void;
export extern function pipeline_type_named_name_into(arena: *u8, type_ref: i32, out: *u8): i32;
export extern function pipeline_expr_array_lit_num_elems_at(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_array_lit_elem_ref(arena: *u8, expr_ref: i32, index: i32): i32;
export extern function pipeline_expr_set_resolved_type_ref(arena: *u8, expr_ref: i32, ty: i32): void;

/**
 * Copy a match-bound aggregate into one STRUCT_LIT field.
 * The bind has no local slot, so emit_expr leaves the struct-lit
 * address in x0 and the scalar store writes that pointer.
 * A declared local of the same name is left to the existing store.
 * @param arena *u8 — expression arena
 * @param elf_ctx *u8 — emit context
 * @param iref i32 — field init, kind VAR
 * @param ctx *u8 — asm function context
 * @param ta i32 — 0 x86_64, 1 arm64
 * @param mod *u8 — module for the subject layout
 * @param store_off i32 — byte offset of this field in the parked base
 * @return i32 — 0 stored; -99 not a slotless match bind; -1 encode error
 * PLATFORM: MACOS|DARWIN. The copy is the existing x19 memcpy.
 */
function struct_lit_store_match_bind_field(
  arena: *u8, elf_ctx: *u8, iref: i32, ctx: *u8, ta: i32, mod: *u8, store_off: i32
): i32 {
  let nm: u8[256] = [];
  let matched: i32 = 0;
  let src_off: i32 = 0;
  let bind_off: i32 = 0;
  let fty: i32 = 0;
  let nbytes: i32 = 0;
  let add_x19: u32 = 0;
  let cell: u8[8];
  if (ctx == (0 as *u8) || mod == (0 as *u8) || iref <= 0) {
    return 0 - 99;
  }
  if (ta != 0 && ta != 1) {
    return 0 - 99;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, iref, &nm[0]);
  }
  unsafe {
    if (asm_ctx_local_find_offset_scoped(ctx, arena, &nm[0], pipeline_expr_var_name_len(arena, iref)) >= 0) {
      return 0 - 99;
    }
    if (asm_ctx_local_find_offset(ctx, &nm[0], pipeline_expr_var_name_len(arena, iref)) >= 0) {
      return 0 - 99;
    }
    if (pipeline_codegen_match_name_is_subject_field_c(mod, arena, &nm[0], pipeline_expr_var_name_len(arena, iref)) == 0) {
      return 0 - 99;
    }
    matched = pipeline_codegen_match_matched_ref_c();
  }
  if (matched <= 0) {
    return 0 - 99;
  }
  unsafe {
    src_off = glue_var_expr_stack_off_elf_c(arena, ctx, matched);
    bind_off = glue_field_layout_offset_for_var_base_field(arena, mod, matched, &nm[0], pipeline_expr_var_name_len(arena, iref));
  }
  if (src_off < 0 || bind_off < 0) {
    return 0 - 99;
  }
  unsafe {
    fty = pipeline_expr_resolved_type_ref(arena, iref);
  }
  if (fty <= 0) {
    return 0 - 99;
  }
  unsafe {
    nbytes = glue_type_named_layout_size_any_module_elf_c(arena, fty);
  }
  if (nbytes < 8) {
    unsafe {
      nbytes = pipeline_asm_type_ref_byte_size_c(arena, fty);
    }
  }
  if (nbytes < 8) {
    return 0 - 99;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    if (bind_off != 0) {
      pipe_store_i32_le(&cell[0], 0, backend_enc_add_imm_to_rax_arch(elf_ctx, bind_off, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    }
    pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2852193267 as u32));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    if (store_off > 0) {
      add_x19 = (2432696947 as u32) | ((store_off as u32) * 1024);
      pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, add_x19));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    }
    pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
  }
  return 0;
}

function w254_sl_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Copy a TYPE_NAMED type's name onto an anonymous STRUCT_LIT.
 * A lit that already has a type name is unchanged. A type that is
 * not kind 8, or a name outside 1..255, does nothing. Field offset
 * and the array element stride both key off that name. Without it,
 * `{ inn: { xs: [ { a: 5, b: 6 }, { a: 50, b: 49 } ] } }` places the
 * next element 4 bytes later, so xs[0].b reads 50.
 * @param arena *u8 — AST arena; null returns 0
 * @param lit_ref i32 — STRUCT_LIT expr; <=0 returns 0
 * @param ty_ref i32 — expected type; <=0 returns 0
 * @return i32 — 1 when the lit has a name afterwards, else 0
 * PLATFORM: MACOS|DARWIN.
 */
function w636_sl_stamp_named(arena: *u8, lit_ref: i32, ty_ref: i32): i32 {
  let nlen: i32 = 0;
  let k: i32 = 0;
  let buf: u8[256] = [];
  if (arena == (0 as *u8) || lit_ref <= 0 || ty_ref <= 0) {
    return 0;
  }
  unsafe {
    nlen = pipeline_expr_struct_lit_type_name_len(arena, lit_ref);
  }
  if (nlen > 0) {
    return 1;
  }
  unsafe {
    k = pipeline_type_kind_ord_at(arena, ty_ref);
  }
  if (k != 8) {
    return 0;
  }
  unsafe {
    nlen = pipeline_type_named_name_into(arena, ty_ref, &buf[0]);
  }
  if (nlen <= 0 || nlen > 255) {
    return 0;
  }
  unsafe {
    pipeline_expr_struct_lit_type_name_set(arena, lit_ref, &buf[0], nlen);
  }
  return 1;
}

/**
 * Name each anonymous STRUCT_LIT element of an ARRAY_LIT from the
 * field element type. The field type must be TYPE_ARRAY (kind 10)
 * of a TYPE_NAMED element. Other shapes write nothing. At most 64
 * elements, the same cap as the field loop.
 * @param arena *u8 — AST arena; null returns 0
 * @param arr_ref i32 — ARRAY_LIT expr; <=0 returns 0
 * @param field_ty i32 — layout type of the field being stored
 * @return i32 — how many elements now have a name
 * PLATFORM: MACOS|DARWIN.
 */
function w636_sl_stamp_array_elems(arena: *u8, arr_ref: i32, field_ty: i32): i32 {
  let k: i32 = 0;
  let elem_ty: i32 = 0;
  let n: i32 = 0;
  let i: i32 = 0;
  let er: i32 = 0;
  let stamped: i32 = 0;
  if (arena == (0 as *u8) || arr_ref <= 0 || field_ty <= 0) {
    return 0;
  }
  unsafe {
    k = pipeline_type_kind_ord_at(arena, field_ty);
  }
  if (k != 10) {
    return 0;
  }
  unsafe {
    elem_ty = pipeline_type_elem_ref_at(arena, field_ty);
  }
  if (elem_ty <= 0) {
    return 0;
  }
  unsafe {
    n = pipeline_expr_array_lit_num_elems_at(arena, arr_ref);
  }
  if (n <= 0 || n > 64) {
    return 0;
  }
  while (i < n) {
    unsafe {
      er = pipeline_expr_array_lit_elem_ref(arena, arr_ref, i);
    }
    if (er > 0) {
      unsafe {
        k = pipeline_expr_kind_ord_at(arena, er);
      }
      if (k == 45) {
        if (w636_sl_stamp_named(arena, er, elem_ty) != 0) {
          stamped = stamped + 1;
        }
      }
    }
    i = i + 1;
  }
  return stamped;
}

/**
 * Store each STRUCT_LIT field into the base parked in rbx/x19.
 * Nested STRUCT_LIT (kind 45) recurses. Other inits are emitted, then
 * stored. VAR, FIELD, INDEX, CALL, and METHOD of 9..16 bytes spill the
 * x0:x1 value and copy those bytes. ARRAY_LIT (kind 46) leaves the
 * payload address in x0. A TYPE_ARRAY field's named-layout size is not
 * that byte count. glue_fixed_array_total_bytes_c supplies N times the
 * element stride. When that count is at least 8, the same address copy
 * stores the payload. An 8-byte array used to miss the wide gate and
 * store the pointer. An array wider than 16 used to stay on that same
 * 8-byte store. A local VAR of that field is not an ARRAY_LIT: emit_expr
 * leaves the array address, and the 8-byte store wrote the pointer, so
 * `*p = { two: src }` kept the zeroed [2]Wrap (Darwin leftover 175).
 * That VAR is lea'd from its frame slot and copied with the same x19
 * memcpy. A named SIMD field is not a TYPE_ARRAY, so that helper
 * returns 0 and the layout size stays lanes times the element width.
 * When that size is at least 8, ARRAY_LIT uses the same address copy.
 * i32x8 is TYPE_NAMED (kind 8) and is 32 bytes. Vec8i is TYPE_VECTOR
 * (kind 13): named-layout returns 0 by contract, and the array helper
 * returns 0 unless kind is 10. pipeline_asm_type_ref_byte_size_c is
 * lanes times the element size (Vec8i is 32, Vec4f is 16). An integer
 * literal into a kind-8 integer spelling uses the same let-init splat
 * as kind 13. A FLOAT_LIT on that same kind-8 gate enters only when
 * vector_let_init_array_lit_a64_vlet_f32_fill_lane returns nonzero.
 * f32x8 is that spelling: the live classifier returns 0, so the
 * integer gate is already open, and `H { v: 1.0 }` used to store one
 * f64 word. The helper declines an integer spelling. Kind 22 of a
 * float already entered. A lane binop (kinds 4..13) and a transparent
 * block use that same let-init. The scalar store keeps at most 8
 * bytes, so lane 7 of `H { v: a + a }` was not the sum. Kind 51 stays
 * on the scalar store: the binop helper reports it, and the let-init
 * would read binop children and fail. A block with lets is wider than
 * 8 bytes here: pipeline_lane_operand_emit_let_block_chain emits those
 * lets and returns the value, then this classifies that value. Nested
 * blocks are that one chain. f32x4 and
 * Vec4f do not reach this gate.
 * A VAR of 9..16 bytes (Vec4f) uses that byte size as
 * `wide` when the named layout is below 8, then the existing x0:x1
 * spill. A width above 16 is not that pair. Kind 13 alignment is
 * unchanged. Do not pin a vector name. A width below 8 stays on the
 * scalar store: the copy rejects it. Layouts wider than 16 for the
 * other kinds already copy from the address in x0.
 * @param arena *u8 — expression arena. Null returns -1.
 * @param elf_ctx *u8 — emit context. Null returns -1.
 * @param lit_ref i32 — STRUCT_LIT expression ref. Non-positive returns -1.
 * @param ctx *u8 — asm ctx. Null falls back to the module ref.
 * @param ta i32 — 0 is x86_64, 1 is arm64. The wide copy keeps this
 *   function's existing ta == 0 or ta == 1 gate.
 * @param base_off i32 — byte offset added to each field offset. Outside
 *   0..4096 returns -1.
 * @return i32 — 0 when every field is stored, -1 on encode or shape failure.
 * PLATFORM: MACOS|DARWIN tip. The Windows seed
 * runtime_pipeline_abi.windows_link_stubs.c still leaves an ARRAY_LIT
 * wider than 16 on the scalar store. This gate does not.
 */
#[no_mangle]
export function win_emit_struct_lit_fields_into_parked_rbx(arena: *u8, elf_ctx: *u8, lit_ref: i32, ctx: *u8, ta: i32, base_off: i32): i32 {
  let nf: i32 = 0;
  let fi: i32 = 0;
  let iref: i32 = 0;
  let foff: i32 = 0;
  let fsz: i32 = 0;
  let store_off: i32 = 0;
  let iko: i32 = 0;
  let fty: i32 = 0;
  let wide: i32 = 0;
  let arr_bytes: i32 = 0;
  let vec_bytes: i32 = 0;
  let use_ptr: i32 = 0;
  let add_x19: u32 = 0;
  let splat_go: i32 = 0;
  let splat_rc: i32 = 0;
  let splat_slot: i32 = 0;
  let splat_elem: i32 = 0;
  let peel_ref: i32 = 0;
  let splat_ek: i32 = 0;
  let splat_tk: i32 = 0;
  let bind_rc: i32 = 0;
  let src_off: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let cell: u8[8];
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || lit_ref <= 0) {
    return 0 - 1;
  }
  if (base_off < 0 || base_off > 4096) {
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, 0);
    mod = glue_emit_module_from_ctx(ctx);
  }
  if (mod == (0 as *u8)) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
  }
  /* A let `let o: Outer = { ... }` may already have stamped the name.
   * If only the resolved type is set, copy that name so field lookup
   * can see Inner and the array element type. PLATFORM: MACOS|DARWIN. */
  fty = 0;
  unsafe {
    fty = pipeline_expr_resolved_type_ref(arena, lit_ref);
  }
  w636_sl_stamp_named(arena, lit_ref, fty);
  unsafe {
    nf = pipeline_expr_struct_lit_num_fields(arena, lit_ref);
  }
  if (nf < 0) {
    nf = 0;
  }
  if (nf > 64) {
    return 0 - 1;
  }
  fi = 0;
  while (fi < nf) {
    unsafe {
      iref = pipeline_expr_struct_lit_init_ref(arena, lit_ref, fi);
    }
    if (iref <= 0) {
      return 0 - 1;
    }
    foff = 0;
    if (mod != (0 as *u8)) {
      unsafe {
        foff = pipeline_expr_struct_lit_field_offset_at(arena, mod, lit_ref, fi);
      }
    }
    if (foff < 0) {
      foff = 0;
    }
    store_off = foff + base_off;
    if (store_off > 4096) {
      return 0 - 1;
    }
    unsafe {
      iko = pipeline_expr_kind_ord_at(arena, iref);
    }
    if (iko == 45) {
      /* Anonymous `{ inn: { xs: [ ... ] } }` has no type name, so the
       * inner field lookup misses and the array stride stays 4.
       * The parent field type is the named struct. Stamp that name
       * before the recursive store. PLATFORM: MACOS|DARWIN. */
      fty = 0;
      if (mod != (0 as *u8)) {
        unsafe {
          fty = pipeline_expr_struct_lit_field_type_ref_at(arena, mod, lit_ref, fi);
        }
      }
      w636_sl_stamp_named(arena, iref, fty);
      if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, iref, ctx, ta, store_off) != 0) {
        return 0 - 1;
      }
      fi = fi + 1;
      continue;
    }
    // Match bind `h` in `{ h: h }` has no slot. Copy the subject field.
    // A real local falls through (-99). PLATFORM: MACOS|DARWIN.
    if (iko == 3) {
      bind_rc = struct_lit_store_match_bind_field(arena, elf_ctx, iref, ctx, ta, mod, store_off);
      if (bind_rc == 0) {
        fi = fi + 1;
        continue;
      }
      if (bind_rc != (0 - 99)) {
        return 0 - 1;
      }
    }
    /* A declared local VAR of a TYPE_ARRAY field. The match-bind helper
     * above returns -99 because the name has a slot. Named-layout size
     * is 0 for kind 10, so the wide gate below never sees N*esz and the
     * scalar store writes 8 bytes of the address emit_expr left in x0.
     * `*p = { two: src }` of [2]Wrap therefore kept the zero init
     * (Darwin leftover 175). Lea the slot and copy through x19, the
     * same memcpy the match-bind aggregate uses. No slot, a non-array,
     * or a size outside 8..4096 falls through. glue_copy rejects sz < 8.
     * PLATFORM: MACOS|DARWIN. pop/push keeps the parked dest for the
     * next field. The mov is x19 = x1 after the arm64 pop. */
    if (iko == 3 && (ta == 0 || ta == 1) && mod != (0 as *u8)) {
      fty = 0;
      arr_bytes = 0;
      src_off = 0 - 1;
      unsafe {
        fty = pipeline_expr_struct_lit_field_type_ref_at(arena, mod, lit_ref, fi);
      }
      if (fty > 0) {
        unsafe {
          splat_tk = pipeline_type_kind_ord_at(arena, fty);
        }
        if (splat_tk == 10) {
          unsafe {
            arr_bytes = glue_fixed_array_total_bytes_c(arena, fty, 0);
          }
        }
      }
      if (arr_bytes >= 8 && arr_bytes <= 4096) {
        unsafe {
          src_off = glue_var_expr_stack_off_elf_c(arena, ctx, iref);
        }
      }
      if (src_off >= 0 && arr_bytes >= 8 && arr_bytes <= 4096) {
        if (store_off < 0 || store_off > 4095) {
          return 0 - 1;
        }
        add_x19 = (2432696947 as u32) | ((store_off as u32) * 1024);
        unsafe {
          pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2852193267 as u32));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          if (store_off > 0) {
            pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, add_x19));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
          pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, arr_bytes, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        }
        fi = fi + 1;
        continue;
      }
    }
    /*
     * INT_LIT, a kind-22 / kind-23 chain, an if (kind 25), or a
     * ternary (kind 27) into an integer vector wider than 8 bytes.
     * The scalar store below keeps at most 8 bytes, so lane 7 of
     * `H { v: 0 }` stayed unset, and `H { v: 3 }` of i32x8 stored one
     * str x of the scalar. Kind 13 reads the element kind. Kind 8
     * (i32x8 and the other integer spellings) has no element ref:
     * asm_type_is_simd_vector_spelling plus glue_vector_elem_is_f32_c
     * is the split vector let-init already uses. Vec4f stays out.
     * The same let-init a `let` uses fills a temp. Kind 25 and 27
     * already branch inside that let-init. Kinds 4..13 are the lane
     * binop that let already fills. Kind 26 is a block: the let-init
     * peels a transparent block and fills the inner value. A block
     * with lets returns -3. Kind 51 is not a binop here. The existing
     * x19 memcpy then copies that temp onto this field. A -3 decline
     * falls through to the scalar store. Kind 1 (FLOAT_LIT) enters only
     * when the f32 fill helper returns nonzero, so f32x8
     * `H { v: 1.0 }` uses this temp. Kind 22 of a float already
     * entered. Kind 24 and an f32 element kind do not enter.
     * ARRAY_LIT stays on the pointer copy below.
     * PLATFORM: MACOS|ARM64.
     */
    if (ta == 1) {
      fty = 0;
      if (mod != (0 as *u8)) {
        unsafe {
          fty = pipeline_expr_struct_lit_field_type_ref_at(arena, mod, lit_ref, fi);
        }
      }
      if (fty > 0) {
        unsafe {
          splat_tk = pipeline_type_kind_ord_at(arena, fty);
        }
        // splat_ek == 0 means the integer-vector gate. f32x8 also
        // lands here: the live classifier returns 0 for that name.
        // -1 means the scalar store below runs.
        splat_ek = 0 - 1;
        if (splat_tk == 13) {
          unsafe {
            splat_elem = pipeline_type_elem_ref_at(arena, fty);
          }
          if (splat_elem > 0) {
            unsafe {
              splat_ek = pipeline_type_kind_ord_at(arena, splat_elem);
            }
          }
        }
        if (splat_tk == 8) {
          unsafe {
            splat_elem = asm_type_is_simd_vector_spelling(arena, fty);
          }
          if (splat_elem != 0) {
            unsafe {
              splat_go = glue_vector_elem_is_f32_c(arena, fty);
            }
            if (splat_go == 0) {
              splat_ek = 0;
            }
          }
        }
        if (splat_ek == 0) {
              splat_go = 0;
              // A block with lets is not transparent. The vector
              // let-init returns -3, and the scalar store keeps at
              // most 8 bytes, so lane 7 of
              // `H { v: { let k; k + k } }` is not the sum. The
              // existing lane chain emits each block's lets and
              // returns the value expr. Nested blocks are that one
              // function. A binop value then takes the let-init
              // below. A VAR value takes the wide copy below. Width
              // 8 or less is not peeled. 128 stops only a chain that
              // does not end. rbx stays the parked field base: the
              // copy below restores it. PLATFORM: MACOS|ARM64.
              if (iko == 26) {
                vec_bytes = 0;
                unsafe {
                  vec_bytes = pipeline_asm_type_ref_byte_size_c(arena, fty);
                }
                if (vec_bytes > 8) {
                  unsafe {
                    peel_ref = pipeline_lane_operand_emit_let_block_chain(
                      arena, elf_ctx, iref, ctx, ta, 128);
                  }
                  if (peel_ref <= 0) {
                    return 0 - 1;
                  }
                  iref = peel_ref;
                  unsafe {
                    iko = pipeline_expr_kind_ord_at(arena, iref);
                  }
                }
              }
              if (iko == 0) {
                splat_go = 1;
              }
              if (iko == 22) {
                splat_go = 1;
              }
              if (iko == 23) {
                splat_go = 1;
              }
              if (iko == 25) {
                splat_go = 1;
              }
              if (iko == 27) {
                splat_go = 1;
              }
              // Kinds 4..13 are a lane binop. glue_is_vector_lane_scalar_binop_ko
              // is that set, and it also returns 1 for kind 51. Kind 51 is an
              // address: the let-init reads binop children and returns -1, so
              // it stays on the scalar store. Kind 26 is a block. The same
              // let-init peels a transparent block, then fills the inner
              // value. A wider block with lets was already replaced by
              // its value above, so this arm is only a narrow block.
              // Nested blocks are the lane chain, not another walker.
              // PLATFORM: MACOS|ARM64.
              if (iko == 26) {
                splat_go = 1;
              }
              if (iko != 51) {
                unsafe {
                  splat_elem = glue_is_vector_lane_scalar_binop_ko(iko);
                }
                if (splat_elem != 0) {
                  splat_go = 1;
                }
              }
              // FLOAT_LIT = 1. The integer set above does not include
              // it, so `H { v: 1.0 }` of f32x8 stored one 8-byte f64
              // word and lane 0 read as 0. Kind 22 of `-1.0` already
              // enters and the let-init converts it. f32x8 is the
              // kind-8 spelling whose live classifier returns 0, so
              // splat_ek is 0 here. The same fill helper a `let` uses
              // returns 1 only for that f32 target. An integer
              // spelling returns 0 and stays on the scalar store.
              // f32x4 and Vec4f never reach splat_ek == 0.
              // PLATFORM: MACOS|ARM64.
              if (iko == 1) {
                unsafe {
                  splat_elem = vector_let_init_array_lit_a64_vlet_f32_fill_lane(arena, fty);
                }
                if (splat_elem != 0) {
                  splat_go = 1;
                }
              }
              if (splat_go != 0) {
                vec_bytes = 0;
                unsafe {
                  vec_bytes = pipeline_asm_type_ref_byte_size_c(arena, fty);
                }
                if (vec_bytes > 8) {
                  if (ctx != (0 as *u8)) {
                    unsafe {
                      splat_slot = glue_simd_alloc_vector_temp_slot_c(arena, ctx, fty);
                    }
                    if (splat_slot < 0) {
                      return 0 - 1;
                    }
                    unsafe {
                      splat_rc = glue_emit_vector_type_let_init_elf_c(
                        arena, elf_ctx, iref, ctx, ta, splat_slot, fty);
                    }
                    if (splat_rc == 0) {
                      unsafe {
                        pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, splat_slot, ta));
                        if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
                        pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
                        if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
                        pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
                        if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
                        pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2852193267 as u32));
                        if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
                        if (store_off > 0) {
                          add_x19 = (2432696947 as u32) | ((store_off as u32) * 1024);
                          pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, add_x19));
                          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
                        }
                        pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, vec_bytes, ta));
                        if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
                      }
                      fi = fi + 1;
                      continue;
                    }
                    if (splat_rc != (0 - 3)) {
                      return 0 - 1;
                    }
                  }
                }
              }
            }
      }
    }
    unsafe {
      fsz = glue_struct_lit_field_store_sz(arena, lit_ref, fi);
    }
    if (fsz <= 0) {
      fi = fi + 1;
      continue;
    }
    if (iko == 46 && mod != (0 as *u8)) {
      fty = 0;
      unsafe {
        fty = pipeline_expr_struct_lit_field_type_ref_at(arena, mod, lit_ref, fi);
      }
      /* Anonymous `{ a: 5, b: 6 }` elements take a 4-byte stride.
       * Naming them from the array element type makes emit_expr use
       * the struct layout. PLATFORM: MACOS|DARWIN. */
      w636_sl_stamp_array_elems(arena, iref, fty);
      /* The array stride is the ARRAY_LIT resolved element type.
       * An unstamped lit falls back to 4 bytes, so the next struct
       * element overwrites the previous one's second field. The
       * field type is that array. PLATFORM: MACOS|DARWIN. */
      if (fty > 0) {
        unsafe {
          splat_tk = pipeline_type_kind_ord_at(arena, fty);
        }
        if (splat_tk == 10) {
          unsafe {
            pipeline_expr_set_resolved_type_ref(arena, iref, fty);
          }
        }
      }
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_emit_expr_elf_rec(arena, elf_ctx, iref, ctx, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) {
        return 0 - 1;
      }
    }
    if ((ta == 0 || ta == 1) && (iko == 3 || iko == 44 || iko == 46 || iko == 47 || iko == 48 || iko == 49)) {
      fty = 0;
      wide = 0;
      if (mod != (0 as *u8)) {
        unsafe {
          fty = pipeline_expr_struct_lit_field_type_ref_at(arena, mod, lit_ref, fi);
        }
      }
      if (fty > 0) {
        unsafe {
          wide = glue_type_named_layout_size_any_module_elf_c(arena, fty);
        }
      }
      // TYPE_ARRAY (kind 10) does not report its byte count through the
      // named-layout size, so [2]i32 and [8]i32 never entered the copy
      // below and the scalar store wrote the payload pointer. The
      // existing total-bytes helper is N times the element stride.
      // A result below 8 stays on the scalar store: the copy rejects it.
      // A named type that is not an array returns 0 and keeps `wide`.
      // PLATFORM: MACOS|DARWIN.
      arr_bytes = 0;
      if (iko == 46 && fty > 0) {
        unsafe {
          arr_bytes = glue_fixed_array_total_bytes_c(arena, fty, 0);
        }
        if (arr_bytes >= 8) {
          wide = arr_bytes;
        }
      }
      // TYPE_VECTOR (kind 13) is not a named layout and not TYPE_ARRAY.
      // named-layout returns 0 by contract (callers treat that as "not a
      // struct"). The fixed-array helper returns 0 unless kind is 10.
      // The byte-size helper is the live size authority: kind 13 is
      // lanes * element size, so Vec8i is 32 and Vec4f is 16. ARRAY_LIT
      // leaves the payload address in x0. A count of at least 8 takes
      // the existing pointer copy below. Below 8 stays on the scalar
      // store. Kind 8 spellings (i32x8) already set `wide` and are not
      // replaced. Do not pin "Vec8i". Do not change kind-13 align.
      // PLATFORM: MACOS|DARWIN — this gate. The size helper is SHARED.
      if (iko == 46 && fty > 0 && arr_bytes < 8) {
        vec_bytes = 0;
        unsafe {
          vec_bytes = pipeline_type_kind_ord_at(arena, fty);
        }
        if (vec_bytes == 13) {
          unsafe {
            vec_bytes = pipeline_asm_type_ref_byte_size_c(arena, fty);
          }
          if (vec_bytes >= 8) {
            wide = vec_bytes;
          }
        }
      }
      // Named-layout size is 0 for a SIMD spelling that is not a user
      // struct, so a Vec4f VAR used to miss the 9..16 pair spill and
      // the scalar store kept one w. The byte-size helper is the same
      // width the assign path copies (Vec4f is 16). Only that window
      // is filled here: above 16 is not an x0:x1 pair, and the integer
      // literal of i32x8 already took the let-init above. ARRAY_LIT
      // keeps the pointer copy. PLATFORM: MACOS|DARWIN.
      if (wide < 8 && fty > 0 && iko != 46) {
        vec_bytes = 0;
        unsafe {
          vec_bytes = pipeline_type_kind_ord_at(arena, fty);
        }
        splat_go = 0;
        if (vec_bytes == 13) {
          splat_go = 1;
        }
        if (vec_bytes == 8) {
          unsafe {
            splat_elem = asm_type_is_simd_vector_spelling(arena, fty);
          }
          if (splat_elem != 0) {
            splat_go = 1;
          }
        }
        if (splat_go != 0) {
          unsafe {
            vec_bytes = pipeline_asm_type_ref_byte_size_c(arena, fty);
          }
          if (vec_bytes > 8 && vec_bytes <= 16) {
            wide = vec_bytes;
          }
        }
      }
      if (wide > 8 || (iko == 46 && arr_bytes >= 8)) {
        if (store_off < 0 || store_off > 4095) {
          return 0 - 1;
        }
        add_x19 = (2432696947 as u32) | ((store_off as u32) * 1024);
        // PLATFORM: MACOS|DARWIN. VAR, FIELD, INDEX, CALL, and METHOD of
        // 9..16 bytes leave the value in x0:x1 and take the pair spill
        // below. A layout wider than 16 leaves the source address in x0.
        // ARRAY_LIT (46) always leaves the payload address in x0. Once
        // `wide` is the array's byte count, that address copy covers
        // 8 bytes and widths above 16 as well as the 9..16 window.
        use_ptr = 0;
        if (wide > 16) {
          if (iko != 46) {
            use_ptr = 1;
          }
        } else {
          if (iko == 46) {
            use_ptr = 1;
          }
        }
        if (iko == 46 && arr_bytes >= 8) {
          use_ptr = 1;
        }
        // A TYPE_VECTOR field is not TYPE_ARRAY, so arr_bytes stays 0 and
        // the wide>16 arm leaves use_ptr clear when the init is ARRAY_LIT.
        // ARRAY_LIT still leaves the payload address in x0. Copying `wide`
        // bytes is the same pointer copy as [8]i32. Measured sizes: kind 8
        // i32x8 / u32x8 are 32, i32x16 is 64; kind 13 Vec8i is 32 via the
        // byte-size helper above. When arr_bytes or that helper already
        // replaced `wide`, this line is the same flag. A width below 8
        // never reaches here.
        // PLATFORM: MACOS|DARWIN.
        if (iko == 46 && wide >= 8) {
          use_ptr = 1;
        }
        if (use_ptr != 0) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2852193267 as u32));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            if (store_off > 0) {
              pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, add_x19));
              if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            }
            pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, wide, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
          fi = fi + 1;
          continue;
        }
        if (iko != 46) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2847868896 as u32));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 4181724147 as u32));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            if (store_off > 0) {
              pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, add_x19));
              if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            }
            pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2432697312 as u32));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, wide, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
            pipe_store_i32_le(&cell[0], 0, backend_enc_append_u32_le_c(elf_ctx, 2432713727 as u32));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
          fi = fi + 1;
          continue;
        }
      }
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    }
    if (fsz > 8) {
      fsz = 8;
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_store_rax_to_rbx_offset_arch(elf_ctx, store_off, fsz, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    }
    fi = fi + 1;
  }
  return 0;
}

/**
 * STRUCT_LIT field store into a stack home or dest-in-rbx (-3).
 * Twin of windows_link_stubs leftover; tip first-wins over archive_leaf.
 */
#[no_mangle]
export function pipeline_asm_emit_struct_lit_fields_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  let dest_in_rbx: i32 = 0;
  let home: i32 = 0;
  let nbytes: i32 = 0;
  let reserve: i32 = 0;
  let mod: *u8 = 0 as *u8;
  let cell: u8[8];
  let nf2: i32 = 0;
  let fi2: i32 = 0;
  let foff2: i32 = 0;
  let fsz2: i32 = 0;
  let end2: i32 = 0;
  let ko: i32 = 0;
  /* Module-level array/struct init may pass a null ctx; fall back via
   * pipeline_asm_emit_module_ref_c like win_emit. Do not require ctx. */
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || expr_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, expr_ref);
  }
  if (ko != 45) {
    return 0 - 1;
  }
  if (stack_slot_off == 0 - 3) {
    dest_in_rbx = 1;
  } else {
    dest_in_rbx = 0;
  }
  home = stack_slot_off;
  unsafe {
    mod = glue_emit_module_from_ctx(ctx);
  }
  if (mod == (0 as *u8)) {
    unsafe {
      mod = pipeline_asm_emit_module_ref_c();
    }
  }
  nbytes = 0;
  if (mod != (0 as *u8)) {
    unsafe {
      nbytes = pipeline_expr_struct_lit_value_bytes(arena, mod, expr_ref);
    }
  }
  if (nbytes <= 0) {
    nbytes = 8;
  }
  if (nbytes > 4096) {
    return 0 - 1;
  }
  if (dest_in_rbx == 0) {
    if (home < 0) {
      reserve = (nbytes + 7) & (0 - 8);
      if (reserve < 8) {
        reserve = 8;
      }
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipe_asm_ctx_off_next_offset());
        home = pipe_load_i32_le(ctx, w254_sl_cell_i32(&cell[0]));
      }
      if ((home & 7) != 0) {
        home = (home + 7) & (0 - 8);
      }
      if (ta == 1) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, pipe_asm_ctx_off_next_offset());
          pipe_store_i32_le(ctx, w254_sl_cell_i32(&cell[0]), home + reserve);
        }
      } else {
        home = home + reserve;
        unsafe {
          pipe_store_i32_le(&cell[0], 0, pipe_asm_ctx_off_next_offset());
          pipe_store_i32_le(ctx, w254_sl_cell_i32(&cell[0]), home);
        }
      }
    }
    if (home < 0) {
      return 0 - 1;
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      pipe_store_i32_le(&cell[0], 0, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
      if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
    }
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_push_rbx_arch(elf_ctx, ta));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
  }
  if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, expr_ref, ctx, ta, 0) != 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
    }
    return 0 - 1;
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_pop_rbx_arch(elf_ctx, ta));
    if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
  }
  if (dest_in_rbx == 0) {
    unsafe {
      nf2 = pipeline_expr_struct_lit_num_fields(arena, expr_ref);
    }
    if (nf2 < 0) {
      nf2 = 0;
    }
    fi2 = 0;
    while (fi2 < nf2) {
      if (fi2 >= 64) {
        break;
      }
      foff2 = 0;
      if (mod != (0 as *u8)) {
        unsafe {
          foff2 = pipeline_expr_struct_lit_field_offset_at(arena, mod, expr_ref, fi2);
        }
      }
      if (foff2 < 0) {
        foff2 = 0;
      }
      unsafe {
        fsz2 = glue_struct_lit_field_store_sz(arena, expr_ref, fi2);
      }
      if (fsz2 <= 0) {
        fi2 = fi2 + 1;
        continue;
      }
      if (fsz2 > 8) {
        fsz2 = 8;
      }
      end2 = foff2 + fsz2;
      if (end2 > nbytes) {
        nbytes = end2;
      }
      fi2 = fi2 + 1;
    }
    if (nbytes <= 8) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta));
        if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
      }
    } else {
      if (nbytes <= 16) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, backend_enc_load_rbp_to_rax_arch(elf_ctx, home, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        }
        if (ta == 1) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, backend_enc_load_rbp_to_rbx_arch(elf_ctx, home + 8, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
        } else {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, backend_enc_load_rbp_to_rdx_arch(elf_ctx, home - 8, ta));
            if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
          }
        }
      } else {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, backend_enc_lea_rbp_to_rax_arch(elf_ctx, home, ta));
          if (w254_sl_cell_i32(&cell[0]) != 0) { return 0 - 1; }
        }
      }
    }
  }
  return 0;
}

/**
 * EXPR_STRUCT_LIT public entry: temp slot stack_slot_off=-1.
 */
#[no_mangle]
export function pipeline_asm_emit_struct_lit_elf_c(
  arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32
): i32 {
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, expr_ref, ctx, ta, 0 - 1);
}

/**
 * STRUCT_LIT let-init: forward to fields with the given stack home.
 * Twin of windows_link_stubs; tip first-wins over archive_leaf.
 */
#[no_mangle]
export function pipeline_asm_emit_struct_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, stack_slot_off: i32
): i32 {
  let ko: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || init_ref <= 0) {
    return 0 - 1;
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (ko != 45) {
    return 0 - 1;
  }
  return pipeline_asm_emit_struct_lit_fields_elf_c(arena, elf_ctx, init_ref, ctx, ta, stack_slot_off);
}
