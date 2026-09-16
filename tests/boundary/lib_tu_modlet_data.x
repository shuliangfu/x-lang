// Isolated: library-TU non-empty module ARRAY_LIT in asm .data.
// Sit-red for prepare baking needles into ELF .data / Mach-O __DATA,__const
// so library TUs (no hoist-target entry) do not read BSS-zero COMMON.
// Empty `u8[N]=[]` stays COMMON (not this probe).
// Expected: compile = 0, run = 42 (asm / host-C).
// PLATFORM: SHARED — Ubuntu gold library-TU .data bake.

const NEEDLE: u8[4] = [65, 66, 67, 0];
const ROW: [2]i32 = [10, 32];

/**
 * Read baked module ARRAY_LIT bytes / elems (no dependence on hoist seed).
 * @return i32 — 42 ok; else the failing case id
 */
function main(): i32 {
  if (NEEDLE[0] != 65) { return 1; }
  if (NEEDLE[1] != 66) { return 2; }
  if (NEEDLE[2] != 67) { return 3; }
  if (NEEDLE[3] != 0) { return 4; }
  if (ROW[0] != 10) { return 5; }
  if (ROW[1] != 32) { return 6; }
  return 42;
}
