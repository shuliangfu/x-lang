// r04_simd_shuffle_select_stub.zig — scalar stub baseline (matches r04_simd_shuffle_select_stub.c)
// Pure scalar lane shuffle/select (no SIMD intrinsic). Baseline for STD-061.
const std = @import("std");

fn shuffle4f(v: [4]f32, mask: [4]i32) [4]f32 {
    var r: [4]f32 = undefined;
    var i: usize = 0;
    while (i < 4) : (i += 1) {
        r[i] = v[@intCast(mask[i])];
    }
    return r;
}

fn shuffle8i(v: [8]i32, mask: [8]i32) [8]i32 {
    var r: [8]i32 = undefined;
    var i: usize = 0;
    while (i < 8) : (i += 1) {
        r[i] = v[@intCast(mask[i])];
    }
    return r;
}

fn select4f(mask: [4]f32, a: [4]f32, b: [4]f32) [4]f32 {
    var r: [4]f32 = undefined;
    var i: usize = 0;
    while (i < 4) : (i += 1) {
        r[i] = if (mask[i] != 0.0) a[i] else b[i];
    }
    return r;
}

fn select8i(mask: [8]i32, a: [8]i32, b: [8]i32) [8]i32 {
    var r: [8]i32 = undefined;
    var i: usize = 0;
    while (i < 8) : (i += 1) {
        r[i] = if (mask[i] != 0) a[i] else b[i];
    }
    return r;
}

pub fn main() !void {
    const limit: i32 = 2_000_000;
    var acc: i32 = 0;
    var i: i32 = 0;
    const v4: [4]f32 = .{ 1.0, 2.0, 3.0, 4.0 };
    const v8: [8]i32 = .{ 0, 1, 2, 3, 4, 5, 6, 7 };
    const mask4: [4]f32 = .{ 1.0, 0.0, 1.0, 0.0 };
    const a4: [4]f32 = .{ 2.0, 2.0, 2.0, 2.0 };
    const b4: [4]f32 = .{ 0.5, 0.5, 0.5, 0.5 };
    const m4: [4]i32 = .{ 3, 2, 1, 0 };
    const m8: [8]i32 = .{ 3, 2, 1, 0, 7, 6, 5, 4 };
    const z8: [8]i32 = .{ 0, 0, 0, 0, 0, 0, 0, 0 };
    while (i < limit) : (i += 1) {
        const r4 = shuffle4f(v4, m4);
        const s4 = select4f(mask4, a4, b4);
        const r8 = shuffle8i(v8, m8);
        const s8 = select8i(m8, r8, z8);
        acc += r8[0] + s8[1] + @as(i32, @intFromFloat(r4[0])) + @as(i32, @intFromFloat(s4[0]));
    }
    std.process.exit(@intCast(acc & 0xFF));
}
