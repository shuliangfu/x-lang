// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-308/452 / P2 runtime rest：path 字节 → open 原语。
// R2 full（2026-07-14）：.x 吃满 driver_fs_open_read_path / driver_fs_open_write；
// 产品 PREFER_X_O：thin full .x + rest 在 FROM_X 下仅 marker（业务 H=0）。
// 🔒 open 经 libc；O_CREAT/O_TRUNC 按 target_os cfg（与 std/fs/posix.x 同源数值）。

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

/** path[0..path_len) 拷到 path_buf 并写尾 0；成功 1 / 失败 0。path_len 须 < 512。
 * Track-L：#[no_mangle] 与 surface 短名一致，禁止模块前缀 mangle（rt_fs_open_rt_fs_path_*）。
 * PLATFORM: SHARED — 链接名契约；双端 prove 同验。 */
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

/** path[0..path_len-1] 打开只读；失败 -1。 */
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

/** path[0..path_len-1] 打开写（CREAT|TRUNC 0644）；失败 -1。 */
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
