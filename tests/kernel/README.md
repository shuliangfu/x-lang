# Shux Kernel Test Suite

30 QEMU-verified kernel tests + 14 gate scripts = 83 total checks, all passing.

## Quick Start

```sh
make kernel           # Run all QEMU kernel gate tests
make kernel-build X=tests/kernel/shuxos_v2.x  # Build single kernel
make kernel-check      # Static ELF + purity gate
make kernel64-check    # 64-bit code model gate
make kernel-smp        # SMP safety gate (-smp 2)
make kernel-stack-check  # #[max_stack] gate
make kernel-host-test  # Host-side unit test
make kernel-repro      # Reproducible build gate
make kernel-send-sync  # #[send]/#[sync] gate
make kernel-cross-arch # Cross-architecture gate
make kernel-uefi       # UEFI firmware gate
```

## Build Chain

```
kernel.x → shux-c -E → kernel.c → zig cc -target x86-linux-gnu -ffreestanding → kernel.o → zig cc -nostdlib -T kernel.ld → kernel.elf → qemu-system-x86_64 -kernel
```

## Test Catalog

### Language Features

| # | Test | Feature | Output |
|---|------|---------|--------|
| 1 | atomics.x | `lock xadd` / `lock cmpxchg` | A:0,5 / C:5,10 |
| 2 | timer_isr.x | `#[naked]` + IDT/PIC/PIT | Shux OS / T:1 |
| 3 | context_switch.x | `switch_to` naked+asm | S/A/B/a |
| 4 | panic_serial.x | `kpanic` serial output | S/PANIC: 42 |
| 5 | bump_alloc.x | Bump allocator + K8 .data init | K:2097152,2097168 |
| 6 | spinlock.x | `xchg` spinlock | L:100 |
| 7 | extern_asm.x | `extern` + hand-written .s | H:17 |
| 8 | no_mangle_kernel.x | `#[no_mangle]` + `#[link_name]` | N:307,48 |
| 9 | vtable_dispatch.x | Vtable + asm indirect call | VT |
| 10 | asm_sym.x | `sym` operand | S:589824 |
| 11 | interrupt_handler.x | `#[interrupt]` auto iret | I:1 |
| 12 | panic_backtrace.x | `ebp` frame chain backtrace | PANIC:99/BT:... |
| 13 | showcase.x | All kernel utils integrated | K:1,2097152 |
| 14 | percpu.x | `gs:` segment addressing | P:12345 |
| 15 | membarrier.x | `mfence`/`lfence`/`sfence` | M:10,20 |

### OS Features

| # | Test | Feature | Output |
|---|------|---------|--------|
| 16 | shuxos.x | VGA + serial + IDT + keyboard | ShuxOS/T:1/DONE |
| 17 | paging.x | 32-bit paging (4MB identity) | P:80000011,80 |
| 18 | scheduler.x | Cooperative 2-task scheduler | S12a! |
| 19 | gdt_syscall.x | GDT + syscall (int 0x80) | G:H30 |
| 20 | usermode.x | Ring 0→3 via IRET + user syscalls | K:GISUU42 |
| 21 | shuxos_v2.x | Comprehensive integration | ShuxOS2/T:1,5,5/A:.../P:.../DONE |
| 22 | ramfs.x | In-memory filesystem | F:0,1,2,hello(2) test(4) [2] |
| 23 | keyboard.x | Set 1 scancode → ASCII | K:hello/shux |
| 24 | preempt.x | Preemptive timer scheduler | S/GP:20,10,0 |
| 25 | pmm.x | Bitmap page frame allocator | M:768,1048576,... |
| 26 | vmm.x | Virtual memory map/unmap | V:00100000,0,12345 |

### Gate Scripts (non-QEMU)

| Script | Checks | Tests |
|--------|--------|-------|
| static-check-gate.sh | 7 | ELF sections, symbols, no libc |
| host-test-gate.sh | 1 | Host-side kernel logic unit test |
| kernel64-gate.sh | 6 | 64-bit code model, RIP-relative, no red zone |
| stack-check-gate.sh | 3 | `#[max_stack(N)]` attribute |
| reproducible-gate.sh | 1 | Bit-identical build |
| smp-gate.sh | 1 | SMP safety (-smp 2) |
| send_sync_gate.sh | 4 | `#[send]`/`#[sync]` attributes |
| cross-arch-gate.sh | 4 | x86/x86_64/arm64/riscv64 |
| uefi-gate.sh | 2 | UEFI firmware available + QEMU boot |

## Files

```
tests/kernel/
├── build-kernel.sh       # 32-bit kernel build script
├── build-kernel64.sh     # 64-bit kernel build script
├── kernel.ld             # 32-bit linker script (0x100000)
├── kernel64.ld           # 64-bit linker script (0xFFFFFFFF80000000)
├── kernel64_boot.s      # 32→64 bit transition boot code
├── freestanding_stubs.c  # libc stubs (abort/fprintf/...)
├── asm_helper.s          # Hand-written asm for extern_asm test
├── asm_multiply.s        # Hand-written asm for no_mangle test
├── kernel_lib.x         # Reusable kernel utility library
├── host_test.x          # Host-side unit test
├── stack_check.x        # #[max_stack] test
├── kernel64_check.x     # 64-bit code model test
├── *.x                  # 26 kernel test files
├── run-kernel-gate.sh    # QEMU kernel gate (26 tests)
├── static-check-gate.sh  # ELF static check + purity
├── host-test-gate.sh     # Host unit test gate
├── kernel64-gate.sh      # 64-bit code model gate
├── stack-check-gate.sh   # Stack usage gate
├── reproducible-gate.sh  # Reproducible build gate
├── smp-gate.sh           # SMP safety gate
├── send_sync_gate.sh     # Send/Sync gate
├── cross-arch-gate.sh    # Cross-architecture gate
└── uefi-gate.sh          # UEFI firmware gate
```

## Language Features Used

| Feature | Attribute/Keyword | Tests |
|---------|-------------------|-------|
| Inline assembly | `asm!(...)` | All kernels |
| Volatile pointers | `*volatile T` | VGA, IDT, PMM, VMM |
| Naked functions | `#[naked]` | context_switch, preempt, timer_isr |
| Entry point | `#[entry]` | All kernels |
| Used (no DCE) | `#[used]` | ISR handlers, task functions |
| Link section | `#[link_section(".boot")]` | Multiboot header |
| Interrupt | `#[interrupt]` | interrupt_handler, shuxos |
| No mangle | `#[no_mangle]` | no_mangle_kernel |
| Link name | `#[link_name("...")]` | no_mangle_kernel |
| Max stack | `#[max_stack(N)]` | stack_check |
| Send/Sync | `#[send]`/`#[sync]` | send_sync_gate |
| Repr C | `#[repr(C)]` | MB1Header, Context |
| Sym operand | `"sym"(var)` | asm_sym |
| Memory barriers | `asm!("mfence")` | membarrier |
