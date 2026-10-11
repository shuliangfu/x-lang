// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_dir_cap_linux.x — Linux x86_64 body of the directory cap merged
// into std/fs/fs.o. Same contract as the Linux half of xlang_dir_cap.h:
// open(O_RDONLY|O_DIRECTORY) + getdents64 into a heap stream, then a
// glibc-layout dirent whose d_name sits 19 bytes in. This compiler emits
// that as the raw_syscall builtin (syscall instruction). It does not
// include the C header, so the numbers below are the x86_64 values from
// that header and must stay equal to it:
//   open = 2, close = 3, getdents64 = 217, O_DIRECTORY = 65536
//   (O_RDONLY is 0, so the flag word is 65536, one literal).
// The stream is 320 bytes, matching
//   int fd; pad; buf*; cap; len; pos; glibc dirent
// where the dirent is 8+8+2+1+256 = 275, rounded to 8 → 280, plus the
// 40-byte header. A regular file open returns a negative fd and this
// face returns null. Windows keeps seeds/runtime_dir_cap.from_x.c.
// Helpers are global text; names start with xlang_dcap_ so they do not
// collide after ld -r. A raw_syscall call stays in its own function:
// locals after that builtin in the same body land outside the frame.
// PLATFORM: LINUX x86_64.

extern function raw_syscall3(nr: i64, a1: i64, a2: i64, a3: i64): i64;
extern function raw_syscall1(nr: i64, a1: i64): i64;
extern "C" function __errno_location(): i64;
extern "C" function calloc(n: u64, sz: u64): *u8;
extern "C" function malloc(n: u64): *u8;
extern "C" function free(p: *u8): void;
extern "C" function memcpy(dst: *u8, src: *u8, n: u64): *u8;

/**
 * Copy 4 bytes out of the stream into an i32.
 * @param p source address
 * @return i32 — the stored value
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_load_i32(p: *u8): i32 {
  let v: i32 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 4);
  }
  return v;
}

/**
 * Copy an i32 into the stream.
 * @param p destination address
 * @param v value to store
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_store_i32(p: *u8, v: i32): void {
  let x: i32 = v;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 4);
  }
}

/**
 * Copy 8 bytes out of the stream into a u64.
 * @param p source address
 * @return u64 — the stored value
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_load_u64(p: *u8): u64 {
  let v: u64 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 8);
  }
  return v;
}

/**
 * Copy a u64 into the stream.
 * @param p destination address
 * @param v value to store
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_store_u64(p: *u8, v: u64): void {
  let x: u64 = v;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 8);
  }
}

/**
 * Copy a pointer into the stream.
 * @param p destination address
 * @param v pointer to store
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_store_ptr(p: *u8, v: *u8): void {
  let x: *u8 = v;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 8);
  }
}

/**
 * Load a pointer from the stream.
 * @param p source address
 * @return i64 — pointer bits in rax
 * PLATFORM: LINUX x86_64 — this product cannot asm-emit a *u8 return.
 */
function xlang_dcap_load_ptr(p: *u8): i64 {
  let v: *u8 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 8);
  }
  return v as i64;
}

/**
 * Read one byte. The index is the constant 0 after advancing the pointer,
 * because a parameter used as a subscript is emitted as an extra load.
 * @param p address of the byte
 * @return i32 — the byte in eax
 * PLATFORM: LINUX x86_64 — this product cannot asm-emit a u8 return.
 */
function xlang_dcap_load_u8(p: *u8): i32 {
  return p[0] as i32;
}

/**
 * Pack two bytes into a little-endian u16.
 * Split from the loads so neither function stores at the frame edge.
 * @param lo low byte
 * @param hi high byte
 * @return i32 — lo + (hi << 8), low 16 bits
 * PLATFORM: LINUX x86_64 — this product cannot asm-emit a u16 return.
 */
function xlang_dcap_u16_pack(lo: i32, hi: i32): i32 {
  return lo + (hi << 8);
}

/**
 * Little-endian u16 from two bytes. d_reclen is not always 2-aligned
 * inside a packed dirent, so this does not use a halfword load.
 * @param p address of the first byte
 * @return i32 — the value in eax
 * PLATFORM: LINUX x86_64 — this product cannot asm-emit a u16 return.
 */
