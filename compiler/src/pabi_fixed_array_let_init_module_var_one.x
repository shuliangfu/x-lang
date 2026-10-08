// One strong glue_emit_fixed_array_type_let_init_elf_c.
// Body is seeds/fixed_array_let_init_module_var_override.c.
// runtime_pipeline_abi.x has the same name and a different body: it
// emits dest-in-rbx ARRAY_LIT element loops. Do not fold this TU into
// that function. The two statics in the C stay file-local helpers in
// this object. They are not a second link winner. Do not gcc the seed
// on the Windows or Linux path. Darwin still compiles the C.
// PLATFORM: SHARED body. Linux and Windows relinks consume this file.

export extern function glue_type_is_fixed_array(arena: *u8, type_ref: i32): i32;
export extern function glue_struct_lit_store_fixed_array_field_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  sret_direct: i32, base_off: i32, foff: i32, fty: i32
): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_asm_emit_lvalue_eff_addr_elf_c(
  arena: *u8, elf_ctx: *u8, lval: i32, ctx: *u8, ta: i32
): i32;
export extern function glue_fixed_array_total_bytes_c(arena: *u8, ty_ref: i32, depth: i32): i32;
export extern function pipeline_type_array_size_at(arena: *u8, ty_ref: i32): i32;
export extern function glue_array_lit_force_esz_from_elem_type_c(arena: *u8, et: i32): i32;
export extern function pipeline_type_elem_ref_at(arena: *u8, ty_ref: i32): i32;
export extern function glue_index_elem_byte_sz_from_type_ref_c(arena: *u8, tr: i32): i32;
export extern function backend_enc_store_rax_to_rbp_arch(elf: *u8, off: i32, ta: i32): i32;
export extern function backend_enc_lea_rbp_to_rax_arch(elf: *u8, off: i32, ta: i32): i32;
export extern function glue_emit_bulk_mem_copy_spills_elf_c(
  elf: *u8, src_spill: i32, dst_spill: i32, nbytes: i32, ta: i32
): i32;
export extern function glue_copy_large_struct_from_rax_ptr_elf_c(
  elf_ctx: *u8, slot_off: i32, sz: i32, ta: i32
): i32;

/**
 * Read the little-endian i32 at byte offset off.
 * @param base *u8 — object; caller already rejected null
 * @param off i32 — byte offset; AsmFuncCtx.next_offset is 4
 * @return i32 — signed value of the four bytes
 * Same bytes as a C int32_t load. Offset 4 is the emit next_offset.
 * PLATFORM: SHARED — little-endian hosts.
 */
function fa_modvar_load_i32(base: *u8, off: i32): i32 {
  let b0: u32 = 0;
  let b1: u32 = 0;
  let b2: u32 = 0;
  let b3: u32 = 0;
  let u: u32 = 0;
  unsafe {
    b0 = base[off] as u32;
    b1 = base[off + 1] as u32;
    b2 = base[off + 2] as u32;
    b3 = base[off + 3] as u32;
  }
  u = b0 + b1 * 256 + b2 * 65536 + b3 * 16777216;
  return u as i32;
}

/**
 * Write a little-endian i32 at byte offset off.
 * @param base *u8 — object; caller already rejected null
 * @param off i32 — byte offset; 4 updates AsmFuncCtx.next_offset
 * @param v i32 — value to store
 * @return void
 * Four byte stores match a C int32_t store on a little-endian host.
 * PLATFORM: SHARED — little-endian hosts.
 */
function fa_modvar_store_i32(base: *u8, off: i32, v: i32): void {
  let u: u32 = v as u32;
  unsafe {
    base[off] = (u & 255) as u8;
    base[off + 1] = ((u / 256) & 255) as u8;
    base[off + 2] = ((u / 65536) & 255) as u8;
    base[off + 3] = ((u / 16777216) & 255) as u8;
  }
}

/**
 * Byte count of a fixed array, with the Cap residual stride fallback.
 * @param arena *u8 — AST arena; caller already rejected null
 * @param type_ref i32 — fixed-array type ref
 * @return i32 — total bytes, which may be <= 0 when the fallback is empty
 * glue_fixed_array_total_bytes_c wins when it is positive. Otherwise
 * count * stride, and the stride is force_esz, then index elem size,
 * then 4. The index-size call receives the array type, not the element.
 * PLATFORM: SHARED.
 */
