// 10.3.1 slice3: TYPE_FN let-init from bare fn name + Cap-style indirect call.
// Grammar (H02): `function(...): Ret`. Bare name LEA lives in
// pipeline_asm_emit_expr_elf_fast (mega + seed twin); hybrid pabi egg must
// carry it. Expect run=42. PLATFORM: SHARED.

#[no_mangle]
function helper_add_one(x: i32): i32 {
  return x + 1;
}

function main(): i32 {
  let f: function(i32): i32 = helper_add_one;
  return f(41);
}
