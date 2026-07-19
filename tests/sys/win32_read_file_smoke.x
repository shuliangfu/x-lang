// See implementation.
const sys = import("std.sys");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  /* "shux_win32_read_gate.txt\0" — relative path resolved from CWD.
   * Why: Win32 CreateFileA does not recognize MSYS2 /tmp/ mapping; absolute
   *      /tmp/ path fails with ERROR_PATH_NOT_FOUND. The gate script writes
   *      this file to CWD before exec, so relative path works on Windows.
   * Invariant: gate script must write shux_win32_read_gate.txt to the
   *            working directory before invoking this binary. */
  let path: u8[30] = [
    115, 104, 117, 120, 95, 119, 105, 110, 51, 50, 95, 114, 101, 97, 100, 95,
    103, 97, 116, 101, 46, 116, 120, 116, 0,
  ];
  let buf: u8[8] = [0, 0, 0, 0, 0, 0, 0, 0];
  let n: i32 = sys.read_file_into(&path[0], &buf[0], 8);
  if (n != 3) {
    return 1;
  }
  if (buf[0] != 87 || buf[1] != 73 || buf[2] != 78) {
    return 2;
  }
  return 0;
}
