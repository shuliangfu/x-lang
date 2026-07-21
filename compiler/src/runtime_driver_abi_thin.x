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
//     (BSS u8[N]; fmt_argv closed in wave21).
//   + wave16 Cap residual pure：driver_x_emit work BSS + get/set/reset/cleanup
//     (p: G.7 shux_ptr_slot_* on LP64 raw u8[208]; i32[17]/usize[5]; free+dep_ctx destroy).
//   + wave17 Cap residual pure：driver_asm_work BSS + get/set/reset/cleanup
//     (p: raw u8[200] 25×ptr; i32[16]/usize[4]; free+dep_ctx+fclose asm_out; clear tmp_path[0]).
//   + wave18 Cap residual pure：driver_parsed_work BSS + get/set/reset/cleanup
//     (p: raw u8[192] 24×ptr; i32[14]/usize[4]; free+dep_ctx+fclose cf; unlink tmp_c; clear tmp slots).
//   + wave19 Cap residual pure：driver_pipeline_dep_ctx field get/set (LP64 fixed offsets
//     + wave14 LE load/store; no C struct in .x).
//   + wave20 Cap residual pure：driver_preamble_{io_net,fs_path}_line_at/count
//     (G.7 shux_ptr_slot_get on Cap-giant-string table raw base; tables stay in rt_preamble).
//   + wave21 Cap residual pure：driver_entry_fmt_argv_slot
//     (u8 lit BSS "shux"/"fmt" + 2× LP64 ptr slots via G.7 shux_ptr_slot_set; no *u8[2] lit).
//   + wave22 Cap residual pure：driver_preamble_fputs
//     (null guard + g05 prologue shux_driver_fputs_opaque FILE* cast; no FILE* in .x).
//   + wave23 Cap residual pure：calloc family + driver_asm_pctx_apply_host_defaults
//     (libc calloc/malloc/memset + pipeline_sizeof_*; host #ifdef → OS residual helpers).
//   + wave24 Cap residual pure：outbuf free/len/data + ptr/size table free/get/set
//     + diag_snapshot_free (pairs wave23 calloc; G.7 shux_ptr_slot_* + LE usize; free).
//   + wave25 Cap residual pure：tmp path BSS slots (asm 64B + parsed 64B/256B)
//     (open_out seed always uses accessors; no dual BSS under hybrid).
//   + wave26 Cap residual pure：driver_parsed_fclose / fclose_rc / write_out
//     (g05 stdout_ptr + fclose/fwrite opaque; min preamble via fputs; io_net/fs_path seed).
//   + wave27 Cap residual pure：driver_parsed_open_out_file
//     (stdout gate pure; mkstemp/rename/close + g05 fopen_write; seed tmp_prefix residual).
//   + wave28 Cap residual pure：driver_parsed_invoke_cc
//     (std .o path pack + set/clear user .o + shux_invoke_cc + fail/KEEP_C cleanup;
//      no va_list reportf; c_paths[1] via G.7 shux_ptr_slot_set).
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
/** Seed rest: fclose asm FILE* (stdout → fflush only). Used by asm_work cleanup pure.
 * PLATFORM: SHARED — wraps driver_asm_fclose_asm_out; null-safe in C body. */
export extern "C" function driver_asm_fclose(fp: *u8): void;
/* wave26: driver_parsed_fclose is pure in this TU (no seed extern under hybrid). */
/** Always-seed Cap-giant-string data residual: address of driver_preamble_io_net_lines[]
 * (pointer table in seeds/rt_preamble.from_x.c). Pure line_at indexes via shux_ptr_slot_get.
 * PLATFORM: SHARED — table text stays C; only base address is seed surface. */
export extern "C" function driver_preamble_io_net_lines_raw(): *u8;
/** Always-seed Cap-giant-string data residual: address of driver_preamble_fs_path_lines[].
 * PLATFORM: SHARED — same pattern as io_net_lines_raw. */
export extern "C" function driver_preamble_fs_path_lines_raw(): *u8;
/** POSIX unlink for tmp .c paths held in parsed work slots.
 * PLATFORM: POSIX (Linux/macOS product path); Windows uses same surface via seed pin. */
export extern "C" function unlink(path: *u8): i32;

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
// Note: local u8[N] is banned in product .x (-E init_globals); module BSS is OK (diagnostic thin pattern).
// Wave21 closed fmt_argv (see section below): byte-lit BSS + G.7 ptr slots, no *u8[2] lit.

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

// ---- Wave25 Cap residual pure: tmp path BSS slots (PLATFORM: SHARED) ----
// open_out (wave27 pure) writes only via accessors; hybrid pure owns BSS (no dual static).
// Caps: asm 64 bytes (mkstemp path); parsed slot 64; parsed buf 256 (Windows long TEMP).
// Cold seed keeps C static + accessor twins under #ifndef SHUX_L2_RDABI_THIN_FROM_X.
// Defined before work_reset so pure reset can call same-TU accessors.

let g_driver_asm_tmp_path_slot: u8[64] = [];
let g_driver_parsed_tmp_c_slot: u8[64] = [];
let g_driver_parsed_tmp_c_buf: u8[256] = [];

/**
 * Return the 64-byte BSS slot used as mkstemp path for asm want-exe temp object.
 * @return *u8 — base of g_driver_asm_tmp_path_slot (never null); capacity 64 including NUL
 * Caller (rt_ab_step_open_out / driver_asm_mkstemp_fdopen) fills the template and path.
 * Wave25 pure. Work reset clears byte 0. PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_asm_tmp_path_slot(): *u8 {
  return &g_driver_asm_tmp_path_slot[0];
}

/**
 * Return the 64-byte parsed tmp slot (parity with cold memset path; work reset clears [0]).
 * @return *u8 — base of g_driver_parsed_tmp_c_slot (never null); capacity 64
 * Wave25 pure. PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_parsed_tmp_c_slot(): *u8 {
  return &g_driver_parsed_tmp_c_slot[0];
}

/**
 * Return the 256-byte path buffer filled by driver_parsed_open_out_file (wave27 pure).
 * @return *u8 — base of g_driver_parsed_tmp_c_buf (never null); capacity 256 including NUL
 * open_out writes only through this accessor (wave25); cleanup may unlink when p[20] empty.
 * Wave25 pure. PLATFORM: SHARED — size matches Windows long TEMP paths.
 */
