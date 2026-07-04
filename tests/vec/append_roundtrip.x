// STD-014：Vec_u64 / Vec_f64 append_slice ↔ from_slice round-trip
const vec = import("std.vec");

function main(): i32 {
  let src_u: u64[4] = [1 as u64, 2 as u64, 3 as u64, 4 as u64];
  let v64: Vec_u64 = vec.from_slice(src_u, 4);
  if (vec.len(v64) != 4) { return 1; }
  if (vec.get(v64, 2) != (3 as u64)) { return 2; }
  let tail: u64[2] = [5 as u64, 6 as u64];
  if (vec.extend(&v64, tail, 2) != 0) { return 3; }
  if (vec.len(v64) != 6) { return 4; }
  if (vec.get(v64, 5) != (6 as u64)) { return 5; }
  let round_u: Vec_u64 = vec.from_slice(v64.ptr, vec.len(v64));
  if (vec.len(round_u) != 6) { return 6; }
  if (vec.get(round_u, 0) != (1 as u64) || vec.get(round_u, 4) != (5 as u64)) { return 7; }
  let u_len: i32 = vec.len(round_u);
  vec.deinit(&v64);
  vec.deinit(&round_u);

  let src_f: f64[3] = [1.0, 2.5, 3.5];
  let vf: Vec_f64 = vec.from_slice(src_f, 3);
  if (vec.len(vf) != 3) { return 8; }
  if (vec.get(vf, 1) != 2.5) { return 9; }
  let tail_f: f64[1] = [4.0];
  if (vec.extend(&vf, tail_f, 1) != 0) { return 10; }
  let round_f: Vec_f64 = vec.from_slice(vf.ptr, vec.len(vf));
  if (vec.len(round_f) != 4) { return 11; }
  if (vec.get(round_f, 3) != 4.0) { return 12; }
  let score: i32 = (vec.len(round_f) as i32) + u_len;
  vec.deinit(&vf);
  vec.deinit(&round_f);
  return score;
}
