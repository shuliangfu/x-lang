// Isolated green: 49-layer scalar unused formal must stay a complete
// host-C fat type (nest>48 first layer; type_to_c_repr scratch is
// 640 so nest 49 i32 tag=602 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 49 (stay in 0..255; nest*10+10 would be 500).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 49; }
function main(): i32 {
  return 49;
}