#[no_mangle]
export function driver_parsed_tmp_c_buf(): *u8 {
  return &g_driver_parsed_tmp_c_buf[0];
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
// reset also clears driver_asm_tmp_path_slot()[0] (wave25 pure owns 64-byte BSS).
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
    // Match cold: clear first byte of asm tmp-path BSS (wave25 pure slot).
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

// ---- Wave18 Cap residual pure: driver_parsed_work BSS + cleanup (PLATFORM: SHARED) ----
// Slot map (must match seed comment + rt_run_compiler_parsed.x consumers):
//   p[24]: 0 path 1 src 2 out_path 3 arena 4 module 5 entry 6 dsrc 7 dpath 8 dlens
//          9 dar 10 dmod 11 out_buf 12 pctx 13 kind 14 code 15 msg 16 lib 17 opt
//          18 argv 19 cf 20 tmp_c 21 target 22 defs 23 (reserved / NP pad)
//   i[14]: 0 nlib 1 ndeps 2 nimp 3 main 4 want_asm 5 emit_stdout 6 ndef 7 use_lto
//          8 argc 9 ec 10 j 11 check 12 n_funcs 13 (pad)
//   z[4]:  0 src_len 1 asz 2 msz 3 (pad)
// Pointer table: 24× LP64 slots in raw u8[192] via G.7 shux_ptr_slot_get/set.
// reset also clears driver_parsed_tmp_c_slot()[0] + driver_parsed_tmp_c_buf()[0] (wave25 pure).
// cleanup: ndeps=i[1]; free dep rows; free table bases; free out_buf; destroy pctx;
//   if !emit_stdout (i[5]): fclose cf (p[19]), unlink tmp_c (p[20] or pure/seed buf);
//   free arena/module/src/kind/code/msg/tmp_c heap; then reset.
// Cold seed keeps C static arrays + memset twin; FROM_X drops pure-dup (no dual BSS).
// G.7: single hybrid authority for driver_parsed_work_* under PREFER.

let g_parsed_work_p_raw: u8[192] = [];
let g_parsed_work_i: i32[14] = [];
let g_parsed_work_z: usize[4] = [];

/** Zero all parsed work pointer / i32 / size_t slots and clear tmp path first bytes.
 * Wave18 pure. PLATFORM: SHARED — hybrid pure authority. */
#[no_mangle]
export function driver_parsed_work_reset(): void {
  unsafe {
    let j: i32 = 0;
    while (j < 24) {
      shux_ptr_slot_set(&g_parsed_work_p_raw[0], j, 0 as *u8);
      j = j + 1;
    }
    j = 0;
    while (j < 14) {
      g_parsed_work_i[j] = 0;
      j = j + 1;
    }
    j = 0;
    while (j < 4) {
      g_parsed_work_z[j] = 0 as usize;
      j = j + 1;
    }
    // Match cold: clear first bytes of parsed tmp slots (wave25 pure BSS).
    let slot: *u8 = driver_parsed_tmp_c_slot();
    if (slot != 0 as *u8) {
      slot[0] = 0;
    }
    let buf: *u8 = driver_parsed_tmp_c_buf();
    if (buf != 0 as *u8) {
      buf[0] = 0;
    }
  }
}

/** Load parsed work pointer slot i (0..23); out of range → null.
 * Wave18 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_parsed_work_p_get(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= 24) {
    return 0 as *u8;
  }
  unsafe {
    return shux_ptr_slot_get(&g_parsed_work_p_raw[0], i);
  }
  return 0 as *u8;
}

/** Store parsed work pointer slot i (0..23); out of range is a no-op.
 * Wave18 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_parsed_work_p_set(i: i32, v: *u8): void {
  if (i < 0) {
    return;
  }
  if (i >= 24) {
    return;
  }
  unsafe {
    shux_ptr_slot_set(&g_parsed_work_p_raw[0], i, v);
  }
}

/** Load parsed work i32 slot i (0..13); out of range → 0.
 * Wave18 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_parsed_work_i_get(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 14) {
    return 0;
  }
  return g_parsed_work_i[i];
}

/** Store parsed work i32 slot i (0..13); out of range is a no-op.
 * Wave18 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_parsed_work_i_set(i: i32, v: i32): void {
  if (i < 0) {
    return;
  }
  if (i >= 14) {
    return;
  }
  g_parsed_work_i[i] = v;
}

/** Load parsed work size_t slot i (0..3); out of range → 0.
 * Wave18 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_parsed_work_z_get(i: i32): usize {
  if (i < 0) {
    return 0 as usize;
  }
  if (i >= 4) {
    return 0 as usize;
  }
  return g_parsed_work_z[i];
}

/** Store parsed work size_t slot i (0..3); out of range is a no-op.
 * Wave18 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_parsed_work_z_set(i: i32, v: usize): void {
  if (i < 0) {
    return;
  }
  if (i >= 4) {
    return;
  }
  g_parsed_work_z[i] = v;
}

/** Free parsed pipeline temporaries held in work slots, then reset all slots.
 * Frees per-dep arena/module/src/path rows (n_deps = i[1]), the five dep table
 * bases (p[6..10]), out_buf (p[11]), pctx via pipeline_dep_ctx_heap_destroy (p[12]),
 * then if emit_stdout (i[5]) is 0: driver_parsed_fclose(cf p[19]) and unlink tmp_c
 * (p[20] if non-empty, else seed driver_parsed_tmp_c_buf). Finally free arena/module/src
 * (p[3]/p[4]/p[1]), kind/code/msg (p[13..15]), and tmp_c heap (p[20]).
 * free(null)/fclose(null) are safe. Wave18 pure; matches cold seed order.
 * PLATFORM: SHARED — hybrid pure under PREFER. */
#[no_mangle]
export function driver_parsed_work_cleanup(): void {
  unsafe {
    let n: i32 = g_parsed_work_i[1];
    let emit_stdout: i32 = g_parsed_work_i[5];
    let ds: *u8 = shux_ptr_slot_get(&g_parsed_work_p_raw[0], 6);
    let dp: *u8 = shux_ptr_slot_get(&g_parsed_work_p_raw[0], 7);
    let dl: *u8 = shux_ptr_slot_get(&g_parsed_work_p_raw[0], 8);
    let da: *u8 = shux_ptr_slot_get(&g_parsed_work_p_raw[0], 9);
    let dm: *u8 = shux_ptr_slot_get(&g_parsed_work_p_raw[0], 10);
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
    free(shux_ptr_slot_get(&g_parsed_work_p_raw[0], 11));
    let pctx: *u8 = shux_ptr_slot_get(&g_parsed_work_p_raw[0], 12);
    if (pctx != 0 as *u8) {
      pipeline_dep_ctx_heap_destroy(pctx);
    }
    // Match cold: only fclose+unlink when not writing to stdout.
    if (emit_stdout == 0) {
      let cf: *u8 = shux_ptr_slot_get(&g_parsed_work_p_raw[0], 19);
      if (cf != 0 as *u8) {
        driver_parsed_fclose(cf);
        let tmpc: *u8 = shux_ptr_slot_get(&g_parsed_work_p_raw[0], 20);
        if (tmpc != 0 as *u8) {
          if (tmpc[0] != 0) {
            unlink(tmpc);
          } else {
            let seed_tmp: *u8 = driver_parsed_tmp_c_buf();
            if (seed_tmp != 0 as *u8) {
              if (seed_tmp[0] != 0) {
                unlink(seed_tmp);
              }
            }
          }
        } else {
          let seed_tmp2: *u8 = driver_parsed_tmp_c_buf();
          if (seed_tmp2 != 0 as *u8) {
            if (seed_tmp2[0] != 0) {
              unlink(seed_tmp2);
            }
          }
        }
      }
    }
    free(shux_ptr_slot_get(&g_parsed_work_p_raw[0], 3));
    free(shux_ptr_slot_get(&g_parsed_work_p_raw[0], 4));
    free(shux_ptr_slot_get(&g_parsed_work_p_raw[0], 1));
    free(shux_ptr_slot_get(&g_parsed_work_p_raw[0], 13));
    free(shux_ptr_slot_get(&g_parsed_work_p_raw[0], 14));
    free(shux_ptr_slot_get(&g_parsed_work_p_raw[0], 15));
    free(shux_ptr_slot_get(&g_parsed_work_p_raw[0], 20));
  }
  driver_parsed_work_reset();
}

// ---- Wave19 Cap residual pure: PipelineDepCtx i32 field get/set (PLATFORM: SHARED LP64) ----
// Cold seed: ((struct ast_PipelineDepCtx *)ctx)->field = v.
// PREFER hybrid: authority in this thin TU via fixed LP64 offsetof + driver_abi_{load,store}_i32_le
//   (same host-layout pattern as wave14 OutBuf len cell).
// Layout authority: compiler/src/runtime_pipeline_abi.h struct ast_PipelineDepCtx
//   (must stay identical to ast.x PipelineDepCtx). Offsets verified with offsetof on LP64.
// wave23: calloc + host_defaults pure (pipeline_sizeof_* / OS residual for host #ifdef).
// G.7: single product authority for driver_pipeline_dep_ctx_{set,get}_* under hybrid;
//   typed pipeline.x path still uses pipeline_dep_ctx_* in ast_pool (typed *PipelineDepCtx).
// PLATFORM: SHARED LP64 (Ubuntu x86_64 + Darwin arm64/x86_64). Not MS64 field packing.

/** offsetof(ast_PipelineDepCtx, use_asm_backend) on LP64 host layout. */
function driver_abi_pctx_off_use_asm(): i32 {
  return 8389660;
}

/** offsetof(ast_PipelineDepCtx, target_arch) on LP64. */
function driver_abi_pctx_off_target_arch(): i32 {
  return 8389664;
}

/** offsetof(ast_PipelineDepCtx, target_cpu_features) on LP64. */
function driver_abi_pctx_off_target_cpu_features(): i32 {
  return 8389668;
}

/** offsetof(ast_PipelineDepCtx, use_macho_o) on LP64. */
function driver_abi_pctx_off_use_macho_o(): i32 {
  return 8389672;
}

/** offsetof(ast_PipelineDepCtx, use_coff_o) on LP64. */
function driver_abi_pctx_off_use_coff_o(): i32 {
  return 8389676;
}

/** offsetof(ast_PipelineDepCtx, skip_codegen_dep_0) on LP64. */
function driver_abi_pctx_off_skip_codegen_dep_0(): i32 {
  return 8389692;
}

/** offsetof(ast_PipelineDepCtx, entry_already_parsed) on LP64. */
function driver_abi_pctx_off_entry_already_parsed(): i32 {
  return 8389696;
}

/** offsetof(ast_PipelineDepCtx, asm_entry_module_only) on LP64. */
function driver_abi_pctx_off_asm_entry_module_only(): i32 {
  return 8389808;
}

/** Store pctx->use_asm_backend = v. Null ctx is a no-op.
 * Wave19 pure: LP64 offsetof + LE i32 store (no C struct in .x).
 * PLATFORM: SHARED LP64 — pure under PREFER hybrid; cold seed keeps C field write. */
#[no_mangle]
export function driver_pipeline_dep_ctx_set_use_asm(ctx: *u8, v: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  driver_abi_store_i32_le(ctx, driver_abi_pctx_off_use_asm(), v);
}

/** Store pctx->target_arch = v. Null ctx is a no-op.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_set_target_arch(ctx: *u8, v: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  driver_abi_store_i32_le(ctx, driver_abi_pctx_off_target_arch(), v);
}

/** Store pctx->target_cpu_features = v. Null ctx is a no-op.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_set_target_cpu_features(ctx: *u8, v: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  driver_abi_store_i32_le(ctx, driver_abi_pctx_off_target_cpu_features(), v);
}

/** Store pctx->use_macho_o = v. Null ctx is a no-op.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_set_use_macho_o(ctx: *u8, v: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  driver_abi_store_i32_le(ctx, driver_abi_pctx_off_use_macho_o(), v);
}

/** Store pctx->use_coff_o = v. Null ctx is a no-op.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_set_use_coff_o(ctx: *u8, v: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  driver_abi_store_i32_le(ctx, driver_abi_pctx_off_use_coff_o(), v);
}

/** Store pctx->entry_already_parsed = v. Null ctx is a no-op.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_set_entry_already_parsed(ctx: *u8, v: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  driver_abi_store_i32_le(ctx, driver_abi_pctx_off_entry_already_parsed(), v);
}

/** Store pctx->asm_entry_module_only = v. Null ctx is a no-op.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_set_asm_entry_module_only(ctx: *u8, v: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  driver_abi_store_i32_le(ctx, driver_abi_pctx_off_asm_entry_module_only(), v);
}

/** Read pctx->asm_entry_module_only. Null ctx → 0.
 * Wave19 pure: LP64 offsetof + LE i32 load. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_get_asm_entry_module_only(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return driver_abi_load_i32_le(ctx, driver_abi_pctx_off_asm_entry_module_only());
}

/** Read pctx->use_macho_o. Null ctx → 0.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_get_use_macho_o(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return driver_abi_load_i32_le(ctx, driver_abi_pctx_off_use_macho_o());
}

/** Read pctx->use_coff_o. Null ctx → 0.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_get_use_coff_o(ctx: *u8): i32 {
  if (ctx == 0 as *u8) {
    return 0;
  }
  return driver_abi_load_i32_le(ctx, driver_abi_pctx_off_use_coff_o());
}

/** Store pctx->skip_codegen_dep_0 = v. Null ctx is a no-op.
 * Wave19 pure. PLATFORM: SHARED LP64. */
#[no_mangle]
export function driver_pipeline_dep_ctx_set_skip_codegen_dep_0(ctx: *u8, v: i32): void {
  if (ctx == 0 as *u8) {
    return;
  }
  driver_abi_store_i32_le(ctx, driver_abi_pctx_off_skip_codegen_dep_0(), v);
}

// ---- Wave20 Cap residual pure: rt_preamble line_at/count bridge (PLATFORM: SHARED) ----
// Cap-giant-string data authority stays in seeds/rt_preamble.from_x.c
//   (driver_preamble_io_net_lines[] / fs_path_lines[] + _n). .x cannot host giant string tables.
// Hybrid pure owns the public line_at/count surface used by rt_preamble.x write_* loops.
// Always-seed residual: driver_preamble_*_lines_raw() = base of pointer table (LP64 *u8 slots).
// Index via G.7 shux_ptr_slot_get (same authority as defines_set_at / work_p).
// Counts are fixed to match sizeof(...)/sizeof(*...) in rt_preamble.from_x.c (verified 219 / 21).
// When adding/removing a table row, update N here in the same commit as the C table.
// Cold seed keeps C line_at/count twins; FROM_X rest drops pure-dup (H↓).
// Wave22 pure: driver_preamble_fputs (g05 FILE* cast helper). Still seed: giant string text tables.

/** Fixed io_net preamble line count (must match driver_preamble_io_net_lines_n).
 * PLATFORM: SHARED — wave20 pure; keep in sync with seeds/rt_preamble.from_x.c. */
function driver_abi_preamble_io_net_n(): i32 {
  return 219;
}

/** Fixed fs_path preamble line count (must match driver_preamble_fs_path_lines_n).
 * PLATFORM: SHARED — wave20 pure; keep in sync with seeds/rt_preamble.from_x.c. */
function driver_abi_preamble_fs_path_n(): i32 {
  return 21;
}

/** Return the i-th io_net Cap-giant-string preamble line (C string as *u8).
 * Out-of-range or negative i → null. Null table base → null.
 * Wave20 pure: bounds + G.7 shux_ptr_slot_get on always-seed raw base.
 * extern calls (raw + ptr_slot) require unsafe (same as wave16 work_p_get).
 * PLATFORM: SHARED — pure authority under PREFER hybrid; cold seed keeps C index. */
#[no_mangle]
export function driver_preamble_io_net_line_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= driver_abi_preamble_io_net_n()) {
    return 0 as *u8;
  }
  unsafe {
    let base: *u8 = driver_preamble_io_net_lines_raw();
    if (base == 0 as *u8) {
      return 0 as *u8;
    }
    return shux_ptr_slot_get(base, i);
  }
  return 0 as *u8;
}

