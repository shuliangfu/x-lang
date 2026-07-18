// asm_append_repro2.x — import only asm.types (transitive codegen dependency).
const types = import("asm.types");

/**
 * Append newline via append_asm_line without directly importing codegen.
 * @param out codegen output buffer
 * @return append status
 */
function f(out: *CodegenOutBuf): i32 {
  let nl: u8[1] = [10];
  return append_asm_line(out, &nl[0], 1);
}
