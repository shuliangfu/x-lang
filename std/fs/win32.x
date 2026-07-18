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
// See implementation.

/* See implementation. */
let fs_saved_last_error: i32 = 0;
let fs_saved_last_error_set: i32 = 0;

/* See implementation. */
allow(padding) struct FsStatOut {
  size: i64;
  mode: u32;
  is_dir: i32;
  is_file: i32;
  mtime_sec: i64;
}

allow(padding) struct FsIovecBuf { ptr: *u8; len: usize; handle: usize; }

/* See implementation. */
allow(padding) struct Win32FindDataA {
  dwFileAttributes: u32;
  pad0: u8[40];
  cFileName: u8[260];
}

allow(padding) struct FsDirHandleWin {
  find: *u8;
  fd: Win32FindDataA;
  has_next: i32;
  first: i32;
}

allow(padding) struct LargeInteger { quad: i64; }

/* See implementation. */
allow(padding) struct Win32FileAttrData {
  dwFileAttributes: u32;
  ftCreation: u8[8];
  ftLastAccess: u8[8];
  ftLastWrite: u8[8];
  nFileSizeHigh: u32;
  nFileSizeLow: u32;
}

extern "C" function CreateFileA(lpFileName: *u8, dwDesiredAccess: u32, dwShareMode: u32, lpSecurityAttributes: *u8, dwCreationDisposition: u32, dwFlagsAndAttributes: u32, hTemplateFile: *u8): *u8;
extern "C" function CreateFileMappingA(hFile: *u8, lpAttributes: *u8, flProtect: u32, dwMaximumSizeHigh: u32, dwMaximumSizeLow: u32, lpName: *u8): *u8;
extern "C" function MapViewOfFile(hFileMappingObject: *u8, dwDesiredAccess: u32, dwFileOffsetHigh: u32, dwFileOffsetLow: u32, dwNumberOfBytesToMap: u32): *u8;
extern "C" function UnmapViewOfFile(lpBaseAddress: *u8): i32;
extern "C" function ReadFile(hFile: *u8, lpBuffer: *u8, nNumberOfBytesToRead: u32, lpNumberOfBytesRead: *u32, lpOverlapped: *u8): i32;
extern "C" function WriteFile(hFile: *u8, lpBuffer: *u8, nNumberOfBytesToWrite: u32, lpNumberOfBytesWritten: *u32, lpOverlapped: *u8): i32;
extern "C" function CloseHandle(hObject: *u8): i32;
extern "C" function GetFileSizeEx(hFile: *u8, lpFileSize: *LargeInteger): i32;
extern "C" function GetSystemInfo(lpSystemInfo: *u8): void;
extern "C" function FlushFileBuffers(hFile: *u8): i32;
extern "C" function SetFilePointerEx(hFile: *u8, liDistanceToMove: LargeInteger, lpNewFilePointer: *LargeInteger, dwMoveMethod: u32): i32;
extern "C" function SetEndOfFile(hFile: *u8): i32;
extern "C" function GetFileAttributesExA(lpFileName: *u8, fInfoLevelId: i32, lpFileInformation: *Win32FileAttrData): i32;
extern "C" function FindFirstFileA(lpFileName: *u8, lpFindFileData: *Win32FindDataA): *u8;
extern "C" function FindNextFileA(hFindFile: *u8, lpFindFileData: *Win32FindDataA): i32;
extern "C" function FindClose(hFindFile: *u8): i32;
extern "C" function GetLastError(): u32;
extern "C" function _open_osfhandle(osfhandle: i64, flags: i32): i32;
extern "C" function _get_osfhandle(fd: i32): i64;
extern "C" function _read(fd: i32, buf: *u8, count: u32): i32;
extern "C" function _write(fd: i32, buf: *u8, count: u32): i32;
extern "C" function _close(fd: i32): i32;
extern "C" function _lseek(fd: i32, offset: i32, origin: i32): i32;
extern "C" function _chmod(path: *u8, mode: i32): i32;
extern "C" function _mkdir(path: *u8): i32;
extern "C" function _rmdir(path: *u8): i32;
extern "C" function DeleteFileA(lpFileName: *u8): i32;
extern "C" function malloc(size: usize): *u8;
extern "C" function free(ptr: *u8): void;
extern "C" function memcpy(dst: *u8, src: *u8, n: usize): *u8;
extern "C" function strlen(s: *u8): usize;
extern "C" function TransmitFile(hSocket: *u8, hFile: *u8, nNumberOfBytesToWrite: u32, nNumberOfBytesPerSend: u32, lpOverlapped: *u8, lpTransmitBuffers: *u8, dwReserved: u32): i32;