function xlang_dcap_load_u16(p: *u8): i32 {
  let p1: *u8 = p + 1;
  let b0: i32 = xlang_dcap_load_u8(p);
  let b1: i32 = xlang_dcap_load_u8(p1);
  return xlang_dcap_u16_pack(b0, b1);
}

/**
 * Linux x86_64 syscall with three arguments. No locals after the builtin.
 * @param nr syscall number
 * @param a1 first argument
 * @param a2 second argument
 * @param a3 third argument
 * @return i64 — raw kernel return in rax (-errno on failure)
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_sys3(nr: i64, a1: i64, a2: i64, a3: i64): i64 {
  unsafe {
    return raw_syscall3(nr, a1, a2, a3);
  }
  return 0;
}

/**
 * Linux x86_64 syscall with one argument. No locals after the builtin.
 * @param nr syscall number
 * @param a1 first argument
 * @return i64 — raw kernel return in rax (-errno on failure)
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_sys1(nr: i64, a1: i64): i64 {
  unsafe {
    return raw_syscall1(nr, a1);
  }
  return 0;
}

/**
 * Pointer bits of glibc errno.
 * @return i64 — __errno_location() in rax
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_errno_ptr(): i64 {
  unsafe {
    return __errno_location();
  }
  return 0;
}

/**
 * Map a raw kernel return. Negative values become -1 and set errno.
 * @param r raw syscall result
 * @return i64 — r, or -1 after storing -r into errno
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_map_err(r: i64): i64 {
  if r < 0 {
    let neg: i64 = 0 - r;
    let e: i32 = neg as i32;
    let ep: i64 = xlang_dcap_errno_ptr();
    let p: *u8 = ep as *u8;
    xlang_dcap_store_i32(p, e);
    return 0 - 1;
  }
  return r;
}

/**
 * open(2) of a directory. Flag word is O_DIRECTORY (65536); O_RDONLY is 0.
 * @param path NUL-terminated path
 * @return i32 — fd, or -1
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_open_dir(path: *u8): i32 {
  let p: i64 = path as i64;
  let nr: i64 = 2;
  let flags: i64 = 65536;
  let mode: i64 = 0;
  let r: i64 = xlang_dcap_sys3(nr, p, flags, mode);
  let m: i64 = xlang_dcap_map_err(r);
  return m as i32;
}

/**
 * close(2). The caller ignores the result, matching xlang_dir_close.
 * @param fd descriptor from xlang_dcap_open_dir
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_close_fd(fd: i32): void {
  let nr: i64 = 3;
  let a1: i64 = fd as i64;
  xlang_dcap_sys1(nr, a1);
}

/**
 * getdents64(2). Zero is EOF. Negative becomes -1 and sets errno.
 * @param fd directory descriptor
 * @param buf destination buffer
 * @param cap buffer size in bytes
 * @return i64 — bytes read, 0 at EOF, -1 on error
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_getdents(fd: i32, buf: *u8, cap: u64): i64 {
  let nr: i64 = 217;
  let a1: i64 = fd as i64;
  let a2: i64 = buf as i64;
  let a3: i64 = cap as i64;
  let r: i64 = xlang_dcap_sys3(nr, a1, a2, a3);
  if r < 0 {
    return xlang_dcap_map_err(r);
  }
  return r;
}

/**
 * Copy a directory name, stopping at NUL or at lim, and write a NUL.
 * lim is capped at 255 so the 256-byte glibc name slot always holds the
 * terminator. One-byte memcpy avoids a variable-index store.
 * @param dst name slot inside the glibc dirent
 * @param src kernel d_name
 * @param lim maximum bytes to consider, not counting the stored NUL
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_copy_name(dst: *u8, src: *u8, lim: i32): void {
  let n: i32 = 0;
  let capn: i32 = lim;
  if capn > 255 {
    capn = 255;
  }
  if capn < 0 {
    capn = 0;
  }
  while n < capn {
    let b: i32 = xlang_dcap_load_u8(src);
    if b == 0 {
      break;
    }
    unsafe { memcpy(dst, src, 1); }
    dst = dst + 1;
    src = src + 1;
    n = n + 1;
  }
  let z: i32 = 0;
  unsafe {
    let zp: *u8 = &z as *u8;
    memcpy(dst, zp, 1);
  }
}

/**
 * Copy one kernel dirent64 into the glibc-layout slot at stream+40.
 * d_name in that slot begins at byte 19. The kernel and glibc prefixes
 * share ino, off, reclen, and type, so the first 19 bytes are copied
 * and the name is repacked into the fixed 256-byte array.
 * @param dirp stream
 * @param entp kernel record
 * @param reclen kernel d_reclen, already checked to be at least 20
 * @return i64 — pointer bits of the glibc dirent
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_store_ent(dirp: *u8, entp: *u8, reclen: i32): i64 {
  let dest: *u8 = dirp + 40;
  unsafe { memcpy(dest, entp, 16); }
  let reclen_src: *u8 = entp + 16;
  let reclen_dst: *u8 = dest + 16;
  unsafe { memcpy(reclen_dst, reclen_src, 2); }
  let type_src: *u8 = entp + 18;
  let type_dst: *u8 = dest + 18;
  unsafe { memcpy(type_dst, type_src, 1); }
  let name_src: *u8 = entp + 19;
  let name_dst: *u8 = dest + 19;
  let name_lim: i32 = reclen - 19;
  xlang_dcap_copy_name(name_dst, name_src, name_lim);
  return dest as i64;
}

/**
 * Anchor for this Linux directory object.
 * @return i32 — always 0
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function runtime_dir_cap_linux_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Open a directory. Empty path and regular files return null.
 * The stream is 320 bytes. The buffer is 8192 bytes.
 * @param name NUL-terminated path
 * @return i64 — stream pointer bits in rax, or 0
 * PLATFORM: LINUX x86_64 — this product cannot asm-emit a *u8 return.
 */
