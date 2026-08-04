// r03_dod_aos_sum.zig — DOD AoS sum (i32) benchmark (matches r03_dod_aos_sum.x)
// Array-of-Structs layout: sum field x over 4096 particles.
const std = @import("std");

const Particle = extern struct {
    x: i32,
    y: i32,
    z: i32,
};

pub fn main() !void {
    const n: usize = 4096;
    var arr: [n]Particle = undefined;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        arr[i].x = 1;
        arr[i].y = 2;
        arr[i].z = 3;
    }
    var s: i32 = 0;
    i = 0;
    while (i < n) : (i += 1) {
        s += arr[i].x;
    }
    std.process.exit(@intCast(@divTrunc(s, 256)));
}
