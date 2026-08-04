// a04_wpo_vec_lane0_loop.zig — vec add + lane0 extract loop (matches a04_wpo_vec_lane0_loop.x)
// Tests WPO with i32x4 vector add and lane0 extraction.
const std = @import("std");

const i32x4 = @Vector(4, i32);

fn vec_add4(a: i32x4, b: i32x4) i32x4 {
    return a + b;
}

fn lane0(v: i32x4) i32 {
    return v[0];
}

pub fn main() !void {
    const limit: i32 = 10_000_000;
    var s: i32 = 0;
    var i: i32 = 0;
    while (i < limit) : (i += 1) {
        s += lane0(vec_add4(.{ 1, 2, 3, 4 }, .{ 10, 20, 30, 40 }));
    }
    if (s != 110_000_000) {
        std.process.exit(1);
    }
}
