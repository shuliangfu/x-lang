// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-34..44/47/53/55/56/64..69：真迁 .x — link_abi needs_* / 空 .o / bank / 路径 / ld 门闩。
// 产品：./shux-c -E → seeds/runtime_link_abi.from_x.c（+ C 尾 + 字符串/签名抛光）。
// C 尾：invoke_cc/ld 主体、nm/popen、fileview、cstr 拷贝、stat 原语、#if host。
// G-02f-69：+ invoke_ld_platform / resolve_dir / append_std/on_demand 门闩。
// G-02f-68：+ prepare_for_exe_link / waitpid / compress / argv_push 门闩。
// G-02f-67：+ shux_ensure_* 族门闩（argv0 单参标准模板）。
// G-02f-66：+ invoke_ld_for_exe / mach+unix tail libs 门闩。

extern "C" function main_entry(argc: i32, argv: *u8): i32;
extern "C" function shux_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32;
extern "C" function getenv(name: *u8): *u8;
extern "C" function shux_host_is_linux(): i32;
extern "C" function shux_host_is_apple_aarch64(): i32;
extern "C" function driver_argv_at(argv: *u8, i: i32): *u8;
extern "C" function driver_copy_cstr_n(src: *u8, buf: *u8, max: i32): i32;
extern "C" function shux_path_is_nonempty_regular_file_impl(path: *u8): i32;
extern "C" function link_abi_obj_exports_marker(obj_o: *u8, marker: *u8): i32;
extern "C" function link_abi_obj_has_undef_sym(obj_o: *u8, sym: *u8): i32;
extern "C" function link_abi_generated_c_contains_substr(c_path: *u8, needle: *u8): i32;
extern "C" function shux_empty_cstr(): *u8;
extern "C" function shux_asm_ld_bank_push_impl(b: *u8, path: *u8): *u8;
extern "C" function shux_runtime_asm_io_stubs_o_path_impl(argv0: *u8): *u8;
extern "C" function shux_runtime_process_argv_o_path_impl(argv0: *u8): *u8;
extern "C" function shux_asm_ld_effective_link_argv0_impl(link_argv0: *u8, syn_buf: *u8, syn_sz: i32): *u8;
extern "C" function shux_invoke_ld_for_exe_impl(o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32, link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32): i32;
extern "C" function shux_asm_ld_append_mach_tail_libs_impl(compress_o: *u8, user_o: *u8, flags: *u8, argv: *u8, la: *i32, max_la: i32, append_lsystem: i32): void;
extern "C" function shux_asm_ld_append_unix_gcc_tail_libs_impl(compress_o: *u8, user_o: *u8, flags: *u8, need_pt: i32, argv: *u8, la: *i32, max_la: i32): void;
extern "C" function shux_ensure_runtime_arrow_simd_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_asm_io_stubs_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_atomic_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_backtrace_platform_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_channel_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_compress_zlib_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_crypto_inc_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_dynlib_os_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_ed25519_ref10_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_env_os_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_heap_user_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_http_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_kv_mmap_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_log_os_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_math_libm_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_net_udp_batch_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_net_workers_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_panic_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_process_argv_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_process_os_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_queue_contention_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_random_fill_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_scheduler_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_sqlite_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_sync_lock_diag_tls_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_sync_os_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_test_fn_invoke_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_thread_glue_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_time_os_o_impl(argv0: *u8): i32;
extern "C" function shux_ensure_runtime_tls_mbedtls_bio_o_impl(argv0: *u8): i32;

#[no_mangle]
function shux_forward_main_to_main_entry(argc: i32, argv: *u8): i32 {
  unsafe {
    let r: i32 = main_entry(argc, argv);
    return r;
  }
  return 0;
}

#[no_mangle]
function shux_freestanding_user_o_needs_panic(user_o: *u8): i32 {
  unsafe {
    let r: i32 = shux_link_obj_needs_undef_sym(user_o, "shux_panic_");
    return r;
  }
  return 0;
}

