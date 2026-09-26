// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// runtime_dir_cap_darwin.x — Darwin arm64 body of runtime_dir_cap.o.
//
// xlang_dir_cap.h walks directories with raw svc #0x80. This compiler
// cannot emit that instruction. __open and __getdirentries64 are the
// libSystem spellings of the same open and SYS_getdirentries64 (344).
// The extern names use three leading underscores so the Mach-O undefined
// symbol matches (same rule as ___atomic_load_4).
// O_RDONLY|O_DIRECTORY is 1048576 (0x100000). A regular file open returns
// a negative fd and this face returns null, matching opendir.
// The heap stream is 1096 bytes: fd at 0, buf at 8, cap at 16, len at 24,
// pos at 32, basep at 40, dirent at 48. d_name is 21 bytes into that
// dirent. Linux and Windows keep the C seed.
// PLATFORM: MACOS|DARWIN arm64.

extern function ___open(path: *u8, flags: i32, mode: i32): i32;
extern function ___getdirentries64(fd: i32, buf: *u8, nbytes: u64, basep: *u8): i32;
extern function close(fd: i32): i32;
extern function calloc(n: u64, sz: u64): *u8;
extern function malloc(n: u64): *u8;
extern function free(p: *u8): void;
extern function memcpy(dst: *u8, src: *u8, n: u64): *u8;

/**
 * Copy 4 bytes out of the stream into an i32.
 * @param p source address
 * @return i32 — the stored value
 * PLATFORM: MACOS|DARWIN
 */
