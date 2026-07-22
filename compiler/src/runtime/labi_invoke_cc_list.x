// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L5 invoke_cc pure table + orch (G.9 English; body is authoritative).
// Hybrid macro SHUX_LABI_INVOKE_CC_LIST_FROM_X (FROM_X rest business H=0, marker only).
// R2 full pure:
//   - labi_linux_harden_flag_{count,at}
//   - labi_invoke_cc_skip_native_env_{count,at} + invoke_cc_skip_native_tuning
//   - labi_icc_rel_* (12) + labi_icc_needs_rel_{count,at}
//   - shux_append_linux_link_harden_impl (wave155; pure orch over harden table)
//   - invoke_cc_append_early_needs (wave198; pure orch early needs scan+push)
// Cap residual: getenv (libc); host_is_* #if probes; ensure/path/needs peers;
//   fork/exec still mega shux_invoke_cc_impl (rest of large leaf).
// PLATFORM: SHARED tables/orch; LINUX consumers for harden -pie/-z flags.

export extern "C" function getenv(name: *u8): *u8;

/* ===== wave198 Cap residual / peer pure for invoke_cc early needs ===== */
export extern "C" function link_abi_generated_c_needs_core_builtin(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_core_mem(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_core_slice(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_db_kv(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_db_arrow(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_fs(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_random(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_time(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_runtime(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_win32(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_win32_wsa(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_libc_heap(c_path: *u8): i32;
export extern "C" function invoke_cc_argv_push_existing(argv: **u8, ia: *i32, max_ia: i32, path: *u8): i32;
export extern "C" function shux_rel_o_path_from_argv0(argv0: *u8, rel: *u8): *u8;
export extern "C" function shux_runtime_kv_mmap_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_arrow_simd_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_random_fill_o(argv0: *u8): i32;
export extern "C" function shux_runtime_random_fill_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_time_os_o(argv0: *u8): i32;
export extern "C" function shux_runtime_time_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_panic_o(argv0: *u8): i32;
export extern "C" function shux_runtime_panic_o_path(argv0: *u8): *u8;
export extern "C" function shux_host_is_linux(): i32;
export extern "C" function link_abi_host_is_apple(): i32;
export extern "C" function link_abi_host_is_windows(): i32;
export extern "C" function labi_ld_flag_lc(): *u8;
export extern "C" function labi_ld_flag_lbcrypt(): *u8;
export extern "C" function labi_ld_flag_lws2_32(): *u8;

/** Exported function `labi_linux_harden_flag_count`.
 * Implements `labi_linux_harden_flag_count`.
 * @return i32
 */
#[no_mangle]
export function labi_linux_harden_flag_count(): i32 {
  return 5;
}

/** Exported function `labi_linux_harden_flag_at`.
 * Implements `labi_linux_harden_flag_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_linux_harden_flag_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-pie";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-fpie";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "-Wl,-z,noexecstack";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "-Wl,-z,relro";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "-Wl,--allow-multiple-definition";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_invoke_cc_skip_native_env_count`.
 * Implements `labi_invoke_cc_skip_native_env_count`.
 * @return i32
 */
#[no_mangle]
export function labi_invoke_cc_skip_native_env_count(): i32 {
  return 3;
}

/** Exported function `labi_invoke_cc_skip_native_env_at`.
 * Implements `labi_invoke_cc_skip_native_env_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_invoke_cc_skip_native_env_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "CI";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "SHUX_CI_DOCKER";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "SHUX_NO_MARCH_NATIVE";
    return p;
  }
  return 0 as *u8;
}

// invoke_cc_skip_native_tuning: see function docblock below.
/** Exported function `invoke_cc_skip_native_tuning`.
 * Implements `invoke_cc_skip_native_tuning`.
 * @return i32
 */
#[no_mangle]
export function invoke_cc_skip_native_tuning(): i32 {
  let n: i32 = labi_invoke_cc_skip_native_env_count();
  let i: i32 = 0;
  while (i < n) {
    let name: *u8 = labi_invoke_cc_skip_native_env_at(i);
    if (name != 0 as *u8) {
      if (name[0] != 0) {
        let v: *u8 = 0 as *u8;
        unsafe {
          v = getenv(name);
        }
        if (v != 0 as *u8) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `labi_icc_rel_core_builtin_o`.
 * Implements `labi_icc_rel_core_builtin_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_core_builtin_o(): *u8 {
  let p: *u8 = "core/builtin/builtin.o";
  return p;
}

/** Exported function `labi_icc_rel_core_builtin_abi_h`.
 * Implements `labi_icc_rel_core_builtin_abi_h`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_core_builtin_abi_h(): *u8 {
  let p: *u8 = "core/builtin/builtin_abi.h";
  return p;
}

/** Exported function `labi_icc_rel_core_mem_o`.
 * Implements `labi_icc_rel_core_mem_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_core_mem_o(): *u8 {
  let p: *u8 = "core/mem/mem.o";
  return p;
}

/** Exported function `labi_icc_rel_core_slice_o`.
 * Implements `labi_icc_rel_core_slice_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_core_slice_o(): *u8 {
  let p: *u8 = "core/slice/slice.o";
  return p;
}

/** Exported function `labi_icc_rel_db_kv_o`.
 * Implements `labi_icc_rel_db_kv_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_db_kv_o(): *u8 {
  let p: *u8 = "std/db/kv/kv.o";
  return p;
}

/** Exported function `labi_icc_rel_db_arrow_o`.
 * Implements `labi_icc_rel_db_arrow_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_db_arrow_o(): *u8 {
  let p: *u8 = "std/db/arrow/arrow.o";
  return p;
}

/** Exported function `labi_icc_rel_csv_o`.
 * Implements `labi_icc_rel_csv_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_csv_o(): *u8 {
  let p: *u8 = "std/csv/csv.o";
  return p;
}

/** Exported function `labi_icc_rel_error_o`.
 * Implements `labi_icc_rel_error_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_error_o(): *u8 {
  let p: *u8 = "std/error/error.o";
  return p;
}

/** Exported function `labi_icc_rel_heap_o`.
 * Implements `labi_icc_rel_heap_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_heap_o(): *u8 {
  let p: *u8 = "std/heap/heap.o";
  return p;
}

/** Exported function `labi_icc_rel_json_o`.
 * Implements `labi_icc_rel_json_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_json_o(): *u8 {
  let p: *u8 = "std/json/json.o";
  return p;
}

/** Exported function `labi_icc_rel_log_o`.
 * Implements `labi_icc_rel_log_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_log_o(): *u8 {
  let p: *u8 = "std/log/log.o";
  return p;
}

/** Exported function `labi_icc_rel_socketio_o`.
 * Implements `labi_icc_rel_socketio_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_socketio_o(): *u8 {
  let p: *u8 = "std/socketio/socketio.o";
  return p;
}

/** Exported function `labi_icc_needs_rel_count`.
 * Implements `labi_icc_needs_rel_count`.
 * @return i32
 */
#[no_mangle]
export function labi_icc_needs_rel_count(): i32 {
  return 12;
}

/** Exported function `labi_icc_needs_rel_at`.
 * Implements `labi_icc_needs_rel_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_icc_needs_rel_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "core/builtin/builtin.o";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "core/builtin/builtin_abi.h";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "core/mem/mem.o";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "core/slice/slice.o";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std/db/kv/kv.o";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std/db/arrow/arrow.o";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std/csv/csv.o";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std/error/error.o";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std/heap/heap.o";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std/json/json.o";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std/log/log.o";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std/socketio/socketio.o";
    return p;
  }
  return 0 as *u8;
}

/**
 * Append Linux release link-hardening flags onto a cc/ld argv (PIE + NX stack + partial RELRO).
 * Scans pure labi_linux_harden_flag_count/at and appends each non-empty flag while capacity remains.
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op; *la < 0 → no-op
 * @param cap i32 — argv capacity; leave one slot for NULL terminator (cap - 1)
 * @return void — appends zero or more harden flags; skips null/empty table entries
 * Pure orch: pure harden table count/at + capacity-guarded append loop (≡ mega cold twin).
 * Why (wave155): hybrid still had always-mega C body for Linux harden flag append over pure table.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Callers: pure gate shux_append_linux_link_harden (labi_gates) + product invoke_cc/ld paths.
 * PLATFORM: SHARED orch / LINUX consumers (flags are Linux ld/gcc -Wl,-z*; mac no-op if not called).
 * Track-L: #[no_mangle] keeps surface short name matching mega / gates Cap residual extern.
 */
#[no_mangle]
export function shux_append_linux_link_harden_impl(argv: **u8, la: *i32, cap: i32): void {
  // Guard argv null via *u8 cast (wave147/151–154: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  // Mega rejects negative length; leave one slot for argv NULL terminator.
  if (la[0] < 0) {
    return;
  }
  let n: i32 = labi_linux_harden_flag_count();
  let k: i32 = 0;
  while (k < n) {
    let cur: i32 = la[0];
    if (cur >= cap - 1) {
      break;
    }
    let f: *u8 = labi_linux_harden_flag_at(k);
    k = k + 1;
    if (f == 0 as *u8) {
      continue;
    }
    if (f[0] == 0) {
      continue;
    }
    // Store table pointer (static string lifetime from pure flag_at; no copy).
    argv[cur] = f;
    la[0] = cur + 1;
  }
}

/**
 * Capacity-guarded push of one non-empty flag onto invoke_cc argv.
 * @param argv **u8 — argv table; null → no-op
 * @param ia *i32 — in/out length; null or *ia < 0 → no-op
 * @param cap i32 — capacity; leave one slot for NULL terminator
 * @param flag *u8 — flag string; null/empty skipped
 * @return void
 * PLATFORM: SHARED helper for wave198 early needs flag appends (-lc / -lbcrypt / …).
 * Track-L: #[no_mangle] keeps surface short name for prove IDENTICAL (no module mangle).
 */
#[no_mangle]
export function labi_icc_argv_try_push_flag(argv: **u8, ia: *i32, cap: i32, flag: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }
  if (flag == 0 as *u8) {
    return;
  }
  if (flag[0] == 0) {
    return;
  }
  let cur: i32 = ia[0];
  if (cur >= cap - 1) {
    return;
  }
  argv[cur] = flag;
  ia[0] = cur + 1;
}

/**
 * invoke_cc early needs: scan generated C paths then ensure/push core|db|fs|random|time|runtime|win32|heap.
 * Composes peer pure needs_* / rel_o / push_existing / path / ensure + host_is_* platform gates.
 * @param argv **u8 — cc argv table (char**); null → no-op
 * @param ia *i32 — in/out argv length; null → no-op; *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity; leave one slot for NULL terminator
 * @param c_paths **u8 — generated C path table; null or n < 1 → no-op scan
 * @param n i32 — number of c_paths entries
 * @param include_root *u8 — repo/include root for rel_o_path (nullable)
 * @param random_o *u8 — product random.o path (nullable; push_existing skips missing)
 * @param time_o *u8 — product time.o path (nullable)
 * @param runtime_o *u8 — product runtime.o path (nullable)
 * @param runtime_panic_o *u8 — product runtime_panic.o path (nullable)
 * @return void — may append -include / .o paths / -l* flags; mutates *ia
 * Pure orch: ≡ mega early block inside shux_invoke_cc_impl (pre-MINIMAL_CC_LINK).
 * Cap residual: generated_c_needs_* (file view peers) + ensure_runtime_* + host_is_windows
 *   + peer push_existing resolve pool; host_is_linux / host_is_apple for -lc POSIX gate.
 * Why (wave198): hybrid still had early needs scan+push always-mega inside invoke_cc_impl.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Callers: mega shux_invoke_cc_impl child argv build (SHARED product C link path).
 * PLATFORM: SHARED orch / POSIX -lc (linux|apple) / WINDOWS -lbcrypt -lkernel32 -lws2_32.
 * Track-L: #[no_mangle] keeps surface short name for mega call sites.
 */
#[no_mangle]
export function invoke_cc_append_early_needs(argv: **u8, ia: *i32, argv_cap: i32, c_paths: **u8, n: i32, include_root: *u8, random_o: *u8, time_o: *u8, runtime_o: *u8, runtime_panic_o: *u8): void {
  // Guard argv/ia null via *u8 cast (wave147/151–197: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }
  let needs_core_builtin: i32 = 0;
  let needs_core_mem: i32 = 0;
  let needs_core_slice: i32 = 0;
  let needs_db_kv: i32 = 0;
  let needs_db_arrow: i32 = 0;
  let needs_fs: i32 = 0;
  let needs_random: i32 = 0;
  let needs_time: i32 = 0;
  let needs_runtime: i32 = 0;
  let needs_win32: i32 = 0;
  let needs_win32_wsa: i32 = 0;
  let needs_libc_heap: i32 = 0;
  // Scan all generated C paths (peer pure needs_* use_line / marker gates).
  if (n > 0) {
    let cpb: *u8 = c_paths as *u8;
    if (cpb != 0 as *u8) {
      let j: i32 = 0;
      while (j < n) {
        let cp: *u8 = c_paths[j];
        j = j + 1;
        if (cp == 0 as *u8) {
          continue;
        }
        unsafe {
          if (link_abi_generated_c_needs_core_builtin(cp) != 0) {
            needs_core_builtin = 1;
          }
          if (link_abi_generated_c_needs_core_mem(cp) != 0) {
            needs_core_mem = 1;
          }
          if (link_abi_generated_c_needs_core_slice(cp) != 0) {
            needs_core_slice = 1;
          }
          if (link_abi_generated_c_needs_db_kv(cp) != 0) {
            needs_db_kv = 1;
          }
          if (link_abi_generated_c_needs_db_arrow(cp) != 0) {
            needs_db_arrow = 1;
          }
          if (link_abi_generated_c_needs_fs(cp) != 0) {
            needs_fs = 1;
          }
          if (link_abi_generated_c_needs_random(cp) != 0) {
            needs_random = 1;
          }
          if (link_abi_generated_c_needs_time(cp) != 0) {
            needs_time = 1;
          }
          if (link_abi_generated_c_needs_runtime(cp) != 0) {
            needs_runtime = 1;
          }
          if (link_abi_generated_c_needs_win32(cp) != 0) {
            needs_win32 = 1;
          }
          if (link_abi_generated_c_needs_win32_wsa(cp) != 0) {
            needs_win32_wsa = 1;
          }
          if (link_abi_generated_c_needs_libc_heap(cp) != 0) {
            needs_libc_heap = 1;
          }
        }
      }
    }
  }
  // core.builtin: -include abi.h then push builtin.o when present.
  if (needs_core_builtin != 0) {
    let abi_h: *u8 = 0 as *u8;
    unsafe {
      abi_h = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_abi_h());
    }
    if (abi_h != 0 as *u8) {
      if (abi_h[0] != 0) {
        let cur: i32 = ia[0];
        if (cur < argv_cap - 2) {
          let inc: *u8 = "-include";
          argv[cur] = inc;
          ia[0] = cur + 1;
          argv[ia[0]] = abi_h;
          ia[0] = ia[0] + 1;
        }
      }
    }
    let bpath: *u8 = 0 as *u8;
    unsafe {
      bpath = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_o());
      let _p0: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, bpath);
    }
  }
  if (needs_core_mem != 0) {
    unsafe {
      let p: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o());
      let _pm: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
    }
  }
  if (needs_core_slice != 0) {
    unsafe {
      let p: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_slice_o());
      let _ps: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
    }
  }
  if (needs_db_kv != 0) {
    unsafe {
      let p: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_kv_o());
      let _pk: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
      let rkv: *u8 = shux_runtime_kv_mmap_glue_o_path(0 as *u8);
      if (rkv != 0 as *u8) {
        if (rkv[0] != 0) {
          let _pk2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rkv);
        }
      }
    }
  }
  if (needs_db_arrow != 0) {
    unsafe {
      let p: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_arrow_o());
      let _pa: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
      let rar: *u8 = shux_runtime_arrow_simd_glue_o_path(0 as *u8);
      if (rar != 0 as *u8) {
        if (rar[0] != 0) {
          let _pa2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rar);
        }
      }
    }
  }
  // -lc on POSIX when fs needs libc (mega #if linux||apple).
  if (needs_fs != 0) {
    let is_posix: i32 = 0;
    unsafe {
      is_posix = shux_host_is_linux();
      if (is_posix == 0) {
        is_posix = link_abi_host_is_apple();
      }
    }
    if (is_posix != 0) {
      let flc: *u8 = 0 as *u8;
      unsafe {
        flc = labi_ld_flag_lc();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc);
    }
  }
  // random.o + ensure random_fill before push (L4 cold tree; G.7 ensure-then-push).
  if (needs_random != 0) {
    unsafe {
      let _pr: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, random_o);
      let _er: i32 = shux_ensure_runtime_random_fill_o(0 as *u8);
      let rrf: *u8 = shux_runtime_random_fill_o_path(0 as *u8);
      if (rrf != 0 as *u8) {
        if (rrf[0] != 0) {
          let _pr2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rrf);
        }
      }
    }
    // PLATFORM: WINDOWS — BCrypt needs -lbcrypt; Linux/macOS use getrandom/getentropy.
    let is_win: i32 = 0;
    unsafe {
      is_win = link_abi_host_is_windows();
    }
    if (is_win != 0) {
      let fbc: *u8 = 0 as *u8;
      unsafe {
        fbc = labi_ld_flag_lbcrypt();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fbc);
    }
  }
  if (needs_time != 0) {
    unsafe {
      let _pt: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, time_o);
      let _et: i32 = shux_ensure_runtime_time_os_o(0 as *u8);
      let rto: *u8 = shux_runtime_time_os_o_path(0 as *u8);
      if (rto != 0 as *u8) {
        if (rto[0] != 0) {
          let _pt2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rto);
        }
      }
    }
  }
  if (needs_runtime != 0) {
    unsafe {
      let _prt: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_o);
      let _ep: i32 = shux_ensure_runtime_panic_o(0 as *u8);
      let _pp: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_panic_o);
      let rp: *u8 = shux_runtime_panic_o_path(0 as *u8);
      if (rp != 0 as *u8) {
        if (rp[0] != 0) {
          let _pp2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rp);
        }
      }
    }
  }
  // PLATFORM: WINDOWS — win32 / WSA link flags only when generated C needs them.
  if (needs_win32 != 0) {
    let is_win2: i32 = 0;
    unsafe {
      is_win2 = link_abi_host_is_windows();
    }
    if (is_win2 != 0) {
      let fk: *u8 = "-lkernel32";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fk);
    }
  }
  if (needs_win32_wsa != 0) {
    let is_win3: i32 = 0;
    unsafe {
      is_win3 = link_abi_host_is_windows();
    }
    if (is_win3 != 0) {
      let fws: *u8 = 0 as *u8;
      unsafe {
        fws = labi_ld_flag_lws2_32();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fws);
    }
  }
  if (needs_libc_heap != 0) {
    let is_posix2: i32 = 0;
    unsafe {
      is_posix2 = shux_host_is_linux();
      if (is_posix2 == 0) {
        is_posix2 = link_abi_host_is_apple();
      }
    }
    if (is_posix2 != 0) {
      let flc2: *u8 = 0 as *u8;
      unsafe {
        flc2 = labi_ld_flag_lc();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc2);
    }
  }
}
