// Stage 10 S3.1 (10.1.4) slice 1: bare `extern "C"` libc call — no
// `xlang_sys_*` C bridge and no raw_syscall builtin. Proves product
// `xlang_asm -o` packs SysV/AAPCS args and links a libc symbol directly.
// Residual (dlsym / fnptr cast / NT) stays 10.1.4 leftover → 10.3 / 10.1.3.
// PLATFORM: SHARED (emit + link) / POSIX (libc write).

/**
 * POSIX libc write — C ABI import, not an X-language syscall builtin.
 * @param fd i32 — file descriptor (1 = stdout)
 * @param buf *u8 — bytes to write
 * @param count i64 — byte count (ssize_t-width; matches SysV long)
 * @return i64 — bytes written, or negative errno encoding
 */
extern "C" function write(fd: i32, buf: *u8, count: i64): i64;

/**
 * Raw-FFI libc smoke entry: write(1, "Hello FFI!\n", 11) must return 11 and
 * print that line. Failure codes: 2 = wrong write length.
 * @return i32 — 0 on success
 * PLATFORM: SHARED / POSIX
 */
function main(): i32 {
  // "Hello FFI!\n" — 11 payload bytes; trailing zeros pad the fixed array.
  let msg: u8[14] = [72, 101, 108, 108, 111, 32, 70, 70, 73, 33, 10, 0, 0, 0];
  let n: i64 = 0;
  unsafe {
    n = write(1, &msg[0], 11);
  }
  if (n != 11) {
    return 2;
  }
  return 0;
}