export const WIN32_INVALID_HANDLE: i64 = -1;
export const GENERIC_READ: u32 = 0x80000000;
export const GENERIC_WRITE: u32 = 0x40000000;
export const FILE_SHARE_READ: u32 = 1;
export const OPEN_EXISTING: u32 = 3;
export const OPEN_ALWAYS: u32 = 4;
export const CREATE_ALWAYS: u32 = 2;
export const FILE_ATTRIBUTE_NORMAL: u32 = 0x80;
export const FILE_FLAG_NO_BUFFERING: u32 = 0x20000000;
export const FILE_APPEND_DATA: u32 = 4;
export const PAGE_READONLY: u32 = 2;
export const PAGE_READWRITE: u32 = 4;
export const FILE_MAP_READ: u32 = 4;
export const FILE_MAP_WRITE: u32 = 2;
export const FILE_BEGIN: u32 = 0;
export const FILE_CURRENT: u32 = 1;
export const GetFileExInfoStandard: i32 = 0;
export const FILE_ATTRIBUTE_DIRECTORY: u32 = 16;
export const TF_USE_DEFAULT_WORKER: u32 = 0;
export const _O_RDONLY: i32 = 0;
export const _O_WRONLY: i32 = 1;
export const _O_APPEND: i32 = 8;
export const ERROR_INVALID_PARAMETER: u32 = 87;
export const FS_IOV_BUF_MAX: i32 = 16;

/**
 * See implementation.
 */
export function fs_note_last_error_win(): void {
  unsafe { fs_saved_last_error = GetLastError() as i32; }
  fs_saved_last_error_set = 1;
}

/** CRT fd → HANDLE。 */
export function fs_win32_handle_from_fd(fd: i32): *u8 {
  let h: i64 = 0;
  unsafe { h = _get_osfhandle(fd); }
  if (h == WIN32_INVALID_HANDLE || h <= 0) {
    return 0 as *u8;
  }
  return h as *u8;
}

/** Exported function `fs_mmap_ro_c`.
 * Implements `fs_mmap_ro_c`.
 * @param path *u8
 * @param out_size *usize
 * @return *u8
 */
export function fs_mmap_ro_c(path: *u8, out_size: *usize): *u8 {
  let hFile: *u8;
  let hMap: *u8;
  let li: LargeInteger;
  let view: *u8;
  if (path == 0 || out_size == 0) {
    return 0 as *u8;
  }
  out_size[0] = 0;
  unsafe { hFile = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ, 0 as *u8, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 as *u8); }
  if ((hFile as i64) == WIN32_INVALID_HANDLE) {
    return 0 as *u8;
  }
  unsafe { if (GetFileSizeEx(hFile, &li) == 0 || li.quad <= 0) {
    CloseHandle(hFile);
    return 0 as *u8;
  } }
  unsafe { hMap = CreateFileMappingA(hFile, 0 as *u8, PAGE_READONLY, 0, 0, 0 as *u8); }
  unsafe { CloseHandle(hFile); }
  if (hMap == 0) {
    return 0 as *u8;
  }
  unsafe { view = MapViewOfFile(hMap, FILE_MAP_READ, 0, 0, 0); }
  unsafe { CloseHandle(hMap); }
  if (view == 0) {
    return 0 as *u8;
  }
  out_size[0] = li.quad as usize;
  return view;
}

/** Exported function `fs_mmap_rw_c`.
 * Implements `fs_mmap_rw_c`.
 * @param path *u8
 * @param out_size *usize
 * @return *u8
 */
