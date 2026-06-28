/**
 * ZC-2 smoke：read_ptr_gen / read_ptr_gen_valid 跨 read_ptr 调用校验。
 * 管道喂入 "AB"：第一次读后 gen 有效；第二次 read_ptr 后旧 gen 失效。exit 0。
 */
const io = import("std.io");

function main(): i32 {
  let p1: *u8 = io.read_stdin_ptr();
  if (p1 == 0 as *u8) {
    return 1;
  }
  if (io.ptr_len() < 2) {
    return 2;
  }
  let g1: u64 = io.ptr_gen();
  if (io.ptr_valid(g1) != 1) {
    return 3;
  }
  if (p1[0] != 65) {
    return 4;
  }
  /** 须消费 _p2，避免 WPO/DCE 删掉第二次 read_ptr（gen 失效烟测依赖此调用）。 */
  let p2: *u8 = io.read_stdin_ptr();
  if (p2 != 0 as *u8 && io.ptr_len() > 0 && p2[0] == 65) {
    return 11;
  }
  if (io.ptr_valid(g1) != 0) {
    return 5;
  }
  let g2: u64 = io.ptr_gen();
  if (io.ptr_valid(g2) != 1) {
    return 6;
  }
  return 0;
}
