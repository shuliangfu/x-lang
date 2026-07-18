/**
 * See implementation.
 */
const dynlib = import("std.dynlib");

/** Internal function `try_open`.
 * Implements `try_open`.
 * @param path *u8
 * @return *u8
 */
function try_open(path: *u8): *u8 {
  return dynlib.open(path);
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /** "/usr/lib/libSystem.B.dylib" */
  let path_mac: u8[27] = [
    47, 117, 115, 114, 47, 108, 105, 98, 47, 108, 105, 98, 83, 121, 115, 116, 101, 109, 46, 66, 46, 100, 121, 108, 105, 98, 0
  ];
  /** "libc.so.6" */
  let path_lin: u8[10] = [108, 105, 98, 99, 46, 115, 111, 46, 54, 0];
  /** "kernel32.dll" */
  let path_win: u8[13] = [107, 101, 114, 110, 101, 108, 51, 50, 46, 100, 108, 108, 0];
  let lib: *u8 = try_open(&path_mac[0]);
  if (lib == 0) { lib = try_open(&path_lin[0]); }
  if (lib == 0) { lib = try_open(&path_win[0]); }
  if (lib == 0) { return 1; }
  dynlib.close(lib);
  return 0;
}
