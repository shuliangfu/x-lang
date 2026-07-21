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
//     freestanding / sanitize / fmt_check_only / skip_typeck / skip_codegen / skip_dep0 /
// See implementation.
// See implementation.
// See implementation.
//   + wave3 Cap residual pure：format print（check_ok / fail rc·path / smoke parse·typeck）
// See implementation.
//     print/fail format _impl。
//   + wave4 Cap residual pure：defines_set_at（G.7 shux_ptr_slot_set）+ os_define_lit
// See implementation.
//   + wave5 Cap residual pure：phase timing BSS + begin/end（f64 acc/start + active i32）
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
//     shux_driver_path_read_preprocess_malloc（no file-view/preprocess in .x）；
// See implementation.
// See implementation.
//     shux_driver_run_thread_on_large_stack_pthread（no pthread_attr/posix_memalign in .x）；
// See implementation.
// See implementation.
//     （SHUX_DEBUG_PIPE truthy → append_* + diag_report；no va_list reportf）；
// See implementation.
// Cap residual pure leaf closed for driver_abi debug_pipe note（OS rest _impl already 0）。
//   + wave14 Cap residual pure：rt_asm_stub GAS line table + out_append_cstr
//     (host OutBuf layout: data[9MiB] then i32 len; LE load/store local to this TU).
//   + wave15 Cap residual pure：rt_entry buffer slots + path_max/entry_dir slots
//     (BSS u8[N]; fmt_argv *char[2] stays seed — .x **u8 / *u8[2] lit init typeck XT001).
//   + wave16 Cap residual pure：driver_x_emit work BSS + get/set/reset/cleanup
//     (p: G.7 shux_ptr_slot_* on LP64 raw u8[208]; i32[17]/usize[5]; free+dep_ctx destroy).
//   + wave17 Cap residual pure：driver_asm_work BSS + get/set/reset/cleanup
//     (p: raw u8[200] 25×ptr; i32[16]/usize[4]; free+dep_ctx+fclose asm_out; clear tmp_path[0]).
//

export extern "C" function getenv(name: *u8): *u8;
/** Permanent OS wall-clock surface (seed rest). Returns seconds as f64.
 * PLATFORM: POSIX gettimeofday / WINDOWS time — hides timeval layout from .x. */
export extern "C" function shux_driver_wall_clock_sec(): f64;
/** Permanent OS indirect call surface (seed rest). Invokes fn(arg) when fn != null.
 * PLATFORM: SHARED — .x cannot safely perform indirect function calls; hide cast in rest. */
export extern "C" function shux_driver_call_fn_void_arg(fn: *u8, arg: *u8): void;
/** Permanent OS RLIMIT_STACK raise surface (seed rest).
 * PLATFORM: POSIX getrlimit/setrlimit; WINDOWS no-op — hides struct rlimit from .x. */
export extern "C" function shux_driver_bump_stack_limit(want_bytes: i64): void;
/** Permanent OS path-read + preprocess surface (seed rest).
 * PLATFORM: SHARED — runtime file view + shux_preprocess; hides IO/preprocess ABI from .x. */
export extern "C" function shux_driver_path_read_preprocess_malloc(path: *u8): *u8;
/** Permanent OS large-stack pthread create/join surface (seed rest).
 * PLATFORM: POSIX pthread_attr / posix_memalign / pthread_create+join; hides OS layouts from .x.
 * Default stack 256MiB; SHUX_STACK_LIMIT_MB (64..8192) overrides. Falls back to current-stack path. */
