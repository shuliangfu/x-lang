// asm_libroot/std/fs/mod.x — Goal2 asm  std.fs（ import("std.fs")
// ）
//
// ： compiler  pipeline/main/parser  open/read/write/close
// ， import("std.io")，
//  ../std/fs/mod.x  std.io  .x typeck （
// scripts/build_xlang_asm.sh）。
//  ../std/fs/mod.x； asm_build_list  -L
// asm_libroot  -L .. 。

extern "C" function fs_open_read_c(path: *u8): i32;
extern "C" function fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize;
extern "C" function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize;
extern "C" function close(fd: i32): i32;

/** Wrap libc close under unsafe; module-private. */
function fs_mod_close(fd: i32): i32 {
  unsafe { return close(fd); }
}

/** Open path (NUL-terminated) for read; -1 on error. */
export function open(path: *u8): i32 {
  unsafe { return fs_open_read_c(path); }
}

/**
 * Close fd; 0 on success, -1 on error.
 * Not export: name collides with libc extern close for L7 surface.
 */
function close(fd: i32): i32 {
  return fs_mod_close(fd);
}

/**  fd  count  buf。 */
export function read(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return fs_posix_read_c(fd, buf, count); }
}

/**  buf[0..count-1]  fd。 */
export function write(fd: i32, buf: *u8, count: usize): isize {
  unsafe { return fs_posix_write_c(fd, buf, count); }
}

/** ： import。 */
export function placeholder(): i32 {
  return 0;
}
