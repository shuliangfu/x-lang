/**
 * TOOL-002 golden（L4 warn）：SHUX_HOT_REORDER=1 时 check 打印 -hot-reorder warning，不阻断。
 */
allow(padding) struct HotLate {
  big: f64
  hot: i32
}

function main(): i32 {
  let s: HotLate = HotLate { big: 1.0, hot: 2 };
  return s.hot;
}
