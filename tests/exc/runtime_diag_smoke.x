// STD-159：runtime 诊断 API 烟测
const runtime = import("std.runtime");

function main(): i32 {
  if (runtime.diag_enabled() != 1) { return 1; }
  runtime.diag_collect(0, 0);
  return 0;
}
