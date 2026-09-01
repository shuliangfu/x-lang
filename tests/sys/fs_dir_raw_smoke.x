/**
 * Stage9 Cap residual 9.1.10 probe: Linux directory walk without libc opendir
 * (std.fs → fs formal merge → xlang_dir_cap.h getdents64).
 *
 * Contract: open "." ; read at least one entry; close succeeds.
 * PLATFORM: LINUX|x86_64 gold.
 */
const fs = import("std.fs");

extern function fs_dir_open_c(path: *u8): i64;
extern function fs_dir_read_c(handle: i64, name_out: *u8, name_cap: i32, is_dir_out: *i32): i32;
extern function fs_dir_close_c(handle: i64): i32;

/**
 * Probe entry for Cap residual 9.1.10 dir face.
 * @return i32 — 0 ok; 1 bad open; 2 bad read; 3 bad close
 */
export function main(): i32 {
  let h: i64 = 0;
  let rc: i32 = 0;
  let nread: i32 = 0;
  let is_dir: i32 = 0;
  let name: [256]u8;
  let path: [2]u8;
  path[0] = 46; /* '.' */
  path[1] = 0;
  unsafe {
    h = fs_dir_open_c(&path[0]);
  }
  if (h < 0) {
    return 1;
  }
  unsafe {
    nread = fs_dir_read_c(h, &name[0], 256, &is_dir);
  }
  if (nread < 1) {
    unsafe {
      rc = fs_dir_close_c(h);
    }
    return 2;
  }
  unsafe {
    rc = fs_dir_close_c(h);
  }
  if (rc != 0) {
    return 3;
  }
  return 0;
}
