// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L8b on_demand symbol groups / rel pure tables; G.9 English; body authoritative.
// Hybrid macro SHUX_LABI_ONDEMAND_LIST_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: simple/kv/arrow/time/queue + rel_* pure tables +
//   wave118 labi_od_net_sym_* + link_abi_user_o_needs_std_net pure orch +
//   wave119 labi_od_set_sym_* + link_abi_user_o_needs_std_set pure orch +
//   wave120 labi_od_map_sym_* + link_abi_user_o_needs_std_map pure orch +
//   wave121 labi_od_queue_api_sym_* + link_abi_user_o_needs_std_queue pure orch
//     (product API; separate from contention labi_od_queue_sym_*) +
//   wave122 labi_od_test_sym_* + link_abi_user_o_needs_std_test pure orch +
//   wave123 labi_od_core_mem_sym_* + link_abi_user_o_needs_core_mem pure orch +
//   wave124 labi_od_core_slice_sym_* + link_abi_user_o_needs_core_slice pure orch +
//   wave125 labi_od_page_mmap_sym_* + link_abi_user_o_needs_std_heap_page_mmap pure orch +
//   wave126 labi_od_sys_linux_sym_* + link_abi_user_o_needs_std_sys_linux pure orch +
//   wave127 labi_od_sys_sym_* + link_abi_user_o_needs_std_sys pure orch +
//   wave128 labi_od_heap_api_sym_* + link_abi_user_o_needs_std_heap_api pure orch.
// Cap residual: nm/push/ensure stay mega; undef_sym probe Cap for needs orch.
// PLATFORM: SHARED — no asm co-emit of option/result/debug (Ubuntu hang); link formal .o only.
// Simple groups: string=0 core_types=1 encoding=2 base64=3 csv=4 schema=5
// core_option=6 core_result=7 core_debug=8 core_slice=9.
// Formal core/*/*.o; g1 rel is core/types/types.o; g9 rel is core/slice/mod.o (API, not glue).
// g9: length.x needs core_slice_len_i32/get_* from mod.x; glue remains core/slice/slice.o.

/** Cap residual: nm UNDEF probe used by pure needs orch (mega always). */
export extern "C" function shux_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32;

/** Return simple on_demand group count (must match seed labi_ondemand_list.from_x.c). */
#[no_mangle]
export function labi_od_simple_group_count(): i32 {
  return 10;
}

/** Return symbol probe count for simple group g. */
#[no_mangle]
export function labi_od_simple_group_sym_count(g: i32): i32 {
  if (g < 0) {
    return 0;
  }
  if (g == 0) {
    return 9;
  }
  if (g == 1) {
    return 2;
  }
  if (g == 2) {
    return 6;
  }
  if (g == 3) {
    return 4;
  }
  if (g == 4) {
    return 3;
  }
  if (g == 5) {
    return 3;
  }
  if (g == 6) {
    return 4;
  }
  if (g == 7) {
    return 4;
  }
  if (g == 8) {
    return 6;
  }
  // core.slice formal API surface (tests/slice/length.x, subslice_split_chunks.x).
  if (g == 9) {
    return 10;
  }
  return 0;
}

