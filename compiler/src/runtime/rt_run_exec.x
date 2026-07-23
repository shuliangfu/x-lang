// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-297～299/311 / P2 runtime R7 → R2 full.
// .x owns 8 public symbols: want_asm / print_usage / test_status_to_rc /
//   print_target_cpu / exec_scan_out / path_is_non_exe / exec_compiled / run_test.
// Product PREFER_X_O: full .x + FROM_X rest is marker only (business H=0).
// Cap residual (driver_abi): driver_print_usage_write (wave44 pure color orch + lit residual;
//   .x forbids "\n" strings) and driver_exec_compiled_body.
// Discipline: no argv == 0 as **u8 (null-check via *u8); no local u8[N]
//   (use malloc); diag via diag_report_with_code (no va); POSIX wait bit
//   decode without WIF* macros.
// PLATFORM: SHARED — surface short names are the link-name contract (Track L).
// Comment rule: never put star-slash sequences inside block comments.

export extern "C" function strlen(s: *u8): usize;
export extern "C" function strcmp(a: *u8, b: *u8): i32;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
/* wave226 G.7: bash test shell via public pure thin link_abi_system (wave224 → _impl host system);
 * not raw libc system. Cap residual host system stays only link_abi_system_impl. */
export extern "C" function link_abi_system(cmd: *u8): i32;
export extern "C" function driver_get_argv_i(argc: i32, argv: **u8, i: i32, buf: *u8, max: i32): i32;
export extern "C" function runtime_diag_errno_path(file: *u8, kind: *u8, op: *u8, path: *u8): void;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function shu_target_cpu_print(out: *u8, features: u32): void;
export extern "C" function shux_repo_root_from_argv0(argv0: *u8): *u8;
export extern "C" function driver_stdio_stdout(): *u8;
export extern "C" function driver_print_usage_write(): void;
export extern "C" function driver_exec_compiled_body(argc: i32, argv_opaque: *u8): i32;

/** Return 1 if path ends with .o / .O / .s (non-executable object/asm suffix).
 * Requires n == strlen(exe). Byte 46 is '.'; 111='o', 79='O', 115='s'.
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_suffix2_non_exe).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_exec_suffix2_non_exe(exe: *u8, n: usize): i32 {
  if (n < 2 as usize) { return 0; }
  if (exe[(n - 2 as usize)] != 46) { return 0; }
  if (exe[(n - 1 as usize)] == 111) { return 1; }
  if (exe[(n - 1 as usize)] == 79) { return 1; }
  if (exe[(n - 1 as usize)] == 115) { return 1; }
  return 0;
}

/** Return 1 if path ends with .obj (object suffix, non-executable).
 * Requires n == strlen(exe). Bytes: '.' 'o' 'b' 'j'.
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_suffix4_non_exe).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_exec_suffix4_non_exe(exe: *u8, n: usize): i32 {
  if (n < 4 as usize) { return 0; }
  if (exe[(n - 4 as usize)] != 46) { return 0; }
  if (exe[(n - 3 as usize)] != 111) { return 0; }
  if (exe[(n - 2 as usize)] != 98) { return 0; }
  if (exe[(n - 1 as usize)] != 106) { return 0; }
  return 1;
}

/** Return 1 if path looks like a non-executable build artifact (.o/.O/.obj/.s).
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_check_non_exe).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_exec_check_non_exe(exe: *u8, n: usize): i32 {
  if (rt_exec_suffix2_non_exe(exe, n) == 1) { return 1; }
  if (rt_exec_suffix4_non_exe(exe, n) == 1) { return 1; }
  return 0;
}

/** Allocate and return default -o path "a.out" (byte-built; avoid literal -E traps).
 * Caller owns the malloc result. Returns null if malloc fails.
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_a_out).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_exec_a_out(): *u8 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = malloc(8 as usize);
  }
  if (p == 0 as *u8) {
    return 0 as *u8;
  }
  p[0] = 97;
  p[1] = 46;
  p[2] = 111;
  p[3] = 117;
  p[4] = 116;
  p[5] = 0;
  return p;
}

/** POSIX wait: normal exit? ((st & 0x7f) == 0). Returns 1 if exited, else 0.
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_wifexited).
 * PLATFORM: SHARED (decode) / POSIX (wait status layout). */