function dir_load_i32(p: *u8): i32 {
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
 * PLATFORM: MACOS|DARWIN
 */
function dir_store_i32(p: *u8, v: i32): void {
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
 * PLATFORM: MACOS|DARWIN
 */
function dir_load_u64(p: *u8): u64 {
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
 * PLATFORM: MACOS|DARWIN
 */
function dir_store_u64(p: *u8, v: u64): void {
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
 * PLATFORM: MACOS|DARWIN
 */
function dir_store_ptr(p: *u8, v: *u8): void {
  let x: *u8 = v;
  unsafe {
    let src: *u8 = &x as *u8;
    memcpy(p, src, 8);
  }
}

/**
 * Load a pointer from the stream.
 * @param p source address
 * @return *u8 — the stored pointer
 * PLATFORM: MACOS|DARWIN
 */
function dir_load_ptr(p: *u8): *u8 {
  let v: *u8 = 0;
  unsafe {
    let dst: *u8 = &v as *u8;
    memcpy(dst, p, 8);
  }
  return v;
}

/**
 * Read one byte. The index is the constant 0 after advancing the pointer,
 * because a parameter used as a subscript is emitted as an extra load.
 * @param p address of the byte
 * @return u8 — that byte
 * PLATFORM: MACOS|DARWIN
 */
function dir_load_u8(p: *u8): u8 {
  return p[0];
}

/**
 * Pack two bytes into a little-endian u16.
 * Split from the loads so neither function stores at the frame edge.
 * @param lo low byte
 * @param hi high byte
 * @return u16 — lo + (hi << 8)
 * PLATFORM: MACOS|DARWIN
 */
function dir_u16_pack(lo: i32, hi: i32): u16 {
  return (lo + (hi << 8)) as u16;
}

/**
 * Little-endian u16 from two bytes. d_reclen is not always 2-aligned
 * inside a packed dirent, so this does not use a halfword load.
 * @param p address of the first byte
 * @return u16 — the value
 * PLATFORM: MACOS|DARWIN
 */
function dir_load_u16(p: *u8): u16 {
  let p1: *u8 = p + 1;
  let b0: u8 = dir_load_u8(p);
  let b1: u8 = dir_load_u8(p1);
  return dir_u16_pack(b0 as i32, b1 as i32);
}

/**
 * Anchor for this Darwin directory object.
 * @return i32 — always 0
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function runtime_dir_cap_darwin_x_doc_anchor(): i32 {
  return 0;
}

/**
 * Open a directory. Empty path and regular files return null.
 * The stream is 1096 bytes. The buffer is 8192 bytes.
 * @param name NUL-terminated path
 * @return *u8 — opaque stream, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_dir_opendir(name: *u8): *u8 {
  if name == 0 {
    return 0;
  }
  if dir_load_u8(name) == 0 {
    return 0;
  }
  unsafe {
    let one: u64 = 1;
    let bytes: u64 = 1096;
    let d: *u8 = calloc(one, bytes);
    if d == 0 {
      return 0;
    }
    let flags: i32 = 1048576;
    let fd: i32 = ___open(name, flags, 0);
    if fd < 0 {
      free(d);
      return 0;
    }
    dir_store_i32(d, fd);
    let cap: u64 = 8192;
    let buf: *u8 = malloc(cap);
    if buf == 0 {
      close(fd);
      free(d);
      return 0;
    }
    let buf_slot: *u8 = d + 8;
    dir_store_ptr(buf_slot, buf);
    let cap_slot: *u8 = d + 16;
    dir_store_u64(cap_slot, cap);
    return d;
  }
  return 0;
}

/**
 * True when the buffered window still has bytes.
 * @param dirp stream
 * @return i32 — 1 when pos is before len
 * PLATFORM: MACOS|DARWIN
 */
function dir_pos_before_len(dirp: *u8): i32 {
  let pos_slot: *u8 = dirp + 32;
  let len_slot: *u8 = dirp + 24;
  let pos: u64 = dir_load_u64(pos_slot);
  let len: u64 = dir_load_u64(len_slot);
  if pos < len {
    return 1;
  }
  return 0;
}

/**
 * Refill the 8192-byte window. One getdirentries64 call.
 * @param dirp stream
 * @param fd directory descriptor
 * @return i32 — 1 when bytes arrived, 0 at EOF or error
 * PLATFORM: MACOS|DARWIN
 */
function dir_fill(dirp: *u8, fd: i32): i32 {
  let buf_slot: *u8 = dirp + 8;
  let cap_slot: *u8 = dirp + 16;
  let buf: *u8 = dir_load_ptr(buf_slot);
  let cap: u64 = dir_load_u64(cap_slot);
  let basep: *u8 = dirp + 40;
  unsafe {
    let nr: i32 = ___getdirentries64(fd, buf, cap, basep);
    if nr <= 0 {
      return 0;
    }
    let nru: u64 = nr as u64;
    let len_slot: *u8 = dirp + 24;
    let pos_slot: *u8 = dirp + 32;
    dir_store_u64(len_slot, nru);
    let zero: u64 = 0;
    dir_store_u64(pos_slot, zero);
  }
  return 1;
}

/**
 * Consume one record at the current position.
 * Returns the stream pointer itself when the record must be skipped
 * (inode 0 or empty name). Returns null when d_reclen is 0.
 * @param dirp stream
 * @return *u8 — dirent, the stream (skip), or null
 * PLATFORM: MACOS|DARWIN
 */
function dir_parse(dirp: *u8): *u8 {
  let pos_slot: *u8 = dirp + 32;
  let pos: u64 = dir_load_u64(pos_slot);
  let buf_slot: *u8 = dirp + 8;
  let buf: *u8 = dir_load_ptr(buf_slot);
  let pos_i: i32 = pos as i32;
  let entp: *u8 = buf + pos_i;
  let reclen_p: *u8 = entp + 16;
  let reclen: u16 = dir_load_u16(reclen_p);
  if reclen == 0 {
    return 0;
  }
  let ino: u64 = dir_load_u64(entp);
  let name_p: *u8 = entp + 21;
  let name0: u8 = dir_load_u8(name_p);
  let step: u64 = reclen as u64;
  let next: u64 = pos + step;
  dir_store_u64(pos_slot, next);
  if ino == 0 || name0 == 0 {
    return dirp;
  }
  let dest: *u8 = dirp + 48;
  let ncopy: u64 = step;
  if ncopy > 1048 {
    ncopy = 1048;
  }
  unsafe { memcpy(dest, entp, ncopy); }
  let term: *u8 = dirp + 1092;
  term[0] = 0;
  return dest;
}

/**
 * Read the next dirent. Skips records whose inode is 0 or whose name
 * is empty. The returned pointer is the stream's dirent slot (offset 48).
 * d_name begins 21 bytes later. Valid until the next read or close.
 * The loop only calls helpers. A single function that both refills and
 * parses writes past its frame and corrupts the caller.
 * @param dirp stream from xlang_dir_opendir
 * @return *u8 — dirent, or null at end
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_dir_readdir(dirp: *u8): *u8 {
  if dirp == 0 {
    return 0;
  }
  let fd: i32 = dir_load_i32(dirp);
  if fd < 0 {
    return 0;
  }
  while 1 == 1 {
    if dir_pos_before_len(dirp) == 0 {
      if dir_fill(dirp, fd) == 0 {
        return 0;
      }
    }
    let got: *u8 = dir_parse(dirp);
    if got == 0 {
      return 0;
    }
    if got != dirp {
      return got;
    }
  }
  return 0;
}

/**
 * Close the stream and free the buffer. Null returns -1.
 * @param dirp stream from xlang_dir_opendir
 * @return i32 — 0, or -1 when dirp is null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_dir_closedir(dirp: *u8): i32 {
  if dirp == 0 {
    return 0 - 1;
  }
  let fd: i32 = dir_load_i32(dirp);
  if fd >= 0 {
    unsafe { close(fd); }
  }
  let buf_slot: *u8 = dirp + 8;
  let buf: *u8 = dir_load_ptr(buf_slot);
  unsafe {
    free(buf);
    free(dirp);
  }
  return 0;
}

/**
 * Next entry's name. The pointer is 21 bytes into the dirent returned
 * by xlang_dir_readdir, and stays valid until the next read or close.
 * @param dirp stream from xlang_dir_opendir
 * @return *u8 — name, or null
 * PLATFORM: MACOS|DARWIN
 */
#[no_mangle]
export function xlang_dir_readdir_name_c(dirp: *u8): *u8 {
  let ent: *u8 = xlang_dir_readdir(dirp);
  if ent == 0 {
    return 0;
  }
  return ent + 21;
}
