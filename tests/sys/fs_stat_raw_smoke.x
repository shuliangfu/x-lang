/**
 * Stage9 Cap residual 9.1.2 probe: std.fs.stat without libc stat.
 * Product pure-asm: fs.stat → fs_stat_c → fs_libc_stat → Linux newfstatat
 * (raw_syscall4; no U stat on fs.o). Also exercises fk0 needle std_fs_stat.
 * PLATFORM: LINUX|x86_64 gold.
 */
const fs = import("std.fs");

/**
 * Probe entry: stat("/") is_dir; fail on missing path.
 * @return i32 — 0 ok; 1 null out; 2 not dir; 3 missing should fail
 */
function main(): i32 {
  let root: u8[2] = [47, 0]; /* "/" */
  let missing: u8[32] = [
    47, 110, 111, 95, 115, 117, 99, 104, 95, 112, 97, 116, 104, 95, 57, 49,
    50, 95, 120, 108, 97, 110, 103, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ];
  let st: FsStatOut = { size: 0, mode: 0, is_dir: 0, is_file: 0, mtime_sec: 0 };
  let r: i32 = fs.stat(&root[0], &st);
  if (r != 0) {
    return 1;
  }
  if (st.is_dir != 1) {
    return 2;
  }
  let r2: i32 = fs.stat(&missing[0], &st);
  if (r2 == 0) {
    return 3;
  }
  return 0;
}