function fa_modvar_nbytes(arena: *u8, type_ref: i32): i32 {
  let nbytes: i32 = 0;
  let n_arr: i32 = 0;
  let elem_tr: i32 = 0;
  let esz: i32 = 0;
  unsafe {
    nbytes = glue_fixed_array_total_bytes_c(arena, type_ref, 0);
  }
  if (nbytes > 0) {
    return nbytes;
  }
  unsafe {
    n_arr = pipeline_type_array_size_at(arena, type_ref);
    elem_tr = pipeline_type_elem_ref_at(arena, type_ref);
    esz = glue_array_lit_force_esz_from_elem_type_c(arena, elem_tr);
  }
  if (esz <= 0) {
    unsafe {
      esz = glue_index_elem_byte_sz_from_type_ref_c(arena, type_ref);
    }
  }
  if (esz <= 0) {
    esz = 4;
  }
  return n_arr * esz;
}

/**
 * Copy a module (non-local) fixed-array VAR into a frame slot.
 * @param arena *u8 — AST arena; null returns -1
 * @param elf_ctx *u8 — encoder context; null returns -1
 * @param init_ref i32 — VAR expr ref; <= 0 returns -1
 * @param ctx *u8 — AsmFuncCtx; next_offset lives at byte 4
 * @param ta i32 — target arch, forwarded to the encoder
 * @param type_ref i32 — fixed-array type; <= 0 returns -1
 * @param stack_slot_off i32 — destination frame slot; < 0 returns -1
 * @return i32 — 0 when the bulk copy returns 0, -1 on a rejected size
 *   or an encoder failure, otherwise the bulk copy's own code
 * Reserves two 16-byte spills, stores the source effective address and
 * the slot address, then copies nbytes. nbytes outside 1..4096 returns
 * -1. gcc -O2 deletes the C source's signed next_offset+32 wrap test,
 * so this body does not emit that test either. A wrapped next_offset
 * still publishes the two spills, matching that object.
 * PLATFORM: SHARED freestanding.
 */
function fa_modvar_copy_nonlocal(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  type_ref: i32, stack_slot_off: i32
): i32 {
  let nbytes: i32 = 0;
  let next_off: i32 = 0;
  let src_spill: i32 = 0;
  let dst_spill: i32 = 0;
  let rc: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)
      || init_ref <= 0 || type_ref <= 0 || stack_slot_off < 0) {
    return 0 - 1;
  }
  nbytes = fa_modvar_nbytes(arena, type_ref);
  if (nbytes <= 0 || nbytes > 4096) {
    return 0 - 1;
  }
  // AsmFuncCtx.next_offset is the i32 at byte 4. The C source tests
  // next_off+32 < next_off, and gcc -O2 drops that test. Do not put it
  // back: the linked object wraps and still copies.
  next_off = fa_modvar_load_i32(ctx, 4);
  next_off = next_off + 16;
  src_spill = next_off;
  next_off = next_off + 16;
  dst_spill = next_off;
  fa_modvar_store_i32(ctx, 4, next_off);
  unsafe {
    rc = pipeline_asm_emit_lvalue_eff_addr_elf_c(arena, elf_ctx, init_ref, ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, src_spill, ta);
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
    rc = backend_enc_store_rax_to_rbp_arch(elf_ctx, dst_spill, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_emit_bulk_mem_copy_spills_elf_c(elf_ctx, src_spill, dst_spill, nbytes, ta);
  }
  return rc;
}

/**
 * Copy a local fixed-array VAR through the pointer already in rbx.
 * @param arena *u8 — AST arena
 * @param elf_ctx *u8 — encoder context
 * @param init_ref i32 — init expr; only kind 3 (VAR) is this shape
 * @param ctx *u8 — AsmFuncCtx passed to the stack-off query
 * @param ta i32 — target arch; only 0 and 1 proceed
 * @param type_ref i32 — fixed-array type used for the byte count
 * @return i32 — 0 copied, -1 encoder failure, -2 not this shape
 * stack_slot_off -3 means the caller already pointed rbx at the
 * destination. A negative source slot, a size outside 8..4096, or a
 * non-VAR returns -2 so the caller can fall through. glue_copy is
 * called with slot -3.
 * PLATFORM: SHARED — SysV and AAPCS64 dest-in-rbx.
 */
