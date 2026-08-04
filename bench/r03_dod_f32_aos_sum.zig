// r03_dod_f32_aos_sum.zig — DOD AoS sum (f32) benchmark (matches r03_dod_f32_aos_sum.x)
// Array-of-Structs layout with f32 fields: sum field x over 4096 particles.
const std = @import("std");

const Particle = extern struct {
    x: f32,
    y: f32,
    z: f32,
};

pub fn main() !void {
    const n: usize = 4096;
    var arr: [n]Particle = undefined;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        arr[i].x = 1.0;
        arr[i].y = 2.0;
        arr[i].z = 3.0;
    }
    var s: f32 = 0.0;
    i = 0;
    while (i < n) : (i += 1) {
        s += arr[i].x;
    }
    const si: i32 = @intFromFloat(s);
    std.process.exit(@intCast(@divTrunc(si, 256)));
}