export extern "C" function shux_driver_run_thread_on_large_stack_pthread(fn: *u8, arg: *u8): void;
// Wave3 format print pure: reuse diagnostic append authority (G.7) + fixed-arity diag report.
export extern "C" function diag_report(file: *u8, line: i32, col: i32, kind: *u8, msg: *u8, detail: *u8): void;
export extern "C" function diag_report_with_code(file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function driver_diag_append_cstr(dst: *u8, cap: i32, at: i32, src: *u8): i32;
export extern "C" function driver_diag_append_i32(dst: *u8, cap: i32, at: i32, val: i32): i32;
// Wave4/16: G.7 reuse pipeline pointer-slot authority (defines / work_p raw / void** tables).
export extern "C" function shux_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern "C" function shux_ptr_slot_get(arr: *u8, i: i32): *u8;
/** Destroy heap PipelineDepCtx (ast_pool authority). Used by work cleanup pure.
 * PLATFORM: SHARED — rest/cold free path; null-safe in C body. */
export extern "C" function pipeline_dep_ctx_heap_destroy(ctx: *u8): void;
/** Seed rest: 64-byte BSS tmp path for mkstemp; reset clears byte 0.
 * PLATFORM: SHARED — still seed buffer; pure reset writes first NUL via this accessor. */
export extern "C" function driver_asm_tmp_path_slot(): *u8;
/** Seed rest: fclose asm FILE* (stdout → fflush only). Used by asm_work cleanup pure.
 * PLATFORM: SHARED — wraps driver_asm_fclose_asm_out; null-safe in C body. */
export extern "C" function driver_asm_fclose(fp: *u8): void;

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
// Wave13 pure: load_and_maybe_debug emits SHUX_DEBUG_PIPE note via append + diag_report.
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

// See implementation.
// See implementation.
// driver_env_flag_truthy: see function docblock below.
/** Internal function `driver_env_flag_truthy`.
 * Implements `driver_env_flag_truthy`.
 * @param name *u8
 * @return i32
 */
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

// driver_env_nonnull: see function docblock below.
/** Internal function `driver_env_nonnull`.
 * Implements `driver_env_nonnull`.
 * @param name *u8
 * @return i32
 */
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

// driver_parse_u32_cstr: see function docblock below.
/** Internal function `driver_parse_u32_cstr`.
 * Implements `driver_parse_u32_cstr`.
 * @param s *u8
 * @return i64
 */
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

// See implementation.
// See implementation.
export extern "C" function driver_check_quiet_ok_get(): i32;

export extern "C" function driver_argv_at(argv: *u8, i: i32): *u8;
export extern "C" function shux_cstr_offset(s: *u8, off: i32): *u8;
/** Permanent OS uname host-define surface (seed rest).
 * PLATFORM: POSIX uname(struct utsname) — hides utsname layout from .x; appends SHUX_OS_*/SHUX_ARCH_*. */
export extern "C" function shux_driver_argv_append_uname(defines: *u8, ndefines: i32, max_defines: i32): i32;
export extern "C" function driver_get_module_num_funcs(m: *u8): i32;
export extern "C" function driver_get_module_main_func_index(m: *u8): i32;
export extern "C" function shux_read_file_into_path(path: *u8, buf: *u8, cap: i64): i32;
export extern "C" function free(p: *u8): void;
export extern "C" function bootstrap_nostdlib_pthread_is_stub(): i32;

// pure: return address of module BSS flag cell (cold seed keeps C static + flag_slot).
/** Exported function `driver_check_only_flag_slot`.
 * Implements `driver_check_only_flag_slot`.
 * @return *i32
 */
#[no_mangle]
export function driver_check_only_flag_slot(): *i32 {
  return &g_driver_check_only_flag[0];
}

/** Exported function `driver_check_diag_emitted_flag_slot`.
 * Implements `driver_check_diag_emitted_flag_slot`.
 * @return *i32
 */
#[no_mangle]
export function driver_check_diag_emitted_flag_slot(): *i32 {
  return &g_driver_check_diag_emitted_flag[0];
}

/** Exported function `driver_freestanding_flag_slot`.
 * Memory management helper `driver_freestanding_flag_slot`.
 * @return *i32
 */
#[no_mangle]
export function driver_freestanding_flag_slot(): *i32 {
  return &g_driver_freestanding_flag[0];
}

/** Exported function `driver_sanitize_address_flag_slot`.
 * Implements `driver_sanitize_address_flag_slot`.
 * @return *i32
 */
#[no_mangle]
export function driver_sanitize_address_flag_slot(): *i32 {
  return &g_driver_sanitize_address_flag[0];
}

/** Exported function `driver_fmt_check_only_flag_slot`.
 * Implements `driver_fmt_check_only_flag_slot`.
 * @return *i32
 */
#[no_mangle]
export function driver_fmt_check_only_flag_slot(): *i32 {
  return &g_driver_fmt_check_only_flag[0];
}

/** Exported function `driver_x_pipeline_skip_typeck_flag_slot`.
 * Implements `driver_x_pipeline_skip_typeck_flag_slot`.
 * @return *i32
 */
#[no_mangle]
export function driver_x_pipeline_skip_typeck_flag_slot(): *i32 {
  return &g_driver_x_pipeline_skip_typeck_flag[0];
}

/** Exported function `driver_x_pipeline_skip_codegen_flag_slot`.
 * Implements `driver_x_pipeline_skip_codegen_flag_slot`.
 * @return *i32
 */
#[no_mangle]
export function driver_x_pipeline_skip_codegen_flag_slot(): *i32 {
  return &g_driver_x_pipeline_skip_codegen_flag[0];
}

/** Exported function `driver_skip_codegen_dep_0_flag_slot`.
 * Implements `driver_skip_codegen_dep_0_flag_slot`.
 * @return *i32
 */
#[no_mangle]
export function driver_skip_codegen_dep_0_flag_slot(): *i32 {
  return &g_driver_skip_codegen_dep_0_flag[0];
}

/** Exported function `driver_large_stack_thread_flag_slot`.
 * Read path helper `driver_large_stack_thread_flag_slot`.
 * @return *i32
 */
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

/** Pure orch: path-read + preprocess via permanent OS surface.
 * Wave11 pure: forwards to shux_driver_path_read_preprocess_malloc (no path_read _impl residual).
 * PLATFORM: SHARED pure orch; file view + preprocess stay in seed rest. */
#[no_mangle]
export function driver_path_read_preprocess_malloc(path: *u8): *u8 {
  unsafe { return shux_driver_path_read_preprocess_malloc(path); }
  return 0 as *u8;
}

/** Exported function `driver_fmt_check_only_set`.
 * Implements `driver_fmt_check_only_set`.
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_fmt_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_fmt_check_only_flag_slot();
    p[0] = v;
  }
}

/** Exported function `driver_large_stack_thread_mark`.
 * Read path helper `driver_large_stack_thread_mark`.
 * @param on i32
 * @return void
 */
#[no_mangle]
export function driver_large_stack_thread_mark(on: i32): void {
  unsafe {
    let p: *i32 = driver_large_stack_thread_flag_slot();
    p[0] = on;
  }
}

/** Exported function `driver_is_large_stack_thread`.
 * Read path helper `driver_is_large_stack_thread`.
 * @return i32
 */
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

/** Exported function `driver_check_only_set`.
 * Implements `driver_check_only_set`.
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_check_only_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_check_only_flag_slot();
    p[0] = v;
  }
}

/** Exported function `driver_skip_codegen_dep_0_get`.
 * Implements `driver_skip_codegen_dep_0_get`.
 * @return i32
 */
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

/** Exported function `driver_x_pipeline_skip_typeck_get`.
 * Implements `driver_x_pipeline_skip_typeck_get`.
 * @return i32
 */
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

/** Exported function `driver_freestanding_get`.
 * Memory management helper `driver_freestanding_get`.
 * @return i32
 */
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

/** Exported function `driver_check_only_get`.
 * Implements `driver_check_only_get`.
 * @return i32
 */
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

// driver_argv_is_D_alone: see function docblock below.
/** Exported function `driver_argv_is_D_alone`.
 * Implements `driver_argv_is_D_alone`.
 * @param arg *u8
 * @return i32
 */
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
/** Exported function `driver_argv_is_D_inline`.
 * Implements `driver_argv_is_D_inline`.
 * @param arg *u8
 * @return i32
 */
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
/** Exported function `driver_argv_is_target_flag`.
 * Implements `driver_argv_is_target_flag`.
 * @param arg *u8
 * @return i32
 */
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
/** Exported function `driver_argv_is_value_skip_flag`.
 * Implements `driver_argv_is_value_skip_flag`.
 * @param arg *u8
 * @return i32
 */
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
/** Exported function `driver_cstr_contains_bytes`.
 * Implements `driver_cstr_contains_bytes`.
 * @param hay *u8
 * @param n0 u8
 * @param n1 u8
 * @param n2 u8
 * @param n3 u8
 * @param n4 u8
 * @param nlen i32
 * @return i32
 */
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
/** Exported function `driver_target_arg_os_kind`.
 * Implements `driver_target_arg_os_kind`.
 * @param target *u8
 * @return i32
 */
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

/** Exported function `driver_x_pipeline_skip_typeck_set`.
 * Implements `driver_x_pipeline_skip_typeck_set`.
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_x_pipeline_skip_typeck_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_typeck_flag_slot();
    p[0] = v;
  }
}

// See implementation.
// driver_x_pipeline_skip_codegen_set: see function docblock below.

/** Exported function `driver_x_pipeline_skip_codegen_set`.
 * Implements `driver_x_pipeline_skip_codegen_set`.
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_x_pipeline_skip_codegen_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_x_pipeline_skip_codegen_flag_slot();
    p[0] = v;
  }
}

/** Exported function `driver_sanitize_address_set`.
 * Implements `driver_sanitize_address_set`.
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_sanitize_address_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_sanitize_address_flag_slot();
    p[0] = v;
  }
}

/** Exported function `driver_x_pipeline_skip_codegen_get`.
 * Implements `driver_x_pipeline_skip_codegen_get`.
 * @return i32
 */
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

/** Exported function `driver_skip_codegen_dep_0_set`.
 * Implements `driver_skip_codegen_dep_0_set`.
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_skip_codegen_dep_0_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_skip_codegen_dep_0_flag_slot();
    p[0] = v;
  }
}

/** Exported function `driver_freestanding_set`.
 * Memory management helper `driver_freestanding_set`.
 * @param v i32
 * @return void
 */
#[no_mangle]
export function driver_freestanding_set(v: i32): void {
  unsafe {
    let p: *i32 = driver_freestanding_flag_slot();
    p[0] = v;
  }
}

/** Exported function `driver_check_diag_emitted_note`.
 * Implements `driver_check_diag_emitted_note`.
 * @return void
 */
#[no_mangle]
export function driver_check_diag_emitted_note(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 1;
  }
}

