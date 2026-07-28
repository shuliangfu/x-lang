// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 migration of runtime_ed25519_ref10_glue: Ed25519 ref10 public API
// wrappers for the 3 .x-consumed entry points.
//
// Architecture (thin + rest):
//   - thin (.x): #[no_mangle] ed25519_ref10_create_keypair / _sign / _verify
//     wrappers (no _c suffix to match ed25519.x extern declarations). Each
//     wrapper forwards to a C-side _impl_c bridge emitted by the .inc files
//     (via macro rename in .from_x.c).
//   - rest (.from_x.c): includes 8 .inc files (sha512/fe/ge/sc/keypair/sign/
//     verify + fixedint.h) that emit ed25519_ref10_*_impl_c implementations.
//     Also emits ed25519_ref10_sha512* directly (NOT wrapped here — consumed
//     by runtime_crypto_inc_glue.from_x.c, a C-to-C cross-module reference).
//
// Why thin+rest (not DIRECT): the .inc files are pure C with macros, internal
// helpers (fe_*/ge_*/sc_*), and platform-portable but .x-inexpressible code.
// The thin side exposes only the 3 public entry points consumed by ed25519.x;
// the rest side keeps the full ref10 implementation.
//
// Why only 3 wrappers (not sha512): ed25519_ref10_sha512 is consumed by
// runtime_crypto_inc_glue.from_x.c (a .c file), not by any .x file. It stays
// in .from_x.c (emitted by sha512.inc via macro rename) so the C extern
// declaration links directly. Wrapping it in .x would add indirection without
// .x-level benefit.
//
// PLATFORM: SHARED — ref10 is portable C; no OS-specific code.
// Build: standalone .o (not embedded in composite rule).

// runtime_ed25519_ref10_glue_x_doc_anchor: see function docblock below.

/** Exported function `runtime_ed25519_ref10_glue_x_doc_anchor`.
 * Anchor for codegen discovery of this TU. Returns 0.
 * @return i32 always 0
 */
export function runtime_ed25519_ref10_glue_x_doc_anchor(): i32 {
  return 0;
}

// ---------------------------------------------------------------------------
// Bridge declarations for the rest-side _impl functions. The rest side
// #includes the .inc files which emit *_impl_c via macro rename.
// ---------------------------------------------------------------------------

export extern "C" function ed25519_ref10_create_keypair_impl_c(public_key: *u8, private_key: *u8, seed: *u8): void;

export extern "C" function ed25519_ref10_sign_impl_c(signature: *u8, message: *u8, message_len: usize, public_key: *u8, private_key: *u8): void;

export extern "C" function ed25519_ref10_verify_impl_c(signature: *u8, message: *u8, message_len: usize, public_key: *u8): i32;

// ---------------------------------------------------------------------------
// Public Ed25519 ref10 entry points. #[no_mangle] ensures the symbol name is
// `ed25519_ref10_create_keypair` / `_sign` / `_verify` (no _c suffix),
// matching the extern declarations in std/crypto/ed25519.x.
// ---------------------------------------------------------------------------

/**
 * Wraps the ref10 create_keypair. Forwards to
 * ed25519_ref10_create_keypair_impl_c emitted by keypair.inc (via macro
 * rename in .from_x.c).
 *
 * 【Why 根源】.inc 文件经 #define ed25519_create_keypair →
 * ed25519_ref10_create_keypair_impl_c 重命名后发射 _impl_c 实现符号；
 * 公开符号 ed25519_ref10_create_keypair 需由 thin (.x) 提供，被
 * ed25519.x extern 引用。
 *
 * @param public_key output 32-byte public key buffer
 * @param private_key output 64-byte private key buffer
 * @param seed input 32-byte seed
 */
#[no_mangle]
export function ed25519_ref10_create_keypair(public_key: *u8, private_key: *u8, seed: *u8): void {
  unsafe { ed25519_ref10_create_keypair_impl_c(public_key, private_key, seed); }
}

/**
 * Wraps the ref10 sign. Forwards to ed25519_ref10_sign_impl_c emitted by
 * sign.inc (via macro rename in .from_x.c).
 *
 * 【Why 根源】同 create_keypair；sign.inc 经宏重命名发射 _impl_c。
 *
 * @param signature output 64-byte signature buffer
 * @param message input message bytes (may be null if message_len is 0)
 * @param message_len message length in bytes
 * @param public_key input 32-byte public key
 * @param private_key input 64-byte private key
 */
#[no_mangle]
export function ed25519_ref10_sign(signature: *u8, message: *u8, message_len: usize, public_key: *u8, private_key: *u8): void {
  unsafe { ed25519_ref10_sign_impl_c(signature, message, message_len, public_key, private_key); }
}

/**
 * Wraps the ref10 verify. Forwards to ed25519_ref10_verify_impl_c emitted by
 * verify.inc (via macro rename in .from_x.c).
 *
 * 【Why 根源】同 create_keypair；verify.inc 经宏重命名发射 _impl_c。
 *
 * @param signature input 64-byte signature to verify
 * @param message input message bytes (may be null if message_len is 0)
 * @param message_len message length in bytes
 * @param public_key input 32-byte public key
 * @return 1 if signature is valid, 0 otherwise
 */
#[no_mangle]
export function ed25519_ref10_verify(signature: *u8, message: *u8, message_len: usize, public_key: *u8): i32 {
  unsafe { return ed25519_ref10_verify_impl_c(signature, message, message_len, public_key); }
}
