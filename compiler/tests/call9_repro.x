// call9_repro.x — nine-arg extern call smoke (ARM64 AAPCS stack args).
// PLATFORM: SHARED ABI shape; stack args matter most on ARM64.
extern function io_register_buffers_4(p0: *u8, l0: usize, p1: *u8, l1: usize, p2: *u8, l2: usize,
p3: *u8, l3: usize, nr: u32): i32;

/**
 * Call a 9-parameter extern with null buffers and zero lengths.
 * Returns the extern result (typically 0 or platform errno-style).
 */
function main(): i32 {
  return io_register_buffers_4(0 as *u8, 0, 0 as *u8, 0, 0 as *u8, 0, 0 as *u8, 0, 0);
}