export function fs_mmap_rw_c(path: *u8, out_size: *usize): *u8 {
  let hFile: *u8;
  let hMap: *u8;
  let li: LargeInteger;
  let view: *u8;
  if (path == 0 || out_size == 0) {
    return 0 as *u8;
  }
  out_size[0] = 0;
  unsafe { hFile = CreateFileA(path, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, 0 as *u8, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 as *u8); }
  if ((hFile as i64) == WIN32_INVALID_HANDLE) {
    return 0 as *u8;
  }
  unsafe { if (GetFileSizeEx(hFile, &li) == 0 || li.quad <= 0) {
    CloseHandle(hFile);
    return 0 as *u8;
  } }
  unsafe { hMap = CreateFileMappingA(hFile, 0 as *u8, PAGE_READWRITE, 0, 0, 0 as *u8); }
  unsafe { CloseHandle(hFile); }
  if (hMap == 0) {
    return 0 as *u8;
  }
  unsafe { view = MapViewOfFile(hMap, FILE_MAP_WRITE, 0, 0, 0); }
  unsafe { CloseHandle(hMap); }
  if (view == 0) {
    return 0 as *u8;
  }
  out_size[0] = li.quad as usize;
  return view;
}

/** UnmapViewOfFile。 */
export function fs_munmap_c(ptr: *u8, size: usize): i32 {
  if (size == 0) {
    return 0;
  }
  unsafe { if (ptr != 0 && UnmapViewOfFile(ptr) != 0) {
    return 0;
  } }
  return -1;
}

/** Exported function `fs_open_read_c`.
 * Read path helper `fs_open_read_c`.
 * @param path *u8
 * @return i32
 */
export function fs_open_read_c(path: *u8): i32 {
  let h: *u8;
  let fd: i32;
  if (path == 0) {
    fs_saved_last_error = ERROR_INVALID_PARAMETER as i32;
    fs_saved_last_error_set = 1;
    return -1;
  }
  unsafe { h = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ, 0 as *u8, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 as *u8); }
  if ((h as i64) == WIN32_INVALID_HANDLE) {
    fs_note_last_error_win();
    return -1;
  }
  unsafe { fd = _open_osfhandle(h as i64, _O_RDONLY); }
  if (fd < 0) {
    fs_note_last_error_win();
    unsafe { CloseHandle(h); }
    return -1;
  }
  return fd;
}

/** Exported function `fs_open_write_c`.
 * Write path helper `fs_open_write_c`.
 * @param path *u8
 * @return i32
 */
export function fs_open_write_c(path: *u8): i32 {
  let h: *u8;
  let fd: i32;
  if (path == 0) {
    return -1;
  }
  unsafe { h = CreateFileA(path, GENERIC_WRITE, FILE_SHARE_READ, 0 as *u8, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 as *u8); }
  if ((h as i64) == WIN32_INVALID_HANDLE) {
    return -1;
  }
  unsafe { fd = _open_osfhandle(h as i64, _O_WRONLY); }
  if (fd < 0) {
    unsafe { CloseHandle(h); }
    return -1;
  }
  return fd;
}

/** Exported function `fs_open_read_direct_c`.
 * Read path helper `fs_open_read_direct_c`.
 * @param path *u8
 * @return i32
 */
export function fs_open_read_direct_c(path: *u8): i32 {
  let h: *u8;
  let fd: i32;
  if (path == 0) {
    return -1;
  }
  unsafe { h = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ, 0 as *u8, OPEN_EXISTING, FILE_FLAG_NO_BUFFERING, 0 as *u8); }
  if ((h as i64) == WIN32_INVALID_HANDLE) {
    return -1;
  }
  unsafe { fd = _open_osfhandle(h as i64, _O_RDONLY); }
  if (fd < 0) {
    unsafe { CloseHandle(h); }
    return -1;
  }
  return fd;
}

/** Exported function `fs_direct_align_c`.
 * Implements `fs_direct_align_c`.
 * @return u64
 */
export function fs_direct_align_c(): u64 {
  let si: u8[48];
  unsafe { GetSystemInfo(&si[0]); }
  let page: u32 = (si[4] as u32) | ((si[5] as u32) << 8) | ((si[6] as u32) << 16) | ((si[7] as u32) << 24);
  return page as u64;
}

/** Exported function `fs_fadvise_sequential_c`.
 * Implements `fs_fadvise_sequential_c`.
 * @param fd i32
 * @return i32
 */
export function fs_fadvise_sequential_c(fd: i32): i32 { return 0; }
/** Exported function `fs_fadvise_willneed_c`.
 * Implements `fs_fadvise_willneed_c`.
 * @param fd i32
 * @param offset i64
 * @param len usize
 * @return i32
 */
