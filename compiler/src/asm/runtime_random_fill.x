// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_random_fill.x — Darwin arm64 user-domain CSPRNG fill.
//
// This is the whole product body of runtime_random_fill.o on Darwin arm64.
// The cold ensure path pure-asms this file and does not pass the C seed to
// host cc. Linux and Windows still compile seeds/runtime_random_fill.from_x.c:
// Linux uses the raw getrandom syscall in include/xlang_random_cap.h, and
// Windows uses BCryptGenRandom. That header function is static inline, so
// it is not a linkable symbol this object can call.
//
// Darwin product bytes come from libSystem getentropy, in chunks of at most
// 256. The return contract matches the header: full length on success, 0 for
// a zero length, -1 for a null buffer or a negative length, and a partial
// count when a later chunk fails after some bytes were written.
//
// Public names stay strong. random_fill_bytes_c is the symbol std/random and
// std/uuid undefined-reference. random_get_alg stays a null stub, which is
// what the non-Windows C seed returned. The C _impl bridges are not emitted
// here; nothing outside this TU referenced them.
//
// This object is a user / STD_AND_PANIC companion. It is not in the g05
// compiler image. A missing object after a pure-asm fault falls back to the
// C seed, which still uses the raw Darwin syscall.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * libSystem getentropy. One call accepts at most 256 bytes.
 * @param buf *u8 — destination; caller owns; must not be null for a positive length
 * @param n usize — byte count for this call; 1 through 256
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN — libSystem, not the raw syscall in xlang_random_cap.h
 */
export extern "C" function getentropy(buf: *u8, n: usize): i32;

/**
 * Read path helper for codegen discovery.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_random_fill_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Non-Windows BCrypt handle. Darwin has no BCrypt provider, so this is null.
 * @return *u8 — always null on Darwin
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function random_get_alg(): *u8 {
  return 0;
}

/**
 * Fill buf with len crypto-secure bytes.
 * Null or a negative length returns -1. A zero length returns 0 and does
 * not call getentropy. Longer requests are split into 256-byte chunks.
 * A chunk failure returns how many bytes were already written, or -1 when
 * the first chunk failed.
 * @param buf *u8 — destination buffer; null is rejected
 * @param len i32 — byte count; negative is rejected; zero is a no-op
 * @return i32 — len on full success, 0 when len is 0, a partial count, or -1
 * PLATFORM: MACOS|DARWIN — libSystem getentropy, chunk cap 256
 */
#[no_mangle]
export function random_fill_bytes_c(buf: *u8, len: i32): i32 {
  if (buf == 0 || len < 0) {
    return -1;
  }
  if (len == 0) {
    return 0;
  }
  let done: i32 = 0;
  while (done < len) {
    let chunk: i32 = len - done;
    // getentropy rejects a length above 256. Match GETENTROPY_MAX.
    if (chunk > 256) {
      chunk = 256;
    }
    let rc: i32 = 0;
    unsafe {
      rc = getentropy(&buf[done], chunk as usize);
    }
    if (rc != 0) {
      if (done > 0) {
        return done;
      }
      return -1;
    }
    done = done + chunk;
  }
  return len;
}
