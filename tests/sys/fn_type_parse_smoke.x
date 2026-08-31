// 10.3.1 slice1: type-position `function(...): T` parses as TYPE_FN (ord 18).
// X grammar (H02): keyword `function` + `: Ret` — not Rust `fn` / `->`.
// Init is deliberately i32 so a typeck mismatch after successful parse still
// proves the annotation was accepted (XP003 = parse fail). PLATFORM: SHARED.
export function main(): i32 {
  let f: function(i32): i32 = 0;
  return 42;
}
