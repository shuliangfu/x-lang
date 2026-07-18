// See implementation.

allow(padding) struct Result_i32 {
  value: i32;
  _pad1: i32;
  err: i32;
  _pad2: i32;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let r3: Result_i32 = Result_i32 { value: 1, _pad1: 0, err: 0, _pad2: 0 };
  if (r3.err != 0) {
    return 1;
  }
  return r3.value;
}