#[no_mangle]
export function rt_exec_wifexited(st: i32): i32 {
  if ((st & 127) == 0) {
    return 1;
  }
  return 0;
}

/** POSIX wait: exit code ((st >> 8) & 0xff). Valid when wifexited is true.
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_wexitstatus).
 * PLATFORM: SHARED (decode) / POSIX (wait status layout). */
#[no_mangle]
export function rt_exec_wexitstatus(st: i32): i32 {
  return (st >> 8) & 255;
}

/** POSIX wait: killed by signal? ((st & 0x7f) != 0 && != 0x7f) simplified form.
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_wifsignaled).
 * PLATFORM: SHARED (decode) / POSIX (wait status layout). */
#[no_mangle]
export function rt_exec_wifsignaled(st: i32): i32 {
  let t: i32 = st & 127;
  if (t == 0) {
    return 0;
  }
  if (t == 127) {
    return 0;
  }
  return 1;
}

/** Append NUL-terminated src onto dst (NUL-terminated in-place).
 * cap is total buffer capacity including room for trailing NUL.
 * Returns new length of dst (not counting NUL). Null/empty args return 0.
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_append).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_exec_append(dst: *u8, cap: i32, src: *u8): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  let c: u8 = 0;
  if (dst == 0 as *u8) {
    return 0;
  }
  if (cap <= 0) {
    return 0;
  }
  if (src == 0 as *u8) {
    return 0;
  }
  while (n < cap) {
    if (dst[n] == 0) {
      break;
    }
    n = n + 1;
  }
  while (n + 1 < cap) {
    c = src[i];
    if (c == 0) {
      break;
    }
    dst[n] = c;
    n = n + 1;
    i = i + 1;
  }
  if (n < cap) {
    dst[n] = 0;
  } else {
    dst[cap - 1] = 0;
  }
  return n;
}

/** Append a single byte b onto dst (e.g. quote=34). Avoids escape literals.
 * Returns new length of dst. Null or tiny cap returns 0 / clamped.
 * Track-L: #[no_mangle] keeps surface short name (not rt_run_exec_rt_exec_append_byte).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_exec_append_byte(dst: *u8, cap: i32, b: u8): i32 {
  let n: i32 = 0;
  if (dst == 0 as *u8) {
    return 0;
  }
  if (cap <= 1) {
    return 0;
  }
  while (n < cap) {
    if (dst[n] == 0) {
      break;
    }
    n = n + 1;
  }
  if (n + 1 >= cap) {
    dst[cap - 1] = 0;
    return n;
  }
  dst[n] = b;
  n = n + 1;
  dst[n] = 0;
  return n;
}

/** Match driver_run_compiler_full default: prefer asm backend unless
 * argv contains `-backend c`. Returns 1 for asm, 0 for c, 0 on bad argv.
 * Track-L: #[no_mangle] keeps public short name.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function driver_want_asm_emit_to_file(argc: i32, argv: **u8): i32 {
  let want_asm: i32 = 1;
  let i: i32 = 1;
  let cur: *u8 = 0 as *u8;
  let nx: *u8 = 0 as *u8;
  let rc: i32 = 0;
  if ((argv as *u8) == 0 as *u8) {
    return 0;
  }
  if (argc < 2) {
    return 0;
  }
  unsafe {
    cur = malloc(512 as usize);
    nx = malloc(512 as usize);
  }
  if (cur == 0 as *u8) {
    return 0;
  }
  if (nx == 0 as *u8) {
    unsafe {
      free(cur);
    }
    return 0;
  }
  while (i < argc) {
    unsafe {
      rc = driver_get_argv_i(argc, argv, i, cur, 512);
    }
    if (rc < 0) {
      i = i + 1;
    } else {
      unsafe {
        if (strcmp(cur, "-backend" as *u8) == 0) {
          if (i + 1 < argc) {
            rc = driver_get_argv_i(argc, argv, i + 1, nx, 512);
            if (rc >= 0) {
              if (strcmp(nx, "c" as *u8) == 0) {
                want_asm = 0;
              }
              if (strcmp(nx, "asm" as *u8) == 0) {
                want_asm = 1;
              }
            }
            i = i + 1;
          }
        }
      }
      i = i + 1;
    }
  }
  unsafe {
    free(cur);
    free(nx);
  }
  if (want_asm != 0) {
    return 1;
  }
  return 0;
}

/** Print shux usage summary on fd 1. Cap residual owns giant usage literal.
 * Track-L: #[no_mangle] keeps public short name.
 * PLATFORM: SHARED — link-name contract. */
