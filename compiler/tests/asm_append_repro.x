// asm_append_repro.x — minimal repro: cross-module call append_asm_line return-type resolution.
const types = import("asm.types");
const codegen = import("codegen");

/**
 * Append a single newline byte to the codegen out buffer via append_asm_line.
 * @param out codegen output buffer pointer
 * @return append_asm_line status code
 */
function f(out: *CodegenOutBuf): i32 {
  let nl: u8[1] = [10];
  return append_asm_line(out, &nl[0], 1);
}