/** Exported function `labi_od_simple_group_sym_at`.
 * Implements `labi_od_simple_group_sym_at`.
 * @param g i32
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_simple_group_sym_at(g: i32, i: i32): *u8 {
  if (g < 0) {
    return 0 as *u8;
  }
  if (i < 0) {
    return 0 as *u8;
  }
  if (g == 0) {
    if (i == 0) {
      let p: *u8 = "shux_string_copy_c";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "shux_string_memcmp_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "shux_string_memchr_c";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "shux_string_memmem_c";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "shux_string_memrchr_c";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "std_string_string_new";
      return p;
    }
    if (i == 6) {
      let p: *u8 = "std_string_string_from_slice";
      return p;
    }
    if (i == 7) {
      let p: *u8 = "std_string_string_view";
      return p;
    }
    if (i == 8) {
      let p: *u8 = "std_string_string_len";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 1) {
    if (i == 0) {
      let p: *u8 = "core_types_size_of_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_types_placeholder";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 2) {
    if (i == 0) {
      let p: *u8 = "encoding_utf8_valid_c";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "encoding_hex_encode_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "encoding_ascii_is_alpha_c";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "std_encoding_utf8_valid";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "std_encoding_utf8_decode_rune";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "std_encoding_ascii_is_alpha";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 3) {
    if (i == 0) {
      let p: *u8 = "base64_encode_standard_c";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "std_base64_encode_standard";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "std_base64_decode_standard";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "std_base64_encode_url";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 4) {
    if (i == 0) {
      let p: *u8 = "std_csv_next_field";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "std_csv_escape";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "std_csv_csv_test_quoted_first";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 5) {
    if (i == 0) {
      let p: *u8 = "schema_create_c";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "schema_decode_json_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "schema_smoke_c";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 6) {
    if (i == 0) {
      let p: *u8 = "core_option_some_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_option_unwrap_or_i32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_option_none_i32";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "core_option_is_some_i32";
      return p;
    }
    return 0 as *u8;
  }
  if (g == 7) {
    if (i == 0) {
      let p: *u8 = "core_result_ok_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_result_is_ok_i32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_result_err_i32";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "core_result_ok";
      return p;
    }
    return 0 as *u8;
  }
  // PLATFORM: SHARED — core.debug formal surface (tests/sort assert_eq_*).
  if (g == 8) {
    if (i == 0) {
      let p: *u8 = "core_debug_assert_eq_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_debug_assert_eq_u32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_debug_assert_eq_u64";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "core_debug_assert_ne_i32";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "core_debug_assert";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "core_debug_debug_assert";
      return p;
    }
    return 0 as *u8;
  }
  // PLATFORM: SHARED — core.slice formal API (mod.o). Glue from_ptr/subslice in slice.o.
  if (g == 9) {
    if (i == 0) {
      let p: *u8 = "core_slice_len_i32";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_slice_get_i32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_slice_get_i32_unchecked";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "core_slice_len_u8";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "core_slice_get_u8";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "core_slice_get_u8_unchecked";
      return p;
    }
    if (i == 6) {
      let p: *u8 = "core_slice_subslice_i32";
      return p;
    }
    if (i == 7) {
      let p: *u8 = "core_slice_subslice_u8";
      return p;
    }
    if (i == 8) {
      let p: *u8 = "core_slice_len_u64";
      return p;
    }
    if (i == 9) {
      let p: *u8 = "core_slice_get_u64";
      return p;
    }
    return 0 as *u8;
  }
  return 0 as *u8;
}

/** Return relative .o path for simple group g (repo-relative). */
#[no_mangle]
export function labi_od_simple_group_rel(g: i32): *u8 {
  if (g < 0) {
    return 0 as *u8;
  }
  if (g == 0) {
    let p: *u8 = "std/string/string.o";
    return p;
  }
  if (g == 1) {
    let p: *u8 = "core/types/types.o";
    return p;
  }
  if (g == 2) {
    let p: *u8 = "std/encoding/encoding.o";
    return p;
  }
  if (g == 3) {
    let p: *u8 = "std/base64/base64.o";
    return p;
  }
  if (g == 4) {
    let p: *u8 = "std/csv/csv.o";
    return p;
  }
  if (g == 5) {
    let p: *u8 = "std/schema/schema.o";
    return p;
  }
  if (g == 6) {
    let p: *u8 = "core/option/option.o";
    return p;
  }
  if (g == 7) {
    let p: *u8 = "core/result/result.o";
    return p;
  }
  if (g == 8) {
    let p: *u8 = "core/debug/debug.o";
    return p;
  }
  if (g == 9) {
    let p: *u8 = "core/slice/mod.o";
    return p;
  }
  return 0 as *u8;
}

/* KV: multi-sym → kv.o + optional glue rel */
#[no_mangle]
export function labi_od_kv_sym_count(): i32 {
  return 2;
}

/** Exported function `labi_od_kv_sym_at`.
 * Implements `labi_od_kv_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_kv_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "db_kv_open_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "db_kv_get_c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_od_kv_rel`.
 * Implements `labi_od_kv_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_kv_rel(): *u8 {
  let p: *u8 = "std/db/kv/kv.o";
  return p;
}

/** Exported function `labi_od_kv_glue_rel`.
 * Implements `labi_od_kv_glue_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_kv_glue_rel(): *u8 {
  let p: *u8 = "compiler/runtime_kv_mmap_glue.o";
  return p;
}

/* Arrow */
#[no_mangle]
export function labi_od_arrow_sym_count(): i32 {
  return 2;
}

