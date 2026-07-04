// pgo_hot_smoke.x — WPO-S4 PGO-Lite：main(d0)+warm_mid(d1)→.text.hot；hot_add/cold_deep(d2)→.text.unlikely
// S2：emit 序 main 先于 warm_mid（同段内 call-depth 升序）
// 用法：SHUX_WPO_PGO_HOT=1 shux_asm ... -o /tmp/pgo.o && readelf -S /tmp/pgo.o | grep -E 'text\.(hot|unlikely)'

/** 热路径：main 直接调用。 */
function hot_add(a: i32, b: i32): i32 {
  return a + b;
}

/** 冷路径：warm_mid 间接调用（call depth 2），emit 进 .text.unlikely。 */
function cold_deep(): i32 {
  return 99;
}

/** 热路径：main 直接调用；内部再调 cold_deep。 */
function warm_mid(): i32 {
  return cold_deep() + hot_add(1, 2);
}

function main(): i32 {
  return warm_mid();
}
