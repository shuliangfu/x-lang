/**
 * DOD-CL-S2 -hot-reorder 负例：大字段 f64 在热计数 i32 之前。
 * SHUX_HOT_REORDER=1 check 时应打印 warning（不 error）。
 */
allow(padding) struct BadOrder {
  payload: f64
  hot_count: i32
}

function main(): i32 {
  return 0;
}
