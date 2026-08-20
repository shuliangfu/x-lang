// Isolated green: 9-layer scalar [][][][][][][][][]i32 unused formal must
// stay a complete host-C fat type (4.2.3 XLANG_SLICE_LAYOUTS_N16).
// take unused so a missing body cannot fake the result; -E must still
// contain take with struct xlang_slice×9_int32_t.
// Expected: compile = 0, run = 50.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][]i32): i32 { return 50; }
function main(): i32 {
  return 50;
}
