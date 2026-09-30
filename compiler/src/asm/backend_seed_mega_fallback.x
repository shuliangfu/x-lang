// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// w1540 (6.3): the whole asm_backend_partial.o surface lives here.
// g05_ensure emits it with product pure asm on all three hosts (no cc).
// Strong: backend_asm_codegen_ast(_to_elf)(_seed_mega),
// pipeline_seed_mega_ctx_reset, pipeline_dep_ctx_target_arch_local.
// Weak on Darwin/Linux (named by g05): the ten backend_emit_* return-0 stubs.
// seeds/backend_seed_mega_fallback.from_x.c stays on disk (deletion is 9.1).
// Context layout (pipeline_glue_AsmFuncCtxLayout, sizeof 1528):
// num_locals@8 i32, label_counter@12 i32, module_ref@16 ptr,
// dep_pipe@1384 ptr, tail_join_label@1392 [128]u8, tail_join_label_len@1520 i32.

export extern "C" function pipeline_dep_ctx_target_arch(ctx: *u8): i32;
export extern "C" function memset(p: *u8, c: i32, n: i32): *u8;
export extern "C" function calloc(n: usize, size: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function pipeline_module_hoist_top_level_lets_into_main(m: *u8, a: *u8): void;
export extern "C" function pipeline_asm_emit_set_dep_pipe(ctx: *u8): void;
export extern "C" function pipeline_asm_emit_set_module(m: *u8): void;
export extern "C" function pipeline_asm_emit_set_arena(a: *u8): void;
export extern "C" function pipeline_asm_emit_set_func_index(fi: i32): void;
export extern "C" function pipeline_module_num_funcs(m: *u8): i32;
export extern "C" function pipeline_asm_module_func_is_extern_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_wpo_should_emit_func(m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_module_func_name_copy64(m: *u8, fi: i32, dst: *u8): void;
export extern "C" function pipeline_asm_module_func_name_len_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_module_func_body_ref_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_module_func_num_params_at(m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_block_num_stmt_order_at(a: *u8, br: i32): i32;
export extern "C" function pipeline_asm_get_return_expr_ref_at(a: *u8, m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_compute_frame_size_c(np: i32, a: *u8, br: i32, m: *u8, fi: i32): i32;
export extern "C" function pipeline_asm_fill_param_slots(ctx: *u8, m: *u8, fi: i32): void;
export extern "C" function pipeline_asm_fill_local_slots(ctx: *u8, a: *u8, br: i32): void;
export extern "C" function pipeline_asm_emit_next_label_c(ctx: *u8, buf: *u8, n: i32): i32;
export extern "C" function pipeline_asm_emit_block_body_c(a: *u8, out: *u8, br: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_block_inits_c(a: *u8, out: *u8, br: i32, ctx: *u8, ta: i32, sb: i32): i32;
export extern "C" function pipeline_asm_emit_expr_c(a: *u8, out: *u8, er: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_backend_asm_codegen_ast_to_elf_c(m: *u8, a: *u8, elf: *u8, ctx: *u8): i32;
export extern "C" function backend_arch_emit_section_text(out: *u8, ta: i32): i32;
export extern "C" function backend_arch_emit_globl(out: *u8, name: *u8, n: i32, ta: i32): i32;
export extern "C" function backend_arch_emit_label(out: *u8, name: *u8, n: i32, ta: i32): i32;
export extern "C" function backend_arch_emit_prologue(out: *u8, fs: i32, ta: i32): i32;
export extern "C" function backend_arch_emit_epilogue(out: *u8, fs: i32, ta: i32): i32;
export extern "C" function ast_ast_block_num_consts(a: *u8, br: i32): i32;
export extern "C" function ast_ast_block_num_lets(a: *u8, br: i32): i32;
export extern "C" function driver_diagnostic_asm_set_current_func(name: *u8, n: i32): void;
export extern "C" function driver_diagnostic_asm_fail_at(loc: i32): void;

/** Exported function `backend_seed_mega_fallback_x_doc_anchor`.
 * Implements `backend_seed_mega_fallback_x_doc_anchor`.
 * @return i32
 */
export function backend_seed_mega_fallback_x_doc_anchor(): i32 {
  return 0;
}

/** w1540 anchor: g05 checks it to tell the pure-asm partial from the old
 * host-cc leftover.
 * @return i32
 */
#[no_mangle]
export function backend_seed_mega_fallback_w1540_anchor(): i32 {
  return 1540;
}

/* ---- G-02f-104 / G-02f-150：seed mega helpers ---- */

// AsmFuncCtxLayout size=1336；label_counter@12 i32；module_ref@16 ptr
/** Exported function `mega_load_i32_le`.
 * Implements `mega_load_i32_le`.
 * @param p *u8
 * @param off i32
 * @return i32
 */
export function mega_load_i32_le(p: *u8, off: i32): i32 {
  if (p == 0) { return 0; }
  let m: i32 = 256;
  let a: i32 = p[off] as i32;
  a = a + (p[off + 1] as i32) * m;
  a = a + (p[off + 2] as i32) * (m * m);
  a = a + (p[off + 3] as i32) * (m * m * m);
  return a;
}

/** Exported function `mega_store_i32_le`.
 * Implements `mega_store_i32_le`.
 * @param p *u8
 * @param off i32
 * @param v i32
 * @return void
 */
export function mega_store_i32_le(p: *u8, off: i32, v: i32): void {
  if (p == 0) { return; }
  let u: u32 = v as u32;
  p[off] = (u & 255) as u8;
  p[off + 1] = ((u / 256) & 255) as u8;
  p[off + 2] = ((u / 65536) & 255) as u8;
  p[off + 3] = ((u / 16777216) & 255) as u8;
}

/** Exported function `mega_store_ptr_le`.
 * Implements `mega_store_ptr_le`.
 * @param p *u8
 * @param off i32
 * @param val *u8
 * @return void
 */
export function mega_store_ptr_le(p: *u8, off: i32, val: *u8): void {
  if (p == 0) { return; }
  // Shifts, not `/ m` or `% m`: a variable divisor emits a zero check that
  // calls xlang_panic_, which g05 pure asm rejects (w1540).
  let a: usize = val as usize;
  p[off + 0] = (a & 255) as u8;
  p[off + 1] = ((a >> 8) & 255) as u8;
  p[off + 2] = ((a >> 16) & 255) as u8;
  p[off + 3] = ((a >> 24) & 255) as u8;
  p[off + 4] = ((a >> 32) & 255) as u8;
  p[off + 5] = ((a >> 40) & 255) as u8;
  p[off + 6] = ((a >> 48) & 255) as u8;
  p[off + 7] = ((a >> 56) & 255) as u8;
}

// pipeline_seed_mega_ctx_reset: see function docblock below.
/** Exported function `pipeline_seed_mega_ctx_reset`.
 * Implements `pipeline_seed_mega_ctx_reset`.
 * @param ctx *u8
 * @param mod *u8
 * @return void
 */
#[no_mangle]
export function pipeline_seed_mega_ctx_reset(ctx: *u8, mod: *u8): void {
  if (ctx == 0) { return; }
  unsafe {
    let label_counter: i32 = mega_load_i32_le(ctx, 12);
    // sizeof(pipeline_glue_AsmFuncCtxLayout)=1528 (seed C sizeof; w1540)
    memset(ctx, 0, 1528);
    mega_store_i32_le(ctx, 12, label_counter);
    mega_store_ptr_le(ctx, 16, mod);
  }
}

// pipeline_dep_ctx_target_arch_local: see function docblock below.
/** Exported function `pipeline_dep_ctx_target_arch_local`.
 * Implements `pipeline_dep_ctx_target_arch_local`.
 * @param ctx *u8
 * @return i32
 */
#[no_mangle]
export function pipeline_dep_ctx_target_arch_local(ctx: *u8): i32 {
  if (ctx == 0) { return 0; }
  unsafe {
    return pipeline_dep_ctx_target_arch(ctx);
  }
  return 0;
}

// ---- w1540 (6.3): seed_mega text codegen, entries, weak emit stubs ----

/** Fail with a diagnostic location; free the work buffer.
 * @param buf *u8
 * @param loc i32
 * @return i32 always -1
 */
function bsmf_fail(buf: *u8, loc: i32): i32 {
  unsafe {
    driver_diagnostic_asm_fail_at(loc);
    free(buf);
    return -1;
  }
  return -1;
}

/** Emit one function body (prologue through epilogue).
 * @return i32 0 ok, or a diagnostic location (1..9)
 */
function bsmf_emit_one_func(module: *u8, arena: *u8, out: *u8, pctx: *u8, ctx: *u8, fname: *u8, i: i32, ta: i32): i32 {
  unsafe {
    pipeline_asm_module_func_name_copy64(module, i, fname);
    let nlen: i32 = pipeline_asm_module_func_name_len_at(module, i);
    driver_diagnostic_asm_set_current_func(fname, nlen);
    pipeline_asm_emit_set_func_index(i);
    pipeline_seed_mega_ctx_reset(ctx, module);
    mega_store_ptr_le(ctx, 1384, pctx);
    pipeline_asm_fill_param_slots(ctx, module, i);
    nlen = pipeline_asm_module_func_name_len_at(module, i);
    if (backend_arch_emit_globl(out, fname, nlen, ta) != 0) { return 2; }
    nlen = pipeline_asm_module_func_name_len_at(module, i);
    if (backend_arch_emit_label(out, fname, nlen, ta) != 0) { return 3; }
    let body_ref: i32 = pipeline_asm_module_func_body_ref_at(module, i);
    let frame_sz: i32 = 0;
    let nstmt: i32 = 0;
    if (body_ref != 0) {
      let np: i32 = pipeline_asm_module_func_num_params_at(module, i);
      frame_sz = pipeline_asm_compute_frame_size_c(np, arena, body_ref, module, i);
      nstmt = pipeline_asm_block_num_stmt_order_at(arena, body_ref);
      if (nstmt == 0) {
        pipeline_asm_fill_local_slots(ctx, arena, body_ref);
      }
    }
    if (backend_arch_emit_prologue(out, frame_sz, ta) != 0) { return 4; }
    if (body_ref != 0) {
      let tjl: *u8 = ctx + 1392;
      let tlen: i32 = pipeline_asm_emit_next_label_c(ctx, tjl, 64);
      mega_store_i32_le(ctx, 1520, tlen);
      if (tlen <= 0) { return 9; }
      nstmt = pipeline_asm_block_num_stmt_order_at(arena, body_ref);
      if (nstmt > 0) {
        if (pipeline_asm_emit_block_body_c(arena, out, body_ref, ctx, ta) != 0) { return 5; }
      } else {
        let nloc: i32 = mega_load_i32_le(ctx, 8);
        let ncon: i32 = ast_ast_block_num_consts(arena, body_ref);
        let nlet: i32 = ast_ast_block_num_lets(arena, body_ref);
        let slot_base: i32 = nloc - ncon;
        slot_base = slot_base - nlet;
        if (slot_base < 0) { return 6; }
        if (pipeline_asm_emit_block_inits_c(arena, out, body_ref, ctx, ta, slot_base) != 0) { return 6; }
      }
      tlen = mega_load_i32_le(ctx, 1520);
      if (backend_arch_emit_label(out, tjl, tlen, ta) != 0) { return 9; }
    }
    let result_ref: i32 = 0;
    let want_ret: i32 = 0;
    if (body_ref == 0) {
      want_ret = 1;
    } else {
      nstmt = pipeline_asm_block_num_stmt_order_at(arena, body_ref);
      if (nstmt == 0) { want_ret = 1; }
    }
    if (want_ret != 0) {
      result_ref = pipeline_asm_get_return_expr_ref_at(arena, module, i);
    }
    if (result_ref != 0) {
      if (pipeline_asm_emit_expr_c(arena, out, result_ref, ctx, ta) != 0) { return 7; }
    }
    if (backend_arch_emit_epilogue(out, frame_sz, ta) != 0) { return 8; }
    return 0;
  }
  return -1;
}

/** Exported function `backend_asm_codegen_ast_seed_mega`.
 * Text asm for every emitted function of the module (seed mega path).
 * Work buffer (ctx 1528 + name 256) is heap, not stack.
 * @return i32 0 ok, -1 fail
 */
#[no_mangle]
export function backend_asm_codegen_ast_seed_mega(module: *u8, arena: *u8, out: *u8, pctx: *u8): i32 {
  unsafe {
    if (module == 0) { return -1; }
    if (arena == 0) { return -1; }
    if (out == 0) { return -1; }
    if (pctx == 0) { return -1; }
    pipeline_module_hoist_top_level_lets_into_main(module, arena);
    let ta: i32 = pipeline_dep_ctx_target_arch_local(pctx);
    let buf: *u8 = 0;
    buf = calloc(1, 1784);
    if (buf == 0) { return -1; }
    let ctx: *u8 = buf;
    let fname: *u8 = buf + 1528;
    pipeline_asm_emit_set_dep_pipe(pctx);
    pipeline_asm_emit_set_module(module);
    pipeline_asm_emit_set_arena(arena);
    let i: i32 = 0;
    let nf: i32 = pipeline_module_num_funcs(module);
    while (i < nf) {
      if (i == 0) {
        if (backend_arch_emit_section_text(out, ta) != 0) { return bsmf_fail(buf, 1); }
      }
      let skip: i32 = 0;
      if (pipeline_asm_module_func_is_extern_at(module, i) != 0) { skip = 1; }
      if (skip == 0) {
        if (pipeline_asm_wpo_should_emit_func(module, i) == 0) { skip = 1; }
      }
      if (skip == 0) {
        let rc: i32 = bsmf_emit_one_func(module, arena, out, pctx, ctx, fname, i, ta);
        if (rc != 0) { return bsmf_fail(buf, rc); }
      }
      i = i + 1;
      nf = pipeline_module_num_funcs(module);
    }
    free(buf);
    return 0;
  }
  return -1;
}

/** Exported function `backend_asm_codegen_ast_to_elf_seed_mega`.
 * @return i32
 */
#[no_mangle]
export function backend_asm_codegen_ast_to_elf_seed_mega(module: *u8, arena: *u8, elf_ctx: *u8, pctx: *u8): i32 {
  unsafe {
    return pipeline_backend_asm_codegen_ast_to_elf_c(module, arena, elf_ctx, pctx);
  }
  return -1;
}

/** Exported function `backend_asm_codegen_ast`.
 * @return i32
 */
#[no_mangle]
export function backend_asm_codegen_ast(module: *u8, arena: *u8, out: *u8, pctx: *u8): i32 {
  return backend_asm_codegen_ast_seed_mega(module, arena, out, pctx);
}

/** Exported function `backend_asm_codegen_ast_to_elf`.
 * @return i32
 */
#[no_mangle]
export function backend_asm_codegen_ast_to_elf(module: *u8, arena: *u8, elf_ctx: *u8, pctx: *u8): i32 {
  return backend_asm_codegen_ast_to_elf_seed_mega(module, arena, elf_ctx, pctx);
}

// Phase1 placeholders: return 0. g05 makes them weak on Darwin/Linux so a
// real body elsewhere wins; Win links first-wins like the old seed object.
#[no_mangle]
export function backend_emit_block_body(a: *u8, out: *u8, br: i32, ctx: *u8, ta: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_block_inits(a: *u8, out: *u8, br: i32, ctx: *u8, ta: i32, sb: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_expr(a: *u8, out: *u8, er: i32, ctx: *u8, ta: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_expr_call(a: *u8, out: *u8, er: i32, ec: *u8, ctx: *u8, ta: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_expr_elf(a: *u8, elf: *u8, er: i32, ctx: *u8, ta: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_expr_method_call(a: *u8, out: *u8, er: i32, ec: *u8, ctx: *u8, ta: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_for_loop(a: *u8, out: *u8, br: i32, fi: i32, ctx: *u8, ta: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_if_then_block_body_text(a: *u8, out: *u8, tbr: i32, ctx: *u8, ta: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_loop_body_content(a: *u8, out: *u8, br: i32, ctx: *u8, ta: i32): i32 { return 0; }
#[no_mangle]
export function backend_emit_while_loop(a: *u8, out: *u8, br: i32, li: i32, ctx: *u8, ta: i32): i32 { return 0; }