/** Exported function `labi_od_arrow_sym_at`.
 * Implements `labi_od_arrow_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_arrow_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "arrow_column_i32_create_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "arrow_column_adopt_f32_c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_od_arrow_rel`.
 * Implements `labi_od_arrow_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_arrow_rel(): *u8 {
  let p: *u8 = "std/db/arrow/arrow.o";
  return p;
}

/** Exported function `labi_od_arrow_glue_rel`.
 * Implements `labi_od_arrow_glue_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_arrow_glue_rel(): *u8 {
  let p: *u8 = "compiler/runtime_arrow_simd_glue.o";
  return p;
}

/* Time */
#[no_mangle]
export function labi_od_time_sym_count(): i32 {
  return 4;
}

/** Exported function `labi_od_time_sym_at`.
 * Implements `labi_od_time_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_time_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_time_now_monotonic_ns";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_time_sleep_ms";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_time_timer_start";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "time_now_monotonic_ns_c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_od_time_rel`.
 * Implements `labi_od_time_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_time_rel(): *u8 {
  let p: *u8 = "std/time/time.o";
  return p;
}

/** Exported function `labi_od_time_os_rel`.
 * Implements `labi_od_time_os_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_time_os_rel(): *u8 {
  let p: *u8 = "compiler/runtime_time_os.o";
  return p;
}

/* Queue contention */
#[no_mangle]
export function labi_od_queue_sym_count(): i32 {
  return 3;
}

/** Exported function `labi_od_queue_sym_at`.
 * Implements `labi_od_queue_sym_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_od_queue_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "sync_queue_contention_smoke_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "queue_os_run_two_workers_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "queue_contention_worker_push_c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_od_queue_rel`.
 * Implements `labi_od_queue_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_queue_rel(): *u8 {
  let p: *u8 = "std/queue/queue.o";
  return p;
}

/** Exported function `labi_od_queue_contention_rel`.
 * Implements `labi_od_queue_contention_rel`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_queue_contention_rel(): *u8 {
  let p: *u8 = "compiler/runtime_queue_contention.o";
  return p;
}

/**
 * Count of UNDEF symbols that pull std/net/net.o on product asm on_demand.
 * @return i32 — 17 (std_net_* + net_*_c surface)
 * PLATFORM: SHARED — must match formal net.o export / C glue mangles
 */
#[no_mangle]
export function labi_od_net_sym_count(): i32 {
  return 17;
}

/**
 * Net on_demand UNDEF symbol at index (product probe table for needs_std_net).
 * @param i i32 — index in [0, 17)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_net_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_net_listen";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_net_connect";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_net_udp_bind";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_net_udp_recv_many_buf";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_net_udp_send_many_buf";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_net_addr_to_u32";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_net_close_udp";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "net_stream_write_batch_c";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "net_tcp_connect_c";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "net_tcp_listen_c";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "net_udp_bind_c";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "net_udp_recv_many_buf_c";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "net_udp_send_many_buf_c";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "net_close_socket_c";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "net_udp_send_c";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "net_dns_resolve_c";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "net_sock_create_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.net / net_*_c (on-demand chain net.o).
 * Pure orch: fixed net UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave118): hybrid still had needs_std_net body always mega C with hard-coded strings.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_net(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_net_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_net_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of UNDEF symbols that pull std/set/set.o on product asm on_demand.
 * @return i32 — 20 (formal overload mangles + legacy std_set_set_i32_*)
 * PLATFORM: SHARED — must match formal set.o export / historical user.o
 */
#[no_mangle]
export function labi_od_set_sym_count(): i32 {
  return 20;
}

/**
 * Set on_demand UNDEF symbol at index (product probe table for needs_std_set).
 * @param i i32 — index in [0, 20)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete existing needs_std_set authority (no second table)
 */
