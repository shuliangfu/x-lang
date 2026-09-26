// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// runtime_process_os_darwin.x — Darwin arm64 OS bridges for
// runtime_process_os_glue.o.
//
// The cold ensure path pure-asms src/asm/runtime_process_os_glue.x
// (the public wrappers) and this file (the _impl bridges), then ld -r.
// It does not pass seeds/runtime_process_os_glue.from_x.c to host cc.
// Linux and Windows keep that C seed, including the Cap svc bodies.
//
// This compiler cannot emit the static-inline svc #0x80 walks in
// xlang_process_cap.h, so Darwin calls libSystem: getpid, getppid,
// getcwd, chdir, fork, execve, waitpid, pipe, dup2, _exit, signal,
// and _NSGetExecutablePath. getenv is link_abi_getenv. setenv and
// unsetenv call env_setenv_c / env_unsetenv_c, the environ authority
// from runtime_env_os. This file does not walk the block itself and
// does not call libc setenv or unsetenv.
//
// A direct store to a file-level let does not emit. Cache pointers
// and lengths are published with memcpy after the address is loaded
// into a local. Passing &let as a call argument makes this compiler
// exit 139. A function name used as a pointer value also exits 139,
// so the SIGCHLD handler is taken with dlsym. A 4096-byte stack
// buffer does not fit, so the cwd and exe caches are malloc'd.
// Each function keeps a single loop. This file has no loop.
//
// This object is a user companion. It is not in the g05 compiler
// image. A missing object after pure-asm faults falls back to the
// C seed.
//
// PLATFORM: MACOS|DARWIN arm64.

/**
 * Byte copy. Publishes file-level slots this compiler cannot store.
 * @param d *u8 — destination
 * @param s *u8 — source
 * @param n i64 — byte count
 * @return *u8 — destination
 * PLATFORM: POSIX
 */
export extern "C" function memcpy(d: *u8, s: *u8, n: i64): *u8;

/**
 * Byte length of a NUL-terminated string.
 * @param s *u8 — string, not null
 * @return i64 — bytes before the NUL
 * PLATFORM: POSIX
 */
export extern "C" function strlen(s: *u8): i64;

/**
 * Heap buffer.
 * @param n i64 — byte count
 * @return *u8 — buffer, or null
 * PLATFORM: POSIX
 */
export extern "C" function malloc(n: i64): *u8;

/**
 * Environ read. Same face as user_env.
 * @param name *u8 — NUL-terminated name
 * @return *u8 — value, or null
 * PLATFORM: SHARED
 */
export extern "C" function link_abi_getenv(name: *u8): *u8;

/**
 * Environ write from runtime_env_os. One authority for setenv.
 * @param name *u8 — NUL-terminated name
 * @param value *u8 — NUL-terminated value
 * @param overwrite i32 — non-zero replaces an existing value
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function env_setenv_c(name: *u8, value: *u8, overwrite: i32): i32;

/**
 * Environ delete from runtime_env_os.
 * @param name *u8 — NUL-terminated name
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function env_unsetenv_c(name: *u8): i32;

/**
 * libSystem getpid.
 * @return i32 — current pid
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function getpid(): i32;

/**
 * libSystem getppid.
 * @return i32 — parent pid
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function getppid(): i32;

/**
 * libSystem getcwd. Writes a NUL-terminated path into buf.
 * @param buf *u8 — destination
 * @param size i64 — capacity, including the NUL
 * @return *u8 — buf on success, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function getcwd(buf: *u8, size: i64): *u8;

/**
 * libSystem chdir.
 * @param path *u8 — NUL-terminated path
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function chdir(path: *u8): i32;

/**
 * Darwin executable path. On success writes a NUL-terminated path.
 * On failure writes the required size into bufsize.
 * @param buf *u8 — destination
 * @param bufsize *u32 — in: capacity, out: required size on failure
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function __NSGetExecutablePath(buf: *u8, bufsize: *u32): i32;

/**
 * libSystem fork. The child receives 0. The parent receives the pid.
 * @return i32 — pid, 0, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function fork(): i32;

/**
 * libSystem execve. Does not return on success.
 * @param path *u8 — program
 * @param argv **u8 — NUL-terminated argument vector
 * @param envp **u8 — NUL-terminated environment vector
 * @return i32 — -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function execve(path: *u8, argv: **u8, envp: **u8): i32;

/**
 * libSystem waitpid.
 * @param pid i32 — child
 * @param status *i32 — wait status out
 * @param options i32 — 0 waits
 * @return i32 — pid on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function waitpid(pid: i32, status: *i32, options: i32): i32;

/**
 * libSystem pipe. Writes two descriptors into fds.
 * @param fds *i32 — two-word destination
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function pipe(fds: *i32): i32;

/**
 * libSystem dup2.
 * @param fd i32 — source
 * @param slot i32 — destination
 * @return i32 — the new descriptor, or -1
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dup2(fd: i32, slot: i32): i32;

/**
 * libSystem _exit. Does not return.
 * @param code i32 — status
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function _exit(code: i32): void;

/**
 * libSystem signal. The handler is a pointer from dlsym.
 * SIG_ERR is the pointer value -1. SIG_DFL is 0. SIG_IGN is 1.
 * @param sig i32 — signal number
 * @param handler *u8 — previous or new handler
 * @return *u8 — previous handler, or SIG_ERR
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function signal(sig: i32, handler: *u8): *u8;

/**
 * libSystem dlsym. RTLD_DEFAULT is the pointer value -2.
 * @param handle *u8 — RTLD_DEFAULT
 * @param name *u8 — symbol, without a leading underscore
 * @return *u8 — address, or null
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function dlsym(handle: *u8, name: *u8): *u8;

/**
 * CRT environ slot.
 * @return ***u8 — address of the environ pointer
 * PLATFORM: MACOS|DARWIN
 */
