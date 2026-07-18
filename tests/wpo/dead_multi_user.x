// See implementation.
const dead_lib = import("dead_lib");
const dead_lib2 = import("dead_lib2");
const dead_lib3 = import("dead_lib3");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return live_export() + live_export2() + live_export3();
}
