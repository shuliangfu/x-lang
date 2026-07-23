// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

/* wave236 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * seed_asm_debug_enabled / seed_asm_emit_trace_enabled are pure orch (no *_impl).
 * PLATFORM: SHARED — product hybrid pure uses same face as cold seed twin. */
export extern "C" function link_abi_getenv(name: *u8): *u8;
export extern "C" function seed_elf_ctx_set_macho_leading_underscore_impl(elf_ctx: *u8, on: i32): void;
export extern "C" function seed_asm_reject_empty_elf_text_impl(module: *u8, elf_ctx: *u8): i32;
export extern "C" function seed_platform_macho_write_macho_o_to_buf_impl(elf_ctx: *u8, out_buf: *u8): i32;
export extern "C" function seed_platform_coff_write_coff_o_to_buf_impl(elf_ctx: *u8, out_buf: *u8): i32;

/** Exported function `user_asm_seed_bridge_x_doc_anchor`.
 * Implements `user_asm_seed_bridge_x_doc_anchor`.
 * @return i32
 */
export function user_asm_seed_bridge_x_doc_anchor(): i32 {
  return 0;
}

/* See implementation. */



#[no_mangle]
export function seed_elf_ctx_set_macho_leading_underscore(elf_ctx: *u8, on: i32): void {
  unsafe {
    seed_elf_ctx_set_macho_leading_underscore_impl(elf_ctx, on);
  }
}



/* See implementation. */

#[no_mangle]
export function seed_asm_reject_empty_elf_text(module: *u8, elf_ctx: *u8): i32 {
  unsafe {
    return seed_asm_reject_empty_elf_text_impl(module, elf_ctx);
  }
  return 0;
}

/** Exported function `seed_platform_macho_write_macho_o_to_buf`.
 * Write path helper `seed_platform_macho_write_macho_o_to_buf`.
 * @param elf_ctx *u8
 * @param out_buf *u8
 * @return i32
 */
#[no_mangle]
export function seed_platform_macho_write_macho_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    return seed_platform_macho_write_macho_o_to_buf_impl(elf_ctx, out_buf);
  }
  return 0 - 1;
}

/** Exported function `seed_platform_coff_write_coff_o_to_buf`.
 * Write path helper `seed_platform_coff_write_coff_o_to_buf`.
 * @param elf_ctx *u8
 * @param out_buf *u8
 * @return i32
 */
#[no_mangle]
export function seed_platform_coff_write_coff_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  unsafe {
    return seed_platform_coff_write_coff_o_to_buf_impl(elf_ctx, out_buf);
  }
  return 0 - 1;
}

/**
 * Whether SHUX_ASM_DEBUG is set (user-asm seed bridge debug gate).
 * wave236 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * @return i32 — 1 if env present (any value), 0 otherwise
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl
 */
#[no_mangle]
export function seed_asm_debug_enabled(): i32 {
  unsafe {
    // wave236 G.7: SHUX_ASM_DEBUG via link_abi_getenv (not raw getenv / not *_impl).
    let e: *u8 = link_abi_getenv("SHUX_ASM_DEBUG");
    if (e != 0 as *u8) {
      return 1;
    }
  }
  return 0;
}

/**
 * Whether SHUX_ASM_EMIT_TRACE is set (user-asm emit-trace gate).
 * wave236 G.7: env via public pure thin link_abi_getenv (not raw libc getenv).
 * @return i32 — 1 if env present (any value), 0 otherwise
 * PLATFORM: SHARED — host residual only link_abi_getenv_impl
 */
#[no_mangle]
export function seed_asm_emit_trace_enabled(): i32 {
  unsafe {
    // wave236 G.7: SHUX_ASM_EMIT_TRACE via link_abi_getenv (not raw getenv / not *_impl).
    let e: *u8 = link_abi_getenv("SHUX_ASM_EMIT_TRACE");
    if (e != 0 as *u8) {
      return 1;
    }
  }
  return 0;
}

// seed_elf_ctx_code_len: see function docblock below.

/** Exported function `seed_elf_ctx_code_len`.
 * Query helper `seed_elf_ctx_code_len`.
 * @param elf_ctx *u8
 * @return i32
 */
#[no_mangle]
export function seed_elf_ctx_code_len(elf_ctx: *u8): i32 {
  if (elf_ctx == 0) { return 0; }
  unsafe {
    let p: *i32 = elf_ctx as *i32;
    return p[0];
  }
  return 0;
}
