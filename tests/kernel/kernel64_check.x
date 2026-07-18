#[repr(C)]
struct MB1Header {
  magic: u32;
  flags: u32;
  checksum: u32;
}

#[link_section(".boot")]
const mb1: MB1Header = {
  magic: 0x1BADB002,
  flags: 0,
  checksum: 0xE4524FFE,
};

let data_var: u32 = 42;

/** Internal function `read_data`.
 * Read path helper `read_data`.
 * @return u32
 */
function read_data(): u32 {
  return data_var;
}

/** Internal function `kmain`.
 * Implements `kmain`.
 * @return i32
 */
function kmain(): i32 {
  let val: u32 = read_data();
  return val as i32;
}

#[entry]
/** Internal function `start`.
 * Implements `start`.
 * @return void
 */
function start(): void {
  unsafe {
    asm!("call kmain; cli; hlt");
  }
}

/** Internal function `main`.
 * Program/test entry point.
 * @param ) i32 { return kmain(
 * @return void
 */
function main(): i32 { return kmain() + mb1.magic as i32; }
