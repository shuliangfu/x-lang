// See implementation.
const async_mod = import("std.async");

async function ping(): i32 {
  await scheduler_yield();
  return 42;
}
