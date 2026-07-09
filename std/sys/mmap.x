// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// std.sys.mmap — 可写 mmap 原语（BOOT-029 v3 / std.db.kv 底座 / F-02 v1 Linux 去 C）
//
// 【文件职责】
// 在硬盘上开辟连续 MAP_SHARED 映射区，供 LSM append-only 引擎顺序写扇区。
// Linux / macOS：纯 .x FFI（std.sys.linux / std.sys.macos）；Windows 占位。
//
// 【依赖】Linux / macOS hosted `-o exe` 链 libc；freestanding 匿名 mmap 见 std.sys.linux。

/** Linux F-02 v1：libc 文件 mmap（无 mmap.inc.c）。 */
#[cfg(target_os = "linux")]
const linux_m = import("std.sys.linux");

/** macOS B-16 v1：libSystem 文件 mmap。 */
#[cfg(target_os = "macos")]
const macos_m = import("std.sys.macos");

/** FreeBSD B-21 v0：libc 文件 mmap。 */
#[cfg(target_os = "freebsd")]
const freebsd_m = import("std.sys.freebsd");

/**
 * v3 探测：mmap API 是否导出（恒 1）。
 */
function mmap_available(): i32 {
  return 1;
}

/**
 * 可写 mmap；返回映射首地址，*out_size 为字节数；失败 null。
 * 调用方须 munmap(ptr, *out_size) 释放。
 */
#[cfg(target_os = "macos")]
function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0;
  }
  return macos_m.macos_mmap_rw(path, min_size, out_size);
}

#[cfg(target_os = "freebsd")]
function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0;
  }
  return freebsd_m.freebsd_mmap_rw(path, min_size, out_size);
}

#[cfg(target_os = "linux")]
#[cfg(not(freestanding))]
function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0;
  }
  return linux_m.linux_mmap_rw(path, min_size, out_size);
}

/** 解除 mmap。 */
#[cfg(target_os = "macos")]
function munmap(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return macos_m.macos_munmap(ptr, size);
}

#[cfg(target_os = "freebsd")]
function munmap(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return freebsd_m.freebsd_munmap(ptr, size);
}

#[cfg(target_os = "linux")]
#[cfg(not(freestanding))]
function munmap(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return linux_m.linux_munmap(ptr, size);
}

/** 将映射区刷盘。 */
#[cfg(target_os = "macos")]
function msync(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return macos_m.macos_msync_sync(ptr, size);
}

#[cfg(target_os = "freebsd")]
function msync(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return freebsd_m.freebsd_msync_sync(ptr, size);
}

#[cfg(target_os = "linux")]
#[cfg(not(freestanding))]
function msync(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return linux_m.linux_msync_sync(ptr, size);
}

/** Windows：mmap 尚未实现；占位 API 供 std.sys 门面 typeck 通过。 */
#[cfg(target_os = "windows")]
function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (out_size != 0) {
    out_size[0] = 0;
  }
  if (path == 0 || min_size == 0) {
    return 0;
  }
  return 0;
}

#[cfg(target_os = "windows")]
function munmap(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return -1;
}

#[cfg(target_os = "windows")]
function msync(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return -1;
}
