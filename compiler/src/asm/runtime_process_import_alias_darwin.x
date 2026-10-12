// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_process_import_alias_darwin.x — Darwin arm64 body of the
// std_process_* import face that is ld -r'd into process.o.
//
// Each name forwards to the process_*_c symbol already in that object.
// This file does not reimplement spawn, wait, or the path cache.
// std_process_exit calls libSystem __exit. The .x name uses three
// leading underscores so the Mach-O undefined symbol is ___exit.
// __exit ends the process with the given code and does not run atexit,
// which is the same termination the Cap raw syscall 1 performs.
// libc _exit stays unused. Linux and Windows keep the C seed.
// PLATFORM: MACOS|DARWIN arm64.

extern function ___exit(code: i32): void;
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
 * Hang if ___exit ever returns. Kept in its own function so the exit
 * wrapper has a single call. One loop in this translation unit is the
 * shape this compiler can emit.
 * @return i32 — does not return
 * PLATFORM: MACOS|DARWIN
 */
function proc_alias_spin(): i32 {
  while 1 == 1 {
    let parked: i32 = 0;
  }
  return 0;
}

/**
 * Anchor so the object is identifiable after ld -r.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_process_import_alias_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Terminate this process with code. Does not return when ___exit works.
 * @param code status passed to __exit
 * @return i32 — only if __exit returns, which it does not
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_exit(code: i32): i32 {
  unsafe {
    ___exit(code);
  }
  return proc_alias_spin();
}

/**
 * Forward the argument count.
 * @return i32 — process_args_count_c
 * PLATFORM: MACOS|DARWIN
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
 * PLATFORM: MACOS|DARWIN
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
 * Forward an environment lookup.
 * @param name NUL-terminated key
 * @return *u8 — process_getenv_c
 * PLATFORM: MACOS|DARWIN
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
 * Forward an environment write.
 * @param name NUL-terminated key
 * @param value NUL-terminated value
 * @param overwrite non-zero to replace an existing key
 * @return i32 — process_setenv_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_setenv(name: *u8, value: *u8, overwrite: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_setenv_c(name, value, overwrite);
  }
  return n;
}

/**
 * Forward an environment delete.
 * @param name NUL-terminated key
 * @return i32 — process_unsetenv_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_unsetenv(name: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_unsetenv_c(name);
  }
  return n;
}

/**
 * Forward the process id.
 * @return i32 — process_getpid_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_getpid(): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_getpid_c();
  }
  return n;
}

/**
 * Forward the parent process id.
 * @return i32 — process_getppid_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_getppid(): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_getppid_c();
  }
  return n;
}

/**
 * Forward a getcwd into the caller buffer.
 * @param buf destination
 * @param buf_size capacity in bytes
 * @return i32 — process_getcwd_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_getcwd(buf: *u8, buf_size: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_getcwd_c(buf, buf_size);
  }
  return n;
}

/**
 * Forward the cached cwd pointer.
 * @return *u8 — process_getcwd_ptr_c
 * PLATFORM: MACOS|DARWIN
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
 * Forward the cached cwd length.
 * @return i32 — process_getcwd_cached_len_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_getcwd_cached_len(): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_getcwd_cached_len_c();
  }
  return n;
}

/**
 * Forward a directory change.
 * @param path NUL-terminated path
 * @return i32 — process_chdir_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_chdir(path: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_chdir_c(path);
  }
  return n;
}

/**
 * Forward the executable path copy.
 * @param buf destination
 * @param buf_size capacity in bytes
 * @return i32 — process_self_exe_path_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_self_exe_path(buf: *u8, buf_size: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_self_exe_path_c(buf, buf_size);
  }
  return n;
}

/**
 * Forward the cached executable path pointer.
 * @return *u8 — process_self_exe_path_ptr_c
 * PLATFORM: MACOS|DARWIN
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
 * Forward the cached executable path length.
 * @return i32 — process_self_exe_path_cached_len_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_self_exe_path_cached_len(): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_self_exe_path_cached_len_c();
  }
  return n;
}

/**
 * Forward a spawn.
 * @param program NUL-terminated program
 * @param argv argument vector as the existing C face expects
 * @return i32 — process_spawn_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_spawn(program: *u8, argv: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_spawn_c(program, argv);
  }
  return n;
}

/**
 * Forward a spawn with redirected io.
 * @param program NUL-terminated program
 * @param argv argument vector
 * @param io opaque io block
 * @return i32 — process_spawn_io_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_spawn_io(program: *u8, argv: *u8, io: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_spawn_io_c(program, argv, io);
  }
  return n;
}

/**
 * Forward an exec.
 * @param program NUL-terminated program
 * @param argv argument vector
 * @return i32 — process_exec_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_exec(program: *u8, argv: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_exec_c(program, argv);
  }
  return n;
}

/**
 * Forward a wait.
 * @param pid child id
 * @return i32 — process_waitpid_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_waitpid(pid: i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_waitpid_c(pid);
  }
  return n;
}

/**
 * Forward a one-argument spawn.
 * @param program NUL-terminated program
 * @return i32 — process_spawn_simple_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_spawn_simple(program: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_spawn_simple_c(program);
  }
  return n;
}

/**
 * Forward a one-argument exec.
 * @param program NUL-terminated program
 * @return i32 — process_exec_simple_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_exec_simple(program: *u8): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_exec_simple_c(program);
  }
  return n;
}

/**
 * Forward a pipe allocation.
 * @param read_fd slot for the read end
 * @param write_fd slot for the write end
 * @return i32 — process_pipe_c
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function std_process_pipe(read_fd: *i32, write_fd: *i32): i32 {
  let n: i32 = 0;
  unsafe {
    n = process_pipe_c(read_fd, write_fd);
  }
  return n;
}
