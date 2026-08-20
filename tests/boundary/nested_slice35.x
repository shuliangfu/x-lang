// Isolated green: 35-layer scalar unused formal must stay a complete
// host-C fat type (nest>34 first layer; type_to_c_repr scratch is
// 512 so nest 35 i32 tag=434 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 250.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 250; }
function main(): i32 {
  return 250;
}
