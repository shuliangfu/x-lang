// File-level INDEX base address.
// The gcc body of glue_try_index_var_or_field_base_to_rbx_elf_c returns -2
// when glue_var_expr_stack_off_elf_c is negative, so `g[i] = v` pushes the
// value and never stores it. Module-level arrays live in an Lxml COMMON.
// pipeline_asm_modlet_load_to_rax_elf_c already emits that address for an
// array cell. Locals, fields, and every other base still call the renamed
// gcc body.
// PLATFORM: SHARED — x86_64 and ARM64 both go through the modlet lea.
// Do not PREFER this into runtime_pipeline_abi.o.

export extern function glue_try_index_var_or_field_base_to_rbx_elf_rest(arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipeline_expr_kind_ord_at(arena: *u8, expr_ref: i32): i32;
export extern function glue_var_expr_stack_off_elf_c(arena: *u8, ctx: *u8, var_expr_ref: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx: *u8, name: *u8, name_len: i32, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;

/**
 * Put the INDEX base address in rbx.
 * A stack local (offset >= 0), a field, or any non-VAR base is handled by
 * the previous body. A module-level VAR (offset < 0) loads the modlet
 * address into rax and moves it to rbx. Array modlets stay as the address
 * (pipeline_asm_modlet_load_to_rax_elf_c does not load the first qword).
 * @param arena *u8 — AST arena; null is forwarded
 * @param elf_ctx *u8 — code buffer; null is forwarded
 * @param base_ref i32 — INDEX base expression; <= 0 is forwarded
 * @param ctx *u8 — asm function context; null is forwarded
 * @param ta i32 — 0 x86_64, 1 arm64
 * @return i32 — 0 when rbx holds the address, -1 on an encoder error, -2 when this base is not handled
 * PLATFORM: SHARED
 */
#[no_mangle]
export function glue_try_index_var_or_field_base_to_rbx_elf_c(arena: *u8, elf_ctx: *u8, base_ref: i32, ctx: *u8, ta: i32): i32 {
  let ko: i32 = 0;
  let off: i32 = 0;
  let nlen: i32 = 0;
  let rc: i32 = 0;
  let name: u8[256] = [];
  if (arena == (0 as *u8) || elf_ctx == (0 as *u8) || ctx == (0 as *u8) || base_ref <= 0) {
    unsafe {
      return glue_try_index_var_or_field_base_to_rbx_elf_rest(arena, elf_ctx, base_ref, ctx, ta);
    }
  }
  unsafe {
    ko = pipeline_expr_kind_ord_at(arena, base_ref);
  }
  // EXPR_VAR == 3. Field, deref, and nested index stay in the previous body.
  if (ko != 3) {
    unsafe {
      return glue_try_index_var_or_field_base_to_rbx_elf_rest(arena, elf_ctx, base_ref, ctx, ta);
    }
  }
  unsafe {
    off = glue_var_expr_stack_off_elf_c(arena, ctx, base_ref);
  }
  if (off >= 0) {
    unsafe {
      return glue_try_index_var_or_field_base_to_rbx_elf_rest(arena, elf_ctx, base_ref, ctx, ta);
    }
  }
  unsafe {
    nlen = pipeline_expr_var_name_len(arena, base_ref);
  }
  if (nlen <= 0 || nlen > 255) {
    return 0 - 2;
  }
  unsafe {
    pipeline_expr_var_name_into(arena, base_ref, &name[0]);
    rc = pipeline_asm_modlet_load_to_rax_elf_c(elf_ctx, &name[0], nlen, ta);
  }
  if (rc != 0) {
    return 0 - 2;
  }
  unsafe {
    rc = backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  return 0;
}