#[no_mangle]
export function driver_print_usage_c(): void {
  unsafe {
    driver_print_usage_write();
  }
}

/** Map wait/system status to process rc; write fixed diags on failure (no va).
 * Returns 0 on clean success, 1 on error / non-zero exit / signal.
 * Track-L: #[no_mangle] keeps public short name.
 * PLATFORM: SHARED entry; POSIX wait decode via rt_exec_wif*. */
#[no_mangle]
export function runtime_test_status_to_rc(script: *u8, st: i32): i32 {
  if (st == 0 - 1) {
    unsafe {
      runtime_diag_errno_path(script, "process error" as *u8, "system(shux test)" as *u8, script);
    }
    return 1;
  }
  if (rt_exec_wifexited(st) != 0) {
    if (rt_exec_wexitstatus(st) != 0) {
      return 1;
    }
    return 0;
  }
  if (rt_exec_wifsignaled(st) != 0) {
    unsafe {
      diag_report_with_code(
        script, 0, 0, "process error" as *u8, "PRC001" as *u8,
        "test script terminated by signal" as *u8, 0 as *u8);
    }
    return 1;
  }
  unsafe {
    diag_report_with_code(
      script, 0, 0, "process error" as *u8, "PRC001" as *u8,
      "test script terminated abnormally" as *u8, 0 as *u8);
  }
  return 1;
}

/** X run_compiler_full_x early exit: print target-cpu features to stdout.
 * Returns 0 always (print path). Track-L: #[no_mangle] keeps public short name.
 * PLATFORM: SHARED — link-name contract. */
#[no_mangle]
export function driver_print_target_cpu_features_c(features: i32): i32 {
  let out: *u8 = 0 as *u8;
  unsafe {
    out = driver_stdio_stdout();
    shu_target_cpu_print(out, features as u32);
  }
  return 0;
}

/** Scan argv for `-o` next arg; default to heap "a.out" when missing.
 * Returned pointer may be argv storage or malloc from rt_exec_a_out.
 * Track-L: #[no_mangle] keeps public short name.
 * PLATFORM: SHARED — link-name contract. */
#[no_mangle]
export function driver_exec_scan_out_path(argc: i32, argv: **u8): *u8 {
  let i: i32 = 1;
  let p: *u8 = 0 as *u8;
  let q: *u8 = 0 as *u8;
  if ((argv as *u8) == 0 as *u8) {
    return rt_exec_a_out();
  }
  if (argc < 1) {
    return rt_exec_a_out();
  }
  while (i < argc - 1) {
    p = argv[i];
    if (p != 0 as *u8) {
      unsafe {
        if (strcmp(p, "-o" as *u8) == 0) {
          q = argv[i + 1];
          if (q != 0 as *u8) {
            if (q[0] != 0) {
              return q;
            }
          }
        }
      }
    }
    i = i + 1;
  }
  return rt_exec_a_out();
}