export function fs_fadvise_willneed_c(fd: i32, offset: i64, len: usize): i32 { return 0; }

/** Exported function `fs_copy_file_range_c`.
 * Implements `fs_copy_file_range_c`.
 * @param fd_in i32
 * @param fd_out i32
 * @param len usize
 * @return i64
 */
export function fs_copy_file_range_c(fd_in: i32, fd_out: i32, len: usize): i64 {
  let hIn: *u8 = fs_win32_handle_from_fd(fd_in);
  let hOut: *u8 = fs_win32_handle_from_fd(fd_out);
  let buf: *u8;
  let copied: usize = 0;
  let nr: u32 = 0;
  let nw: u32 = 0;
  let chunk: u32;
  if (hIn == 0 || hOut == 0) {
    return -1;
  }
  unsafe { buf = malloc(262144); }
  if (buf == 0) {
    return -1;
  }
  while (copied < len) {
    chunk = (len - copied) as u32;
    if (chunk > 262144) {
      chunk = 262144;
    }
    unsafe { if (ReadFile(hIn, buf, chunk, &nr, 0 as *u8) == 0 || nr == 0) {
      break;
    } }
    unsafe { if (WriteFile(hOut, buf, nr, &nw, 0 as *u8) == 0 || nw != nr) {
      copied = 0xffffffffffffffff;
      break;
    } }
    copied = copied + (nr);
    if (nr < chunk) {
      break;
    }
  }
  unsafe { free(buf); }
  if (copied as i64 == -1) {
    return -1;
  }
  return copied as i64;
}

/** Exported function `fs_readv2_c`.
 * Read path helper `fs_readv2_c`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @return i64
 */
export function fs_readv2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 {
  let h: *u8 = fs_win32_handle_from_fd(fd);
  let n0: u32 = 0;
  let n1: u32 = 0;
  let c0: u32 = l0 as u32;
  let c1: u32 = l1 as u32;
  if (l0 > 0x7fffffff) { c0 = 0x7fffffff; }
  if (l1 > 0x7fffffff) { c1 = 0x7fffffff; }
  if (h == 0) {
    return -1;
  }
  unsafe { if (ReadFile(h, p0, c0, &n0, 0 as *u8) == 0) {
    return -1;
  } }
  unsafe { if (ReadFile(h, p1, c1, &n1, 0 as *u8) == 0) {
    return -1;
  } }
  return (n0 as i64) + (n1 as i64);
}

/** Exported function `fs_writev2_c`.
 * Write path helper `fs_writev2_c`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @return i64
 */
export function fs_writev2_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize): i64 {
  let h: *u8 = fs_win32_handle_from_fd(fd);
  let n0: u32 = 0;
  let n1: u32 = 0;
  let c0: u32 = l0 as u32;
  let c1: u32 = l1 as u32;
  if (l0 > 0x7fffffff) { c0 = 0x7fffffff; }
  if (l1 > 0x7fffffff) { c1 = 0x7fffffff; }
  if (h == 0) {
    return -1;
  }
  unsafe { if (WriteFile(h, p0, c0, &n0, 0 as *u8) == 0) {
    return -1;
  } }
  unsafe { if (WriteFile(h, p1, c1, &n1, 0 as *u8) == 0) {
    return -1;
  } }
  return (n0 as i64) + (n1 as i64);
}

/** Exported function `fs_sendfile_c`.
 * Implements `fs_sendfile_c`.
 * @param out_fd i32
 * @param in_fd i32
 * @param count usize
 * @return i64
 */
export function fs_sendfile_c(out_fd: i32, in_fd: i32, count: usize): i64 {
  let hFile: *u8 = fs_win32_handle_from_fd(in_fd);
  let s: *u8 = fs_win32_handle_from_fd(out_fd);
  let c: u32 = count as u32;
  if (count > 0x7fffffff) {
    c = 0x7fffffff;
  }
  if (hFile == 0) {
    return -1;
  }
  unsafe { if (TransmitFile(s, hFile, c, 0, 0 as *u8, 0 as *u8, TF_USE_DEFAULT_WORKER) != 0) {
    return count as i64;
  } }
  return -1;
}