/** Exported function `driver_check_diag_emitted_reset`.
 * Implements `driver_check_diag_emitted_reset`.
 * @return void
 */
#[no_mangle]
export function driver_check_diag_emitted_reset(): void {
  unsafe {
    let p: *i32 = driver_check_diag_emitted_flag_slot();
    p[0] = 0;
  }
}

/** Exported function `driver_fmt_check_only_get`.
 * Implements `driver_fmt_check_only_get`.
 * @return i32
 */
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

/** Exported function `driver_check_diag_emitted_get`.
 * Implements `driver_check_diag_emitted_get`.
 * @return i32
 */
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

// ---- G-02f-343 gates (permanent OS surfaces; pure orch above) ----

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

/** Wall-clock seconds for compile-phase timing (begin/end).
 * Wave7 pure: forwards to permanent OS surface shux_driver_wall_clock_sec (no timeval in .x).
 * PLATFORM: SHARED pure authority in thin; OS layout stays in seed rest; FROM_X no pure-dup. */
#[no_mangle]
export function compile_phase_now_sec(): f64 {
  unsafe {
    return shux_driver_wall_clock_sec();
  }
  return 0.0;
}

/** Run fn(arg) on the current thread under large-stack mark + stack limit bump.
 * Wave8 pure orch: null gate + mark/bump; indirect call via permanent OS surface
 * shux_driver_call_fn_void_arg (no call_fn _impl residual).
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C twin; FROM_X no pure-dup. */
#[no_mangle]
export function driver_run_fn_on_current_large_stack(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  driver_large_stack_thread_mark(1);
  driver_bump_stack_limit();
  unsafe {
    shux_driver_call_fn_void_arg(fn, arg);
  }
  driver_large_stack_thread_mark(0);
}

// ---- G-02f-344 / wave5–6：timing BSS + begin/end + flush pure ----

/** Exported function `driver_compile_phase_index_ok`.
 * Implements `driver_compile_phase_index_ok`.
 * @param phase i32
 * @return i32
 */
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

// driver_compile_phase_timing_enabled: see function docblock below.
/** Exported function `driver_compile_phase_timing_enabled`.
 * Implements `driver_compile_phase_timing_enabled`.
 * @return i32
 */
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
// driver_ascii_toupper: see function docblock below.
/** Exported function `driver_ascii_toupper`.
 * Implements `driver_ascii_toupper`.
 * @param c i32
 * @return i32
 */
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

/** Exported function `driver_typeck_skip_large_entry`.
 * Implements `driver_typeck_skip_large_entry`.
 * @return i32
 */
#[no_mangle]
export function driver_typeck_skip_large_entry(): i32 {
  let len: i32 = driver_pipeline_entry_source_len_i32();
  if (len > 150000) {
    return 1;
  }
  return 0;
}

// driver_sanitize_address_get: see function docblock below.
/** Exported function `driver_sanitize_address_get`.
 * Implements `driver_sanitize_address_get`.
 * @return i32
 */
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

// driver_typeck_force_c_enabled: see function docblock below.
/** Exported function `driver_typeck_force_c_enabled`.
 * Implements `driver_typeck_force_c_enabled`.
 * @return i32
 */
#[no_mangle]
export function driver_typeck_force_c_enabled(): i32 {
  return driver_env_flag_truthy("SHUX_TYPECK_FORCE_C");
}

