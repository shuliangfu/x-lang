// Isolated green: 17-layer scalar unused formal must stay a complete
// host-C fat type (nest>16 soft first layer past the 4.2.3 16-layer cap).
// take unused so a missing body cannot fake the result; -E must still
// contain take.
// Expected: compile = 0, run = 70.
// PLATFORM: SHARED — Ubuntu gold host-C.

function take(x: [][][][][][][][][][][][][][][][][]i32): i32 { return 70; }
function main(): i32 {
  return 70;
}
