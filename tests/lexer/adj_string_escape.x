// wave282: adjacent concat + escape decode — "\x41" "B" → "AB".

/**
 * Program entry: first literal uses \xHH, second is plain; concat then index.
 * @return i32 — 66 when s[1] is 'B'
 * PLATFORM: SHARED
 */
export function main(): i32 {
  let s: *u8 = "\x41" "B";
  return s[1] as i32;
}