/** Exported function `driver_asm_build_skip_typeck`.
 * Implements `driver_asm_build_skip_typeck`.
 * @return i32
 */
#[no_mangle]
export function driver_asm_build_skip_typeck(): i32 {
  return driver_env_flag_truthy("SHUX_ASM_BUILD_SKIP_TYPECK");
}

/** Exported function `driver_asm_entry_emit_heavy`.
 * Implements `driver_asm_entry_emit_heavy`.
 * @return i32
 */
#[no_mangle]
export function driver_asm_entry_emit_heavy(): i32 {
  return driver_env_flag_truthy("SHUX_ASM_ENTRY_EMIT_HEAVY");
}

/** Exported function `driver_pipeline_no_large_stack_env`.
 * Implements `driver_pipeline_no_large_stack_env`.
 * @return i32
 */
#[no_mangle]
export function driver_pipeline_no_large_stack_env(): i32 {
  return driver_env_flag_truthy("SHUX_PIPELINE_NO_LARGE_STACK");
}

/** Exported function `driver_asm_entry_module_only_from_env`.
 * Implements `driver_asm_entry_module_only_from_env`.
 * @return i32
 */
#[no_mangle]
export function driver_asm_entry_module_only_from_env(): i32 {
  return driver_env_flag_truthy("SHUX_ASM_ENTRY_MODULE_ONLY");
}

/** Exported function `driver_asm_parse_metric_only_from_env`.
 * Implements `driver_asm_parse_metric_only_from_env`.
 * @return i32
 */
#[no_mangle]
export function driver_asm_parse_metric_only_from_env(): i32 {
  return driver_env_flag_truthy("SHUX_ASM_PARSE_METRIC_ONLY");
}

// driver_pipeline_entry_source_len_i32: see function docblock below.
/** Exported function `driver_pipeline_entry_source_len_i32`.
 * Implements `driver_pipeline_entry_source_len_i32`.
 * @return i32
 */
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

// driver_stack_limit_want_bytes: see function docblock below.
/** Exported function `driver_stack_limit_want_bytes`.
 * Implements `driver_stack_limit_want_bytes`.
 * @return i64
 */
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

// ---- G-02f-402 / wave9：bump_stack orch pure / set_entry_len / phase_timing enabled pure / os_define_lit wave4 ----
/** Raise RLIMIT_STACK soft limit using env-derived want bytes.
 * Wave9 pure: want pure in thin; setrlimit via permanent OS surface shux_driver_bump_stack_limit.
 * PLATFORM: SHARED pure orch; OS layout stays in seed rest; FROM_X no pure-dup setrlimit _impl. */
#[no_mangle]
export function driver_bump_stack_limit(): void {
  unsafe {
    shux_driver_bump_stack_limit(driver_stack_limit_want_bytes());
  }
}

/** Alias for driver_pipeline_entry_source_len_store (large-stack entry before pipeline).
 * PLATFORM: SHARED — pure forward to entry-len BSS store. */
#[no_mangle]
export function driver_set_pipeline_entry_source_len(len: i64): void {
  driver_pipeline_entry_source_len_store(len);
}

// compile_phase_timing_enabled: see function docblock below.
/** Exported function `compile_phase_timing_enabled`.
 * Implements `compile_phase_timing_enabled`.
 * @return i32
 */
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

// driver_peek_source_file: see function docblock below.
/** Exported function `driver_peek_source_file`.
 * Implements `driver_peek_source_file`.
 * @param path *u8
 * @param content *u8
 * @param cap i64
 * @return i32
 */
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

/** Collect -D / -target defines from argv; append host uname defines when room.
 * Wave10 pure orch: main loop pure; host OS/arch via permanent OS surface
 * shux_driver_argv_append_uname (no struct utsname in .x; no append_uname _impl residual).
 * PLATFORM: SHARED pure orch; uname layout stays in seed rest. */
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
      ndefines = shux_driver_argv_append_uname(defines, ndefines, max_defines);
    }
  }
  return ndefines;
}

// ---- G-02f-414：import scan + large-stack entry → seed impl ----

// driver_source_scan_top_level_import: see function docblock below.
/** Exported function `driver_source_scan_top_level_import`.
 * Implements `driver_source_scan_top_level_import`.
 * @param src *u8
 * @param src_len i64
 * @return i32
 */
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

// driver_source_has_top_level_import: see function docblock below.
/** Exported function `driver_source_has_top_level_import`.
 * Implements `driver_source_has_top_level_import`.
 * @param src *u8
 * @param src_len i64
 * @return i32
 */
#[no_mangle]
export function driver_source_has_top_level_import(src: *u8, src_len: i64): i32 {
  if (src == 0 as *u8) { return 0; }
  if (src_len < 9) { return 0; }
  return driver_source_scan_top_level_import(src, src_len);
}

// driver_source_has_top_level_import_path: see function docblock below.
/** Exported function `driver_source_has_top_level_import_path`.
 * Implements `driver_source_has_top_level_import_path`.
 * @param path *u8
 * @return i32
 */
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

/** Orchestrate large-stack run: pure early exits; pthread create via permanent OS surface.
 * Wave8: already-on-large-stack path uses shux_driver_call_fn_void_arg (no call_fn _impl).
 * Wave12 pure: pthread body via shux_driver_run_thread_on_large_stack_pthread (no pthread _impl residual).
 * PLATFORM: SHARED pure orch; pthread_attr / memalign / create+join stay in seed rest. */
