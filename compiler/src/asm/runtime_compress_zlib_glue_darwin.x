// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// runtime_compress_zlib_glue_darwin.x — Darwin arm64 bridges for
// runtime_compress_zlib_glue.o.
//
// The cold ensure path pure-asms src/asm/runtime_compress_zlib_glue.x
// (the public deflateInit2 / inflateInit2 wrappers) and this file
// (the two _impl bridges), then ld -r. It does not pass
// seeds/runtime_compress_zlib_glue.from_x.c to host cc.
// Linux keeps the seed, which includes that platform's zlib.h.
// Windows keeps the seed the same way.
//
// zlib.h turns deflateInit2 / inflateInit2 into macros that call
// deflateInit2_ / inflateInit2_ with ZLIB_VERSION and sizeof(z_stream).
// This compiler cannot include that header. The two constants were
// measured against the SDK libz that `clang -lz` links on this host:
// ZLIB_VERSION is "1.2.12" and sizeof(z_stream) is 112. A different
// SDK zlib needs those two literals updated together.
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Real zlib deflate initializer. The public name deflateInit2 is a
 * macro in zlib.h; this is the symbol libz exports.
 * @param strm *u8 — z_stream, caller owns
 * @param level i32 — compression level
 * @param method i32 — Z_DEFLATED
 * @param windowBits i32 — window size
 * @param memLevel i32 — memory level
 * @param strategy i32 — strategy
 * @param version *u8 — ZLIB_VERSION of the linked libz
 * @param stream_size i32 — sizeof(z_stream)
 * @return i32 — zlib status, 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function deflateInit2_(strm: *u8, level: i32, method: i32, windowBits: i32, memLevel: i32, strategy: i32, version: *u8, stream_size: i32): i32;

/**
 * Real zlib inflate initializer.
 * @param strm *u8 — z_stream, caller owns
 * @param windowBits i32 — window size
 * @param version *u8 — ZLIB_VERSION of the linked libz
 * @param stream_size i32 — sizeof(z_stream)
 * @return i32 — zlib status, 0 on success
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function inflateInit2_(strm: *u8, windowBits: i32, version: *u8, stream_size: i32): i32;

/**
 * Forward deflateInit2 to deflateInit2_ with the Darwin SDK version
 * and the 112-byte z_stream size.
 * @param strm *u8 — z_stream, null is forwarded to libz
 * @param level i32 — compression level
 * @param method i32 — method
 * @param windowBits i32 — window size
 * @param memLevel i32 — memory level
 * @param strategy i32 — strategy
 * @return i32 — zlib status
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function deflateInit2_impl_c(strm: *u8, level: i32, method: i32, windowBits: i32, memLevel: i32, strategy: i32): i32 {
  unsafe {
    return deflateInit2_(strm, level, method, windowBits, memLevel, strategy, "1.2.12", 112);
  }
}

/**
 * Forward inflateInit2 to inflateInit2_ with the Darwin SDK version
 * and the 112-byte z_stream size.
 * @param strm *u8 — z_stream, null is forwarded to libz
 * @param windowBits i32 — window size
 * @return i32 — zlib status
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function inflateInit2_impl_c(strm: *u8, windowBits: i32): i32 {
  unsafe {
    return inflateInit2_(strm, windowBits, "1.2.12", 112);
  }
}
