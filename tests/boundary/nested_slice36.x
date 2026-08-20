// Isolated green: 36-layer scalar unused formal must stay a complete
// host-C fat type (nest>35 first layer; type_to_c_repr scratch is
// 512 so nest 36 i32 tag=446 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 36 (stay in 0..255; nest*10+10 would be 260).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 36; }
function main(): i32 {
  return 36;
}
