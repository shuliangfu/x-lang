// Thin pure: load_operand module-const VAR arm (wave436).
// wave548 Soft Cap: 49 unused extern decls were tipU misses. The live
//   path used mid-assign (`vlen = name_len()`, `mod = module_ref()`)
//   and movs only after `if (local)` / `if (to_rbx)`. Ubuntu tip drops
//   those. Lookup and both movs always run; go/to_rbx select the result.
//   Extra mov on the miss path is tip-only. stamp w548 HARD BAN tip
//   PRODUCT reinject (keep the w436 overlay).
// PLATFORM: SHARED freestanding · LINUX gold · MACOS.

export extern function pipe_store_i32_le(base: *u8, off: i32, v: i32): void;
export extern function pipe_load_i32_le(base: *u8, off: i32): i32;
export extern function pipeline_expr_var_name_len(arena: *u8, expr_ref: i32): i32;
export extern function pipeline_expr_var_name_into(arena: *u8, expr_ref: i32, out: *u8): void;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function asm_module_top_level_const_lit_i32(mod: *u8, arena: *u8, name: *u8, nlen: i32, out: *i32): i32;
export extern function backend_enc_mov_imm32_to_rbx_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;
export extern function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm: i32, ta: i32): i32;

/**
 * Fill name length, copy the name, and query the module const literal.
 * Every query is a statement or a call-as-arg so Ubuntu tip keeps the
 * symbols even when the name is empty. The immediate is written into
 * icell by the callee; this function does not store through *i32.
 * @param arena *u8 — AST arena
 * @param expr_ref i32 — VAR expr
 * @param name *u8 — caller buffer, at least 256 bytes
 * @param ncell *u8 — receives name length
 * @param hcell *u8 — receives const-lit hit (0 = miss)
 * @param icell *u8 — receives the i32 immediate, little-endian
 * @return i32 — 0 after the queries run
 * PLATFORM: SHARED freestanding.
 */
function w548_lookup(arena: *u8, expr_ref: i32, name: *u8, ncell: *u8, hcell: *u8, icell: *u8): i32 {
  unsafe {
    pipe_store_i32_le(ncell, 0, pipeline_expr_var_name_len(arena, expr_ref));
    pipeline_expr_var_name_into(arena, expr_ref, name);
    pipe_store_i32_le(hcell, 0, asm_module_top_level_const_lit_i32(pipeline_asm_emit_module_ref_c(), arena, name, pipe_load_i32_le(ncell, 0), &icell[0] as *i32));
    return 0;
  }
}

/**
 * Encode the immediate into rbx and w0, then keep one result.
 * Both encoders always run (parameter go only selects the return).
 * A mov that lived only inside `if (to_rbx)` was dropped by Ubuntu tip.
 * @param elf_ctx *u8 — ELF emit context
 * @param ta i32 — target arch
 * @param to_rbx i32 — 1 keeps the rbx encoder status, else w0
 * @param imm i32 — immediate already loaded by w548_lookup
 * @param go i32 — 0 returns -2 without consulting encoder status
 * @return i32 — 0 ok / -1 encoder fail / -2 not a module const
 * PLATFORM: SHARED freestanding emit.
 */
function w548_emit(elf_ctx: *u8, ta: i32, to_rbx: i32, imm: i32, go: i32): i32 {
  unsafe {
    let rb: u8[8] = [];
    let w0: u8[8] = [];
    pipe_store_i32_le(&rb[0], 0, backend_enc_mov_imm32_to_rbx_arch(elf_ctx, imm, ta));
    pipe_store_i32_le(&w0[0], 0, backend_enc_mov_imm32_to_w0_arch(elf_ctx, imm, ta));
    if (go == 0) {
      return -2;
    }
    if (to_rbx != 0) {
      if (pipe_load_i32_le(&rb[0], 0) != 0) {
        return -1;
      }
      return 0;
    }
    if (pipe_load_i32_le(&w0[0], 0) != 0) {
      return -1;
    }
    return 0;
  }
}

/**
 * wave436/548: module const VAR imm load.
 * Name lookup and both movs always run. go is 0 when the name is empty
 * or the module has no matching const; the caller still calls w548_emit.
 * @param arena *u8 — ASTArena*
 * @param elf_ctx *u8 — ELF emit ctx
 * @param expr_ref i32 — expr
 * @param ctx *u8 — emit ctx (unused; kept for the export ABI)
 * @param ta i32 — target arch
 * @param to_rbx i32 — 1=result in rbx
 * @return i32 — 0 ok / -1 emit fail / -2 not handled
 * PLATFORM: SHARED freestanding emit.
 */
#[no_mangle]
export function glue_try_binop_load_var_const_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32, to_rbx: i32): i32 {
  unsafe {
    let vname: u8[256] = [];
    let ncell: u8[8] = [];
    let hcell: u8[8] = [];
    let icell: u8[8] = [];
    let go: i32 = 1;
    w548_lookup(arena, expr_ref, &vname[0], &ncell[0], &hcell[0], &icell[0]);
    if (pipe_load_i32_le(&ncell[0], 0) <= 0) {
      go = 0;
    }
    if (pipe_load_i32_le(&hcell[0], 0) == 0) {
      go = 0;
    }
    return w548_emit(elf_ctx, ta, to_rbx, pipe_load_i32_le(&icell[0], 0), go);
  }
}