export extern "C" function __NSGetEnviron(): ***u8;

/**
 * Empty SIGCHLD handler defined by the shared thin.
 * @param sig i32 — signal number
 * PLATFORM: SHARED
 */
export extern "C" function process_nop_sigchld(sig: i32): void;

/**
 * Heap cache of the working directory, 4096 bytes. Null until first fill.
 * Direct assignment does not emit.
 * PLATFORM: MACOS|DARWIN
 */
export let process_cwd_buf: *u8 = 0;

/**
 * Cached cwd length, excluding the NUL. 0 means empty or invalidated.
 * PLATFORM: MACOS|DARWIN
 */
export let process_cwd_len: i32 = 0;

/**
 * Heap cache of the executable path, 4096 bytes. Null until first fill.
 * PLATFORM: MACOS|DARWIN
 */
export let process_exe_buf: *u8 = 0;

/**
 * Cached executable-path length, excluding the NUL.
 * PLATFORM: MACOS|DARWIN
 */
export let process_exe_len: i32 = 0;

/**
 * Copy 4 bytes into an i32 slot.
 * @param slot *i32 — destination; the caller loaded any file-level address
 * @param v i32 — value
 * PLATFORM: MACOS|DARWIN
 */
function process_set_i32(slot: *i32, v: i32): void {
  let tmp: i32 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 4);
  }
}

/**
 * Copy one pointer into a pointer slot.
 * @param slot **u8 — destination
 * @param v *u8 — pointer
 * PLATFORM: MACOS|DARWIN
 */
function process_set_ptr(slot: **u8, v: *u8): void {
  let tmp: *u8 = v;
  unsafe {
    memcpy(slot as *u8, &tmp as *u8, 8);
  }
}

/**
 * Publish the cwd cache pointer.
 * @param p *u8 — 4096-byte buffer
 * PLATFORM: MACOS|DARWIN
 */
function process_cwd_buf_set(p: *u8): void {
  let slot: **u8 = &process_cwd_buf;
  process_set_ptr(slot, p);
}

/**
 * Publish the cwd length.
 * @param n i32 — bytes excluding NUL, or 0
 * PLATFORM: MACOS|DARWIN
 */
function process_cwd_len_set(n: i32): void {
  let slot: *i32 = &process_cwd_len;
  process_set_i32(slot, n);
}

/**
 * Publish the executable-path cache pointer.
 * @param p *u8 — 4096-byte buffer
 * PLATFORM: MACOS|DARWIN
 */
function process_exe_buf_set(p: *u8): void {
  let slot: **u8 = &process_exe_buf;
  process_set_ptr(slot, p);
}

/**
 * Publish the executable-path length.
 * @param n i32 — bytes excluding NUL, or 0
 * PLATFORM: MACOS|DARWIN
 */
