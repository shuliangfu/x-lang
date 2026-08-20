// Isolated green: 46-layer scalar unused formal must stay a complete
// host-C fat type (nest>45 first layer; type_to_c_repr scratch is
// 640 so nest 46 i32 tag=566 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 46 (stay in 0..255; nest*10+10 would be 470).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 46; }
function main(): i32 {
  return 46;
}