#[no_mangle]
function shux_freestanding_user_o_needs_io(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_write") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_read") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_close") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_exit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_open") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_openat") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_mmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_munmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_socket") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_connect") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_bind") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_listen") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_sys_accept") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function invoke_cc_skip_native_tuning(): i32 {
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

/* ---- G-02f-36：freestanding_enabled（OS 门闩经 C 槽）---- */

#[no_mangle]
function shux_link_freestanding_enabled(driver_freestanding: i32): i32 {
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
    /* '0' == 48 — 避免单引号字面量被 -E 丢掉整函数 */
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

/* ---- G-02f-36：按需链 user.o needs 探针（原 static C）---- */

#[no_mangle]
function link_abi_user_o_needs_libc_heap(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym(user_o, "malloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "calloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "realloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "free") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "posix_memalign") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "getenv") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_std_map(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    let r: i32 = shux_link_obj_needs_undef_sym(user_o, "std_map_empty_size");
    return r;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_std_set(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_insert") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_contains") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_remove") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_len") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_set_set_i32_deinit") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_std_test(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "test_call_i32_void_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "test_runner_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "test_expect_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "test_bench_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "test_f_test_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "test_io_") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "test_fuzz_") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_core_mem(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_mem_align_up") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_mem_align_down") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_mem_mem_copy") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_mem_mem_set") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_mem_mem_zero") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_mem_mem_move") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_mem_mem_compare") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_core_slice(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym(user_o, "core_slice_i32_from_ptr_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_subslice_i32_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_slice_u8_from_ptr_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_subslice_u8_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_slice_u64_from_ptr_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "core_subslice_u64_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_std_heap_page_mmap(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_page_mmap_page_mmap_heap_available") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_page_mmap_page_mmap_heap_init") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_page_mmap_page_mmap_heap_alloc") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_page_mmap_page_mmap_heap_deinit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_page_mmap_page_mmap_heap_free") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_std_sys_linux(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_linux_linux_syscall_invoke_available") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_linux_linux_anonymous_mmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_linux_linux_syscall_munmap") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_linux_linux_syscall_read") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_linux_linux_syscall_write") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_linux_linux_syscall_close") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_linux_linux_syscall_exit") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_std_sys(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_write_stdout") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_write_stderr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_write") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_read") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_close") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_exit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_freestanding_write_available") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_sys_linux_syscall_table_available") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_std_net(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_net_listen") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_net_connect") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_net_udp_bind") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_net_udp_recv_many_buf") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_net_udp_send_many_buf") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_net_addr_to_u32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_net_close_udp") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_stream_write_batch_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_tcp_connect_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_tcp_listen_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_udp_bind_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_udp_recv_many_buf_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_udp_send_many_buf_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_close_socket_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_udp_send_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_dns_resolve_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "net_sock_create_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}


/* ---- G-02f-37：std.heap API / heap_*_c 单路径探针（argv 循环仍 C）---- */

#[no_mangle]
function link_abi_user_o_needs_std_heap_api(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_alloc_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_alloc_u8") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_free_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_free_u8") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_alloc_size_zero") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_alloc_usize") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_free_u8_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_libc_heap_arena64_alloc_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_libc_heap_alloc_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_libc_heap_free_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "std_heap_libc_heap_alloc_aligned_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
function link_abi_user_o_needs_heap_user_syms(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  unsafe {
    if (user_o[0] == 0) {
      return 0;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "heap_alloc_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "heap_free_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "heap_realloc_c") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "heap_arena64_alloc_c") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/* ---- G-02f-37：async scheduler 按需链（原 static 符号表展开为 if）---- */

#[no_mangle]
function link_abi_user_o_needs_async_scheduler(user_o: *u8): i32 {
  unsafe {
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_coop_pingpong") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_coop_pingpong_jmp") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_cps_suspend") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_asm_frame_phase_by_id") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_asm_frame_store_from_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_asm_frame_load_to_ptr") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_asm_frame_reset_by_id") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_cps_suspend_io") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_task_submit") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_task_submit_to") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_scheduler_drain") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_worker_drain") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_worker_count") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_worker_pending") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_queue_reset") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_scheduler_pending") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_io_wake_all") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_io_waiters_pending") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_io_completions_ready") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_set_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_reset") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_push_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_push_u32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_push_i64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_valid") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_take_i32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_take_u32") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_async_run_seed_take_i64") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_io_submit_read_async") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_io_complete_read_async") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_io_complete_read_async_slot") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_io_submit_write_async") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_io_complete_write_async") != 0) {
      return 1;
    }
    if (shux_link_obj_needs_undef_sym(user_o, "shux_io_complete_write_async_slot") != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}


