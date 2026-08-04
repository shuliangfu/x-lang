// r04_simd_shuffle_select.zig — SIMD shuffle/select with @Vector (matches r04_simd_shuffle_select.x)
// Uses Zig @Vector + @shuffle + element-wise select.
const std = @import("std");

const Vec4f = @Vector(4, f32);
const Vec8i = @Vector(8, i32);

pub fn main() !void {
    const limit: i32 = 2_000_000;
    var acc: i32 = 0;
    var i: i32 = 0;
    const v4: Vec4f = .{ 1.0, 2.0, 3.0, 4.0 };
    const v8: Vec8i = .{ 0, 1, 2, 3, 4, 5, 6, 7 };
    const m4_mask: Vec4f = .{ 1.0, 0.0, 1.0, 0.0 };
    const a4: Vec4f = .{ 2.0, 2.0, 2.0, 2.0 };
    const b4: Vec4f = .{ 0.5, 0.5, 0.5, 0.5 };
    // shuffle indices (compile-time for @shuffle)
    const m4: [4]i32 = .{ 3, 2, 1, 0 };
    const m8: [8]i32 = .{ 3, 2, 1, 0, 7, 6, 5, 4 };
    const z8: Vec8i = @splat(0);
    const o8: Vec8i = @splat(1);
    while (i < limit) : (i += 1) {
        // Scalar shuffle (Zig @shuffle needs comptime mask; emulate for dynamic)
        var r4: Vec4f = undefined;
        r4[0] = v4[@intCast(m4[0])];
        r4[1] = v4[@intCast(m4[1])];
        r4[2] = v4[@intCast(m4[2])];
        r4[3] = v4[@intCast(m4[3])];
        // select: mask != 0 ? a : b
        const s4: Vec4f = .{
            if (m4_mask[0] != 0.0) a4[0] else b4[0],
            if (m4_mask[1] != 0.0) a4[1] else b4[1],
            if (m4_mask[2] != 0.0) a4[2] else b4[2],
            if (m4_mask[3] != 0.0) a4[3] else b4[3],
        };
        var r8: Vec8i = undefined;
        r8[0] = v8[@intCast(m8[0])];
        r8[1] = v8[@intCast(m8[1])];
        r8[2] = v8[@intCast(m8[2])];
        r8[3] = v8[@intCast(m8[3])];
        r8[4] = v8[@intCast(m8[4])];
        r8[5] = v8[@intCast(m8[5])];
        r8[6] = v8[@intCast(m8[6])];
        r8[7] = v8[@intCast(m8[7])];
        // select: splat(1) != 0 ? r8 : splat(0)
        const s8: Vec8i = @select(i32, o8 > z8, r8, z8);
        acc += r8[0] + s8[1] + @as(i32, @intFromFloat(r4[0])) + @as(i32, @intFromFloat(s4[0]));
    }
    std.process.exit(@intCast(acc & 0xFF));
}
