// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-308/452 / P2 runtime rest: path bytes → open primitives.
// R2 full (2026-07-14): .x owns driver_fs_open_read_path / driver_fs_open_write.
// Product PREFER_X_O: thin full .x + rest under FROM_X is marker-only (business H=0).
// open via libc; O_CREAT/O_TRUNC values by target_os cfg (same numeric sources as std/fs/posix.x).

export extern "C" function open(path: *u8, flags: i32, mode: i32): i32;

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
 * Copy path[0..path_len) into path_buf and write trailing NUL.
 * Params: path — source bytes; path_len — length; path_buf — dest (>=512).
 * Returns: 1 on success, 0 on failure.
 * Contracts: path non-null; path_len in (0, 512); path_buf must hold path_len+1 bytes.
 * Track-L: #[no_mangle] matches surface short name; forbid module-prefix mangle.
 * PLATFORM: SHARED — link-name contract; dual-host prove.
 */
#[no_mangle]
export function rt_fs_path_copy_nul(path: *u8, path_len: i32, path_buf: *u8): i32 {
  let i: i32 = 0;
  if (path == 0 as *u8) {
    return 0;
  }
  if (path_len <= 0) {
    return 0;
  }
  if (path_len >= 512) {
    return 0;
  }
  while (i < path_len) {
    path_buf[i as usize] = path[i as usize];
    i = i + 1;
  }
  path_buf[path_len as usize] = 0;
  return 1;
}

/**
 * Open path[0..path_len) read-only via libc open.
 * Params: path — path bytes; path_len — length (must be < 512 after copy_nul).
 * Returns: file descriptor, or -1 on failure.
 * Contracts: uses stack path_buf[512]; O_RDONLY; mode 0.
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — open via libc.
 */
#[no_mangle]
export function driver_fs_open_read_path(path: *u8, path_len: i32): i32 {
  let path_buf: u8[512] = [];
  let fd: i32 = 0 - 1;
  if (rt_fs_path_copy_nul(path, path_len, &path_buf[0]) == 0) {
    return 0 - 1;
  }
  unsafe {
    fd = open(&path_buf[0], RT_FS_O_RDONLY, 0);
  }
  return fd;
}

/**
 * Open path[0..path_len) for write (CREAT|TRUNC 0644=420) via libc open.
 * Params: path — path bytes; path_len — length (must be < 512 after copy_nul).
 * Returns: file descriptor, or -1 on failure.
 * Contracts: flags = WRONLY|CREAT|TRUNC; mode 0644 (420 decimal).
 * Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — O_CREAT/O_TRUNC values differ by cfg(target_os).
 */
#[no_mangle]
export function driver_fs_open_write(path: *u8, path_len: i32): i32 {
  let path_buf: u8[512] = [];
  let fd: i32 = 0 - 1;
  let flags: i32 = RT_FS_O_WRONLY | RT_FS_O_CREAT | RT_FS_O_TRUNC;
  if (rt_fs_path_copy_nul(path, path_len, &path_buf[0]) == 0) {
    return 0 - 1;
  }
  unsafe {
    fd = open(&path_buf[0], flags, 420);
  }
  return fd;
}
