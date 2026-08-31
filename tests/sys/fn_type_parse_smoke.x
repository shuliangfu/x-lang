// 10.3.1 slice3: bare fn name → Cap LEA onto TYPE_FN + Cap indirect call.
// Grammar (H02): `function(...): Ret`. wave100 types bare name as Cap *u8;
// emit_expr_elf_fast LEAs #[no_mangle] when no stack slot (no `as *u8` required).
// Expect product xlang_asm -o → run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f: function(i32): i32 = helper_add_one;
  return f(41);
}
