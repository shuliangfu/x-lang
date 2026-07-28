// wave282: three adjacent string literals → one STRING_LIT "Hello".

/**
 * Program entry: three-way adjacent concat "He" "ll" "o" → "Hello".
 * @return i32 — 111 when s[4] is 'o'
 * PLATFORM: SHARED
 */
export function main(): i32 {
  let s: *u8 = "He" "ll" "o";
  return s[4] as i32;
}
