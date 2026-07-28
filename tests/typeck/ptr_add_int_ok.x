/** wave285: ptr + integer offset remains legal; return second byte (66 = 'B'). */
export function main(): i32 {
  let p: *u8 = "ABC";
  let q: *u8 = p + 1;
  return q[0] as i32;
}
