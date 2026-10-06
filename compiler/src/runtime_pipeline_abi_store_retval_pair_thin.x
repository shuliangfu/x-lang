// Windows link body of glue_store_retval_pair_to_rbp_elf_c.
// The live Windows egg defines that name twice. demote-all-dual keeps the
// cap-band copy, which copies a value wider than 16 bytes only for
// CALL (48), METHOD (49), and INDEX (47). The earlier copy is left static
// and compares only 48 and 49. The tip function in runtime_pipeline_abi.x
// also copies STRUCT_LIT (45), FIELD (44), and VAR (3). This file is that
// tip body, routed through pipe cells because the product drops a direct
// "name = extern(...)" store. ARRAY_LIT (46) stays out, matching the tip.
// No integer division or remainder, so the product divisor check is not
// on this path. Do not set XLANG_PREFER_ASM_O for this TU.
// Linux and Darwin are not switched in this commit. Do not link the full
// asm_expr thin from here.
// PLATFORM: WINDOWS link. The control flow matches the SHARED tip function.

export extern function glue_type_size_simple(m: *u8, a: *u8, ty_ref: i32, depth: i32): i32;
export extern function glue_sysv_dual_gp_byte_size_c(arena: *u8, ty_ref: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32): i32;
export extern function pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena: *u8, call_expr_ref: i32): i32;
export extern function pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx: *u8, ta: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function pipeline_type_kind_ord_at(arena: *u8, ref: i32): i32;
export extern function glue_slice_dual_gp_length_off_c(data_home: i32, ta: i32): i32;
export extern function backend_enc_store_rdx_to_rbp_arch(elf_ctx: *u8, offset: i32, ta: i32): i32;
export extern function glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(arena: *u8, elf_ctx: *u8, ctx: *u8, ta: i32, home: i32, ty_ref: i32, use_frame: i32): i32;
export extern function pipe_load_i32_le(p: *u8, off: i32): i32;
export extern function pipe_store_i32_le(p: *u8, off: i32, v: i32): void;

/**
 * Load one i32 that pipe_store_i32_le just wrote at offset 0.
 * The name is unique to this object. The helpers thin already emits
 * w495_cell_i32 as its own strong T, so a second object must not reuse it.
 * @param base *u8 — 8-byte cell; the i32 is at offset 0. Null is not used.
 * @return i32 — the stored value
 * PLATFORM: WINDOWS. Not an egg symbol. Leave it strong.
 */
function w2060_store_pair_cell_i32(base: *u8): i32 {
  unsafe {
    return pipe_load_i32_le(base, 0);
  }
}

/**
 * Store a call, method, index, struct literal, var, or field result into a
 * let slot. The low half goes through rax. A 9 to 16 byte value also stores
 * rdx. A value wider than 16 bytes is copied from the address in rax when
 * the init kind is 48, 49, 47, 45, 44, or 3. TYPE_SLICE (11) then stores the
 * length half and, for kind 48 or 49, runs the frame deep copy.
 * Kind 3 is safe only while the var loader leaves an address for a payload
 * wider than 16 bytes. Kind 44 is safe only while the field emitter leaves
 * the field address in that same case. A qword in rax must not take the
 * copy branch. ARRAY_LIT (46) is not in the set.
 * Every extern result is stored into the pipe cell and loaded back. A direct
 * assignment of an extern call is dropped by the product. The length offset
 * is loaded before the rdx store so the two calls are not nested.
 * The copy result is returned from the cell, not from inside the store.
 * @param m *u8 — module. Null skips the 9 to 16 byte rdx half after the slice test.
 * @param arena *u8 — AST arena. Null skips the widen, the kind tests, and the slice test.
 * @param elf_ctx *u8 — emit context. Null returns -1.
 * @param ty_ref i32 — let type. Zero stores rax only.
 * @param slot_off i32 — rbp-relative home of the low half.
 * @param ta i32 — 0 is x86_64 (second half at slot_off minus 8). 1 is arm64
 *   (second half at slot_off plus 8).
 * @param init_ref i32 — init expr. Zero skips the wide copy, the struct16
 *   deref, and the slice deep copy.
 * @param ctx *u8 — function context. Null skips the slice deep copy.
 * @return i32 — 0 on success or when there is nothing to store. -1 when the
 *   context is null or an encoder returns nonzero. The wide-copy helper's
 *   own return is passed through.
 * PLATFORM: WINDOWS link of the SHARED tip body. Linux and Darwin keep the
 * egg body in this commit. Keep this kind set identical to
 * glue_store_retval_pair_to_rbp_elf_c in runtime_pipeline_abi.x.
 */