/** Number of io_net Cap-giant-string preamble lines (219).
 * Wave20 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_preamble_io_net_line_count(): i32 {
  return driver_abi_preamble_io_net_n();
}

/** Return the i-th fs_path Cap-giant-string preamble line (C string as *u8).
 * Out-of-range or negative i → null. Null table base → null.
 * Wave20 pure: bounds + G.7 shux_ptr_slot_get on always-seed raw base.
 * extern calls require unsafe. PLATFORM: SHARED. */
#[no_mangle]
export function driver_preamble_fs_path_line_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i >= driver_abi_preamble_fs_path_n()) {
    return 0 as *u8;
  }
  unsafe {
    let base: *u8 = driver_preamble_fs_path_lines_raw();
    if (base == 0 as *u8) {
      return 0 as *u8;
    }
    return shux_ptr_slot_get(base, i);
  }
  return 0 as *u8;
}

/** Number of fs_path Cap-giant-string preamble lines (21).
 * Wave20 pure. PLATFORM: SHARED. */
#[no_mangle]
export function driver_preamble_fs_path_line_count(): i32 {
  return driver_abi_preamble_fs_path_n();
}

// ---- Wave21 Cap residual pure: driver_entry_fmt_argv_slot (PLATFORM: SHARED) ----
// Cold seed: static char *[2] = {"shux","fmt"} + slot getter.
// Product .x cannot host *u8[2] / char*[2] lit-array init (typeck XT001 history).
// Pure path (same as fmt_check_cmd_thin check_argv / wave16 work_p):
//   - C strings as module BSS byte arrays (ASCII, trailing NUL)
//   - argv table as 2× LP64 pointer slots in raw u8[16]
//   - first call: G.7 shux_ptr_slot_set slots 0/1 → lit bases
//   - return base of raw table (ABI = char ** / **u8 for driver_run_fmt)
// G.7: single hybrid authority under PREFER; FROM_X rest drops pure-dup.
// Return type *u8 is the opaque base of the pointer table (same ABI width as char **).

// ASCII "shux\0"
let g_driver_entry_fmt_argv_lit0: u8[5] = [115, 104, 117, 120, 0];
// ASCII "fmt\0"
let g_driver_entry_fmt_argv_lit1: u8[4] = [102, 109, 116, 0];
// 2 × 8-byte LP64 pointer slots (char *[2] layout)
let g_driver_entry_fmt_argv_raw: u8[16] = [];
// 0 = not yet filled; 1 = slots 0/1 point at lit0/lit1
let g_driver_entry_fmt_argv_ready: i32 = 0;

/** Return fixed argv table for driver_run_fmt when no user paths (argc=2).
 * Layout: [0]="shux", [1]="fmt" as *u8 C strings (NUL-terminated BSS lits).
 * Wave21 pure: no char*[2] lit init; lazy G.7 shux_ptr_slot_set into raw u8[16].
 * Returns base of the 2-slot pointer table (ABI-compatible with char ** / **u8).
 * PLATFORM: SHARED — pure authority under PREFER hybrid; cold seed keeps C static. */
#[no_mangle]
export function driver_entry_fmt_argv_slot(): *u8 {
  if (g_driver_entry_fmt_argv_ready == 0) {
    unsafe {
      shux_ptr_slot_set(&g_driver_entry_fmt_argv_raw[0], 0, &g_driver_entry_fmt_argv_lit0[0]);
      shux_ptr_slot_set(&g_driver_entry_fmt_argv_raw[0], 1, &g_driver_entry_fmt_argv_lit1[0]);
    }
    g_driver_entry_fmt_argv_ready = 1;
  }
  return &g_driver_entry_fmt_argv_raw[0];
}