#[no_mangle]
export function labi_od_set_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_set_new_i32_retSet_i32";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_set_new_i32_retSet_u64";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_set_with_capacity_Set_i32_ptr_i32";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_set_insert_Set_i32_ptr_i32";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_set_insert_Set_u64_ptr_u64";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_set_contains_key_Set_i32_i32";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_set_contains_key_Set_u64_u64";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_set_remove_Set_i32_ptr_i32";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_set_remove_Set_u64_ptr_u64";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_set_len_Set_i32";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std_set_len_Set_u64";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std_set_deinit_Set_i32_ptr";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "std_set_deinit_Set_u64_ptr";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "std_set_str_new";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "std_set_str_insert";
    return p;
  }
  /* Legacy / alternate mangles: old user.o still pulls set.o. */
  if (i == 15) {
    let p: *u8 = "std_set_set_i32_insert";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "std_set_set_i32_contains";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "std_set_set_i32_remove";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "std_set_set_i32_len";
    return p;
  }
  if (i == 19) {
    let p: *u8 = "std_set_set_i32_deinit";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.set API (on-demand chain set.o + heap/hash deps).
 * Pure orch: fixed set UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave119): hybrid still had needs_std_set body always mega C with hard-coded strings.
 * Stale names alone never appear as U on product asm → set.o never pushed → BLD001 (Ubuntu).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_set(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_set_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_set_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of UNDEF symbols that pull std/map/map.o on product asm on_demand.
 * @return i32 — 9 (empty_size smoke + Map_i32_i32 surface + str map)
 * PLATFORM: SHARED — must match formal map.o export mangles
 */
#[no_mangle]
export function labi_od_map_sym_count(): i32 {
  return 9;
}

/**
 * Map on_demand UNDEF symbol at index (product probe table for needs_std_map).
 * @param i i32 — index in [0, 9)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete existing needs_std_map authority (no second table)
 */
#[no_mangle]
export function labi_od_map_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_map_empty_size";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_map_new_Map_i32_i32";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_map_with_capacity_Map_i32_i32_ptr_i32";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_map_insert_Map_i32_i32_ptr_i32_i32";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_map_get_Map_i32_i32_i32";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_map_find_Map_i32_i32_i32";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_map_deinit_Map_i32_i32_ptr";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_map_str_new";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_map_str_insert";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.map API (on-demand chain map.o + heap companions).
 * Pure orch: fixed map UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave120): hybrid still had needs_std_map body always mega C with hard-coded strings.
 * Complete authority was empty_size + full Map_i32/str surface; keep single table+orch in L8b.
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_map(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_map_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_map_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of product std.queue UNDEF symbols (tests/queue surface; not contention).
 * Complements labi_od_queue_sym_* (contention smoke only).
 * @return i32 — 12
 * PLATFORM: SHARED — must match formal queue.o export mangles
 */
#[no_mangle]
export function labi_od_queue_api_sym_count(): i32 {
  return 12;
}

/**
 * Product queue on_demand UNDEF symbol at index (needs_std_queue probe table).
 * @param i i32 — index in [0, 12)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete product needs_std_queue authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_queue_api_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_queue_new_retQueue_i32";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_queue_new_retQueue_u8";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_queue_push_back_Queue_i32_ptr_i32";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_queue_push_back_Queue_u8_ptr_u8";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_queue_push_front";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_queue_pop_front_Queue_i32_ptr";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_queue_pop_back";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_queue_get";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_queue_len_Queue_i32";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_queue_is_empty_Queue_i32";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std_queue_deinit_Queue_i32_ptr";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std_queue_with_capacity";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references product std.queue API (on-demand chain queue.o).
 * Pure orch: fixed product queue UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * Contention path stays labi_od_queue_sym_* + labi_od_user_needs_any_sym_table in mega.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave121): hybrid still had needs_std_queue body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; do not merge with contention table (different objs).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_queue(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_queue_api_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_queue_api_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of std.test on_demand UNDEF probes (product test.o gate).
 * Prefix-style entries (test_runner_ etc.) rely on Cap residual strstr
 * fallback inside shux_link_obj_needs_undef_sym (exact + substring).
 * @return i32 — 7
 * PLATFORM: SHARED — must match formal test.o / runner export prefixes
 */
#[no_mangle]
export function labi_od_test_sym_count(): i32 {
  return 7;
}

/**
 * Product test on_demand UNDEF symbol or prefix at index (needs_std_test probe table).
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string symbol/prefix, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_test authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_test_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "test_call_i32_void_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "test_runner_";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "test_expect_";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "test_bench_";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "test_f_test_";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "test_io_";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "test_fuzz_";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.test API (on-demand chain test.o).
 * Pure orch: fixed test UNDEF/prefix table; Cap residual shux_link_obj_needs_undef_sym.
 * Avoids unconditional test.o on hello-class minimal links (ld duplicate risk).
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave122): hybrid still had needs_std_test body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; prefixes intentionally retained (strstr Cap).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_test(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_test_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_test_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of core.mem on_demand UNDEF probes (product core/mem/mem.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 7
 * PLATFORM: SHARED — must match formal core/mem export surface
 */
#[no_mangle]
export function labi_od_core_mem_sym_count(): i32 {
  return 7;
}

/**
 * Product core.mem on_demand UNDEF symbol at index (needs_core_mem probe table).
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_core_mem authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_core_mem_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "core_mem_align_up";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "core_mem_align_down";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "core_mem_mem_copy";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "core_mem_mem_set";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "core_mem_mem_zero";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "core_mem_mem_move";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "core_mem_mem_compare";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references core.mem API (on-demand chain core/mem/mem.o).
 * Pure orch: fixed exact UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave123): hybrid still had needs_core_mem body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_core_mem(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_core_mem_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_core_mem_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of core.slice on_demand UNDEF probes (product core/slice glue gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 6
 * PLATFORM: SHARED — must match formal core/slice export surface used by needs_core_slice
 */
#[no_mangle]
export function labi_od_core_slice_sym_count(): i32 {
  return 6;
}

/**
 * Product core.slice on_demand UNDEF symbol at index (needs_core_slice probe table).
 * @param i i32 — index in [0, 6)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_core_slice authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_core_slice_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "core_slice_i32_from_ptr_c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "core_subslice_i32_c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "core_slice_u8_from_ptr_c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "core_subslice_u8_c";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "core_slice_u64_from_ptr_c";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "core_subslice_u64_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references core.slice glue API (on-demand chain core/slice/slice.o).
 * Pure orch: fixed exact UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave124): hybrid still had needs_core_slice body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_core_slice(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_core_slice_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_core_slice_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of std.heap.page_mmap on_demand UNDEF probes (product page_mmap.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 5
 * PLATFORM: SHARED — must match formal std/heap/page_mmap export surface
 */
#[no_mangle]
export function labi_od_page_mmap_sym_count(): i32 {
  return 5;
}

/**
 * Product std.heap.page_mmap on_demand UNDEF symbol at index (needs_std_heap_page_mmap probe table).
 * @param i i32 — index in [0, 5)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_heap_page_mmap authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_page_mmap_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_available";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_init";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_alloc";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_deinit";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_heap_page_mmap_page_mmap_heap_free";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.heap.page_mmap API (on-demand chain std/heap/page_mmap.o).
 * Pure orch: fixed exact UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * Freestanding mmap bump heap gate; transitive linux.o + core_mem.o covered by later on_demand.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave125): hybrid still had needs_std_heap_page_mmap body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_heap_page_mmap(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_page_mmap_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_page_mmap_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of std.sys.linux on_demand UNDEF probes (product linux.o freestanding gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 7
 * PLATFORM: SHARED — must match formal std/sys/linux export surface
 */
#[no_mangle]
export function labi_od_sys_linux_sym_count(): i32 {
  return 7;
}

/**
 * Product std.sys.linux on_demand UNDEF symbol at index (needs_std_sys_linux probe table).
 * @param i i32 — index in [0, 7)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_sys_linux authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_sys_linux_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_sys_linux_linux_syscall_invoke_available";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_sys_linux_linux_anonymous_mmap";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_sys_linux_linux_syscall_munmap";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_sys_linux_linux_syscall_read";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_sys_linux_linux_syscall_write";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_sys_linux_linux_syscall_close";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_sys_linux_linux_syscall_exit";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.sys.linux API (on-demand chain std/sys/linux.o).
 * Pure orch: fixed exact UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * F-no-libc freestanding Linux syscall thin wrappers (mmap/read/write/close/exit).
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave126): hybrid still had needs_std_sys_linux body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_sys_linux(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_sys_linux_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_sys_linux_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of std.sys facade on_demand UNDEF probes (product sys.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 8
 * PLATFORM: SHARED — must match formal std/sys export surface
 */
#[no_mangle]
export function labi_od_sys_sym_count(): i32 {
  return 8;
}

/**
 * Product std.sys on_demand UNDEF symbol at index (needs_std_sys probe table).
 * @param i i32 — index in [0, 8)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_sys authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_sys_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_sys_write_stdout";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_sys_write_stderr";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_sys_write";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_sys_read";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_sys_close";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_sys_exit";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_sys_freestanding_write_available";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_sys_linux_syscall_table_available";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.sys facade API (on-demand chain std/sys/sys.o).
 * Pure orch: fixed exact UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * F-no-libc: write_stdout/read/close/exit + freestanding availability probes.
 * On Linux, sys.o may transitively pull linux.o via cfg target_os.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave127): hybrid still had needs_std_sys body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_sys(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_sys_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_sys_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Count of std.heap formal API on_demand UNDEF probes (product heap.o gate).
 * Exact symbol names only (no prefix/strstr probes).
 * @return i32 — 25
 * PLATFORM: SHARED — must match formal std/heap export surface (incl. Allocator/libc family)
 */
#[no_mangle]
export function labi_od_heap_api_sym_count(): i32 {
  return 25;
}

/**
 * Product std.heap on_demand UNDEF symbol at index (needs_std_heap_api probe table).
 * @param i i32 — index in [0, 25)
 * @return *u8 — static C string symbol, or null if out of range
 * PLATFORM: SHARED — G.7 complete needs_std_heap_api authority (no second hard-coded list)
 */
#[no_mangle]
export function labi_od_heap_api_sym_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_heap_alloc_i32";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_heap_alloc_u8";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_heap_free_i32";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_heap_free_u8";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_heap_alloc_size_zero";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_heap_alloc_usize";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_heap_free_u8_ptr";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_heap_default_alloc";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_heap_kind_arena";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_heap_alloc_Allocator_usize";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std_heap_realloc_Allocator_u8_ptr_usize";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std_heap_free_Allocator_u8_ptr";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "std_heap_arena64_alloc";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "std_heap_libc_heap_arena64_alloc_c";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "std_heap_libc_heap_alloc_c";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "std_heap_libc_heap_free_c";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "std_heap_libc_heap_alloc_aligned_c";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "std_heap_libc_heap_alloc_i32_c";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "std_heap_libc_heap_alloc_u8_c";
    return p;
  }
  if (i == 19) {
    let p: *u8 = "std_heap_libc_heap_alloc_u64_c";
    return p;
  }
  if (i == 20) {
    let p: *u8 = "std_heap_libc_heap_free_i32_c";
    return p;
  }
  if (i == 21) {
    let p: *u8 = "std_heap_libc_heap_free_u8_c";
    return p;
  }
  if (i == 22) {
    let p: *u8 = "std_heap_libc_heap_free_u64_c";
    return p;
  }
  if (i == 23) {
    let p: *u8 = "std_heap_map_find";
    return p;
  }
  if (i == 24) {
    let p: *u8 = "std_heap_libc_heap_copy_u8_at_c";
    return p;
  }
  return 0 as *u8;
}

