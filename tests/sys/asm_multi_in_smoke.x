/**
 * Stage10 10.2.1 slice2 probe: multi `in` operands.
 * Expect: mov $1 → rax; mov $2 → rax; mov rax→rdi; nop; return 42.
 * PLATFORM: LINUX|x86_64 gold (Ubuntu).
 */
export function main(): i32 {
  unsafe {
    asm!("nop", in("rax") 1, in("rdi") 2);
  }
  return 42;
}
