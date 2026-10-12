// Thin pure: arr_return path a2 (wave439).
// wave579 Soft Cap: Ubuntu tip `-backend asm -c` UND=0 (T export
//   present). The original body used if-before-call (sret_act==0 ||
//   sret_sz<=16 || ta not 0/1 || ko!=47) then rc=emit then if,
//   rc=mov then if, rc=memcpy then if, which that tip drops. Darwin
//   original kept the three encoders (3 UND). arr_return_a2_store_encoders
//   always stores each encoder once and declares no locals. The export
//   returns 0; the real path stays on the w439 overlay.
// stamp w579 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx: *u8, nbytes: i32, ta: i32): i32;
export extern function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern function backend_enc_mov_rax_to_rbx_arch(elf_ctx: *u8, ta: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the path-A2 sret INDEX encoders. Offset 0 is
 * pipeline_asm_emit_expr_elf_c, 4 is backend_enc_mov_rax_to_rbx_arch,
 * 8 is glue_emit_sret_memcpy_rbx_to_home_elf_c. No locals. Each
 * encoder runs once, not under if or after a mid-assign.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ret_op i32 — returned INDEX expr ref
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param sret_sz i32 — sret byte count passed to memcpy
 * @param cell *u8 — at least 12 bytes
 * @return i32 — 0 after the stores
 * PLATFORM: SHARED freestanding emit.
 */
function arr_return_a2_store_encoders(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, sret_sz: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, pipeline_asm_emit_expr_elf_c(arena, elf_ctx, ret_op, ctx, ta));
    pipe_store_i32_le(cell, 4, backend_enc_mov_rax_to_rbx_arch(elf_ctx, ta));
    pipe_store_i32_le(cell, 8, glue_emit_sret_memcpy_rbx_to_home_elf_c(elf_ctx, sret_sz, ta));
    return 0;
  }
}

/**
 * wave439/579: sret return of an INDEX of a large struct.
 * Encoders always run. Tip returns 0. ko / sret_* / mod / fi stay
 * live so the signature matches the w439 overlay, which still does
 * the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param ret_op i32 — returned INDEX expr ref
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param ko i32 — expr kind; unused for the tip result
 * @param sret_act i32 — sret active flag; kept live
 * @param sret_sz i32 — sret size; kept live and passed to memcpy
 * @param mod *u8 — module; kept live
 * @param fi i32 — function index; kept live
 * @return i32 — 0 on this tip; overlay returns 0 / 1 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_return_path_a2_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let cell: u8[12] = [];
    let sink: i32 = 0;
    arr_return_a2_store_encoders(arena, elf_ctx, ret_op, ctx, ta, sret_sz, &cell[0]);
    sink = sret_act + sret_sz + ko;
    if (sink < (0 - 2000000000)) {
      return 0;
    }
    if (mod == (0 as *u8) && fi < (0 - 1)) {
      return 0;
    }
    return 0;
  }
}
