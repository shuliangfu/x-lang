// See implementation.
#[repr(compatible)]
allow(padding) struct PairA { a: i32; b: i32; }

allow(padding) struct PairC { a: i32; b: i32; }

/** Internal function `take_a`.
 * Implements `take_a`.
 * @param _p *PairA
 * @return i32
 */
function take_a(_p: *PairA): i32 {
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let c: PairC = PairC { a: 1, b: 2 };
  take_a(&c);
  return 0;
}
