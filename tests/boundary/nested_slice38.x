// Isolated green: 38-layer scalar unused formal must stay a complete
// host-C fat type (nest>37 first layer; type_to_c_repr scratch is
// 512 so nest 38 i32 tag=470 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 38 (stay in 0..255; nest*10+10 would be 280).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 38; }
function main(): i32 {
  return 38;
}
