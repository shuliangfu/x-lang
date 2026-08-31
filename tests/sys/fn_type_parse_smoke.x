// 10.3.1 slice2: TYPE_FN let-init from bare fn + Cap-style indirect call.
// Grammar (H02): `function(...): Ret` — not Rust `fn` / `->`.
// Bare name is Cap *u8 (wave100); typeck coerces onto TYPE_FN; asm Cap blr.
// Expect product xlang_asm -o → run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f: function(i32): i32 = helper_add_one;
  return f(41);
}
