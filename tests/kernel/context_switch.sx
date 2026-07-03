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

#[repr(C)]
struct Context {
  sp: u32;
}

let ctx_a: Context = { sp: 0 };
let ctx_b: Context = { sp: 0 };

function serial_putc(c: u8): void {
  unsafe {
    asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8));
  }
}

#[used]
#[naked]
function switch_to(old: *Context, new_ctx: *Context): void {
  unsafe {
    asm!("movl 4(%esp), %eax; movl 8(%esp), %edx; pushl %ebp; pushl %ebx; pushl %esi; pushl %edi; movl %esp, (%eax); movl (%edx), %esp; popl %edi; popl %esi; popl %ebx; popl %ebp; ret");
  }
}

#[used]
function thread_b(): void {
  serial_putc(66);
  serial_putc(10);
  switch_to(&ctx_b, &ctx_a);
  serial_putc(98);
  serial_putc(10);
  unsafe { asm!("cli; hlt"); }
}

function kmain(): i32 {
  serial_putc(83);
  serial_putc(10);
  let b_addr: u32 = 0;
  unsafe {
    asm!("mov $thread_b, %0" : "=a"(b_addr));
  }
  let stack_top: u32 = 0x71000;
  let p0: *volatile u32 = (stack_top - 4) as *volatile u32;
  unsafe { *p0 = b_addr; }
  let p1: *volatile u32 = (stack_top - 8) as *volatile u32;
  unsafe { *p1 = 0; }
  let p2: *volatile u32 = (stack_top - 12) as *volatile u32;
  unsafe { *p2 = 0; }
  let p3: *volatile u32 = (stack_top - 16) as *volatile u32;
  unsafe { *p3 = 0; }
  let p4: *volatile u32 = (stack_top - 20) as *volatile u32;
  unsafe { *p4 = 0; }
  ctx_b.sp = stack_top - 20;
  serial_putc(65);
  serial_putc(10);
  switch_to(&ctx_a, &ctx_b);
  serial_putc(97);
  serial_putc(10);
  unsafe { asm!("cli; hlt"); }
  return 0;
}

#[entry]
function start(): void {
  unsafe {
    asm!("mov $0x80000, %esp; call kmain; cli; hlt");
  }
}

function main(): i32 { return kmain() + mb1.magic as i32; }