/** Return 1 if path is a non-executable product suffix (.o/.O/.obj/.s).
 * Null path is treated as non-exe (1). Track-L: #[no_mangle] public short name.
 * PLATFORM: SHARED — link-name contract. */
#[no_mangle]
export function driver_exec_path_is_non_exe(exe: *u8): i32 {
  if (exe == 0 as *u8) {
    return 1;
  }
  unsafe {
    let n: usize = strlen(exe);
    return rt_exec_check_non_exe(exe, n);
  }
  return 0;
}

/** cmd_run: after successful compile, exec the product binary.
 * argv is *u8 opaque (seed ABI). Cap residual: *u8→**u8 cast + fork/exec body
 * (-E forbids let **u8 / cast drops body).
 * Track-L: #[no_mangle] keeps public short name.
 * PLATFORM: SHARED entry; exec body Cap residual in driver_abi. */
#[no_mangle]
export function driver_exec_compiled(argc: i32, argv_opaque: *u8): i32 {
  if (argv_opaque == 0 as *u8) {
    return 1;
  }
  if (argc < 1) {
    return 1;
  }
  unsafe {
    return driver_exec_compiled_body(argc, argv_opaque);
  }
  return 1;
}

/** shux test: run bash test script at repo root.
 * wave226: uses link_abi_system (public pure thin → _impl host system; I/O boundary).
 * Optional argv[1] is relative path (must not start with '-'); default run-all.sh.
 * Track-L: #[no_mangle] keeps public short name.
 * PLATFORM: POSIX system/shell; SHARED surface name. */
#[no_mangle]
export function driver_run_test(argc: i32, argv: **u8): i32 {
  let root: *u8 = 0 as *u8;
  let rel: *u8 = 0 as *u8;
  let script: *u8 = 0 as *u8;
  let cmd: *u8 = 0 as *u8;
  let a0: *u8 = 0 as *u8;
  let st: i32 = 0;
  if ((argv as *u8) != 0 as *u8) {
    if (argc > 0) {
      a0 = argv[0];
    }
  }
  unsafe {
    root = shux_repo_root_from_argv0(a0);
  }
  rel = "tests/run-all.sh" as *u8;
  if (argc >= 2) {
    if ((argv as *u8) != 0 as *u8) {
      if (argv[1] != 0 as *u8) {
        if (argv[1][0] != 45) {
          rel = argv[1];
        }
      }
    }
  }
  unsafe {
    script = malloc(768 as usize);
    cmd = malloc(1024 as usize);
  }
  if (script == 0 as *u8) {
    return 1;
  }
  if (cmd == 0 as *u8) {
    unsafe {
      free(script);
    }
    return 1;
  }
  script[0] = 0;
  cmd[0] = 0;
  if (rel[0] == 47) {
    rt_exec_append(script, 768, rel);
  } else {
    rt_exec_append(script, 768, root);
    rt_exec_append(script, 768, "/" as *u8);
    rt_exec_append(script, 768, rel);
  }
  // Build: cd "ROOT" && bash "SCRIPT" — quote via byte 34 (no \" escape; -E would emit 92,34).
  rt_exec_append(cmd, 1024, "cd " as *u8);
  rt_exec_append_byte(cmd, 1024, 34);
  rt_exec_append(cmd, 1024, root);
  rt_exec_append_byte(cmd, 1024, 34);
  rt_exec_append(cmd, 1024, " && bash " as *u8);
  rt_exec_append_byte(cmd, 1024, 34);
  rt_exec_append(cmd, 1024, script);
  rt_exec_append_byte(cmd, 1024, 34);
  unsafe {
    diag_report_with_code(
      0 as *u8, 0, 0, "info" as *u8, "I000" as *u8,
      "test script" as *u8, script);
    // wave226 G.7: public pure thin link_abi_system (not raw libc system).
    st = link_abi_system(cmd);
  }
  st = runtime_test_status_to_rc(script, st);
  unsafe {
    free(script);
    free(cmd);
  }
  return st;
}
