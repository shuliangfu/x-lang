// Isolated green: 39-layer scalar unused formal must stay a complete
// host-C fat type (nest>38 first layer; type_to_c_repr scratch is
// 512 so nest 39 i32 tag=482 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 39 (stay in 0..255; nest*10+10 would be 400).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 39; }
function main(): i32 {
  return 39;
}
