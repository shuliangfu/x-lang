// CORE-010：core.fmt usize/isize/指针 fmt_*_to_buf 边界烟测
const fmt = import("core.fmt");

/** 校验 buf[0..len) 与期望 ASCII 字节序列一致。 */
function buf_eq(buf: *u8, len: i32, b0: u8, b1: u8, b2: u8, b3: u8, b4: u8): bool {
  if (len < 1) { return false; }
  if (buf[0] != b0) { return false; }
  if (len < 2) { return true; }
  if (buf[1] != b1) { return false; }
  if (len < 3) { return true; }
  if (buf[2] != b2) { return false; }
  if (len < 4) { return true; }
  if (buf[3] != b3) { return false; }
  if (len < 5) { return true; }
  if (buf[4] != b4) { return false; }
  return true;
}

function main(): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  // usize：0 与正数
  let n0: i32 = fmt.to_buf(buf, 32, 0 as usize);
  if (n0 != 1 || buf[0] != 48) { return 1; }
  let n1: i32 = fmt.to_buf(buf, 32, 42 as usize);
  if (n1 != 2 || !buf_eq(buf, 2, 52, 50, 0, 0, 0)) { return 2; }
  let too_usize: i32 = fmt.to_buf(buf, 1, 99 as usize);
  if (too_usize != -1) { return 3; }

  // isize：负数与 INT64_MIN 特判
  let n2: i32 = fmt.to_buf(buf, 32, (0 - 7) as isize);
  if (n2 != 2 || !buf_eq(buf, 2, 45, 55, 0, 0, 0)) { return 4; }
  let min_i64: i64 = 0 - 9223372036854775807 - 1;
  let n3: i32 = fmt.to_buf(buf, 32, min_i64 as isize);
  if (n3 != 20) { return 5; }

  // 指针：null 与非 null
  let null_p: *u8 = 0 as *u8;
  let np: i32 = fmt.ptr_to_buf(buf, 32, null_p);
  if (np != 3 || !buf_eq(buf, 3, 48, 120, 48, 0, 0)) { return 6; }
  let too_ptr: i32 = fmt.ptr_to_buf(buf, 2, null_p);
  if (too_ptr != -1) { return 7; }
  let local: u8 = 1;
  let lp: *u8 = &local;
  let pp: i32 = fmt.ptr_to_buf(buf, 32, lp);
  if (pp < 3) { return 8; }
  if (buf[0] != 48 || buf[1] != 120) { return 9; }

  return 0;
}
