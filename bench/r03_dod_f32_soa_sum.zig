// r03_dod_f32_soa_sum.zig — DOD SoA sum (f32) benchmark (matches r03_dod_f32_soa_sum.x)
// Struct-of-Arrays layout with f32 fields: sum field x over 4096 particles.
const std = @import("std");

const n: usize = 4096;
var xs: [n]f32 = undefined;
var ys: [n]f32 = undefined;
var zs: [n]f32 = undefined;

pub fn main() !void {
    const one: f32 = 1.0;
    const two: f32 = 2.0;
    const three: f32 = 3.0;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        xs[i] = one;
        ys[i] = two;
        zs[i] = three;
    }
    var s: f32 = 0.0;
    i = 0;
    while (i < n) : (i += 1) {
        s += xs[i];
    }
    const si: i32 = @intFromFloat(s);
    std.process.exit(@intCast(@divTrunc(si, 256)));
}
