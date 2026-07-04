// x86_64 QEMU boot — 32-bit multiboot1 + long mode switch + 64-bit serial output.
// longmode_boot.s: _start (32-bit) -> long mode -> _start64 (64-bit) -> serial output.
// This file provides the multiboot1 header + kmain (for DCE prevention).

#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }
#[link_section(".boot")]
const mb1: MB1Header = { magic: 0x1BADB002, flags: 0, checksum: 0xE4524FFE, };

#[used]
function kmain(): i32 { return 0; }
function main(): i32 { return kmain() + mb1.magic as i32; }