// ---- Wave22 Cap residual pure: driver_preamble_fputs (PLATFORM: SHARED) ----
// G.7 authority for opaque *u8 stream → libc fputs (rt_preamble + async emit pure).
// .x cannot name FILE*; direct fputs(*u8,*u8) fails host-cc under
// -Werror=incompatible-pointer-types. Cast residual lives in g05_try_x_to_o prologue
// as static inline shux_driver_fputs_opaque (same pattern as shux_fmt_opendir/DIR*).
// Cold seed keeps C twin with (FILE*)(void*) cast; FROM_X rest drops pure-dup (H↓).

/** g05 prologue: cast opaque *u8 args to const char* / FILE* then fputs.
 * PLATFORM: SHARED — harness residual only; not a second product authority. */
export extern "C" function shux_driver_fputs_opaque(s: *u8, stream: *u8): i32;

/** Write C string s to opaque FILE* stream via fputs.
 * Null s or stream → -1. Otherwise returns libc fputs result (EOF → negative).
 * Wave22 pure: null guard in .x; FILE* cast via g05 shux_driver_fputs_opaque.
 * G.7 single authority for Cap residual fputs (async/rt_preamble call this symbol).
 * PLATFORM: SHARED — pure under PREFER hybrid; cold seed keeps C twin. */
#[no_mangle]
export function driver_preamble_fputs(s: *u8, stream: *u8): i32 {
  if (s == 0 as *u8) {
    return -1;
  }
  if (stream == 0 as *u8) {
    return -1;
  }
  unsafe {
    return shux_driver_fputs_opaque(s, stream);
  }
  return -1;
}

// ---- Wave23 Cap residual pure: calloc family + host_defaults (PLATFORM: SHARED LP64) ----
// G.7: product authority under PREFER hybrid thin; cold seed keeps C twins (sizeof / #ifdef).
// Sizes: outbuf = 9MiB data + i32 len (wave14 layout); dep_ctx/elf via pipeline_sizeof_*;
//   ptr/size table element = 8 on LP64; DiagContextSnapshot = 32 on LP64.
// host_defaults: field writes via wave19 setters; target substr via strstr + BSS needles;
//   host #ifdef arch/macho/coff via permanent OS residual helpers (seed rest always linked).
// Still seed: free/get/set/len/data table accessors; tmp path slots; giant tables.

/** libc zero-fill alloc. PLATFORM: SHARED. */
export extern "C" function calloc(nmemb: usize, size: usize): *u8;
/** libc heap alloc. PLATFORM: SHARED. */
export extern "C" function malloc(sz: usize): *u8;
/** libc memset. PLATFORM: SHARED. */
export extern "C" function memset(p: *u8, c: i32, n: usize): *u8;
/** libc strstr. PLATFORM: SHARED — target triple substring parse in host_defaults. */
export extern "C" function strstr(hay: *u8, needle: *u8): *u8;
/** Authority size of ast_PipelineDepCtx (pipeline_glue). PLATFORM: SHARED LP64. */
export extern "C" function pipeline_sizeof_dep_ctx(): usize;
/** Authority size of ElfCodegenCtx (0 when ELF ctx disabled). PLATFORM: SHARED. */
export extern "C" function pipeline_sizeof_elf_ctx(): usize;
/** Pending -mcpu feature bits from target_cpu pure. PLATFORM: SHARED. */
export extern "C" function driver_get_pending_target_cpu_features(): u32;
/** Host default target_arch when -target is null (1 = aarch64 on Apple arm64 host).
 * Permanent OS residual: seed #if __APPLE__ && __aarch64__. PLATFORM: MACOS arm64 vs SHARED.
 */
export extern "C" function shux_driver_host_default_target_arch(): i32;
/** Prefer Mach-O object when emit_elf_o on Apple host. Permanent OS residual. PLATFORM: MACOS. */
export extern "C" function shux_driver_host_prefer_macho(emit_elf_o: i32): i32;
/** Prefer COFF object when emit_elf_o on Windows/Cygwin host. Permanent OS residual. PLATFORM: WINDOWS. */
export extern "C" function shux_driver_host_prefer_coff(emit_elf_o: i32): i32;

// Target-triple needles (NUL-terminated) for strstr in host_defaults.
// ASCII "aarch64\0"
let g_driver_host_needle_aarch64: u8[8] = [97, 97, 114, 99, 104, 54, 52, 0];
// ASCII "arm64\0"
let g_driver_host_needle_arm64: u8[6] = [97, 114, 109, 54, 52, 0];
// ASCII "riscv64\0"
let g_driver_host_needle_riscv64: u8[8] = [114, 105, 115, 99, 118, 54, 52, 0];
// ASCII "windows\0"
let g_driver_host_needle_windows: u8[8] = [119, 105, 110, 100, 111, 119, 115, 0];

/** Fixed sizeof(driver_codegen_outbuf_abi) on product LP64: 9*1024*1024 + 4.
 * Must match seed X_CODEGEN_OUTBUF_CAP_ABI + int32_t len (wave14 OutBuf layout).
 */
function driver_abi_sizeof_codegen_outbuf(): usize {
  return 9437188 as usize;
}

/** Fixed sizeof(DiagContextSnapshot) on LP64 (3×ptr + size_t + int + pad = 32). */
function driver_abi_sizeof_diag_snapshot(): usize {
  return 32 as usize;
}

/** LP64 pointer / size_t width in bytes. */
function driver_abi_sizeof_lp64_word(): usize {
  return 8 as usize;
}

/** Allocate zeroed CodegenOutBuf (9MiB data + i32 len).
 * Wave23 pure: calloc(1, fixed sizeof). PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_codegen_outbuf_calloc(): *u8 {
  unsafe {
    return calloc(1 as usize, driver_abi_sizeof_codegen_outbuf());
  }
  return 0 as *u8;
}

/** Allocate zeroed PipelineDepCtx via pipeline_sizeof_dep_ctx.
 * Wave23 pure: no C struct in .x. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_pipeline_dep_ctx_calloc(): *u8 {
  unsafe {
    let sz: usize = pipeline_sizeof_dep_ctx();
    if (sz == 0 as usize) {
      return 0 as *u8;
    }
    return calloc(1 as usize, sz);
  }
  return 0 as *u8;
}

/** Allocate zeroed void*[n] pointer table (LP64 element size 8).
 * n <= 0 → null. Wave23 pure. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_ptr_table_calloc(n: i32): *u8 {
  if (n <= 0) {
    return 0 as *u8;
  }
  unsafe {
    return calloc(n as usize, driver_abi_sizeof_lp64_word());
  }
  return 0 as *u8;
}

/** Allocate zeroed size_t[n] table (LP64 element size 8).
 * n <= 0 → null. Wave23 pure. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_size_table_calloc(n: i32): *u8 {
  if (n <= 0) {
    return 0 as *u8;
  }
  unsafe {
    return calloc(n as usize, driver_abi_sizeof_lp64_word());
  }
  return 0 as *u8;
}

/** Allocate zeroed DiagContextSnapshot (LP64 size 32).
 * Wave23 pure. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_diag_snapshot_alloc(): *u8 {
  unsafe {
    return calloc(1 as usize, driver_abi_sizeof_diag_snapshot());
  }
  return 0 as *u8;
}

/** Allocate zeroed ElfCodegenCtx via pipeline_sizeof_elf_ctx + malloc/memset.
 * sz==0 (no ELF) → null. Wave23 pure. PLATFORM: SHARED (ELF size 0 on non-ELF builds).
 */
#[no_mangle]
export function driver_asm_elf_ctx_calloc(): *u8 {
  unsafe {
    let sz: usize = pipeline_sizeof_elf_ctx();
    if (sz == 0 as usize) {
      return 0 as *u8;
    }
    let p: *u8 = malloc(sz);
    if (p != 0 as *u8) {
      memset(p, 0, sz);
    }
    return p;
  }
  return 0 as *u8;
}

/** Fill PipelineDepCtx host defaults from -target string and emit_elf_o flag.
 * Logic (matches cold seed twin):
 *   1) target_arch: 0 default; aarch64|arm64 → 1; riscv64 → 2
 *   2) target_cpu_features from driver_get_pending_target_cpu_features
 *   3) if target is null, host default arch (Apple aarch64 host → 1) via OS residual
 *   4) use_macho_o / use_coff_o: host #ifdef via OS residual when emit_elf_o;
 *      plus target contains "windows" → coff=1 when emit_elf_o
 * Field writes: wave19 pure setters (G.7). No C struct in .x.
 * PLATFORM: SHARED orch; MACOS/WINDOWS residual helpers only for host #ifdef.
 */
