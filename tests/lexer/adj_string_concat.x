// wave282: C-style adjacent string-literal concat at parse time.
// "AB" "C" → semantic "ABC"; s[2] == 'C' (67). Soft residual was silent drop of "C".

/**
 * Program entry: prove adjacent string literals concatenate into one STRING_LIT.
 * @return i32 — 67 when s[2] is 'C' after "AB" "C" concat
 * PLATFORM: SHARED
 */
export function main(): i32 {
  let s: *u8 = "AB" "C";
  return s[2] as i32;
}
