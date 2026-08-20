// Isolated green: 37-layer scalar unused formal must stay a complete
// host-C fat type (nest>36 first layer; type_to_c_repr scratch is
// 512 so nest 37 i32 tag=458 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 37 (stay in 0..255; nest*10+10 would be 270).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 37; }
function main(): i32 {
  return 37;
}
