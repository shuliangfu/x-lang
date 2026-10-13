// knife256/10.2 Cap tip soft: real bake_scalar over m8 hollow ret0.
export extern function pipeline_elf_ctx_data_poke_u8(ctx: *u8, off: i32, b: i32): i32;

#[no_mangle]
export function pipe_modlet_bake_scalar_imm_to_data(
  elf_ctx: *u8, data_off: i32, imm: i32, csz: i32
): i32 {
  unsafe {
    let bi: i32 = 0;
    let n: i32 = 0;
    let rc: i32 = 0;
    let uw: u32 = 0;
    let hi: u32 = 0;
    if (elf_ctx == (0 as *u8) || data_off < 0 || csz <= 0) {
      return 0 - 1;
    }
    n = csz;
    if (n > 8) { n = 8; }
    uw = imm as u32;
    bi = 0;
    while (bi < n && bi < 4) {
      rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, data_off + bi, (uw & 255) as i32);
      if (rc != 0) { return 0 - 1; }
      uw = uw / 256;
      bi = bi + 1;
    }
    if (bi < n) {
      hi = 0;
      if (imm < 0) { hi = 4294967295 as u32; }
      while (bi < n) {
        rc = pipeline_elf_ctx_data_poke_u8(elf_ctx, data_off + bi, (hi & 255) as i32);
        if (rc != 0) { return 0 - 1; }
        hi = hi / 256;
        bi = bi + 1;
      }
    }
    return 0;
  }
}
