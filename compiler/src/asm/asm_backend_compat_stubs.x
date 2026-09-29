// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// asm_backend_compat_stubs: link-name compat layer for the asm backend.
// w1519 (5.8b): the whole object is built from this file by product pure
// asm on all three hosts; seeds/asm_backend_compat_stubs.from_x.c is no
// longer compiled by host cc on the product path (the seed stays only for
// build_xlang_asm.sh until 5.11).
// Weak set (Darwin/Linux, named by g05 via G05_X_O_WEAK_FUNCS; Windows is
// all strong, matching XLANG_WEAK = empty on PE): append_asm_line,
// format_i32_to_buf, asm_types_append_asm_line, asm_types_format_i32_to_buf,
// asm_types_format_u32_to_buf, asm_types_format_u32_hex8_to_buf,
// asm_types_elf_read_u32_le, expr_layout_prime_call_resolved,
// emit_ldr_sp_slot_to_xreg, backend_asm_codegen_ast_seed_mega,
// backend_asm_codegen_ast_to_elf_seed_mega, peephole_peephole_run,
// peephole_peephole_elf_run, typeck_lsp_build_semantic_tokens_response.
// Pointers to C structs are passed as *u8; struct fields are read by byte
// offset (CodegenOutBuf.length at 9437184; AsmFuncCtx next_offset at 4,
// num_locals at 8).
// PLATFORM: MACOS arm64 · LINUX x86_64 · WINDOWS x86_64.

