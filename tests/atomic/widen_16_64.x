// STD-146：std.atomic i16/u16 与 i64/u64 扩展 API 烟测
const atomic = import("std.atomic");

function main(): i32 {
  // i16
  let s: i16 = (0 as i16);
  atomic.store(&s, (10 as i16));
  if (atomic.load(&s) != (10 as i16)) { return 1; }
  if (atomic.fetch_add(&s, (3 as i16)) != (10 as i16)) { return 2; }
  if (atomic.load(&s) != (13 as i16)) { return 3; }
  let exp_s: i16 = (13 as i16);
  if (atomic.compare_exchange(&s, &exp_s, (20 as i16)) != 1) { return 4; }
  if (atomic.load(&s) != (20 as i16)) { return 5; }

  // u16
  let u: u16 = (0 as u16);
  atomic.store(&u, (100 as u16));
  if (atomic.load(&u) != (100 as u16)) { return 6; }
  if (atomic.fetch_add(&u, (5 as u16)) != (100 as u16)) { return 7; }
  let exp_u: u16 = (105 as u16);
  if (atomic.compare_exchange(&u, &exp_u, (200 as u16)) != 1) { return 8; }

  // i64 CE + fetch_sub
  let y: i64 = (1000 as i64);
  let exp_y: i64 = (1000 as i64);
  if (atomic.compare_exchange(&y, &exp_y, (2000 as i64)) != 1) { return 9; }
  if (atomic.fetch_sub(&y, (500 as i64)) != (2000 as i64)) { return 10; }
  if (atomic.load(&y) != (1500 as i64)) { return 11; }

  // u64 fetch + CE
  let z: u64 = (0 as u64);
  atomic.store(&z, (42 as u64));
  if (atomic.fetch_add(&z, (8 as u64)) != (42 as u64)) { return 12; }
  if (atomic.fetch_sub(&z, (2 as u64)) != (50 as u64)) { return 13; }
  let exp_z: u64 = (48 as u64);
  if (atomic.compare_exchange(&z, &exp_z, (99 as u64)) != 1) { return 14; }
  if (atomic.load(&z) != (99 as u64)) { return 15; }

  return 0;
}