#[no_mangle]
export function driver_asm_pctx_apply_host_defaults(ctx: *u8, target: *u8, emit_elf_o: i32): void {
  let arch: i32 = 0;
  let feats: i32 = 0;
  let macho: i32 = 0;
  let coff: i32 = 0;
  let ha: i32 = 0;
  if (ctx == 0 as *u8) {
    return;
  }
  // Parse arch from -target triple (substring match).
  if (target != 0 as *u8) {
    unsafe {
      if (strstr(target, &g_driver_host_needle_aarch64[0]) != 0 as *u8) {
        arch = 1;
      }
      if (strstr(target, &g_driver_host_needle_arm64[0]) != 0 as *u8) {
        arch = 1;
      }
      if (strstr(target, &g_driver_host_needle_riscv64[0]) != 0 as *u8) {
        arch = 2;
      }
    }
  }
  driver_pipeline_dep_ctx_set_target_arch(ctx, arch);
  unsafe {
    feats = driver_get_pending_target_cpu_features() as i32;
  }
  driver_pipeline_dep_ctx_set_target_cpu_features(ctx, feats);
  // Host default arch only when -target is absent (seed: if (!t) on Apple aarch64).
  if (target == 0 as *u8) {
    unsafe {
      ha = shux_driver_host_default_target_arch();
    }
    if (ha != 0) {
      driver_pipeline_dep_ctx_set_target_arch(ctx, ha);
    }
  }
  // Object format prefs: host platform residual + windows in triple.
  unsafe {
    macho = shux_driver_host_prefer_macho(emit_elf_o);
    coff = shux_driver_host_prefer_coff(emit_elf_o);
  }
  if (emit_elf_o != 0) {
    if (target != 0 as *u8) {
      unsafe {
        if (strstr(target, &g_driver_host_needle_windows[0]) != 0 as *u8) {
          coff = 1;
        }
      }
    }
  }
  driver_pipeline_dep_ctx_set_use_macho_o(ctx, macho);
  driver_pipeline_dep_ctx_set_use_coff_o(ctx, coff);
}

// ---- Wave24 Cap residual pure: table free/get/set + outbuf free/len/data (PLATFORM: SHARED) ----
// Pairs wave23 calloc family. Cold seed keeps C twins under #ifndef SHUX_L2_RDABI_THIN_FROM_X.
// Layout: CodegenOutBuf = data[9MiB] then i32 len at offset CAP (wave14 LE helpers).
// ptr table: void*[n] → G.7 shux_ptr_slot_get/set. size table: size_t[n] → LE usize at i*8.

/**
 * Load little-endian usize at base+off (null / off < 0 → 0).
 * Module-local host layout helper for size_t tables (LP64 8-byte cells).
 * @param p *u8 — base address of the table or buffer; null-safe
 * @param off i32 — byte offset from p; negative → 0
 * @return usize — LE-decoded value, or 0 on invalid base/offset
 * PLATFORM: SHARED LP64.
 */
function driver_abi_load_usize_le(p: *u8, off: i32): usize {
  if (p == 0 as *u8) {
    return 0 as usize;
  }
  if (off < 0) {
    return 0 as usize;
  }
  unsafe {
    let m: usize = 256 as usize;
    let m2: usize = m * m;
    let m4: usize = m2 * m2;
    let a0: usize = p[off] as usize;
    let a1: usize = a0 + (p[off + 1] as usize) * m;
    let a2: usize = a1 + (p[off + 2] as usize) * m2;
    let a3: usize = a2 + (p[off + 3] as usize) * (m2 * m);
    let a4: usize = a3 + (p[off + 4] as usize) * m4;
    let a5: usize = a4 + (p[off + 5] as usize) * (m4 * m);
    let a6: usize = a5 + (p[off + 6] as usize) * (m4 * m2);
    let a7: usize = a6 + (p[off + 7] as usize) * (m4 * m2 * m);
    return a7;
  }
  return 0 as usize;
}

/**
 * Store little-endian usize at base+off (null / off < 0 no-op).
 * Module-local host layout helper for size_t tables (LP64 8-byte cells).
 * @param p *u8 — base address of the table or buffer; null-safe
 * @param off i32 — byte offset from p; negative → no-op
 * @param v usize — value to store little-endian
 * @return void
 * PLATFORM: SHARED LP64.
 */
function driver_abi_store_usize_le(p: *u8, off: i32, v: usize): void {
  if (p == 0 as *u8) {
    return;
  }
  if (off < 0) {
    return;
  }
  unsafe {
    // Same successive /256 + low-byte extract pattern as wave14 i32 LE store (no % op).
    let m: usize = 256 as usize;
    let b255: usize = 255 as usize;
    let u0: usize = v;
    p[off] = (u0 & b255) as u8;
    let u1: usize = u0 / m;
    p[off + 1] = (u1 & b255) as u8;
    let u2: usize = u1 / m;
    p[off + 2] = (u2 & b255) as u8;
    let u3: usize = u2 / m;
    p[off + 3] = (u3 & b255) as u8;
    let u4: usize = u3 / m;
    p[off + 4] = (u4 & b255) as u8;
    let u5: usize = u4 / m;
    p[off + 5] = (u5 & b255) as u8;
    let u6: usize = u5 / m;
    p[off + 6] = (u6 & b255) as u8;
    let u7: usize = u6 / m;
    p[off + 7] = (u7 & b255) as u8;
  }
}

/**
 * Free a CodegenOutBuf previously allocated by driver_codegen_outbuf_calloc.
 * @param p *u8 — heap pointer from outbuf_calloc; null is safe (free no-op)
 * @return void
 * Wave24 pure. PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_codegen_outbuf_free(p: *u8): void {
  unsafe {
    free(p);
  }
}

/**
 * Read the live byte length of a CodegenOutBuf (i32 len after the 9MiB data[]).
 * @param p *u8 — outbuf pointer; null → 0
 * @return i32 — current len field (LE at offset CAP), or 0 if p is null
 * Wave24 pure: wave14 LE load. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_codegen_outbuf_len(p: *u8): i32 {
  if (p == 0 as *u8) {
    return 0;
  }
  return driver_abi_load_i32_le(p, driver_abi_codegen_outbuf_cap());
}

/**
 * Return pointer to the data[] base of a CodegenOutBuf (first byte of the buffer).
 * @param p *u8 — outbuf pointer; null → null
 * @return *u8 — &data[0], same address as p on product layout (data is first field)
 * Wave24 pure. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_codegen_outbuf_data(p: *u8): *u8 {
  if (p == 0 as *u8) {
    return 0 as *u8;
  }
  // Host layout: unsigned char data[CAP] is the first field; p is already data base.
  return p;
}

/**
 * Free a void* table from driver_ptr_table_calloc.
 * @param t *u8 — heap table; null is safe
 * @return void
 * Wave24 pure. PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_ptr_table_free(t: *u8): void {
  unsafe {
    free(t);
  }
}

/**
 * Load pointer table slot i (LP64 void* element).
 * @param t *u8 — table from ptr_table_calloc; null → null
 * @param i i32 — index; i < 0 → null (no upper bound check; caller owns n)
 * @return *u8 — stored pointer at slot i, or null
 * Wave24 pure: G.7 shux_ptr_slot_get. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_ptr_table_get(t: *u8, i: i32): *u8 {
  if (t == 0 as *u8) {
    return 0 as *u8;
  }
  if (i < 0) {
    return 0 as *u8;
  }
  // FFI: G.7 authority lives in pipeline C; Cap-T001 unsafe at call site.
  unsafe {
    return shux_ptr_slot_get(t, i);
  }
  return 0 as *u8;
}

/**
 * Store pointer table slot i (LP64 void* element).
 * @param t *u8 — table from ptr_table_calloc; null → no-op
 * @param i i32 — index; i < 0 → no-op
 * @param p *u8 — value to store (may be null)
 * @return void
 * Wave24 pure: G.7 shux_ptr_slot_set. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_ptr_table_set(t: *u8, i: i32, p: *u8): void {
  if (t == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  unsafe {
    shux_ptr_slot_set(t, i, p);
  }
}

/**
 * Free a size_t table from driver_size_table_calloc.
 * @param t *u8 — heap table; null is safe
 * @return void
 * Wave24 pure. PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_size_table_free(t: *u8): void {
  unsafe {
    free(t);
  }
}

/**
 * Load size_t table slot i (LP64 8-byte LE cell at offset i*8).
 * @param t *u8 — table from size_table_calloc; null → 0
 * @param i i32 — index; i < 0 → 0
 * @return usize — stored size at slot i, or 0
 * Wave24 pure. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_size_table_get(t: *u8, i: i32): usize {
  if (t == 0 as *u8) {
    return 0 as usize;
  }
  if (i < 0) {
    return 0 as usize;
  }
  // Element size 8: byte offset = i * 8.
  return driver_abi_load_usize_le(t, i * 8);
}

/**
 * Store size_t table slot i (LP64 8-byte LE cell at offset i*8).
 * @param t *u8 — table from size_table_calloc; null → no-op
 * @param i i32 — index; i < 0 → no-op
 * @param v usize — value to store
 * @return void
 * Wave24 pure. PLATFORM: SHARED LP64.
 */