export extern "C" function pipeline_elf_ctx_append_bytes(ctx: *u8, ptr: *u8, n: i32): i32;
export extern "C" function pipeline_elf_ctx_code_data_ptr(ctx: *u8): *u8;
export extern "C" function backend_emit_expr_elf(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function backend_enc_mov_rax_to_arg_reg_arch(elf_ctx: *u8, k: i32, ta: i32): i32;
export extern "C" function asm_ctx_ensure_block_locals(ctx: *u8, arena: *u8, block_ref: i32, io_off: *u8, io_nl: *u8): void;
export extern "C" function asm_ctx_block_slot_get(ctx: *u8, block_ref: i32): i32;
export extern "C" function pipeline_expr_call_arg_ref(arena: *u8, expr_ref: i32, idx: i32): i32;
export extern "C" function pipeline_asm_emit_expr_elf_c(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function ast_ast_block_num_consts(a: *u8, br: i32): i32;
export extern "C" function ast_ast_block_num_lets(a: *u8, br: i32): i32;
export extern "C" function backend_enc_mov_imm32_to_w0_arch(elf_ctx: *u8, imm32: i32, ta: i32): i32;
export extern "C" function backend_enc_epilogue_arch(elf_ctx: *u8, ta: i32): i32;
export extern "C" function backend_emit_block_inits(arena: *u8, out: *u8, block_ref: i32, ctx: *u8, target_arch: i32, slot_base: i32): i32;
export extern "C" function backend_emit_block_body(arena: *u8, out: *u8, block_ref: i32, ctx: *u8, target_arch: i32): i32;
export extern "C" function backend_emit_while_loop(arena: *u8, out: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, target_arch: i32): i32;
export extern "C" function backend_emit_for_loop(arena: *u8, out: *u8, block_ref: i32, for_idx: i32, ctx: *u8, target_arch: i32): i32;
export extern "C" function backend_emit_loop_body_content(arena: *u8, out: *u8, body_ref: i32, ctx: *u8, target_arch: i32): i32;
export extern "C" function backend_emit_if_then_block_body_text(arena: *u8, out: *u8, then_block_ref: i32, ctx: *u8, target_arch: i32): i32;
export extern "C" function backend_emit_expr(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8, target_arch: i32): i32;
export extern "C" function pipeline_asm_emit_loop_body_content_elf_c(arena: *u8, elf_ctx: *u8, body_ref: i32, ctx: *u8, ta: i32): i32;
export extern "C" function pipeline_asm_emit_call_args_text_c(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8, target_arch: i32, nargs: i32): i32;
export extern "C" function backend_asm_codegen_ast(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8): i32;
export extern "C" function backend_asm_codegen_ast_to_elf(module: *u8, arena: *u8, elf_ctx: *u8, ctx: *u8): i32;

/** Doc anchor (keeps the TU non-empty for cold tooling). */
#[no_mangle]
export function asm_backend_compat_stubs_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Little-endian i32 read at byte offset (CodegenOutBuf / AsmFuncCtx fields).
 * PLATFORM: SHARED
 */
function abcs_rd32(p: *u8, off: i32): i32 {
  let q: *u8 = p + off;
  let b0: i32 = (q[0] as i32) & 255;
  let b1: i32 = (q[1] as i32) & 255;
  let b2: i32 = (q[2] as i32) & 255;
  let b3: i32 = (q[3] as i32) & 255;
  return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
}

/**
 * Little-endian i32 write at byte offset.
 * PLATFORM: SHARED
 */
function abcs_wr32(p: *u8, off: i32, v: i32): void {
  let q: *u8 = p + off;
  q[0] = (v & 255) as u8;
  q[1] = ((v >> 8) & 255) as u8;
  q[2] = ((v >> 16) & 255) as u8;
  q[3] = ((v >> 24) & 255) as u8;
}

/* ---- G-02f-99 / G-02f-139：format ---- */

/** Unsigned decimal into buf[off..]; returns digit count or -1. */
#[no_mangle]
export function xlang_format_u32_to_buf(buf: *u8, off: i32, max: i32, u: u32): i32 {
  if (buf == 0) { return 0 - 1; }
  if (max < 1) { return 0 - 1; }
  let tmp: u8[10] = [];
  let num_digits: i32 = 0;
  let v: u32 = u;
  // digit_chars '0'+d
  while (v > 0) {
    if (num_digits >= 10) { break; }
    let d: u32 = v % 10;
    tmp[num_digits] = (48 + (d as i32)) as u8;
    num_digits = num_digits + 1;
    v = v / 10;
  }
  if (num_digits == 0) {
    buf[off] = 48;
    return 1;
  }
  if (num_digits > max) { return 0 - 1; }
  let idx: i32 = 0;
  while (idx < num_digits) {
    buf[off + idx] = tmp[num_digits - 1 - idx];
    idx = idx + 1;
  }
  return num_digits;
}

/**
 * Append bytes plus '\n' to a CodegenOutBuf (data[9437184] then length).
 * Weak on Darwin/Linux: the real types.o symbol wins when linked.
 */
#[no_mangle]
export function append_asm_line(out: *u8, ptr: *u8, len: i32): i32 {
  if (out == 0 as *u8) { return 0 - 1; }
  if (ptr == 0 as *u8) { return 0 - 1; }
  if (len < 0) { return 0 - 1; }
  let n: i32 = abcs_rd32(out, 9437184);
  let i: i32 = 0;
  while (i < len) {
    if (n >= 9437184) {
      abcs_wr32(out, 9437184, n);
      return 0 - 1;
    }
    out[n] = ptr[i];
    n = n + 1;
    i = i + 1;
  }
  if (n >= 9437184) {
    abcs_wr32(out, 9437184, n);
    return 0 - 1;
  }
  out[n] = 10;
  n = n + 1;
  abcs_wr32(out, 9437184, n);
  return 0;
}

/** Signed decimal into buf[off..]; same meaning as types.x format_i32_to_buf. */
#[no_mangle]
export function format_i32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32 {
  if (buf == 0 as *u8) { return 0 - 1; }
  if (max < 1) { return 0 - 1; }
  if (val < 0) {
    let min_i32: i32 = 0 - 2147483647 - 1;
    if (val == min_i32) {
      if (max < 11) { return 0 - 1; }
      let s: *u8 = "-2147483648";
      let k: i32 = 0;
      while (k < 11) {
        buf[off + k] = s[k];
        k = k + 1;
      }
      return 11;
    }
    buf[off] = 45;
    let neg: i32 = 0 - val;
    let n: i32 = xlang_format_u32_to_buf(buf, off + 1, max - 1, neg as u32);
    if (n < 0) { return 0 - 1; }
    return n + 1;
  }
  return xlang_format_u32_to_buf(buf, off, max, val as u32);
}

/** types.append_asm_line link name on Linux ELF (weak forward). */
#[no_mangle]
export function asm_types_append_asm_line(out: *u8, ptr: *u8, len: i32): i32 {
  return append_asm_line(out, ptr, len);
}

/** types.format_i32_to_buf link name (weak forward). */
#[no_mangle]
export function asm_types_format_i32_to_buf(buf: *u8, off: i32, max: i32, val: i32): i32 {
  return format_i32_to_buf(buf, off, max, val);
}

/** types.format_u32_to_buf link name (weak forward). */
#[no_mangle]
export function asm_types_format_u32_to_buf(buf: *u8, off: i32, max: i32, u: i32): i32 {
  return xlang_format_u32_to_buf(buf, off, max, u as u32);
}

/** 8 lowercase hex digits, most significant first (types.x). */
#[no_mangle]
export function asm_types_format_u32_hex8_to_buf(buf: *u8, off: i32, val: i32): i32 {
  if (buf == 0 as *u8) { return 0 - 1; }
  let hex: *u8 = "0123456789abcdef";
  let i: i32 = 0;
  while (i < 8) {
    let nib: i32 = (val >> (i * 4)) & 15;
    buf[off + 7 - i] = hex[nib];
    i = i + 1;
  }
  return 8;
}

/** u32 LE from ElfCodegenCtx.code_data (elf.x elf_read_u32_le). */
#[no_mangle]
export function asm_types_elf_read_u32_le(ctx: *u8, pos: i32): i32 {
  unsafe {
    if (ctx == 0 as *u8) { return 0; }
    if (pos < 0) { return 0; }
    let base: *u8 = pipeline_elf_ctx_code_data_ptr(ctx);
    if (base == 0 as *u8) { return 0; }
    return abcs_rd32(base, pos);
  }
}

/** ast.x Expr layout prime; no-op until build_asm/ast.o emits it. */
#[no_mangle]
export function expr_layout_prime_call_resolved(): void {
}

/** arm64 text: `ldr x{reg}, [sp]` or `ldr x{reg}, [sp, #slot*16]` (arm64.x). */
#[no_mangle]
export function emit_ldr_sp_slot_to_xreg(out: *u8, slot: i32, reg: i32): i32 {
  if (out == 0 as *u8) { return 0 - 1; }
  let s: i32 = slot;
  if (s < 0) { s = 0; }
  if (s > 7) { s = 7; }
  let rd: i32 = reg;
  if (rd < 0) { rd = 0; }
  if (rd > 7) { rd = 7; }
  let line: u8[48] = [];
  let bp: *u8 = &line[0];
  let pre: *u8 = "ldr x0, [sp";
  let k: i32 = 0;
  while (k < 11) {
    bp[k] = pre[k];
    k = k + 1;
  }
  bp[5] = (48 + rd) as u8;
  if (s == 0) {
    bp[11] = 93;
    return append_asm_line(out, bp, 12);
  }
  bp[11] = 44;
  bp[12] = 32;
  bp[13] = 35;
  let n: i32 = format_i32_to_buf(bp, 14, 12, s * 16);
  if (n < 0) { return 0 - 1; }
  bp[14 + n] = 93;
  return append_asm_line(out, bp, 15 + n);
}

/** Append a u32 as 4 LE bytes to ElfCodegenCtx code. */
#[no_mangle]
export function xlang_elf_ctx_append_u32_le(elf_ctx: *u8, word: u32): i32 {
  unsafe {
    if (elf_ctx == 0) { return 0 - 1; }
    // Live pad. Darwin arm64 placed a store at the frame edge (room 0).
    // The pad grows sub sp so that store stays inside the frame.
    // PLATFORM: MACOS|DARWIN arm64.
    let pad: u8[32] = [];
    pad[0] = 0;
    let b0: u8 = (word & 255) as u8;
    let b1: u8 = ((word / 256) & 255) as u8;
    let b2: u8 = ((word / 65536) & 255) as u8;
    let b3: u8 = ((word / 16777216) & 255) as u8;
    let r: i32 = 0;
    unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b0, 1); }
    if (r != 0) { return 0 - 1; }
    unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b1, 1); }
    if (r != 0) { return 0 - 1; }
    unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b2, 1); }
    if (r != 0) { return 0 - 1; }
    unsafe { r = pipeline_elf_ctx_append_bytes(elf_ctx, &b3, 1); }
    return r;
  }
}

