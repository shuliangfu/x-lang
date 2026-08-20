// Isolated green: 41-layer scalar unused formal must stay a complete
// host-C fat type (nest>40 first layer; type_to_c_repr scratch is
// 512 so nest 41 i32 tag=506 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 41 (stay in 0..255; nest*10+10 would be 420).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 41; }
function main(): i32 {
  return 41;
}
