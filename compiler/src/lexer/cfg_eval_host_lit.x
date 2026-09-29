// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// wave851: sole bodies of cfg_host_os_lit and cfg_host_arch_lit.
// Companion to cfg_eval.x (export-extern cfg_host_*_lit). The product
// ladder pure-asms this file and ld -r's it next to cfg_eval.x.
// seeds/cfg_eval_host_lit.from_x.c is deleted. There is no host-cc
// fallback and this TU is not on the gcc -E path.
//
// w1534: a file-scope *u8 string literal is parked in the first
// function. cfg_host_os_lit stored both "macos" and "aarch64" and
// returned the os pointer; cfg_host_arch_lit only loaded the unused
// stack slot and depended on that residue surviving. A larger caller
// frame (the lexer-step bridge) overwrites the slot and cfg_strlen
// walks 0x310027f648. Each literal is now a cfg-selected byte array
// with its own data symbol, and each function loads that symbol.
// Stack arrays would dangle after return. Same-name #[cfg] functions
// dual-emit on the Darwin image that still has the stack-slot lit, so
// the cfg stays on the arrays.
// #[cfg(not(...))] on this TU SIGSEGVs the Darwin compiler (rc 139).
// #[cfg(target_arch = ...)] SIGSEGVs the Ubuntu image whose
// cfg_host_arch_lit is still that stack slot: this file is compiled
// by that image, so the arch bytes are selected by target_os. The
// product pairs are linux/x86_64, windows/x86_64, macos/aarch64,
// freebsd/x86_64. A linux riscv64 host is not one of those pairs.
// PLATFORM: SHARED.

#[cfg(target_os = "linux")]
let CFG_HOST_OS_LIT: u8[6] = [108, 105, 110, 117, 120, 0];
#[cfg(target_os = "macos")]
let CFG_HOST_OS_LIT: u8[6] = [109, 97, 99, 111, 115, 0];
#[cfg(target_os = "windows")]
let CFG_HOST_OS_LIT: u8[8] = [119, 105, 110, 100, 111, 119, 115, 0];
#[cfg(target_os = "freebsd")]
let CFG_HOST_OS_LIT: u8[8] = [102, 114, 101, 101, 98, 115, 100, 0];

#[cfg(target_os = "linux")]
let CFG_HOST_ARCH_LIT: u8[7] = [120, 56, 54, 95, 54, 52, 0];
#[cfg(target_os = "macos")]
let CFG_HOST_ARCH_LIT: u8[8] = [97, 97, 114, 99, 104, 54, 52, 0];
#[cfg(target_os = "windows")]
let CFG_HOST_ARCH_LIT: u8[7] = [120, 56, 54, 95, 54, 52, 0];
#[cfg(target_os = "freebsd")]
let CFG_HOST_ARCH_LIT: u8[7] = [120, 56, 54, 95, 54, 52, 0];

/**
 * Host target_os literal ("linux" / "macos" / "windows" / "freebsd").
 * @return *u8 — NUL-terminated static bytes; never null. The pointer
 *   addresses CFG_HOST_OS_LIT, not a stack temporary.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function cfg_host_os_lit(): *u8 {
  return &CFG_HOST_OS_LIT[0];
}

/**
 * Host target_arch literal for the product pair of this OS
 * ("x86_64" on linux, windows, and freebsd; "aarch64" on macos).
 * @return *u8 — NUL-terminated static bytes; never null. The pointer
 *   addresses CFG_HOST_ARCH_LIT. It must not reuse cfg_host_os_lit's frame.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function cfg_host_arch_lit(): *u8 {
  return &CFG_HOST_ARCH_LIT[0];
}
