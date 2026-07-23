// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

export extern "C" function main_entry(argc: i32, argv: *u8): i32;
export extern "C" function shux_link_obj_needs_undef_sym_impl(user_o: *u8, sym: *u8): i32;
export extern "C" function getenv(name: *u8): *u8;
export extern "C" function shux_host_is_linux(): i32;
export extern "C" function shux_host_is_apple_aarch64(): i32;
export extern "C" function driver_argv_at(argv: *u8, i: i32): *u8;
export extern "C" function shux_path_is_nonempty_regular_file_impl(path: *u8): i32;
export extern "C" function link_abi_obj_exports_marker_impl(obj_o: *u8, marker: *u8): i32;
export extern "C" function link_abi_obj_has_undef_sym_impl(obj_o: *u8, sym: *u8): i32;
export extern "C" function link_abi_generated_c_contains_substr(c_path: *u8, needle: *u8): i32;
export extern "C" function shux_empty_cstr(): *u8;
export extern "C" function shux_asm_ld_bank_push_impl(b: *u8, path: *u8): *u8;
export extern "C" function shux_runtime_asm_io_stubs_o_path_impl(argv0: *u8): *u8;
export extern "C" function shux_runtime_process_argv_o_path_impl(argv0: *u8): *u8;
export extern "C" function shux_asm_ld_effective_link_argv0_impl(link_argv0: *u8, syn_buf: *u8, syn_sz: i32): *u8;
export extern "C" function shux_invoke_ld_for_exe_impl(o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32, link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32): i32;
export extern "C" function shux_asm_ld_append_mach_tail_libs_impl(compress_o: *u8, user_o: *u8, flags: *u8, argv: *u8, la: *i32, max_la: i32, append_lsystem: i32): void;
export extern "C" function shux_asm_ld_append_unix_gcc_tail_libs_impl(compress_o: *u8, user_o: *u8, flags: *u8, need_pt: i32, argv: *u8, la: *i32, max_la: i32): void;
export extern "C" function shux_ensure_runtime_arrow_simd_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_asm_io_stubs_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_atomic_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_backtrace_platform_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_channel_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_compress_zlib_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_crypto_inc_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_dynlib_os_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_ed25519_ref10_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_env_os_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_heap_user_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_http_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_kv_mmap_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_log_os_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_math_libm_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_net_udp_batch_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_net_workers_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_panic_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_process_argv_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_process_os_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_queue_contention_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_random_fill_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_scheduler_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_sqlite_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_sync_lock_diag_tls_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_sync_os_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_test_fn_invoke_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_thread_glue_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_time_os_o_impl(argv0: *u8): i32;
export extern "C" function shux_ensure_runtime_tls_mbedtls_bio_o_impl(argv0: *u8): i32;

export extern "C" function link_diag_tool_status_impl(tool: *u8, status: i32): void;
export extern "C" function link_diag_runtime_source_missing_impl(obj_name: *u8, source_path: *u8): void;
export extern "C" function link_diag_runtime_source_missing_under_impl(obj_name: *u8, base_dir: *u8, suffix: *u8): void;
export extern "C" function link_diag_runtime_obj_missing_impl(obj_name: *u8, out_o: *u8): void;
export extern "C" function link_diag_runtime_obj_resolve_fail_impl(obj_name: *u8, hint: *u8): void;
export extern "C" function link_diag_runtime_obj_build_status_impl(obj_name: *u8, status: i32): void;
export extern "C" function link_diag_errno_impl(kind: *u8, op: *u8): void;
export extern "C" function link_diag_errno_path_impl(kind: *u8, op: *u8, path: *u8): void;
export extern "C" function link_diag_freestanding_missing_impl(obj_name: *u8, symbol_name: *u8): void;
export extern "C" function link_diag_freestanding_unsupported_impl(): void;
export extern "C" function link_diag_ld_debug_push_impl(rel: *u8, stage: *u8, path: *u8): void;
export extern "C" function link_diag_ld_debug_argv_impl(label: *u8, argv: *u8): void;
export extern "C" function shux_asm_ld_lib_root_ptr_usable_impl(p: *u8): i32;
export extern "C" function shux_asm_ld_lib_root_default_impl(root_buf: *u8): void;
export extern "C" function shux_linux_host_gcc_path_impl(): *u8;
export extern "C" function shux_linux_ld_child_path_impl(): void;

export extern "C" function shux_runtime_o_realpath_if_exists_impl(path: *u8, resolved: *u8): *u8;
export extern "C" function shux_runtime_compiler_o_path_copy_impl(argv0: *u8, leaf: *u8, out: *u8, out_sz: i64): i32;
export extern "C" function link_abi_link_needs_heap_user_c_impl(user_o: *u8, argv: *u8, la: i32): i32;
export extern "C" function link_abi_link_needs_std_heap_import_impl(user_o: *u8, argv: *u8, la: i32): i32;
export extern "C" function link_abi_asm_ld_argv_has_obj_impl(argv: *u8, la: i32, path: *u8): i32;
export extern "C" function link_abi_asm_ld_argv_push_stable_impl(bank: *u8, argv: *u8, la: *i32, max_la: i32, p: *u8): void;
export extern "C" function link_abi_asm_ld_push_obj_impl(primary: *u8, link_argv0: *u8, rel: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flag_out: *i32): i32;

export extern "C" function shux_cc_compile_sync_impl(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32): i32;
export extern "C" function shux_spawn_sync_impl(prog: *u8, argv: *u8): i32;
export extern "C" function shux_link_perror_impl(msg: *u8): void;
export extern "C" function ld_append_brew_lib_paths_impl(argv: *u8, la: *i32, max_la: i32): void;
export extern "C" function link_abi_generated_c_contains_any_substr_impl(c_path: *u8, needles: *u8, n_needles: i32): i32;
export extern "C" function link_abi_asm_ld_push_glue_after_std_impl(have_std: i32, ensure_fn: *u8, glue_primary: *u8, link_argv0: *u8, glue_rel: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32): void;
export extern "C" function link_abi_asm_ld_push_minimal_runtime_objs_impl(link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32): void;

export extern "C" function shux_cc_compile_sync_ex_impl(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32, extra_flags: *u8): i32;
export extern "C" function shux_asm_nostdlib_minimal_selfcontained_exe_link_impl(o_path: *u8, exe_path: *u8, link_eff: *u8, lib_roots: *u8, n_lib_roots: i32): i32;

/** Exported function `shux_forward_main_to_main_entry`.
 * Implements `shux_forward_main_to_main_entry`.
 * @param argc i32
 * @param argv *u8
 * @return i32
 */
#[no_mangle]
export function shux_forward_main_to_main_entry(argc: i32, argv: *u8): i32 {
  unsafe {
    let r: i32 = main_entry(argc, argv);
    return r;
  }
  return 0;
}

/** Exported function `shux_freestanding_user_o_needs_panic`.
 * Memory management helper `shux_freestanding_user_o_needs_panic`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function shux_freestanding_user_o_needs_panic(user_o: *u8): i32 {
  unsafe {
    let r: i32 = shux_link_obj_needs_undef_sym_impl(user_o, "shux_panic_");
    return r;
  }
  return 0;
}

/** Exported function `shux_freestanding_user_o_needs_io`.
 * Memory management helper `shux_freestanding_user_o_needs_io`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function shux_freestanding_user_o_needs_io(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_write") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_read") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_close") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_exit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_open") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_openat") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_mmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_munmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_socket") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_connect") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_bind") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_listen") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_sys_accept") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `invoke_cc_skip_native_tuning`.
 * Implements `invoke_cc_skip_native_tuning`.
 * @return i32
 */
