// TOOL-009 golden：async/await 关键字高亮
const async_mod = import("std.async");

async function ping(): i32 {
  await scheduler_yield();
  return 42;
}
