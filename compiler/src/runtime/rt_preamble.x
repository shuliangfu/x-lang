// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Sole bodies of write_io_net_abi_inline / write_fs_path_map_error_abi_inline
// (w843), labi_rt_preamble_slice_marker (w861), and, since w1495 (终局待办
// 5.4), the Cap-giant-string preamble tables themselves. The tables are
// module lets (pointer slots) filled from string literals on first use; the
// product installer renames their Lxml commons onto the C names
// driver_preamble_io_net_lines / driver_preamble_fs_path_lines that
// runtime_driver_abi's *_lines_raw() bases read. seeds/rt_preamble.from_x.c
// is deleted. Line access is driver_preamble_*_line_at (runtime_driver_abi).
// Each line is written by driver_preamble_fputs, which decodes the opaque
// fd-handle and calls xlang_io_write.
// Product install: ensure_rt_preamble_prefer (pure-asm this file + BSS
// rename). No seed, no host cc, no gcc -E.
// PLATFORM: SHARED — same object on POSIX and Windows.
// Row counts: io_net 218, fs_path 21 — exported as driver_preamble_*_lines_n
// beside the tables (single authority; seed externs them; thin reads them).
// The io_net writer used to loop to runtime_driver_abi's fixed 224 and read
// six slots past the table (the first six fs_path rows on Darwin); w1495
// loops to 218. Skip ranges below keep their historical row numbers.

export extern "C" function codegen_get_preamble_skip_mask(): i32;
export extern "C" function driver_preamble_io_net_line_at(i: i32): *u8;
export extern "C" function driver_preamble_io_net_line_count(): i32;
export extern "C" function driver_preamble_fs_path_line_at(i: i32): *u8;
export extern "C" function driver_preamble_fs_path_line_count(): i32;
export extern "C" function driver_preamble_fputs(s: *u8, stream: *u8): i32;
export extern "C" function xlang_ptr_slot_set(arr: *u8, i: i32, p: *u8): void;
export extern "C" function xlang_ptr_slot_get(arr: *u8, i: i32): *u8;
export extern function strlen(s: *u8): usize;
export extern function memcpy(d: *u8, s: *u8, n: usize): *u8;

// Cap-giant-string tables (w1495) + row-count authority (w2060).
// Renamed onto the C names at install (ensure renames by name+index):
//   driver_preamble_io_net_lines    (218 pointer slots)
//   driver_preamble_fs_path_lines   (21 pointer slots)
//   driver_preamble_io_net_lines_n  (i32 count = 218)
//   driver_preamble_fs_path_lines_n (i32 count = 21)
// Keep these four lets first and in this order. rt_pre_arena (fifth) is
// not renamed. Counts are the single authority for seed extern and thin
// line_at/count bounds — do not hardcode 218/21/224 elsewhere.
let driver_preamble_io_net_lines: i64[218] = [];
let driver_preamble_fs_path_lines: i64[21] = [];
let driver_preamble_io_net_lines_n: i32 = 218;
let driver_preamble_fs_path_lines_n: i32 = 21;
// Backing store for the 38 rows longer than 120 bytes (bytes + NULs).
// Fifth let, not renamed (stays a local common).
let rt_pre_arena: u8[28114] = [];

// CODEGEN_PREAMBLE_SKIP_* bit layout (codegen.h; keep numeric literals in .x):
//   1 = CORE_MACROS (i 64..81)
//   2 = DRIVER_HANDLE (i 60..63)
//   4 = UNDEF_REDEFINE (i 105..118)
//   8 = WEAK_IO_BATCH (i 178..181; wave29)

/**
 * Append literal p at a+off (no NUL) and return the new offset. Rows longer
 * than 120 bytes are built from pieces into rt_pre_arena: the asm backend
 * keeps only 127 bytes of a string literal on Darwin arm64 and crashes past
 * about 4 KiB on every target. PLATFORM: SHARED.
 */
function rt_pre_cat(a: *u8, off: i64, p: *u8): i64 {
  let n: i64 = 0;
  unsafe {
    n = strlen(p) as i64;
    memcpy((a as i64 + off) as *u8, p, n as usize);
  }
  return off + n;
}