#[no_mangle]
export function invoke_cc_skip_native_tuning(): i32 {
  unsafe {
    let a: *u8 = getenv("CI");
    if (a != 0 as *u8) {
      return 1;
    }
    let b: *u8 = getenv("SHUX_CI_DOCKER");
    if (b != 0 as *u8) {
      return 1;
    }
    let c: *u8 = getenv("SHUX_NO_MARCH_NATIVE");
    if (c != 0 as *u8) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shux_link_freestanding_enabled(driver_freestanding: i32): i32 {
  unsafe {
    if (shux_host_is_linux() == 0) {
      return 0;
    }
    if (driver_freestanding != 0) {
      return 1;
    }
    let e: *u8 = getenv("SHUX_FREESTANDING");
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    /* See implementation. */
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function link_abi_user_o_needs_libc_heap(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym_impl(user_o, "malloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "calloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "realloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "free") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "posix_memalign") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "getenv") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** True when user.o has U refs to std.map formal exports (empty_size + Map surface).
 * PLATFORM: SHARED — must stay aligned with seeds/runtime_link_abi.from_x.c. */
#[no_mangle]
export function link_abi_user_o_needs_std_map(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_empty_size") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_new_Map_i32_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_with_capacity_Map_i32_i32_ptr_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_insert_Map_i32_i32_ptr_i32_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_get_Map_i32_i32_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_find_Map_i32_i32_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_deinit_Map_i32_i32_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_str_new") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_map_str_insert") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** True when user.o has U refs to std.set formal overload mangles (not stale set_i32_*).
 * PLATFORM: SHARED — seed + this .x must stay same-commit. */
#[no_mangle]
export function link_abi_user_o_needs_std_set(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_new_i32_retSet_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_new_i32_retSet_u64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_with_capacity_Set_i32_ptr_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_insert_Set_i32_ptr_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_insert_Set_u64_ptr_u64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_contains_key_Set_i32_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_contains_key_Set_u64_u64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_remove_Set_i32_ptr_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_remove_Set_u64_ptr_u64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_len_Set_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_len_Set_u64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_deinit_Set_i32_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_deinit_Set_u64_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_str_new") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_str_insert") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_set_i32_insert") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_set_i32_contains") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_set_i32_remove") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_set_i32_len") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_set_set_i32_deinit") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** True when user.o has U refs to product std.queue APIs (tests/queue surface).
 * PLATFORM: SHARED — complements labi_od_queue_sym contention table. */
#[no_mangle]
export function link_abi_user_o_needs_std_queue(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_new_retQueue_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_new_retQueue_u8") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_push_back_Queue_i32_ptr_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_push_back_Queue_u8_ptr_u8") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_push_front") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_pop_front_Queue_i32_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_pop_back") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_get") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_len_Queue_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_is_empty_Queue_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_deinit_Queue_i32_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_queue_with_capacity") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_std_test`.
 * Implements `link_abi_user_o_needs_std_test`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_std_test(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "test_call_i32_void_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "test_runner_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "test_expect_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "test_bench_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "test_f_test_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "test_io_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "test_fuzz_") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_core_mem`.
 * Implements `link_abi_user_o_needs_core_mem`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_core_mem(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_mem_align_up") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_mem_align_down") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_mem_mem_copy") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_mem_mem_set") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_mem_mem_zero") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_mem_mem_move") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_mem_mem_compare") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_core_slice`.
 * Implements `link_abi_user_o_needs_core_slice`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_core_slice(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_slice_i32_from_ptr_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_subslice_i32_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_slice_u8_from_ptr_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_subslice_u8_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_slice_u64_from_ptr_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "core_subslice_u64_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_std_heap_page_mmap`.
 * Implements `link_abi_user_o_needs_std_heap_page_mmap`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_std_heap_page_mmap(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_page_mmap_page_mmap_heap_available") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_page_mmap_page_mmap_heap_init") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_page_mmap_page_mmap_heap_alloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_page_mmap_page_mmap_heap_deinit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_page_mmap_page_mmap_heap_free") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_std_sys_linux`.
 * Implements `link_abi_user_o_needs_std_sys_linux`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_std_sys_linux(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_linux_linux_syscall_invoke_available") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_linux_linux_anonymous_mmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_linux_linux_syscall_munmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_linux_linux_syscall_read") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_linux_linux_syscall_write") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_linux_linux_syscall_close") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_linux_linux_syscall_exit") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_std_sys`.
 * Implements `link_abi_user_o_needs_std_sys`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_std_sys(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_write_stdout") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_write_stderr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_write") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_read") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_close") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_exit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_freestanding_write_available") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_sys_linux_syscall_table_available") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_std_net`.
 * Implements `link_abi_user_o_needs_std_net`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_std_net(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_net_listen") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_net_connect") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_net_udp_bind") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_net_udp_recv_many_buf") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_net_udp_send_many_buf") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_net_addr_to_u32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_net_close_udp") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_stream_write_batch_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_tcp_connect_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_tcp_listen_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_udp_bind_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_udp_recv_many_buf_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_udp_send_many_buf_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_close_socket_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_udp_send_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_dns_resolve_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "net_sock_create_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}


/* See implementation. */

#[no_mangle]
export function link_abi_user_o_needs_std_heap_api(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_alloc_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_alloc_u8") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_free_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_free_u8") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_alloc_size_zero") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_alloc_usize") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_free_u8_ptr") != 0) {
      return 1;
    }
    /* Formal std/vec/vec.o Allocator/default/kind family — keep seed probes in sync (G.7). */
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_default_alloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_kind_arena") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_alloc_Allocator_usize") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_realloc_Allocator_u8_ptr_usize") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_free_Allocator_u8_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_arena64_alloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_arena64_alloc_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_alloc_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_free_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_alloc_aligned_c") != 0) {
      return 1;
    }
    /* Typed libc heap surface used by formal set/map/queue/vec .o. */
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_alloc_i32_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_alloc_u8_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_alloc_u64_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_free_i32_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_free_u8_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_free_u64_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_map_find") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "std_heap_libc_heap_copy_u8_at_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_heap_user_syms`.
 * Implements `link_abi_user_o_needs_heap_user_syms`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_heap_user_syms(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "heap_alloc_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "heap_free_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "heap_realloc_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "heap_arena64_alloc_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function link_abi_user_o_needs_async_scheduler(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_coop_pingpong") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_coop_pingpong_jmp") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_cps_suspend") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_asm_frame_phase_by_id") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_asm_frame_store_from_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_asm_frame_load_to_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_asm_frame_reset_by_id") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_cps_suspend_io") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_task_submit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_task_submit_to") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_scheduler_drain") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_worker_drain") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_worker_count") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_worker_pending") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_queue_reset") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_scheduler_pending") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_io_wake_all") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_io_waiters_pending") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_io_completions_ready") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_set_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_reset") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_push_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_push_u32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_push_i64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_valid") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_take_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_take_u32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_async_run_seed_take_i64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_io_submit_read_async") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_io_complete_read_async") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_io_complete_read_async_slot") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_io_submit_write_async") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_io_complete_write_async") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym_impl(user_o, "shux_io_complete_write_async_slot") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}


/* See implementation. */

