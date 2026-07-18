// Scheduler kernel — two tasks that switch between each other.
// Demonstrates context switch (switch_to) in a real scheduling scenario.

#[repr(C)]
struct MB1Header {
  magic: u32;
  flags: u32;
  checksum: u32;
};

#[link_section(".boot")]
const mb1: MB1Header = {
  magic: 0x1BADB002,
  flags: 0,
  checksum: 0xE4524FFE,
};

#[repr(C)]
struct Context {
  sp: u32;
};

/** Internal function `serial_putc`.
 * Implements `serial_putc`.
 * @param c u8
 * @return void
 */
function serial_putc(c: u8): void {
  unsafe { asm!("outb %%al, %%dx" : : "a"(c), "d"(0x3F8)); }
};

let ctx_main: Context = { sp: 0 };
let ctx_task1: Context = { sp: 0 };
let ctx_task2: Context = { sp: 0 };

/** Internal function `switch_to`.
 * Implements `switch_to`.
 * @param old *Context
 * @param new_ctx *Context
 * @return void
 */
#[used]
#[naked]
function switch_to(old: *Context, new_ctx: *Context): void {
  unsafe {
    asm!("movl 4(%esp), %eax; movl 8(%esp), %edx; pushl %ebp; pushl %ebx; pushl %esi; pushl %edi; movl %esp, (%eax); movl (%edx), %esp; popl %edi; popl %esi; popl %ebx; popl %ebp; ret");
  }
};

let task1_stack: u32 = 0;
let task2_stack: u32 = 0;
let schedule_count: u32 = 0;

/** Internal function `task1_entry`.
 * Implements `task1_entry`.
 * @return void
 */
#[used]
function task1_entry(): void {
  serial_putc(49);  // '1'
  switch_to(&ctx_task1, &ctx_task2);
  serial_putc(97);  // 'a'
  switch_to(&ctx_task1, &ctx_main);
};

/** Internal function `task2_entry`.
 * Implements `task2_entry`.
 * @return void
 */
#[used]
function task2_entry(): void {
  serial_putc(50);  // '2'
  switch_to(&ctx_task2, &ctx_task1);
  serial_putc(98);  // 'b'
  switch_to(&ctx_task2, &ctx_main);
};

/** Internal function `setup_task`.
 * Implements `setup_task`.
 * @param ctx *Context
 * @param entry_addr u32
 * @param stack_top u32
 * @return void
 */
function setup_task(ctx: *Context, entry_addr: u32, stack_top: u32): void {
  // Build initial stack: edi, esi, ebx, ebp (all 0), return address (entry)
  let sp: u32 = stack_top - 20;
  let p: *volatile u32 = (stack_top - 4) as *volatile u32;
  unsafe { *p = entry_addr; }   // return address
  let p2: *volatile u32 = (stack_top - 8) as *volatile u32;
  unsafe { *p2 = 0; }            // ebp
  let p3: *volatile u32 = (stack_top - 12) as *volatile u32;
  unsafe { *p3 = 0; }            // ebx
  let p4: *volatile u32 = (stack_top - 16) as *volatile u32;
  unsafe { *p4 = 0; }            // esi
  let p5: *volatile u32 = (stack_top - 20) as *volatile u32;
  unsafe { *p5 = 0; }            // edi
  let ctx_sp: *volatile u32 = ctx as *volatile u32;
  unsafe { *ctx_sp = sp; }
};

/** Internal function `kmain`.
 * Implements `kmain`.
 * @return i32
 */
function kmain(): i32 {
  serial_putc(83);  // S

  let t1_addr: u32 = 0;
  let t2_addr: u32 = 0;
  unsafe {
    asm!("mov $task1_entry, %0" : "=a"(t1_addr));
    asm!("mov $task2_entry, %0" : "=a"(t2_addr));
  }

  // Set up task stacks at fixed memory
  task1_stack = 0x70000;
  task2_stack = 0x78000;
  setup_task(&ctx_task1, t1_addr, task1_stack);
  setup_task(&ctx_task2, t2_addr, task2_stack);

  // Switch to task1 (saves main context)
  switch_to(&ctx_main, &ctx_task1);

  // Returns here after task1 yields back to main
  serial_putc(33);  // '!'
  serial_putc(10);  // newline
  return 0;
};

/** Internal function `start`.
 * Implements `start`.
 * @return void
 */
#[entry]
function start(): void {
  unsafe { asm!("mov $0x80000, %esp; call kmain; cli; hlt"); }
};
/** Internal function `main`.
 * Program/test entry point.
 * @param ) i32 { return kmain(
 * @return void
 */
function main(): i32 { return kmain() + mb1.magic as i32; }