#[no_mangle]
export function xlang_dir_opendir(name: *u8): i64 {
  if name == 0 {
    return 0;
  }
  if xlang_dcap_load_u8(name) == 0 {
    return 0;
  }
  unsafe {
    let one: u64 = 1;
    let bytes: u64 = 320;
    let d: *u8 = calloc(one, bytes);
    if d == 0 {
      return 0;
    }
    let fd: i32 = xlang_dcap_open_dir(name);
    if fd < 0 {
      free(d);
      return 0;
    }
    xlang_dcap_store_i32(d, fd);
    let cap: u64 = 8192;
    let buf: *u8 = malloc(cap);
    if buf == 0 {
      xlang_dcap_close_fd(fd);
      free(d);
      return 0;
    }
    let buf_slot: *u8 = d + 8;
    xlang_dcap_store_ptr(buf_slot, buf);
    let cap_slot: *u8 = d + 16;
    xlang_dcap_store_u64(cap_slot, cap);
    return d as i64;
  }
  return 0;
}

/**
 * True when the buffered window still has bytes.
 * @param dirp stream
 * @return i32 — 1 when pos is before len
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_pos_before_len(dirp: *u8): i32 {
  let pos_slot: *u8 = dirp + 32;
  let len_slot: *u8 = dirp + 24;
  let pos: u64 = xlang_dcap_load_u64(pos_slot);
  let len: u64 = xlang_dcap_load_u64(len_slot);
  if pos < len {
    return 1;
  }
  return 0;
}

/**
 * Refill the 8192-byte window. One getdents64 call.
 * @param dirp stream
 * @param fd directory descriptor
 * @return i32 — 1 when bytes arrived, 0 at EOF or error
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_fill(dirp: *u8, fd: i32): i32 {
  let buf_slot: *u8 = dirp + 8;
  let cap_slot: *u8 = dirp + 16;
  let buf: *u8 = xlang_dcap_load_ptr(buf_slot) as *u8;
  let cap: u64 = xlang_dcap_load_u64(cap_slot);
  let nr: i64 = xlang_dcap_getdents(fd, buf, cap);
  if nr <= 0 {
    return 0;
  }
  let nru: u64 = nr as u64;
  let len_slot: *u8 = dirp + 24;
  let pos_slot: *u8 = dirp + 32;
  xlang_dcap_store_u64(len_slot, nru);
  let zero: u64 = 0;
  xlang_dcap_store_u64(pos_slot, zero);
  return 1;
}

/**
 * Consume one kernel record at the current position.
 * Returns the stream pointer itself when the name is empty (skip).
 * Returns null when d_reclen is too small to hold a name.
 * @param dirp stream
 * @return i64 — glibc dirent, the stream (skip), or 0
 * PLATFORM: LINUX x86_64
 */
