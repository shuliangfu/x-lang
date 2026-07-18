// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L9 thin gate / null-check forward layer (G.9 English; body is authoritative).
// link_abi L9 thin gate / null-check forward layer (G.9 English; body is authoritative).
// link_abi L9 thin gate / null-check forward layer (G.9 English; body is authoritative).
//
// link_abi L9 thin gate / null-check forward layer (G.9 English; body is authoritative).
//   shux_asm_ld_bank_push / shux_invoke_cc
//   shux_asm_ld_append_mach_tail_libs / shux_asm_ld_append_unix_gcc_tail_libs
//   shux_append_linux_link_harden / shux_invoke_ld_for_exe
//   labi_gates_count
// link_abi L9 thin gate / null-check forward layer (G.9 English; body is authoritative).
//
// link_abi L9 thin gate / null-check forward layer (G.9 English; body is authoritative).
// link_abi L9 thin gate / null-check forward layer (G.9 English; body is authoritative).

export extern "C" function shux_asm_ld_bank_push_impl(b: *u8, path: *u8): *u8;
export extern "C" function shux_append_linux_link_harden_impl(argv: *u8, la: *i32, cap: i32): void;
export extern "C" function shux_invoke_ld_for_exe_impl(
  o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32,
  link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32
): i32;
export extern "C" function shux_invoke_cc_impl(
  c_paths: *u8, n: i32, out_path: *u8, target: *u8, opt_level: *u8, use_lto: i32,
  io_o: *u8, fs_o: *u8, process_o: *u8, string_o: *u8, heap_o: *u8, path_o: *u8, runtime_o: *u8,
  runtime_panic_o: *u8, net_o: *u8, thread_o: *u8, time_o: *u8, random_o: *u8, env_o: *u8,
  sync_o: *u8, encoding_o: *u8, base64_o: *u8, crypto_o: *u8, log_o: *u8, atomic_o: *u8,
  channel_o: *u8, backtrace_o: *u8, hash_o: *u8, math_o: *u8, sort_o: *u8, ffi_o: *u8,
  db_o: *u8, elf_o: *u8, json_o: *u8, csv_o: *u8, regex_o: *u8, compress_o: *u8, unicode_o: *u8,
  dynlib_o: *u8, http_o: *u8, tar_o: *u8, simd_o: *u8, context_o: *u8, datetime_o: *u8,
  uuid_o: *u8, url_o: *u8, cli_o: *u8, security_o: *u8, config_o: *u8, cache_o: *u8,
  trace_o: *u8, task_o: *u8, schema_o: *u8, test_o: *u8, include_root: *u8, async_scheduler_o: *u8
): i32;
export extern "C" function shux_asm_ld_append_mach_tail_libs_impl(
  compress_o: *u8, user_o: *u8, flags: *u8, argv: *u8, la: *i32, max_la: i32, append_lsystem: i32
): void;
export extern "C" function shux_asm_ld_append_unix_gcc_tail_libs_impl(
  compress_o: *u8, user_o: *u8, flags: *u8, need_pt: i32, argv: *u8, la: *i32, max_la: i32
): void;

/** Exported function `shux_asm_ld_bank_push`.
 * Implements `shux_asm_ld_bank_push`.
 * @param b *u8
 * @param path *u8
 * @return *u8
 */
#[no_mangle]
export function shux_asm_ld_bank_push(b: *u8, path: *u8): *u8 {
  if (b == 0 as *u8) { return 0 as *u8; }
  if (path == 0 as *u8) { return 0 as *u8; }
  if (path[0] == 0) { return 0 as *u8; }
  unsafe { return shux_asm_ld_bank_push_impl(b, path); }
  return 0 as *u8;
}

