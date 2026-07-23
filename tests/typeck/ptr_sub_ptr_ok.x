/** wave285: ptr - ptr yields integer difference (isize → i32). */
export function main(): i32 {
  let p: *u8 = "ABC";
  let q: *u8 = p + 2;
  let d: i32 = (q - p) as i32;
  return d;
}
