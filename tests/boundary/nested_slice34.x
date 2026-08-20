// Isolated green: 34-layer scalar unused formal must stay a complete
// host-C fat type (nest>33 first layer; type_to_c_repr scratch is
// 512 so nest 34 i32 tag=422 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 240.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 240; }
function main(): i32 {
  return 240;
}
