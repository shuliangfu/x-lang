// a04_wpo_scale_loop.zig — scale loop benchmark (matches a04_wpo_scale_loop.x)
// Tests WPO (whole-program optimization) on a simple scale function.
const std = @import("std");

fn scale(n: i32, k: i32) i32 {
    return n * k;
}

pub fn main() !void {
    const limit: i32 = 10_000_000;
    var s: i32 = 0;
    var i: i32 = 0;
    while (i < limit) : (i += 1) {
        s += scale(1024, 64);
    }
    std.process.exit(@intCast(s));
}
