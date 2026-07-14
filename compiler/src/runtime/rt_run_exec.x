// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-297～299/311 / P2 runtime R7 → R2 full。
// .x 吃满 8 公共符号：want_asm / print_usage / test_status_to_rc /
//   print_target_cpu / exec_scan_out / path_is_non_exe / exec_compiled / run_test。
// 产品 PREFER_X_O：full .x + rest 在 FROM_X 下仅 marker（业务 H=0）。
// Cap residual（driver_abi）：driver_print_usage_write（巨型 usage 字面量；.x 禁 \n 字串）。
// 纪律：禁 argv == 0 as **u8（经 *u8 判空）；禁局部 u8[N]（malloc）；
//   diag 用 diag_report_with_code（无 va）；POSIX wait 位解码（无 WIF* 宏）。

export extern "C" function strlen(s: *u8): usize;
export extern "C" function strcmp(a: *u8, b: *u8): i32;
export extern "C" function malloc(n: usize): *u8;
export extern "C" function free(p: *u8): void;
export extern "C" function system(cmd: *u8): i32;
export extern "C" function driver_get_argv_i(argc: i32, argv: **u8, i: i32, buf: *u8, max: i32): i32;
export extern "C" function runtime_diag_errno_path(file: *u8, kind: *u8, op: *u8, path: *u8): void;
export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function shu_target_cpu_print(out: *u8, features: u32): void;
export extern "C" function shux_repo_root_from_argv0(argv0: *u8): *u8;
export extern "C" function driver_stdio_stdout(): *u8;
export extern "C" function driver_print_usage_write(): void;
export extern "C" function driver_exec_compiled_body(argc: i32, argv_opaque: *u8): i32;

// 2-byte suffix check: .o (111) / .O (79) / .s (115) — 46='.'
export function rt_exec_suffix2_non_exe(exe: *u8, n: usize): i32 {
  if (n < 2 as usize) { return 0; }
  if (exe[(n - 2 as usize)] != 46) { return 0; }
  if (exe[(n - 1 as usize)] == 111) { return 1; }
  if (exe[(n - 1 as usize)] == 79) { return 1; }
  if (exe[(n - 1 as usize)] == 115) { return 1; }
  return 0;
}

// 4-byte suffix check: .obj (111,98,106) — 46='.'
export function rt_exec_suffix4_non_exe(exe: *u8, n: usize): i32 {
  if (n < 4 as usize) { return 0; }
  if (exe[(n - 4 as usize)] != 46) { return 0; }
  if (exe[(n - 3 as usize)] != 111) { return 0; }
  if (exe[(n - 2 as usize)] != 98) { return 0; }
  if (exe[(n - 1 as usize)] != 106) { return 0; }
  return 1;
}

export function rt_exec_check_non_exe(exe: *u8, n: usize): i32 {
  if (rt_exec_suffix2_non_exe(exe, n) == 1) { return 1; }
  if (rt_exec_suffix4_non_exe(exe, n) == 1) { return 1; }
  return 0;
}

/** 默认 -o 路径 "a.out"（字节拼，避免 "a.out" 字面量 -E 误解析）。 */
function rt_exec_a_out(): *u8 {
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

/** POSIX wait 状态：正常退出？((st & 0x7f) == 0) */
function rt_exec_wifexited(st: i32): i32 {
  if ((st & 127) == 0) {
    return 1;
  }
  return 0;
}

/** POSIX wait 状态：退出码 ((st >> 8) & 0xff) */
function rt_exec_wexitstatus(st: i32): i32 {
  return (st >> 8) & 255;
}

/** POSIX wait 状态：被信号杀？((st & 0x7f) != 0 && (st & 0x7f) != 0x7f) 简化 */
function rt_exec_wifsignaled(st: i32): i32 {
  let t: i32 = st & 127;
  if (t == 0) {
    return 0;
  }
  if (t == 127) {
    return 0;
  }
  return 1;
}

function rt_exec_append(dst: *u8, cap: i32, src: *u8): i32 {
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

/** 追加单字节（用于 '"'=34 等，禁字面量转义）。 */
function rt_exec_append_byte(dst: *u8, cap: i32, b: u8): i32 {
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

/**
 * 是否与 driver_run_compiler_full 默认一致：默认可走 asm 后端；
 * 仅当 argv 含 `-backend c` 时为 0。
 */
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

/** 打印 shux 用法摘要（fd 1）。Cap residual 持巨型 usage 字面量。 */
#[no_mangle]
export function driver_print_usage_c(): void {
  unsafe {
    driver_print_usage_write();
  }
}

/** wait/system 状态 → 进程 rc；失败路径写诊断（固定 msg，无 va）。 */
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

/** X run_compiler_full_x：`--print-target-cpu` 早退打印 feature。 */
#[no_mangle]
export function driver_print_target_cpu_features_c(features: i32): i32 {
  let out: *u8 = 0 as *u8;
  unsafe {
    out = driver_stdio_stdout();
    shu_target_cpu_print(out, features as u32);
  }
  return 0;
}

/** 从 argv 扫描 `-o` 下一参数；缺省 `"a.out"`。 */
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

/** 路径是否非可执行产物后缀（.o/.O/.obj/.s）。 */
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

/**
 * cmd_run：编译成功后 exec 产物。
 * argv 作 *u8 opaque（与 seed ABI 一致）。
 * Cap residual：*u8→**u8 cast + fork/exec 体（-E 禁 let **u8 / cast 丢体）。
 */
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

/** shux test：在仓库根执行 bash 测试脚本。🔒 system。 */
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
  /* cd "ROOT" && bash "SCRIPT" — 引号用字节 34，禁 \" 转义（-E 编成 92,34） */
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
    st = system(cmd);
  }
  st = runtime_test_status_to_rc(script, st);
  unsafe {
    free(script);
    free(cmd);
  }
  return st;
}
