// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// wave758 Class I: host OS/arch lit for cfg_eval product Rung0 — pure-asm only.
// Companion to cfg_eval.x (export-extern cfg_host_*_lit). Product ladder
// prefers `-backend asm -c` of this file + ld -r (no host-cc of
// seeds/cfg_eval_host_lit.from_x.c when xlang_asm present).
//
// wave98: multi-#[cfg] same-name under -E-extern is illegal C — this TU is NOT
// on the -E path (cold fallback still uses the C seed). Values match
// seeds/cfg_eval_host_lit.from_x.c. Global *u8 string lits (not stack arrays /
// not same-name overload returns) so pure-asm keeps bare cfg_host_* names and
// embeds cstring data.
// PLATFORM: SHARED — Darwin + Ubuntu L2.

#[cfg(target_os = "linux")]
let CFG_HOST_OS_LIT: *u8 = "linux";
#[cfg(target_os = "macos")]
let CFG_HOST_OS_LIT: *u8 = "macos";
#[cfg(target_os = "windows")]
let CFG_HOST_OS_LIT: *u8 = "windows";
#[cfg(target_os = "freebsd")]
let CFG_HOST_OS_LIT: *u8 = "freebsd";
#[cfg(not(target_os = "linux"))]
#[cfg(not(target_os = "macos"))]
#[cfg(not(target_os = "windows"))]
#[cfg(not(target_os = "freebsd"))]
let CFG_HOST_OS_LIT: *u8 = "unknown";

#[cfg(target_arch = "aarch64")]
let CFG_HOST_ARCH_LIT: *u8 = "aarch64";
#[cfg(target_arch = "x86_64")]
let CFG_HOST_ARCH_LIT: *u8 = "x86_64";
#[cfg(target_arch = "riscv64")]
let CFG_HOST_ARCH_LIT: *u8 = "riscv64";
#[cfg(not(target_arch = "aarch64"))]
#[cfg(not(target_arch = "x86_64"))]
#[cfg(not(target_arch = "riscv64"))]
let CFG_HOST_ARCH_LIT: *u8 = "unknown";

/**
 * Host target_os literal ("linux" / "macos" / "windows" / "freebsd" / "unknown").
 * @return *u8 — NUL-terminated static string; never null
 */
#[no_mangle]
export function cfg_host_os_lit(): *u8 {
  return CFG_HOST_OS_LIT;
}

/**
 * Host target_arch literal ("x86_64" / "aarch64" / "riscv64" / "unknown").
 * @return *u8 — NUL-terminated static string; never null
 */
#[no_mangle]
export function cfg_host_arch_lit(): *u8 {
  return CFG_HOST_ARCH_LIT;
}
