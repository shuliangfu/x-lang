// Isolated green: 21-layer scalar unused formal must stay a complete
// host-C fat type (nest>20 soft first layer past the 256-byte
// type_to_c_repr scratch; tag is 266 bytes so scratch is 384).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 110.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][][][][][]i32): i32 { return 110; }
function main(): i32 {
  return 110;
}
