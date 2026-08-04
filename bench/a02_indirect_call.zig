// a02_indirect_call.zig — 与 bench/a02_indirect_call.x / .c 等价的 Zig 参照
// 间接调用/函数指针密集，N=100000000 次。
// 4 个函数 op_add/op_sub/op_mul/op_xor 放入函数指针表，
// 循环 N 次按 i&3 选择函数，累加结果。
// 使用 wrapping 算术（+% / -% / *%）以匹配 C/xlang 的 i32 溢出回绕语义。
const std = @import("std");

fn op_add(a: i32, b: i32) i32 { return a +% b; }
fn op_sub(a: i32, b: i32) i32 { return a -% b; }
fn op_mul(a: i32, b: i32) i32 { return a *% b; }
fn op_xor(a: i32, b: i32) i32 { return a ^ b; }

pub fn main() !void {
    const OpFn = *const fn (i32, i32) i32;
    const ops: [4]OpFn = .{ &op_add, &op_sub, &op_mul, &op_xor };
    const n: i32 = 100_000_000;
    var acc: i32 = 0;
    var i: i32 = 0;
    while (i < n) : (i += 1) {
        acc = ops[@intCast(i & 3)](acc, i);
    }
    std.process.exit(@intCast(acc & 0xFF));
}
