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

function w254_sl_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
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
 * 8-byte store. A named SIMD field is not a TYPE_ARRAY, so that helper
 * returns 0 and the layout size stays lanes times the element width.
 * When that size is at least 8, ARRAY_LIT uses the same address copy.
 * i32x8 is TYPE_NAMED (kind 8) and is 32 bytes. Vec8i is TYPE_VECTOR
 * (kind 13): named-layout returns 0 by contract, and the array helper
 * returns 0 unless kind is 10. pipeline_asm_type_ref_byte_size_c is
 * lanes times the element size (Vec8i is 32). That count replaces
 * `wide`, and the same address copy stores the payload. Kind 13
 * alignment is unchanged. Do not pin a vector name. A width below 8
 * stays on the scalar store: the copy rejects it. Layouts wider than
 * 16 for the other kinds already copy from the address in x0.
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
      if (win_emit_struct_lit_fields_into_parked_rbx(arena, elf_ctx, iref, ctx, ta, store_off) != 0) {
        return 0 - 1;
      }
      fi = fi + 1;
      continue;
    }
    unsafe {
      fsz = glue_struct_lit_field_store_sz(arena, lit_ref, fi);
    }
    if (fsz <= 0) {
      fi = fi + 1;
      continue;
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
