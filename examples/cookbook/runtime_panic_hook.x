/**
 * Cookbook RT-01：runtime_ready + panic_hook_collect（STD-028）。
 */
const runtime = import("std.runtime");

function main(): i32 {
  if (runtime.ready() != 0) { return 1; }
  runtime.panic_hook_collect(1, 42);
  return 0;
}
