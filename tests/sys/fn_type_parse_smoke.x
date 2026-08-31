// 10.3.1 slice2: TYPE_FN let-init from Cap *u8 + Cap-style indirect call.
// Grammar (H02): `function(...): Ret` — not Rust `fn` / `->`.
// Init uses `(fn as *u8)` — Cap LEA authority (EXPR_AS); typeck coerces onto
// TYPE_FN; asm Cap blr. Bare name alone is not Cap LEA emit (wave100 typeck
// only). Expect product xlang_asm -o → run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f: function(i32): i32 = (helper_add_one as *u8);
  return f(41);
}
