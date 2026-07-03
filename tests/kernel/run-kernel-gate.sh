#!/bin/sh
# G2: QEMU kernel gate — build each .sx kernel, boot in QEMU, verify serial output.
# Usage: run-kernel-gate.sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KERNEL_DIR="$SCRIPT_DIR"
WORKDIR="${TMPDIR:-/tmp}"
SHUX_C="$KERNEL_DIR/../../compiler/shux-c"
PASS=0
FAIL=0

# Each test: filename|expected_serial
run_test() {
    SX_FILE="$KERNEL_DIR/$1"
    EXPECTED="$2"
    ELF="$WORKDIR/gate_$1.elf"
    SERIAL="$WORKDIR/gate_$1.serial"
    NAME="$1"
    echo "=== GATE: $NAME ==="
    sh "$KERNEL_DIR/build-kernel.sh" "$SX_FILE" "$ELF" 2>&1
    rm -f "$SERIAL"
    qemu-system-x86_64 -kernel "$ELF" -no-reboot -display none \
        -serial file:"$SERIAL" &
    QPID=$!
    sleep 3
    kill "$QPID" 2>/dev/null
    wait "$QPID" 2>/dev/null
    ACTUAL="$(cat "$SERIAL" 2>/dev/null | sed 's/ *$//')"
    echo "  expected: $(printf '%s' "$EXPECTED" | tr '\n' '|')"
    echo "  actual:   $(printf '%s' "$ACTUAL" | tr '\n' '|')"
    if [ "$ACTUAL" = "$EXPECTED" ]; then
        echo "  PASS"
        PASS=$((PASS + 1))
    else
        echo "  FAIL"
        FAIL=$((FAIL + 1))
    fi
}

run_test "atomics.sx" "A:0,5
C:5,10"
run_test "timer_isr.sx" "Shux OS
T:1"
run_test "context_switch.sx" "S
A
B
a"
run_test "panic_serial.sx" "S
PANIC: 42"
run_test "bump_alloc.sx" "K:2097152,2097168"
run_test "spinlock.sx" "L:100"

# extern_asm test: needs .s assembly linking (special build)
echo "=== GATE: extern_asm.sx ==="
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$KERNEL_DIR/extern_asm.sx" > "$WORKDIR/extern_kernel.c"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -fno-stack-protector -c -o "$WORKDIR/extern_kernel.o" "$WORKDIR/extern_kernel.c"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$WORKDIR/asm_helper.o" "$KERNEL_DIR/asm_helper.s"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" zig cc -target x86-linux-gnu -ffreestanding -nostdlib -fno-sanitize=all -T "$KERNEL_DIR/kernel.ld" -o "$WORKDIR/gate_extern_asm.elf" "$WORKDIR/extern_kernel.o" "$WORKDIR/asm_helper.o" "$WORKDIR/shux_freestanding_stubs.o" 2>&1
rm -f "$WORKDIR/gate_extern_asm.serial"
qemu-system-x86_64 -kernel "$WORKDIR/gate_extern_asm.elf" -no-reboot -display none -serial file:"$WORKDIR/gate_extern_asm.serial" &
QPID=$!
sleep 3
kill "$QPID" 2>/dev/null
wait "$QPID" 2>/dev/null
ACTUAL="$(cat "$WORKDIR/gate_extern_asm.serial" 2>/dev/null)"
echo "  expected: H:17"
echo "  actual:   $ACTUAL"
if [ "$ACTUAL" = "H:17" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

# no_mangle_kernel test: needs .s assembly linking (like extern_asm)
echo "=== GATE: no_mangle_kernel.sx ==="
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" "$SHUX_C" -E "$KERNEL_DIR/no_mangle_kernel.sx" > "$WORKDIR/nm_kernel.c"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -fno-stack-protector -c -o "$WORKDIR/nm_kernel.o" "$WORKDIR/nm_kernel.c"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" zig cc -target x86-linux-gnu -ffreestanding -fno-sanitize=all -c -o "$WORKDIR/nm_mul.o" "$KERNEL_DIR/asm_multiply.s"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/zigcache}" zig cc -target x86-linux-gnu -ffreestanding -nostdlib -fno-sanitize=all -T "$KERNEL_DIR/kernel.ld" -o "$WORKDIR/gate_nm_kernel.elf" "$WORKDIR/nm_kernel.o" "$WORKDIR/nm_mul.o" "$WORKDIR/shux_freestanding_stubs.o" 2>&1
rm -f "$WORKDIR/gate_nm_kernel.serial"
qemu-system-x86_64 -kernel "$WORKDIR/gate_nm_kernel.elf" -no-reboot -display none -serial file:"$WORKDIR/gate_nm_kernel.serial" &
QPID=$!
sleep 3
kill "$QPID" 2>/dev/null
wait "$QPID" 2>/dev/null
ACTUAL="$(cat "$WORKDIR/gate_nm_kernel.serial" 2>/dev/null)"
echo "  expected: N:307,48"
echo "  actual:   $ACTUAL"
if [ "$ACTUAL" = "N:307,48" ]; then
    echo "  PASS"
    PASS=$((PASS + 1))
else
    echo "  FAIL"
    FAIL=$((FAIL + 1))
fi

run_test "vtable_dispatch.sx" "VT"
run_test "asm_sym.sx" "S:589824"
run_test "interrupt_handler.sx" "I:1"
run_test "panic_backtrace.sx" "S
PANIC:99
BT:00100645 0010067F 00100742 0010069A"
run_test "showcase.sx" "K:1,2097152"
run_test "percpu.sx" "P:12345"
run_test "membarrier.sx" "M:10,20"
run_test "shuxos.sx" "ShuxOS
T:1
DONE"
run_test "paging.sx" "P:80000011,80"
run_test "scheduler.sx" "S12a!"
run_test "gdt_syscall.sx" "G:H30"
run_test "usermode.sx" "K:GISUU42"
run_test "shuxos_v2.sx" "ShuxOS2
T:1,5,5
A:2097152,2097168
P:80000011
DONE"
run_test "ramfs.sx" "F:0,1,2,hello(2) test(4) [2]"
run_test "keyboard.sx" "K:hello
shux"
run_test "preempt.sx" "S
GP:20,10,0"
run_test "pmm.sx" "M:768,1048576,1052672,765,766,1052672"
run_test "vmm.sx" "V:00100000,0,12345"
run_test "intrinsics.sx" "I:00000011,0000000D,0,10,10,20"
run_test "bss_clear.sx" "B:0"
run_test "asm_goto.sx" "G:99"
run_test "bitfield.sx" "F:2,4096"

echo ""
echo "=== GATE SUMMARY: $PASS passed, $FAIL failed ==="
exit $FAIL
