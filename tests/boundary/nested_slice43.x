// Isolated green: 43-layer scalar unused formal must stay a complete
// host-C fat type (nest>42 first layer; type_to_c_repr scratch is
// 640 so nest 43 i32 tag=530 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 43 (stay in 0..255; nest*10+10 would be 440).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 43; }
function main(): i32 {
  return 43;
}
