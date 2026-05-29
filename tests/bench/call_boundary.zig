// call_boundary.zig — 与 tests/bench/call_boundary.su 对齐
const std = @import("std");

fn f0(x: i32) i32 {
    return x + 1;
}
fn f1(x: i32) i32 {
    return f0(x) + 1;
}
fn f2(x: i32) i32 {
    return f1(x) + 1;
}
fn f3(x: i32) i32 {
    return f2(x) + 1;
}
fn f4(x: i32) i32 {
    return f3(x) + 1;
}

pub fn main() !void {
    const n: i32 = 200_000_000;
    var s: i32 = 0;
    var i: i32 = 0;
    while (i < n) : (i += 1) {
        s += f4(i);
    }
    std.process.exit(@intCast(s));
}
