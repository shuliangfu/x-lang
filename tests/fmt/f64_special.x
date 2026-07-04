/**
 * CORE-011 烟测：core.fmt f64 NaN/Inf 与 fmt_f64_to_buf_prec 金样向量。
 */
const fmt = import("core.fmt");

/** 校验 buf[0..len) 与期望 ASCII 字节一致。 */
function expect_bytes(buf: *u8, len: i32, b0: u8, b1: u8, b2: u8, b3: u8, b4: u8, b5: u8, b6: u8, b7: u8): bool {
  if (len < 1) { return false; }
  if (buf[0] != b0) { return false; }
  if (len > 1 && buf[1] != b1) { return false; }
  if (len > 2 && buf[2] != b2) { return false; }
  if (len > 3 && buf[3] != b3) { return false; }
  if (len > 4 && buf[4] != b4) { return false; }
  if (len > 5 && buf[5] != b5) { return false; }
  if (len > 6 && buf[6] != b6) { return false; }
  if (len > 7 && buf[7] != b7) { return false; }
  return true;
}

function main(): i32 {
  let buf: u8[16] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

  // NaN：0.0 / 0.0
  let z: f64 = 0.0;
  let nan_v: f64 = z / z;
  let n_nan: i32 = fmt.to_buf(buf, 16, nan_v);
  if (n_nan != 3) { return 1; }
  if (!expect_bytes(buf, 3, 78, 97, 110, 0, 0, 0, 0, 0)) { return 2; }

  // +Inf：1e200 * 1e200 溢出
  let huge: f64 = 1e200;
  let inf_p: f64 = huge * huge;
  let n_inf: i32 = fmt.to_buf(buf, 16, inf_p);
  if (n_inf != 3) { return 3; }
  if (!expect_bytes(buf, 3, 73, 110, 102, 0, 0, 0, 0, 0)) { return 4; }

  // -Inf
  let inf_n: f64 = 0.0 - inf_p;
  let n_ninf: i32 = fmt.to_buf(buf, 16, inf_n);
  if (n_ninf != 4) { return 5; }
  if (!expect_bytes(buf, 4, 45, 73, 110, 102, 0, 0, 0, 0)) { return 6; }

  // prec=2：3.14159 → "3.14"
  let pi: f64 = 3.14159;
  let n_prec2: i32 = fmt.to_buf_prec(buf, 16, pi, 2);
  if (n_prec2 != 4) { return 7; }
  if (!expect_bytes(buf, 4, 51, 46, 49, 52, 0, 0, 0, 0)) { return 8; }

  // prec=0：仅整数部分
  let n_prec0: i32 = fmt.to_buf_prec(buf, 16, pi, 0);
  if (n_prec0 != 1) { return 9; }
  if (buf[0] != 51) { return 10; }

  // 非法 prec
  let bad: i32 = fmt.to_buf_prec(buf, 16, pi, 10);
  if (bad != -1) { return 11; }

  // 默认 6 位：1.5 → "1.500000"
  let one_half: f64 = 1.5;
  let n_def: i32 = fmt.to_buf(buf, 16, one_half);
  if (n_def != 8) { return 12; }
  if (!expect_bytes(buf, 8, 49, 46, 53, 48, 48, 48, 48, 48)) { return 13; }

  return 0;
}
