// Strong platform_macho_write_macho_o_to_buf for the modlet inject merge.
// The same body lives in runtime_pipeline_abi_macho_write_thin.x and in
// runtime_pipeline_abi.x. Those files stay where they are. This TU exists
// so the modlet inject can cc -r one strong T over the all-weak pabi copy.
// Do not PREFER runtime_pipeline_abi_macho_write_thin.x: that file has
// file-level lets and the rest of the writer. Do not host-cc
// seeds/pabi_strong_writer.from_x.c. The callee is extern here, so the
// call sits in unsafe. In the thin it is a same-file function.
// PLATFORM: SHARED — Linux, Darwin, and Windows product compilers.

export extern function pipeline_macho_write_o_to_buf_c(elf_ctx: *u8, out_buf: *u8): i32;

/**
 * Reject a null context or a null output buffer, then write the Mach-O.
 * @param elf_ctx *u8 — Mach-O context; null returns -1
 * @param out_buf *u8 — output buffer; null returns -1
 * @return i32 — -1 when either pointer is null, otherwise the callee status
 * PLATFORM: SHARED — strong T merged over the weak pabi symbol.
 */
#[no_mangle]
export function platform_macho_write_macho_o_to_buf(elf_ctx: *u8, out_buf: *u8): i32 {
  if (elf_ctx == 0 as *u8 || out_buf == 0 as *u8) {
    return -1;
  }
  // Extern call. The callee owns the writer.
  unsafe {
    return pipeline_macho_write_o_to_buf_c(elf_ctx, out_buf);
  }
}
