// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-343/344/345/387/388/400–402/413/414/416 + getenv/数值 env pure 深迁：runtime_driver_abi R2 thin。
// 产品 PREFER_X_O：thin.o + full seed rest（-DSHUX_L2_RDABI_THIN_FROM_X）ld -r → runtime_driver_abi.o
// prove IDENTICAL：thin.x ↔ seeds/runtime_driver_abi_thin_surface.from_x.c（公共面 61+；_impl 仍 U / rest）
// pure 深迁：scan/has/argv_collect/target_os/fail/smoke/peek/entry_len_i32/large_stack orch
//   + getenv 门闩（非空且非 '0' → 1）
//   + 数值 env（parse_u32 + stack_limit_want_bytes + phase_timing_enabled 非空 getenv）真体在 thin.x。
//   + wave1 Cap residual pure：9× i32 flag-slot BSS 进 thin（check_only / diag_emitted /
//     freestanding / sanitize / fmt_check_only / skip_typeck / skip_codegen / skip_dep0 /
//     large_stack_thread）；FROM_X rest 无 pure-dup flag_slot _impl。
//   + wave2 Cap residual pure：path/len BSS 进 thin（dep path *u8 · entry_source_len i64 ·
//     path_last_preprocess_len i64）；FROM_X rest 无 pure-dup path/len store/load _impl。
//   + wave3 Cap residual pure：format print（check_ok / fail rc·path / smoke parse·typeck）
//     via driver_diag_append_* + diag_report*（no va_list reportf）；FROM_X rest 无 pure-dup
//     print/fail format _impl。
//   + wave4 Cap residual pure：defines_set_at（G.7 shux_ptr_slot_set）+ os_define_lit
//     string-lit table；FROM_X rest 无 pure-dup set_at/os_lit _impl。
//   + wave5 Cap residual pure：phase timing BSS + begin/end（f64 acc/start + active i32）
//     真迁 thin；FROM_X rest 无 pure-dup begin/end _impl。
//   + wave6 Cap residual pure：phase_timing_flush 真迁 thin（whole-ms i32 via append_* +
//     diag_report；no va_list reportf floats）；FROM_X rest 无 pure-dup flush _impl。
// Cap residual：uname / setrlimit / pthread 创建 / path-read IO /
//   debug_pipe reportf note / gettimeofday phase_now 仍 rest。
//

export extern "C" function getenv(name: *u8): *u8;
export extern "C" function driver_path_read_preprocess_malloc_impl(path: *u8): *u8;
// Wave3 format print pure: reuse diagnostic append authority (G.7) + fixed-arity diag report.
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
export extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function driver_diag_append_cstr(dst: *u8, cap: i32, at: i32, src: *u8): i32;
export extern "C" function driver_diag_append_i32(dst: *u8, cap: i32, at: i32, val: i32): i32;
// Wave4: G.7 reuse pipeline pointer-slot authority for defines[i] = s (arr is **u8 as *u8).
export extern "C" function shux_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;

// ---- Wave1 Cap residual pure: driver flag-slot BSS (PLATFORM: SHARED) ----
// Authority lives in this thin TU under PREFER hybrid; cold seed keeps C static BSS.
// Use i32[1] so &g[0] is a stable *i32 (scalar let address form is less portable in -E).
// nostdlib: plain BSS (not TLS) — see seed comment on large_stack_thread flag.
let g_driver_check_only_flag: i32[1] = [0];
let g_driver_check_diag_emitted_flag: i32[1] = [0];
let g_driver_freestanding_flag: i32[1] = [0];
let g_driver_sanitize_address_flag: i32[1] = [0];
let g_driver_fmt_check_only_flag: i32[1] = [0];
let g_driver_x_pipeline_skip_typeck_flag: i32[1] = [0];
let g_driver_x_pipeline_skip_codegen_flag: i32[1] = [0];
let g_driver_skip_codegen_dep_0_flag: i32[1] = [0];
let g_driver_on_large_stack_thread_flag: i32[1] = [0];

// ---- Wave2 Cap residual pure: path/len BSS (PLATFORM: SHARED) ----
// dep path: single *u8 cell (import logic path pointer; no owned buffer).
// entry_source_len / path_last_preprocess_len: i64[1] so store/load use [0] without &scalar.
// Rest path_read_impl writes preprocess len via driver_path_last_preprocess_len_store.
// Hybrid pure load of entry_source_len skips SHUX_DEBUG_PIPE reportf (cold seed keeps note).
let g_driver_current_dep_path: *u8 = 0 as *u8;
let g_pipeline_entry_source_len: i64[1] = [0];
let g_driver_path_last_preprocess_len: i64[1] = [0];

// ---- Wave5 Cap residual pure: compile phase timing BSS (PLATFORM: SHARED) ----
// phase 0=parse 1=typeck 2=codegen. Hybrid thin owns acc_ms/start_sec/active cells;
// cold seed keeps C static BSS. flush Cap (diag_reportf floats) reads via
// driver_compile_phase_acc_ms_get + driver_compile_phase_timing_clear.
let g_compile_phase_acc_ms: f64[3] = [0.0, 0.0, 0.0];
let g_compile_phase_start_sec: f64[3] = [0.0, 0.0, 0.0];
let g_compile_phase_active: i32[3] = [0, 0, 0];

