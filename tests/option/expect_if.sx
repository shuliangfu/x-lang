// 最小复现：expect_i32 出现在 if 条件中，seed shux typeck 曾 SIGSEGV（shux-c 正常）
const option = import("core.option");

function main(): i32 {
  let o1: Option_i32 = option.or_i32(option.none_i32(), option.some_i32(99));
  if (option.expect_i32(o1) != 99) {
    return -3;
  }
  return 0;
}