#[no_mangle]
export function link_abi_obj_needs_zlib(obj_o: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (obj_o[0] == 0) {
      return 0;
    }
    if (link_abi_obj_exports_marker(obj_o, "shu_compress_zlib_marker") != 0) {
      return 1;
    }
    if (link_abi_obj_has_undef_sym(obj_o, "_compress2") != 0) {
      return 1;
    }
    if (link_abi_obj_has_undef_sym(obj_o, "_deflate") != 0) {
      return 1;
    }
    if (link_abi_obj_has_undef_sym(obj_o, "_inflate") != 0) {
      return 1;
    }
    if (link_abi_obj_has_undef_sym(obj_o, "_uncompress") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_obj_needs_zstd`.
 * Implements `link_abi_obj_needs_zstd`.
 * @param obj_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_obj_needs_zstd(obj_o: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (obj_o[0] == 0) {
      return 0;
    }
    if (link_abi_obj_exports_marker(obj_o, "shu_compress_zstd_marker") != 0) {
      return 1;
    }
    if (link_abi_obj_has_undef_sym(obj_o, "ZSTD_") != 0) {
      return 1;
    }
    if (link_abi_obj_has_undef_sym(obj_o, "_ZSTD") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_obj_needs_brotli`.
 * Implements `link_abi_obj_needs_brotli`.
 * @param obj_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_obj_needs_brotli(obj_o: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (obj_o[0] == 0) {
      return 0;
    }
    if (link_abi_obj_exports_marker(obj_o, "shu_compress_brotli_marker") != 0) {
      return 1;
    }
    if (link_abi_obj_has_undef_sym(obj_o, "BrotliEncoderCompress") != 0) {
      return 1;
    }
    if (link_abi_obj_has_undef_sym(obj_o, "BrotliDecoderDecompress") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_user_o_needs_compress_libs`.
 * Implements `link_abi_user_o_needs_compress_libs`.
 * @param user_o *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_user_o_needs_compress_libs(user_o: *u8): i32 {
  unsafe {
    if (link_abi_obj_needs_zlib(user_o) != 0) {
      return 1;
    }
    if (link_abi_obj_needs_zstd(user_o) != 0) {
      return 1;
    }
    if (link_abi_obj_needs_brotli(user_o) != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function link_abi_generated_c_needs_core_builtin(c_path: *u8): i32 {
  return 0;
}

/** Exported function `link_abi_generated_c_needs_core_mem`.
 * Implements `link_abi_generated_c_needs_core_mem`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_core_mem(c_path: *u8): i32 {
  return 0;
}

/** Exported function `link_abi_generated_c_needs_libc_heap`.
 * Implements `link_abi_generated_c_needs_libc_heap`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_libc_heap(c_path: *u8): i32 {
  /* See implementation. */
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "malloc") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "calloc") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "realloc") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "posix_memalign") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "heap_alloc_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "heap_free_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "heap_realloc_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "heap_alloc_zeroed_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "getenv") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_win32`.
 * Implements `link_abi_generated_c_needs_win32`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_win32(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "GetStdHandle") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "WriteFile") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "CreateFileA") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "ReadFile") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "CloseHandle") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "ExitProcess") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "win32_write") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "win32_read_file_into") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "win32_exit_process") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_win32_wsa`.
 * Implements `link_abi_generated_c_needs_win32_wsa`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_win32_wsa(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "WSAStartup") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "WSACleanup") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "win32_net_available") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_db_kv`.
 * Implements `link_abi_generated_c_needs_db_kv`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_db_kv(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "db_kv_open_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "db_kv_put_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "db_kv_get_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "db_kv_append_ts_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "db_kv_wal_flush_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "db_kv_compact_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "db_kv_sst_level_count_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_db_arrow`.
 * Implements `link_abi_generated_c_needs_db_arrow`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_db_arrow(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "arrow_column_") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "arrow_batch_") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "arrow_smoke_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_core_slice`.
 * Implements `link_abi_generated_c_needs_core_slice`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_core_slice(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "core_slice_i32_from_ptr_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "core_subslice_i32_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "core_slice_u8_from_ptr_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "core_subslice_u8_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "core_slice_u64_from_ptr_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "core_subslice_u64_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_fs`.
 * Implements `link_abi_generated_c_needs_fs`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_fs(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "fs_open_read_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "fs_last_error_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "fs_close_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "fs_read_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "fs_write_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_zlib`.
 * Implements `link_abi_generated_c_needs_zlib`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_zlib(c_path: *u8): i32 {
  /* See implementation. */
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "_compress2") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "_deflate") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "_inflate") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "_uncompress") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "compress2") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "deflateInit") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "inflateInit") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_zstd`.
 * Implements `link_abi_generated_c_needs_zstd`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_zstd(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "ZSTD_compress") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "ZSTD_decompress") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "ZSTD_create") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "ZSTD_free") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "ZSTD_isError") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_brotli`.
 * Implements `link_abi_generated_c_needs_brotli`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_brotli(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "BrotliEncoder") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "BrotliDecoder") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_random`.
 * Implements `link_abi_generated_c_needs_random`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_random(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "random_rng_smoke_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "random_fill_bytes_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "random_u64_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_time`.
 * Implements `link_abi_generated_c_needs_time`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_time(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "std_time_now_monotonic_ns") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "std_time_sleep_ms") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "std_time_duration_ns") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "std_time_now_wall_ns") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "std_time_format_timezone_smoke") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "time_now_monotonic_ns_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "time_sleep_ms_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "time_duration_ns_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "time_now_wall_ns_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "time_format_timezone_smoke_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `link_abi_generated_c_needs_runtime`.
 * Implements `link_abi_generated_c_needs_runtime`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_needs_runtime(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "runtime_crash_evidence_collect_c") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "runtime_panic") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "runtime_abort") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Exported function `shux_generated_c_needs_async_scheduler`.
 * Implements `shux_generated_c_needs_async_scheduler`.
 * @param c_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_generated_c_needs_async_scheduler(c_path: *u8): i32 {
  unsafe {
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_run_i32") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_cps_suspend") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_task_submit") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_run_seed_") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_coop_pingpong_jmp") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_coop_pingpong") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_run_drain_until_idle") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_queue_reset") != 0) {
      return 1;
    }
    if (link_abi_generated_c_contains_substr(c_path, "shux_async_bind_context_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}
/* See implementation. */

#[no_mangle]
export function asm_link_obj_skip_missing(path: *u8): *u8 {
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    if (path[0] == 0) {
      return 0 as *u8;
    }
    if (shux_path_is_nonempty_regular_file(path) == 0) {
      return 0 as *u8;
    }
    return path;
  }
  return 0 as *u8;
}

/* See implementation. */

#[no_mangle]
export function driver_get_argv_i(argc: i32, argv: *u8, i: i32, buf: *u8, max: i32): i32 {
  if (argv == 0 as *u8) {
    return 0 - 1;
  }
  if (buf == 0 as *u8) {
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
  unsafe {
    let s: *u8 = driver_argv_at(argv, i);
    if (s == 0 as *u8) {
      return 0 - 1;
    }
    let r: i32 = driver_copy_cstr_n(s, buf, max);
    return r;
  }
  return 0 - 1;
}

/* See implementation. */

#[no_mangle]
export function driver_resolve_target_arch(parsed_target: i32, saw_target_flag: i32): i32 {
  if (saw_target_flag != 0) {
    return parsed_target;
  }
  unsafe {
    if (shux_host_is_apple_aarch64() != 0) {
      return 1;
    }
    return parsed_target;
  }
  return parsed_target;
}

/** Exported function `bootstrap_init_static_tls`.
 * Implements `bootstrap_init_static_tls`.
 * @return void
 */
#[no_mangle]
export function bootstrap_init_static_tls(): void {
}

/** Exported function `bootstrap_init_environ`.
 * Implements `bootstrap_init_environ`.
 * @param argc i32
 * @param argv *u8
 * @return void
 */
#[no_mangle]
export function bootstrap_init_environ(argc: i32, argv: *u8): void {
}

/** Exported function `bootstrap_nostdlib_pthread_is_stub`.
 * Read path helper `bootstrap_nostdlib_pthread_is_stub`.
 * Returns 1 when pthread large-stack path is unavailable (stub or crashes),
 * forcing driver_run_thread_on_large_stack to use current-thread path.
 * PLATFORM: SHARED — POSIX returns 0 (real pthread supports 256MiB custom
 * stack); WINDOWS returns 1 (winpthreads crash with posix_memalign'd
 * 256MiB stack during pthread_join cleanup). See seed
 * seeds/runtime_link_abi.from_x.c for #ifdef _WIN32 branch.
 * @return i32
 */
#[no_mangle]
export function bootstrap_nostdlib_pthread_is_stub(): i32 {
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shux_std_io_o_path(argv0: *u8): *u8 {
  unsafe {
    return shux_empty_cstr();
  }
  return 0 as *u8;
}

/** Exported function `shux_std_compress_o_path`.
 * Implements `shux_std_compress_o_path`.
 * @param argv0 *u8
 * @return *u8
 */
#[no_mangle]
export function shux_std_compress_o_path(argv0: *u8): *u8 {
  unsafe {
    return shux_empty_cstr();
  }
  return 0 as *u8;
}

/* See implementation. */

#[no_mangle]
export function shux_asm_ld_effective_link_argv0(link_argv0: *u8, syn_buf: *u8, syn_sz: i32): *u8 {
  unsafe {
    return shux_asm_ld_effective_link_argv0_impl(link_argv0, syn_buf, syn_sz);
  }
  return 0 as *u8;
}

/* See implementation. */

#[no_mangle]
export function shux_asm_ld_bank_push(b: *u8, path: *u8): *u8 {
  if (b == 0 as *u8) {
    return 0 as *u8;
  }
  if (path == 0 as *u8) {
    return 0 as *u8;
  }
  unsafe {
    if (path[0] == 0) {
      return 0 as *u8;
    }
    return shux_asm_ld_bank_push_impl(b, path);
  }
  return 0 as *u8;
}

/* See implementation. */

#[no_mangle]
export function shux_runtime_asm_io_stubs_o_path(argv0: *u8): *u8 {
  unsafe {
    return shux_runtime_asm_io_stubs_o_path_impl(argv0);
  }
  return 0 as *u8;
}

/** Exported function `shux_runtime_process_argv_o_path`.
 * Implements `shux_runtime_process_argv_o_path`.
 * @param argv0 *u8
 * @return *u8
 */
#[no_mangle]
export function shux_runtime_process_argv_o_path(argv0: *u8): *u8 {
  unsafe {
    return shux_runtime_process_argv_o_path_impl(argv0);
  }
  return 0 as *u8;
}

/* See implementation. */

/* See implementation. */
#[no_mangle]
export function shux_output_is_elf_o(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  unsafe {
    let n: i64 = 0;
    while (path[n] != 0) {
      n = n + 1;
    }
    /* ".o" / ".O" */
    if (n >= 2) {
      if (path[n - 2] == 46) {
        if (path[n - 1] == 111) {
          return 1;
        }
        if (path[n - 1] == 79) {
          return 1;
        }
      }
    }
    /* ".obj" */
    if (n >= 4) {
      if (path[n - 4] == 46) {
        if (path[n - 3] == 111) {
          if (path[n - 2] == 98) {
            if (path[n - 1] == 106) {
              return 1;
            }
          }
        }
      }
    }
    return 0;
  }
  return 0;
}

/* See implementation. */
#[no_mangle]
export function shux_output_want_exe(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (path[0] == 0) {
      return 0;
    }
    let n: i64 = 0;
    while (path[n] != 0) {
      n = n + 1;
    }
    /* ".o" / ".O" */
    if (n >= 2) {
      if (path[n - 2] == 46) {
        if (path[n - 1] == 111) {
          return 0;
        }
        if (path[n - 1] == 79) {
          return 0;
        }
        /* ".s" */
        if (path[n - 1] == 115) {
          return 0;
        }
      }
    }
    /* ".obj" */
    if (n >= 4) {
      if (path[n - 4] == 46) {
        if (path[n - 3] == 111) {
          if (path[n - 2] == 98) {
            if (path[n - 1] == 106) {
              return 0;
            }
          }
        }
      }
    }
    return 1;
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shux_path_is_nonempty_regular_file(path: *u8): i32 {
  if (path == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (path[0] == 0) {
      return 0;
    }
    return shux_path_is_nonempty_regular_file_impl(path);
  }
  return 0;
}

/* See implementation. */
#[no_mangle]
export function link_abi_ld_argv_entry_is_obj(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (s[0] == 0) {
      return 0;
    }
    let n: i64 = 0;
    while (s[n] != 0) {
      n = n + 1;
    }
    if (n >= 2) {
      if (s[n - 2] == 46) {
        if (s[n - 1] == 111) {
          return 1;
        }
      }
    }
    if (n >= 4) {
      if (s[n - 4] == 46) {
        if (s[n - 3] == 111) {
          if (s[n - 2] == 98) {
            if (s[n - 1] == 106) {
              return 1;
            }
          }
        }
      }
    }
    return 0;
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shux_invoke_ld_for_exe(o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32, link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32): i32 {
  if (o_path == 0 as *u8) {
    return 0 - 1;
  }
  if (exe_path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_invoke_ld_for_exe_impl(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots);
  }
  return 0 - 1;
}

/** Exported function `shux_asm_ld_append_mach_tail_libs`.
 * Implements `shux_asm_ld_append_mach_tail_libs`.
 * @param compress_o *u8
 * @param user_o *u8
 * @param flags *u8
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @param append_lsystem i32
 * @return void
 */
#[no_mangle]
export function shux_asm_ld_append_mach_tail_libs(compress_o: *u8, user_o: *u8, flags: *u8, argv: *u8, la: *i32, max_la: i32, append_lsystem: i32): void {
  if (flags == 0 as *u8) {
    return;
  }
  if (argv == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  unsafe {
    if (*la < 0) {
      return;
    }
    shux_asm_ld_append_mach_tail_libs_impl(compress_o, user_o, flags, argv, la, max_la, append_lsystem);
  }
}

/** Exported function `shux_asm_ld_append_unix_gcc_tail_libs`.
 * Implements `shux_asm_ld_append_unix_gcc_tail_libs`.
 * @param compress_o *u8
 * @param user_o *u8
 * @param flags *u8
 * @param need_pt i32
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @return void
 */
#[no_mangle]
export function shux_asm_ld_append_unix_gcc_tail_libs(compress_o: *u8, user_o: *u8, flags: *u8, need_pt: i32, argv: *u8, la: *i32, max_la: i32): void {
  if (flags == 0 as *u8) {
    return;
  }
  if (argv == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  unsafe {
    if (*la < 0) {
      return;
    }
    shux_asm_ld_append_unix_gcc_tail_libs_impl(compress_o, user_o, flags, need_pt, argv, la, max_la);
  }
}

export extern "C" function shux_ensure_crt0_user_o_impl(argv0: *u8, driver_freestanding: i32): i32;

export extern "C" function shux_ensure_freestanding_io_o_impl(argv0: *u8, driver_freestanding: i32): i32;
export extern "C" function shu_waitpid_retry_impl(pid: i64, status_out: *i32): i32;
export extern "C" function shux_asm_user_o_has_undef_syms_impl(o_path: *u8): i32;
export extern "C" function asm_ld_append_compress_libs_impl(compress_o: *u8, user_o: *u8, argv: *u8, la: *i32, max_la: i32): void;
export extern "C" function invoke_cc_append_compress_ld_impl(argv: *u8, i: *i32, argv_cap: i32, compress_o: *u8, user_o: *u8): void;
export extern "C" function invoke_cc_argv_push_existing_impl(argv: *u8, ia: *i32, max_ia: i32, path: *u8): i32;
export extern "C" function shux_asm_ld_prepare_for_exe_link_impl(link_eff: *u8, user_o: *u8, driver_freestanding: i32, use_macho_o: i32, use_coff_o: i32): i32;

/* See implementation. */

#[no_mangle]
export function shux_ensure_runtime_arrow_simd_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_arrow_simd_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_asm_io_stubs_o`.
 * Implements `shux_ensure_runtime_asm_io_stubs_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_asm_io_stubs_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_asm_io_stubs_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_atomic_glue_o`.
 * Implements `shux_ensure_runtime_atomic_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_atomic_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_atomic_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_backtrace_platform_o`.
 * Implements `shux_ensure_runtime_backtrace_platform_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_backtrace_platform_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_backtrace_platform_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_channel_glue_o`.
 * Implements `shux_ensure_runtime_channel_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_channel_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_channel_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_compress_zlib_glue_o`.
 * Implements `shux_ensure_runtime_compress_zlib_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_compress_zlib_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_compress_zlib_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_crypto_inc_glue_o`.
 * Implements `shux_ensure_runtime_crypto_inc_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_crypto_inc_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_crypto_inc_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_dynlib_os_o`.
 * Implements `shux_ensure_runtime_dynlib_os_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_dynlib_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_dynlib_os_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_ed25519_ref10_glue_o`.
 * Implements `shux_ensure_runtime_ed25519_ref10_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_ed25519_ref10_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_ed25519_ref10_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_env_os_o`.
 * Implements `shux_ensure_runtime_env_os_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_env_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_env_os_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_heap_user_o`.
 * Implements `shux_ensure_runtime_heap_user_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_heap_user_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_heap_user_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_http_glue_o`.
 * Implements `shux_ensure_runtime_http_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_http_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_http_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_kv_mmap_glue_o`.
 * Implements `shux_ensure_runtime_kv_mmap_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_kv_mmap_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_kv_mmap_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_log_os_o`.
 * Implements `shux_ensure_runtime_log_os_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_log_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_log_os_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_math_libm_o`.
 * Implements `shux_ensure_runtime_math_libm_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_math_libm_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_math_libm_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_net_udp_batch_o`.
 * Implements `shux_ensure_runtime_net_udp_batch_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_net_udp_batch_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_net_udp_batch_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_net_workers_o`.
 * Implements `shux_ensure_runtime_net_workers_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_net_workers_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_net_workers_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_panic_o`.
 * Implements `shux_ensure_runtime_panic_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_panic_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_panic_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_process_argv_o`.
 * Implements `shux_ensure_runtime_process_argv_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_process_argv_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_process_argv_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_process_os_glue_o`.
 * Implements `shux_ensure_runtime_process_os_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_process_os_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_process_os_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_queue_contention_o`.
 * Implements `shux_ensure_runtime_queue_contention_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_queue_contention_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_queue_contention_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_random_fill_o`.
 * Implements `shux_ensure_runtime_random_fill_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_random_fill_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_random_fill_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_scheduler_glue_o`.
 * Implements `shux_ensure_runtime_scheduler_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_scheduler_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_scheduler_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_sqlite_glue_o`.
 * Implements `shux_ensure_runtime_sqlite_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_sqlite_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_sqlite_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_sync_lock_diag_tls_o`.
 * Implements `shux_ensure_runtime_sync_lock_diag_tls_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_sync_lock_diag_tls_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_sync_lock_diag_tls_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_sync_os_o`.
 * Implements `shux_ensure_runtime_sync_os_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_sync_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_sync_os_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_test_fn_invoke_o`.
 * Implements `shux_ensure_runtime_test_fn_invoke_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_test_fn_invoke_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_test_fn_invoke_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_thread_glue_o`.
 * Read path helper `shux_ensure_runtime_thread_glue_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_thread_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_thread_glue_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_time_os_o`.
 * Implements `shux_ensure_runtime_time_os_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_time_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_time_os_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_runtime_tls_mbedtls_bio_o`.
 * Implements `shux_ensure_runtime_tls_mbedtls_bio_o`.
 * @param argv0 *u8
 * @return i32
 */
#[no_mangle]
export function shux_ensure_runtime_tls_mbedtls_bio_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_tls_mbedtls_bio_o_impl(argv0);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_crt0_user_o`.
 * Implements `shux_ensure_crt0_user_o`.
 * @param argv0 *u8
 * @param driver_freestanding i32
 * @return i32
 */
#[no_mangle]
export function shux_ensure_crt0_user_o(argv0: *u8, driver_freestanding: i32): i32 {
  unsafe {
    return shux_ensure_crt0_user_o_impl(argv0, driver_freestanding);
  }
  return 0 - 1;
}

/** Exported function `shux_ensure_freestanding_io_o`.
 * Memory management helper `shux_ensure_freestanding_io_o`.
 * @param argv0 *u8
 * @param driver_freestanding i32
 * @return i32
 */
#[no_mangle]
export function shux_ensure_freestanding_io_o(argv0: *u8, driver_freestanding: i32): i32 {
  unsafe {
    return shux_ensure_freestanding_io_o_impl(argv0, driver_freestanding);
  }
  return 0 - 1;
}

export extern "C" function shu_resolve_compiler_dir_impl(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32;
export extern "C" function shux_asm_invoke_ld_platform_impl(o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32, link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, driver_freestanding: i32): i32;
export extern "C" function shux_asm_ld_append_std_objs_impl(link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flags: *u8): void;
export extern "C" function shux_asm_ld_append_on_demand_user_objs_impl(link_argv0: *u8, user_o: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flags: *u8): void;
export extern "C" function invoke_cc_append_net_tls_ld_impl(argv: *u8, i: *i32, argv_cap: i32, net_o: *u8, repo_root: *u8): i32;
export extern "C" function ensure_std_net_o_auto_tls_impl(repo_root: *u8): void;

/* See implementation. */

#[no_mangle]
export function shu_waitpid_retry(pid: i64, status_out: *i32): i32 {
  unsafe {
    return shu_waitpid_retry_impl(pid, status_out);
  }
  return 0 - 1;
}

/** Exported function `shux_asm_user_o_has_undef_syms`.
 * Implements `shux_asm_user_o_has_undef_syms`.
 * @param o_path *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_user_o_has_undef_syms(o_path: *u8): i32 {
  if (o_path == 0 as *u8) {
    return 1;
  }
  unsafe {
    return shux_asm_user_o_has_undef_syms_impl(o_path);
  }
  return 1;
}

/** Exported function `asm_ld_append_compress_libs`.
 * Implements `asm_ld_append_compress_libs`.
 * @param compress_o *u8
 * @param user_o *u8
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @return void
 */
#[no_mangle]
export function asm_ld_append_compress_libs(compress_o: *u8, user_o: *u8, argv: *u8, la: *i32, max_la: i32): void {
  if (argv == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  unsafe {
    asm_ld_append_compress_libs_impl(compress_o, user_o, argv, la, max_la);
  }
}

/** Exported function `invoke_cc_append_compress_ld`.
 * Implements `invoke_cc_append_compress_ld`.
 * @param argv *u8
 * @param i *i32
 * @param argv_cap i32
 * @param compress_o *u8
 * @param user_o *u8
 * @return void
 */
#[no_mangle]
export function invoke_cc_append_compress_ld(argv: *u8, i: *i32, argv_cap: i32, compress_o: *u8, user_o: *u8): void {
  if (argv == 0 as *u8) {
    return;
  }
  if (i == 0 as *i32) {
    return;
  }
  unsafe {
    invoke_cc_append_compress_ld_impl(argv, i, argv_cap, compress_o, user_o);
  }
}

/** Exported function `invoke_cc_argv_push_existing`.
 * Implements `invoke_cc_argv_push_existing`.
 * @param argv *u8
 * @param ia *i32
 * @param max_ia i32
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function invoke_cc_argv_push_existing(argv: *u8, ia: *i32, max_ia: i32, path: *u8): i32 {
  if (argv == 0 as *u8) {
    return 0;
  }
  if (ia == 0 as *i32) {
    return 0;
  }
  unsafe {
    return invoke_cc_argv_push_existing_impl(argv, ia, max_ia, path);
  }
  return 0;
}

/** Exported function `shux_asm_ld_prepare_for_exe_link`.
 * Implements `shux_asm_ld_prepare_for_exe_link`.
 * @param link_eff *u8
 * @param user_o *u8
 * @param driver_freestanding i32
 * @param use_macho_o i32
 * @param use_coff_o i32
 * @return i32
 */
#[no_mangle]
export function shux_asm_ld_prepare_for_exe_link(link_eff: *u8, user_o: *u8, driver_freestanding: i32, use_macho_o: i32, use_coff_o: i32): i32 {
  if (link_eff == 0 as *u8) {
    return 0 - 1;
  }
  if (user_o == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_asm_ld_prepare_for_exe_link_impl(link_eff, user_o, driver_freestanding, use_macho_o, use_coff_o);
  }
  return 0 - 1;
}

export extern "C" function shux_invoke_cc_impl(c_paths: *u8, n: i32, out_path: *u8, target: *u8, opt_level: *u8, use_lto: i32, io_o: *u8, fs_o: *u8, process_o: *u8, string_o: *u8, heap_o: *u8, path_o: *u8, runtime_o: *u8, runtime_panic_o: *u8, net_o: *u8, thread_o: *u8, time_o: *u8, random_o: *u8, env_o: *u8, sync_o: *u8, encoding_o: *u8, base64_o: *u8, crypto_o: *u8, log_o: *u8, atomic_o: *u8, channel_o: *u8, backtrace_o: *u8, hash_o: *u8, math_o: *u8, sort_o: *u8, ffi_o: *u8, db_o: *u8, elf_o: *u8, json_o: *u8, csv_o: *u8, regex_o: *u8, compress_o: *u8, unicode_o: *u8, dynlib_o: *u8, http_o: *u8, tar_o: *u8, simd_o: *u8, context_o: *u8, datetime_o: *u8, uuid_o: *u8, url_o: *u8, cli_o: *u8, security_o: *u8, config_o: *u8, cache_o: *u8, trace_o: *u8, task_o: *u8, schema_o: *u8, test_o: *u8, include_root: *u8, async_scheduler_o: *u8): i32;
export extern "C" function shux_append_linux_link_harden_impl(argv: *u8, la: *i32, cap: i32): void;

/* See implementation. */

#[no_mangle]
export function shu_resolve_compiler_dir(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32 {
  if (out_dir == 0 as *u8) {
    return 0 - 1;
  }
  if (out_dir_sz == 0) {
    return 0 - 1;
  }
  unsafe {
    return shu_resolve_compiler_dir_impl(argv0, out_dir, out_dir_sz);
  }
  return 0 - 1;
}

/** Exported function `shux_asm_invoke_ld_platform`.
 * Implements `shux_asm_invoke_ld_platform`.
 * @param o_path *u8
 * @param exe_path *u8
 * @param target *u8
 * @param use_macho_o i32
 * @param use_coff_o i32
 * @param link_argv0 *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param driver_freestanding i32
 * @return i32
 */
#[no_mangle]
export function shux_asm_invoke_ld_platform(o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32, link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, driver_freestanding: i32): i32 {
  if (o_path == 0 as *u8) {
    return 0 - 1;
  }
  if (exe_path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_asm_invoke_ld_platform_impl(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots, driver_freestanding);
  }
  return 0 - 1;
}

/** Exported function `shux_asm_ld_append_std_objs`.
 * Implements `shux_asm_ld_append_std_objs`.
 * @param link_argv0 *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param bank *u8
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @param flags *u8
 * @return void
 */
#[no_mangle]
export function shux_asm_ld_append_std_objs(link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flags: *u8): void {
  if (argv == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  if (flags == 0 as *u8) {
    return;
  }
  unsafe {
    shux_asm_ld_append_std_objs_impl(link_argv0, lib_roots, n_lib_roots, bank, argv, la, max_la, flags);
  }
}

/** Exported function `shux_asm_ld_append_on_demand_user_objs`.
 * Implements `shux_asm_ld_append_on_demand_user_objs`.
 * @param link_argv0 *u8
 * @param user_o *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param bank *u8
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @param flags *u8
 * @return void
 */
#[no_mangle]
export function shux_asm_ld_append_on_demand_user_objs(link_argv0: *u8, user_o: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flags: *u8): void {
  if (user_o == 0 as *u8) {
    return;
  }
  if (argv == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  if (flags == 0 as *u8) {
    return;
  }
  unsafe {
    shux_asm_ld_append_on_demand_user_objs_impl(link_argv0, user_o, lib_roots, n_lib_roots, bank, argv, la, max_la, flags);
  }
}

/** Exported function `invoke_cc_append_net_tls_ld`.
 * Implements `invoke_cc_append_net_tls_ld`.
 * @param argv *u8
 * @param i *i32
 * @param argv_cap i32
 * @param net_o *u8
 * @param repo_root *u8
 * @return i32
 */
#[no_mangle]
export function invoke_cc_append_net_tls_ld(argv: *u8, i: *i32, argv_cap: i32, net_o: *u8, repo_root: *u8): i32 {
  if (argv == 0 as *u8) {
    return 0;
  }
  if (i == 0 as *i32) {
    return 0;
  }
  unsafe {
    return invoke_cc_append_net_tls_ld_impl(argv, i, argv_cap, net_o, repo_root);
  }
  return 0;
}

/** Exported function `ensure_std_net_o_auto_tls`.
 * Implements `ensure_std_net_o_auto_tls`.
 * @param repo_root *u8
 * @return void
 */
#[no_mangle]
export function ensure_std_net_o_auto_tls(repo_root: *u8): void {
  unsafe {
    ensure_std_net_o_auto_tls_impl(repo_root);
  }
}

/* See implementation. */

#[no_mangle]
export function shux_invoke_cc(c_paths: *u8, n: i32, out_path: *u8, target: *u8, opt_level: *u8, use_lto: i32, io_o: *u8, fs_o: *u8, process_o: *u8, string_o: *u8, heap_o: *u8, path_o: *u8, runtime_o: *u8, runtime_panic_o: *u8, net_o: *u8, thread_o: *u8, time_o: *u8, random_o: *u8, env_o: *u8, sync_o: *u8, encoding_o: *u8, base64_o: *u8, crypto_o: *u8, log_o: *u8, atomic_o: *u8, channel_o: *u8, backtrace_o: *u8, hash_o: *u8, math_o: *u8, sort_o: *u8, ffi_o: *u8, db_o: *u8, elf_o: *u8, json_o: *u8, csv_o: *u8, regex_o: *u8, compress_o: *u8, unicode_o: *u8, dynlib_o: *u8, http_o: *u8, tar_o: *u8, simd_o: *u8, context_o: *u8, datetime_o: *u8, uuid_o: *u8, url_o: *u8, cli_o: *u8, security_o: *u8, config_o: *u8, cache_o: *u8, trace_o: *u8, task_o: *u8, schema_o: *u8, test_o: *u8, include_root: *u8, async_scheduler_o: *u8): i32 {
  if (c_paths == 0 as *u8) {
    return 0 - 1;
  }
  if (out_path == 0 as *u8) {
    return 0 - 1;
  }
  unsafe {
    return shux_invoke_cc_impl(c_paths, n, out_path, target, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, include_root, async_scheduler_o);
  }
  return 0 - 1;
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
  if (argv == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  unsafe {
    shux_append_linux_link_harden_impl(argv, la, cap);
  }
}


/* See implementation. */



#[no_mangle]
export function shux_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32 {
  unsafe {
    return shux_link_obj_needs_undef_sym_impl(user_o, sym);
  }
  return 0;
}

/* See implementation. */







#[no_mangle]
export function link_diag_tool_status(tool: *u8, status: i32): void {
  unsafe {
    link_diag_tool_status_impl(tool, status);
  }
}

/** Exported function `link_diag_runtime_source_missing`.
 * Implements `link_diag_runtime_source_missing`.
 * @param obj_name *u8
 * @param source_path *u8
 * @return void
 */
#[no_mangle]
export function link_diag_runtime_source_missing(obj_name: *u8, source_path: *u8): void {
  unsafe {
    link_diag_runtime_source_missing_impl(obj_name, source_path);
  }
}

/** Exported function `link_diag_runtime_source_missing_under`.
 * Implements `link_diag_runtime_source_missing_under`.
 * @param obj_name *u8
 * @param base_dir *u8
 * @param suffix *u8
 * @return void
 */
#[no_mangle]
export function link_diag_runtime_source_missing_under(obj_name: *u8, base_dir: *u8, suffix: *u8): void {
  unsafe {
    link_diag_runtime_source_missing_under_impl(obj_name, base_dir, suffix);
  }
}

/** Exported function `link_diag_runtime_obj_missing`.
 * Implements `link_diag_runtime_obj_missing`.
 * @param obj_name *u8
 * @param out_o *u8
 * @return void
 */
#[no_mangle]
export function link_diag_runtime_obj_missing(obj_name: *u8, out_o: *u8): void {
  unsafe {
    link_diag_runtime_obj_missing_impl(obj_name, out_o);
  }
}

/** Exported function `link_diag_runtime_obj_resolve_fail`.
 * Implements `link_diag_runtime_obj_resolve_fail`.
 * @param obj_name *u8
 * @param hint *u8
 * @return void
 */
#[no_mangle]
export function link_diag_runtime_obj_resolve_fail(obj_name: *u8, hint: *u8): void {
  unsafe {
    link_diag_runtime_obj_resolve_fail_impl(obj_name, hint);
  }
}

/** Exported function `link_diag_runtime_obj_build_status`.
 * Implements `link_diag_runtime_obj_build_status`.
 * @param obj_name *u8
 * @param status i32
 * @return void
 */
#[no_mangle]
export function link_diag_runtime_obj_build_status(obj_name: *u8, status: i32): void {
  unsafe {
    link_diag_runtime_obj_build_status_impl(obj_name, status);
  }
}

/** Exported function `link_diag_errno`.
 * Implements `link_diag_errno`.
 * @param kind *u8
 * @param op *u8
 * @return void
 */
#[no_mangle]
export function link_diag_errno(kind: *u8, op: *u8): void {
  unsafe {
    link_diag_errno_impl(kind, op);
  }
}

/** Exported function `link_diag_errno_path`.
 * Implements `link_diag_errno_path`.
 * @param kind *u8
 * @param op *u8
 * @param path *u8
 * @return void
 */
#[no_mangle]
export function link_diag_errno_path(kind: *u8, op: *u8, path: *u8): void {
  unsafe {
    link_diag_errno_path_impl(kind, op, path);
  }
}

/** Exported function `link_diag_freestanding_missing`.
 * Memory management helper `link_diag_freestanding_missing`.
 * @param obj_name *u8
 * @param symbol_name *u8
 * @return void
 */
#[no_mangle]
export function link_diag_freestanding_missing(obj_name: *u8, symbol_name: *u8): void {
  unsafe {
    link_diag_freestanding_missing_impl(obj_name, symbol_name);
  }
}

/** Exported function `link_diag_freestanding_unsupported`.
 * Memory management helper `link_diag_freestanding_unsupported`.
 * @return void
 */
#[no_mangle]
export function link_diag_freestanding_unsupported(): void {
  unsafe {
    link_diag_freestanding_unsupported_impl();
  }
}

/** Exported function `link_diag_ld_debug_push`.
 * Implements `link_diag_ld_debug_push`.
 * @param rel *u8
 * @param stage *u8
 * @param path *u8
 * @return void
 */
#[no_mangle]
export function link_diag_ld_debug_push(rel: *u8, stage: *u8, path: *u8): void {
  unsafe {
    link_diag_ld_debug_push_impl(rel, stage, path);
  }
}

/** Exported function `link_diag_ld_debug_argv`.
 * Implements `link_diag_ld_debug_argv`.
 * @param label *u8
 * @param argv *u8
 * @return void
 */
#[no_mangle]
export function link_diag_ld_debug_argv(label: *u8, argv: *u8): void {
  unsafe {
    link_diag_ld_debug_argv_impl(label, argv);
  }
}


/**
 * Write default lib-root into root_buf (SHUX_LIB or ".").
 * @param root_buf *u8 — capacity >= 512
 * Authority: labi_path_pure.x (wave115 product hybrid). Anchor body matches pure.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function shux_asm_ld_lib_root_default(root_buf: *u8): void {
  /* Anchor mirror of labi_path_pure pure orch (not product hybrid path). */
  root_buf[0] = 46;
  root_buf[1] = 0;
  let def: *u8 = 0 as *u8;
  unsafe {
    def = getenv("SHUX_LIB");
  }
  if (shux_asm_ld_lib_root_ptr_usable(def) == 0) {
    return;
  }
  let i: i32 = 0;
  while (i < 511) {
    let c: u8 = def[i];
    root_buf[i] = c;
    if (c == 0) {
      return;
    }
    i = i + 1;
  }
  root_buf[511] = 0;
}

/** Exported function `shux_linux_host_gcc_path`.
 * Implements `shux_linux_host_gcc_path`.
 * @return *u8
 */
#[no_mangle]
export function shux_linux_host_gcc_path(): *u8 {
  unsafe {
    return shux_linux_host_gcc_path_impl();
  }
  return 0 as *u8;
}

/** Exported function `shux_linux_ld_child_path`.
 * Implements `shux_linux_ld_child_path`.
 * @return void
 */
#[no_mangle]
export function shux_linux_ld_child_path(): void {
  unsafe {
    shux_linux_ld_child_path_impl();
  }
}

/* See implementation. */

#[no_mangle]
export function shux_runtime_o_realpath_if_exists(path: *u8, resolved: *u8): *u8 {
  unsafe {
    return shux_runtime_o_realpath_if_exists_impl(path, resolved);
  }
  return 0 as *u8;
}

/** Exported function `shux_runtime_compiler_o_path_copy`.
 * Implements `shux_runtime_compiler_o_path_copy`.
 * @param argv0 *u8
 * @param leaf *u8
 * @param out *u8
 * @param out_sz i64
 * @return i32
 */
#[no_mangle]
export function shux_runtime_compiler_o_path_copy(argv0: *u8, leaf: *u8, out: *u8, out_sz: i64): i32 {
  unsafe {
    return shux_runtime_compiler_o_path_copy_impl(argv0, leaf, out, out_sz);
  }
  return 0;
}

/** Exported function `link_abi_link_needs_heap_user_c`.
 * Implements `link_abi_link_needs_heap_user_c`.
 * @param user_o *u8
 * @param argv *u8
 * @param la i32
 * @return i32
 */
#[no_mangle]
export function link_abi_link_needs_heap_user_c(user_o: *u8, argv: *u8, la: i32): i32 {
  unsafe {
    return link_abi_link_needs_heap_user_c_impl(user_o, argv, la);
  }
  return 0;
}

/** Exported function `link_abi_link_needs_std_heap_import`.
 * Implements `link_abi_link_needs_std_heap_import`.
 * @param user_o *u8
 * @param argv *u8
 * @param la i32
 * @return i32
 */
#[no_mangle]
export function link_abi_link_needs_std_heap_import(user_o: *u8, argv: *u8, la: i32): i32 {
  unsafe {
    return link_abi_link_needs_std_heap_import_impl(user_o, argv, la);
  }
  return 0;
}

/** Exported function `link_abi_asm_ld_argv_has_obj`.
 * Implements `link_abi_asm_ld_argv_has_obj`.
 * @param argv *u8
 * @param la i32
 * @param path *u8
 * @return i32
 */
#[no_mangle]
export function link_abi_asm_ld_argv_has_obj(argv: *u8, la: i32, path: *u8): i32 {
  unsafe {
    return link_abi_asm_ld_argv_has_obj_impl(argv, la, path);
  }
  return 0;
}

/** Exported function `link_abi_asm_ld_argv_push_stable`.
 * Implements `link_abi_asm_ld_argv_push_stable`.
 * @param bank *u8
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @param p *u8
 * @return void
 */
#[no_mangle]
export function link_abi_asm_ld_argv_push_stable(bank: *u8, argv: *u8, la: *i32, max_la: i32, p: *u8): void {
  unsafe {
    link_abi_asm_ld_argv_push_stable_impl(bank, argv, la, max_la, p);
  }
}

/** Exported function `link_abi_asm_ld_push_obj`.
 * Implements `link_abi_asm_ld_push_obj`.
 * @param primary *u8
 * @param link_argv0 *u8
 * @param rel *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param bank *u8
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @param flag_out *i32
 * @return i32
 */
#[no_mangle]
export function link_abi_asm_ld_push_obj(primary: *u8, link_argv0: *u8, rel: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flag_out: *i32): i32 {
  unsafe {
    return link_abi_asm_ld_push_obj_impl(primary, link_argv0, rel, lib_roots, n_lib_roots, bank, argv, la, max_la, flag_out);
  }
  return 0;
}

/* See implementation. */

#[no_mangle]
export function shux_cc_compile_sync(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32): i32 {
  unsafe {
    return shux_cc_compile_sync_impl(src, out_o, inc0, inc1, inc2, from_asm_s);
  }
  return 0 - 1;
}

/** Exported function `shux_spawn_sync`.
 * Implements `shux_spawn_sync`.
 * @param prog *u8
 * @param argv *u8
 * @return i32
 */
#[no_mangle]
export function shux_spawn_sync(prog: *u8, argv: *u8): i32 {
  unsafe {
    return shux_spawn_sync_impl(prog, argv);
  }
  return 0 - 1;
}

/** Exported function `shux_link_perror`.
 * Implements `shux_link_perror`.
 * @param msg *u8
 * @return void
 */
#[no_mangle]
export function shux_link_perror(msg: *u8): void {
  unsafe {
    shux_link_perror_impl(msg);
  }
}

/** Exported function `ld_append_brew_lib_paths`.
 * Implements `ld_append_brew_lib_paths`.
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @return void
 */
#[no_mangle]
export function ld_append_brew_lib_paths(argv: *u8, la: *i32, max_la: i32): void {
  unsafe {
    ld_append_brew_lib_paths_impl(argv, la, max_la);
  }
}

/** Exported function `link_abi_generated_c_contains_any_substr`.
 * Implements `link_abi_generated_c_contains_any_substr`.
 * @param c_path *u8
 * @param needles *u8
 * @param n_needles i32
 * @return i32
 */
#[no_mangle]
export function link_abi_generated_c_contains_any_substr(c_path: *u8, needles: *u8, n_needles: i32): i32 {
  unsafe {
    return link_abi_generated_c_contains_any_substr_impl(c_path, needles, n_needles);
  }
  return 0;
}

/** Exported function `link_abi_asm_ld_push_glue_after_std`.
 * Implements `link_abi_asm_ld_push_glue_after_std`.
 * @param have_std i32
 * @param ensure_fn *u8
 * @param glue_primary *u8
 * @param link_argv0 *u8
 * @param glue_rel *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param bank *u8
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @return void
 */
#[no_mangle]
export function link_abi_asm_ld_push_glue_after_std(have_std: i32, ensure_fn: *u8, glue_primary: *u8, link_argv0: *u8, glue_rel: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32): void {
  unsafe {
    link_abi_asm_ld_push_glue_after_std_impl(have_std, ensure_fn, glue_primary, link_argv0, glue_rel, lib_roots, n_lib_roots, bank, argv, la, max_la);
  }
}

/** Exported function `link_abi_asm_ld_push_minimal_runtime_objs`.
 * Implements `link_abi_asm_ld_push_minimal_runtime_objs`.
 * @param link_argv0 *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @param bank *u8
 * @param argv *u8
 * @param la *i32
 * @param max_la i32
 * @return void
 */
#[no_mangle]
export function link_abi_asm_ld_push_minimal_runtime_objs(link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32): void {
  unsafe {
    link_abi_asm_ld_push_minimal_runtime_objs_impl(link_argv0, lib_roots, n_lib_roots, bank, argv, la, max_la);
  }
}

/* See implementation. */

#[no_mangle]
export function shux_cc_compile_sync_ex(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32, extra_flags: *u8): i32 {
  unsafe {
    return shux_cc_compile_sync_ex_impl(src, out_o, inc0, inc1, inc2, from_asm_s, extra_flags);
  }
  return 0 - 1;
}

/** Exported function `shux_asm_nostdlib_minimal_selfcontained_exe_link`.
 * Implements `shux_asm_nostdlib_minimal_selfcontained_exe_link`.
 * @param o_path *u8
 * @param exe_path *u8
 * @param link_eff *u8
 * @param lib_roots *u8
 * @param n_lib_roots i32
 * @return i32
 */
#[no_mangle]
export function shux_asm_nostdlib_minimal_selfcontained_exe_link(o_path: *u8, exe_path: *u8, link_eff: *u8, lib_roots: *u8, n_lib_roots: i32): i32 {
  unsafe {
    return shux_asm_nostdlib_minimal_selfcontained_exe_link_impl(o_path, exe_path, link_eff, lib_roots, n_lib_roots);
  }
  return 0 - 1;
}

/**
 * Return 1 iff .o nm output contains marker substring; null/empty → 0 without residual.
 * @param obj_o *u8 — path to .o; null/empty rejected at pure gate
 * @param marker *u8 — marker substring; null/empty rejected at pure gate
 * @return i32 — 1 if any nm line contains marker, else 0
 * Authority (G.7 / wave211): product pure orch is labi_ondemand_list.x
 * `link_abi_obj_exports_marker` (same gates + Cap residual _impl). This mega .x twin
 * stays isomorphic for logical-source fold; product hybrid uses L8b pure.
 * Cap residual: link_abi_obj_exports_marker_impl (realpath + nm + strstr marker).
 * PLATFORM: SHARED orch; residual nm/popen is host.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function link_abi_obj_exports_marker(obj_o: *u8, marker: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  if (obj_o[0] == 0) {
    return 0;
  }
  if (marker == 0 as *u8) {
    return 0;
  }
  if (marker[0] == 0) {
    return 0;
  }
  unsafe {
    return link_abi_obj_exports_marker_impl(obj_o, marker);
  }
  return 0;
}

/**
 * Return 1 iff .o has an UNDEF line containing sym (host nm); null/empty → 0 without residual.
 * @param obj_o *u8 — path to .o; null/empty rejected at pure gate
 * @param sym *u8 — symbol name or prefix needle; null/empty rejected at pure gate
 * @return i32 — 1 if UNDEF line hits, else 0
 * Authority (G.7 / wave210): product pure orch is labi_ondemand_list.x
 * `link_abi_obj_has_undef_sym` (same gates + Cap residual _impl). This mega .x twin
 * stays isomorphic for logical-source fold; product hybrid uses L8b pure.
 * Cap residual: link_abi_obj_has_undef_sym_impl (realpath + nm + " U " + needle).
 * PLATFORM: SHARED orch; residual nm/popen is host.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function link_abi_obj_has_undef_sym(obj_o: *u8, sym: *u8): i32 {
  if (obj_o == 0 as *u8) {
    return 0;
  }
  if (obj_o[0] == 0) {
    return 0;
  }
  if (sym == 0 as *u8) {
    return 0;
  }
  if (sym[0] == 0) {
    return 0;
  }
  unsafe {
    return link_abi_obj_has_undef_sym_impl(obj_o, sym);
  }
  return 0;
}

// See implementation.

export extern "C" function shux_debug_hello_stage1_report_impl(): void;

/* See implementation. */

#[no_mangle]
export function shux_debug_hello_stage1_report(): void {
  unsafe { shux_debug_hello_stage1_report_impl(); }
}

// shux_asm_ld_lib_root_ptr_usable: see function docblock below.

/** Exported function `shux_asm_ld_lib_root_ptr_usable`.
 * Implements `shux_asm_ld_lib_root_ptr_usable`.
 * @param p *u8
 * @return i32
 */
#[no_mangle]
export function shux_asm_ld_lib_root_ptr_usable(p: *u8): i32 {
  /* Authority: labi_path_pure.x (wave114 product hybrid). Keep mega semantics. */
  if (p == 0 as *u8) { return 0; }
  if ((p as usize) < (4096 as usize)) { return 0; }
  if (p[0] == 0) { return 0; }
  return 1;
}

// driver_copy_cstr_n: see function docblock below.

/** Exported function `driver_copy_cstr_n`.
 * Implements `driver_copy_cstr_n`.
 * @param src *u8
 * @param buf *u8
 * @param max i32
 * @return i32
 */
#[no_mangle]
export function driver_copy_cstr_n(src: *u8, buf: *u8, max: i32): i32 {
  if (src == 0) { return 0 - 1; }
  if (buf == 0) { return 0 - 1; }
  if (max <= 0) { return 0 - 1; }
  let n: i32 = max - 1;
  let j: i32 = 0;
  while (j < n) {
    let c: u8 = src[j];
    if (c == 0) { break; }
    buf[j] = c;
    j = j + 1;
  }
  buf[j] = 0;
  return j;
}

/** Exported function `shux_path_has_sep`.
 * Implements `shux_path_has_sep`.
 * @param s *u8
 * @return i32
 */
#[no_mangle]
export function shux_path_has_sep(s: *u8): i32 {
  if (s == 0) { return 0; }
  let i: i32 = 0;
  while (i < 4096) {
    let c: u8 = s[i];
    if (c == 0) { break; }
    if (c == 47) { return 1; } // '/'
    if (c == 92) { return 1; } // '\\'
    i = i + 1;
  }
  return 0;
}

/** Exported function `shux_path_last_sep`.
 * Implements `shux_path_last_sep`.
 * @param s *u8
 * @return *u8
 */
#[no_mangle]
export function shux_path_last_sep(s: *u8): *u8 {
  if (s == 0) { return 0 as *u8; }
  let last: *u8 = 0 as *u8;
  let i: i32 = 0;
  while (i < 4096) {
    let c: u8 = s[i];
    if (c == 0) { break; }
    if (c == 47) { last = s + i; }
    if (c == 92) { last = s + i; }
    i = i + 1;
  }
  return last;
}

// link_diag_code_for_kind: see function docblock below.

/** Exported function `link_diag_code_for_kind`.
 * Implements `link_diag_code_for_kind`.
 * @param kind *u8
 * @return *u8
 */
#[no_mangle]
export function link_diag_code_for_kind(kind: *u8): *u8 {
  if (kind == 0) { return "PRC001"; }
  // "build error"
  if (kind[0]==98 && kind[1]==117 && kind[2]==105 && kind[3]==108 && kind[4]==100
      && kind[5]==32 && kind[6]==101 && kind[7]==114 && kind[8]==114 && kind[9]==111
      && kind[10]==114 && kind[11]==0) {
    return "BLD001";
  }
  // "process error"
  if (kind[0]==112 && kind[1]==114 && kind[2]==111 && kind[3]==99 && kind[4]==101
      && kind[5]==115 && kind[6]==115 && kind[7]==32 && kind[8]==101 && kind[9]==114
      && kind[10]==114 && kind[11]==111 && kind[12]==114 && kind[13]==0) {
    return "PRC001";
  }
  return 0 as *u8;
}

