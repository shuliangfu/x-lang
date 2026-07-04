// tests/import-std-layout/check_imports.x — STBL-004 多 std.* import 烟测
// 验证 -L . 下 dotted import 可解析；main 空实现仅过 typeck。

const io = import("std.io");
const fs = import("std.fs");
const path = import("std.path");
const http = import("std.http");
const json = import("std.json");
const process = import("std.process");
const types = import("core.types");

function main(): i32 {
  return 0;
}
