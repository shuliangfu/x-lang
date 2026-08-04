// r04_simd_dot.zig — Vec4f dot product accumulation (matches r04_simd_dot.c / .x)
// Uses @Vector(4, f32) for SIMD; horizontal sum of 4 lanes.
const std = @import("std");

const Vec4f = @Vector(4, f32);

fn hsum4(v: Vec4f) f32 {
    return v[0] + v[1] + v[2] + v[3];
}

pub fn main() !void {
    const limit: i32 = 2_000_000;
    var sum: f32 = 0.0;
    var i: i32 = 0;
    while (i < limit) : (i += 1) {
        const t: f32 = @floatFromInt(@mod(i, 256));
        const a: Vec4f = .{ t, t + 1.0, t + 2.0, t + 3.0 };
        const b: Vec4f = .{ 0.5, 0.25, 0.125, 0.0625 };
        const p: Vec4f = a * b;
        sum += hsum4(p);
    }
    const sum_i: i32 = @intFromFloat(sum);
    std.process.exit(@intCast(sum_i & 0xFF));
}
