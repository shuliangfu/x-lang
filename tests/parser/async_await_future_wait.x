// See implementation.
const async_mod = import("std.async");

async function wait_fut(): i32 {
  let fut: async_mod.Future = async_mod.future_new();
  async_mod.future_complete(&fut, 42);
  let st: i32 = await async_mod.future_wait(&fut, 8);
  if (st != async_mod.POLL_READY) {
    return 1;
  }
  return 0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return wait_fut();
}
