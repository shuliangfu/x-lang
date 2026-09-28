// w1502 (终局待办 10.25): compound assign on a module let inside a leaf function.
// Darwin and Windows reported CG002 before w1502. An interim gate that kept the
// old arm64 load pair (frame home past the prologue frame) crashed with SIGBUS
// here. Exit 0 when right; the non-zero code names the first wrong check.
let g: i32 = 10;
function bump(): i32 { g += 5; g *= 2; return g; }
function main(): i32 {
  if (bump() != 30) { return 1; }
  g -= 1; if (g != 29) { return 2; }
  g %= 8; if (g != 5) { return 3; }
  g <<= 3; if (g != 40) { return 4; }
  return 0;
}