function process_exe_len_set(n: i32): void {
  let slot: *i32 = &process_exe_len;
  process_set_i32(slot, n);
}

/**
 * Cwd cache, allocated once.
 * @return *u8 — 4096-byte buffer, or null
 * PLATFORM: MACOS|DARWIN
 */
function process_cwd_ensure(): *u8 {
  let cur: *u8 = process_cwd_buf;
  if (cur != 0) {
    return cur;
  }
  let p: *u8 = 0;
  unsafe {
    p = malloc(4096);
  }
  if (p == 0) {
    return 0;
  }
  process_cwd_buf_set(p);
  return p;
}

/**
 * Executable-path cache, allocated once.
 * @return *u8 — 4096-byte buffer, or null
 * PLATFORM: MACOS|DARWIN
 */
function process_exe_ensure(): *u8 {
  let cur: *u8 = process_exe_buf;
  if (cur != 0) {
    return cur;
  }
  let p: *u8 = 0;
  unsafe {
    p = malloc(4096);
  }
  if (p == 0) {
    return 0;
  }
  process_exe_buf_set(p);
  return p;
}

/**
 * Current environ vector.
 * @return **u8 — environ, or null
 * PLATFORM: MACOS|DARWIN
 */
function process_environ(): **u8 {
  unsafe {
    let slot: ***u8 = __NSGetEnviron();
    if (slot == 0) {
      return 0;
    }
    return slot[0];
  }
}

/**
 * Store one pointer at argv[i]. The base is a parameter.
 * @param argv **u8 — vector
 * @param i i32 — slot
 * @param v *u8 — pointer, or null
 * PLATFORM: MACOS|DARWIN
 */
function process_store_ptr(argv: **u8, i: i32, v: *u8): void {
  argv[i] = v;
}

/**
 * Load a little-endian i32 at a byte offset. The index is a local.
 * @param p *u8 — base
 * @param off i32 — byte offset
 * @return i32 — the word
 * PLATFORM: MACOS|DARWIN
 */
function process_load_i32(p: *u8, off: i32): i32 {
  let j: i32 = off;
  let b0: u32 = p[j] as u32;
  let j1: i32 = j + 1;
  let b1: u32 = p[j1] as u32;
  let j2: i32 = j + 2;
  let b2: u32 = p[j2] as u32;
  let j3: i32 = j + 3;
  let b3: u32 = p[j3] as u32;
  let v: u32 = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
  return v as i32;
}

/**
 * Darwin RTLD_DEFAULT.
 * @return *u8 — pointer value -2
 * PLATFORM: MACOS|DARWIN
 */
function process_rtld_default(): *u8 {
  let n: i64 = 0 - 2;
  return n as *u8;
}

/**
 * Address of the thin SIGCHLD handler. A direct call keeps the symbol
 * referenced. dlsym avoids using the function name as a pointer value.
 * @return *u8 — handler, or null
 * PLATFORM: MACOS|DARWIN
 */
function process_nop_fp(): *u8 {
  unsafe {
    process_nop_sigchld(0);
    let handle: *u8 = process_rtld_default();
    return dlsym(handle, "process_nop_sigchld");
  }
}

/**
 * Install the empty SIGCHLD handler. SIGCHLD is 20. A SIG_ERR result
 * is replaced with SIG_DFL (0) so the caller can restore a real handler.
 * @return *u8 — previous handler
 * PLATFORM: MACOS|DARWIN
 */
function process_sigchld_install(): *u8 {
  let handler: *u8 = process_nop_fp();
  if (handler == 0) {
    let dfl: i64 = 0;
    handler = dfl as *u8;
  }
  let prev: *u8 = 0;
  unsafe {
    prev = signal(20, handler);
  }
  let errn: i64 = 0 - 1;
  let errp: *u8 = errn as *u8;
  if (prev == errp) {
    let dfl2: i64 = 0;
    return dfl2 as *u8;
  }
  return prev;
}

/**
 * Restore the SIGCHLD handler captured before fork.
 * @param prev *u8 — previous handler
 * PLATFORM: MACOS|DARWIN
 */
function process_sigchld_restore(prev: *u8): void {
  unsafe {
    signal(20, prev);
  }
}