function xlang_dcap_parse(dirp: *u8): i64 {
  let pos_slot: *u8 = dirp + 32;
  let pos: u64 = xlang_dcap_load_u64(pos_slot);
  let buf_slot: *u8 = dirp + 8;
  let buf: *u8 = xlang_dcap_load_ptr(buf_slot) as *u8;
  let pos_i: i32 = pos as i32;
  let entp: *u8 = buf + pos_i;
  let reclen_p: *u8 = entp + 16;
  let reclen: i32 = xlang_dcap_load_u16(reclen_p);
  if reclen < 20 {
    return 0;
  }
  let step: u64 = reclen as u64;
  let next: u64 = pos + step;
  xlang_dcap_store_u64(pos_slot, next);
  let name_p: *u8 = entp + 19;
  let name0: i32 = xlang_dcap_load_u8(name_p);
  if name0 == 0 {
    return dirp as i64;
  }
  return xlang_dcap_store_ent(dirp, entp, reclen);
}

/**
 * Read the next dirent. Skips records whose name is empty.
 * The returned pointer is the stream's glibc dirent (offset 40).
 * d_name begins 19 bytes later. Valid until the next read or close.
 * The loop only calls helpers. A single function that both refills and
 * parses writes past its frame and corrupts the caller.
 * @param dirp stream from xlang_dir_opendir
 * @return i64 — dirent pointer bits in rax, or 0
 * PLATFORM: LINUX x86_64 — this product cannot asm-emit a *u8 return.
 */
#[no_mangle]
export function xlang_dir_readdir(dirp: *u8): i64 {
  if dirp == 0 {
    return 0;
  }
  let fd: i32 = xlang_dcap_load_i32(dirp);
  if fd < 0 {
    return 0;
  }
  while 1 == 1 {
    if xlang_dcap_pos_before_len(dirp) == 0 {
      if xlang_dcap_fill(dirp, fd) == 0 {
        return 0;
      }
    }
    let got: *u8 = xlang_dcap_parse(dirp) as *u8;
    if got == 0 {
      return 0;
    }
    if got != dirp {
      return got as i64;
    }
  }
  return 0;
}

/**
 * Close the stream and free the buffer. Null returns -1.
 * @param dirp stream from xlang_dir_opendir
 * @return i32 — 0, or -1 when dirp is null
 * PLATFORM: LINUX x86_64
 */
#[no_mangle]
export function xlang_dir_closedir(dirp: *u8): i32 {
  if dirp == 0 {
    return 0 - 1;
  }
  let fd: i32 = xlang_dcap_load_i32(dirp);
  if fd >= 0 {
    xlang_dcap_close_fd(fd);
  }
  let buf_slot: *u8 = dirp + 8;
  let buf: *u8 = xlang_dcap_load_ptr(buf_slot) as *u8;
  unsafe {
    free(buf);
    free(dirp);
  }
  return 0;
}

/**
 * Next entry's name. The pointer is 19 bytes into the dirent returned
 * by xlang_dir_readdir, and stays valid until the next read or close.
 * @param dirp stream from xlang_dir_opendir
 * @return i64 — name pointer bits in rax, or 0
 * PLATFORM: LINUX x86_64 — this product cannot asm-emit a *u8 return.
 */
#[no_mangle]
export function xlang_dir_readdir_name_c(dirp: *u8): i64 {
  let ent: *u8 = xlang_dir_readdir(dirp) as *u8;
  if ent == 0 {
    return 0;
  }
  return (ent + 19) as i64;
}
