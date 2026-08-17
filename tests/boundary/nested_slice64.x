// Isolated green: 64-layer scalar unused formal must stay a complete
// host-C fat type (nest>52 jump to product freeze; type_to_c_repr
// scratch is 896 so nest 64 i32 tag=782 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 64 (stay in 0..255; nest*10+10 would be 650).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 64; }
function main(): i32 {
  return 64;
}