/** Exported function `fs_pipe_splice_c`.
 * Implements `fs_pipe_splice_c`.
 * @param fd_in i32
 * @param fd_out i32
 * @param len usize
 * @return i64
 */
export function fs_pipe_splice_c(fd_in: i32, fd_out: i32, len: usize): i64 {
  return fs_copy_file_range_c(fd_in, fd_out, len);
}

/** Exported function `fs_sync_range_c`.
 * Implements `fs_sync_range_c`.
 * @param fd i32
 * @param offset i64
 * @param len usize
 * @return i32
 */
export function fs_sync_range_c(fd: i32, offset: i64, len: usize): i32 { return 0; }

/** Exported function `fs_fallocate_c`.
 * Memory management helper `fs_fallocate_c`.
 * @param fd i32
 * @param offset i64
 * @param len i64
 * @return i32
 */
export function fs_fallocate_c(fd: i32, offset: i64, len: i64): i32 {
  let h: *u8;
  let cur: LargeInteger;
  let need: LargeInteger;
  let oldPos: LargeInteger;
  let zero: LargeInteger;
  if (len <= 0) {
    return 0;
  }
  h = fs_win32_handle_from_fd(fd);
  if (h == 0) {
    return -1;
  }
  unsafe { if (GetFileSizeEx(h, &cur) == 0) {
    return -1;
  } }
  need.quad = offset + len;
  if (need.quad <= cur.quad) {
    return 0;
  }
  zero.quad = 0;
  unsafe { if (SetFilePointerEx(h, zero, &oldPos, FILE_CURRENT) == 0) {
    return -1;
  } }
  unsafe { if (SetFilePointerEx(h, need, 0 as *LargeInteger, FILE_BEGIN) == 0) {
    return -1;
  } }
  unsafe { if (SetEndOfFile(h) == 0) {
    SetFilePointerEx(h, oldPos, 0 as *LargeInteger, FILE_BEGIN);
    return -1;
  } }
  unsafe { SetFilePointerEx(h, oldPos, 0 as *LargeInteger, FILE_BEGIN); }
  return 0;
}

/** Exported function `fs_open_append_c`.
 * Implements `fs_open_append_c`.
 * @param path *u8
 * @return i32
 */
export function fs_open_append_c(path: *u8): i32 {
  let h: *u8;
  let fd: i32;
  if (path == 0) {
    return -1;
  }
  unsafe { h = CreateFileA(path, FILE_APPEND_DATA, FILE_SHARE_READ, 0 as *u8, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 as *u8); }
  if ((h as i64) == WIN32_INVALID_HANDLE) {
    return -1;
  }
  unsafe { fd = _open_osfhandle(h as i64, _O_WRONLY | _O_APPEND); }
  if (fd < 0) {
    unsafe { CloseHandle(h); }
    return -1;
  }
  return fd;
}

/** Exported function `fs_open_create_c`.
 * Implements `fs_open_create_c`.
 * @param path *u8
 * @return i32
 */
export function fs_open_create_c(path: *u8): i32 {
  let h: *u8;
  let fd: i32;
  if (path == 0) {
    return -1;
  }
  unsafe { h = CreateFileA(path, GENERIC_WRITE, FILE_SHARE_READ, 0 as *u8, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0 as *u8); }
  if ((h as i64) == WIN32_INVALID_HANDLE) {
    return -1;
  }
  unsafe { fd = _open_osfhandle(h as i64, _O_WRONLY); }
  if (fd < 0) {
    unsafe { CloseHandle(h); }
    return -1;
  }
  return fd;
}

/** Exported function `fs_last_error_c`.
 * Implements `fs_last_error_c`.
 * @return i32
 */
export function fs_last_error_c(): i32 {
  if (fs_saved_last_error_set != 0) {
    return fs_saved_last_error;
  }
  unsafe { return GetLastError() as i32; }
  return 0; // unreachable — typeck workaround
}

/** Exported function `fs_posix_read_c`.
 * Read path helper `fs_posix_read_c`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @return i64
 */
export function fs_posix_read_c(fd: i32, buf: *u8, count: usize): i64 {
  let c: u32 = count as u32;
  if (count > 0x7fffffff) {
    c = 0x7fffffff;
  }
  unsafe { return _read(fd, buf, c) as i64; }
  return 0; // unreachable — typeck workaround
}