#[no_mangle]
export function driver_size_table_set(t: *u8, i: i32, v: usize): void {
  if (t == 0 as *u8) {
    return;
  }
  if (i < 0) {
    return;
  }
  driver_abi_store_usize_le(t, i * 8, v);
}

/**
 * Free a DiagContextSnapshot from driver_diag_snapshot_alloc.
 * @param s *u8 — heap snapshot; null is safe
 * @return void
 * Wave24 pure. PLATFORM: SHARED.
 */
#[no_mangle]
export function driver_diag_snapshot_free(s: *u8): void {
  unsafe {
    free(s);
  }
}

// ---- Wave26 Cap residual pure: parsed fclose + write_out (PLATFORM: SHARED) ----
// G.7 authority under PREFER hybrid thin; cold seed keeps C twins (FILE* cast).
// .x cannot name FILE* or compare to stdout — g05 prologue injects:
//   shux_driver_stdout_ptr / shux_driver_fclose_opaque / shux_driver_fwrite_opaque
// (same harness pattern as wave22 shux_driver_fputs_opaque).
// write_out still calls always-seed write_io_net_abi_inline + write_fs_path_map_error_abi_inline
// (rt_preamble Cap-giant-string tables + skip mask). min preamble via driver_preamble_fputs
// short lits (avoid long -E string cap). wave27 open_out; wave28 invoke_cc; still seed: giant tables.

/** g05 prologue: opaque identity of host stdout as *u8.
 * PLATFORM: SHARED — harness residual; product pure compares pointers only. */
export extern "C" function shux_driver_stdout_ptr(): *u8;
/** g05 prologue: fclose((FILE*)stream); 0 success, 1 failure; null → 0.
 * PLATFORM: SHARED — harness FILE* cast residual. */
export extern "C" function shux_driver_fclose_opaque(stream: *u8): i32;
/** g05 prologue: fwrite(data,1,len,FILE*); 0 full write, 1 fail; len==0 → 0.
 * @param data *u8 — bytes to write
 * @param len i32 — byte count; negative rejected as fail
 * @param stream *u8 — opaque FILE*
 * PLATFORM: SHARED — harness FILE* cast residual. */
export extern "C" function shux_driver_fwrite_opaque(data: *u8, len: i32, stream: *u8): i32;
/** Always-seed rt_preamble: write io/net Cap-giant-string ABI block to opaque FILE*.
 * @param cf *u8 — FILE* as *u8 (product C ABI pointer-compatible with FILE*)
 * @return i32 — 0 success, non-zero fail
 * PLATFORM: SHARED — table+skip authority remains seeds/rt_preamble.from_x.c. */
export extern "C" function write_io_net_abi_inline(cf: *u8): i32;
/** Always-seed rt_preamble: write fs/path/map/error Cap-giant-string ABI block.
 * @param cf *u8 — FILE* as *u8
 * @return i32 — 0 success, non-zero fail
 * PLATFORM: SHARED. */
export extern "C" function write_fs_path_map_error_abi_inline(cf: *u8): i32;

/**
 * Close a parsed-pipeline C output FILE* (opaque *u8).
 * Null or stdout → no-op (stdout must stay open for -E emit-to-stdout).
 * @param fp *u8 — opaque FILE* from open_out / work slot; may be null or stdout
 * @return void
 * Wave26 pure: stdout identity via g05 shux_driver_stdout_ptr; fclose via opaque.
 * PLATFORM: SHARED — pure under PREFER hybrid; cold seed keeps C twin.
 */
#[no_mangle]
export function driver_parsed_fclose(fp: *u8): void {
  if (fp == 0 as *u8) {
    return;
  }
  unsafe {
    let so: *u8 = shux_driver_stdout_ptr();
    if (fp == so) {
      return;
    }
    shux_driver_fclose_opaque(fp);
  }
}

/**
 * Close a parsed-pipeline C output FILE* and report status.
 * Null or stdout → 0 (success no-op). Otherwise 0 if fclose succeeds, 1 on fail.
 * @param fp *u8 — opaque FILE*; may be null or stdout
 * @return i32 — 0 success / no-op, 1 fclose failure
 * Wave26 pure. PLATFORM: SHARED — pure under PREFER hybrid; cold seed keeps C twin.
 */
#[no_mangle]
export function driver_parsed_fclose_rc(fp: *u8): i32 {
  if (fp == 0 as *u8) {
    return 0;
  }
  unsafe {
    let so: *u8 = shux_driver_stdout_ptr();
    if (fp == so) {
      return 0;
    }
    return shux_driver_fclose_opaque(fp);
  }
  return 0;
}

/**
 * Write min-preamble include block used when generated C lacks leading # or comment.
 * Split into short fputs lits so -E string cap (~63) cannot truncate a single lit.
 * @param fp *u8 — opaque FILE*; non-null (caller validated)
 * @return i32 — 0 success, 1 if any fputs failed
 * Wave26 pure helper (not product export surface beyond write_out). PLATFORM: SHARED.
 */
function driver_parsed_write_min_preamble(fp: *u8): i32 {
  // Each lit is short; driver_preamble_fputs returns libc fputs result (EOF → negative).
  if (driver_preamble_fputs("/* generated */\n", fp) < 0) {
    return 1;
  }
  if (driver_preamble_fputs("#include <stdint.h>\n", fp) < 0) {
    return 1;
  }
  if (driver_preamble_fputs("#include <stddef.h>\n", fp) < 0) {
    return 1;
  }
  if (driver_preamble_fputs("#include <stdlib.h>\n", fp) < 0) {
    return 1;
  }
  if (driver_preamble_fputs("#include <stdio.h>\n", fp) < 0) {
    return 1;
  }
  if (driver_preamble_fputs("#include <string.h>\n", fp) < 0) {
    return 1;
  }
  return 0;
}

/**
 * Write pipeline C product to open FILE*: optional min preamble, first source line,
 * then io_net + fs_path Cap residual ABI tables, then remainder of data.
 * @param fp *u8 — opaque FILE* from open_out; null rejected
 * @param data *u8 — full generated C bytes; null rejected
 * @param len i32 — byte count of data; negative → fail; 0 still inserts preamble path
 * @return i32 — 0 success, 1 I/O or table-write failure
 * Wave26 pure: first-line scan + need_preamble gate in .x; fwrite via g05 opaque;
 * write_io_net_abi_inline / write_fs_path_map_error_abi_inline remain seed (giant tables).
 * PLATFORM: SHARED — pure under PREFER hybrid; cold seed keeps C twin.
 */
#[no_mangle]
export function driver_parsed_write_out(fp: *u8, data: *u8, len: i32): i32 {
  if (fp == 0 as *u8) {
    return 1;
  }
  if (data == 0 as *u8) {
    return 1;
  }
  if (len < 0) {
    return 1;
  }
  // first_line = index just past first '\n' (or len if no newline).
  let first_line: i32 = 0;
  while (first_line < len) {
    if (data[first_line] == 10) {
      first_line = first_line + 1;
      break;
    }
    first_line = first_line + 1;
  }
  // need_preamble when body does not already start with '#' or '/*'.
  let need_preamble: i32 = 0;
  if (len > 0) {
    if (data[0] != 35) {
      // not '#'
      if (len < 2) {
        need_preamble = 1;
      } else {
        if (data[0] != 47) {
          // not '/'
          need_preamble = 1;
        } else {
          if (data[1] != 42) {
            // not '*'
            need_preamble = 1;
          }
        }
      }
    }
  }
  if (need_preamble != 0) {
    if (driver_parsed_write_min_preamble(fp) != 0) {
      return 1;
    }
  }
  unsafe {
    if (shux_driver_fwrite_opaque(data, first_line, fp) != 0) {
      return 1;
    }
    if (write_io_net_abi_inline(fp) != 0) {
      return 1;
    }
    if (write_fs_path_map_error_abi_inline(fp) != 0) {
      return 1;
    }
    let rest: i32 = len - first_line;
    if (rest > 0) {
      // data + first_line as *u8 without pointer arithmetic type issues.
      let rest_p: *u8 = &data[first_line];
      if (shux_driver_fwrite_opaque(rest_p, rest, fp) != 0) {
        return 1;
      }
    }
  }
  return 0;
}

