// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_process_import_alias_linux.x — Linux x86_64 body of the
// std_process_* import face that is ld -r'd into process.o.
//
// Each name forwards to the process_*_c symbol already in that object.
// This file does not reimplement spawn, wait, or the path cache.
// std_process_exit uses raw_syscall1(231, code) — Linux exit_group —
// matching Cap residual xlang_proc_exit in xlang_process_cap.h. A miss
// in ensure returns 1 and does not exec cc. Darwin keeps the libSystem
// ___exit face. Windows keeps the C seed.
// PLATFORM: LINUX x86_64.

extern function raw_syscall1(nr: i64, a1: i64): i64;
extern function process_args_count_c(): i32;
extern function process_arg_c(i: i32): *u8;
extern function process_getenv_c(name: *u8): *u8;
extern function process_setenv_c(name: *u8, value: *u8, overwrite: i32): i32;
extern function process_unsetenv_c(name: *u8): i32;
extern function process_getpid_c(): i32;
extern function process_getppid_c(): i32;
extern function process_getcwd_c(buf: *u8, buf_size: i32): i32;
extern function process_getcwd_ptr_c(): *u8;
extern function process_getcwd_cached_len_c(): i32;
extern function process_chdir_c(path: *u8): i32;
extern function process_self_exe_path_c(buf: *u8, buf_size: i32): i32;
extern function process_self_exe_path_ptr_c(): *u8;
extern function process_self_exe_path_cached_len_c(): i32;
extern function process_spawn_c(program: *u8, argv: *u8): i32;
extern function process_spawn_io_c(program: *u8, argv: *u8, io: *u8): i32;
extern function process_exec_c(program: *u8, argv: *u8): i32;
extern function process_waitpid_c(pid: i32): i32;
extern function process_spawn_simple_c(program: *u8): i32;
extern function process_exec_simple_c(program: *u8): i32;
extern function process_pipe_c(read_fd: *i32, write_fd: *i32): i32;

/**
 * Hang if exit_group ever returns. Kept in its own function so the exit
 * wrapper has a single call. One loop in this translation unit is the
 * shape this compiler can emit.
 * @return i32 — does not return
 * PLATFORM: LINUX x86_64
 */
function proc_alias_spin(): i32 {
  while 1 == 1 {
    let parked: i32 = 0;
  }
  return 0;
}

/**
 * Cap residual exit_group via raw_syscall. Syscall number 231 must stay
 * equal to xlang_process_cap.h on x86_64.
 * @param code status passed to exit_group
 * PLATFORM: LINUX x86_64
 */
function proc_alias_exit_group(code: i32): void {
  let nr: i64 = 231;
  let a1: i64 = code as i64;
  unsafe {
    let ignored: i64 = raw_syscall1(nr, a1);
  }
}