/**
 * Whether user .o references std.heap formal API (on-demand chain std/heap/heap.o).
 * Pure orch: fixed exact UNDEF table; Cap residual shux_link_obj_needs_undef_sym.
 * Covers typed alloc/free, Allocator/default/kind, arena64, and libc heap surface
 * used by formal set/map/queue/vec .o after import_alias C stubs were removed.
 * @param user_o *u8 — path to user .o; null/empty → 0
 * @return i32 — 1 if any UNDEF hits, else 0
 * Why (wave128): hybrid still had needs_std_heap_api body always mega C with hard-coded strings.
 * Keep single product table+orch in L8b; exact symbols only (no prefix table).
 * PLATFORM: SHARED — hybrid L8b pure; mega cold twin under #ifndef ONDEMAND_LIST_FROM_X.
 */
#[no_mangle]
export function link_abi_user_o_needs_std_heap_api(user_o: *u8): i32 {
  if (user_o == 0 as *u8) {
    return 0;
  }
  if (user_o[0] == 0) {
    return 0;
  }
  let n: i32 = labi_od_heap_api_sym_count();
  let i: i32 = 0;
  while (i < n) {
    let sym: *u8 = labi_od_heap_api_sym_at(i);
    if (sym != 0 as *u8) {
      if (sym[0] != 0) {
        let hit: i32 = 0;
        unsafe {
          hit = shux_link_obj_needs_undef_sym(user_o, sym);
        }
        if (hit != 0) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/* Pure rel constants for needs_* driven branches (early on_demand). */
/**
 * Relative path of formal std/net/net.o for on_demand push.
 * @return *u8 — static C string "std/net/net.o"
 * PLATFORM: SHARED
 */
#[no_mangle]
export function labi_od_rel_net(): *u8 {
  let p: *u8 = "std/net/net.o";
  return p;
}

/** Exported function `labi_od_rel_thread`.
 * Read path helper `labi_od_rel_thread`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_thread(): *u8 {
  let p: *u8 = "std/thread/thread.o";
  return p;
}

/** Exported function `labi_od_rel_heap`.
 * Implements `labi_od_rel_heap`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_heap(): *u8 {
  let p: *u8 = "std/heap/heap.o";
  return p;
}

/** Exported function `labi_od_rel_set`.
 * Implements `labi_od_rel_set`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_set(): *u8 {
  let p: *u8 = "std/set/set.o";
  return p;
}

/** Exported function `labi_od_rel_map`.
 * Implements `labi_od_rel_map`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_map(): *u8 {
  let p: *u8 = "std/map/map.o";
  return p;
}

/** Exported function `labi_od_rel_async_scheduler`.
 * Implements `labi_od_rel_async_scheduler`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_async_scheduler(): *u8 {
  let p: *u8 = "std/async/scheduler.o";
  return p;
}

/** Exported function `labi_od_rel_core_mem`.
 * Implements `labi_od_rel_core_mem`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_core_mem(): *u8 {
  let p: *u8 = "core/mem/mem.o";
  return p;
}

/** Exported function `labi_od_rel_sys_linux`.
 * Implements `labi_od_rel_sys_linux`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_sys_linux(): *u8 {
  let p: *u8 = "std/sys/linux.o";
  return p;
}

/** Exported function `labi_od_rel_page_mmap`.
 * Implements `labi_od_rel_page_mmap`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_page_mmap(): *u8 {
  let p: *u8 = "std/heap/page_mmap.o";
  return p;
}

/** Exported function `labi_od_rel_sys`.
 * Implements `labi_od_rel_sys`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_sys(): *u8 {
  let p: *u8 = "std/sys/sys.o";
  return p;
}

/** Exported function `labi_od_rel_core_slice`.
 * Implements `labi_od_rel_core_slice`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_core_slice(): *u8 {
  let p: *u8 = "core/slice/slice.o";
  return p;
}

/** Exported function `labi_od_rel_test`.
 * Implements `labi_od_rel_test`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_test(): *u8 {
  let p: *u8 = "std/test/test.o";
  return p;
}

/** Exported function `labi_od_rel_heap_user`.
 * Implements `labi_od_rel_heap_user`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_heap_user(): *u8 {
  let p: *u8 = "compiler/runtime_heap_user.o";
  return p;
}

/** Exported function `labi_od_rel_scheduler_glue`.
 * Implements `labi_od_rel_scheduler_glue`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_scheduler_glue(): *u8 {
  let p: *u8 = "compiler/runtime_scheduler_glue.o";
  return p;
}

/** Exported function `labi_od_rel_thread_glue`.
 * Read path helper `labi_od_rel_thread_glue`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_thread_glue(): *u8 {
  let p: *u8 = "compiler/runtime_thread_glue.o";
  return p;
}

/** Exported function `labi_od_rel_net_udp_batch`.
 * Implements `labi_od_rel_net_udp_batch`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_net_udp_batch(): *u8 {
  let p: *u8 = "compiler/runtime_net_udp_batch.o";
  return p;
}

/** Exported function `labi_od_rel_net_workers`.
 * Implements `labi_od_rel_net_workers`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_net_workers(): *u8 {
  let p: *u8 = "compiler/runtime_net_workers.o";
  return p;
}

/** Exported function `labi_od_rel_test_fn_invoke`.
 * Implements `labi_od_rel_test_fn_invoke`.
 * @return *u8
 */
#[no_mangle]
export function labi_od_rel_test_fn_invoke(): *u8 {
  let p: *u8 = "compiler/runtime_test_fn_invoke.o";
  return p;
}
