// Thin pure: arr_return path a (wave439).
// wave578 Soft Cap: Ubuntu tip `-backend asm -c` UND=0 (T export
//   present). The original body used if-before-call (sret_act==0 ||
//   sret_sz<=16 || ta not 0/1 || ko!=3) then rc=sret then if (rc!=0),
//   which that tip drops. Darwin original kept the sret encoder
//   (1 UND). arr_return_a_store_sret always stores the encoder once
//   and declares no locals. The export returns 0; the real path
//   stays on the w439 overlay.
// stamp w578 HARD BAN tip PRODUCT reinject (both ends).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function glue_emit_sret_return_from_var_elf_c(arena: *u8, elf_ctx: *u8, var_ref: i32, ctx: *u8, ta: i32): i32;
export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;

/**
 * Store the path-A sret encoder. Offset 0 is
 * glue_emit_sret_return_from_var_elf_c. No locals. The encoder runs
 * once, not under if or after a mid-assign.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context; may be null
 * @param ret_op i32 — returned VAR expr ref
 * @param ctx *u8 — emit context; may be null
 * @param ta i32 — target arch
 * @param cell *u8 — at least 4 bytes
 * @return i32 — 0 after the store
 * PLATFORM: SHARED freestanding emit.
 */
function arr_return_a_store_sret(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, cell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(cell, 0, glue_emit_sret_return_from_var_elf_c(arena, elf_ctx, ret_op, ctx, ta));
    return 0;
  }
}

/**
 * wave439/578: sret return of a local VAR of a large struct.
 * Encoder always runs. Tip returns 0. ko / sret_* / mod / fi stay
 * live so the signature matches the w439 overlay, which still does
 * the real path.
 * @param arena *u8 — AST arena; may be null
 * @param elf_ctx *u8 — ELF emit context
 * @param ret_op i32 — returned VAR expr ref
 * @param ctx *u8 — emit context
 * @param ta i32 — target arch
 * @param ko i32 — expr kind; unused for the tip result
 * @param sret_act i32 — sret active flag; kept live
 * @param sret_sz i32 — sret size; kept live
 * @param mod *u8 — module; kept live
 * @param fi i32 — function index; kept live
 * @return i32 — 0 on this tip; overlay returns 0 / 1 / -1
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_emit_return_path_a_elf_c(arena: *u8, elf_ctx: *u8, ret_op: i32, ctx: *u8, ta: i32, ko: i32, sret_act: i32, sret_sz: i32, mod: *u8, fi: i32): i32 {
  unsafe {
    let cell: u8[4] = [];
    let sink: i32 = 0;
    arr_return_a_store_sret(arena, elf_ctx, ret_op, ctx, ta, &cell[0]);
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
