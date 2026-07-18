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
//
// See implementation.

/* See implementation. */
#[cfg(target_os = "linux")]
const linux_m = import("std.sys.linux");

/* See implementation. */
#[cfg(target_os = "macos")]
const macos_m = import("std.sys.macos");

/* See implementation. */
#[cfg(target_os = "freebsd")]
const freebsd_m = import("std.sys.freebsd");

/**
 * See implementation.
 */
export function mmap_available(): i32 {
  return 1;
}

/**
 * See implementation.
 * See implementation.
 */
#[cfg(target_os = "macos")]
export function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0 as *u8;
  }
  return macos_m.macos_mmap_rw(path, min_size, out_size);
}

#[cfg(target_os = "freebsd")]
/** Exported function `mmap_rw`.
 * Implements `mmap_rw`.
 * @param path *u8
 * @param min_size usize
 * @param out_size *usize
 * @return *u8
 */
export function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0 as *u8;
  }
  return freebsd_m.freebsd_mmap_rw(path, min_size, out_size);
}

#[cfg(target_os = "linux")]
#[cfg(not(freestanding))]
/** Exported function `mmap_rw`.
 * Implements `mmap_rw`.
 * @param path *u8
 * @param min_size usize
 * @param out_size *usize
 * @return *u8
 */
export function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (path == 0 || out_size == 0 || min_size == 0) {
    return 0 as *u8;
  }
  return linux_m.linux_mmap_rw(path, min_size, out_size);
}

/** Exported function `munmap`.
 * Implements `munmap`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
#[cfg(target_os = "macos")]
export function munmap(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return macos_m.macos_munmap(ptr, size);
}

#[cfg(target_os = "freebsd")]
/** Exported function `munmap`.
 * Implements `munmap`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
export function munmap(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return freebsd_m.freebsd_munmap(ptr, size);
}

#[cfg(target_os = "linux")]
#[cfg(not(freestanding))]
/** Exported function `munmap`.
 * Implements `munmap`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
export function munmap(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return linux_m.linux_munmap(ptr, size);
}

/** Exported function `msync`.
 * Implements `msync`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
#[cfg(target_os = "macos")]
export function msync(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return macos_m.macos_msync_sync(ptr, size);
}

#[cfg(target_os = "freebsd")]
/** Exported function `msync`.
 * Implements `msync`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
export function msync(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return freebsd_m.freebsd_msync_sync(ptr, size);
}

#[cfg(target_os = "linux")]
#[cfg(not(freestanding))]
/** Exported function `msync`.
 * Implements `msync`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
export function msync(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return linux_m.linux_msync_sync(ptr, size);
}

/** Exported function `mmap_rw`.
 * Implements `mmap_rw`.
 * @param path *u8
 * @param min_size usize
 * @param out_size *usize
 * @return *u8
 */
#[cfg(target_os = "windows")]
export function mmap_rw(path: *u8, min_size: usize, out_size: *usize): *u8 {
  if (out_size != 0) {
    out_size[0] = 0;
  }
  if (path == 0 || min_size == 0) {
    return 0 as *u8;
  }
  return 0 as *u8;
}

#[cfg(target_os = "windows")]
/** Exported function `munmap`.
 * Implements `munmap`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
export function munmap(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return -1;
}

#[cfg(target_os = "windows")]
/** Exported function `msync`.
 * Implements `msync`.
 * @param ptr *u8
 * @param size usize
 * @return i32
 */
export function msync(ptr: *u8, size: usize): i32 {
  if (ptr == 0 || size == 0) {
    return -1;
  }
  return -1;
}
