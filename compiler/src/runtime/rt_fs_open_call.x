// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-308/452 / P2 runtime rest: libc open for a path that was copied by
// rt_fs_path_copy_nul. w1135 keeps the 512-byte buffer in this file and the
// copy loop in rt_fs_open.x. One translation unit cannot hold both.
// O_CREAT / O_TRUNC match std/fs/posix.x. The slice marker stays in the C rest.
// PLATFORM: SHARED — cfg selects the flag values. Darwin is 512 and 1024.

export extern "C" function open(path: *u8, flags: i32, mode: i32): i32;
export extern "C" function rt_fs_path_copy_nul(path: *u8, path_len: i32, path_buf: *u8): i32;

export const RT_FS_O_RDONLY: i32 = 0;
export const RT_FS_O_WRONLY: i32 = 1;

#[cfg(target_os = "linux")]
export const RT_FS_O_CREAT: i32 = 64;
#[cfg(target_os = "linux")]
export const RT_FS_O_TRUNC: i32 = 512;

#[cfg(target_os = "macos")]
export const RT_FS_O_CREAT: i32 = 512;
#[cfg(target_os = "macos")]
export const RT_FS_O_TRUNC: i32 = 1024;

/**
 * Open path[0..path_len) read-only via libc open.
 * Params: path — path bytes; path_len — length, must be in (0, 512).
 * Returns: file descriptor, or -1 when the copy fails or open fails.
 * Contracts: stack path_buf[512]; flags O_RDONLY; mode 0.
 * PLATFORM: SHARED — open via libc.
 */
#[no_mangle]
export function driver_fs_open_read_path(path: *u8, path_len: i32): i32 {
  let path_buf: u8[512] = [];
  let fd: i32 = 0 - 1;
  let p: *u8 = &path_buf[0];
  let copied: i32 = 0;
  unsafe {
    copied = rt_fs_path_copy_nul(path, path_len, p);
  }
  if (copied == 0) {
    return 0 - 1;
  }
  unsafe {
    fd = open(p, RT_FS_O_RDONLY, 0);
  }
  return fd;
}

/**
 * Open path[0..path_len) for write, creating and truncating the file.
 * Params: path — path bytes; path_len — length, must be in (0, 512).
 * Returns: file descriptor, or -1 when the copy fails or open fails.
 * Contracts: flags are WRONLY|CREAT|TRUNC; mode is 0644 (420).
 * PLATFORM: SHARED — CREAT and TRUNC come from cfg(target_os).
 */
#[no_mangle]
export function driver_fs_open_write(path: *u8, path_len: i32): i32 {
  let path_buf: u8[512] = [];
  let fd: i32 = 0 - 1;
  let flags: i32 = RT_FS_O_WRONLY | RT_FS_O_CREAT | RT_FS_O_TRUNC;
  let p: *u8 = &path_buf[0];
  let copied: i32 = 0;
  unsafe {
    copied = rt_fs_path_copy_nul(path, path_len, p);
  }
  if (copied == 0) {
    return 0 - 1;
  }
  unsafe {
    fd = open(p, flags, 420);
  }
  return fd;
}
