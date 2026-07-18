/** Probe: *u8 pointer index load of u8 and newline skip (seed asm). */

/**
 * If ptr[3] is newline (10), return 77; else return 33.
 */
function main(): i32 {
  let line: u8[8] = [99, 100, 101, 10, 0, 0, 0, 0];
  let ptr: *u8 = &line[0];
  let offset: i32 = 3;
  if (ptr[offset] == 10) { return 77; }
  return 33;
}