/** Fill io_net rows 0..17. PLATFORM: SHARED. */
function rt_pre_io_net_fill_0(t: *u8, a: *u8, off0: i64): i64 {
  let off: i64 = off0;
  let s: i64 = 0;
  s = off;
  off = rt_pre_cat(a, off, "#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 201112L\n#error \"Generated code needs C11. Compile with -std=gnu11 o");
  off = rt_pre_cat(a, off, "r -std=c11.\"\n#endif\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 0, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 1, "#include <stddef.h>\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 2, "#include <stdint.h>\n#include <xlang_va_cap.h>\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 3, "#include <stdlib.h>\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 4, "#include <string.h>\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 5, "#if !defined(_WIN32) && !defined(_WIN64)\n#include <unistd.h>\n#else\n#include <io.h>\n#include <sys/types.h>\n#endif\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 6, "#if !defined(_WIN32) && !defined(_WIN64)\n#include <sys/uio.h>\n#endif\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 7, "#if !defined(_WIN32) && !defined(_WIN64)\n#include <poll.h>\n#endif\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#ifndef O_RDONLY\n#define O_RDONLY 0\n#endif\n#ifndef O_WRONLY\n#define O_WRONLY 1\n#endif\n#ifndef O_RDWR\n#define O_RDWR 2\n#e");
  off = rt_pre_cat(a, off, "ndif\n#if defined(__APPLE__)\n#ifndef O_CREAT\n#define O_CREAT 512\n#endif\n#ifndef O_TRUNC\n#define O_TRUNC 1024\n#endif\n#ifnd");
  off = rt_pre_cat(a, off, "ef O_APPEND\n#define O_APPEND 8\n#endif\n#ifndef F_NOCACHE\n#define F_NOCACHE 48\n#endif\n#else\n#ifndef O_CREAT\n#define O_CREA");
  off = rt_pre_cat(a, off, "T 64\n#endif\n#ifndef O_TRUNC\n#define O_TRUNC 512\n#endif\n#ifndef O_APPEND\n#define O_APPEND 1024\n#endif\n#endif\n#ifndef PROT");
  off = rt_pre_cat(a, off, "_READ\n#define PROT_READ 1\n#endif\n#ifndef PROT_WRITE\n#define PROT_WRITE 2\n#endif\n#ifndef MAP_SHARED\n#define MAP_SHARED 1\n");
  off = rt_pre_cat(a, off, "#endif\n#ifndef MAP_PRIVATE\n#define MAP_PRIVATE 2\n#endif\n#ifndef MAP_FAILED\n#define MAP_FAILED ((int64_t)-1)\n#endif\n#ifnd");
  off = rt_pre_cat(a, off, "ef S_IFMT\n#define S_IFMT 61440u\n#endif\n#ifndef S_IFDIR\n#define S_IFDIR 16384u\n#endif\n#ifndef S_IFREG\n#define S_IFREG 327");
  off = rt_pre_cat(a, off, "68u\n#endif\n#ifndef FS_IOV_BUF_MAX\n#define FS_IOV_BUF_MAX 16\n#endif\n#ifndef DIRENT_D_NAME_OFF\n#if defined(__APPLE__)\n#def");
  off = rt_pre_cat(a, off, "ine DIRENT_D_NAME_OFF ((size_t)21)\n#else\n#define DIRENT_D_NAME_OFF ((size_t)19)\n#endif\n#endif\n#if !defined(_WIN32) && !d");
  off = rt_pre_cat(a, off, "efined(_WIN64)\n#if defined(__APPLE__)\nextern int *__error(void);\n#else\nextern int *__errno_location(void);\n#endif\nextern");
  off = rt_pre_cat(a, off, " int32_t fcntl(int32_t fd, int32_t cmd, int32_t arg);\nextern int32_t madvise(uint8_t *addr, size_t len, int32_t advice);");
  off = rt_pre_cat(a, off, "\nextern int32_t open(uint8_t *path, int32_t flags, int32_t mode);\nstatic inline int32_t fs_libc_open(uint8_t *path, int3");
  off = rt_pre_cat(a, off, "2_t flags, int32_t mode) {\n  return open(path, flags, mode);\n}\n#define fs_note_last_error_posix std_fs_posix_fs_note_las");
  off = rt_pre_cat(a, off, "t_error_posix\n#endif\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 8, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "#include <xlang_io_cap.h>\nstatic inline ssize_t xlang_sys_read(int32_t fd, uint8_t *buf, size_t count) {\n  return (ssize");
  off = rt_pre_cat(a, off, "_t)xlang_io_read((int)fd, (void *)buf, count);\n}\nstatic inline ssize_t xlang_sys_write(int32_t fd, uint8_t *buf, size_t ");
  off = rt_pre_cat(a, off, "count) {\n  return (ssize_t)xlang_io_write((int)fd, (const void *)buf, count);\n}\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 9, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "#if !defined(_WIN32) && !defined(_WIN64)\nstatic inline ssize_t xlang_sys_readv(int32_t fd, uint8_t *iov, int32_t iovcnt)");
  off = rt_pre_cat(a, off, " {\n  return readv((int)fd, (const struct iovec *)(const void *)iov, (int)iovcnt);\n}\n#endif\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 10, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "static inline ssize_t xlang_sys_writev(int32_t fd, uint8_t *iov, int32_t iovcnt) {\n  return (ssize_t)xlang_io_writev((in");
  off = rt_pre_cat(a, off, "t)fd, (const void *)iov, (int)iovcnt);\n}\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 11, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "#if !defined(_WIN32) && !defined(_WIN64)\n#include <xlang_net_cap.h>\nstatic inline int32_t xlang_sys_poll(uint8_t *fds, i");
  off = rt_pre_cat(a, off, "nt32_t nfds, int32_t timeout) {\n  return (int32_t)xlang_net_poll((void *)fds, (unsigned int)nfds, (int)timeout);\n}\n#endi");
  off = rt_pre_cat(a, off, "f\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 12, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "#if !defined(_WIN32) && !defined(_WIN64)\nstatic inline ssize_t xlang_sys_pread(int32_t fd, uint8_t *buf, size_t count, i");
  off = rt_pre_cat(a, off, "nt64_t offset) {\n  return pread((int)fd, (void *)buf, count, (off_t)offset);\n}\n#endif\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 13, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "#if !defined(_WIN32) && !defined(_WIN64)\nstatic inline ssize_t xlang_sys_pwrite(int32_t fd, uint8_t *buf, size_t count, ");
  off = rt_pre_cat(a, off, "int64_t offset) {\n  return pwrite((int)fd, (const void *)buf, count, (off_t)offset);\n}\n#endif\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 14, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 15, "static inline int32_t xlang_fs_unlink(uint8_t *path) {\n  return (int32_t)unlink((const char *)path);\n}\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 16, "static inline int32_t xlang_fs_rmdir(uint8_t *path) {\n  return (int32_t)rmdir((const char *)path);\n}\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#ifndef XLANG_DYN_OBJ\n#define XLANG_DYN_OBJ\nstruct xlang_dyn_obj { void *data; void *vtable; };\n#endif\n#ifndef XLANG_SLI");
  off = rt_pre_cat(a, off, "CE_LAYOUTS\n#define XLANG_SLICE_LAYOUTS\nstruct xlang_slice_uint8_t { uint8_t *data; size_t length; };\nstruct xlang_slice_");
  off = rt_pre_cat(a, off, "int8_t { int8_t *data; size_t length; };\nstruct xlang_slice_int16_t { int16_t *data; size_t length; };\nstruct xlang_slic");
  off = rt_pre_cat(a, off, "e_uint16_t { uint16_t *data; size_t length; };\nstruct xlang_slice_int { int *data; size_t length; };\nstruct xlang_slice_");
  off = rt_pre_cat(a, off, "int32_t { int32_t *data; size_t length; };\nstruct xlang_slice_uint32_t { uint32_t *data; size_t length; };\nstruct xlang_");
  off = rt_pre_cat(a, off, "slice_int64_t { int64_t *data; size_t length; };\nstruct xlang_slice_uint64_t { uint64_t *data; size_t length; };\nstruct ");
  off = rt_pre_cat(a, off, "xlang_slice_size_t { size_t *data; size_t length; };\nstruct xlang_slice_ssize_t { ssize_t *data; size_t length; };\nstruc");
  off = rt_pre_cat(a, off, "t xlang_slice_float { float *data; size_t length; };\nstruct xlang_slice_double { double *data; size_t length; };\nstruct ");
  off = rt_pre_cat(a, off, "xlang_slice_xlang_slice_uint8_t { struct xlang_slice_uint8_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_int");
  off = rt_pre_cat(a, off, "8_t { struct xlang_slice_int8_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_int16_t { struct xlang_slice_int");
  off = rt_pre_cat(a, off, "16_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_uint16_t { struct xlang_slice_uint16_t *data; size_t length");
  off = rt_pre_cat(a, off, "; };\nstruct xlang_slice_xlang_slice_int { struct xlang_slice_int *data; size_t length; };\nstruct xlang_slice_xlang_slice");
  off = rt_pre_cat(a, off, "_int32_t { struct xlang_slice_int32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_uint32_t { struct xlang_sl");
  off = rt_pre_cat(a, off, "ice_uint32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_int64_t { struct xlang_slice_int64_t *data; size_t ");
  off = rt_pre_cat(a, off, "length; };\nstruct xlang_slice_xlang_slice_uint64_t { struct xlang_slice_uint64_t *data; size_t length; };\nstruct xlang_s");
  off = rt_pre_cat(a, off, "lice_xlang_slice_size_t { struct xlang_slice_size_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_ssize_t { st");
  off = rt_pre_cat(a, off, "ruct xlang_slice_ssize_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_float { struct xlang_slice_float *data;");
  off = rt_pre_cat(a, off, " size_t length; };\nstruct xlang_slice_xlang_slice_double { struct xlang_slice_double *data; size_t length; };\nstruct xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_uint8_t *data; size_t length; };\nstruct xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_int8_t *data; size_t length; };\nstruct xlang_slice");
  off = rt_pre_cat(a, off, "_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_int16_t *data; size_t length; };\nstruct xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_uint16_t *data; size_t length; };\nstruct xlang_slice_xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_int { struct xlang_slice_xlang_slice_int *data; size_t length; };\nstruct xlang_slice_xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_int32_t { struct xlang_slice_xlang_slice_int32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang");
  off = rt_pre_cat(a, off, "_slice_uint32_t { struct xlang_slice_xlang_slice_uint32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_int64_t { struct xlang_slice_xlang_slice_int64_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_uint64_t { struct xlang_slice_xlang_slice_uint64_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slic");
  off = rt_pre_cat(a, off, "e_size_t { struct xlang_slice_xlang_slice_size_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_ssi");
  off = rt_pre_cat(a, off, "ze_t { struct xlang_slice_xlang_slice_ssize_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_float ");
  off = rt_pre_cat(a, off, "{ struct xlang_slice_xlang_slice_float *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_double { stru");
  off = rt_pre_cat(a, off, "ct xlang_slice_xlang_slice_double *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_");
  off = rt_pre_cat(a, off, "t { struct xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang_slice_int8_t *data; size_t length; };\nstruct xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_slice_int16_t *data; size_t length; };\n");
  off = rt_pre_cat(a, off, "struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_xlang_slice_uint16_t *d");
  off = rt_pre_cat(a, off, "ata; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xlang");
  off = rt_pre_cat(a, off, "_slice_int *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_xlang_slice_int32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t");
  off = rt_pre_cat(a, off, " { struct xlang_slice_xlang_slice_xlang_slice_uint32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_int64_t { struct xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };\nstruct xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length;");
  off = rt_pre_cat(a, off, " };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_size_t *d");
  off = rt_pre_cat(a, off, "ata; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_x");
  off = rt_pre_cat(a, off, "lang_slice_ssize_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_float { struct xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_xlang_slice_float *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_doub");
  off = rt_pre_cat(a, off, "le { struct xlang_slice_xlang_slice_xlang_slice_double *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length");
  off = rt_pre_cat(a, off, "; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang_sl");
  off = rt_pre_cat(a, off, "ice_xlang_slice_int8_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16");
  off = rt_pre_cat(a, off, "_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t *data; size_t length; };\nstruct xlang_slice_xlang_sl");
  off = rt_pre_cat(a, off, "ice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t *data");
  off = rt_pre_cat(a, off, "; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_sl");
  off = rt_pre_cat(a, off, "ice_xlang_slice_xlang_slice_int *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_sl");
  off = rt_pre_cat(a, off, "ice_int32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t *data; size_t length; };\nstruct xlang_slice");
  off = rt_pre_cat(a, off, "_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint3");
  off = rt_pre_cat(a, off, "2_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t { struct xlang_s");
  off = rt_pre_cat(a, off, "lice_xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };");
  off = rt_pre_cat(a, off, "\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_size_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t {");
  off = rt_pre_cat(a, off, " struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_float *data; size_t l");
  off = rt_pre_cat(a, off, "ength; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double { struct xlang_slice_xlang_slice_xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_double *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_uint8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; }");
  off = rt_pre_cat(a, off, ";\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice");
  off = rt_pre_cat(a, off, "_xlang_slice_xlang_slice_xlang_slice_int8_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_sl");
  off = rt_pre_cat(a, off, "ice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t *data; ");
  off = rt_pre_cat(a, off, "size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang");
  off = rt_pre_cat(a, off, "_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice");
  off = rt_pre_cat(a, off, "_int *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { s");
  off = rt_pre_cat(a, off, "truct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t *data; size_t length; };\nstruct xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_sl");
  off = rt_pre_cat(a, off, "ice_xlang_slice_uint32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xla");
  off = rt_pre_cat(a, off, "ng_slice_int64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };\ns");
  off = rt_pre_cat(a, off, "truct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_s");
  off = rt_pre_cat(a, off, "lice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t *data; s");
  off = rt_pre_cat(a, off, "ize_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_s");
  off = rt_pre_cat(a, off, "lice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_ssize_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "float *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double { s");
  off = rt_pre_cat(a, off, "truct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double *data; size_t length; };\nstruct xlang_slice_xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_xlang_slic");
  off = rt_pre_cat(a, off, "e_xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_int8_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice");
  off = rt_pre_cat(a, off, "_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t *data; siz");
  off = rt_pre_cat(a, off, "e_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { str");
  off = rt_pre_cat(a, off, "uct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t *data; size_t length; };\nstruct xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_xlang_slice_xlang_slice_xlang_slice_int *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_int32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang");
  off = rt_pre_cat(a, off, "_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t *d");
  off = rt_pre_cat(a, off, "ata; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_");
  off = rt_pre_cat(a, off, "t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };\nstru");
  off = rt_pre_cat(a, off, "ct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };\nstruct xlang_slice_xlang_slic");
  off = rt_pre_cat(a, off, "e_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_xlang_slice_size_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xla");
  off = rt_pre_cat(a, off, "ng_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slic");
  off = rt_pre_cat(a, off, "e_ssize_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_float { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_float *data; size_t length;");
  off = rt_pre_cat(a, off, " };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double { struct xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_double *data; size_t length; };\nstruct xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t { struct xlang_slice_xlang_slice_x");
  off = rt_pre_cat(a, off, "lang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint8_t *data; size_t length; };\nstruct xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t { struct xlang_slice_xlang_slice_xlang");
  off = rt_pre_cat(a, off, "_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int8_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t { struct xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int16_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang");
  off = rt_pre_cat(a, off, "_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t { struct xlang_slice_xlang_slice_xlang_slice");
  off = rt_pre_cat(a, off, "_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint16_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int { struct xlang_slice_xlang_slice_xlang_slice_xlang");
  off = rt_pre_cat(a, off, "_slice_xlang_slice_xlang_slice_xlang_slice_int *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang");
  off = rt_pre_cat(a, off, "_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_xlang_slice_xlang_slice_int32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_sl");
  off = rt_pre_cat(a, off, "ice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint32_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xl");
  off = rt_pre_cat(a, off, "ang_slice_xlang_slice_xlang_slice_uint32_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_xlang_slice_xlang_slice_xlang_slice_int64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlan");
  off = rt_pre_cat(a, off, "g_slice_xlang_slice_xlang_slice_int64_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_xlang_slice_xlang_slice_xlang_slice_uint64_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_xlang_slice_uint64_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_x");
  off = rt_pre_cat(a, off, "lang_slice_xlang_slice_xlang_slice_xlang_slice_size_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_xlang_slice_size_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_xlang_slice_xlang_slice_ssize_t { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_x");
  off = rt_pre_cat(a, off, "lang_slice_xlang_slice_ssize_t *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_sli");
  off = rt_pre_cat(a, off, "ce_xlang_slice_xlang_slice_xlang_slice_float { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_");
  off = rt_pre_cat(a, off, "slice_xlang_slice_float *data; size_t length; };\nstruct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlan");
  off = rt_pre_cat(a, off, "g_slice_xlang_slice_xlang_slice_double { struct xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_xlang_slice_");
  off = rt_pre_cat(a, off, "xlang_slice_double *data; size_t length; };\n#endif\n#ifndef XLANG_VECTOR_TYPES\n#define XLANG_VECTOR_TYPES\n#if defined(__G");
  off = rt_pre_cat(a, off, "NUC__) || defined(__clang__)\ntypedef int32_t i32x4_t __attribute__((vector_size(16)));\ntypedef int32_t i32x8_t __attribu");
  off = rt_pre_cat(a, off, "te__((vector_size(32)));\ntypedef int32_t i32x16_t __attribute__((vector_size(64)));\ntypedef uint32_t u32x4_t __attribute");
  off = rt_pre_cat(a, off, "__((vector_size(16)));\ntypedef uint32_t u32x8_t __attribute__((vector_size(32)));\ntypedef uint32_t u32x16_t __attribute_");
  off = rt_pre_cat(a, off, "_((vector_size(64)));\ntypedef float f32x4_t __attribute__((vector_size(16)));\ntypedef float f32x8_t __attribute__((vecto");
  off = rt_pre_cat(a, off, "r_size(32)));\ntypedef float f32x16_t __attribute__((vector_size(64)));\n#else\ntypedef struct { int32_t e[4]; } i32x4_t;\nt");
  off = rt_pre_cat(a, off, "ypedef struct { int32_t e[8]; } i32x8_t;\ntypedef struct { int32_t e[16]; } i32x16_t;\ntypedef struct { uint32_t e[4]; } u");
  off = rt_pre_cat(a, off, "32x4_t;\ntypedef struct { uint32_t e[8]; } u32x8_t;\ntypedef struct { uint32_t e[16]; } u32x16_t;\ntypedef struct { float e");
  off = rt_pre_cat(a, off, "[4]; } f32x4_t;\ntypedef struct { float e[8]; } f32x8_t;\ntypedef struct { float e[16]; } f32x16_t;\n#endif\n#endif\ntypedef ");
  off = rt_pre_cat(a, off, "struct { uint8_t *ptr; size_t length; size_t handle; } xlang_batch_buf_t;\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 17, (a as i64 + s) as *u8);
  }
  return off;
}

/** Fill io_net rows 18..52. PLATFORM: SHARED. */
function rt_pre_io_net_fill_1(t: *u8, a: *u8, off0: i64): i64 {
  let off: i64 = off0;
  let s: i64 = 0;
  unsafe {
    xlang_ptr_slot_set(t, 18, "extern int io_register_buffer(uint8_t *ptr, size_t len);\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "extern int io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *p3, si");
  off = rt_pre_cat(a, off, "ze_t l3, unsigned nr);\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 19, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "__attribute__((weak)) int io_register_buffers_buf_c(const xlang_batch_buf_t *bufs, int nr) { (void)bufs; (void)nr; retur");
  off = rt_pre_cat(a, off, "n -1; }\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 20, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "static inline int io_register_buffers_buf_i32(intptr_t bufs, int nr) { return io_register_buffers_buf_c((const xlang_bat");
  off = rt_pre_cat(a, off, "ch_buf_t *)(uintptr_t)bufs, nr); }\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 21, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 22, "#define io_register_buffers_buf(bufs, nr) io_register_buffers_buf_i32((intptr_t)(void *)(bufs), (nr))\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 23, "extern void io_unregister_buffers(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 24, "extern ptrdiff_t io_read(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 25, "extern ptrdiff_t io_write(int fd, uint8_t *buf, size_t count, unsigned timeout_ms);\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "extern ptrdiff_t io_read_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *");
  off = rt_pre_cat(a, off, "p3, size_t l3, int n, unsigned timeout_ms);\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 26, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "extern ptrdiff_t io_write_batch(int fd, uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t ");
  off = rt_pre_cat(a, off, "*p3, size_t l3, int n, unsigned timeout_ms);\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 27, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 28, "extern ptrdiff_t io_read_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 29, "extern ptrdiff_t io_write_fixed(int fd, unsigned buf_index, size_t offset, size_t len, unsigned timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 30, "extern int io_wait_readable(int32_t *fds, int n, unsigned timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 31, "extern uint8_t *io_read_ptr(size_t handle, unsigned timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 32, "extern int io_read_ptr_len(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 33, "extern int32_t xlang_io_register(uint8_t *ptr, size_t len, size_t handle);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 34, "extern int32_t xlang_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 35, "extern int32_t xlang_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 36, "extern int32_t xlang_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_m);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 37, "extern int32_t xlang_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_m);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 38, "extern uint8_t *xlang_io_read_ptr(size_t handle, unsigned timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 39, "extern int32_t xlang_io_read_ptr_len(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 40, "typedef struct { void *ptr; size_t length; size_t handle; } xlang_buffer_abi_t;\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "static inline int32_t xlang_io_register_buf(intptr_t buf) { const xlang_buffer_abi_t *b = (const xlang_buffer_abi_t *)(u");
  off = rt_pre_cat(a, off, "intptr_t)buf; return xlang_io_register((uint8_t *)b->ptr, b->length, b->handle); }\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 41, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "static inline int32_t xlang_io_submit_read_buf(intptr_t buf, int32_t timeout_m) { const xlang_buffer_abi_t *b = (const x");
  off = rt_pre_cat(a, off, "lang_buffer_abi_t *)(uintptr_t)buf; return (xlang_io_submit_read)((uint8_t *)b->ptr, b->length, b->handle, (uint32_t)tim");
  off = rt_pre_cat(a, off, "eout_m); }\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 42, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "static inline int32_t xlang_io_submit_write_buf(intptr_t buf, int32_t timeout_m) { const xlang_buffer_abi_t *b = (const ");
  off = rt_pre_cat(a, off, "xlang_buffer_abi_t *)(uintptr_t)buf; return (xlang_io_submit_write)((uint8_t *)b->ptr, b->length, b->handle, (uint32_t)t");
  off = rt_pre_cat(a, off, "imeout_m); }\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 43, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "static inline int32_t std_io_driver_submit_read_via_ptr(ptrdiff_t buf, uint32_t timeout_ms) { return xlang_io_submit_rea");
  off = rt_pre_cat(a, off, "d_buf((intptr_t)buf, (int32_t)timeout_ms); }\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 44, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "static inline int32_t std_io_driver_submit_write_via_ptr(ptrdiff_t buf, uint32_t timeout_ms) { return xlang_io_submit_wr");
  off = rt_pre_cat(a, off, "ite_buf((intptr_t)buf, (int32_t)timeout_ms); }\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 45, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 46, "#define xlang_io_register(buf) xlang_io_register_buf(buf)\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 47, "#define xlang_io_submit_read(buf, timeout_m) xlang_io_submit_read_buf(buf, timeout_m)\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 48, "#define xlang_io_submit_write(buf, timeout_m) xlang_io_submit_write_buf(buf, timeout_m)\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "/* 撤销宏：X codegen 会生成同名函数定义(xlang_io_register/submit_read/submit_write)，宏与多参签名冲");
  off = rt_pre_cat(a, off, "突，在函数体前必须 undef。 */\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 49, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 50, "#undef xlang_io_register\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 51, "#undef xlang_io_submit_read\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 52, "#undef xlang_io_submit_write\n");
  }
  return off;
}

/** Fill io_net rows 53..116. PLATFORM: SHARED. */
function rt_pre_io_net_fill_2(t: *u8, a: *u8, off0: i64): i64 {
  let off: i64 = off0;
  let s: i64 = 0;
  unsafe {
    xlang_ptr_slot_set(t, 53, "struct std_io_driver_Buffer { void *ptr; size_t length; size_t handle; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 54, "typedef struct std_io_driver_Buffer std_io_Buffer;\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 55, "#define std_io_Buffer std_io_driver_Buffer\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 56, "extern ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 57, "extern ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 58, "extern int32_t std_io_driver_submit_register_fixed_buffers_buf(struct std_io_driver_Buffer * bufs, uint32_t nr);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 59, "#define std_io_driver_driver_read_ptr_len xlang_io_read_ptr_len\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 60, "#define std_io_driver_driver_read_ptr xlang_io_read_ptr\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 61, "#define driver_read_ptr_len std_io_driver_driver_read_ptr_len\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 62, "#define driver_read_ptr std_io_driver_driver_read_ptr\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 63, "#define submit_register_fixed_buffers_buf std_io_driver_submit_register_fixed_buffers_buf\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 64, "/* 短名 submit_read/write → via_ptr；全名 std_io_driver_submit_* 由 co-emit 定义。 */\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 65, "#define submit_read(buf, timeout_ms) std_io_driver_submit_read_via_ptr((ptrdiff_t)(uintptr_t)&(buf), (timeout_ms))\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 66, "#define submit_write(buf, timeout_ms) std_io_driver_submit_write_via_ptr((ptrdiff_t)(uintptr_t)&(buf), (timeout_ms))\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 67, "#define std_io_driver_read_ptr driver_read_ptr\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 68, "#define std_io_driver_read_ptr_len driver_read_ptr_len\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 69, "extern size_t std_io_handle_stdin(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 70, "extern size_t std_io_handle_stdout(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 71, "extern size_t std_io_handle_stderr(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 72, "extern size_t std_io_handle_from_fd(int32_t fd, int32_t unused);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 73, "extern size_t std_io_driver_handle_from_fd(int32_t fd, int32_t unused);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 74, "extern int32_t std_io_write_stdout(uint8_t *ptr, size_t len);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 75, "#define std_io_driver_handle_stdin std_io_handle_stdin\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 76, "#define std_io_driver_handle_stdout std_io_handle_stdout\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 77, "#define std_io_driver_handle_stderr std_io_handle_stderr\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 78, "#define std_io_driver_write_stdout std_io_write_stdout\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 79, "/* std.io.core 体内调 extern io_*；codegen 前缀为 std_io_core_io_*，映射到 preamble 已声明的 io_*。 */\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 80, "#define std_io_core_io_read io_read\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 81, "#define std_io_core_io_write io_write\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 82, "#define std_io_core_io_read_batch io_read_batch\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 83, "#define std_io_core_io_write_batch io_write_batch\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 84, "#define std_io_core_io_read_fixed io_read_fixed\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 85, "#define std_io_core_io_write_fixed io_write_fixed\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 86, "#define std_io_core_xlang_io_register xlang_io_register\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 87, "#define std_io_core_xlang_io_register_buffers xlang_io_register_buffers\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 88, "#define std_io_core_xlang_io_unregister_buffers xlang_io_unregister_buffers\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 89, "#define std_io_core_xlang_io_submit_read xlang_io_submit_read\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 90, "#define std_io_core_xlang_io_read_ptr xlang_io_read_ptr\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 91, "#define std_io_core_xlang_io_read_ptr_len xlang_io_read_ptr_len\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 92, "#define std_io_core_xlang_io_submit_write xlang_io_submit_write\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 93, "#define std_io_core_xlang_io_submit_read_batch xlang_io_submit_read_batch\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 94, "#define std_io_core_xlang_io_submit_write_batch xlang_io_submit_write_batch\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 95, "#define std_io_core_xlang_io_read_fixed xlang_io_read_fixed\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 96, "#define std_io_core_xlang_io_write_fixed xlang_io_write_fixed\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 97, "#define std_io_core_xlang_io_register_buffers_buf io_register_buffers_buf\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 98, "#define std_io_core_xlang_io_read_ptr_gen xlang_io_read_ptr_gen\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 99, "#define std_io_core_xlang_io_read_ptr_gen_valid xlang_io_read_ptr_gen_valid\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 100, "#define std_io_core_xlang_io_read_ptr_backend xlang_io_read_ptr_backend\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 101, "#define std_io_core_xlang_io_read_ptr_slice xlang_io_read_ptr_slice\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#define std_io_core_xlang_io_read_batch_buf(fd, bufs, n, t) io_read_batch_buf((fd), (const struct std_io_driver_Buffer *");
  off = rt_pre_cat(a, off, ")(const void *)(bufs), (n), (t))\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 102, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "#define std_io_core_xlang_io_write_batch_buf(fd, bufs, n, t) io_write_batch_buf((fd), (const struct std_io_driver_Buffer");
  off = rt_pre_cat(a, off, " *)(const void *)(bufs), (n), (t))\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 103, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 104, "#define std_io_core_xlang_io_register_provided_buffers xlang_io_register_provided_buffers\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 105, "#define std_io_core_xlang_io_unregister_provided_buffers xlang_io_unregister_provided_buffers\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 106, "#define std_io_core_xlang_io_provided_buffer_ptr xlang_io_provided_buffer_ptr\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 107, "#define std_io_core_xlang_io_provided_buffer_size xlang_io_provided_buffer_size\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 108, "#define std_io_core_xlang_io_read_provided xlang_io_read_provided\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 109, "#define std_io_core_xlang_io_read_batch_provided xlang_io_read_batch_provided\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 110, "#define std_io_core_xlang_io_submit_read_async xlang_io_submit_read_async\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 111, "#define std_io_core_xlang_io_complete_read_async xlang_io_complete_read_async\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 112, "#define std_io_core_xlang_io_complete_read_async_slot xlang_io_complete_read_async_slot\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 113, "#define std_io_core_xlang_io_submit_write_async xlang_io_submit_write_async\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 114, "#define std_io_core_xlang_io_complete_write_async xlang_io_complete_write_async\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 115, "#define std_io_core_xlang_io_complete_write_async_slot xlang_io_complete_write_async_slot\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 116, "#define std_io_core_xlang_io_poll_async_completions xlang_io_poll_async_completions\n");
  }
  return off;
}

/** Fill io_net rows 117..157. PLATFORM: SHARED. */
function rt_pre_io_net_fill_3(t: *u8, a: *u8, off0: i64): i64 {
  let off: i64 = off0;
  let s: i64 = 0;
  unsafe {
    xlang_ptr_slot_set(t, 117, "#define std_io_core_xlang_io_uring_is_available_c xlang_io_uring_is_available_c\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 118, "extern int32_t xlang_io_read_ptr_gen_valid(uint64_t saved);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 119, "extern int32_t xlang_io_read_ptr_backend(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 120, "extern uint64_t xlang_io_read_ptr_gen(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 121, "extern struct xlang_slice_uint8_t xlang_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 122, "extern int32_t xlang_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 123, "extern void xlang_io_unregister_provided_buffers(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 124, "extern uint8_t *xlang_io_provided_buffer_ptr(uint32_t bid);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 125, "extern uint32_t xlang_io_provided_buffer_size(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 126, "extern int32_t xlang_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t *out_bid, uint32_t *out_len);\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "extern int32_t xlang_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t *out_bids, uint32_t ");
  off = rt_pre_cat(a, off, "*out_lens);\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 127, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 128, "extern int32_t xlang_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 129, "extern int32_t xlang_io_complete_read_async(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 130, "extern int32_t xlang_io_complete_read_async_slot(int32_t slot);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 131, "extern int32_t xlang_io_submit_write_async(uint8_t *ptr, size_t len, size_t handle);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 132, "extern int32_t xlang_io_complete_write_async(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 133, "extern int32_t xlang_io_complete_write_async_slot(int32_t slot);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 134, "extern uint32_t xlang_io_poll_async_completions(uint32_t timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 135, "extern int32_t xlang_io_uring_is_available_c(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 136, "#define std_io_driver_io_register_buffers_buf(bufs, nr) io_register_buffers_buf((intptr_t)(void *)(bufs), (int)(nr))\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "extern int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer * bufs, int32_t n, uint32_");
  off = rt_pre_cat(a, off, "t timeout_ms);\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 137, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "extern int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer * bufs, int32_t n, uint32");
  off = rt_pre_cat(a, off, "_t timeout_ms);\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 138, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 139, "#define std_io_submit_read_batch_buf std_io_driver_submit_read_batch_buf\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 140, "#define std_io_submit_write_batch_buf std_io_driver_submit_write_batch_buf\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "extern int32_t std_io_read_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms)");
  off = rt_pre_cat(a, off, ";\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 141, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "extern int32_t std_io_write_fixed_fd_impl(int32_t fd, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_ms");
  off = rt_pre_cat(a, off, ");\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 142, (a as i64 + s) as *u8);
  }
  s = off;
  off = rt_pre_cat(a, off, "/* X 生成代码可能调用 std_io_* / std_net_* 带前缀名且首参为 stream/listener 结构体；以下宏统一");
  off = rt_pre_cat(a, off, "转为 .fd 再调 _impl。C 路径下 std.io 仍定义 std_io_read_fixed_fd，故仅 X 需宏。 */\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 143, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 144, "struct std_net_TcpStream { int32_t fd; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 145, "struct std_net_TcpListener { int32_t fd; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 146, "struct std_net_UdpSocket { int32_t fd; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 147, "#if defined(__clang__)\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#define xlang_io_net_fd(x) _Generic((x), struct std_net_TcpStream: (x).fd, struct std_net_TcpListener: (x).fd, struct st");
  off = rt_pre_cat(a, off, "d_net_UdpSocket: (x).fd, default: (int32_t)(x))\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 148, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 149, "#elif defined(__GNUC__)\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "/* 仅用 *(int32_t*)&(x)：int32_t 与仅含 .fd 的 struct 首字节相同，且避免 __builtin_types_compatible_p ");
  off = rt_pre_cat(a, off, "在部分环境报错、三元分支被全量类型检查。调用方须传 lvalue。 */\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 150, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 151, "#define xlang_io_net_fd(x) (*(int32_t*)(void*)&(x))\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 152, "#else\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#define xlang_io_net_fd(x) _Generic((x), struct std_net_TcpStream: (x).fd, struct std_net_TcpListener: (x).fd, struct st");
  off = rt_pre_cat(a, off, "d_net_UdpSocket: (x).fd, default: (int32_t)(x))\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 153, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 154, "#endif\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 155, "#define std_io_read_fixed_fd(x, a, b, c, d) std_io_read_fixed_fd_impl(xlang_io_net_fd(x), a, b, c, d)\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 156, "#define std_io_write_fixed_fd(x, a, b, c, d) std_io_write_fixed_fd_impl(xlang_io_net_fd(x), a, b, c, d)\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "/* X 内联 std.io 会生成函数定义；撤销与定义/extern 冲突的宏，并补齐 batch 注册符号映射。 *");
  off = rt_pre_cat(a, off, "/\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 157, (a as i64 + s) as *u8);
  }
  return off;
}

/** Fill io_net rows 158..191. PLATFORM: SHARED. */
function rt_pre_io_net_fill_4(t: *u8, a: *u8, off0: i64): i64 {
  let off: i64 = off0;
  let s: i64 = 0;
  unsafe {
    xlang_ptr_slot_set(t, 158, "#undef std_io_driver_io_register_buffers_buf\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 159, "#undef std_io_read_fixed_fd\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 160, "#undef std_io_write_fixed_fd\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 161, "#undef std_io_core_xlang_io_register_buffers\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 162, "#undef std_io_core_xlang_io_unregister_buffers\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 163, "#undef std_io_core_xlang_io_read_fixed\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 164, "#undef std_io_core_xlang_io_write_fixed\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 165, "#undef std_io_core_xlang_io_wait_readable\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 166, "#define std_io_core_xlang_io_register_buffers io_register_buffers_4\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 167, "#define std_io_core_xlang_io_unregister_buffers io_unregister_buffers\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 168, "#define std_io_core_xlang_io_read_fixed xlang_io_read_fixed\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 169, "#define std_io_core_xlang_io_write_fixed xlang_io_write_fixed\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 170, "#define std_io_core_xlang_io_wait_readable io_wait_readable\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 171, "/* codegen 体内调 std_io_driver_io_*；#undef 后重绑到 preamble/io.o 的 io_*。 */\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 172, "#define std_io_driver_io_read_batch_buf io_read_batch_buf\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 173, "#define std_io_driver_io_write_batch_buf io_write_batch_buf\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 174, "#define std_io_driver_io_register_buffers_buf(bufs, nr) io_register_buffers_buf((intptr_t)(void *)(bufs), (int)(nr))\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#include <stdio.h>\n#ifndef __cplusplus\n/* 仅补 co-emit 未定义的符号；勿桩 submit_read / submit_*_batch / subm");
  off = rt_pre_cat(a, off, "it_write（core 强定义）。 */\n__attribute__((weak)) int32_t xlang_io_submit_read_async(uint8_t *ptr, size_t len, si");
  off = rt_pre_cat(a, off, "ze_t handle) {\n  (void)ptr; (void)len; (void)handle; return -1;\n}\n__attribute__((weak)) int32_t xlang_io_read_fixed(size");
  off = rt_pre_cat(a, off, "_t h, uint32_t bi, size_t o, size_t l, uint32_t t) {\n  (void)h;(void)bi;(void)o;(void)l;(void)t; return -1;\n}\n__attribut");
  off = rt_pre_cat(a, off, "e__((weak)) int32_t xlang_io_write_fixed(size_t h, uint32_t bi, size_t o, size_t l, uint32_t t) {\n  (void)h;(void)bi;(vo");
  off = rt_pre_cat(a, off, "id)o;(void)l;(void)t; return -1;\n}\n__attribute__((weak)) int32_t xlang_io_read_ptr_backend(void) { return 0; }\n__attribu");
  off = rt_pre_cat(a, off, "te__((weak)) int io_register_buffers_4(uint8_t *p0, size_t l0, uint8_t *p1, size_t l1, uint8_t *p2, size_t l2, uint8_t *");
  off = rt_pre_cat(a, off, "p3, size_t l3, unsigned nr) {\n  (void)p0;(void)l0;(void)p1;(void)l1;(void)p2;(void)l2;(void)p3;(void)l3;(void)nr; return");
  off = rt_pre_cat(a, off, " -1;\n}\n__attribute__((weak)) int io_wait_readable(int32_t *fds, int n, unsigned timeout_ms) {\n  (void)fds;(void)n;(void)");
  off = rt_pre_cat(a, off, "timeout_ms; return -1;\n}\n__attribute__((weak)) ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bu");
  off = rt_pre_cat(a, off, "fs, int n, unsigned timeout_ms) {\n  (void)fd;(void)bufs;(void)n;(void)timeout_ms; return (ptrdiff_t)-1;\n}\n__attribute__(");
  off = rt_pre_cat(a, off, "(weak)) ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms) {\n  (v");
  off = rt_pre_cat(a, off, "oid)fd;(void)bufs;(void)n;(void)timeout_ms; return (ptrdiff_t)-1;\n}\n__attribute__((weak)) int32_t process_xlang_argc_get");
  off = rt_pre_cat(a, off, "(void) { return 0; }\n__attribute__((weak)) uint8_t *process_xlang_argv_get(int32_t i) { (void)i; return (uint8_t *)0; }\n");
  off = rt_pre_cat(a, off, "__attribute__((weak)) int32_t process_args_count_c(void) { return process_xlang_argc_get(); }\n__attribute__((weak)) uint");
  off = rt_pre_cat(a, off, "8_t *process_arg_c(int32_t i) { return process_xlang_argv_get(i); }\n__attribute__((weak)) int32_t args_iter_count_c(void");
  off = rt_pre_cat(a, off, ") { return process_args_count_c(); }\n__attribute__((weak)) uint8_t *args_iter_at_c(int32_t i) { return process_arg_c(i);");
  off = rt_pre_cat(a, off, " }\n__attribute__((weak)) uint64_t std_io_driver_driver_read_ptr_gen(void) { return 0; }\n__attribute__((weak)) int64_t ct");
  off = rt_pre_cat(a, off, "x_background_c(void) { return 0; }\n__attribute__((weak)) void ctx_cancel_c(int64_t c) { (void)c; }\n__attribute__((weak))");
  off = rt_pre_cat(a, off, " int64_t ctx_deadline_ns_c(int64_t c) { (void)c; return 0; }\n__attribute__((weak)) void ctx_free_c(int64_t c) { (void)c;");
  off = rt_pre_cat(a, off, " }\n__attribute__((weak)) int32_t ctx_get_value_c(int64_t h, uint8_t *key, int64_t *out) {\n  (void)h;(void)key; if (out) ");
  off = rt_pre_cat(a, off, "*out = 0; return 0;\n}\n__attribute__((weak)) int32_t ctx_is_cancelled_c(int64_t c) { (void)c; return 0; }\n__attribute__((");
  off = rt_pre_cat(a, off, "weak)) int64_t ctx_remaining_ns_c(int64_t c) { (void)c; return 0; }\n__attribute__((weak)) int32_t ctx_set_value_c(int64_");
  off = rt_pre_cat(a, off, "t h, uint8_t *key, int64_t value) {\n  (void)h;(void)key;(void)value; return 0;\n}\n__attribute__((weak)) int64_t ctx_with_");
  off = rt_pre_cat(a, off, "cancel_c(int64_t p) { (void)p; return 0; }\n__attribute__((weak)) int64_t ctx_with_deadline_c(int64_t p, int64_t ns) { (v");
  off = rt_pre_cat(a, off, "oid)p;(void)ns; return 0; }\n__attribute__((weak)) int64_t ctx_with_timeout_c(int64_t p, int64_t ns) { (void)p;(void)ns; ");
  off = rt_pre_cat(a, off, "return 0; }\n#endif\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 175, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 176, "struct std_net_Ipv4Addr { uint8_t a; uint8_t b; uint8_t c; uint8_t d; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 177, "struct std_net_Ipv6Addr { uint8_t b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 178, "#define handle_from_fd std_io_handle_from_fd\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 179, "#define submit_read_batch_buf std_io_submit_read_batch_buf\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 180, "#define submit_write_batch_buf std_io_submit_write_batch_buf\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 181, "#define read_fixed_fd(x, a, b, c, d) std_io_read_fixed_fd_impl(xlang_io_net_fd(x), a, b, c, d)\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 182, "#define write_fixed_fd(x, a, b, c, d) std_io_write_fixed_fd_impl(xlang_io_net_fd(x), a, b, c, d)\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "/* 实际符号用 _real；仅定义 std_net_net_* 宏。\n * 【Why 勿 #define net_close_socket_c / net_run_accept_work");
  off = rt_pre_cat(a, off, "ers_c】\n * link_only 路径会 emit `extern int32_t net_close_socket_c(...)`；\n * 若宏同名，extern 声明被展");
  off = rt_pre_cat(a, off, "开 → expected parameter declarator。 */\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 183, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 184, "extern int32_t net_close_socket_c_real(int32_t fd);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 185, "extern int32_t net_run_accept_workers_c_real(int32_t listener_fd, int32_t n_workers, uint32_t timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 186, "extern int32_t net_close_socket_c(int32_t fd);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 187, "extern int32_t net_run_accept_workers_c(int32_t listener_fd, int32_t n_workers, uint32_t timeout_ms);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 188, "#define std_net_net_close_socket_c(x) net_close_socket_c_real(xlang_io_net_fd(x))\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 189, "#define std_net_net_run_accept_workers_c(x, n, t) net_run_accept_workers_c_real(xlang_io_net_fd(x), n, t)\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#define STD_FS_FS_IOVEC_BUF_DEFINED\nstruct std_fs_FsIovecBuf { void *ptr; size_t length; size_t handle; };\n#define std_f");
  off = rt_pre_cat(a, off, "s_posix_FsIovecBuf std_fs_FsIovecBuf\nstruct std_io_sync_Iovec { uint8_t *base; size_t length; };\n#define std_fs_posix_Io");
  off = rt_pre_cat(a, off, "vec std_io_sync_Iovec\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 190, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 191, "struct std_map_Map_i32_i32;\n");
  }
  return off;
}

/** Fill io_net rows 192..217. PLATFORM: SHARED. */
function rt_pre_io_net_fill_5(t: *u8, a: *u8, off0: i64): i64 {
  let off: i64 = off0;
  let s: i64 = 0;
  unsafe {
    xlang_ptr_slot_set(t, 192, "typedef struct std_io_driver_Buffer std_net_Buffer;\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 193, "struct std_error_Error { int32_t code; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 194, "struct std_error_ErrorChain { int32_t depth; int32_t c0; int32_t c1; int32_t c2; int32_t c3; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 195, "struct std_string_String { uint8_t data[256]; int32_t length; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 196, "typedef struct std_string_String String;\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 197, "struct std_string_StrView { uint8_t *ptr; int32_t length; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 198, "struct std_heap_Arena64 { uint8_t *chunk; size_t cap; size_t off; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 199, "struct std_heap_Allocator { int32_t kind; struct std_heap_Arena64 *arena; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 200, "struct std_vec_Vec_i32;\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 201, "struct core_option_Option_i32 { int is_some; int32_t value; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 202, "struct core_option_Option_u8 { int is_some; uint8_t value; uint8_t _pad0; uint8_t _pad1; uint8_t _pad2; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 203, "struct core_option_Option_u64 { int is_some; int32_t _pad; uint64_t value; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 204, "struct core_option_Option_ptr_u8 { int is_some; int32_t _pad; uint8_t *value; };\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 205, "struct core_result_Result_i32 { int32_t value; int32_t _pad1; int32_t err; int32_t _pad2; };\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "struct core_result_Result_u8 { uint8_t value; uint8_t _pad1; uint8_t _pad2; uint8_t _pad3; int32_t err; int32_t _pad4; }");
  off = rt_pre_cat(a, off, ";\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 206, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 207, "extern void xlang_panic_(int, intptr_t);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 208, "extern int32_t core_types_placeholder(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 209, "extern int32_t std_heap_alloc_size_zero(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 210, "extern int32_t std_runtime_runtime_ready(void);\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#ifndef __cplusplus\n__attribute__((weak)) int32_t std_vec_vec_len_empty(void) { return 0; }\n__attribute__((weak)) int32_");
  off = rt_pre_cat(a, off, "t std_vec_len_empty(void) { return 0; }\n#else\nextern int32_t std_vec_vec_len_empty(void);\nextern int32_t std_vec_len_emp");
  off = rt_pre_cat(a, off, "ty(void);\n#endif\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 211, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 212, "#define vec_len_empty std_vec_vec_len_empty\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 213, "#define alloc_size_zero std_heap_alloc_size_zero\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 214, "#define runtime_ready std_runtime_runtime_ready\n");
  }
  s = off;
  off = rt_pre_cat(a, off, "#ifndef __cplusplus\n__attribute__((weak)) int32_t std_string_placeholder(void) { return 0; }\n#else\nextern int32_t std_st");
  off = rt_pre_cat(a, off, "ring_placeholder(void);\n#endif\n");
  off = off + 1;
  unsafe {
    xlang_ptr_slot_set(t, 215, (a as i64 + s) as *u8);
  }
  unsafe {
    xlang_ptr_slot_set(t, 216, "extern int32_t fmt_i32(int32_t);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 217, "extern struct std_string_String std_string_string_new(void);\n");
  }
  return off;
}

/** Fill fs_path rows 0..20. PLATFORM: SHARED. */
function rt_pre_fs_path_fill_0(t: *u8, a: *u8, off0: i64): i64 {
  let off: i64 = off0;
  let s: i64 = 0;
  unsafe {
    xlang_ptr_slot_set(t, 0, "typedef struct std_fs_FsIovecBuf fs_iovec_buf_t;\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 1, "extern int32_t fs_open_read_c(uint8_t *path);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 2, "extern uint64_t fs_direct_align_c(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 3, "extern int32_t fs_fadvise_sequential_c(int32_t fd);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 4, "extern int32_t fs_fadvise_willneed_c(int32_t fd, int64_t offset, size_t len);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 5, "extern int64_t fs_copy_file_range_c(int32_t fd_in, int32_t fd_out, size_t len);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 6, "extern int64_t fs_sendfile_c(int32_t out_fd, int32_t in_fd, size_t count);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 7, "extern int64_t fs_pipe_splice_c(int32_t fd_in, int32_t fd_out, size_t len);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 8, "extern int32_t fs_sync_range_c(int32_t fd, int64_t offset, size_t len);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 9, "extern int32_t fs_sync_c(int32_t fd);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 10, "extern int32_t fs_fallocate_c(int32_t fd, int64_t offset, int64_t len);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 11, "extern int32_t fs_last_error_c(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 12, "extern int64_t fs_readv_buf_c(int32_t fd, const fs_iovec_buf_t *bufs, int n);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 13, "extern int64_t fs_writev_buf_c(int32_t fd, const fs_iovec_buf_t *bufs, int n);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 14, "extern int32_t std_path_empty_len(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 15, "#define empty_len() std_path_empty_len()\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 16, "extern int32_t map_i32_i32_find_c(int32_t *keys, uint8_t *occupied, int32_t cap, int32_t key);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 17, "extern int32_t std_map_empty_size(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 18, "#define empty_size(_a, _b) std_map_empty_size()\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 19, "extern int32_t std_error_error_ok(void);\n");
  }
  unsafe {
    xlang_ptr_slot_set(t, 20, "#define error_ok(_a, _b) std_error_error_ok()\n");
  }
  return off;
}

/**
 * Fill both tables once. Slot 0 of each table is non-null after a fill.
 * The two writers are the only readers (through line_at), and both call
 * this first. Long rows live in rt_pre_arena (BSS, already zero, so each
 * row keeps its NUL). PLATFORM: SHARED.
 */
function rt_pre_tables_ready(): void {
  let io: *u8 = &driver_preamble_io_net_lines as *u8;
  let fs: *u8 = &driver_preamble_fs_path_lines as *u8;
  let a: *u8 = &rt_pre_arena as *u8;
  let off: i64 = 0;
  let p: *u8 = 0 as *u8;
  unsafe {
    p = xlang_ptr_slot_get(io, 0);
  }
  if (p == 0 as *u8) {
    off = rt_pre_io_net_fill_0(io, a, off);
    off = rt_pre_io_net_fill_1(io, a, off);
    off = rt_pre_io_net_fill_2(io, a, off);
    off = rt_pre_io_net_fill_3(io, a, off);
    off = rt_pre_io_net_fill_4(io, a, off);
    off = rt_pre_io_net_fill_5(io, a, off);
  }
  off = 28114;
  unsafe {
    p = xlang_ptr_slot_get(fs, 0);
  }
  if (p == 0 as *u8) {
    off = rt_pre_fs_path_fill_0(fs, a, off);
  }
}

/**
 * Write std.io / std.net Cap-giant-string ABI lines into an opaque FILE* stream.
 * Honors codegen_get_preamble_skip_mask so co-emit of std.io.core / std.io.driver
 * does not redefine macros or weak stubs already emitted in the same TU.
 * @param cf *u8 — opaque FILE* (must be non-null open write stream)
 * @return i32 — 0 on success; 1 if any fputs fails (EOF or a bad handle)
 * PLATFORM: SHARED — sole definition. Skip ranges are 60..63 (handle),
 * 64..81 (core macros), 105..118 (undef/rebind), and 178..181 (weak IO).
 */
#[no_mangle]
export function write_io_net_abi_inline(cf: *u8): i32 {
  let skip: i32 = 0;
  let n: i32 = 0;
  let i: i32 = 0;
  rt_pre_tables_ready();
  unsafe {
    skip = codegen_get_preamble_skip_mask();
  }
  // w1495: the real io_net row count. driver_preamble_io_net_line_count()
  // still returns the stale 224 from runtime_driver_abi.
  n = 218;
  while (i < n) {
    let skip_line: i32 = 0;
    // DRIVER_HANDLE aliases: skip when codegen already emitted handle_stdin etc.
    if ((skip & 2) != 0) {
      if (i >= 60) {
        if (i < 64) {
          skip_line = 1;
        }
      }
    }
    // CORE_MACROS: std_io_core_io_* map macros when core is not co-emitted.
    if ((skip & 1) != 0) {
      if (i >= 64) {
        if (i < 82) {
          skip_line = 1;
        }
      }
    }
    // UNDEF_REDEFINE: #undef / rebind block when X inlines std.io.core.
    if ((skip & 4) != 0) {
      if (i >= 105) {
        if (i < 119) {
          skip_line = 1;
        }
      }
    }
    // WEAK_IO_BATCH (wave29): rows 178..181 = stdio guard + weak xlang_io_* /
    // process_xlang_* / std_io_driver_* / ctx_* (#include..#endif). Co-emit of
    // std.io.driver supplies strong defs; same-TU weak would redef.
    if ((skip & 8) != 0) {
      if (i >= 178) {
        if (i <= 181) {
          skip_line = 1;
        }
      }
    }
    if (skip_line == 0) {
      let line: *u8 = 0 as *u8;
      let rc: i32 = 0;
      unsafe {
        line = driver_preamble_io_net_line_at(i);
        rc = driver_preamble_fputs(line, cf);
      }
      // driver_preamble_fputs returns libc fputs result; EOF is negative.
      if (rc < 0) {
        return 1;
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Write std.fs / std.path / std.map / std.error Cap-giant-string ABI lines.
 * No skip mask today (full table always emitted).
 * @param cf *u8 — opaque FILE* (must be non-null open write stream)
 * @return i32 — 0 on success; 1 if any fputs fails (EOF or a bad handle)
 * PLATFORM: SHARED — sole definition. Every table row is written.
 */
#[no_mangle]
export function write_fs_path_map_error_abi_inline(cf: *u8): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  rt_pre_tables_ready();
  unsafe {
    n = driver_preamble_fs_path_line_count();
  }
  while (i < n) {
    let line: *u8 = 0 as *u8;
    let rc: i32 = 0;
    unsafe {
      line = driver_preamble_fs_path_line_at(i);
      rc = driver_preamble_fputs(line, cf);
    }
    if (rc < 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Slice presence marker for this translation unit.
 * Returns 1, the same value the former host-cc marker returned.
 * No product caller reads it. The ensure nm gate only checks the symbol exists.
 * @return i32 — always 1
 * PLATFORM: SHARED — pure asm. The string tables are in this file too (w1495).
 */
#[no_mangle]
export function labi_rt_preamble_slice_marker(): i32 {
  return 1;
}