// ---- Wave27 Cap residual pure: driver_parsed_open_out_file (PLATFORM: SHARED) ----
// G.7 authority under PREFER hybrid thin; cold seed keeps C twin (FILE* + snprintf).
// Cap residual split:
//   - seed always: shux_driver_tmp_prefix (SHUX_TMP_PREFIX #ifdef; no platform ifdef in .x)
//   - g05 prologue: shux_driver_fopen_write_opaque (FILE* cast; same pattern as wave22/26)
//   - libc via g05 unistd/stdio: mkstemp, close, rename, unlink
//   - pure orch: stdout gate, template build, close-before-rename (BLD001), path copy
// Still seed after wave28: rt_preamble giant tables (write_io_net / write_fs_path).

/** Permanent OS residual: host temp path prefix for mkstemp templates.
 * @return *u8 — NUL-terminated C string; POSIX "/tmp/shux_"; WINDOWS "shux_"
 * PLATFORM: SHARED surface; body is #ifdef in seed rest (not pure-dup). */
export extern "C" function shux_driver_tmp_prefix(): *u8;
/** POSIX mkstemp: mutate template ending in XXXXXX; return fd or -1.
 * PLATFORM: POSIX product path (win32_compat may provide on WINDOWS probes). */
export extern "C" function mkstemp(path: *u8): i32;
/** POSIX close(fd). PLATFORM: POSIX / win32_compat. */
export extern "C" function close(fd: i32): i32;
/** POSIX rename(old, new). PLATFORM: SHARED rename surface. */
export extern "C" function rename(old_path: *u8, new_path: *u8): i32;
/** g05 prologue: fopen(path, "w") as opaque *u8; null path → null.
 * PLATFORM: SHARED — harness FILE* cast residual. */
export extern "C" function shux_driver_fopen_write_opaque(path: *u8): *u8;
/** Diag with single path + errno (runtime authority). */
export extern "C" function runtime_diag_errno_path(
  file: *u8, kind: *u8, op: *u8, path: *u8): void;
/** Diag with from/to path pair + errno (runtime authority). */
export extern "C" function runtime_diag_errno_path_pair(
  file: *u8, kind: *u8, op: *u8, from_path: *u8, to_path: *u8): void;

/**
 * Copy NUL-terminated src into dst with capacity cap (writes trailing NUL).
 * @param dst *u8 — destination; null → no-op
 * @param cap i32 — capacity including NUL; cap <= 0 → no-op
 * @param src *u8 — source C string; null treated as empty
 * @return void
 * Wave27 pure helper. PLATFORM: SHARED.
 */