#[no_mangle]
export function driver_run_thread_on_large_stack(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  if (driver_is_large_stack_thread() != 0) {
    unsafe {
      shux_driver_call_fn_void_arg(fn, arg);
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
    shux_driver_run_thread_on_large_stack_pthread(fn, arg);
  }
}

// driver_run_on_large_stack_pthread: see function docblock below.
/** Exported function `driver_run_on_large_stack_pthread`.
 * Read path helper `driver_run_on_large_stack_pthread`.
 * @param fn *u8
 * @param arg *u8
 * @return void
 */
#[no_mangle]
export function driver_run_on_large_stack_pthread(fn: *u8, arg: *u8): void {
  if (fn == 0 as *u8) {
    return;
  }
  driver_run_thread_on_large_stack(fn, arg);
}

/** Load pipeline entry source length from thin BSS; optionally emit a debug note.
 * Wave13 pure: when SHUX_DEBUG_PIPE is truthy (non-empty and not '0'), assemble
 * "pipeline debug: entry_source_len_global=<len>" via driver_diag_append_cstr +
 * driver_abi_append_i64 + diag_report (no va_list diag_reportf). Env gate reuses
 * driver_env_flag_truthy (same shape as driver_diag_env_debug_pipe / G.7).
 * Cold seed keeps an integer-note twin under #ifndef FROM_X.
 * PLATFORM: SHARED — hybrid pure authority for the length cell + debug note. */
#[no_mangle]
export function driver_pipeline_entry_source_len_load_and_maybe_debug(): i64 {
  unsafe {
    let len: i64 = g_pipeline_entry_source_len[0];
    if (driver_env_flag_truthy("SHUX_DEBUG_PIPE") != 0) {
      let msg: u8[96] = [0];
      let at: i32 = driver_diag_append_cstr(&msg[0], 96, 0, "pipeline debug: entry_source_len_global=");
      at = driver_abi_append_i64(&msg[0], 96, at, len);
      diag_report(0 as *u8, 0, 0, "note", &msg[0], 0 as *u8);
    }
    return len;
  }
  return 0;
}

/** Query entry source length (delegates to load_and_maybe_debug; may emit debug note).
 * PLATFORM: SHARED. */
#[no_mangle]
export function driver_pipeline_entry_source_len(): i64 {
  return driver_pipeline_entry_source_len_load_and_maybe_debug();
}

// ---- Wave14 Cap residual pure: rt_asm_stub GAS table + OutBuf append (PLATFORM: SHARED) ----
// Host layout (seeds/runtime_driver_abi.from_x.c driver_codegen_outbuf_abi):
//   unsigned char data[X_CODEGEN_OUTBUF_CAP_ABI];  // CAP = 9 * 1024 * 1024
//   int32_t len;                                   // little-endian i32 at offset CAP
// Cold seed keeps C table/append under #ifndef SHUX_L2_RDABI_THIN_FROM_X.
// G.7: single product authority for gas_line_* / out_append under PREFER hybrid thin.

/** Codegen OutBuf capacity in bytes (matches X_CODEGEN_OUTBUF_CAP_ABI in seed).
 * PLATFORM: SHARED — must stay identical to cold C define. */
function driver_abi_codegen_outbuf_cap(): i32 {
  return 9 * 1024 * 1024;
}

/** Load little-endian i32 at base+off (null-safe; off < 0 → 0).
 * Module-local host layout helper for wave14 OutBuf len cell.
 * PLATFORM: SHARED. */
function driver_abi_load_i32_le(p: *u8, off: i32): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  unsafe {
    let m: i32 = 256;
    let a: i32 = p[off] as i32;
    a = a + (p[off + 1] as i32) * m;
    a = a + (p[off + 2] as i32) * m * m;
    a = a + (p[off + 3] as i32) * m * m * m;
    return a;
  }
  return 0;
}

/** Store little-endian i32 at base+off (null / off < 0 no-op).
 * Module-local host layout helper for wave14 OutBuf len cell.
 * PLATFORM: SHARED. */
function driver_abi_store_i32_le(p: *u8, off: i32, v: i32): void {
  if (p == 0 as *u8) {
    return;
  }
  if (off < 0) {
    return;
  }
  unsafe {
    let u: u32 = v as u32;
    p[off] = (u & 255) as u8;
    p[off + 1] = ((u / 256) & 255) as u8;
    p[off + 2] = ((u / 65536) & 255) as u8;
    p[off + 3] = ((u / 16777216) & 255) as u8;
  }
}

/** C-string length in bytes (no trailing NUL counted); null → 0.
 * PLATFORM: SHARED — pure helper for gas append. */
function driver_abi_cstr_len(s: *u8): i32 {
  if (s == 0 as *u8) {
    return 0;
  }
  let n: i32 = 0;
  unsafe {
    while (s[n] != 0) {
      n = n + 1;
      if (n > 100000000) {
        return n;
      }
    }
  }
  return n;
}

/** Return the i-th fixed GAS stub line for asm_codegen_ast (rv=42 skeleton).
 * Wave14 pure: string-lit table in thin (same text as cold seed g_asm_stub_gas_lines).
 * Out-of-range or negative i → null.
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C table; FROM_X no pure-dup. */
#[no_mangle]
export function driver_asm_stub_gas_line_at(i: i32): *u8 {
  if (i == 0) {
    return ".text";
  }
  if (i == 1) {
    return ".globl main";
  }
  if (i == 2) {
    return "main:";
  }
  if (i == 3) {
    return "pushq %rbp";
  }
  if (i == 4) {
    return "movq %rsp, %rbp";
  }
  if (i == 5) {
    return "subq $0, %rsp";
  }
  if (i == 6) {
    return "movl $42, %eax";
  }
  if (i == 7) {
    return "movq %rsp, %rbp";
  }
  if (i == 8) {
    return "popq %rbp";
  }
  if (i == 9) {
    return "ret";
  }
  return 0 as *u8;
}

/** Number of fixed GAS stub lines (matches cold seed g_asm_stub_gas_lines_n = 10).
 * PLATFORM: SHARED — wave14 pure. */
#[no_mangle]
export function driver_asm_stub_gas_line_count(): i32 {
  return 10;
}

