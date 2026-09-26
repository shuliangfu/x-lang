// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// build_tool_libc_bridge_darwin.x — Darwin arm64 body of
// build_tool_libc_bridge.o.
//
// Shell commands go through system. A null or empty command returns -1.
// build_run_asm_build always runs sh scripts/g05_build_xlang_asm.sh.
// build_copy_xlang_asm copies xlang onto xlang_asm and ignores a
// failing first copy. argv bytes are copied with one loop.
// Linux and Windows keep the C seed.
// PLATFORM: MACOS|DARWIN arm64.

extern function system(cmd: *u8): i32;
extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

/**
 * Anchor for this Darwin build-tool bridge.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function build_tool_libc_bridge_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Call host system once.
 * @param cmd command string
 * @return i32 — system status
 * PLATFORM: MACOS|DARWIN
 */
function bt_system(cmd: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = system(cmd);
  }
  return n;
}

/**
 * Host system with no empty-command gate.
 * @param cmd command, may be null
 * @return i32 — system status
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function link_abi_system_impl(cmd: *u8): i32 {
  return bt_system(cmd);
}

/**
 * Read the first byte of a command.
 * @param cmd command pointer
 * @return u8 — that byte
 * PLATFORM: MACOS|DARWIN
 */
function bt_first(cmd: *u8): u8 {
  let p: *u8 = cmd;
  return p[0];
}

/**
 * Public shell face. Null or empty returns -1.
 * @param cmd NUL-terminated command
 * @return i32 — -1 or system status
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function link_abi_system(cmd: *u8): i32 {
  if (cmd == 0) {
    return 0 - 1;
  }
  if (bt_first(cmd) == 0) {
    return 0 - 1;
  }
  return link_abi_system_impl(cmd);
}

/**
 * Build-tool shell entry. Forwards to the public face.
 * @param cmd NUL-terminated command
 * @return i32 — link_abi_system status
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function build_exec_system(cmd: *u8): i32 {
  return link_abi_system(cmd);
}

/**
 * Load argv[i]. Each slot is 8 bytes.
 * @param argv pointer to the argv vector
 * @param i index
 * @return *u8 — that C string, or null
 * PLATFORM: MACOS|DARWIN
 */
function bt_argv_at(argv: *u8, i: i32): *u8 {
  let off: i32 = i * 8;
  let slot: *u8 = argv + off;
  let v: *u8 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, slot, 8);
  }
  return v;
}

/**
 * Copy a C string into buf, leaving room for NUL.
 * One loop. The written length does not include the NUL.
 * @param src source string
 * @param buf destination
 * @param max destination capacity, including NUL
 * @return i32 — bytes copied before NUL
 * PLATFORM: MACOS|DARWIN
 */
function bt_copy(src: *u8, buf: *u8, max: i32): i32 {
  let n: i32 = max - 1;
  let j: i32 = 0;
  while (j < n) {
    let sp: *u8 = src + j;
    let b: u8 = sp[0];
    if (b == 0) {
      let term: *u8 = buf + j;
      term[0] = 0;
      return j;
    }
    let dp: *u8 = buf + j;
    dp[0] = b;
    j = j + 1;
  }
  let endp: *u8 = buf + j;
  endp[0] = 0;
  return j;
}

/**
 * Copy argv[i] into buf. Bad arguments return -1.
 * @param argc argument count
 * @param argv argument vector
 * @param i index
 * @param buf destination
 * @param max destination capacity
 * @return i32 — copied length, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function driver_get_argv_i(argc: i32, argv: *u8, i: i32, buf: *u8, max: i32): i32 {
  if (argv == 0) {
    return 0 - 1;
  }
  if (buf == 0) {
    return 0 - 1;
  }
  if (max <= 0) {
    return 0 - 1;
  }
  if (i < 0) {
    return 0 - 1;
  }
  if (i >= argc) {
    return 0 - 1;
  }
  let s: *u8 = bt_argv_at(argv, i);
  if (s == 0) {
    return 0 - 1;
  }
  return bt_copy(s, buf, max);
}

/**
 * Run the single asm-build script. xlang_path is kept for the caller ABI.
 * @param xlang_path unused path argument
 * @return i32 — 0 when the script status is 0, else -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function build_run_asm_build(xlang_path: *u8): i32 {
  let keep: *u8 = xlang_path;
  if (keep == keep) {
    let rc: i32 = build_exec_system("sh scripts/g05_build_xlang_asm.sh");
    if (rc != 0) {
      return 0 - 1;
    }
  }
  return 0;
}

/**
 * Copy xlang onto xlang_asm. A failing first copy still returns 0.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function build_copy_xlang_asm(): i32 {
  let rc: i32 = build_exec_system("cp -f xlang xlang_asm 2>/dev/null; true");
  if (rc != 0) {
    return 0;
  }
  let ignored: i32 = build_exec_system("test -f xlang && test -f xlang_asm && cp -f xlang xlang_asm");
  if (ignored == ignored) {
    return 0;
  }
  return 0;
}