function driver_open_out_cstr_copy(dst: *u8, cap: i32, src: *u8): void {
  if (dst == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  if (cap == 1) {
    dst[0] = 0;
    return;
  }
  let i: i32 = 0;
  let max: i32 = cap - 1;
  if (src == 0 as *u8) {
    dst[0] = 0;
    return;
  }
  while (i < max) {
    let b: u8 = src[i];
    if (b == 0) {
      break;
    }
    dst[i] = b;
    i = i + 1;
  }
  dst[i] = 0;
}

/**
 * Append NUL-terminated src onto dst (dst must already be NUL-terminated).
 * @param dst *u8 — destination buffer; null → no-op
 * @param cap i32 — total capacity including NUL
 * @param src *u8 — suffix to append; null → no-op
 * @return void
 * Wave27 pure helper. PLATFORM: SHARED.
 */
function driver_open_out_cstr_cat(dst: *u8, cap: i32, src: *u8): void {
  if (dst == 0 as *u8) {
    return;
  }
  if (cap <= 0) {
    return;
  }
  if (src == 0 as *u8) {
    return;
  }
  let i: i32 = 0;
  while (i < cap) {
    if (dst[i] == 0) {
      break;
    }
    i = i + 1;
  }
  // i is current length; append until cap-1.
  let j: i32 = 0;
  while (i < (cap - 1)) {
    let b: u8 = src[j];
    if (b == 0) {
      break;
    }
    dst[i] = b;
    i = i + 1;
    j = j + 1;
  }
  if (i < cap) {
    dst[i] = 0;
  } else {
    dst[cap - 1] = 0;
  }
}

/**
 * Open pipeline C output: null out_path → stdout (emit_stdout=1); else mkstemp + rename .c + fopen "w".
 * @param out_path *u8 — product output path (diag file field); null means emit-to-stdout (-E style)
 * @param tmp_c_out64 *u8 — optional buffer for resulting .c path (cap >= 256 recommended); may be null
 * @param emit_stdout *i32 — out flag: 1 when returning stdout, else 0; may be null
 * @return *u8 — opaque FILE* (or stdout) on success; null on failure (diag already emitted)
 * Wave27 pure: stdout identity via g05 stdout_ptr; path BSS via wave25 accessor;
 * template = shux_driver_tmp_prefix() + "shux_x.XXXXXX"; close(fd) before rename (BLD001);
 * fopen via g05 opaque. PLATFORM: SHARED orch; WINDOWS|POSIX close-before-rename contract.
 */
#[no_mangle]
export function driver_parsed_open_out_file(
  out_path: *u8, tmp_c_out64: *u8, emit_stdout: *i32): *u8 {
  unsafe {
    if (emit_stdout != 0 as *i32) {
      emit_stdout[0] = 0;
    }
    let tbuf: *u8 = driver_parsed_tmp_c_buf();
    if (tbuf != 0 as *u8) {
      tbuf[0] = 0;
    }
    if (tmp_c_out64 != 0 as *u8) {
      tmp_c_out64[0] = 0;
    }
    // Emit-to-stdout path: no temp file; caller must not fclose stdout.
    if (out_path == 0 as *u8) {
      if (emit_stdout != 0 as *i32) {
        emit_stdout[0] = 1;
      }
      return shux_driver_stdout_ptr();
    }
    if (tbuf == 0 as *u8) {
      return 0 as *u8;
    }
    // Stack template for mkstemp (mutates XXXXXX in place). Cap 128 matches cold twin.
    let tmp: u8[128] = [];
    let prefix: *u8 = shux_driver_tmp_prefix();
    driver_open_out_cstr_copy(&tmp[0], 128, prefix);
    // Suffix is short; keep under -E string cap (~63).
    driver_open_out_cstr_cat(&tmp[0], 128, "shux_x.XXXXXX");
    let fd: i32 = mkstemp(&tmp[0]);
    if (fd < 0) {
      runtime_diag_errno_path(out_path, "build error", "mkstemp", &tmp[0]);
      return 0 as *u8;
    }
    // PLATFORM: WINDOWS | POSIX — must close before rename (Windows sharing violation).
    close(fd);
    // tbuf = tmp + ".c" (cap 256 pure BSS).
    driver_open_out_cstr_copy(tbuf, 256, &tmp[0]);
    driver_open_out_cstr_cat(tbuf, 256, ".c");
    if (rename(&tmp[0], tbuf) != 0) {
      runtime_diag_errno_path_pair(out_path, "build error", "rename", &tmp[0], tbuf);
      unlink(&tmp[0]);
      return 0 as *u8;
    }
    let cf: *u8 = shux_driver_fopen_write_opaque(tbuf);
    if (cf == 0 as *u8) {
      runtime_diag_errno_path(out_path, "build error", "fopen", tbuf);
      unlink(tbuf);
      return 0 as *u8;
    }
    // Optional copy of final .c path for work slots / invoke_cc.
    if (tmp_c_out64 != 0 as *u8) {
      driver_open_out_cstr_copy(tmp_c_out64, 256, tbuf);
    }
    return cf;
  }
  return 0 as *u8;
}

// ---- Wave28 Cap residual pure: driver_parsed_invoke_cc (PLATFORM: SHARED) ----
// G.7 authority under PREFER hybrid thin; cold seed keeps C twin (c_paths[1] + path pack).
// Cap residual split:
//   - product link authority: shux_invoke_cc (+ set/clear user .o table)
//   - path resolvers: shux_std_io_o_path / shux_rel_o_path_from_argv0 /
//     shux_runtime_panic_o_path / shux_repo_root_from_argv0 (same seed surface as cold)
//   - pure orch: null gate, default opt "2", c_paths pack via G.7 ptr_slot,
//     fail unlink+BLD001 (append+diag_report_with_code), KEEP_C note, success unlink tmp
// Still seed: rt_preamble giant tables (io_net / fs_path).

/** Resolve std/io/io.o (or product empty F-06) from compiler argv0. */
export extern "C" function shux_std_io_o_path(argv0: *u8): *u8;
/** Resolve repo-relative .o path from argv0 (e.g. "std/process/process.o").
 * @param argv0 *u8 — compiler argv[0]; may be null
 * @param rel *u8 — relative path under repo/compiler layout; non-null
 * @return *u8 — stable path string or null
 * PLATFORM: SHARED — link_abi authority. */
export extern "C" function shux_rel_o_path_from_argv0(argv0: *u8, rel: *u8): *u8;
/** Resolve runtime_panic.o path from argv0. PLATFORM: SHARED. */
export extern "C" function shux_runtime_panic_o_path(argv0: *u8): *u8;
/** Repo root directory from compiler argv0 (include_root for invoke_cc).
 * PLATFORM: SHARED. */
export extern "C" function shux_repo_root_from_argv0(argv0: *u8): *u8;
/** Product C frontend host-cc link: fixed std/core .o list + scan-on-demand.
 * @param c_paths *u8 — opaque const char** (one-slot table from pure pack)
 * @param n i32 — number of .c paths (parsed pipeline uses 1)
 * @param out_path *u8 — product -o path; non-null
 * @param target *u8 — triple or null
 * @param opt_level *u8 — "0".."3"; pure default "2" when caller passes null
 * @param use_lto i32 — LTO flag
 * @param … remaining *u8 — optional std/core .o paths (null ok; impl may scan C)
 * @return i32 — 0 success, non-zero host-cc fail
 * PLATFORM: SHARED — runtime_link_abi authority. */
export extern "C" function shux_invoke_cc(
  c_paths: *u8, n: i32, out_path: *u8, target: *u8, opt_level: *u8, use_lto: i32,
  io_o: *u8, fs_o: *u8, process_o: *u8, string_o: *u8, heap_o: *u8, path_o: *u8,
  runtime_o: *u8, runtime_panic_o: *u8, net_o: *u8, thread_o: *u8, time_o: *u8,
  random_o: *u8, env_o: *u8, sync_o: *u8, encoding_o: *u8, base64_o: *u8, crypto_o: *u8,
  log_o: *u8, atomic_o: *u8, channel_o: *u8, backtrace_o: *u8, hash_o: *u8, math_o: *u8,
  sort_o: *u8, ffi_o: *u8, db_o: *u8, elf_o: *u8, json_o: *u8, csv_o: *u8, regex_o: *u8,
  compress_o: *u8, unicode_o: *u8, dynlib_o: *u8, http_o: *u8, tar_o: *u8, simd_o: *u8,
  context_o: *u8, datetime_o: *u8, uuid_o: *u8, url_o: *u8, cli_o: *u8, security_o: *u8,
  config_o: *u8, cache_o: *u8, trace_o: *u8, task_o: *u8, schema_o: *u8, test_o: *u8,
  include_root: *u8, async_scheduler_o: *u8): i32;
/** G.7 single authority: plumb CLI user .o files into invoke_cc/ld link line.
 * @param argc i32 — argv length
 * @param argv *u8 — opaque char** (same as process argv)
 * PLATFORM: SHARED — set before invoke; clear after. */
export extern "C" function shux_invoke_cc_set_user_o_files_from_argv(argc: i32, argv: *u8): void;
/** Clear user .o table after invoke (prevents stale pointers). PLATFORM: SHARED. */
export extern "C" function shux_invoke_cc_clear_user_o_files(): void;
/** Unlink failed product -o path (best-effort). PLATFORM: SHARED. */
export extern "C" function driver_unlink_failed_output(out_path: *u8): void;

/**
 * Host-cc link step after open_out/write_out: pack std .o paths, invoke shux_invoke_cc,
 * then unlink failed out or drop/keep generated tmp .c.
 * @param tmp_c *u8 — path to generated .c from open_out; null → fail 1
 * @param out_path *u8 — product -o path; null → fail 1
 * @param opt_level *u8 — opt level string; null → default "2"
 * @param use_lto i32 — LTO flag passed through to shux_invoke_cc
 * @param argv0 *u8 — compiler argv[0] for path resolution; may be null
 * @param argc i32 — full argv count (user .o scan)
 * @param argv *u8 — opaque char** argv base (user .o scan)
 * @return i32 — 0 success, 1 host-cc fail (BLD001 already reported) or bad args
 * Wave28 pure: c_paths one-slot via G.7 shux_ptr_slot_set; fail/KEEP_C via
 * append + diag_report(_with_code) (no va_list reportf).
 * PLATFORM: SHARED — pure under PREFER hybrid; cold seed keeps C twin.
 */
#[no_mangle]
export function driver_parsed_invoke_cc(
  tmp_c: *u8, out_path: *u8, opt_level: *u8, use_lto: i32,
  argv0: *u8, argc: i32, argv: *u8): i32 {
  if (tmp_c == 0 as *u8) {
    return 1;
  }
  if (out_path == 0 as *u8) {
    return 1;
  }
  unsafe {
    let opt: *u8 = opt_level;
    if (opt == 0 as *u8) {
      opt = "2";
    }
    // c_paths[1] as raw LP64 pointer table (G.7; .x bans **u8 array lit).
    let c_paths_raw: u8[8] = [];
    shux_ptr_slot_set(&c_paths_raw[0], 0, tmp_c);
    // Path pack mirrors cold seed twin (F-06 nulls for scan-on-demand modules).
    let a0: *u8 = argv0;
    let io_o: *u8 = shux_std_io_o_path(a0);
    let fs_o: *u8 = 0 as *u8;
    let process_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/process/process.o");
    let string_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/string/string.o");
    let heap_o: *u8 = 0 as *u8;
    let path_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/path/path.o");
    let runtime_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/runtime/runtime.o");
    let runtime_panic_o: *u8 = shux_runtime_panic_o_path(a0);
    let net_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/net/net.o");
    let thread_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/thread/thread.o");
    let time_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/time/time.o");
    let random_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/random/random.o");
    let env_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/env/env.o");
    let sync_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/sync/sync.o");
    let encoding_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/encoding/encoding.o");
    let base64_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/base64/base64.o");
    let crypto_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/crypto/crypto.o");
    let log_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/log/log.o");
    let atomic_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/atomic/atomic.o");
    let channel_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/channel/channel.o");
    let backtrace_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/backtrace/backtrace.o");
    let hash_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/hash/hash.o");
    let math_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/math/math.o");
    let sort_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/sort/sort.o");
    let ffi_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/ffi/ffi.o");
    let db_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/db/sqlite/sqlite.o");
    let elf_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/elf/elf.o");
    let json_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/json/json.o");
    let csv_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/csv/csv.o");
    let regex_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/regex/regex.o");
    let compress_o: *u8 = 0 as *u8;
    let unicode_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/unicode/unicode.o");
    let dynlib_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/dynlib/dynlib.o");
    let http_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/http/http.o");
    let tar_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/tar/tar.o");
    let simd_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/simd/simd.o");
    let context_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/context/context.o");
    let datetime_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/datetime/datetime.o");
    let uuid_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/uuid/uuid.o");
    let url_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/url/url.o");
    let cli_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/cli/cli.o");
    let security_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/security/security.o");
    let config_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/config/config.o");
    let cache_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/cache/cache.o");
    let trace_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/trace/trace.o");
    let task_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/task/task.o");
    let schema_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/schema/schema.o");
    let test_o: *u8 = shux_rel_o_path_from_argv0(a0, "std/test/test.o");
    let include_root: *u8 = shux_repo_root_from_argv0(a0);
    // G.7: user .o from CLI (e.g. runtime_atomic_glue.o) into the same table as asm ld.
    shux_invoke_cc_set_user_o_files_from_argv(argc, argv);
    let cc_ret: i32 = shux_invoke_cc(
      &c_paths_raw[0], 1, out_path, 0 as *u8, opt, use_lto,
      io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o,
      net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o,
      log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o,
      json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o,
      context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o,
      task_o, schema_o, test_o, include_root, 0 as *u8);
    shux_invoke_cc_clear_user_o_files();
    if (cc_ret != 0) {
      driver_unlink_failed_output(out_path);
      // BLD001: match cold seed message text without va_list reportf.
      let msg: u8[512] = [];
      let at: i32 = driver_diag_append_cstr(&msg[0], 512, 0, "cc failed, keeping generated C: ");
      at = driver_diag_append_cstr(&msg[0], 512, at, tmp_c);
      diag_report_with_code(0 as *u8, 0, 0, "build error", "BLD001", &msg[0], 0 as *u8);
      return 1;
    }
    // Success: drop tmp .c unless SHUX_KEEP_C is set (dev inspection).
    if (getenv("SHUX_KEEP_C") == 0 as *u8) {
      unlink(tmp_c);
    } else {
      let note: u8[512] = [];
      let atn: i32 = driver_diag_append_cstr(&note[0], 512, 0, "kept generated C: ");
      atn = driver_diag_append_cstr(&note[0], 512, atn, tmp_c);
      diag_report(0 as *u8, 0, 0, "note", &note[0], 0 as *u8);
    }
    return 0;
  }
  return 1;
}

