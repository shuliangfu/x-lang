// 10.3.1 slice2/3: TYPE_FN let-init + Cap-style indirect call.
// Grammar (H02): `function(...): Ret`. Init uses Cap LEA via EXPR_AS
// `(fn as *u8)`; typeck coerces onto TYPE_FN. Bare name LEA is in
// emit_expr_elf_fast (seed) but needs hybrid pabi egg to ship — keep AS
// until egg restored. Expect run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f: function(i32): i32 = (helper_add_one as *u8);
  return f(41);
}
