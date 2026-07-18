// See implementation.
#[repr(compatible)]
allow(padding) struct PairA { a: i32; b: i32; }

#[repr(compatible)]
allow(padding) struct PairB { a: i32; b: i32; }

/** Internal function `take_b`.
 * Implements `take_b`.
 * @param _p *PairB
 * @return i32
 */
function take_b(_p: *PairB): i32 {
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: PairA = PairA { a: 3, b: 4 };
  take_b(&x);
  return 0;
}
