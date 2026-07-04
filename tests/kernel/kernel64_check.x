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

function read_data(): u32 {
  return data_var;
}

function kmain(): i32 {
  let val: u32 = read_data();
  return val as i32;
}

#[entry]
function start(): void {
  unsafe {
    asm!("call kmain; cli; hlt");
  }
}

function main(): i32 { return kmain() + mb1.magic as i32; }