#[no_mangle]
export function glue_store_retval_pair_to_rbp_elf_c(
    m: *u8, arena: *u8, elf_ctx: *u8, ty_ref: i32, slot_off: i32, ta: i32, init_ref: i32, ctx: *u8): i32 {
  let sz: i32 = 0;
  let nsz: i32 = 0;
  let ko: i32 = 0;
  let tk: i32 = 0;
  let half2: i32 = 0;
  let rc: i32 = 0;
  let cell: u8[8];
  if (elf_ctx == (0 as *u8)) {
    return 0 - 1;
  }
  // Size first. A named import can report 4 from the simple sizer and a
  // larger dual-GP size. Take the larger one only while the simple size is
  // still at most 16. The wide-copy test stays the frozen greater-than-16 gate.
  unsafe {
    pipe_store_i32_le(&cell[0], 0, glue_type_size_simple(m, arena, ty_ref, 0));
  }
  sz = w2060_store_pair_cell_i32(&cell[0]);
  if (sz <= 16 && arena != (0 as *u8) && ty_ref > 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, glue_sysv_dual_gp_byte_size_c(arena, ty_ref));
    }
    nsz = w2060_store_pair_cell_i32(&cell[0]);
    if (nsz > sz) {
      sz = nsz;
    }
  }
  // Wider than 16 bytes: CALL 48, METHOD 49, INDEX 47, STRUCT_LIT 45,
  // FIELD 44, VAR 3. Those emitters leave an address in rax. Storing the
  // pointer would keep 8 bytes and drop the payload.
  if (sz > 16 && init_ref > 0 && arena != (0 as *u8)) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, init_ref));
    }
    ko = w2060_store_pair_cell_i32(&cell[0]);
    if (ko == 48 || ko == 49 || ko == 47 || ko == 45 || ko == 44 || ko == 3) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, slot_off, sz, ta));
      }
      return w2060_store_pair_cell_i32(&cell[0]);
    }
  }
  // 9 to 16 byte call that returns a struct through a pointer in rax.
  if (sz > 8 && sz <= 16 && init_ref > 0 && arena != (0 as *u8)) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_asm_call_struct16_ret_needs_rax_deref_c(arena, init_ref));
    }
    rc = w2060_store_pair_cell_i32(&cell[0]);
    if (rc != 0) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, pipeline_asm_deref_struct16_rax_ptr_elf_c(elf_ctx, ta));
      }
      rc = w2060_store_pair_cell_i32(&cell[0]);
      if (rc != 0) {
        return 0 - 1;
      }
    }
  }
  unsafe {
    pipe_store_i32_le(&cell[0], 0, backend_enc_store_rax_to_rbp_arch(elf_ctx, slot_off, ta));
  }
  rc = w2060_store_pair_cell_i32(&cell[0]);
  if (rc != 0) {
    return 0 - 1;
  }
  // TYPE_SLICE is 11. Store the length half, then deep-copy a call or method.
  if (arena != (0 as *u8) && ty_ref > 0) {
    unsafe {
      pipe_store_i32_le(&cell[0], 0, pipeline_type_kind_ord_at(arena, ty_ref));
    }
    tk = w2060_store_pair_cell_i32(&cell[0]);
    if (tk == 11) {
      unsafe {
        pipe_store_i32_le(&cell[0], 0, glue_slice_dual_gp_length_off_c(slot_off, ta));
      }
      half2 = w2060_store_pair_cell_i32(&cell[0]);
      unsafe {
        pipe_store_i32_le(&cell[0], 0, backend_enc_store_rdx_to_rbp_arch(elf_ctx, half2, ta));
      }
      rc = w2060_store_pair_cell_i32(&cell[0]);
      if (rc != 0) {
        return 0 - 1;
      }
      if (ctx != (0 as *u8) && init_ref > 0) {
        unsafe {
          pipe_store_i32_le(&cell[0], 0, pipeline_expr_kind_ord_at(arena, init_ref));
        }
        ko = w2060_store_pair_cell_i32(&cell[0]);
        if (ko == 48 || ko == 49) {
          unsafe {
            pipe_store_i32_le(&cell[0], 0, glue_slice_let_reent_deep_copy_after_dual_gp_elf_c(
                arena, elf_ctx, ctx, ta, slot_off, ty_ref, 1));
          }
          rc = w2060_store_pair_cell_i32(&cell[0]);
          if (rc != 0) {
            return 0 - 1;
          }
        }
      }
      return 0;
    }
  }
  if (m == (0 as *u8) || arena == (0 as *u8) || ty_ref <= 0) {
    return 0;
  }
  if (sz > 8 && sz <= 16) {
    // x86_64 second half sits 8 bytes below the low home. arm64 sits 8 above.
    if (ta == 1) {
      half2 = slot_off + 8;
    } else {
      half2 = slot_off - 8;
    }
    unsafe {
      pipe_store_i32_le(&cell[0], 0, backend_enc_store_rdx_to_rbp_arch(elf_ctx, half2, ta));
    }
    rc = w2060_store_pair_cell_i32(&cell[0]);
    if (rc != 0) {
      return 0 - 1;
    }
  }
  return 0;
}