/* ---- G-02f-38：compress 库按需探针（nm marker/undef 原语仍 C）---- */

#[no_mangle]
function link_abi_obj_needs_zlib(obj_o: *u8): i32 {
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

#[no_mangle]
function link_abi_obj_needs_zstd(obj_o: *u8): i32 {
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

#[no_mangle]
function link_abi_obj_needs_brotli(obj_o: *u8): i32 {
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

#[no_mangle]
function link_abi_user_o_needs_compress_libs(user_o: *u8): i32 {
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

/* ---- G-02f-39：generated_c 子串探针（fileview 扫描原语仍 C）---- */

#[no_mangle]
function link_abi_generated_c_needs_core_builtin(c_path: *u8): i32 {
  return 0;
}

#[no_mangle]
function link_abi_generated_c_needs_core_mem(c_path: *u8): i32 {
  return 0;
}

#[no_mangle]
function link_abi_generated_c_needs_libc_heap(c_path: *u8): i32 {
  /* needles 无 '('：shux-c -E 对含括号字符串会丢整函数 */
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

#[no_mangle]
function link_abi_generated_c_needs_win32(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_win32_wsa(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_db_kv(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_db_arrow(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_core_slice(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_fs(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_zlib(c_path: *u8): i32 {
  /* 无 '(' needle：避免 -E 丢函数；_compress2 等前缀已覆盖 libc 符号 */
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

#[no_mangle]
function link_abi_generated_c_needs_zstd(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_brotli(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_random(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_time(c_path: *u8): i32 {
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

#[no_mangle]
function link_abi_generated_c_needs_runtime(c_path: *u8): i32 {
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

#[no_mangle]
function shux_generated_c_needs_async_scheduler(c_path: *u8): i32 {
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
/* ---- G-02f-47：已存在非空常规文件则返回 path ---- */

#[no_mangle]
function asm_link_obj_skip_missing(path: *u8): *u8 {
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

/* ---- G-02f-44：argv[i] 拷贝到 buf（循环在 C）---- */

#[no_mangle]
function driver_get_argv_i(argc: i32, argv: *u8, i: i32, buf: *u8, max: i32): i32 {
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

/* ---- G-02f-43：target arch 解析（OS 门闩经 C 槽）---- */

#[no_mangle]
function driver_resolve_target_arch(parsed_target: i32, saw_target_flag: i32): i32 {
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

#[no_mangle]
function bootstrap_init_static_tls(): void {
}

#[no_mangle]
function bootstrap_init_environ(argc: i32, argv: *u8): void {
}

#[no_mangle]
function bootstrap_nostdlib_pthread_is_stub(): i32 {
  return 0;
}

/* ---- G-02f-53：std.io / std.compress 已无 .o，返回空串 ---- */

#[no_mangle]
function shux_std_io_o_path(argv0: *u8): *u8 {
  unsafe {
    return shux_empty_cstr();
  }
  return 0 as *u8;
}

#[no_mangle]
function shux_std_compress_o_path(argv0: *u8): *u8 {
  unsafe {
    return shux_empty_cstr();
  }
  return 0 as *u8;
}

/* ---- G-02f-56：effective link argv0（靠前以免 -E 尾丢）---- */

#[no_mangle]
function shux_asm_ld_effective_link_argv0(link_argv0: *u8, syn_buf: *u8, syn_sz: i32): *u8 {
  unsafe {
    return shux_asm_ld_effective_link_argv0_impl(link_argv0, syn_buf, syn_sz);
  }
  return 0 as *u8;
}

/* ---- G-02f-55：ld path bank push 门闩 ---- */

#[no_mangle]
function shux_asm_ld_bank_push(b: *u8, path: *u8): *u8 {
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

/* ---- G-02f-56：runtime .o 路径 + effective link argv0 ---- */

#[no_mangle]
function shux_runtime_asm_io_stubs_o_path(argv0: *u8): *u8 {
  unsafe {
    return shux_runtime_asm_io_stubs_o_path_impl(argv0);
  }
  return 0 as *u8;
}

#[no_mangle]
function shux_runtime_process_argv_o_path(argv0: *u8): *u8 {
  unsafe {
    return shux_runtime_process_argv_o_path_impl(argv0);
  }
  return 0 as *u8;
}

/* ---- G-02f-64：-o 路径后缀形态（真逻辑，无 _impl）---- */

/* .o / .O / .obj → 对象文件路径（非自动 ld exe）。 */
#[no_mangle]
function shux_output_is_elf_o(path: *u8): i32 {
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

/* 非 .o/.obj/.s 后缀 → asm 应自动 ld 出 exe。 */
#[no_mangle]
function shux_output_want_exe(path: *u8): i32 {
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

/* ---- G-02f-65：stat 门闩 + ld argv 条目是否为 .o/.obj ---- */

#[no_mangle]
function shux_path_is_nonempty_regular_file(path: *u8): i32 {
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

/* 真逻辑：argv 槽是否为对象文件路径（.o / .obj）。供 merge/needs 循环复用。 */
#[no_mangle]
function link_abi_ld_argv_entry_is_obj(s: *u8): i32 {
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

/* ---- G-02f-66：asm -o exe 编排 + tail libs 门闩 ---- */

#[no_mangle]
function shux_invoke_ld_for_exe(o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32, link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32): i32 {
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

#[no_mangle]
function shux_asm_ld_append_mach_tail_libs(compress_o: *u8, user_o: *u8, flags: *u8, argv: *u8, la: *i32, max_la: i32, append_lsystem: i32): void {
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

#[no_mangle]
function shux_asm_ld_append_unix_gcc_tail_libs(compress_o: *u8, user_o: *u8, flags: *u8, need_pt: i32, argv: *u8, la: *i32, max_la: i32): void {
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

extern "C" function shux_ensure_crt0_user_o_impl(argv0: *u8, driver_freestanding: i32): i32;

extern "C" function shux_ensure_freestanding_io_o_impl(argv0: *u8, driver_freestanding: i32): i32;
extern "C" function shu_waitpid_retry_impl(pid: i64, status_out: *i32): i32;
extern "C" function shux_asm_user_o_has_undef_syms_impl(o_path: *u8): i32;
extern "C" function asm_ld_append_compress_libs_impl(compress_o: *u8, user_o: *u8, argv: *u8, la: *i32, max_la: i32): void;
extern "C" function invoke_cc_append_compress_ld_impl(argv: *u8, i: *i32, argv_cap: i32, compress_o: *u8, user_o: *u8): void;
extern "C" function invoke_cc_argv_push_existing_impl(argv: *u8, ia: *i32, max_ia: i32, path: *u8): i32;
extern "C" function shux_asm_ld_prepare_for_exe_link_impl(link_eff: *u8, user_o: *u8, driver_freestanding: i32, use_macho_o: i32, use_coff_o: i32): i32;

/* ---- G-02f-67：ensure_* 标准模板门闩（argv0） ---- */

#[no_mangle]
function shux_ensure_runtime_arrow_simd_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_arrow_simd_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_asm_io_stubs_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_asm_io_stubs_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_atomic_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_atomic_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_backtrace_platform_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_backtrace_platform_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_channel_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_channel_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_compress_zlib_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_compress_zlib_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_crypto_inc_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_crypto_inc_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_dynlib_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_dynlib_os_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_ed25519_ref10_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_ed25519_ref10_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_env_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_env_os_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_heap_user_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_heap_user_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_http_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_http_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_kv_mmap_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_kv_mmap_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_log_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_log_os_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_math_libm_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_math_libm_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_net_udp_batch_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_net_udp_batch_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_net_workers_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_net_workers_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_panic_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_panic_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_process_argv_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_process_argv_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_process_os_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_process_os_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_queue_contention_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_queue_contention_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_random_fill_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_random_fill_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_scheduler_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_scheduler_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_sqlite_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_sqlite_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_sync_lock_diag_tls_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_sync_lock_diag_tls_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_sync_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_sync_os_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_test_fn_invoke_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_test_fn_invoke_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_thread_glue_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_thread_glue_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_time_os_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_time_os_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_runtime_tls_mbedtls_bio_o(argv0: *u8): i32 {
  unsafe {
    return shux_ensure_runtime_tls_mbedtls_bio_o_impl(argv0);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_crt0_user_o(argv0: *u8, driver_freestanding: i32): i32 {
  unsafe {
    return shux_ensure_crt0_user_o_impl(argv0, driver_freestanding);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_ensure_freestanding_io_o(argv0: *u8, driver_freestanding: i32): i32 {
  unsafe {
    return shux_ensure_freestanding_io_o_impl(argv0, driver_freestanding);
  }
  return 0 - 1;
}

extern "C" function shu_resolve_compiler_dir_impl(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32;
extern "C" function shux_asm_invoke_ld_platform_impl(o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32, link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, driver_freestanding: i32): i32;
extern "C" function shux_asm_ld_append_std_objs_impl(link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flags: *u8): void;
extern "C" function shux_asm_ld_append_on_demand_user_objs_impl(link_argv0: *u8, user_o: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flags: *u8): void;
extern "C" function invoke_cc_append_net_tls_ld_impl(argv: *u8, i: *i32, argv_cap: i32, net_o: *u8, repo_root: *u8): i32;
extern "C" function ensure_std_net_o_auto_tls_impl(repo_root: *u8): void;

/* ---- G-02f-68：prepare / waitpid / compress / argv_push 门闩 ---- */

#[no_mangle]
function shu_waitpid_retry(pid: i64, status_out: *i32): i32 {
  unsafe {
    return shu_waitpid_retry_impl(pid, status_out);
  }
  return 0 - 1;
}

#[no_mangle]
function shux_asm_user_o_has_undef_syms(o_path: *u8): i32 {
  if (o_path == 0 as *u8) {
    return 1;
  }
  unsafe {
    return shux_asm_user_o_has_undef_syms_impl(o_path);
  }
  return 1;
}

#[no_mangle]
function asm_ld_append_compress_libs(compress_o: *u8, user_o: *u8, argv: *u8, la: *i32, max_la: i32): void {
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

#[no_mangle]
function invoke_cc_append_compress_ld(argv: *u8, i: *i32, argv_cap: i32, compress_o: *u8, user_o: *u8): void {
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

#[no_mangle]
function invoke_cc_argv_push_existing(argv: *u8, ia: *i32, max_ia: i32, path: *u8): i32 {
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

#[no_mangle]
function shux_asm_ld_prepare_for_exe_link(link_eff: *u8, user_o: *u8, driver_freestanding: i32, use_macho_o: i32, use_coff_o: i32): i32 {
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

/* ---- G-02f-69：invoke_ld_platform / resolve_dir / append objs 门闩 ---- */

#[no_mangle]
function shu_resolve_compiler_dir(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32 {
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

#[no_mangle]
function shux_asm_invoke_ld_platform(o_path: *u8, exe_path: *u8, target: *u8, use_macho_o: i32, use_coff_o: i32, link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, driver_freestanding: i32): i32 {
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

#[no_mangle]
function shux_asm_ld_append_std_objs(link_argv0: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flags: *u8): void {
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

#[no_mangle]
function shux_asm_ld_append_on_demand_user_objs(link_argv0: *u8, user_o: *u8, lib_roots: *u8, n_lib_roots: i32, bank: *u8, argv: *u8, la: *i32, max_la: i32, flags: *u8): void {
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

#[no_mangle]
function invoke_cc_append_net_tls_ld(argv: *u8, i: *i32, argv_cap: i32, net_o: *u8, repo_root: *u8): i32 {
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

#[no_mangle]
function ensure_std_net_o_auto_tls(repo_root: *u8): void {
  unsafe {
    ensure_std_net_o_auto_tls_impl(repo_root);
  }
}
