// CORE-017：core.mem volatile_load/store 与 fence 烟测
const mem = import("core.mem");

function main(): i32 {
  let cell: u8[4] = [0, 0, 0, 0];
  let p: *u8 = &cell[0];
  mem.volatile_store_u32(p, 0x11223344);
  if (mem.volatile_load_u32(p) != 0x11223344) {
    return 1;
  }
  mem.volatile_store_u8(p, 0xAA);
  if (mem.volatile_load_u8(p) != 0xAA) {
    return 2;
  }
  let cell16: u8[2] = [0, 0];
  let p16: *u8 = &cell16[0];
  mem.volatile_store_u16(p16, (0xABCD as u16));
  if (mem.volatile_load_u16(p16) != (0xABCD as u16)) {
    return 3;
  }
  mem.compiler_fence();
  mem.fence_release();
  mem.fence_acquire();
  mem.fence_seq_cst();
  return 0;
}