/** Append C-string s plus a trailing newline into driver codegen OutBuf at out.
 * Host layout: data[CAP] then i32 len (LE) at offset CAP. Bounds-check before write.
 * Returns 0 on success; -1 on null args, oversize len cell, or capacity overflow.
 * Wave14 pure: LE load/store of len + byte copy (no memcpy/strlen libc).
 * PLATFORM: SHARED — pure authority in thin; cold seed keeps C append; FROM_X no pure-dup. */
#[no_mangle]
export function driver_asm_stub_out_append_cstr(out: *u8, s: *u8): i32 {
  if (out == 0 as *u8) {
    return 0 - 1;
  }
  if (s == 0 as *u8) {
    return 0 - 1;
  }
  let cap: i32 = driver_abi_codegen_outbuf_cap();
  let cur: i32 = driver_abi_load_i32_le(out, cap);
  if (cur < 0) {
    return 0 - 1;
  }
  if (cur > cap) {
    return 0 - 1;
  }
  let slen: i32 = driver_abi_cstr_len(s);
  // need room for slen bytes + one newline
  if (cur > cap - slen - 1) {
    return 0 - 1;
  }
  unsafe {
    let j: i32 = 0;
    while (j < slen) {
      out[cur + j] = s[j];
      j = j + 1;
    }
    out[cur + slen] = 10; // '\n'
  }
  driver_abi_store_i32_le(out, cap, cur + slen + 1);
  return 0;
}

// ---- Wave15 Cap residual pure: rt_entry + path buffer slots (PLATFORM: SHARED) ----
// Cold seed: static char buffers + slot getters (always present for surface R2).
// PREFER hybrid: authority in this thin TU; FROM_X rest drops pure-dup BSS/slots (H↓).
// G.7: single product authority for entry_*_slot (buf) / path_max / entry_dir under hybrid.
// Cap residual left in seed: driver_entry_fmt_argv_slot (char*[2] + string-lit init;
//   .x **u8 return / *u8[2] lit array trips typeck XT001 — dig when pointer-array init pure).
// Note: local u8[N] is banned in product .x (-E init_globals); module BSS is OK (diagnostic thin pattern).

let g_driver_entry_ab: u8[256] = [];
let g_driver_entry_code: u8[256] = [];
let g_driver_entry_suggest: u8[16] = [];
let g_driver_entry_msg: u8[256] = [];
let g_driver_entry_tmp: u8[16] = [];
let g_driver_entry_tmp2: u8[16] = [];
let g_driver_path_max_slot_buf: u8[4096] = [];
let g_driver_entry_dir_slot_buf: u8[512] = [];

/** Return BSS scratch for entry diagnostic / argv buffer (256 bytes).
 * Wave15 pure: thin owns slot; cold seed keeps C static char[256].
 * PLATFORM: SHARED — pure buffer authority under PREFER hybrid. */
#[no_mangle]
export function driver_entry_ab_slot(): *u8 {
  return &g_driver_entry_ab[0];
}

/** Return BSS scratch for entry diagnostic code string (256 bytes).
 * Wave15 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_entry_code_slot(): *u8 {
  return &g_driver_entry_code[0];
}

/** Return BSS scratch for entry suggestion short string (16 bytes).
 * Wave15 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_entry_suggest_slot(): *u8 {
  return &g_driver_entry_suggest[0];
}

/** Return BSS scratch for entry diagnostic message (256 bytes).
 * Wave15 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_entry_msg_slot(): *u8 {
  return &g_driver_entry_msg[0];
}

/** Return BSS scratch for entry temporary small string (16 bytes).
 * Wave15 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_entry_tmp_slot(): *u8 {
  return &g_driver_entry_tmp[0];
}

/** Return second entry temporary small string slot (16 bytes).
 * Wave15 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_entry_tmp2_slot(): *u8 {
  return &g_driver_entry_tmp2[0];
}

/** Return BSS path buffer for import resolve / path_max (4096 bytes).
 * Wave15 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_path_max_slot(): *u8 {
  return &g_driver_path_max_slot_buf[0];
}

/** Return BSS entry directory buffer (512 bytes) used by x_emit dep layout.
 * Wave15 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_entry_dir_slot(): *u8 {
  return &g_driver_entry_dir_slot_buf[0];
}

// ---- Wave16 Cap residual pure: driver_x_emit work BSS + cleanup (PLATFORM: SHARED) ----
// Slot map (must match seed comment + rt_run_x_emit.x consumers):
//   p[26]: 0 path 1 src 2 raw 3 arena 4 module 5 entry_dir 6 dep_sources 7 dep_paths
//          8 dep_lens 9 dep_arenas 10 dep_modules 11 out_buf 12 pctx 13 one_ctx
//          14 dep_out 15 dep_src 16 resolved 17 snap 18 dep_diag_file 19 kind
//          20 code 21 msg 22 cpaths 23 out_data 24 lib_roots 25 tmp_p
//   i[17]: 0 want_extern 1 n_lib 2 n_deps 3 asm_direct 4 n_imports 5 main_idx
//          6 pr_ok 7 ec 8 ec_dep 9 emit_ret 10 out_len 11 j 12 i 13 fail_tok
//          14 n_closure 15 rc 16 free_src_flag
//   z[5]:  0 src_len 1 raw_len 2 arena_sz 3 module_sz 4 dep_len
// Pointer table: .x has no *u8[N] product array type for BSS (fmt_argv XT001 history);
//   store 26× LP64 pointer slots in raw u8[208] via G.7 shux_ptr_slot_get/set.
// Cold seed keeps C static arrays + memset reset; FROM_X drops pure-dup (no dual BSS).
// G.7: single hybrid authority for driver_x_emit_work_* under PREFER.

let g_xe_work_p_raw: u8[208] = [];
let g_xe_work_i: i32[17] = [];
let g_xe_work_z: usize[5] = [];

/** Zero all x_emit work pointer / i32 / size_t slots (same effect as cold memset).
 * Wave16 pure. PLATFORM: SHARED — hybrid pure authority. */
