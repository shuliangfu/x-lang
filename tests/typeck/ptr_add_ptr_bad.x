/** wave285: ptr + ptr must hard-fail at typeck (not host BLD001). */
export function main(): i32 {
  let a: *u8 = "hel";
  let b: *u8 = "lo";
  let c: *u8 = a + b;
  return 42;
}
