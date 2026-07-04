/**
 * TOOL-002 golden（L3 warn）：SHUX_PAD_FIELDS=1 时 check 打印 -pad-fields warning，不阻断。
 */
struct BadShare {
  head: u32
  data: u32
}

function main(): i32 {
  let s: BadShare = BadShare { head: 0, data: 0 };
  s.head = 1 as u32;
  s.data = 2 as u32;
  return s.head + s.data;
}