#[no_mangle]
export function driver_x_emit_work_reset(): void {
  unsafe {
    let j: i32 = 0;
    while (j < 26) {
      shux_ptr_slot_set(&g_xe_work_p_raw[0], j, 0 as *u8);
      j = j + 1;
    }
    j = 0;
    while (j < 17) {
      g_xe_work_i[j] = 0;
      j = j + 1;
    }
    j = 0;
    while (j < 5) {
      g_xe_work_z[j] = 0 as usize;
      j = j + 1;
    }
  }
}

/** Load work pointer slot i (0..25); out of range → null.
 * Wave16 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_x_emit_work_p_get(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 26) {
    return 0 as *u8;
  }
  unsafe {
    return shux_ptr_slot_get(&g_xe_work_p_raw[0], i);
  }
  return 0 as *u8;
}

/** Store work pointer slot i (0..25); out of range is a no-op.
 * Wave16 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_x_emit_work_p_set(i: i32, v: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 26) {
    return;
  }
  unsafe {
    shux_ptr_slot_set(&g_xe_work_p_raw[0], i, v);
  }
}

/** Load work i32 slot i (0..16); out of range → 0.
 * Wave16 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_x_emit_work_i_get(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 17) {
    return 0;
  }
  return g_xe_work_i[i];
}

/** Store work i32 slot i (0..16); out of range is a no-op.
 * Wave16 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_x_emit_work_i_set(i: i32, v: i32): void {
  if (i < 0) {
    return;
  }
  if (i >= 17) {
    return;
  }
  g_xe_work_i[i] = v;
}

/** Load work size_t slot i (0..4); out of range → 0.
 * Wave16 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_x_emit_work_z_get(i: i32): usize {
  if (i < 0) {
    return 0 as usize;
  }
  if (i >= 5) {
    return 0 as usize;
  }
  return g_xe_work_z[i];
}

/** Store work size_t slot i (0..4); out of range is a no-op.
 * Wave16 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_x_emit_work_z_set(i: i32, v: usize): void {
  if (i < 0) {
    return;
  }
  if (i >= 5) {
    return;
  }
  g_xe_work_z[i] = v;
}

/** Free x_emit pipeline temporaries held in work slots, then reset all slots.
 * Frees per-dep arena/module/src/path rows (n_deps = i[2]), the five dep table
 * bases (p[6..10]), out_buf (p[11]), pctx via pipeline_dep_ctx_heap_destroy (p[12]),
 * arena/module/src (p[3]/p[4]/p[1]), and kind/code/msg (p[19..21]).
 * free(null) is safe. Wave16 pure; matches cold seed order.
 * PLATFORM: SHARED — hybrid pure authority under PREFER. */
#[no_mangle]
export function driver_x_emit_work_cleanup(): void {
  unsafe {
    let n: i32 = g_xe_work_i[2];
    let ds: *u8 = shux_ptr_slot_get(&g_xe_work_p_raw[0], 6);
    let dp: *u8 = shux_ptr_slot_get(&g_xe_work_p_raw[0], 7);
    let dl: *u8 = shux_ptr_slot_get(&g_xe_work_p_raw[0], 8);
    let da: *u8 = shux_ptr_slot_get(&g_xe_work_p_raw[0], 9);
    let dm: *u8 = shux_ptr_slot_get(&g_xe_work_p_raw[0], 10);
    let i: i32 = 0;
    while (i < n) {
      if (da != 0 as *u8) {
        free(shux_ptr_slot_get(da, i));
      }
      if (dm != 0 as *u8) {
        free(shux_ptr_slot_get(dm, i));
      }
      if (ds != 0 as *u8) {
        free(shux_ptr_slot_get(ds, i));
      }
      if (dp != 0 as *u8) {
        free(shux_ptr_slot_get(dp, i));
      }
      i = i + 1;
    }
    free(ds);
    free(dp);
    free(dl);
    free(da);
    free(dm);
    free(shux_ptr_slot_get(&g_xe_work_p_raw[0], 11));
    let pctx: *u8 = shux_ptr_slot_get(&g_xe_work_p_raw[0], 12);
    if (pctx != 0 as *u8) {
      pipeline_dep_ctx_heap_destroy(pctx);
    }
    free(shux_ptr_slot_get(&g_xe_work_p_raw[0], 3));
    free(shux_ptr_slot_get(&g_xe_work_p_raw[0], 4));
    free(shux_ptr_slot_get(&g_xe_work_p_raw[0], 1));
    free(shux_ptr_slot_get(&g_xe_work_p_raw[0], 19));
    free(shux_ptr_slot_get(&g_xe_work_p_raw[0], 20));
    free(shux_ptr_slot_get(&g_xe_work_p_raw[0], 21));
  }
  driver_x_emit_work_reset();
}

// ---- Wave17 Cap residual pure: driver_asm_work BSS + cleanup (PLATFORM: SHARED) ----
// Slot map (must match seed comment + rt_run_asm_backend.x consumers):
//   p[25]: 0 path 1 src 2 out_path 3 arena 4 module 5 entry 6 dsrc 7 dpath 8 dlens
//          9 dar 10 dmod 11 out_buf 12 pctx 13 kind 14 code 15 msg 16 lib 17 target
//          18 argv 19 asm_out 20 elf 21 defines 22 tmp_path 23 one_ctx 24 dep_out
//   i[16]: 0 nlib 1 ndeps 2 nimp 3 main 4 emit_elf 5 want_exe 6 smoke 7 ndef 8 argc
//          9 ec 10 j 11 entry_only 12 skip_dep_load 13 rc 14 n_closure 15 num_funcs
//   z[4]:  0 src_len 1 asz 2 msz 3 dep_len
// Pointer table: 25× LP64 slots in raw u8[200] via G.7 shux_ptr_slot_get/set.
// reset also clears seed driver_asm_tmp_path_slot()[0] (same as cold memset path).
// cleanup: ndeps=i[1]; free dep rows; free table bases; free out_buf; destroy pctx;
//   fclose asm_out (p[19]); free elf/arena/module/src/kind/code/msg; then reset.
// Cold seed keeps C static arrays + memset twin; FROM_X drops pure-dup (no dual BSS).
// G.7: single hybrid authority for driver_asm_work_* under PREFER.

