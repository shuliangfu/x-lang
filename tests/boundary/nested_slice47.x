// Isolated green: 47-layer scalar unused formal must stay a complete
// host-C fat type (nest>46 first layer; type_to_c_repr scratch is
// 640 so nest 47 i32 tag=578 fits).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 47 (stay in 0..255; nest*10+10 would be 480).
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 47; }
function main(): i32 {
  return 47;
}