/**
 * Read an environment value.
 * @param name *u8 — NUL-terminated name, or null
 * @return *u8 — value, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_getenv_impl(name: *u8): *u8 {
  if (name == 0) {
    return 0;
  }
  unsafe {
    return link_abi_getenv(name);
  }
}

/**
 * Set an environment value through env_setenv_c. A null value becomes
 * an empty string. A null name returns -1.
 * @param name *u8 — name
 * @param value *u8 — value, or null
 * @param overwrite i32 — non-zero replaces
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_setenv_impl(name: *u8, value: *u8, overwrite: i32): i32 {
  if (name == 0) {
    return 0 - 1;
  }
  let v: *u8 = value;
  if (v == 0) {
    v = "";
  }
  unsafe {
    return env_setenv_c(name, v, overwrite);
  }
}

/**
 * Delete an environment name through env_unsetenv_c.
 * @param name *u8 — name, or null
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_unsetenv_impl(name: *u8): i32 {
  if (name == 0) {
    return 0 - 1;
  }
  unsafe {
    return env_unsetenv_c(name);
  }
}

/**
 * Current process id.
 * @return i32 — pid
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_getpid_impl(): i32 {
  unsafe {
    return getpid();
  }
}

/**
 * Parent process id.
 * @return i32 — ppid
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_getppid_impl(): i32 {
  unsafe {
    return getppid();
  }
}

/**
 * Copy the cached cwd into buf. Fills the cache from getcwd on a miss.
 * @param buf *u8 — destination
 * @param buf_size i32 — capacity, including the NUL
 * @return i32 — length excluding NUL, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_getcwd_impl(buf: *u8, buf_size: i32): i32 {
  if (buf == 0 || buf_size <= 0) {
    return 0 - 1;
  }
  let n: i32 = process_cwd_len;
  let cache: *u8 = process_cwd_buf;
  if (n > 0 && cache != 0) {
    if (n >= buf_size) {
      return 0 - 1;
    }
    unsafe {
      memcpy(buf, cache, (n + 1) as i64);
    }
    return n;
  }
  cache = process_cwd_ensure();
  if (cache == 0) {
    return 0 - 1;
  }
  let got: *u8 = 0;
  unsafe {
    got = getcwd(cache, 4096);
  }
  if (got == 0) {
    return 0 - 1;
  }
  let len: i32 = 0;
  unsafe {
    len = strlen(cache) as i32;
  }
  process_cwd_len_set(len);
  if (len >= buf_size) {
    return 0 - 1;
  }
  unsafe {
    memcpy(buf, cache, (len + 1) as i64);
  }
  return len;
}

/**
 * Pointer to the cached cwd. Fills the cache on a miss.
 * @return *u8 — path, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_getcwd_ptr_impl(): *u8 {
  let n: i32 = process_cwd_len;
  let cache: *u8 = process_cwd_buf;
  if (n > 0 && cache != 0) {
    return cache;
  }
  cache = process_cwd_ensure();
  if (cache == 0) {
    return 0;
  }
  let got: *u8 = 0;
  unsafe {
    got = getcwd(cache, 4096);
  }
  if (got == 0) {
    return 0;
  }
  let len: i32 = 0;
  unsafe {
    len = strlen(cache) as i32;
  }
  process_cwd_len_set(len);
  return cache;
}

/**
 * Cached cwd length, excluding the NUL.
 * @return i32 — length, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_getcwd_cached_len_impl(): i32 {
  return process_cwd_len;
}

/**
 * Change the working directory and drop the cwd cache.
 * The cache is cleared even when chdir fails, matching the C seed.
 * @param path *u8 — path, or null
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_chdir_impl(path: *u8): i32 {
  if (path == 0) {
    return 0 - 1;
  }
  process_cwd_len_set(0);
  unsafe {
    return chdir(path);
  }
}

/**
 * Copy the executable path into buf. The first call asks
 * _NSGetExecutablePath and caches 4096 bytes.
 * @param buf *u8 — destination
 * @param buf_size i32 — capacity, including the NUL
 * @return i32 — length excluding NUL, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_self_exe_path_impl(buf: *u8, buf_size: i32): i32 {
  if (buf == 0 || buf_size <= 0) {
    return 0 - 1;
  }
  let n: i32 = process_exe_len;
  let cache: *u8 = process_exe_buf;
  if (n > 0 && cache != 0) {
    if (n >= buf_size) {
      return 0 - 1;
    }
    unsafe {
      memcpy(buf, cache, (n + 1) as i64);
    }
    return n;
  }
  cache = process_exe_ensure();
  if (cache == 0) {
    return 0 - 1;
  }
  let sz: u32 = 4096;
  let rc: i32 = 0;
  unsafe {
    rc = __NSGetExecutablePath(cache, &sz);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let len: i32 = 0;
  unsafe {
    len = strlen(cache) as i32;
  }
  process_exe_len_set(len);
  if (len >= buf_size) {
    return 0 - 1;
  }
  unsafe {
    memcpy(buf, cache, (len + 1) as i64);
  }
  return len;
}

/**
 * Pointer to the cached executable path.
 * @return *u8 — path, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_self_exe_path_ptr_impl(): *u8 {
  let n: i32 = process_exe_len;
  let cache: *u8 = process_exe_buf;
  if (n > 0 && cache != 0) {
    return cache;
  }
  cache = process_exe_ensure();
  if (cache == 0) {
    return 0;
  }
  let sz: u32 = 4096;
  let rc: i32 = 0;
  unsafe {
    rc = __NSGetExecutablePath(cache, &sz);
  }
  if (rc != 0) {
    return 0;
  }
  let len: i32 = 0;
  unsafe {
    len = strlen(cache) as i32;
  }
  process_exe_len_set(len);
  return cache;
}

/**
 * Cached executable-path length, excluding the NUL.
 * @return i32 — length, or 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_self_exe_path_cached_len_impl(): i32 {
  return process_exe_len;
}

/**
 * Empty SIGCHLD body. The thin wrapper is what signal installs.
 * @param sig i32 — unused
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_nop_sigchld_impl(sig: i32): void {
  let unused: i32 = sig;
  if (unused == 0) {
    return;
  }
}

/**
 * Fork and exec. The child exits 127 when execve fails.
 * @param program *u8 — program path
 * @param argv_ptr *u8 — argument vector, as a byte pointer
 * @return i32 — child pid, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_spawn_impl(program: *u8, argv_ptr: *u8): i32 {
  if (program == 0 || argv_ptr == 0) {
    return 0 - 1;
  }
  let argv: **u8 = argv_ptr as **u8;
  let prev: *u8 = process_sigchld_install();
  let pid: i32 = 0;
  unsafe {
    pid = fork();
  }
  if (pid < 0) {
    process_sigchld_restore(prev);
    return 0 - 1;
  }
  if (pid == 0) {
    process_sigchld_restore(prev);
    let envp: **u8 = process_environ();
    unsafe {
      execve(program, argv, envp);
      _exit(127);
    }
  }
  process_sigchld_restore(prev);
  return pid;
}

/**
 * Replace this process. Returns -1 when execve fails.
 * @param program *u8 — program path
 * @param argv_ptr *u8 — argument vector
 * @return i32 — -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_exec_impl(program: *u8, argv_ptr: *u8): i32 {
  if (program == 0 || argv_ptr == 0) {
    return 0 - 1;
  }
  let argv: **u8 = argv_ptr as **u8;
  let envp: **u8 = process_environ();
  unsafe {
    execve(program, argv, envp);
  }
  return 0 - 1;
}

/**
 * Wait for a child. Darwin status: exited when the low 7 bits are 0.
 * The exit code is bits 8..15.
 * @param pid i32 — child, must be > 0
 * @return i32 — exit code, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_waitpid_impl(pid: i32): i32 {
  if (pid <= 0) {
    return 0 - 1;
  }
  let status: i32 = 0;
  let w: i32 = 0;
  unsafe {
    w = waitpid(pid, &status, 0);
  }
  if (w != pid) {
    return 0 - 1;
  }
  let low: i32 = status & 127;
  if (low != 0) {
    return 0 - 1;
  }
  let code: i32 = (status >> 8) & 255;
  return code;
}

/**
 * Build argv = [program, null] on the heap and spawn.
 * @param program *u8 — program path
 * @return i32 — child pid, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_spawn_simple_impl(program: *u8): i32 {
  if (program == 0) {
    return 0 - 1;
  }
  let raw: *u8 = 0;
  unsafe {
    raw = malloc(16);
  }
  if (raw == 0) {
    return 0 - 1;
  }
  let argv: **u8 = raw as **u8;
  process_store_ptr(argv, 0, program);
  process_store_ptr(argv, 1, 0);
  return process_spawn_impl(program, raw);
}

/**
 * Build argv = [program, null] and exec.
 * @param program *u8 — program path
 * @return i32 — -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_exec_simple_impl(program: *u8): i32 {
  if (program == 0) {
    return 0 - 1;
  }
  let raw: *u8 = 0;
  unsafe {
    raw = malloc(16);
  }
  if (raw == 0) {
    return 0 - 1;
  }
  let argv: **u8 = raw as **u8;
  process_store_ptr(argv, 0, program);
  process_store_ptr(argv, 1, 0);
  return process_exec_impl(program, raw);
}

/**
 * dup2 fd onto slot. A negative fd is a no-op success.
 * @param fd i32 — source
 * @param slot i32 — destination
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_dup_stdio_posix_impl(fd: i32, slot: i32): i32 {
  if (fd < 0) {
    return 0;
  }
  let rc: i32 = 0;
  unsafe {
    rc = dup2(fd, slot);
  }
  if (rc < 0) {
    return 0 - 1;
  }
  return 0;
}

/**
 * Apply the three stdio redirects in the child, then exec.
 * io is three little-endian i32 file descriptors at offsets 0, 4, and 8.
 * A null io inherits all three. A negative fd inherits that slot.
 * @param program *u8 — program
 * @param argv **u8 — argument vector
 * @param in_fd i32 — stdin, or -1
 * @param out_fd i32 — stdout, or -1
 * @param err_fd i32 — stderr, or -1
 * PLATFORM: MACOS|DARWIN
 */
