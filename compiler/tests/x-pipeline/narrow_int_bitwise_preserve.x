const ast = import("ast");

/** Internal function `main`.
 * Purpose: see body; keep contracts (null/cap/PLATFORM) aligned with implementation.
 * Params/returns: as declared in the signature; panics or error codes follow local conventions.
 */
function main(): i32 {
  let bytes: u8[4] = [];
  bytes[0] = 1;
  bytes[0] = bytes[0] ^ 1;
  bytes[1] = (bytes[1] & 15) | 64;
  bytes[2] = bytes[2] << 1;
  bytes[3] = bytes[3] >> 1;
  return 0;
}
