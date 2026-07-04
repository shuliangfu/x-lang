/**
 * DOD-CL-S1 smoke：struct 字段 align(64) cache line 分隔。
 * head@0 + tail@64 → 返回 head+tail=64（运行时逻辑 smoke；layout 实锤见 gate disasm）。
 */
allow(padding) struct Ring64 {
  align(64) head: u32
  align(64) tail: u32
}

function main(): i32 {
  let r: Ring64 = Ring64 { head: 0, tail: 0 };
  r.head = 11 as u32;
  r.tail = 53 as u32;
  return r.head + r.tail;
}
