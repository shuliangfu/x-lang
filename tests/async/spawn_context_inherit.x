// STD-093：language spawn / task_submit 自动继承 bind_context 烟测
const async_mod = import("std.async");

function main(): i32 {
  if (async_mod.spawn_ctx_smoke() != 0) {
    return 1;
  }
  return 0;
}
