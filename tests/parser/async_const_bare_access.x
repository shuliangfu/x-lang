// NEG: bare import const names must not resolve (must use import binding).
const async_mod = import("std.async");

function main(): i32 {
  if (POLL_PENDING != 0) { return 1; }
  if (POLL_READY != 1) { return 2; }
  return 0;
}
