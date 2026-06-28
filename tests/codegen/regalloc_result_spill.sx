// C5 §5.3 / X9：16B Result_i32 spill；gate manifest：spill_probe / 0x12345678

allow(padding) struct Result_i32 {
  value: i32;
  _pad1: i32;
  err: i32;
  _pad2: i32;
}

/** spill_probe 内联于 main：105 + 120 = 225 */
function main(): i32 {
  let v1: i32 = 1;
  let v2: i32 = 2;
  let v3: i32 = 3;
  let v4: i32 = 4;
  let v5: i32 = 5;
  let v6: i32 = 6;
  let v7: i32 = 7;
  let v8: i32 = 8;
  let v9: i32 = 9;
  let v10: i32 = 10;
  let v11: i32 = 11;
  let v12: i32 = 12;
  let v13: i32 = 13;
  let v14: i32 = 14;
  let r0: Result_i32 = Result_i32 { value: 0x12345678, _pad1: 0, err: 0, _pad2: 0 };
  let r1: Result_i32 = Result_i32 { value: 0, _pad1: 0, err: 0, _pad2: 0 };
  let r2: Result_i32 = Result_i32 { value: 0, _pad1: 0, err: 99, _pad2: 0 };
  let r3: Result_i32 = Result_i32 { value: 0x12345678, _pad1: 0, err: 0, _pad2: 0 };
  let sum: i32 = v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13 + v14;
  let val: i32 = r3.value;
  let err: i32 = r3.err;
  if (err != 0) {
    return panic();
  }
  if (val != 0x12345678) {
    return 1;
  }
  return sum + (val & 255);
}
