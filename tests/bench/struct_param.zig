// struct_param.zig — 与 tests/bench/struct_param.su 对齐
const std = @import("std");

const Pair = struct { a: i32, b: i32 };

fn addPair(p: Pair) i32 {
    return p.a + p.b;
}

pub fn main() !void {
    const n: i32 = 100_000_000;
    var s: i32 = 0;
    var i: i32 = 0;
    const p = Pair{ .a = 1, .b = 2 };
    while (i < n) : (i += 1) {
        s += addPair(p);
    }
    std.process.exit(@intCast(s));
}