/**
 * Anchor so the object is identifiable after ld -r.
 * @return i32 — always 0
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function runtime_process_import_alias_linux_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Terminate this process with code. Does not return when exit_group works.
 * @param code status passed to exit_group
 * @return i32 — only if the syscall returns, which it does not
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_exit(code: i32): i32 {
  unsafe {
    proc_alias_exit_group(code);
  }
  return proc_alias_spin();
}

/**
 * Forward the argument count.
 * @return i32 — process_args_count_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_args_count(): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_args_count_c();
  }
  return n;
}

/**
 * Forward one argument pointer.
 * @param i argument index
 * @return *u8 — process_arg_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_arg(i: i32): *u8 {
  let p: *u8 = 0;
  unsafe {
    p = process_arg_c(i);
  }
  return p;
}

/**
 * Forward getenv.
 * @param name env name
 * @return *u8 — process_getenv_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_getenv(name: *u8): *u8 {
  let p: *u8 = 0;
  unsafe {
    p = process_getenv_c(name);
  }
  return p;
}

/**
 * Forward setenv.
 * @param name env name
 * @param value env value
 * @param overwrite replace flag
 * @return i32 — process_setenv_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_setenv(name: *u8, value: *u8, overwrite: i32): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_setenv_c(name, value, overwrite);
  }
  return r;
}

/**
 * Forward unsetenv.
 * @param name env name
 * @return i32 — process_unsetenv_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_unsetenv(name: *u8): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_unsetenv_c(name);
  }
  return r;
}

/**
 * Forward getpid.
 * @return i32 — process_getpid_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_getpid(): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_getpid_c();
  }
  return r;
}

/**
 * Forward getppid.
 * @return i32 — process_getppid_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_getppid(): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_getppid_c();
  }
  return r;
}

/**
 * Forward getcwd into a buffer.
 * @param buf output buffer
 * @param buf_size capacity
 * @return i32 — process_getcwd_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_getcwd(buf: *u8, buf_size: i32): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_getcwd_c(buf, buf_size);
  }
  return r;
}

/**
 * Forward getcwd cached pointer.
 * @return *u8 — process_getcwd_ptr_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_getcwd_ptr(): *u8 {
  let p: *u8 = 0;
  unsafe {
    p = process_getcwd_ptr_c();
  }
  return p;
}

/**
 * Forward getcwd cached length.
 * @return i32 — process_getcwd_cached_len_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_getcwd_cached_len(): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_getcwd_cached_len_c();
  }
  return r;
}

/**
 * Forward chdir.
 * @param path directory path
 * @return i32 — process_chdir_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_chdir(path: *u8): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_chdir_c(path);
  }
  return r;
}

/**
 * Forward self exe path into a buffer.
 * @param buf output buffer
 * @param buf_size capacity
 * @return i32 — process_self_exe_path_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_self_exe_path(buf: *u8, buf_size: i32): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_self_exe_path_c(buf, buf_size);
  }
  return r;
}

/**
 * Forward self exe cached pointer.
 * @return *u8 — process_self_exe_path_ptr_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_self_exe_path_ptr(): *u8 {
  let p: *u8 = 0;
  unsafe {
    p = process_self_exe_path_ptr_c();
  }
  return p;
}

/**
 * Forward self exe cached length.
 * @return i32 — process_self_exe_path_cached_len_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_self_exe_path_cached_len(): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_self_exe_path_cached_len_c();
  }
  return r;
}

/**
 * Forward spawn.
 * @param program program path
 * @param argv argument vector
 * @return i32 — process_spawn_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_spawn(program: *u8, argv: *u8): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_spawn_c(program, argv);
  }
  return r;
}

/**
 * Forward spawn with IO.
 * @param program program path
 * @param argv argument vector
 * @param io IO bundle
 * @return i32 — process_spawn_io_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_spawn_io(program: *u8, argv: *u8, io: *u8): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_spawn_io_c(program, argv, io);
  }
  return r;
}

/**
 * Forward exec.
 * @param program program path
 * @param argv argument vector
 * @return i32 — process_exec_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_exec(program: *u8, argv: *u8): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_exec_c(program, argv);
  }
  return r;
}

/**
 * Forward waitpid.
 * @param pid child pid
 * @return i32 — process_waitpid_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_waitpid(pid: i32): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_waitpid_c(pid);
  }
  return r;
}

/**
 * Forward spawn_simple.
 * @param program program path
 * @return i32 — process_spawn_simple_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_spawn_simple(program: *u8): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_spawn_simple_c(program);
  }
  return r;
}

/**
 * Forward exec_simple.
 * @param program program path
 * @return i32 — process_exec_simple_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_exec_simple(program: *u8): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_exec_simple_c(program);
  }
  return r;
}

/**
 * Forward pipe.
 * @param read_fd read end out
 * @param write_fd write end out
 * @return i32 — process_pipe_c
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function std_process_pipe(read_fd: *i32, write_fd: *i32): i32 {
  let r: i32 = 0;
  unsafe {
    r = process_pipe_c(read_fd, write_fd);
  }
  return r;
}
