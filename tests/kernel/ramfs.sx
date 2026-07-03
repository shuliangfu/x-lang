// Ramdisk filesystem — simple in-memory file storage.
// Demonstrates: file create/write/read/list, memory management, data structures.

#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }

#[link_section(".boot")]
const mb1: MB1Header = {
  magic: 0x1BADB002,
  flags: 0,
  checksum: 0xE4524FFE,
};

function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
}
function serial_putint(n: i32): void {
  if (n >= 10) { serial_putint(n / 10); }
  serial_putc((n % 10 + 48) as u8);
}

// Ramdisk: 16 files max, each up to 256 bytes, at 0x300000
const RAMDISK_BASE: u32 = 0x300000;
const RFS_MAX_FILES: u32 = 16;
const RFS_NAME_MAX: u32 = 32;
const RFS_DATA_MAX: u32 = 256;
const RFS_ENTRY_SIZE: u32 = 320;  // 32 name + 4 len + 4 used + 256 data + 24 pad

// File entry layout: name[32], data_len[4], used[4], data[256], pad[24]
function file_name_addr(index: u32): u32 {
  return RAMDISK_BASE + index * RFS_ENTRY_SIZE;
}
function file_data_len_addr(index: u32): u32 {
  return RAMDISK_BASE + index * RFS_ENTRY_SIZE + RFS_NAME_MAX;
}
function file_used_addr(index: u32): u32 {
  return RAMDISK_BASE + index * RFS_ENTRY_SIZE + RFS_NAME_MAX + 4;
}
function file_data_addr(index: u32): u32 {
  return RAMDISK_BASE + index * RFS_ENTRY_SIZE + RFS_NAME_MAX + 8;
}

function ramfs_init(): void {
  let i: u32 = 0;
  while (i < RFS_MAX_FILES) {
    let used: *volatile u32 = file_used_addr(i) as *volatile u32;
    unsafe { *used = 0; }
    i = i + 1;
  }
}

function ramfs_find_free(): i32 {
  let i: u32 = 0;
  while (i < RFS_MAX_FILES) {
    let used: *volatile u32 = file_used_addr(i) as *volatile u32;
    let u: u32 = 0;
    unsafe { u = *used; }
    if (u == 0) { return i as i32; }
    i = i + 1;
  }
  return -1;
}

function ramfs_write(name: u32, data: u32, len: u32): i32 {
  let idx: i32 = ramfs_find_free();
  if (idx < 0) { return -1; }
  let i: u32 = idx as u32;
  // Copy name
  let src: *volatile u8 = name as *volatile u8;
  let dst: *volatile u8 = file_name_addr(i) as *volatile u8;
  let j: u32 = 0;
  let ch: u8 = 0;
  unsafe { ch = *src; }
  while (ch != 0 && j < RFS_NAME_MAX) {
    unsafe { *dst = ch; }
    src = (src as u32 + 1) as *volatile u8;
    dst = (dst as u32 + 1) as *volatile u8;
    unsafe { ch = *src; }
    j = j + 1;
  }
  if (j < RFS_NAME_MAX) {
    unsafe { *dst = 0; }
  }
  // Copy data
  let dsrc: *volatile u8 = data as *volatile u8;
  let ddst: *volatile u8 = file_data_addr(i) as *volatile u8;
  let k: u32 = 0;
  while (k < len && k < RFS_DATA_MAX) {
    let b: u8 = 0;
    unsafe { b = *dsrc; }
    unsafe { *ddst = b; }
    dsrc = (dsrc as u32 + 1) as *volatile u8;
    ddst = (ddst as u32 + 1) as *volatile u8;
    k = k + 1;
  }
  // Set metadata
  let dl: *volatile u32 = file_data_len_addr(i) as *volatile u32;
  unsafe { *dl = k; }
  let used: *volatile u32 = file_used_addr(i) as *volatile u32;
  unsafe { *used = 1; }
  return idx;
}

function ramfs_read(index: u32): u32 {
  let used: *volatile u32 = file_used_addr(index) as *volatile u32;
  let u: u32 = 0;
  unsafe { u = *used; }
  if (u == 0) { return 0; }
  let dl: *volatile u32 = file_data_len_addr(index) as *volatile u32;
  let len: u32 = 0;
  unsafe { len = *dl; }
  return len;
}

function ramfs_list(): u32 {
  let count: u32 = 0;
  let i: u32 = 0;
  while (i < RFS_MAX_FILES) {
    let used: *volatile u32 = file_used_addr(i) as *volatile u32;
    let u: u32 = 0;
    unsafe { u = *used; }
    if (u != 0) {
      count = count + 1;
      // Print filename
      let p: *volatile u8 = file_name_addr(i) as *volatile u8;
      let ch: u8 = 0;
      unsafe { ch = *p; }
      while (ch != 0) {
        serial_putc(ch);
        p = (p as u32 + 1) as *volatile u8;
        unsafe { ch = *p; }
      }
      serial_putc(40);  // (
      let dl: *volatile u32 = file_data_len_addr(i) as *volatile u32;
      let len: u32 = 0;
      unsafe { len = *dl; }
      serial_putint(len as i32);
      serial_putc(41);  // )
      serial_putc(32);  // space
    }
    i = i + 1;
  }
  return count;
}

function kmain(): i32 {
  serial_putc(70);  // F
  serial_putc(58);  // :
  
  ramfs_init();
  
  // Create file 1: "hello" with content "Hi"
  let name1: u8[6] = [104, 101, 108, 108, 111, 0];  // "hello"
  let data1: u8[3] = [72, 105, 0];  // "Hi"
  let r1: i32 = ramfs_write((&name1[0]) as u32, (&data1[0]) as u32, 2);
  serial_putint(r1); serial_putc(44);
  
  // Create file 2: "test" with content "OK!!"
  let name2: u8[5] = [116, 101, 115, 116, 0];  // "test"
  let data2: u8[5] = [79, 75, 33, 33, 0];  // "OK!!"
  let r2: i32 = ramfs_write((&name2[0]) as u32, (&data2[0]) as u32, 4);
  serial_putint(r2); serial_putc(44);
  
  // Read file 0 length
  let len0: u32 = ramfs_read(0);
  serial_putint(len0 as i32); serial_putc(44);
  
  // List files
  let count: u32 = ramfs_list();
  serial_putc(91); serial_putint(count as i32); serial_putc(93);
  serial_putc(10);
  return 0;
}

#[entry]
function start(): void {
  unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); }
}
function main(): i32 { return kmain() + mb1.magic as i32; }
