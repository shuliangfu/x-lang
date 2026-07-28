// LANG-004 T5: method call with no impl for receiver type.
// Non-empty struct so typeck reaches method resolution (empty S{} is separate residual).
struct S { v: i32 }
/**
 * Program/test entry point — must fail typeck with "no impl for type".
 * @return i32
 */
function main(): i32 {
  let s: S = S { v: 1 }
  return s.double();
}
