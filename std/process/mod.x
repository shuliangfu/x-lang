// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// Full text: LICENSE.Apache-2.0

// std.process —
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// setenv）、
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// process.o。
//
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// std/process/process.o。
// See implementation.
// process.c）。
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
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

/* See implementation. */
export struct SpawnIo {
  stdin_fd: i32;
  stdout_fd: i32;
  stderr_fd: i32;
}

extern function process_spawn_c(program: *u8, argv: *u8): i32;
extern function process_spawn_io_c(program: *u8, argv: *u8, io: *SpawnIo): i32;
extern function process_exec_c(program: *u8, argv: *u8): i32;
extern function process_waitpid_c(pid: i32): i32;
extern function process_spawn_simple_c(program: *u8): i32;
extern function process_exec_simple_c(program: *u8): i32;
/** Exported function `exit`.
 * Implements `exit`.
 * @param code i32
 * @return i32
 */
export function exit(code: i32): i32 {
  return 0;
}
/** Exported function `args_count`.
 * Implements `args_count`.
 * @return i32
 */
export function args_count(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_args_count_c(); }
  return _rc;
}
/** Exported function `arg`.
 * Implements `arg`.
 * @param i i32
 * @return *u8
 */
export function arg(i: i32): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = process_arg_c(i); }
  return _rc;
}
/** Exported function `getenv`.
 * Implements `getenv`.
 * @param name *u8
 * @return *u8
 */
export function getenv(name: *u8): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = process_getenv_c(name); }
  return _rc;
}
/** Exported function `setenv`.
 * Implements `setenv`.
 * @param name *u8
 * @param value *u8
 * @param overwrite i32
 * @return i32
 */
export function setenv(name: *u8, value: *u8, overwrite: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_setenv_c(name, value, overwrite); }
  return _rc;
}
/** Exported function `unsetenv`.
 * Implements `unsetenv`.
 * @param name *u8
 * @return i32
 */
export function unsetenv(name: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_unsetenv_c(name); }
  return _rc;
}
/** Exported function `getpid`.
 * Implements `getpid`.
 * @return i32
 */
export function getpid(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_getpid_c(); }
  return _rc;
}
/** Exported function `getppid`.
 * Implements `getppid`.
 * @return i32
 */
export function getppid(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_getppid_c(); }
  return _rc;
}
/** Exported function `getcwd`.
 * Implements `getcwd`.
 * @param buf *u8
 * @param buf_size i32
 * @return i32
 */
export function getcwd(buf: *u8, buf_size: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_getcwd_c(buf, buf_size); }
  return _rc;
}
/** Exported function `getcwd_ptr`.
 * Implements `getcwd_ptr`.
 * @return *u8
 */
export function getcwd_ptr(): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = process_getcwd_ptr_c(); }
  return _rc;
}
/** Exported function `getcwd_cached_len`.
 * Query helper `getcwd_cached_len`.
 * @return i32
 */
export function getcwd_cached_len(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_getcwd_cached_len_c(); }
  return _rc;
}
/** Exported function `chdir`.
 * Implements `chdir`.
 * @param path *u8
 * @return i32
 */
export function chdir(path: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_chdir_c(path); }
  return _rc;
}
/** Exported function `self_exe_path`.
 * Implements `self_exe_path`.
 * @param buf *u8
 * @param buf_size i32
 * @return i32
 */
export function self_exe_path(buf: *u8, buf_size: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_self_exe_path_c(buf, buf_size); }
  return _rc;
}
/** Exported function `self_exe_path_ptr`.
 * Implements `self_exe_path_ptr`.
 * @return *u8
 */
export function self_exe_path_ptr(): *u8 {
  let _rc: *u8 = 0;
  unsafe { _rc = process_self_exe_path_ptr_c(); }
  return _rc;
}
/** Exported function `self_exe_path_cached_len`.
 * Query helper `self_exe_path_cached_len`.
 * @return i32
 */
export function self_exe_path_cached_len(): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_self_exe_path_cached_len_c(); }
  return _rc;
}
/**
* See implementation.
* See implementation.
* See implementation.
* Command::spawn / Go StartProcess / Zig Child.spawn）。
*/
export function spawn(program: *u8, argv: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_spawn_c(program, argv); }
  return _rc;
}

/**
 * See implementation.
 * See implementation.
 */
export function spawn_io(program: *u8, argv: *u8, io: *SpawnIo): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_spawn_io_c(program, argv, io); }
  return _rc;
}
/**
* See implementation.
* -1（POSIX execve / Go syscall.Exec）。
*/
export function exec(program: *u8, argv: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_exec_c(program, argv); }
  return _rc;
}
/** Exported function `waitpid`.
 * Implements `waitpid`.
 * @param pid i32
 * @return i32
 */
export function waitpid(pid: i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_waitpid_c(pid); }
  return _rc;
}
/** Exported function `spawn_simple`.
 * Implements `spawn_simple`.
 * @param program *u8
 * @return i32
 */
export function spawn_simple(program: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_spawn_simple_c(program); }
  return _rc;
}
/** Exported function `exec_simple`.
 * Implements `exec_simple`.
 * @param program *u8
 * @return i32
 */
export function exec_simple(program: *u8): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_exec_simple_c(program); }
  return _rc;
}
extern function process_pipe_c(read_fd: *i32, write_fd: *i32): i32;
/** Exported function `pipe`.
 * Implements `pipe`.
 * @param read_fd *i32
 * @param write_fd *i32
 * @return i32
 */
export function pipe(read_fd: *i32, write_fd: *i32): i32 {
  let _rc: i32 = 0;
  unsafe { _rc = process_pipe_c(read_fd, write_fd); }
  return _rc;
}