/** Exported function `fs_posix_write_c`.
 * Write path helper `fs_posix_write_c`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @return i64
 */
export function fs_posix_write_c(fd: i32, buf: *u8, count: usize): i64 {
  let c: u32 = count as u32;
  if (count > 0x7fffffff) {
    c = 0x7fffffff;
  }
  unsafe { return _write(fd, buf, c) as i64; }
  return 0; // unreachable — typeck workaround
}

/** Exported function `fs_posix_close_c`.
 * Implements `fs_posix_close_c`.
 * @param fd i32
 * @return i32
 */
export function fs_posix_close_c(fd: i32): i32 {
  unsafe { return _close(fd); }
  return 0; // unreachable — typeck workaround
}

/** Exported function `fs_posix_pread_c`.
 * Read path helper `fs_posix_pread_c`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @param offset i64
 * @return i64
 */
export function fs_posix_pread_c(fd: i32, buf: *u8, count: usize, offset: i64): i64 {
  unsafe { if (_lseek(fd, offset as i32, 0) < 0) {
    return -1;
  } }
  return fs_posix_read_c(fd, buf, count);
}

/** Exported function `fs_posix_pwrite_c`.
 * Write path helper `fs_posix_pwrite_c`.
 * @param fd i32
 * @param buf *u8
 * @param count usize
 * @param offset i64
 * @return i64
 */
export function fs_posix_pwrite_c(fd: i32, buf: *u8, count: usize, offset: i64): i64 {
  unsafe { if (_lseek(fd, offset as i32, 0) < 0) {
    return -1;
  } }
  return fs_posix_write_c(fd, buf, count);
}

/** Exported function `fs_readv4_c`.
 * Read path helper `fs_readv4_c`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @return i64
 */
export function fs_readv4_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize): i64 {
  let h: *u8 = fs_win32_handle_from_fd(fd);
  let n0: u32 = 0;
  let n1: u32 = 0;
  let n2: u32 = 0;
  let n3: u32 = 0;
  if (h == 0) {
    return -1;
  }
  unsafe { if (ReadFile(h, p0, l0 as u32, &n0, 0 as *u8) == 0) { return -1; } }
  unsafe { if (ReadFile(h, p1, l1 as u32, &n1, 0 as *u8) == 0) { return -1; } }
  unsafe { if (ReadFile(h, p2, l2 as u32, &n2, 0 as *u8) == 0) { return -1; } }
  unsafe { if (ReadFile(h, p3, l3 as u32, &n3, 0 as *u8) == 0) { return -1; } }
  return (n0 as i64) + (n1 as i64) + (n2 as i64) + (n3 as i64);
}

/** Exported function `fs_writev4_c`.
 * Write path helper `fs_writev4_c`.
 * @param fd i32
 * @param p0 *u8
 * @param l0 usize
 * @param p1 *u8
 * @param l1 usize
 * @param p2 *u8
 * @param l2 usize
 * @param p3 *u8
 * @param l3 usize
 * @return i64
 */
export function fs_writev4_c(fd: i32, p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize, p3: *u8, l3: usize): i64 {
  let h: *u8 = fs_win32_handle_from_fd(fd);
  let n0: u32 = 0;
  let n1: u32 = 0;
  let n2: u32 = 0;
  let n3: u32 = 0;
  if (h == 0) {
    return -1;
  }
  unsafe { if (WriteFile(h, p0, l0 as u32, &n0, 0 as *u8) == 0) { return -1; } }
  unsafe { if (WriteFile(h, p1, l1 as u32, &n1, 0 as *u8) == 0) { return -1; } }
  unsafe { if (WriteFile(h, p2, l2 as u32, &n2, 0 as *u8) == 0) { return -1; } }
  unsafe { if (WriteFile(h, p3, l3 as u32, &n3, 0 as *u8) == 0) { return -1; } }
  return (n0 as i64) + (n1 as i64) + (n2 as i64) + (n3 as i64);
}

/** Exported function `fs_readv_buf_c`.
 * Read path helper `fs_readv_buf_c`.
 * @param fd i32
 * @param bufs *u8
 * @param n i32
 * @return i64
 */
