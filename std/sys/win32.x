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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
//
// See implementation.
// See implementation.

/* See implementation. */
extern function GetStdHandle(nStdHandle: i32): *u8;

/* See implementation. */
extern function WriteFile(hFile: *u8, lpBuffer: *u8, nNumberOfBytesToWrite: u32, lpNumberOfBytesWritten: *u32, lpOverlapped: *u8): i32;

/* See implementation. */
extern function CreateFileA(lpFileName: *u8, dwDesiredAccess: u32, dwShareMode: u32, lpSecurityAttributes: *u8, dwCreationDisposition: u32, dwFlagsAndAttributes: u32, hTemplateFile: *u8): *u8;

/* See implementation. */
extern function ReadFile(hFile: *u8, lpBuffer: *u8, nNumberOfBytesToRead: u32, lpNumberOfBytesRead: *u32, lpOverlapped: *u8): i32;

/* See implementation. */
extern function CloseHandle(hObject: *u8): i32;

/** kernel32 ExitProcess；noreturn。 */
extern function ExitProcess(uExitCode: u32): void;

/* See implementation. */
export const WIN32_INVALID_HANDLE: i64 = -1;

/** GetStdHandle(STD_OUTPUT_HANDLE)。 */
export const WIN32_STD_OUTPUT_HANDLE: i32 = -11;

/** GetStdHandle(STD_ERROR_HANDLE)。 */
export const WIN32_STD_ERROR_HANDLE: i32 = -12;

/** CreateFileA GENERIC_READ。 */
export const WIN32_GENERIC_READ: u32 = 0x80000000;

/** CreateFileA FILE_SHARE_READ。 */
export const WIN32_FILE_SHARE_READ: u32 = 1;

/** CreateFileA OPEN_EXISTING。 */
export const WIN32_OPEN_EXISTING: u32 = 3;

/** CreateFileA FILE_ATTRIBUTE_NORMAL。 */
export const WIN32_FILE_ATTRIBUTE_NORMAL: u32 = 0x80;

/**
 * See implementation.
 */
export function win32_write_available(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function win32_get_std_handle(n: i32): *u8 {
  let h: *u8 = 0;
  unsafe {
    h = GetStdHandle(n);
  }
  let h_i: i64 = h as i64;
  if (h == 0 || h_i == WIN32_INVALID_HANDLE) {
    return 0 as *u8;
  }
  return h;
}

/**
 * See implementation.
 * See implementation.
 */
export function win32_write_file(handle: *u8, buf: *u8, len: i32, written_out: *u32): i32 {
  if (handle == 0 || buf == 0 || len <= 0) {
    return -1;
  }
  let written: u32 = 0;
  let len_u: u32 = len as u32;
  let ok: i32 = 0;
  unsafe {
    ok = WriteFile(handle, buf, len_u, &written, 0 as *u8);
  }
  if (ok == 0) {
    return -1;
  }
  if (written_out != 0) {
    written_out[0] = written;
  }
  return written as i32;
}

/**
 * See implementation.
 */
export function win32_std_handle_id_for_fd(fd: i32): i32 {
  if (fd == 1) {
    return WIN32_STD_OUTPUT_HANDLE;
  }
  if (fd == 2) {
    return WIN32_STD_ERROR_HANDLE;
  }
  return -1;
}

/**
 * See implementation.
 * See implementation.
 */
export function win32_write(fd: i32, buf: *u8, len: i32): i32 {
  if (len <= 0) {
    return 0;
  }
  if (buf == 0) {
    return -1;
  }
  let std_id: i32 = win32_std_handle_id_for_fd(fd);
  if (std_id < 0) {
    return -1;
  }
  let h: *u8 = win32_get_std_handle(std_id);
  let h_i: i64 = h as i64;
  if (h_i <= 0) {
    return -1;
  }
  let written: u32 = 0;
  let r: i32 = win32_write_file(h, buf, len, &written);
  if (r < 0) {
    return -1;
  }
  return r;
}

/** Exported function `win32_write_stdout`.
 * Write path helper `win32_write_stdout`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function win32_write_stdout(buf: *u8, len: i32): i32 {
  return win32_write(1, buf, len);
}

/** Exported function `win32_write_stderr`.
 * Write path helper `win32_write_stderr`.
 * @param buf *u8
 * @param len i32
 * @return i32
 */
export function win32_write_stderr(buf: *u8, len: i32): i32 {
  return win32_write(2, buf, len);
}

/**
 * See implementation.
 * See implementation.
 */
export function win32_read_file_into_path(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  let h: *u8 = 0;
  unsafe {
    h = CreateFileA(path, WIN32_GENERIC_READ, WIN32_FILE_SHARE_READ, 0 as *u8,
      WIN32_OPEN_EXISTING, WIN32_FILE_ATTRIBUTE_NORMAL, 0 as *u8);
  }
  let h_i: i64 = h as i64;
  if (h_i == WIN32_INVALID_HANDLE || h_i <= 0) {
    return -1;
  }
  let total: i32 = 0;
  while (total < cap) {
    let chunk: u32 = (cap - total) as u32;
    let nr: u32 = 0;
    let dst: *u8 = (buf as *u8) + total;
    let rf_ok: i32 = 0;
    unsafe {
      rf_ok = ReadFile(h, dst, chunk, &nr, 0 as *u8);
    }
    if (rf_ok == 0) {
      unsafe {
        CloseHandle(h);
      }
      return -1;
    }
    if (nr == 0) {
      break;
    }
    total = total + (nr as i32);
  }
  unsafe {
    CloseHandle(h);
  }
  return total;
}

/** Exported function `win32_read_available`.
 * Read path helper `win32_read_available`.
 * @return i32
 */
export function win32_read_available(): i32 {
  return 1;
}

/**
 * See implementation.
 */
export function win32_read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  if (win32_read_available() != 1) {
    return -1;
  }
  return win32_read_file_into_path(path, buf, cap);
}

/**
 * See implementation.
 */
export function win32_exit_process(code: i32): void {
  let c: u32 = code as u32;
  unsafe {
    ExitProcess(c);
  }
}
