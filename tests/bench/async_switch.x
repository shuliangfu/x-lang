// See implementation.
// See implementation.
allow(padding)
struct CoopFrame {
  phase: i32
  ops: i64
}

/** Internal function `coop_frame_step`.
 * Implements `coop_frame_step`.
 * @param f *CoopFrame
 * @return i32
 */
function coop_frame_step(f: *CoopFrame): i32 {
  if (f.phase == 0) {
    f.ops = f.ops + 1;
    f.phase = 1;
    return 0;
  }
  f.ops = f.ops + 1;
  f.phase = 0;
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let rounds: i64 = 1000000;
  let ping: CoopFrame = CoopFrame { phase: 0, ops: 0 };
  let pong: CoopFrame = CoopFrame { phase: 0, ops: 0 };
  let i: i64 = 0;
  while (i < rounds) {
    let _p: i32 = coop_frame_step(&ping);
    let _q: i32 = coop_frame_step(&pong);
    i = i + 1;
  }
  let total: i64 = ping.ops + pong.ops;
  if (total != 2000000) { return 5; }
  return 0;
}
