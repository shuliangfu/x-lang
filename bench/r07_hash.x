// r07_hash.x — FNV-1a 64-bit hash benchmark (matches r07_hash.c / .zig)
// Tests: 64-bit integer arithmetic, byte-level memory access, dependency chain.
// Uses i64 for the hash (xlang does not have u64; bit patterns match uint64_t
// under two's complement wrapping, so the low-32-bit return value is identical).
// FNV-1a offset basis 0xcbf29ce484222325 = -3750763034362895579 as i64.

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 10000000;
  let rounds: i32 = 10;
  let buf: u8[10000000] = [];
  let i: i32 = 0;
  while (i < n) {
    buf[i] = (i & 255) as u8;
    i = i + 1;
  }
  // FNV-1a 64-bit offset basis (same bit pattern as 0xcbf29ce484222325)
  let offset: i64 = -3750763034362895579;
  // FNV-1a 64-bit prime
  let prime: i64 = 1099511628211;
  let hash: i64 = 0;
  let r: i32 = 0;
  while (r < rounds) {
    let h: i64 = offset;
    i = 0;
    while (i < n) {
      h = (h ^ (buf[i] as i64)) * prime;
      i = i + 1;
    }
    hash = hash + h;
    r = r + 1;
  }
  // Return low 32 bits (truncation gives identical bits to C uint64_t & 0xFFFFFFFF)
  return (hash as i32);
}
