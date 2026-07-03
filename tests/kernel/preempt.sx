// Preemptive scheduler — timer switches between two tasks via pushal/iret.
#[repr(C)]
struct MB1Header { magic: u32; flags: u32; checksum: u32; }
#[link_section(".boot")]
const mb1: MB1Header = { magic: 0x1BADB002, flags: 0, checksum: 0xE4524FFE, };

#[used]
function kputc(c: u8): void { unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); } }

let tick_count: u32 = 0;
let current_task: u32 = 0;
let ctx_task1: u32 = 0;
let ctx_task2: u32 = 0;

#[used]
#[naked]
function timer_preempt(): void {
  unsafe {
    asm!("pushal; incl tick_count; movb $0x20, %al; outb %al, $0x20;
          movl current_task, %eax; cmpl $0, %eax; je from1;
          movl %esp, ctx_task2; movl ctx_task1, %esp; movl $0, current_task; jmp tdone;
          from1: movl %esp, ctx_task1; movl ctx_task2, %esp; movl $1, current_task;
          tdone: popal; iret");
  }
}

#[used]
function task1_loop(): void {
  unsafe { asm!("sti"); }
  while (0 == 0) {
    if (tick_count >= 20) {
      kputc(80); kputc(58); kputc(50); kputc(48); kputc(44); kputc(49); kputc(48); kputc(44); kputc(48); kputc(10);
      unsafe { asm!("cli; hlt"); }
    }
  }
}

#[used]
function task2_loop(): void {
  while (0 == 0) { }
}

// Stack format: pushal(32) + iret(12) = 44 bytes
function setup_task(ctx_sp: *volatile u32, entry: u32, stack_top: u32): void {
  unsafe {
    *((stack_top - 4) as *volatile u32) = 0x202;   // EFLAGS (IF=1)
    *((stack_top - 8) as *volatile u32) = 8;        // CS
    *((stack_top - 12) as *volatile u32) = entry;   // EIP
    *((stack_top - 16) as *volatile u32) = 0;       // EAX
    *((stack_top - 20) as *volatile u32) = 0;       // ECX
    *((stack_top - 24) as *volatile u32) = 0;       // EDX
    *((stack_top - 28) as *volatile u32) = 0;       // EBX
    *((stack_top - 32) as *volatile u32) = stack_top-32; // ESP (orig)
    *((stack_top - 36) as *volatile u32) = 0;       // EBP
    *((stack_top - 40) as *volatile u32) = 0;       // ESI
    *((stack_top - 44) as *volatile u32) = 0;       // EDI
    *ctx_sp = stack_top - 44;
  }
}

#[used]
function idt_set_entry(index: u32, handler: u32): void {
  let base: u32 = 0x90000 + index * 8;
  unsafe {
    *(base as *volatile u16) = (handler & 65535) as u16;
    *((base + 2) as *volatile u16) = 8;
    *((base + 4) as *volatile u8) = 0;
    *((base + 5) as *volatile u8) = 142;
    *((base + 6) as *volatile u16) = (handler >> 16) as u16;
  }
}

function kmain(): i32 {
  kputc(83); kputc(10);
  let ta: u32 = 0; unsafe { asm!("mov $timer_preempt, %0" : "=a"(ta)); }
  idt_set_entry(32, ta);
  unsafe { *(0x8F000 as *volatile u16) = 2047; *(0x8F002 as *volatile u32) = 0x90000; asm!("lidt 0x8F000"); }
  unsafe {
    asm!("outb %%al, $0x20" : : "a"(17)); asm!("outb %%al, $0xA0" : : "a"(17));
    asm!("outb %%al, $0x21" : : "a"(32)); asm!("outb %%al, $0xA1" : : "a"(40));
    asm!("outb %%al, $0x21" : : "a"(4));  asm!("outb %%al, $0xA1" : : "a"(2));
    asm!("outb %%al, $0x21" : : "a"(1));  asm!("outb %%al, $0xA1" : : "a"(1));
    asm!("outb %%al, $0x21" : : "a"(252)); asm!("outb %%al, $0xA1" : : "a"(255));
    asm!("outb %%al, $0x43" : : "a"(54)); asm!("outb %%al, $0x40" : : "a"(255)); asm!("outb %%al, $0x40" : : "a"(255));
  }
  let t1: u32 = 0; let t2: u32 = 0;
  unsafe { asm!("mov $task1_loop, %0" : "=a"(t1)); asm!("mov $task2_loop, %0" : "=a"(t2)); }
  setup_task((&ctx_task1) as *volatile u32, t1, 0x70000);
  setup_task((&ctx_task2) as *volatile u32, t2, 0x78000);
  current_task = 0;
  kputc(71);
  // Start task1 via iret: manually push iret frame and execute iret
  // After sti in task1, timer will preempt and switch between tasks
  unsafe {
    let sp: u32 = ctx_task1;
    asm!("movl %0, %%esp; popal; iret" : : "a"(sp) : "memory");
  }
  return 0;
}

#[entry]
function start(): void { unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); } }
function main(): i32 { return kmain() + mb1.magic as i32; }
