// Isolated green: 42-layer scalar unused formal must stay a complete
// host-C fat type (nest>41 first layer; type_to_c_repr scratch is
// 640 so nest 42 i32 tag=518 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 42 (stay in 0..255; nest*10+10 would be 430).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 42; }
function main(): i32 {
  return 42;
}
