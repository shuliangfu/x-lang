// asm_append_repro2.x — 仅 import asm.types（传递依赖 codegen）
const types = import("asm.types");

function f(out: *CodegenOutBuf): i32 {
  let nl: u8[1] = [10];
  return append_asm_line(out, &nl[0], 1);
}