let g_asm_work_p_raw: u8[200] = [];
let g_asm_work_i: i32[16] = [];
let g_asm_work_z: usize[4] = [];

/** Zero all asm work pointer / i32 / size_t slots and clear tmp-path first byte.
 * Wave17 pure. PLATFORM: SHARED — hybrid pure authority. */
#[no_mangle]
export function driver_asm_work_reset(): void {
  unsafe {
    let j: i32 = 0;
    while (j < 25) {
      shux_ptr_slot_set(&g_asm_work_p_raw[0], j, 0 as *u8);
      j = j + 1;
    }
    j = 0;
    while (j < 16) {
      g_asm_work_i[j] = 0;
      j = j + 1;
    }
    j = 0;
    while (j < 4) {
      g_asm_work_z[j] = 0 as usize;
      j = j + 1;
    }
    // Match cold: g_driver_asm_tmp_path_slot[0] = 0 (seed owns the 64-byte BSS).
    let tmp: *u8 = driver_asm_tmp_path_slot();
    if (tmp != 0 as *u8) {
      tmp[0] = 0;
    }
  }
}

/** Load asm work pointer slot i (0..24); out of range → null.
 * Wave17 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_asm_work_p_get(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 25) {
    return 0 as *u8;
  }
  unsafe {
    return shux_ptr_slot_get(&g_asm_work_p_raw[0], i);
  }
  return 0 as *u8;
}

/** Store asm work pointer slot i (0..24); out of range is a no-op.
 * Wave17 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_asm_work_p_set(i: i32, v: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 25) {
    return;
  }
  unsafe {
    shux_ptr_slot_set(&g_asm_work_p_raw[0], i, v);
  }
}

/** Load asm work i32 slot i (0..15); out of range → 0.
 * Wave17 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_asm_work_i_get(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 16) {
    return 0;
  }
  return g_asm_work_i[i];
}

/** Store asm work i32 slot i (0..15); out of range is a no-op.
 * Wave17 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_asm_work_i_set(i: i32, v: i32): void {
  if (i < 0) {
    return;
  }
  if (i >= 16) {
    return;
  }
  g_asm_work_i[i] = v;
}

/** Load asm work size_t slot i (0..3); out of range → 0.
 * Wave17 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_asm_work_z_get(i: i32): usize {
  if (i < 0) {
    return 0 as usize;
  }
  if (i >= 4) {
    return 0 as usize;
  }
  return g_asm_work_z[i];
}

/** Store asm work size_t slot i (0..3); out of range is a no-op.
 * Wave17 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_asm_work_z_set(i: i32, v: usize): void {
  if (i < 0) {
    return;
  }
  if (i >= 4) {
    return;
  }
  g_asm_work_z[i] = v;
}

/** Free asm pipeline temporaries held in work slots, then reset all slots.
 * Frees per-dep arena/module/src/path rows (n_deps = i[1]), the five dep table
 * bases (p[6..10]), out_buf (p[11]), pctx via pipeline_dep_ctx_heap_destroy (p[12]),
 * asm_out via driver_asm_fclose (p[19]), elf (p[20]), arena/module/src (p[3]/p[4]/p[1]),
 * and kind/code/msg (p[13..15]). free(null)/fclose(null) are safe.
 * Wave17 pure; matches cold seed order. PLATFORM: SHARED — hybrid pure under PREFER. */
#[no_mangle]
export function driver_asm_work_cleanup(): void {
  unsafe {
    let n: i32 = g_asm_work_i[1];
    let ds: *u8 = shux_ptr_slot_get(&g_asm_work_p_raw[0], 6);
    let dp: *u8 = shux_ptr_slot_get(&g_asm_work_p_raw[0], 7);
    let dl: *u8 = shux_ptr_slot_get(&g_asm_work_p_raw[0], 8);
    let da: *u8 = shux_ptr_slot_get(&g_asm_work_p_raw[0], 9);
    let dm: *u8 = shux_ptr_slot_get(&g_asm_work_p_raw[0], 10);
    let i: i32 = 0;
    while (i < n) {
      if (da != 0 as *u8) {
        free(shux_ptr_slot_get(da, i));
      }
      if (dm != 0 as *u8) {
        free(shux_ptr_slot_get(dm, i));
      }
      if (ds != 0 as *u8) {
        free(shux_ptr_slot_get(ds, i));
      }
      if (dp != 0 as *u8) {
        free(shux_ptr_slot_get(dp, i));
      }
      i = i + 1;
    }
    free(ds);
    free(dp);
    free(dl);
    free(da);
    free(dm);
    free(shux_ptr_slot_get(&g_asm_work_p_raw[0], 11));
    let pctx: *u8 = shux_ptr_slot_get(&g_asm_work_p_raw[0], 12);
    if (pctx != 0 as *u8) {
      pipeline_dep_ctx_heap_destroy(pctx);
    }
    let asm_out: *u8 = shux_ptr_slot_get(&g_asm_work_p_raw[0], 19);
    if (asm_out != 0 as *u8) {
      driver_asm_fclose(asm_out);
    }
    free(shux_ptr_slot_get(&g_asm_work_p_raw[0], 20));
    free(shux_ptr_slot_get(&g_asm_work_p_raw[0], 3));
    free(shux_ptr_slot_get(&g_asm_work_p_raw[0], 4));
    free(shux_ptr_slot_get(&g_asm_work_p_raw[0], 1));
    free(shux_ptr_slot_get(&g_asm_work_p_raw[0], 13));
    free(shux_ptr_slot_get(&g_asm_work_p_raw[0], 14));
    free(shux_ptr_slot_get(&g_asm_work_p_raw[0], 15));
  }
  driver_asm_work_reset();
}