/**
 * arm64 MOVZ/MOVK load imm32 into w0 (f32 IEEE bits / large i32).
 * wave616: MOVK hw=1 (0x72a00000 = lsl #16), not hw=0 (0x72800000).
 * Matches arch_arm64_enc_enc_mov_imm32_to_w0 / arm64_enc.x.
 */
#[no_mangle]
export function xlang_arm64_mov_imm32_to_w0_c(elf_ctx: *u8, imm32: i32): i32 {
  let u: u32 = imm32 as u32;
  let lo: u32 = u & 65535;
  let hi: u32 = (u / 65536) & 65535;
  /* MOVZ w0, #lo — 0x52800000 | (lo << 5) */
  if (xlang_elf_ctx_append_u32_le(elf_ctx, 1384120320 | (lo * 32)) != 0) {
    return 0 - 1;
  }
  if (hi != 0) {
    /* MOVK w0, #hi, lsl #16 — 0x72a00000 | (hi << 5) */
    if (xlang_elf_ctx_append_u32_le(elf_ctx, 1923088384 | (hi * 32)) != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/** partial.o exports backend_emit_expr_elf; the slow path wants _full. */
#[no_mangle]
export function backend_emit_expr_elf_full(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return backend_emit_expr_elf(arena, elf_ctx, expr_ref, ctx, ta);
  }
}

/** Slow path calls the full body (never the thin wrapper: mutual recursion). */
#[no_mangle]
export function backend_emit_expr_elf_slow(arena: *u8, elf_ctx: *u8, expr_ref: i32, ctx: *u8, ta: i32): i32 {
  return backend_emit_expr_elf_full(arena, elf_ctx, expr_ref, ctx, ta);
}

/**
 * Register block const/let stack slots (runtime_pipeline_abi steps by type
 * width and records block to slot_base). AsmFuncCtx next_offset at +4,
 * num_locals at +8.
 */
#[no_mangle]
export function backend_ensure_block_local_slots(ctx: *u8, arena: *u8, block_ref: i32): void {
  unsafe {
    if (ctx == 0 as *u8) { return; }
    if (arena == 0 as *u8) { return; }
    if (block_ref <= 0) { return; }
    let io: u8[8] = [];
    let ip: *u8 = &io[0];
    abcs_wr32(ip, 0, abcs_rd32(ctx, 4));
    abcs_wr32(ip, 4, abcs_rd32(ctx, 8));
    asm_ctx_ensure_block_locals(ctx, arena, block_ref, ip, ip + 4);
    abcs_wr32(ctx, 4, abcs_rd32(ip, 0));
    abcs_wr32(ctx, 8, abcs_rd32(ip, 4));
  }
}

/** First local slot index of a block (asm_ctx_block_slot_get first). */
#[no_mangle]
export function backend_block_slot_base_for(ctx: *u8, arena: *u8, block_ref: i32): i32 {
  unsafe {
    if (ctx == 0 as *u8) { return 0; }
    if (arena == 0 as *u8) { return 0; }
    if (block_ref <= 0) { return 0; }
    let slot_base: i32 = asm_ctx_block_slot_get(ctx, block_ref);
    if (slot_base >= 0) { return slot_base; }
    let nconst: i32 = ast_ast_block_num_consts(arena, block_ref);
    let nlet: i32 = ast_ast_block_num_lets(arena, block_ref);
    slot_base = abcs_rd32(ctx, 8) - nconst - nlet;
    if (slot_base < 0) { return 0; }
    return slot_base;
  }
}

/** ARM64 one call argument: emit the expression, then move to arg reg. */
#[no_mangle]
export function backend_asm_emit_one_call_arg_elf_arm64_push(arena: *u8, elf_ctx: *u8, expr_ref: i32, arg_idx: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    let arg_ref: i32 = pipeline_expr_call_arg_ref(arena, expr_ref, arg_idx);
    if (arg_ref == 0) { return 0; }
    if (pipeline_asm_emit_expr_elf_c(arena, elf_ctx, arg_ref, ctx, ta) != 0) {
      return 0 - 1;
    }
    return backend_enc_mov_rax_to_arg_reg_arch(elf_ctx, arg_idx, ta);
  }
}

/** Text asm: block const/let inits (seed partial backend_emit_block_inits). */
#[no_mangle]
export function pipeline_asm_emit_block_inits_c(arena: *u8, out: *u8, block_ref: i32, ctx: *u8, target_arch: i32, slot_base: i32): i32 {
  unsafe {
    return backend_emit_block_inits(arena, out, block_ref, ctx, target_arch, slot_base);
  }
}

/** Text asm block body. */
#[no_mangle]
export function pipeline_asm_emit_block_body_c(arena: *u8, out: *u8, block_ref: i32, ctx: *u8, target_arch: i32): i32 {
  unsafe {
    return backend_emit_block_body(arena, out, block_ref, ctx, target_arch);
  }
}

/** Text asm while loop. */
#[no_mangle]
export function pipeline_asm_emit_while_loop_c(arena: *u8, out: *u8, block_ref: i32, loop_idx: i32, ctx: *u8, target_arch: i32): i32 {
  unsafe {
    return backend_emit_while_loop(arena, out, block_ref, loop_idx, ctx, target_arch);
  }
}

/** Text asm for loop. */
#[no_mangle]
export function pipeline_asm_emit_for_loop_c(arena: *u8, out: *u8, block_ref: i32, for_idx: i32, ctx: *u8, target_arch: i32): i32 {
  unsafe {
    return backend_emit_for_loop(arena, out, block_ref, for_idx, ctx, target_arch);
  }
}

/** Text asm loop body content. */
#[no_mangle]
export function pipeline_asm_emit_loop_body_content_c(arena: *u8, out: *u8, body_ref: i32, ctx: *u8, target_arch: i32): i32 {
  unsafe {
    return backend_emit_loop_body_content(arena, out, body_ref, ctx, target_arch);
  }
}

/** Text asm if-then block body. */
#[no_mangle]
export function pipeline_asm_emit_if_then_block_body_text_c(arena: *u8, out: *u8, then_block_ref: i32, ctx: *u8, target_arch: i32): i32 {
  unsafe {
    return backend_emit_if_then_block_body_text(arena, out, then_block_ref, ctx, target_arch);
  }
}

/** Text asm expression. */
#[no_mangle]
export function pipeline_asm_emit_expr_c(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8, target_arch: i32): i32 {
  unsafe {
    return backend_emit_expr(arena, out, expr_ref, ctx, target_arch);
  }
}

/** SKIP_TYPECK stub: mov w0/x0/eax, #0 then epilogue. */
#[no_mangle]
export function pipeline_asm_emit_skip_heavy_stub_elf_c(elf_ctx: *u8, ta: i32): i32 {
  unsafe {
    if (backend_enc_mov_imm32_to_w0_arch(elf_ctx, 0, ta) != 0) {
      return 0 - 1;
    }
    return backend_enc_epilogue_arch(elf_ctx, ta);
  }
}

/** Link-name fix: no _c suffix forwards to the _c body. */
#[no_mangle]
export function pipeline_asm_emit_loop_body_content(arena: *u8, out: *u8, body_ref: i32, ctx: *u8, target_arch: i32): i32 {
  return pipeline_asm_emit_loop_body_content_c(arena, out, body_ref, ctx, target_arch);
}

/** ELF link-name fix (no _c suffix). */
#[no_mangle]
export function pipeline_asm_emit_loop_body_content_elf(arena: *u8, elf_ctx: *u8, body_ref: i32, ctx: *u8, ta: i32): i32 {
  unsafe {
    return pipeline_asm_emit_loop_body_content_elf_c(arena, elf_ctx, body_ref, ctx, ta);
  }
}

/** Link-name fix for pipeline_asm_emit_call_args_text. */
#[no_mangle]
export function pipeline_asm_emit_call_args_text(arena: *u8, out: *u8, expr_ref: i32, ctx: *u8, target_arch: i32, nargs: i32): i32 {
  unsafe {
    return pipeline_asm_emit_call_args_text_c(arena, out, expr_ref, ctx, target_arch, nargs);
  }
}

/** Weak seed_mega names forward to backend_asm_codegen_ast*. */
#[no_mangle]
export function backend_asm_codegen_ast_seed_mega(module: *u8, arena: *u8, out_buf: *u8, ctx: *u8): i32 {
  unsafe {
    return backend_asm_codegen_ast(module, arena, out_buf, ctx);
  }
}

/** Weak seed_mega ELF name. */
#[no_mangle]
export function backend_asm_codegen_ast_to_elf_seed_mega(module: *u8, arena: *u8, elf_ctx: *u8, ctx: *u8): i32 {
  unsafe {
    return backend_asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx);
  }
}

/** Weak fallback when build_asm/peephole.o is a text stub. */
#[no_mangle]
export function peephole_peephole_run(out_buf: *u8): i32 {
  return 0;
}

/** Weak ELF fallback. */
#[no_mangle]
export function peephole_peephole_elf_run(elf_ctx: *u8): i32 {
  return 0;
}

/** user_asm_seed_bridge calls unprefixed peephole_run. */
#[no_mangle]
export function peephole_run(out_buf: *u8): i32 {
  return peephole_peephole_run(out_buf);
}

/** Unprefixed ELF peephole. */
#[no_mangle]
export function peephole_elf_run(elf_ctx: *u8): i32 {
  return peephole_peephole_elf_run(elf_ctx);
}

/** Weak semanticTokens fallback until lsp_diag_x.o provides the strong one. */
#[no_mangle]
export function typeck_lsp_build_semantic_tokens_response(id_val: i32, doc_buf: *u8, doc_len: i32, out_buf: *u8, out_cap: i32): i32 {
  return 0 - 1;
}