/** Function `shux_invoke_cc`.
 * Purpose: implements `shux_invoke_cc`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function shux_invoke_cc(
  c_paths: *u8, n: i32, out_path: *u8, target: *u8, opt_level: *u8, use_lto: i32,
  io_o: *u8, fs_o: *u8, process_o: *u8, string_o: *u8, heap_o: *u8, path_o: *u8, runtime_o: *u8,
  runtime_panic_o: *u8, net_o: *u8, thread_o: *u8, time_o: *u8, random_o: *u8, env_o: *u8,
  sync_o: *u8, encoding_o: *u8, base64_o: *u8, crypto_o: *u8, log_o: *u8, atomic_o: *u8,
  channel_o: *u8, backtrace_o: *u8, hash_o: *u8, math_o: *u8, sort_o: *u8, ffi_o: *u8,
  db_o: *u8, elf_o: *u8, json_o: *u8, csv_o: *u8, regex_o: *u8, compress_o: *u8, unicode_o: *u8,
  dynlib_o: *u8, http_o: *u8, tar_o: *u8, simd_o: *u8, context_o: *u8, datetime_o: *u8,
  uuid_o: *u8, url_o: *u8, cli_o: *u8, security_o: *u8, config_o: *u8, cache_o: *u8,
  trace_o: *u8, task_o: *u8, schema_o: *u8, test_o: *u8, include_root: *u8, async_scheduler_o: *u8
): i32 {
  if (c_paths == 0 as *u8) { return 0 - 1; }
  if (out_path == 0 as *u8) { return 0 - 1; }
  unsafe {
    return shux_invoke_cc_impl(
      c_paths, n, out_path, target, opt_level, use_lto,
      io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o,
      runtime_panic_o, net_o, thread_o, time_o, random_o, env_o,
      sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o,
      channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o,
      db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o,
      dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o,
      uuid_o, url_o, cli_o, security_o, config_o, cache_o,
      trace_o, task_o, schema_o, test_o, include_root, async_scheduler_o
    );
  }
  return 0 - 1;
}

/** Function `shux_asm_ld_append_mach_tail_libs`.
 * Purpose: implements `shux_asm_ld_append_mach_tail_libs`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function shux_asm_ld_append_mach_tail_libs(
  compress_o: *u8, user_o: *u8, flags: *u8, argv: *u8, la: *i32, max_la: i32, append_lsystem: i32
): void {
  if (flags == 0 as *u8) { return; }
  if (argv == 0 as *u8) { return; }
  if (la == 0 as *i32) { return; }
  if (la[0] < 0) { return; }
  unsafe {
    shux_asm_ld_append_mach_tail_libs_impl(compress_o, user_o, flags, argv, la, max_la, append_lsystem);
  }
}

/** Function `shux_asm_ld_append_unix_gcc_tail_libs`.
 * Purpose: implements `shux_asm_ld_append_unix_gcc_tail_libs`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function shux_asm_ld_append_unix_gcc_tail_libs(
  compress_o: *u8, user_o: *u8, flags: *u8, need_pt: i32, argv: *u8, la: *i32, max_la: i32
): void {
  if (flags == 0 as *u8) { return; }
  if (argv == 0 as *u8) { return; }
  if (la == 0 as *i32) { return; }
  if (la[0] < 0) { return; }
  unsafe {
    shux_asm_ld_append_unix_gcc_tail_libs_impl(compress_o, user_o, flags, need_pt, argv, la, max_la);
  }
}

/** Exported function `shux_append_linux_link_harden`.
 * Implements `shux_append_linux_link_harden`.
 * @param argv *u8
 * @param la *i32
 * @param cap i32
 * @return void
 */
#[no_mangle]
export function shux_append_linux_link_harden(argv: *u8, la: *i32, cap: i32): void {
  if (argv == 0 as *u8) { return; }
  if (la == 0 as *i32) { return; }
  unsafe {
    shux_append_linux_link_harden_impl(argv, la, cap);
  }
}

/** Function `shux_invoke_ld_for_exe`.
 * Purpose: implements `shux_invoke_ld_for_exe`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function shux_invoke_ld_for_exe(
  o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32,
  link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32
): i32 {
  if (o_path == 0 as *u8) { return 0 - 1; }
  if (exe_path == 0 as *u8) { return 0 - 1; }
  unsafe {
    return shux_invoke_ld_for_exe_impl(
      o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots
    );
  }
  return 0 - 1;
}

/** Exported function `labi_gates_count`.
 * Implements `labi_gates_count`.
 * @return i32
 */
#[no_mangle]
export function labi_gates_count(): i32 {
  return 6;
}
