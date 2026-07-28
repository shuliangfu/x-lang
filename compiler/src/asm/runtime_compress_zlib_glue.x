// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 migration of runtime_compress_zlib_glue: zlib macro wrapper stubs.
//
// Architecture (thin + rest):
//   - thin (.x): public deflateInit2 / inflateInit2 wrappers (#[no_mangle] so
//     the symbol name matches what libz.x extern function expects — no _c
//     suffix). Each wrapper forwards to a C-side _impl_c bridge.
//   - rest (.from_x.c): deflateInit2_impl_c / inflateInit2_impl_c bridges
//     that #include <zlib.h>, #undef the macros, and call the real
//     deflateInit2_ / inflateInit2_ functions with ZLIB_VERSION and
//     sizeof(z_stream) arguments (the macro expansion the wrappers replace).
//
// Why thin+rest (not DIRECT): the wrappers must #include <zlib.h> to obtain
// ZLIB_VERSION, z_stream layout, and the deflateInit2_ / inflateInit2_ symbol
// declarations. .x cannot #include C headers. The thin side exposes the
// public symbols (no _c suffix to match libz.x extern declarations); the
// rest side keeps the zlib.h dependency.
//
// PLATFORM: SHARED — zlib is platform-portable; no OS-specific code.
// Build: standalone .o (not embedded in composite rule).

// runtime_compress_zlib_glue_x_doc_anchor: see function docblock below.

/** Exported function `runtime_compress_zlib_glue_x_doc_anchor`.
 * Anchor for codegen discovery of this TU. Returns 0.
 * @return i32 always 0
 */
export function runtime_compress_zlib_glue_x_doc_anchor(): i32 {
  return 0;
}

// ---------------------------------------------------------------------------
// Bridge declarations for the rest-side _impl functions. The rest side
// #include <zlib.h> and calls the real deflateInit2_ / inflateInit2_.
// ---------------------------------------------------------------------------

export extern "C" function deflateInit2_impl_c(strm: *u8, level: i32, method: i32, windowBits: i32, memLevel: i32, strategy: i32): i32;
export extern "C" function inflateInit2_impl_c(strm: *u8, windowBits: i32): i32;

// ---------------------------------------------------------------------------
// Public zlib macro wrappers. #[no_mangle] ensures the symbol name is
// `deflateInit2` / `inflateInit2` (no _c suffix), matching the extern
// declarations in std/compress/gzip/libz.x.
// ---------------------------------------------------------------------------

/**
 * Wraps the zlib deflateInit2 macro. Forwards to deflateInit2_impl_c which
 * #include <zlib.h> and calls deflateInit2_ with ZLIB_VERSION and
 * sizeof(z_stream).
 *
 * 【Why 根源】zlib.h 中 deflateInit2 是宏，展开为 deflateInit2_（带
 * ZLIB_VERSION 和 sizeof(z_stream) 参数）。XLANG 生成 C 不包含 zlib.h，
 * 直接调用 deflateInit2 链接器找不到符号。此 wrapper 提供与 libz.x
 * extern 声明同名的真实函数符号。
 *
 * @param strm pointer to z_stream (ZStream in libz.x, void* here to avoid
 *             cross-TU type mismatch warnings)
 * @param level compression level
 * @param method compression method
 * @param windowBits window size
 * @param memLevel memory level
 * @param strategy compression strategy
 * @return zlib error code (Z_OK on success)
 */
#[no_mangle]
export function deflateInit2(strm: *u8, level: i32, method: i32, windowBits: i32, memLevel: i32, strategy: i32): i32 {
  unsafe { return deflateInit2_impl_c(strm, level, method, windowBits, memLevel, strategy); }
}

/**
 * Wraps the zlib inflateInit2 macro. Forwards to inflateInit2_impl_c which
 * #include <zlib.h> and calls inflateInit2_ with ZLIB_VERSION and
 * sizeof(z_stream).
 *
 * 【Why 根源】同 deflateInit2；inflateInit2 宏展开为 inflateInit2_。
 *
 * @param strm pointer to z_stream (ZStream in libz.x, void* here)
 * @param windowBits window size
 * @return zlib error code (Z_OK on success)
 */
#[no_mangle]
export function inflateInit2(strm: *u8, windowBits: i32): i32 {
  unsafe { return inflateInit2_impl_c(strm, windowBits); }
}