export function fs_readv_buf_c(fd: i32, bufs: *u8, n: i32): i64 {
  let b: *FsIovecBuf = bufs as *FsIovecBuf;
  let h: *u8;
  let total: i64 = 0;
  let i: i32 = 0;
  let got: u32 = 0;
  let len: u32;
  if (n <= 0 || n > FS_IOV_BUF_MAX || bufs == 0) {
    return -1;
  }
  h = fs_win32_handle_from_fd(fd);
  if (h == 0) {
    return -1;
  }
  while (i < n) {
    len = b[i].len as u32;
    if (b[i].len > 0x7fffffff) {
      len = 0x7fffffff;
    }
    unsafe { if (ReadFile(h, b[i].ptr, len, &got, 0 as *u8) == 0) {
      return -1;
    } }
    total = total + (got as i64);
    if ((got) < b[i].len) {
      return total;
    }
    i = i + 1;
  }
  return total;
}

/** Exported function `fs_writev_buf_c`.
 * Write path helper `fs_writev_buf_c`.
 * @param fd i32
 * @param bufs *u8
 * @param n i32
 * @return i64
 */
export function fs_writev_buf_c(fd: i32, bufs: *u8, n: i32): i64 {
  let b: *FsIovecBuf = bufs as *FsIovecBuf;
  let h: *u8;
  let total: i64 = 0;
  let i: i32 = 0;
  let written: u32 = 0;
  let len: u32;
  if (n <= 0 || n > FS_IOV_BUF_MAX || bufs == 0) {
    return -1;
  }
  h = fs_win32_handle_from_fd(fd);
  if (h == 0) {
    return -1;
  }
  while (i < n) {
    len = b[i].len as u32;
    if (b[i].len > 0x7fffffff) {
      len = 0x7fffffff;
    }
    unsafe { if (WriteFile(h, b[i].ptr, len, &written, 0 as *u8) == 0) {
      return -1;
    } }
    total = total + (written as i64);
    if ((written) < b[i].len) {
      return total;
    }
    i = i + 1;
  }
  return total;
}

/** Exported function `fs_sync_c`.
 * Implements `fs_sync_c`.
 * @param fd i32
 * @return i32
 */
export function fs_sync_c(fd: i32): i32 {
  let h: *u8 = fs_win32_handle_from_fd(fd);
  if (h == 0) {
    return -1;
  }
  unsafe { if (FlushFileBuffers(h) != 0) {
    return 0;
  } }
  return -1;
}

/** Exported function `fs_stat_c`.
 * Implements `fs_stat_c`.
 * @param path *u8
 * @param out *u8
 * @return i32
 */