function fa_modvar_copy_local(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32, type_ref: i32
): i32 {
  let src_off: i32 = 0;
  let nbytes: i32 = 0;
  let rc: i32 = 0;
  if (ta != 0 && ta != 1) {
    return 0 - 2;
  }
  unsafe {
    rc = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (rc != 3) {
    return 0 - 2;
  }
  unsafe {
    src_off = glue_var_expr_stack_off_elf_c(arena, ctx, init_ref);
  }
  if (src_off < 0) {
    return 0 - 2;
  }
  nbytes = fa_modvar_nbytes(arena, type_ref);
  if (nbytes < 8 || nbytes > 4096) {
    return 0 - 2;
  }
  unsafe {
    rc = backend_enc_lea_rbp_to_rax_arch(elf_ctx, src_off, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  unsafe {
    rc = glue_copy_large_struct_from_rax_ptr_elf_c(elf_ctx, 0 - 3, nbytes, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Fixed-array let-init: Cap residual store, then a module-VAR fallback.
 * @param arena *u8 — AST arena; null returns -2
 * @param elf_ctx *u8 — encoder context; null returns -2
 * @param init_ref i32 — initializer expr; <= 0 returns -2
 * @param ctx *u8 — AsmFuncCtx; null returns -2
 * @param ta i32 — target arch forwarded to the helpers
 * @param type_ref i32 — destination type; not a fixed array returns -2
 * @param stack_slot_off i32 — frame slot, or -3 when rbx already holds dest
 * @return i32 — 0 ok, -1 hard fail, -2 not a fixed array or not this shape
 * -3 tries the local VAR copy first. Any result other than -2 is final.
 * The struct-lit store then runs. 0 and -1 return immediately. -2 with
 * a non-local VAR and a real frame slot copies through two spills.
 * Any other store code is returned unchanged when that VAR shape misses.
 * PLATFORM: SHARED — one strong T. Linux and Windows link this ahead of the egg.
 */
#[no_mangle]
export function glue_emit_fixed_array_type_let_init_elf_c(
  arena: *u8, elf_ctx: *u8, init_ref: i32, ctx: *u8, ta: i32,
  type_ref: i32, stack_slot_off: i32
): i32 {
  let st: i32 = 0;
  let kind: i32 = 0;
  let voff: i32 = 0;
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8)
      || init_ref <= 0 || type_ref <= 0) {
    return 0 - 2;
  }
  unsafe {
    st = glue_type_is_fixed_array(arena, type_ref);
  }
  if (st == 0) {
    return 0 - 2;
  }
  // -3 is dest-in-rbx, not a frame magnitude. A local VAR copies
  // through rbx. -2 falls through to the store.
  if (stack_slot_off == (0 - 3)) {
    st = fa_modvar_copy_local(arena, elf_ctx, init_ref, ctx, ta, type_ref);
    if (st != (0 - 2)) {
      return st;
    }
  }
  unsafe {
    st = glue_struct_lit_store_fixed_array_field_elf_c(
        arena, elf_ctx, init_ref, ctx, ta, 0, stack_slot_off, 0, type_ref);
  }
  if (st == 0 || st == (0 - 1)) {
    return st;
  }
  // st == -2 is the module VAR with no stack home. Other codes still
  // try that shape and otherwise return st unchanged.
  unsafe {
    kind = pipeline_expr_kind_ord_at(arena, init_ref);
  }
  if (kind == 3) {
    unsafe {
      voff = glue_var_expr_stack_off_elf_c(arena, ctx, init_ref);
    }
    if (voff < 0 && stack_slot_off >= 0) {
      st = fa_modvar_copy_nonlocal(
          arena, elf_ctx, init_ref, ctx, ta, type_ref, stack_slot_off);
      if (st == 0) {
        return 0;
      }
      return 0 - 1;
    }
  }
  return st;
}