// pure：getenv 非空且首字节非 '0' → 1（与 seed Cap residual 同形）。
// 调用点用字符串字面量（-E → 实参 compound lit，生命周期覆盖 call；勿用全局 let u8[]：
// -E 会降成指针 + 未调用的 init_globals，悬空/NULL → getenv SIGSEGV）。
function driver_env_flag_truthy(name: *u8): i32 {
  unsafe {
    let e: *u8 = getenv(name);
    if (e == 0 as *u8) {
      return 0;
    }
    if (e[0] == 0) {
      return 0;
    }
    if (e[0] == 48) {
      return 0;
    }
    return 1;
  }
  return 0;
}

// pure：getenv 非空 → 1（phase timing：空串亦启用，与 seed 同形；≠ truthy）。
function driver_env_nonnull(name: *u8): i32 {
  unsafe {
    let e: *u8 = getenv(name);
    if (e == 0 as *u8) {
      return 0;
    }
    return 1;
  }
  return 0;
}

// pure：十进制 u32 解析；非数字 / 空 → -1（与 seed driver_parse_u32_cstr 同形）。
function driver_parse_u32_cstr(s: *u8): i64 {
  if (s == 0 as *u8) {
    return 0 - 1;
  }
  if (s[0] == 0) {
    return 0 - 1;
  }
  let n: i64 = 0;
  let i: i32 = 0;
  while (i < 20) {
    if (s[i] == 0) {
      break;
    }
    let c: i32 = s[i] as i32;
    if (c < 48) {
      return 0 - 1;
    }
    if (c > 57) {
      return 0 - 1;
    }
    n = n * 10 + (c - 48) as i64;
    i = i + 1;
  }
  if (i == 0) {
    return 0 - 1;
  }
  return n;
}

// driver_check_quiet_ok_get：weak default 由 seed 提供，强符号由 fmt_check_cmd 提供。
// thin.x 不导出，仅 extern 声明供 driver_print_check_ok 调用。
export extern "C" function driver_check_quiet_ok_get(): i32;

export extern "C" function driver_argv_at(argv: *u8, i: i32): *u8;
export extern "C" function shux_cstr_offset(s: *u8, off: i32): *u8;
export extern "C" function driver_argv_collect_append_uname_impl(defines: *u8, ndefines: i32, max_defines: i32): i32;
export extern "C" function driver_get_module_num_funcs(m: *u8): i32;
export extern "C" function driver_get_module_main_func_index(m: *u8): i32;
export extern "C" function shux_read_file_into_path(path: *u8, buf: *u8, cap: i64): i32;
export extern "C" function free(p: *u8): void;
export extern "C" function bootstrap_nostdlib_pthread_is_stub(): i32;
export extern "C" function driver_run_thread_on_large_stack_pthread_impl(fn: *u8, arg: *u8): void;

// pure: return address of module BSS flag cell (cold seed keeps C static + flag_slot).
#[no_mangle]
export function driver_check_only_flag_slot(): *i32 {
  return &g_driver_check_only_flag[0];
}

#[no_mangle]
export function driver_check_diag_emitted_flag_slot(): *i32 {
  return &g_driver_check_diag_emitted_flag[0];
}

#[no_mangle]
export function driver_freestanding_flag_slot(): *i32 {
  return &g_driver_freestanding_flag[0];
}

#[no_mangle]
export function driver_sanitize_address_flag_slot(): *i32 {
  return &g_driver_sanitize_address_flag[0];
}

#[no_mangle]
export function driver_fmt_check_only_flag_slot(): *i32 {
  return &g_driver_fmt_check_only_flag[0];
}

#[no_mangle]
export function driver_x_pipeline_skip_typeck_flag_slot(): *i32 {
  return &g_driver_x_pipeline_skip_typeck_flag[0];
}

#[no_mangle]
export function driver_x_pipeline_skip_codegen_flag_slot(): *i32 {
  return &g_driver_x_pipeline_skip_codegen_flag[0];
}

#[no_mangle]
export function driver_skip_codegen_dep_0_flag_slot(): *i32 {
  return &g_driver_skip_codegen_dep_0_flag[0];
}

#[no_mangle]
export function driver_large_stack_thread_flag_slot(): *i32 {
  return &g_driver_on_large_stack_thread_flag[0];
}

/** Store current codegen dep path pointer into thin BSS (no copy; caller owns string).
 * PLATFORM: SHARED — hybrid pure authority; cold seed keeps C static + store_impl. */
#[no_mangle]
export function driver_current_dep_path_store(path: *u8): void {
  g_driver_current_dep_path = path;
}

/** Load current codegen dep path pointer from thin BSS (may be null).
 * PLATFORM: SHARED — hybrid pure authority. */
#[no_mangle]
export function driver_current_dep_path_load(): *u8 {
  return g_driver_current_dep_path;
}

/** Store pipeline entry source byte length into thin BSS.
 * Parameters: len — preprocess-or-entry source size in bytes (saturated by callers if needed).
 * PLATFORM: SHARED — hybrid pure authority. */
#[no_mangle]
export function driver_pipeline_entry_source_len_store(len: i64): void {
  g_pipeline_entry_source_len[0] = len;
}

/** Store last path_read_preprocess result length into thin BSS.
 * Called by rest path_read_impl after preprocess (and reset to 0 on entry/fail paths).
 * PLATFORM: SHARED — hybrid pure authority; cold seed keeps C static + store. */
#[no_mangle]
export function driver_path_last_preprocess_len_store(len: i64): void {
  g_driver_path_last_preprocess_len[0] = len;
}

/** Return last path_read_preprocess length from thin BSS.
 * PLATFORM: SHARED — hybrid pure authority. */