export function fs_stat_c(path: *u8, out: *u8): i32 {
  let fad: Win32FileAttrData;
  let o: *FsStatOut = out as *FsStatOut;
  if (path == 0 || out == 0) {
    return -1;
  }
  unsafe { if (GetFileAttributesExA(path, GetFileExInfoStandard, &fad) == 0) {
    fs_note_last_error_win();
    return -1;
  } }
  o[0].size = ((fad.nFileSizeHigh as i64) << 32) | (fad.nFileSizeLow as i64);
  if ((fad.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0) {
    o[0].mode = 493;
    o[0].is_dir = 1;
    o[0].is_file = 0;
  } else {
    o[0].mode = 420;
    o[0].is_dir = 0;
    o[0].is_file = 1;
  }
  o[0].mtime_sec = 0;
  return 0;
}

/** Exported function `fs_chmod_c`.
 * Implements `fs_chmod_c`.
 * @param path *u8
 * @param mode u32
 * @return i32
 */
export function fs_chmod_c(path: *u8, mode: u32): i32 {
  if (path == 0) {
    return -1;
  }
  unsafe { if (_chmod(path, mode as i32) != 0) {
    fs_note_last_error_win();
    return -1;
  } }
  return 0;
}

/** Exported function `fs_mkdir_c`.
 * Implements `fs_mkdir_c`.
 * @param path *u8
 * @param mode u32
 * @return i32
 */
export function fs_mkdir_c(path: *u8, mode: u32): i32 {
  if (path == 0) {
    return -1;
  }
  unsafe { if (_mkdir(path) != 0) {
    fs_note_last_error_win();
    return -1;
  } }
  return 0;
}

/** Exported function `fs_unlink_c`.
 * Implements `fs_unlink_c`.
 * @param path *u8
 * @return i32
 */
export function fs_unlink_c(path: *u8): i32 {
  if (path == 0) {
    return -1;
  }
  unsafe { if (DeleteFileA(path) == 0) {
    fs_note_last_error_win();
    return -1;
  } }
  return 0;
}

/** Exported function `fs_rmdir_c`.
 * Implements `fs_rmdir_c`.
 * @param path *u8
 * @return i32
 */
export function fs_rmdir_c(path: *u8): i32 {
  if (path == 0) {
    return -1;
  }
  unsafe { if (_rmdir(path) != 0) {
    fs_note_last_error_win();
    return -1;
  } }
  return 0;
}

/** Exported function `fs_dir_open_c`.
 * Implements `fs_dir_open_c`.
 * @param path *u8
 * @return i64
 */
export function fs_dir_open_c(path: *u8): i64 {
  let pattern: u8[280];
  let h: *FsDirHandleWin;
  let find: *u8;
  let plen: i32 = 0;
  let pi: i32 = 0;
  if (path == 0) {
    return -1;
  }
  while (path[plen] != 0 && plen < 260) {
    pattern[plen] = path[plen];
    plen = plen + 1;
  }
  if (plen + 2 >= 280) {
    return -1;
  }
  if (plen > 0 && path[plen - 1] != 92 && path[plen - 1] != 47) {
    pattern[plen] = 92;
    plen = plen + 1;
  }
  pattern[plen] = 42;
  pattern[plen + 1] = 0;
  unsafe { h = malloc(300) as *FsDirHandleWin; }
  if (h == 0) {
    return -1;
  }
  unsafe { find = FindFirstFileA(&pattern[0], &h[0].fd); }
  if ((find as i64) == WIN32_INVALID_HANDLE) {
    unsafe { free(h as *u8); }
    fs_note_last_error_win();
    return -1;
  }
  h[0].find = find;
  h[0].first = 1;
  h[0].has_next = 1;
  return h as i64;
}

/** Exported function `fs_dir_read_c`.
 * Read path helper `fs_dir_read_c`.
 * @param handle i64
 * @param name_out *u8
 * @param name_cap i32
 * @param is_dir_out *i32
 * @return i32
 */
export function fs_dir_read_c(handle: i64, name_out: *u8, name_cap: i32, is_dir_out: *i32): i32 {
  let h: *FsDirHandleWin;
  let name: *u8;
  let nlen: usize;
  if (handle < 0 || name_out == 0 || name_cap <= 0) {
    return -1;
  }
  h = handle as *FsDirHandleWin;
  while (h[0].has_next != 0) {
    if (h[0].first != 0) {
      h[0].first = 0;
    } else {
      /* See implementation. */
      let next_rc: i32 = 0;
      unsafe { next_rc = FindNextFileA(h[0].find, &h[0].fd); }
      if (next_rc == 0) {
        h[0].has_next = 0;
        return 0;
      }
    }
    name = &h[0].fd.cFileName[0];
    if (name[0] == 46 && (name[1] == 0 || (name[1] == 46 && name[2] == 0))) {
      continue;
    }
    unsafe { nlen = strlen(name); }
    if (((nlen + 1) as i32) > name_cap) {
      return -1;
    }
    unsafe { memcpy(name_out, name, nlen + 1); }
    if (is_dir_out != 0) {
      if ((h[0].fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0) {
        is_dir_out[0] = 1;
      } else {
        is_dir_out[0] = 0;
      }
    }
    return 1;
  }
  return 0;
}

/** Exported function `fs_dir_close_c`.
 * Implements `fs_dir_close_c`.
 * @param handle i64
 * @return i32
 */
export function fs_dir_close_c(handle: i64): i32 {
  let h: *FsDirHandleWin;
  if (handle < 0) {
    return -1;
  }
  h = handle as *FsDirHandleWin;
  unsafe { FindClose(h[0].find); }
  unsafe { free(h as *u8); }
  return 0;
}

/** Exported function `fs_win32_module_anchor`.
 * Implements `fs_win32_module_anchor`.
 * @return i32
 */
export function fs_win32_module_anchor(): i32 {
  return 0;
}
