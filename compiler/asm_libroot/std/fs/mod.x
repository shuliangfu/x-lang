// asm_libroot/std/fs/mod.x — Goal2 asm  std.fs（ import("std.fs")
// ）
//
// ： compiler  pipeline/main/parser  open/read/write/close
// ， import("std.io")，
//  ../std/fs/mod.x  std.io  .x typeck （
// scripts/build_shux_asm.sh）。
//  ../std/fs/mod.x； asm_build_list  -L
// asm_libroot  -L .. 。

extern "C" function fs_open_read_c(path: *u8): i32;
extern "C" function fs_posix_read_c(fd: i32, buf: *u8, count: usize): isize;
extern "C" function fs_posix_write_c(fd: i32, buf: *u8, count: usize): isize;
extern "C" function close(fd: i32): i32;

/** mod  libc close  unsafe； close 。 */
function fs_mod_close(fd: i32): i32 {
  unsafe { return close(fd); }
}

/**  path（NUL ）； -1。 */
function open(path: *u8): i32 {
  return fs_open_read_c(path);
}

/**  fd； 0， -1。 */
function close(fd: i32): i32 {
  return fs_mod_close(fd);
}

/**  fd  count  buf。 */
function read(fd: i32, buf: *u8, count: usize): isize {
  return fs_posix_read_c(fd, buf, count);
}

/**  buf[0..count-1]  fd。 */
function write(fd: i32, buf: *u8, count: usize): isize {
  return fs_posix_write_c(fd, buf, count);
}

/** ： import。 */
function placeholder(): i32 {
  return 0;
}