#[no_mangle]
export function driver_path_last_preprocess_len(): i64 {
  return g_driver_path_last_preprocess_len[0];
}

#[no_mangle]
export function driver_path_read_preprocess_malloc(path: *u8): *u8 {
  unsafe { return driver_path_read_preprocess_malloc_impl(path); }
  return 0 as *u8;
}

#[no_mangle]
export function driver_fmt_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_fmt_check_only_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_large_stack_thread_mark(on: i32): void {
  unsafe {
    let p: *i32 = driver_large_stack_thread_flag_slot();
    p[0] = on;
  }
}

#[no_mangle]
export function driver_is_large_stack_thread(): i32 {
  unsafe {
    let p: *i32 = driver_large_stack_thread_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function driver_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_check_only_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_skip_codegen_dep_0_get(): i32 {
  unsafe {
    let p: *i32 = driver_skip_codegen_dep_0_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function driver_x_pipeline_skip_typeck_get(): i32 {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_typeck_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function driver_freestanding_get(): i32 {
  unsafe {
    let p: *i32 = driver_freestanding_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function driver_check_only_get(): i32 {
  unsafe {
    let p: *i32 = driver_check_only_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

/** Alias for driver_current_dep_path_store (pipeline codegen loop per-dep).
 * PLATFORM: SHARED — pure forward to path BSS store. */
#[no_mangle]
export function driver_set_current_dep_path_for_codegen(path: *u8): void {
  driver_current_dep_path_store(path);
}

// G-02f-245 pure 深迁：target → OS kind（字节 contains，无 strstr）
export function driver_argv_is_D_alone(arg: *u8): i32 {
  if (arg == 0 as *u8) { return 0; }
  unsafe {
    if (arg[0] != 45) { return 0; }
    if (arg[1] != 68) { return 0; }
    if (arg[2] != 0) { return 0; }
    return 1;
  }
  return 0;
}
export function driver_argv_is_D_inline(arg: *u8): i32 {
  if (arg == 0 as *u8) { return 0; }
  unsafe {
    if (arg[0] != 45) { return 0; }
    if (arg[1] != 68) { return 0; }
    if (arg[2] == 0) { return 0; }
    return 1;
  }
  return 0;
}
export function driver_argv_is_target_flag(arg: *u8): i32 {
  if (arg == 0 as *u8) { return 0; }
  unsafe {
    if (arg[0] != 45) { return 0; }
    if (arg[1] != 116) { return 0; }
    if (arg[2] != 97) { return 0; }
    if (arg[3] != 114) { return 0; }
    if (arg[4] != 103) { return 0; }
    if (arg[5] != 101) { return 0; }
    if (arg[6] != 116) { return 0; }
    if (arg[7] != 0) { return 0; }
    return 1;
  }
  return 0;
}
export function driver_argv_is_value_skip_flag(arg: *u8): i32 {
  if (arg == 0 as *u8) { return 0; }
  unsafe {
    if (arg[0] != 45) { return 0; }
    if (arg[1] == 111) { if (arg[2] == 0) { return 1; } }
    if (arg[1] == 76) { if (arg[2] == 0) { return 1; } }
    if (arg[1] == 79) { if (arg[2] == 0) { return 1; } }
    if (arg[1] == 98) {
      if (arg[2] == 97) {
        if (arg[3] == 99) {
          if (arg[4] == 107) {
            if (arg[5] == 101) {
              if (arg[6] == 110) {
                if (arg[7] == 100) {
                  if (arg[8] == 0) { return 1; }
                }
              }
            }
          }
        }
      }
    }
  }
  return 0;
}
export function driver_cstr_contains_bytes(hay: *u8, n0: u8, n1: u8, n2: u8, n3: u8, n4: u8, nlen: i32): i32 {
  if (hay == 0 as *u8) { return 0; }
  if (nlen <= 0) { return 0; }
  unsafe {
    let i: i32 = 0;
    while (i < 4096) {
      if (hay[i] == 0) { return 0; }
      if (hay[i] == n0) {
        if (nlen == 1) { return 1; }
        if (hay[i + 1] == n1) {
          if (nlen == 2) { return 1; }
          if (hay[i + 2] == n2) {
            if (nlen == 3) { return 1; }
            if (hay[i + 3] == n3) {
              if (nlen == 4) { return 1; }
              if (hay[i + 4] == n4) { return 1; }
            }
          }
        }
      }
      i = i + 1;
    }
  }
  return 0;
}
#[no_mangle]
export function driver_target_arg_os_kind(target: *u8): i32 {
  if (target == 0 as *u8) { return 0; }
  if (driver_cstr_contains_bytes(target, 108, 105, 110, 117, 120, 5) != 0) { return 1; }
  if (driver_cstr_contains_bytes(target, 100, 97, 114, 119, 105, 5) != 0) { return 2; }
  if (driver_cstr_contains_bytes(target, 97, 112, 112, 108, 101, 5) != 0) { return 2; }
  if (driver_cstr_contains_bytes(target, 102, 114, 101, 101, 98, 5) != 0) { return 3; }
  if (driver_cstr_contains_bytes(target, 119, 105, 110, 100, 111, 5) != 0) { return 4; }
  return 0;
}

#[no_mangle]
export function driver_x_pipeline_skip_typeck_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_typeck_flag_slot();
    p[0] = v;
  }
}

// driver_check_quiet_ok_get：weak default 由 seed 提供（fmt_check_cmd 强符号覆盖）。
// thin.x 不导出，避免与 fmt_check_cmd_thin.x 的强符号冲突。

#[no_mangle]
export function driver_x_pipeline_skip_codegen_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_codegen_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_sanitize_address_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_sanitize_address_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_x_pipeline_skip_codegen_get(): i32 {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_codegen_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function driver_skip_codegen_dep_0_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_skip_codegen_dep_0_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_freestanding_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_freestanding_flag_slot();
    p[0] = v;
  }
}

#[no_mangle]
export function driver_check_diag_emitted_note(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 1;
  }
}

#[no_mangle]
export function driver_check_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 0;
  }
}

#[no_mangle]
export function driver_fmt_check_only_get(): i32 {
  unsafe {
    let p: *i32 = driver_fmt_check_only_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

#[no_mangle]
export function driver_check_diag_emitted_get(): i32 {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return 0;
  }
  return 0;
}

// ---- G-02f-343 gates (direct _impl; seed rest keeps full logic wrappers optional) ----
export extern "C" function compile_phase_now_sec_impl(): f64;
export extern "C" function driver_call_fn_void_arg_impl(fn: *u8, arg: *u8): void;

/** Append non-negative i64 decimal into dst (for size_t-style fields such as codegen_bytes).
 * Values in [0, INT_MAX] delegate to driver_diag_append_i32 (G.7 reuse). Larger values use a
 * local 20-digit stack so message text matches cold seed %zu for typical module sizes.
 * PLATFORM: SHARED — local helper for wave3 format print pure only. */
function driver_abi_append_i64(dst: *u8, cap: i32, at: i32, val: i64): i32 {
  unsafe {
    if (dst == 0 as *u8) {
      return at;
    }
    if (val < 0) {
      // Smoke/codegen lengths are non-negative; keep sign for defensive completeness.
      if (at + 1 >= cap) {
        return at;
      }
      dst[at] = 45;
      at = at + 1;
      val = 0 - val;
    }
    if (val <= 2147483647) {
      return driver_diag_append_i32(dst, cap, at, val as i32);
    }
    // Digit stack (least-significant first); up to 20 decimal digits for i64.
    let d0: i32 = 0;
    let d1: i32 = 0;
    let d2: i32 = 0;
    let d3: i32 = 0;
    let d4: i32 = 0;
    let d5: i32 = 0;
    let d6: i32 = 0;
    let d7: i32 = 0;
    let d8: i32 = 0;
    let d9: i32 = 0;
    let d10: i32 = 0;
    let d11: i32 = 0;
    let d12: i32 = 0;
    let d13: i32 = 0;
    let d14: i32 = 0;
    let d15: i32 = 0;
    let d16: i32 = 0;
    let d17: i32 = 0;
    let d18: i32 = 0;
    let d19: i32 = 0;
    let dn: i32 = 0;
    let t: i64 = val;
    while (t > 0) {
      if (dn >= 20) {
        break;
      }
      let dig: i32 = (t % 10) as i32;
      if (dn == 0) { d0 = dig; }
      if (dn == 1) { d1 = dig; }
      if (dn == 2) { d2 = dig; }
      if (dn == 3) { d3 = dig; }
      if (dn == 4) { d4 = dig; }
      if (dn == 5) { d5 = dig; }
      if (dn == 6) { d6 = dig; }
      if (dn == 7) { d7 = dig; }
      if (dn == 8) { d8 = dig; }
      if (dn == 9) { d9 = dig; }
      if (dn == 10) { d10 = dig; }
      if (dn == 11) { d11 = dig; }
      if (dn == 12) { d12 = dig; }
      if (dn == 13) { d13 = dig; }
      if (dn == 14) { d14 = dig; }
      if (dn == 15) { d15 = dig; }
      if (dn == 16) { d16 = dig; }
      if (dn == 17) { d17 = dig; }
      if (dn == 18) { d18 = dig; }
      if (dn == 19) { d19 = dig; }
      t = t / 10;
      dn = dn + 1;
    }
    if (dn == 0) {
      d0 = 0;
      dn = 1;
    }
    let i: i32 = dn - 1;
    while (i >= 0) {
      if (at + 1 >= cap) {
        break;
      }
      let dig2: i32 = 0;
      if (i == 0) { dig2 = d0; }
      if (i == 1) { dig2 = d1; }
      if (i == 2) { dig2 = d2; }
      if (i == 3) { dig2 = d3; }
      if (i == 4) { dig2 = d4; }
      if (i == 5) { dig2 = d5; }
      if (i == 6) { dig2 = d6; }
      if (i == 7) { dig2 = d7; }
      if (i == 8) { dig2 = d8; }
      if (i == 9) { dig2 = d9; }
      if (i == 10) { dig2 = d10; }
      if (i == 11) { dig2 = d11; }
      if (i == 12) { dig2 = d12; }
      if (i == 13) { dig2 = d13; }
      if (i == 14) { dig2 = d14; }
      if (i == 15) { dig2 = d15; }
      if (i == 16) { dig2 = d16; }
      if (i == 17) { dig2 = d17; }
      if (i == 18) { dig2 = d18; }
      if (i == 19) { dig2 = d19; }
      dst[at] = (48 + dig2) as u8;
      at = at + 1;
      i = i - 1;
    }
    if (at < cap) {
      dst[at] = 0;
    }
    return at;
  }
  return at;
}

/** Emit quiet-gated "check OK: <path>" info line (deno check stays silent when quiet).
 * Assembles via driver_diag_append_cstr then diag_report; no va_list diag_reportf.
 * Message text matches cold seed reportf format. PLATFORM: SHARED — pure authority in thin;
 * cold seed keeps C _impl; FROM_X rest drops pure-dup format _impl. */
#[no_mangle]
export function driver_print_check_ok(input_path: *u8): void {
  unsafe {
    if (driver_check_quiet_ok_get() != 0) {
      return;
    }
    let msg: u8[512] = [];
    let at: i32 = driver_diag_append_cstr(&msg[0], 512, 0, "check OK: ");
    if (input_path != 0 as *u8) {
      at = driver_diag_append_cstr(&msg[0], 512, at, input_path);
    } else {
      at = driver_diag_append_cstr(&msg[0], 512, at, "?");
    }
    diag_report(0 as *u8, 0, 0, "info", &msg[0], 0 as *u8);
  }
}

#[no_mangle]
export function compile_phase_now_sec(): f64 {
  unsafe {
    return compile_phase_now_sec_impl();
  }
  return 0.0;
}

// G-02f-246 pure 深迁：mark + bump + call 编排；call 🔒
#[no_mangle]
export function driver_run_fn_on_current_large_stack(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  driver_large_stack_thread_mark(1);
  driver_bump_stack_limit();
  unsafe {
    driver_call_fn_void_arg_impl(fn, arg);
  }
  driver_large_stack_thread_mark(0);
}

// ---- G-02f-344 / wave5–6：timing BSS + begin/end + flush pure ----

#[no_mangle]
export function driver_compile_phase_index_ok(phase: i32): i32 {
  if (phase < 0) {
    return 0;
  }
  if (phase >= 3) {
    return 0;
  }
  return 1;
}

// pure：SHUX_COMPILE_PHASE_TIMING 非空 getenv（空串亦启用）
#[no_mangle]
export function driver_compile_phase_timing_enabled(): i32 {
  return driver_env_nonnull("SHUX_COMPILE_PHASE_TIMING");
}

/** Load accumulated phase ms from thin BSS (0 if phase out of range).
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C twin; FROM_X rest flush Cap uses this. */
#[no_mangle]
export function driver_compile_phase_acc_ms_get(phase: i32): f64 {
  if (driver_compile_phase_index_ok(phase) == 0) {
    return 0.0;
  }
  return g_compile_phase_acc_ms[phase];
}

/** Clear phase timing accumulators and active flags (same cells as cold seed memset).
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C twin; FROM_X rest flush Cap uses this. */
#[no_mangle]
export function driver_compile_phase_timing_clear(): void {
  g_compile_phase_acc_ms[0] = 0.0;
  g_compile_phase_acc_ms[1] = 0.0;
  g_compile_phase_acc_ms[2] = 0.0;
  g_compile_phase_active[0] = 0;
  g_compile_phase_active[1] = 0;
  g_compile_phase_active[2] = 0;
}

/** Mark compile phase start (wall-clock via compile_phase_now_sec Cap).
 * Wave5 pure: stores start_sec + active in thin BSS (no begin_impl).
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C _impl; FROM_X no pure-dup. */
#[no_mangle]
export function driver_compile_phase_timing_begin(phase: i32): void {
  if (driver_compile_phase_timing_enabled() == 0) {
    return;
  }
  if (driver_compile_phase_index_ok(phase) == 0) {
    return;
  }
  g_compile_phase_start_sec[phase] = compile_phase_now_sec();
  g_compile_phase_active[phase] = 1;
}

/** Accumulate phase duration into acc_ms (ms) and clear active.
 * Wave5 pure: f64 arithmetic on thin BSS (no end_impl).
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C _impl; FROM_X no pure-dup. */
#[no_mangle]
export function driver_compile_phase_timing_end(phase: i32): void {
  if (driver_compile_phase_timing_enabled() == 0) {
    return;
  }
  if (driver_compile_phase_index_ok(phase) == 0) {
    return;
  }
  if (g_compile_phase_active[phase] == 0) {
    return;
  }
  let now: f64 = compile_phase_now_sec();
  // PLATFORM: SHARED — use (1000 as f64); decimal f64 lit 1000.0 lowers to 0.0 under -E.
  g_compile_phase_acc_ms[phase] =
    g_compile_phase_acc_ms[phase] + (now - g_compile_phase_start_sec[phase]) * (1000 as f64);
  g_compile_phase_active[phase] = 0;
}

/** Print compile phase timing note then clear thin BSS.
 * Wave6 pure: whole milliseconds via driver_diag_append_* + diag_report (no va_list reportf).
 * Fractional sub-ms is truncated (f64→i32); sufficient for SHUX_COMPILE_PHASE_TIMING notes.
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps integer-ms twin; FROM_X no pure-dup. */
#[no_mangle]
export function driver_compile_phase_timing_flush(): void {
  if (driver_compile_phase_timing_enabled() == 0) {
    return;
  }
  unsafe {
    let a0: i32 = driver_compile_phase_acc_ms_get(0) as i32;
    let a1: i32 = driver_compile_phase_acc_ms_get(1) as i32;
    let a2: i32 = driver_compile_phase_acc_ms_get(2) as i32;
    let total: i32 = a0 + a1 + a2;
    let msg: u8[192] = [];
    let at: i32 = driver_diag_append_cstr(&msg[0], 192, 0, "compile phase timing: parse_ms=");
    at = driver_diag_append_i32(&msg[0], 192, at, a0);
    at = driver_diag_append_cstr(&msg[0], 192, at, " typeck_ms=");
    at = driver_diag_append_i32(&msg[0], 192, at, a1);
    at = driver_diag_append_cstr(&msg[0], 192, at, " codegen_ms=");
    at = driver_diag_append_i32(&msg[0], 192, at, a2);
    at = driver_diag_append_cstr(&msg[0], 192, at, " total_ms=");
    at = driver_diag_append_i32(&msg[0], 192, at, total);
    diag_report(0 as *u8, 0, 0, "note", &msg[0], 0 as *u8);
  }
  driver_compile_phase_timing_clear();
}

// ---- G-02f-345：ascii_toupper / typeck_skip / sanitize_get ----
// -E：嵌套 if 会丢整函数体，用早退扁平控制流
#[no_mangle]
export function driver_ascii_toupper(c: i32): i32 {
  if (c < 97) {
    return c;
  }
  if (c > 122) {
    return c;
  }
  return c - 32;
}

#[no_mangle]
export function driver_typeck_skip_large_entry(): i32 {
  let len: i32 = driver_pipeline_entry_source_len_i32();
  if (len > 150000) {
    return 1;
  }
  return 0;
}

// pure：flag 槽 或 SHUX_SANITIZE_ADDRESS 非空且非 '0'
#[no_mangle]
export function driver_sanitize_address_get(): i32 {
  unsafe {
    let p: *i32 = driver_sanitize_address_flag_slot();
    if (p[0] != 0) {
      return 1;
    }
    return driver_env_flag_truthy("SHUX_SANITIZE_ADDRESS");
  }
  return 0;
}

// ---- getenv pure 深迁：env flag 门闩真体（FROM_X 无 pure-dup _impl）----
#[no_mangle]
export function driver_typeck_force_c_enabled(): i32 {
  return driver_env_flag_truthy("SHUX_TYPECK_FORCE_C");
}

#[no_mangle]
export function driver_asm_build_skip_typeck(): i32 {
  return driver_env_flag_truthy("SHUX_ASM_BUILD_SKIP_TYPECK");
}

#[no_mangle]
export function driver_asm_entry_emit_heavy(): i32 {
  return driver_env_flag_truthy("SHUX_ASM_ENTRY_EMIT_HEAVY");
}

#[no_mangle]
export function driver_pipeline_no_large_stack_env(): i32 {
  return driver_env_flag_truthy("SHUX_PIPELINE_NO_LARGE_STACK");
}

#[no_mangle]
export function driver_asm_entry_module_only_from_env(): i32 {
  return driver_env_flag_truthy("SHUX_ASM_ENTRY_MODULE_ONLY");
}

#[no_mangle]
export function driver_asm_parse_metric_only_from_env(): i32 {
  return driver_env_flag_truthy("SHUX_ASM_PARSE_METRIC_ONLY");
}

// G-02f-243 pure 深迁：load + i32 饱和
#[no_mangle]
export function driver_pipeline_entry_source_len_i32(): i32 {
  unsafe {
    let len: i64 = driver_pipeline_entry_source_len_load_and_maybe_debug();
    if (len > 2147483647) {
      return 2147483647;
    }
    if (len < 0) {
      return 0;
    }
    return len as i32;
  }
  return 0;
}

// ---- G-02f-400 / wave4 pure：defines_set_at via shux_ptr_slot_set (G.7); path_last pure wave2 ----
/** Store defines[i] = s for argv -D table (defines is opaque *u8 for **char).
 * Null defines or negative i is a no-op. Uses pipeline shux_ptr_slot_set as the single
 * pointer-slot write authority (G.7) — no second **write path in driver rest.
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C _impl; FROM_X no pure-dup. */
#[no_mangle]
export function driver_defines_set_at(defines: *u8, i: i32, s: *u8): void {
  if (defines == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  unsafe {
    shux_ptr_slot_set(defines, i, s);
  }
}

// pure：默认 512MiB；SHUX_STACK_LIMIT_MB 在 [64,8192] 则取 mb*1MiB
#[no_mangle]
export function driver_stack_limit_want_bytes(): i64 {
  let def: i64 = 512 as i64 * 1024 as i64 * 1024 as i64;
  unsafe {
    let e: *u8 = getenv("SHUX_STACK_LIMIT_MB");
    if (e == 0 as *u8) {
      return def;
    }
    if (e[0] == 0) {
      return def;
    }
    let mb: i64 = driver_parse_u32_cstr(e);
    if (mb < 64) {
      return def;
    }
    if (mb > 8192) {
      return def;
    }
    return mb * (1024 as i64 * 1024 as i64);
  }
  return def;
}

// ---- G-02f-402：bump_stack / set_entry_len / phase_timing enabled pure / os_define_lit wave4 ----
export extern "C" function driver_bump_stack_limit_to_impl(want_bytes: i64): void;

#[no_mangle]
export function driver_bump_stack_limit(): void {
  unsafe {
    driver_bump_stack_limit_to_impl(driver_stack_limit_want_bytes());
  }
}

/** Alias for driver_pipeline_entry_source_len_store (large-stack entry before pipeline).
 * PLATFORM: SHARED — pure forward to entry-len BSS store. */
#[no_mangle]
export function driver_set_pipeline_entry_source_len(len: i64): void {
  driver_pipeline_entry_source_len_store(len);
}

// pure：与 driver_compile_phase_timing_enabled 同形（公共别名面）
#[no_mangle]
export function compile_phase_timing_enabled(): i32 {
  return driver_env_nonnull("SHUX_COMPILE_PHASE_TIMING");
}

/** Map target OS kind (1..4) to a static define literal pointer (OS_LINUX/…).
 * kind 0 or unknown → null. Wave4 pure: string-lit table in thin (same text as cold seed).
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C _impl; FROM_X no pure-dup. */
#[no_mangle]
export function driver_os_define_lit(kind: i32): *u8 {
  if (kind == 1) {
    return "OS_LINUX";
  }
  if (kind == 2) {
    return "OS_MACOS";
  }
  if (kind == 3) {
    return "OS_FREEBSD";
  }
  if (kind == 4) {
    return "OS_WINDOWS";
  }
  return 0 as *u8;
}

// ---- G-02f-413：fail_code / smoke / peek / get_dep / argv_defines → seed impl ----

/** Emit XP003 "pipeline failed rc=N"; when rc==-7 also XP004 "resolve path tried: P".
 * Wave3 pure: append_i32/cstr + diag_report_with_code (codes XP003/XP004 match cold seed
 * SHUX_DIAG_CODE_X_PIPELINE_*). No va_list reportf. PLATFORM: SHARED — pure authority in thin;
 * cold seed keeps C format _impl; FROM_X rest drops pure-dup. */
#[no_mangle]
export function driver_pipeline_fail_code(rc: i32, path: *u8): void {
  unsafe {
    let msg: u8[96] = [];
    let at: i32 = driver_diag_append_cstr(&msg[0], 96, 0, "pipeline failed rc=");
    at = driver_diag_append_i32(&msg[0], 96, at, rc);
    diag_report_with_code(0 as *u8, 0, 0, "pipeline error", "XP003", &msg[0], 0 as *u8);
    if (rc != 0 - 7) {
      return;
    }
    if (path == 0 as *u8) {
      return;
    }
    let msg2: u8[512] = [];
    let at2: i32 = driver_diag_append_cstr(&msg2[0], 512, 0, "resolve path tried: ");
    at2 = driver_diag_append_cstr(&msg2[0], 512, at2, path);
    diag_report_with_code(0 as *u8, 0, 0, "pipeline error", "XP004", &msg2[0], 0 as *u8);
  }
}

/** Emit smoke summary: parse OK line; if no funcs, P001 empty-module error and return;
 * else typeck OK. Wave3 pure: assemble via append_* + diag_report / diag_report_with_code;
 * no va_list reportf. Prefix strings match cold seed for run-import gate grep.
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C format _impl; FROM_X no pure-dup. */
#[no_mangle]
export function driver_print_x_smoke_summary(module: *u8, codegen_len: i64): void {
  if (module == 0 as *u8) {
    return;
  }
  unsafe {
    if (driver_check_diag_emitted_get() != 0) {
      return;
    }
    let num_funcs: i32 = driver_get_module_num_funcs(module);
    let main_ix: i32 = driver_get_module_main_func_index(module);
    let msg: u8[160] = [];
    let at: i32 = driver_diag_append_cstr(&msg[0], 160, 0, "parse OK: num_funcs=");
    at = driver_diag_append_i32(&msg[0], 160, at, num_funcs);
    at = driver_diag_append_cstr(&msg[0], 160, at, " main_idx=");
    at = driver_diag_append_i32(&msg[0], 160, at, main_ix);
    at = driver_diag_append_cstr(&msg[0], 160, at, " codegen_bytes=");
    at = driver_abi_append_i64(&msg[0], 160, at, codegen_len);
    diag_report(0 as *u8, 0, 0, "info", &msg[0], 0 as *u8);
    if (num_funcs <= 0) {
      diag_report_with_code(0 as *u8, 0, 0, "parse error", "P001",
        "parse produced no functions in module", 0 as *u8);
      return;
    }
    diag_report(0 as *u8, 0, 0, "info", "typeck OK", 0 as *u8);
  }
}

// G-02f-413 pure 深迁：边界 + read
#[no_mangle]
export function driver_peek_source_file(path: *u8, content: *u8, cap: i64): i32 {
  if (path == 0 as *u8) {
    return 0 - 1;
  }
  if (content == 0 as *u8) {
    return 0 - 1;
  }
  if (cap <= 1) {
    return 0 - 1;
  }
  unsafe {
    let n: i32 = shux_read_file_into_path(path, content, cap - 1);
    return n;
  }
  return 0 - 1;
}

/** Alias for driver_current_dep_path_load (codegen prefix reads current dep).
 * PLATFORM: SHARED — pure forward to path BSS load. */
#[no_mangle]
export function driver_get_current_dep_path_for_codegen(): *u8 {
  return driver_current_dep_path_load();
}

// G-02f-245 pure 深迁：主循环 pure；uname 🔒
#[no_mangle]
export function driver_argv_collect_defines(argc: i32, argv: *u8, defines: *u8, max_defines: i32): i32 {
  if (argv == 0 as *u8) { return 0; }
  if (defines == 0 as *u8) { return 0; }
  if (max_defines <= 0) { return 0; }
  if (argc <= 0) { return 0; }
  let ndefines: i32 = 0;
  let target_arg: *u8 = 0 as *u8;
  let i: i32 = 1;
  while (i < argc) {
    unsafe {
      let arg: *u8 = driver_argv_at(argv, i);
      if (arg == 0 as *u8) {
        i = i + 1;
      } else {
        if (driver_argv_is_D_alone(arg) != 0) {
          if (i + 1 >= argc) {
            i = i + 1;
          } else {
            let v: *u8 = driver_argv_at(argv, i + 1);
            if (v != 0 as *u8) {
              if (ndefines < max_defines) {
                driver_defines_set_at(defines, ndefines, v);
                ndefines = ndefines + 1;
              }
            }
            i = i + 2;
          }
        } else {
          if (driver_argv_is_D_inline(arg) != 0) {
            let def: *u8 = shux_cstr_offset(arg, 2);
            if (def != 0 as *u8) {
              if (ndefines < max_defines) {
                driver_defines_set_at(defines, ndefines, def);
                ndefines = ndefines + 1;
              }
            }
            i = i + 1;
          } else {
            if (driver_argv_is_target_flag(arg) != 0) {
              if (i + 1 < argc) {
                target_arg = driver_argv_at(argv, i + 1);
                i = i + 2;
              } else {
                i = i + 1;
              }
            } else {
              if (driver_argv_is_value_skip_flag(arg) != 0) {
                if (i + 1 < argc) {
                  i = i + 2;
                } else {
                  i = i + 1;
                }
              } else {
                i = i + 1;
              }
            }
          }
        }
      }
    }
  }
  if (target_arg != 0 as *u8) {
    if (ndefines < max_defines) {
      let k: i32 = driver_target_arg_os_kind(target_arg);
      if (k != 0) {
        unsafe {
          let lit: *u8 = driver_os_define_lit(k);
          if (lit != 0 as *u8) {
            driver_defines_set_at(defines, ndefines, lit);
            ndefines = ndefines + 1;
          }
        }
      }
    }
  }
  if (ndefines + 2 <= max_defines) {
    unsafe {
      ndefines = driver_argv_collect_append_uname_impl(defines, ndefines, max_defines);
    }
  }
  return ndefines;
}

// ---- G-02f-414：import scan + large-stack entry → seed impl ----

// G-02f-243 pure 深迁：字节扫描 import(" / = import(
#[no_mangle]
export function driver_source_scan_top_level_import(src: *u8, src_len: i64): i32 {
  if (src == 0 as *u8) { return 0; }
  if (src_len < 8) { return 0; }
  unsafe {
    let i: i64 = 0;
    while (i + 8 <= src_len) {
      if (src[i] == 105) {
        if (src[i + 1] == 109) {
          if (src[i + 2] == 112) {
            if (src[i + 3] == 111) {
              if (src[i + 4] == 114) {
                if (src[i + 5] == 116) {
                  if (src[i + 6] == 40) {
                    if (src[i + 7] == 34) {
                      return 1;
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (i + 9 <= src_len) {
        if (src[i] == 61) {
          if (src[i + 1] == 32) {
            if (src[i + 2] == 105) {
              if (src[i + 3] == 109) {
                if (src[i + 4] == 112) {
                  if (src[i + 5] == 111) {
                    if (src[i + 6] == 114) {
                      if (src[i + 7] == 116) {
                        if (src[i + 8] == 40) {
                          return 1;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      i = i + 1;
    }
  }
  return 0;
}

// G-02f-243 pure 深迁
#[no_mangle]
export function driver_source_has_top_level_import(src: *u8, src_len: i64): i32 {
  if (src == 0 as *u8) { return 0; }
  if (src_len < 9) { return 0; }
  return driver_source_scan_top_level_import(src, src_len);
}

// G-02f-244 pure 深迁：read+preprocess 🔒 → scan pure → free
#[no_mangle]
export function driver_source_has_top_level_import_path(path: *u8): i32 {
  if (path == 0 as *u8) { return 0; }
  unsafe {
    let src: *u8 = driver_path_read_preprocess_malloc(path);
    if (src == 0 as *u8) { return 0; }
    let len: i64 = driver_path_last_preprocess_len();
    let has: i32 = driver_source_has_top_level_import(src, len);
    free(src);
    return has;
  }
  return 0;
}

// G-02f-246 pure 深迁：早退 pure → pthread 体 🔒
#[no_mangle]
export function driver_run_thread_on_large_stack(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  if (driver_is_large_stack_thread() != 0) {
    unsafe {
      driver_call_fn_void_arg_impl(fn, arg);
    }
    return;
  }
  driver_bump_stack_limit();
  unsafe {
    if (bootstrap_nostdlib_pthread_is_stub() != 0) {
      driver_run_fn_on_current_large_stack(fn, arg);
      return;
    }
  }
  if (driver_pipeline_no_large_stack_env() != 0) {
    driver_run_fn_on_current_large_stack(fn, arg);
    return;
  }
  unsafe {
    driver_run_thread_on_large_stack_pthread_impl(fn, arg);
  }
}

// G-02f-246 pure 深迁：别名
#[no_mangle]
export function driver_run_on_large_stack_pthread(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  driver_run_thread_on_large_stack(fn, arg);
}

/** Load pipeline entry source length from thin BSS.
 * Wave2 pure: hybrid skips SHUX_DEBUG_PIPE reportf (cold seed load_impl still notes).
 * PLATFORM: SHARED — hybrid pure authority for the length cell. */
#[no_mangle]
export function driver_pipeline_entry_source_len_load_and_maybe_debug(): i64 {
  return g_pipeline_entry_source_len[0];
}

/** Query entry source length (same as load_and_maybe_debug under hybrid pure).
 * PLATFORM: SHARED. */
#[no_mangle]
export function driver_pipeline_entry_source_len(): i64 {
  return driver_pipeline_entry_source_len_load_and_maybe_debug();
}