function process_spawn_io_child(program: *u8, argv: **u8, in_fd: i32, out_fd: i32, err_fd: i32): void {
  if (in_fd >= 0 && process_dup_stdio_posix_impl(in_fd, 0) != 0) {
    unsafe { _exit(127); }
  }
  if (out_fd >= 0 && process_dup_stdio_posix_impl(out_fd, 1) != 0) {
    unsafe { _exit(127); }
  }
  if (err_fd >= 0 && process_dup_stdio_posix_impl(err_fd, 2) != 0) {
    unsafe { _exit(127); }
  }
  let envp: **u8 = process_environ();
  unsafe {
    execve(program, argv, envp);
    _exit(127);
  }
}

/**
 * Fork, redirect stdio in the child, and exec.
 * @param program *u8 — program
 * @param argv_ptr *u8 — argument vector
 * @param io_void *u8 — three i32 fds, or null
 * @return i32 — child pid, or -1
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_spawn_io_impl(program: *u8, argv_ptr: *u8, io_void: *u8): i32 {
  if (program == 0 || argv_ptr == 0) {
    return 0 - 1;
  }
  let in_fd: i32 = 0 - 1;
  let out_fd: i32 = 0 - 1;
  let err_fd: i32 = 0 - 1;
  if (io_void != 0) {
    in_fd = process_load_i32(io_void, 0);
    out_fd = process_load_i32(io_void, 4);
    err_fd = process_load_i32(io_void, 8);
  }
  let argv: **u8 = argv_ptr as **u8;
  let prev: *u8 = process_sigchld_install();
  let pid: i32 = 0;
  unsafe {
    pid = fork();
  }
  if (pid < 0) {
    process_sigchld_restore(prev);
    return 0 - 1;
  }
  if (pid == 0) {
    process_sigchld_restore(prev);
    process_spawn_io_child(program, argv, in_fd, out_fd, err_fd);
  }
  process_sigchld_restore(prev);
  return pid;
}

/**
 * Create a pipe. The two descriptors are written through the out pointers.
 * @param read_fd *i32 — read end out
 * @param write_fd *i32 — write end out
 * @return i32 — 0 on success, -1 on failure
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function process_pipe_impl(read_fd: *i32, write_fd: *i32): i32 {
  if (read_fd == 0 || write_fd == 0) {
    return 0 - 1;
  }
  let raw: *u8 = 0;
  unsafe {
    raw = malloc(8);
  }
  if (raw == 0) {
    return 0 - 1;
  }
  let rc: i32 = 0;
  unsafe {
    rc = pipe(raw as *i32);
  }
  if (rc != 0) {
    return 0 - 1;
  }
  let r: i32 = process_load_i32(raw, 0);
  let w: i32 = process_load_i32(raw, 4);
  process_set_i32(read_fd, r);
  process_set_i32(write_fd, w);
  return 0;
}
