// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-34/35/36：真迁 .x — link_abi 入口转发 / freestanding / needs_* 探针 / bootstrap 桩。
// 产品：./shux-c -E → seeds/runtime_link_abi.from_x.c（+ C 尾 + 字符串/签名抛光）。
// C 尾：invoke_cc/ld、路径后缀 is_elf_o/want_exe、object 扫描、argv 循环 needs。
// G-02f-36：+ link_abi_user_o_needs_* 按需链探针；freestanding_enabled（经 host_is_linux 槽）。

extern "C" function main_entry(argc: i32, argv: *u8): i32;
extern "C" function shux_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32;
extern "C" function getenv(name: *u8): *u8;
extern "C" function shux_host_is_linux(): i32;

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
